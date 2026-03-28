// Imports
const { editGame } = require("../db/games.js");
const { ObjectId } = require("mongodb");

// Function to edit a game.
const modGame = async (req, res) => {
    try {
        const { id, name, players, genre, portable, coverImage } = req.body;
        const userId = req.user?.id;

        if (!id) {
            return res.status(400).json({ error: "ID_REQ" });
        }

        if (!ObjectId.isValid(id)) {
            return res.status(400).json({ error: "ID_INVALID" });
        }

        if (!userId) {
            return res.sendStatus(401);
        }

        const result = await editGame({
            id,
            name,
            players,
            genre,
            portable,
            coverImage,
            userId
        });

        if (result.matchedCount === 0) {
            return res.sendStatus(404);
        }

        res.sendStatus(200);
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
};

module.exports = { modGame };