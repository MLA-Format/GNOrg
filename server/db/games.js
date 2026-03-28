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

// Function to get games that meet the requirements the user
// provides. Uses partial search for name searches, and matches
// all other parameters provided.
const getGames = async (game) => db().find((() => {
  
  const query = { userId: game.userId };

  if (game.name) {
    query.name = { $regex: game.name, $options: "i" };
  }

  if (game.players) {
    query.players = game.players;
  }
  
  if (game.genre?.category) {
    query["genre.category"] = game.genre.category;
  }
  
  if (game.genre?.type) {
    query["genre.type"] = game.genre.type;
  }
  
  if (game.portable != null) {
    query.portable = game.portable;
  }
  
  if (game.coverImage) {
    query.coverImage = game.coverImage;
  }

  return query;
})()).toArray();

module.exports = { connect, insertGame, deleteGame, editGame };