// Imports.
const { insertGame } = require("../db/games.js");

// Function to create a new game.
const newGame = async (req, res) => {
    try {
        const { name, players, genre, portable, coverImage } = req.body;
        const userId = req.user?.id;

        if (!name) {
            return res.status(400).json({ error: "Name is required." });
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