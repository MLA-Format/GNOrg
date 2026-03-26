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
            return res.sendStatus(401);
        }

        const result = await deleteGame({
            name,
            userId
        });

        if (result.deletedCount === 0) {
            return res.sendStatus(404);
        }

        res.sendStatus(200);
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
};

module.exports = { delGame };