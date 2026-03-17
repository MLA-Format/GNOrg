const { MongoClient } = require("mongodb");
const client = new MongoClient(process.env.MONGODB_URL);
const { hashPassword } = require("../utils/hashPassword.js");

const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    await client.connect();

    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const userExists = await users.findOne({username, password: hashPassword(password)})
    if (userExists)
      res.status(200).json();
    else
      res.status(401).json({message: "LOGIN_INVALID"});
  } catch (err) {
    res.status(500).json({ message: "Internal server error" });
  }
}