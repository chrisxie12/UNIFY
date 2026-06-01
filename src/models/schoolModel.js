const db = require('../config/db');

const listAll = async () => {
  const { rows } = await db.query(
    'SELECT id, name, type, region, created_at FROM schools ORDER BY name ASC'
  );
  return rows;
};

module.exports = {
  listAll
};
