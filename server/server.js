require("dotenv").config({ path: __dirname + "/.env" });

const express = require("express");
const app = express();
app.use(express.json());

const { registerUser, verifyEmail } = require("./controllers/userRegistration.js");

app.post("/register", registerUser);
app.get("/register/verifyEmail/:token", verifyEmail);

app.listen(3000, () => console.log("Server running on port 3000"));