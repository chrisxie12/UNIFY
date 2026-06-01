const pendingSignups = new Map();

const setPendingSignup = ({ email, phone, name, passwordHash, otp }) => {
  pendingSignups.set(email.toLowerCase(), {
    email: email.toLowerCase(),
    phone,
    name,
    passwordHash,
    otp,
    createdAt: Date.now()
  });
};

const getPendingSignup = (email) => pendingSignups.get(email.toLowerCase());

const clearPendingSignup = (email) => pendingSignups.delete(email.toLowerCase());

module.exports = {
  setPendingSignup,
  getPendingSignup,
  clearPendingSignup
};
