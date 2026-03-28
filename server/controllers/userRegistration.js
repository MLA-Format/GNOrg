// Imports.
const { getVerificationToken } = require("../utils/jwtToken.js");
const { sendEmail } = require("../utils/emailVerification.js");
const { hashPassword } = require("../utils/hashPassword.js");
const { connect, checkUserExistence, checkEmailExistence, insertUser, findUserById, setUserVerified } = require("../db/usr.js");
const { jwt } = require("jsonwebtoken");

// Function to handle initially registering a user before they are verified.
const registerUser = async (req, res) => {
  const { username, password, email } = req.body;

  try {
    await connect();

    const userExists = await checkUserExistence(username);
    if (userExists)
      return res.status(400).json({ message: "USER_TAKEN" });

    const emailExists = await checkEmailExistence(email);
    if (emailExists)
      return res.status(400).json({ message: "EMAIL_TAKEN" });

    const insertedUser = await insertUser({
      username,
      email,
      password: await hashPassword(password),
      isVerified: false,
    });

    const newUser = await findUserById(insertedUser.insertedId);

    if (newUser) {
      const token = getVerificationToken(newUser);
      const verificationUrl = `${process.env.FRONTEND_URL}/verify-email/${token}`;
      await sendEmail({
        email: newUser.email,
        subject: "Email Verification",
        message: `Please verify your email by clicking the following link: ${verificationUrl}`,
      });
      res.sendStatus(201);
    }
  } catch (err) {
    console.error("Registration error:", err);
    res.sendStatus(500);
  }
}

// Function to handle verifying a user when they go to the url they are sent.
const verifyEmail = async (req, res) => {
  try {
    const decoded = jwt.verify(req.params.token, process.env.JWT_SECRET);
    await connect();
    await setUserVerified(decoded.id);
    res.sendStatus(200);
  } catch (err) {
    console.error("Verification error:", err);
    res.status(400).json({ message: "Invalid or expired token." });
  }
}

module.exports = { registerUser, verifyEmail };