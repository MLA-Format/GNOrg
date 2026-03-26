// Imports.
const bcrypt = require("bcryptjs");
const { connect, checkUserExistence } = require("../db/usr.js");
const jwt = require("jsonwebtoken");

// Function to log a user in.
const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    await connect();
    const user = await checkUserExistence(username);

    if (!user || !await bcrypt.compare(password, user.password)) {
      return res.sendStatus(401);
    }

    // Create JWT
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "30m" }
    );

    res.status(200).json({ token });
  } catch (err) {
    console.error("Login error:", err);
    res.sendStatus(500);
  }
};

module.exports = { login };