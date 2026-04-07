// Imports.
const { getGames } = require("../db/games.js");
const { ObjectId } = require("mongodb");

// Function to get games based on users entered parameters.
const fetchGames = async (req, res) => {
    try {
        const { id, name, players, genre, portable, coverImage } = req.body;
        const userId = req.user?.id;

        if (!userId) {
            return res.sendStatus(401);
        }

        if (id && !ObjectId.isValid(id)) {
            return res.status(400).json({ error: "ID_INVALID" });
        }

        if (name != null && typeof name !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }
        if (genre?.category != null && typeof genre.category !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }
        if (genre?.type != null && typeof genre.type !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }
        if (coverImage != null && typeof coverImage !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }

        const results = await getGames({
            id,
            name,
            players,
            genre,
            portable,
            coverImage,
            userId
        });

        if (!results.length) {
            return res.sendStatus(404);
        }

        res.status(200).json(results);
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
};

module.exports = { fetchGames };