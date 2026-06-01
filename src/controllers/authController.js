const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const env = require('../config/env');
const userModel = require('../models/userModel');
const otpStore = require('../models/otpStore');

const issueTokens = (user) => {
  const payload = { sub: user.id, email: user.email };

  const accessToken = jwt.sign(payload, env.jwtSecret, {
    expiresIn: env.jwtAccessExpiresIn
  });

  const refreshToken = jwt.sign(payload, env.jwtRefreshSecret, {
    expiresIn: env.jwtRefreshExpiresIn
  });

  return { accessToken, refreshToken };
};

const signup = async (req, res, next) => {
  try {
    const { email, phone, name, password } = req.body;

    const existingUser = await userModel.findByEmail(email);
    if (existingUser) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const otp = String(Math.floor(100000 + Math.random() * 900000));

    otpStore.setPendingSignup({
      email,
      phone,
      name,
      passwordHash,
      otp
    });

    return res.status(201).json({
      message: 'Signup initiated. Verify OTP to complete account creation.',
      otp
    });
  } catch (error) {
    return next(error);
  }
};

const verifyOtp = async (req, res, next) => {
  try {
    const { email, otp } = req.body;
    const pendingSignup = otpStore.getPendingSignup(email);

    if (!pendingSignup || pendingSignup.otp !== otp) {
      return res.status(400).json({ error: 'Invalid OTP or signup session expired' });
    }

    const user = await userModel.createUser({
      email: pendingSignup.email,
      phone: pendingSignup.phone,
      name: pendingSignup.name,
      passwordHash: pendingSignup.passwordHash
    });

    otpStore.clearPendingSignup(email);

    const tokens = issueTokens(user);

    return res.status(200).json({
      message: 'OTP verified and account created successfully.',
      user,
      ...tokens
    });
  } catch (error) {
    return next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await userModel.findByEmail(email);

    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const tokens = issueTokens(user);

    return res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        name: user.name
      },
      ...tokens
    });
  } catch (error) {
    return next(error);
  }
};

const refreshToken = (req, res) => {
  const { refreshToken: token } = req.body;

  if (!token) {
    return res.status(400).json({ error: 'refreshToken is required' });
  }

  try {
    const payload = jwt.verify(token, env.jwtRefreshSecret);
    const accessToken = jwt.sign(
      { sub: payload.sub, email: payload.email },
      env.jwtSecret,
      { expiresIn: env.jwtAccessExpiresIn }
    );

    return res.status(200).json({ accessToken });
  } catch (_error) {
    return res.status(401).json({ error: 'Invalid refresh token' });
  }
};

const googleOAuth = (_req, res) => {
  return res.status(501).json({
    message: 'Google OAuth flow scaffolded. Integrate passport/google strategy next.',
    configPresent: Boolean(env.googleClientId && env.googleClientSecret && env.googleCallbackUrl)
  });
};

module.exports = {
  signup,
  verifyOtp,
  login,
  refreshToken,
  googleOAuth
};
