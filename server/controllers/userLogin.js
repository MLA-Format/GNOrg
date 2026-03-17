const { MongoClient } = require("mongodb");
const client = new MongoClient(process.env.MONGODB_URL);
const bcrypt = require("bcryptjs");

const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    await client.connect();

    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const user = await users.findOne({username})
    if (!user || !await bcrypt.compare(password, user.password))
      return res.status(401).json({message: "LOGIN_INVALID"});
    res.status(200).json();
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
}

module.exports = { login };