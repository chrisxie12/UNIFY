const { Pool } = require('pg');
const env = require('./env');

const pool = new Pool(
  env.databaseUrl
    ? {
        connectionString: env.databaseUrl,
        ssl: env.nodeEnv === 'production' ? { rejectUnauthorized: false } : false
      }
    : undefined
);

const query = (text, params) => pool.query(text, params);

module.exports = {
  pool,
  query
};
