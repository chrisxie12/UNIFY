const express = require('express');
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const schoolRoutes = require('./schoolRoutes');
const unitRoutes = require('./unitRoutes');

const router = express.Router();

router.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/schools', schoolRoutes);
router.use('/units', unitRoutes);

module.exports = router;
