const crypto = require("crypto");

const getVerificationToken = (user) => {
    const token = crypto.randomBytes(20).toString("hex");

    user.verificationToken = crypto.createHash("sha256").update(token).digest("hex");

    user.verificationTokenExpire = Date.now() + 30 * 60 * 1000;

    return token;
}