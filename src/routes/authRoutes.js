const express = require('express');
const authController = require('../controllers/authController');
const { validateRequest } = require('../middleware/validateRequest');
const {
  signupValidator,
  verifyOtpValidator,
  loginValidator,
  refreshTokenValidator
} = require('../validators/authValidators');

const router = express.Router();

router.post('/signup', signupValidator, validateRequest, authController.signup);
router.post('/verify-otp', verifyOtpValidator, validateRequest, authController.verifyOtp);
router.post('/login', loginValidator, validateRequest, authController.login);
router.post('/refresh-token', refreshTokenValidator, validateRequest, authController.refreshToken);
router.get('/google', authController.googleOAuth);

module.exports = router;
