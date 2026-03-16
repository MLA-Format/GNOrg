const { MongoClient } = require("mongodb");
const dbUrl = process.env.MONGODB_URL;
const bcrypt = require("bcryptjs");
const { getVerificationToken } = require("../models/user.js");

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(12);
  return await bcrypt.hash(password, salt);
};

async function registerUser() {
  const { username, password, email } = req.body;

  const client = new MongoClient(dbUrl);

  try {
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

      const verificationUrl = "";

      await sendEmail({
        email: newUser.email,
        subject: "Email Verification",
        message: `Please verify your email by clicking the following link: ${verificationUrl}`,
      });

      res.status(201).json({ success: true });
    }
  } catch {
    await client.close();
  }
}

const verifyEmail = asyncHandler(async (req, res) => {
  const client = new MongoClient(dbUrl);

  try {
    const db = client.db("GNOrgDB");
    const users = db.collection("usr");

    const hashedToken = crypto
      .createHash("sha256")
      .update(req.params.token)
      .digest("hex");

    const user = await user.findOne({
      verificationToken: hashedToken,
      verificationTokenExpire: { $gt: Date.now() },
    });

    if (!user) {
      res.status(400).json({ message: "Invalid or expired token." });
      return;
    }

    user.isVerified = true;
    user.verificationToken = undefined;
    user.verificationTokenExpire = undefined;
    await user.save();

    res.status(200).json({ success: true });
  } finally {
    client.close();
  }
});
