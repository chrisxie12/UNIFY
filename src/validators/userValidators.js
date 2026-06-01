const { body, param } = require('express-validator');

const userIdParamValidator = [
  param('id').isInt({ min: 1 }).withMessage('User id must be a positive integer')
];

const updateUserValidator = [
  ...userIdParamValidator,
  body('name').optional().isString().trim().notEmpty(),
  body('bio').optional().isString(),
  body('avatar').optional().isURL(),
  body('hometown').optional().isString(),
  body('interests').optional().isArray()
];

module.exports = {
  userIdParamValidator,
  updateUserValidator
};
