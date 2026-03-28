// Imports
const { MongoClient, ObjectId } = require("mongodb");

// DB Connection Setup
const client = new MongoClient(process.env.MONGODB_URL);
const db = () => client.db("GNOrgDB").collection("games");

const connect = async () => await client.connect();

// Function to insert a game into a user's games collection.
const insertGame = async (game) => db().insertOne({
  name: game.name,
  players: game.players || null,
  genre: {
    category: game.genre?.category || null,
    type: game.genre?.type || null,
  },
  portable: game.portable ?? null,
  coverImage: game.coverImage || null,
  userId: game.userId || null
});

// Function to delete a game from a user's game collection.
const deleteGame = async (game) => db().deleteOne({
  name: game.name,
  userId: game.userId,
});

// Function to update a game in a users game collection.
const editGame = async (game) => db().updateOne(
  { _id: new ObjectId(game.id), userId: game.userId },
  {
    $set: {
      name: game.name || null,
      players: game.players || null,
      genre: {
        category: game.genre?.category || null,
        type: game.genre?.type || null,
      },
      portable: game.portable ?? null,
      coverImage: game.coverImage || null,
    }
  }
);

module.exports = { connect, insertGame, deleteGame, editGame };