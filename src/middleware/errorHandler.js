const errorHandler = (err, _req, res, _next) => {
  const statusCode = err.statusCode || 500;
  const message = statusCode === 500 ? 'Internal server error' : err.message;

  if (process.env.NODE_ENV !== 'test') {    console.error(err);
  }

  res.status(statusCode).json({ error: message });
};

module.exports = {
  errorHandler
};
