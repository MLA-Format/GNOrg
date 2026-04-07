// Imports.
const jwt = require("jsonwebtoken");
const { getPwdRstToken } = require("../utils/jwtToken.js");
const { sendEmail } = require("../utils/emailVerification.js");
const { hashPassword } = require("../utils/hashPassword.js");
const { connect, checkEmailExistence, updateUserPwd } = require("../db/usr.js");
const { tokenDenylist, activeResetTokens } = require("../utils/auth.js");

// Function to handle requesting a password reset email.
const requestPasswordReset = async (req, res) => {
  try {
    if (typeof req.body.email !== "string") {
      return res.sendStatus(400);
    }

    await connect();
    const user = await checkEmailExistence(req.body.email);

    // Always return 200 to avoid leaking whether the email is registered.
    if (!user) {
      return res.sendStatus(200);
    }

    // Check if a reset token is already active for this user.
    if (activeResetTokens.has(user._id.toString()))
      return res.status(400).json({ message: "RESET_ALREADY_SENT" });

    const token = getPwdRstToken(user);
    activeResetTokens.add(user._id.toString());

    // Auto-remove from active reset tokens after 30 minutes if unused.
    setTimeout(() => activeResetTokens.delete(user._id.toString()), 30 * 60 * 1000);

    const resetUrl = `${process.env.FRONTEND_URL}/reset-password/${token}`;
    await sendEmail({
      email: user.email,
      subject: "Password Reset",
      message: `Reset your password (expires in 30 minutes): ${resetUrl}`,
    });

    res.sendStatus(200);
  } catch (err) {
    console.error("Password reset request error:", err);
    res.sendStatus(500);
  }
};

// Function to handle resetting the password once the user visits the reset URL.
const resetPassword = async (req, res) => {
  try {
    // Check if token is present in deny list.
    if (tokenDenylist.has(req.params.token))
      return res.status(400).json({ message: "RESET_TOKEN_INVALID" });

    const { password } = req.body;
    if (!password || password.length < 8) {
      return res.status(400).json({ message: "PASSWORD_TOO_SHORT" });
    }

    const decoded = jwt.verify(req.params.token, process.env.JWT_SECRET);

    if (decoded.type !== "password-reset") {
      return res.status(400).json({ message: "RESET_TOKEN_INVALID" });
    }

    await connect();
    await updateUserPwd(decoded.id, await hashPassword(password));

    // Add token to deny list and clear active reset token.
    tokenDenylist.add(req.params.token);
    activeResetTokens.delete(decoded.id);

    res.sendStatus(200);
  } catch (err) {
    console.error("Password reset error:", err);

    // Check if error is due to token expiring.
    if (err.name === "TokenExpiredError")
      return res.status(400).json({ message: "RESET_TOKEN_EXPIRED" });

    // Check if error is due to token creation.
    if (err.name === "JsonWebTokenError")
      return res.status(400).json({ message: "RESET_TOKEN_INVALID" });

    res.sendStatus(500);
  }
};

module.exports = { requestPasswordReset, resetPassword };