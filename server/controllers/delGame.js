// Imports.
const { deleteGame } = require("../db/games.js");

// Function to delete a game.
const delGame = async (req, res) => {
    try {
        const { name } = req.body;
        const userId = req.user?.id;

        if (!name) {
            return res.status(400).json({ error: "Name is required." });
        }

        if (!userId) {
            return res.status(401).json({ error: "Unauthorized." });
        }

        const result = await deleteGame({
            name,
            userId
        });

        if (result.deletedCount === 0) {
            return res.status(404).json({ error: "Game not found." });
        }

        res.status(200).json({ message: "Game deleted." });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error." });
    }
};

module.exports = { delGame };