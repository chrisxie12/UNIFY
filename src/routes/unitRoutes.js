const express = require('express');
const unitsController = require('../controllers/unitsController');
const { validateRequest } = require('../middleware/validateRequest');
const { schoolIdParamValidator } = require('../validators/unitValidators');

const router = express.Router();

router.get('/:schoolId', schoolIdParamValidator, validateRequest, unitsController.listUnitsBySchool);

module.exports = router;
