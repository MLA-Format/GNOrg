// Imports.
const jwt = require("jsonwebtoken");

// Setting deny list for reference 
const tokenDenylist = new Set();

// Function to handle logging a user out. It adds the JWT to the tokenDenyList, which
// is used to determine if a token is logged out or not.
const logoff = async (req, res) => {
    const token = req.headers.authorization.split(" ")[1];

    try {
        const { exp } = jwt.decode(token);
        tokenDenylist.add(token);

        // Auto-remove token from denylist once it naturally expires.
        setTimeout(() => tokenDenylist.delete(token), exp * 1000 - Date.now());

        res.sendStatus(200);
    } catch (err) {
        console.error("Logoff error:", err);
        res.sendStatus(500);
    }
};

module.exports = { logoff, tokenDenylist };