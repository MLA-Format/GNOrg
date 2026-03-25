// Imports
const { MongoClient } = require("mongodb");

// DB Connection Setup
const client = new MongoClient(process.env.MONGODB_URL);
const db = () => client.db("GNOrgDB").collection("games");

const connect = async () => await client.connect();

// Function to insert a game into the games collection.
const insertGame = async (game) => db().insertOne({
  name: game.name,
  players: game.players || null,
  genre: {
    category: game.genre?.category || null,
    type: game.genre?.type || null,
  },
  portable: game.portable ?? null,
  coverImage: game.coverImage || null,
});

module.exports = { connect, insertGame };