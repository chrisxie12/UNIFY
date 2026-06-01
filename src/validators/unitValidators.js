const { param } = require('express-validator');

const schoolIdParamValidator = [
  param('schoolId')
    .isInt({ min: 1 })
    .withMessage('schoolId must be a positive integer')
];

module.exports = {
  schoolIdParamValidator
};
