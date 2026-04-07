// Imports
const { MongoClient, ObjectId } = require("mongodb");

// DB Connection Setup
const client = new MongoClient(process.env.MONGODB_URL);
const db = () => client.db("GNOrgDB").collection("games");

const connect = async () => await client.connect();

// Normalise the players field into { min, max, exact } — all keys optional.
const normalisePlayers = (players) => {
    if (!players) return null;
    const result = {};
    if (players.min != null)                              result.min   = players.min;
    if (players.max != null)                              result.max   = players.max;
    if (Array.isArray(players.exact) && players.exact.length) result.exact = players.exact;
    return Object.keys(result).length ? result : null;
};

// Function to insert a game into a user's games collection.
const insertGame = async (game) => db().insertOne({
  name: game.name,
  players: normalisePlayers(game.players),
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

// Function to update a game in a user's game collection.
const editGame = async (game) => db().updateOne(
  { _id: new ObjectId(game.id), userId: game.userId },
  {
    $set: {
      name: game.name || null,
      players: normalisePlayers(game.players),
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
    const escaped = game.name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    query.name = { $regex: escaped, $options: "i" };
  }

  if (game.players?.count != null) {
    const count = Number(game.players.count);
    query.$or = [
      { $and: [{ "players.min": { $lte: count } }, { "players.max": { $gte: count } }] },
      { "players.exact": count },
    ];
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

module.exports = { connect, insertGame, deleteGame, editGame, getGames };