const db = require('../config/db');

const toUserProfile = (row) => {
  if (!row) return null;

  return {
    id: row.id,
    email: row.email,
    phone: row.phone,
    name: row.name,
    bio: row.bio,
    avatar: row.avatar,
    hometown: row.hometown,
    interests: row.interests || [],
    createdAt: row.created_at
  };
};

const createUser = async ({ email, phone, name, passwordHash }) => {
  const { rows } = await db.query(
    `INSERT INTO users (email, phone, name, password_hash)
     VALUES ($1, $2, $3, $4)
     RETURNING id, email, phone, name, bio, avatar, hometown, interests, created_at`,
    [email, phone, name, passwordHash]
  );

  return toUserProfile(rows[0]);
};

const findByEmail = async (email) => {
  const { rows } = await db.query('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
  return rows[0] || null;
};

const getById = async (id) => {
  const { rows } = await db.query(
    `SELECT id, email, phone, name, bio, avatar, hometown, interests, created_at
     FROM users
     WHERE id = $1`,
    [id]
  );

  return toUserProfile(rows[0]);
};

const updateById = async (id, updates) => {
  const keys = ['name', 'bio', 'avatar', 'hometown', 'interests'];
  const setClauses = [];
  const values = [];

  keys.forEach((key) => {
    if (updates[key] !== undefined) {
      values.push(updates[key]);
      setClauses.push(`${key} = $${values.length}`);
    }
  });

  if (setClauses.length === 0) {
    return getById(id);
  }

  values.push(id);

  const { rows } = await db.query(
    `UPDATE users
     SET ${setClauses.join(', ')}
     WHERE id = $${values.length}
     RETURNING id, email, phone, name, bio, avatar, hometown, interests, created_at`,
    values
  );

  return toUserProfile(rows[0]);
};

module.exports = {
  createUser,
  findByEmail,
  getById,
  updateById
};
