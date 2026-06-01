const schoolModel = require('../models/schoolModel');

const listSchools = async (_req, res, next) => {
  try {
    const schools = await schoolModel.listAll();
    return res.status(200).json(schools);
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  listSchools
};
