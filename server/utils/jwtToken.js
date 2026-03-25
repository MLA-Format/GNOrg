// Imports.
const jwt = require("jsonwebtoken");

// Function to create a verification token.
const getVerificationToken = (user) => {
    return jwt.sign(
        { id: user._id },
        process.env.JWT_SECRET,
        { expiresIn: "30m" }
    );
}

module.exports = { getVerificationToken };