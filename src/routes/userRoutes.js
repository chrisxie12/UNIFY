const express = require('express');
const usersController = require('../controllers/usersController');
const { requireAuth } = require('../middleware/authMiddleware');
const { validateRequest } = require('../middleware/validateRequest');
const {
  userIdParamValidator,
  updateUserValidator
} = require('../validators/userValidators');

const router = express.Router();

router.get('/:id', requireAuth, userIdParamValidator, validateRequest, usersController.getUserProfile);
router.put('/:id', requireAuth, updateUserValidator, validateRequest, usersController.updateUserProfile);

module.exports = router;
