const { body } = require('express-validator');

const signupValidator = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('phone').isString().trim().notEmpty().withMessage('Phone is required'),
  body('name').isString().trim().notEmpty().withMessage('Name is required'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
];

const verifyOtpValidator = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('otp')
    .isString()
    .matches(/^\d{6}$/)
    .withMessage('OTP must be a 6-digit code')
];

const loginValidator = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').isString().notEmpty().withMessage('Password is required')
];

const refreshTokenValidator = [
  body('refreshToken').isString().notEmpty().withMessage('refreshToken is required')
];

module.exports = {
  signupValidator,
  verifyOtpValidator,
  loginValidator,
  refreshTokenValidator
};
