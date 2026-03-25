// Imports.
const jwt = require("jsonwebtoken");

const requireAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;

    // Checking if Authorization header present in request.
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Unauthorized." });
    }

    const token = authHeader.split(" ")[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // This sets req.user.id used in your controller
        next();
    } catch (err) {
        return res.status(401).json({ error: "Unauthorized." });
    }
};

module.exports = { requireAuth };