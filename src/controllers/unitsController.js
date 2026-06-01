const unitModel = require('../models/unitModel');

const listUnitsBySchool = async (req, res, next) => {
  try {
    const units = await unitModel.listBySchoolId(req.params.schoolId);
    return res.status(200).json(units);
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  listUnitsBySchool
};
