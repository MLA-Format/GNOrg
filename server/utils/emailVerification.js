// Imports.
const { Resend } = require("resend");

// Function to send a verification email to a user using Resend.
const sendEmail = async (options) => {
    const resend = new Resend(process.env.RESEND_APIKEY);

    const { error } = await resend.emails.send({
        from: `${process.env.FROM_NAME} <${process.env.FROM_EMAIL}>`,
        to: options.email,
        subject: options.subject,
        text: options.message,
    });

    if (error) {
        throw new Error(`Email send failed: ${error.message}`);
    }
}

module.exports = { sendEmail };