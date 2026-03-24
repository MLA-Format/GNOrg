const { MongoClient, ObjectId } = require("mongodb");
const client = new MongoClient(process.env.MONGODB_URL);
const db = () => client.db("GNOrgDB").collection("usr");

const connect = async () => await client.connect();

const checkUserExistence = async (username) => db().findOne({ username });
const checkEmailExistence = async (email) => db().findOne({ email });
const findUserById = async (id) => db().findOne({ _id: new ObjectId(id) });
const insertUser = async (user) => db().insertOne(user);
const setUserVerified = async (id) => db().updateOne(
    { _id: new ObjectId(id) },
    { $set: { isVerified: true } }
);

module.exports = { connect, checkUserExistence, checkEmailExistence, findUserById, insertUser, setUserVerified };