const { MongoClient } = require("mongodb");
const bcrypt = require("bcryptjs");
const client = new MongoClient(process.env.MONGODB_URL);

const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const userExists = users.findOne(username, )
  } catch (err) {

  }
}