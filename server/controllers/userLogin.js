const bcrypt = require("bcryptjs");
const { connect, checkUserExistence } = require("../db/usr.js");

const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    await connect();
    const user = await checkUserExistence(username);
    if (!user || !await bcrypt.compare(password, user.password))
      return res.status(401).json({message: "LOGIN_INVALID"});
    res.status(200).json();
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
}

module.exports = { login };