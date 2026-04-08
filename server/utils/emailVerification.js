// Imports.
const { Resend } = require("resend");

// Function to send a verification email to a user using Resend.
const sendEmail = async (options) => {
    const resend = new Resend(process.env.RESEND_APIKEY);

    await resend.emails.send({
        from: `${process.env.FROM_NAME} <${process.env.FROM_EMAIL}>`,
        to: options.email,
        subject: options.subject,
        text: options.message,
    });
}

module.exports = { sendEmail };