const { BrevoClient } = require('@getbrevo/brevo');

const brevo = new BrevoClient({ apiKey: process.env.BREVO_API_KEY });
const FROM_EMAIL = process.env.BREVO_FROM_EMAIL || 'davidstore.cd@gmail.com';
const FROM_NAME = 'DavidSTORE';

async function sendEmail({ to, subject, html }) {
  return brevo.transactionalEmails.sendTransacEmail({
    subject,
    htmlContent: html,
    sender: { name: FROM_NAME, email: FROM_EMAIL },
    to: [{ email: to }],
  });
}

module.exports = { sendEmail };
