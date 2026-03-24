require("dotenv").config({ path: __dirname + "/.env" });

const express = require("express");
const app = express();
app.use(express.json());

const cors = require("cors");
app.use(cors());

const { registerUser, verifyEmail } = require("./controllers/userRegistration.js");
const { login } = require("./controllers/userLogin.js");

app.post("/register", registerUser);
app.get("/register/verifyEmail/:token", verifyEmail);
app.post("/login", login);
app.post("/games/create");

app.listen(3000, () => console.log("Server running on port 3000"));