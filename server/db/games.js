// Imports
const { MongoClient } = require("mongodb");

// DB Connection Setup
const client = new MongoClient(process.env.MONGODB_URL);
const db = () => client.db("GNOrgDB").collection("games");

const connect = async () => await client.connect();

// Function to insert a game into a users games collection.
const insertGame = async (game) => db().insertOne({
  name: game.name,
  players: game.players || null,
  genre: {
    category: game.genre?.category || null,
    type: game.genre?.type || null,
  },
  portable: game.portable ?? null,
  coverImage: game.coverImage || null,
  userId: game.userId || null,  // <-- add this
});

// Function to delete a game from a users game collection.
const deleteGame = async (game) => db().deleteOne({
  name: game.name,
  userId: game.userId,
});

module.exports = { connect, insertGame };