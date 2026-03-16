const crypto = require("crypto");

userSchema.methods.getVerificationToken = function () {
    const token = crypto.randomBytes(20).toString("hex");

    this.verificationToken = crypto.createHash("sha256").update("token").digest("hex");

    this.verificationTokenExpire = Date.now() + 30 * 60 * 1000;

    return token;
}