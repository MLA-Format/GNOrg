// Imports.
const multer = require("multer");
const path = require("path");
const { v4: uuidv4 } = require("uuid");

// Store uploaded files in /uploads with a UUID filename.
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, path.join(__dirname, "../uploads")),
    filename:    (req, file, cb) => cb(null, `${uuidv4()}${path.extname(file.originalname)}`),
});

const ALLOWED_EXTENSIONS = new Set(['.jpg', '.jpeg', '.png', '.gif', '.webp']);

// Reject non-image files and enforce 5MB limit.
const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const ext = path.extname(file.originalname).toLowerCase();
        if (ALLOWED_EXTENSIONS.has(ext)) cb(null, true);
        else cb(new Error("Only image files are allowed"));
    },
}).single("image");

// Function to handle a cover image upload.
const uploadImage = (req, res) => {
    upload(req, res, (err) => {
        if (err instanceof multer.MulterError && err.code === "LIMIT_FILE_SIZE")
            return res.status(400).json({ error: "FILE_TOO_LARGE" });
        if (err)
            return res.status(400).json({ error: err.message });
        if (!req.file)
            return res.status(400).json({ error: "NO_FILE" });

        // Return the relative path for the uploaded file.
        res.status(201).json({ url: `/uploads/${req.file.filename}` });
    });
};

module.exports = { uploadImage };