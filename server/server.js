require("dotenv").config({ path: __dirname + "/.env" });

const express = require("express");
const path = require("path");
const app = express();
app.use(express.json());

const cors = require("cors");
app.use(cors());

// Serve uploaded images as static files.
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// API function imports.
const { registerUser, verifyEmail } = require("./controllers/userRegistration.js");
const { requestPasswordReset, resetPassword } = require("./controllers/userPwdRst.js");
const { login } = require("./controllers/userLogin.js");
const { logoff } = require("./controllers/userLogoff.js");
const { newGame } = require("./controllers/newGame.js");
const { delGame } = require("./controllers/delGame.js");
const { modGame } = require("./controllers/editGame.js");
const { fetchGames } = require("./controllers/getGames.js");
const { requireAuth } = require("./utils/auth.js");
const { uploadImage } = require("./utils/upload.js");

// Registering paths for API.
app.post("/register", registerUser);
app.get("/register/verifyEmail/:token", verifyEmail);
app.post("/login", login);
app.post("/games/create", requireAuth, newGame);
app.delete("/games/delete", requireAuth, delGame);
app.patch("/games/edit", requireAuth, modGame);
app.post("/games/get", requireAuth, fetchGames);
app.get("/logoff", logoff);
app.post("/request-password-reset", requestPasswordReset);
app.post("/reset-password/:token", resetPassword);
app.post("/upload", requireAuth, uploadImage);

// Initializing app.
app.listen(3000, () => console.log("Server running on port 3000"));