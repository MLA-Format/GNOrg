// Imports.
const { insertGame } = require("../db/games.js");

// Function to create a new game.
const newGame = async (req, res) => {
    try {
        const { name, players, genre, portable, coverImage } = req.body;
        const userId = req.user?.id;

        if (!name || typeof name !== 'string') {
            return res.status(400).json({ error: "NAME_REQ" });
        }

        if (name.length > 100) {
            return res.status(400).json({ error: "NAME_TOO_LONG" });
        }

        if (players?.min != null && players.min < 0) return res.status(400).json({ error: "INVALID_PLAYER_COUNT" });
        if (players?.max != null && players.max < 0) return res.status(400).json({ error: "INVALID_PLAYER_COUNT" });
        if (Array.isArray(players?.exact) && players.exact.some(n => n < 0)) return res.status(400).json({ error: "INVALID_PLAYER_COUNT" });
        if (players?.min != null && players?.max != null && players.max < players.min) {
            return res.status(400).json({ error: "INVALID_PLAYER_RANGE" });
        }

        if (genre?.category != null && typeof genre.category !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }
        if (genre?.category != null && genre.category.length > 50) {
            return res.status(400).json({ error: "GENRE_TOO_LONG" });
        }
        if (genre?.type != null && typeof genre.type !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }
        if (genre?.type != null && genre.type.length > 50) {
            return res.status(400).json({ error: "GENRE_TOO_LONG" });
        }
        if (coverImage != null && typeof coverImage !== 'string') {
            return res.status(400).json({ error: "INVALID_INPUT" });
        }

        if (!userId) {
            return res.sendStatus(401);
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
        res.sendStatus(500);
    }
};

module.exports = { newGame };