const { MongoClient } = require("mongodb");
const bcrypt = require("bcryptjs");
const { getVerificationToken } = require("../models/user.js");
const { sendEmail } = require("../utils/emailVerification.js");
const client = new MongoClient(process.env.MONGODB_URL);
const crypto = require("crypto");

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(12);
  return await bcrypt.hash(password, salt);
};

const registerUser = async (req, res) => {
  const { username, password, email } = req.body;


  try {
    await client.connect();
    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const userExists = await users.findOne({ username });
    if (userExists) {
      res.status(400).json({ message: "Invalid or expired token." });
      throw new Error("User already exists.");
    }

    const emailExists = await users.findOne({ email });
    if (emailExists) {
      res.status(400).json({ message: "Invalid or expired token." });
      throw new Error("Email already used.");
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

      await users.updateOne(
        { _id: newUser._id },
        {
          $set: {
            verificationToken: newUser.verificationToken,
            verificationTokenExpire: newUser.verificationTokenExpire,
          },
        },
      );

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
    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const hashedToken = crypto
      .createHash("sha256")
      .update(req.params.token)
      .digest("hex");

    const user = await users.findOne({
      verificationToken: hashedToken,
      verificationTokenExpire: { $gt: Date.now() },
    });

    if (!user) {
      res.status(400).json({ message: "Invalid or expired token." });
      return;
    }

    await users.updateOne({ _id: user._id }, {
        $set: { isVerified: true },
        $unset: { verificationToken: "", verificationTokenExpire: "" }
    });

    res.status(200).json({ success: true });
  } catch (err) {
    console.error("Registration error:", err);
    res.status(500).json({ message: err.message });
  }
}

module.exports = { registerUser, verifyEmail };