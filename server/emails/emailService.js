const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { sendEmail } = require('./brevoClient');
const { welcomeEmail } = require('./templates/welcomeEmail');
const { passwordResetEmail } = require('./templates/passwordResetEmail');
const { orderReceivedEmail } = require('./templates/orderReceivedEmail');
const { paymentConfirmedEmail } = require('./templates/paymentConfirmedEmail');
const { deliveryCompletedEmail } = require('./templates/deliveryCompletedEmail');
const { loginAlertEmail } = require('./templates/loginAlertEmail');
const { orderPreparingEmail } = require('./templates/orderPreparingEmail');
const { orderShippedEmail } = require('./templates/orderShippedEmail');
const { driverNearbyEmail } = require('./templates/driverNearbyEmail');
const { orderCancelledEmail } = require('./templates/orderCancelledEmail');

const TEMPLATES = {
  WELCOME: { render: welcomeEmail, subject: 'Bienvenue sur DavidSTORE' },
  PASSWORD_RESET: { render: passwordResetEmail, subject: 'Réinitialisation de votre mot de passe DavidSTORE' },
  ORDER_RECEIVED: { render: orderReceivedEmail, subject: (d) => `Votre commande DavidSTORE #${d.orderNumber} a été reçue` },
  PAYMENT_CONFIRMED: { render: paymentConfirmedEmail, subject: (d) => `Paiement confirmé — Commande #${d.orderNumber}` },
  DELIVERY_COMPLETED: { render: deliveryCompletedEmail, subject: (d) => `Commande #${d.orderNumber} livrée avec succès` },
  LOGIN_ALERT: { render: loginAlertEmail, subject: 'Nouvelle connexion détectée — DavidSTORE' },
  ORDER_PREPARING: { render: orderPreparingEmail, subject: (d) => `Commande #${d.orderNumber} en préparation` },
  ORDER_SHIPPED: { render: orderShippedEmail, subject: (d) => `Commande #${d.orderNumber} expédiée` },
  DRIVER_NEARBY: { render: driverNearbyEmail, subject: (d) => `Votre livreur arrive — Commande #${d.orderNumber}` },
  ORDER_CANCELLED: { render: orderCancelledEmail, subject: (d) => `Commande #${d.orderNumber} annulée` },
};

async function logEmailAttempt({ type, recipient, status, error, relatedUserId, relatedOrderId }) {
  try {
    const db = getFirestore();
    await db.collection('emailLogs').add({
      type,
      recipient,
      status,
      error: error || null,
      relatedUserId: relatedUserId || null,
      relatedOrderId: relatedOrderId || null,
      sentAt: FieldValue.serverTimestamp(),
    });
  } catch (logError) {
    console.error('Erreur log emailLogs:', logError);
  }
}

async function sendTransactionalEmail({ type, to, data = {}, relatedUserId, relatedOrderId }) {
  const template = TEMPLATES[type];
  if (!template) {
    console.error(`Type d'email inconnu: ${type}`);
    return { success: false, error: 'unknown_email_type' };
  }

  try {
    const html = template.render(data);
    const subject = typeof template.subject === 'function' ? template.subject(data) : template.subject;

    await sendEmail({ to, subject, html });
    await logEmailAttempt({ type, recipient: to, status: 'sent', relatedUserId, relatedOrderId });

    return { success: true };
  } catch (error) {
    console.error(`Erreur envoi email ${type}:`, error);
    await logEmailAttempt({ type, recipient: to, status: 'failed', error: error.message, relatedUserId, relatedOrderId });

    return { success: false, error: 'send_failed' };
  }
}

module.exports = { sendTransactionalEmail };
