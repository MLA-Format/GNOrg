// Imports.
const { tokenDenylist } = require("../utils/auth.js");

// Function to handle logging a user out. It adds the JWT to the tokenDenyList, which
// is used to determine if a token is logged out or not.
const logoff = async (req, res) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.sendStatus(401);
    const token = authHeader.split(" ")[1];

    try {
        // req.user is already set and verified by requireAuth middleware.
        const { exp } = req.user;
        tokenDenylist.add(token);

        // Auto-remove token from denylist once it naturally expires.
        const ttl = Math.max(0, exp * 1000 - Date.now());
        setTimeout(() => tokenDenylist.delete(token), ttl);

        res.sendStatus(200);
    } catch (err) {
        console.error("Logoff error:", err);
        res.sendStatus(500);
    }
};

module.exports = { logoff };