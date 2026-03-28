require("dotenv").config({ path: __dirname + "/.env" });

const express = require("express");
const app = express();
app.use(express.json());

const cors = require("cors");
app.use(cors());

// API function imports.
const { registerUser, verifyEmail } = require("./controllers/userRegistration.js");
const { login } = require("./controllers/userLogin.js");
const { newGame } = require("./controllers/newGame.js");
const { delGame } = require("./controllers/delGame.js");
const { modGame } = require("./controllers/editGame.js");
const { requireAuth } = require("./utils/auth.js");

// Registering paths for API.
app.post("/register", registerUser);
app.get("/register/verifyEmail/:token", verifyEmail);
app.post("/login", login);
app.post("/games/create", requireAuth, newGame);
app.delete("/games/delete", requireAuth, delGame);
app.delete("/games/delete", requireAuth, modGame
// Initializing app.
app.listen(3000, () => console.log("Server running on port 3000"));