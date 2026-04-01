// Imports.
const { MongoClient, ObjectId } = require("mongodb");

// DB connection setup.
const client = new MongoClient(process.env.MONGODB_URL);
const db = () => client.db("GNOrgDB").collection("usr");

const connect = async () => await client.connect();

// Function to check if a user with username already exists.
const checkUserExistence = async (username) => db().findOne({ username });

// Function to check if a user with email already exists.
const checkEmailExistence = async (email) => db().findOne({ email });

// Function to get a user using their ID.
const findUserById = async (id) => db().findOne({ _id: new ObjectId(id) });

// Function to insert a new user.
const insertUser = async (user) => db().insertOne(user);

// Function to update a user after they are verified.
const setUserVerified = async (id) => db().updateOne(
    { _id: new ObjectId(id) },
    { $set: { isVerified: true } }
);

// Function to update a user's password.
const updateUserPwd = async (id, hashedPassword) => db().updateOne(
    { _id: new ObjectId(id) },
    { $set: { password: hashedPassword } }
)


module.exports = { connect, checkUserExistence, checkEmailExistence, findUserById, insertUser, setUserVerified, updateUserPwd };