const express = require('express');
const schoolsController = require('../controllers/schoolsController');

const router = express.Router();

router.get('/', schoolsController.listSchools);

module.exports = router;
