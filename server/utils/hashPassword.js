// Imports.
const bcrypt = require("bcryptjs");

// Function to hash a password.
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(12);
  return await bcrypt.hash(password, salt);
};

module.exports = { hashPassword };