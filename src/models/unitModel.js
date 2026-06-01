const db = require('../config/db');

const listBySchoolId = async (schoolId) => {
  const { rows } = await db.query(
    `SELECT id, school_id, user_id, joined_at
     FROM units
     WHERE school_id = $1
     ORDER BY joined_at DESC`,
    [schoolId]
  );

  return rows;
};

module.exports = {
  listBySchoolId
};
