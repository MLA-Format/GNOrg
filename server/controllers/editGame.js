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

        if (players?.min != null && players.min < 0) return res.status(400).json({ error: "INVALID_PLAYER_COUNT" });
        if (players?.max != null && players.max < 0) return res.status(400).json({ error: "INVALID_PLAYER_COUNT" });
        if (Array.isArray(players?.exact) && players.exact.some(n => n < 0)) return res.status(400).json({ error: "INVALID_PLAYER_COUNT" });
        if (players?.min != null && players?.max != null && players.max < players.min) return res.status(400).json({ error: "INVALID_PLAYER_RANGE" });

        if (name !== undefined && name !== null && typeof name !== "string") return res.status(400).json({ error: "INVALID_INPUT" });
        if (name !== undefined && name !== null && name.length > 100) return res.status(400).json({ error: "NAME_TOO_LONG" });
        if (coverImage !== undefined && coverImage !== null && typeof coverImage !== "string") return res.status(400).json({ error: "INVALID_INPUT" });
        if (genre !== undefined && genre !== null) {
            if (genre.category !== undefined && genre.category !== null && typeof genre.category !== "string") return res.status(400).json({ error: "INVALID_INPUT" });
            if (genre.category !== undefined && genre.category !== null && genre.category.length > 50) return res.status(400).json({ error: "GENRE_TOO_LONG" });
            if (genre.type !== undefined && genre.type !== null && typeof genre.type !== "string") return res.status(400).json({ error: "INVALID_INPUT" });
            if (genre.type !== undefined && genre.type !== null && genre.type.length > 50) return res.status(400).json({ error: "GENRE_TOO_LONG" });
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
