const { MongoClient } = require('mongodb');
const dbUrl = process.env.MONGODB_URL;
const bcrypt = require('bcryptjs');

async function registerUser()
{
    const {name, password, email} = req.body;

    const client = new MongoClient(dbUrl);

    try {
        const db = client.db("GNOrgDB");
        const users = db.collection("usr");

        const userExists = await users.findOne({ username });
        if (userExists) {
            res.status(400);
            throw new Error("User already exists.");
        }

        const emailExists = await users.findOne({ email });
        if (emailExists){
            res.status(400);
            throw new Error("Email already used.");
        }

        const newUser = await users.insertOne({
            name,
            email,
            password: await hashPassword(password),
            isVerified: false
        });

    } catch {
        await client.close()
    }
}

const hashPassword = async (password) => {
    const salt = await bcrypt.genSalt(12);
    return await bcrypt.hash(password, salt);
}