// Imports.
const jwt = require("jsonwebtoken");

// Denylist for invalidated tokens.
const tokenDenylist = new Set();

// Active reset tokens tracker.
const activeResetTokens = new Set();

// Function to check for authorization header and set the JWT for the request.
const requireAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;

    // Checking if authorization header present in request.
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Unauthorized." });
    }

    const token = authHeader.split(" ")[1];

    // Checking if the token has been denied.
    if (tokenDenylist.has(token)) {
        return res.status(401).json({ error: "Unauthorized." });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Setting req.user.id inside request.
        next();
    } catch (err) {
        return res.status(401).json({ error: "Unauthorized." });
    }
};

module.exports = { requireAuth, tokenDenylist, activeResetTokens };