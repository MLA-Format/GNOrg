// Imports.
const jwt = require("jsonwebtoken");

// Function to create a verification token.
const getVerificationToken = (user) => {
    return jwt.sign(
        { id: user._id, type: "email-verification" },
        process.env.JWT_SECRET,
        { expiresIn: "30m" }
    );
}

// Function to create a password reset verification token.
const getPwdRstToken = (user) => {
    return jwt.sign(
        { id: user._id, type: "password-reset" },
        process.env.JWT_SECRET,
        { expiresIn: "30m" }
    );
}

module.exports = { getVerificationToken, getPwdRstToken };