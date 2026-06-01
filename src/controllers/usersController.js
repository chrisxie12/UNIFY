const userModel = require('../models/userModel');

const getUserProfile = async (req, res, next) => {
  try {
    const user = await userModel.getById(req.params.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.status(200).json(user);
  } catch (error) {
    return next(error);
  }
};

const updateUserProfile = async (req, res, next) => {
  try {
    const user = await userModel.updateById(req.params.id, req.body);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.status(200).json(user);
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getUserProfile,
  updateUserProfile
};
