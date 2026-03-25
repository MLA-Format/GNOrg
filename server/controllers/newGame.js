// Imports.
const { insertGame } = require("../db/games.js");

// Create a new game.
const newGame = async (req, res) => {
    try {
        const { name, players, genre, portable, coverImage } = req.body;
        const userId = req.user?.id; // comes from JWT middleware

        if (!name) {
            return res.status(400).json({ error: "Name is required." });
        }

        if (!userId) {
            return res.status(401).json({ error: "Unauthorized." });
        }

        const result = await insertGame({
            name,
            players,
            genre,
            portable,
            coverImage,
            userId
        });

        res.status(201).json({ id: result.insertedId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error." });
    }
};

module.exports = { newGame };