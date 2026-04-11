// Imports.
const jwt = require("jsonwebtoken");
const { getVerificationToken } = require("../utils/jwtToken.js");
const { sendEmail } = require("../utils/emailVerification.js");
const { hashPassword } = require("../utils/hashPassword.js");
const { connect, checkUserExistence, checkEmailExistence, insertUser, findUserById, setUserVerified } = require("../db/usr.js");

// Function to handle initially registering a user before they are verified.
const registerUser = async (req, res) => {
  const { username, password, email } = req.body;

  if (typeof username !== "string" || typeof email !== "string") {
    return res.sendStatus(400);
  }

  try {
    await connect();

    if (!password || typeof password !== "string" || password.length < 8) {
      return res.status(400).json({ message: "PASSWORD_TOO_SHORT" });
    }

    if (username.length > 30) {
      return res.status(400).json({ message: "USERNAME_TOO_LONG" });
    }

    if (email.length > 254) {
      return res.status(400).json({ message: "EMAIL_TOO_LONG" });
    }

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
};

// Function to handle verifying a user when they go to the url they are sent.
const verifyEmail = async (req, res) => {
  try {
    const decoded = jwt.verify(req.params.token, process.env.JWT_SECRET);

    if (decoded.type !== "email-verification") {
      return res.status(400).json({ message: "Invalid or expired token." });
    }

    await connect();
    await setUserVerified(decoded.id);

    // Issue a new auth token so the frontend can auto-login after verification.
    const authToken = jwt.sign({ id: decoded.id, type: "auth" }, process.env.JWT_SECRET, { expiresIn: "30m" });
    res.status(200).json({ token: authToken });
  } catch (err) {
    console.error("Verification error:", err);
    res.status(400).json({ message: "Invalid or expired token." });
  }
};

module.exports = { registerUser, verifyEmail };