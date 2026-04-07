// Imports.
const bcrypt = require("bcryptjs");
const { connect, checkUserExistence } = require("../db/usr.js");
const jwt = require("jsonwebtoken");

// Function to log a user in.
const login = async (req, res) => {
  const { username, password } = req.body;

  if (typeof username !== "string" || typeof password !== "string") {
    return res.sendStatus(400);
  }

  try {
    await connect();
    const user = await checkUserExistence(username);

    if (!user || !await bcrypt.compare(password, user.password)) {
      return res.sendStatus(401);
    }

    if (!user.isVerified) {
      return res.status(403).json({ error: "EMAIL_NOT_VERIFIED" });
    }

    // Create JWT
    const token = jwt.sign(
      { id: user._id, type: "auth" },
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