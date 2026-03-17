const { MongoClient } = require("mongodb");
const { getVerificationToken } = require("../models/user.js");
const { sendEmail } = require("../utils/emailVerification.js");
const client = new MongoClient(process.env.MONGODB_URL);
const jwt = require("jsonwebtoken");
const { hashPassword } = require("../utils/hashPassword.js");

const registerUser = async (req, res) => {
  const { username, password, email } = req.body;


  try {
    await client.connect();
    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const userExists = await users.findOne({ username });
    if (userExists) {
      res.status(400).json({ message: "USER_TAKEN" });
      return;
    }

    const emailExists = await users.findOne({ email });
    if (emailExists) {
      res.status(400).json({ message: "EMAIL_ASC." });
      return;
    }

    const insertedUser = await users.insertOne({
      username,
      email,
      password: await hashPassword(password),
      isVerified: false,
    });

    const newUser = await users.findOne({ _id: insertedUser.insertedId });

    if (newUser) {
      const token = getVerificationToken(newUser);

      const verificationUrl = `${process.env.FRONTEND_URL}/verify-email/${token}`;

      await sendEmail({
        email: newUser.email,
        subject: "Email Verification",
        message: `Please verify your email by clicking the following link: ${verificationUrl}`,
      });

      res.status(201).json({ success: true });
    }
  } catch (err) {
    console.error("Registration error:", err);
    res.status(500).json({ message: err.message });
  }
}

const verifyEmail = async (req, res) => {

  try {

    const decoded = jwt.verify(req.params.token, process.env.JWT_SECRET);

    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const { ObjectId } = require("mongodb");

    await users.updateOne(
      { _id: new ObjectId(decoded.id) },
      { $set: { isVerified: true } }
    );

    res.status(200).json({ success: true });
  } catch (err) {
    console.error("Registration error:", err);
    res.status(400).json({ message: "Invalid or expired token." });
  }
}

module.exports = { registerUser, verifyEmail };