require("dotenv").config({ path: __dirname + "/.env" });

const path = require("path");
const express = require("express");
const app = express();
app.use(express.json());

const helmet = require("helmet");
app.use(helmet());

const cors = require("cors");
const allowedOrigin = process.env.ALLOWED_ORIGIN || "http://localhost:5173";
app.use(cors({ origin: allowedOrigin, exposedHeaders: ['X-Refreshed-Token'] }));

app.set("trust proxy", 1);

const rateLimit = require("express-rate-limit");
const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10 });
const resetLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10 });
const registerLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 5 });

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

// Registering paths for API (all routes under /api prefix).
const router = require("express").Router();
router.post("/register", registerLimiter, registerUser);
router.get("/verify-email/:token", verifyEmail);
router.post("/login", loginLimiter, login);
router.post("/games/create", requireAuth, newGame);
router.delete("/games/delete", requireAuth, delGame);
router.patch("/games/edit", requireAuth, modGame);
router.post("/games/get", requireAuth, fetchGames);
router.post("/games/upload-image", requireAuth, uploadImage);
router.get("/logoff", requireAuth, logoff);
router.post("/request-password-reset", resetLimiter, requestPasswordReset);
router.post("/reset-password/:token", resetPassword);
app.use("/api", router);

// Initializing app.
app.listen(3000, () => console.log("Server running on port 3000"));