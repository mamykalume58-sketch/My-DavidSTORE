const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoRow, infoCard, securityNote } = require('../emailRenderer');

const REASON_TRANSLATIONS = {
  'the customer does not have enough funds to complete the payment.': 'Solde insuffisant sur votre compte Mobile Money.',
  'insufficient funds': 'Solde insuffisant sur votre compte Mobile Money.',
  'transaction timeout': "Le délai pour confirmer le paiement a expiré.",
  'transaction cancelled by user': "Vous avez annulé la transaction.",
  'invalid pin': 'Code PIN Mobile Money incorrect.',
  'invalid phone number': 'Numéro de téléphone invalide.',
  'network error': 'Erreur de réseau pendant la transaction.',
};

function translateReason(reason) {
  if (!reason) return null;
  const key = reason.trim().toLowerCase();
  return REASON_TRANSLATIONS[key] || "Le paiement n'a pas pu être confirmé par votre opérateur Mobile Money.";
}

function paymentFailedEmail({ orderNumber, reason }) {
  const translatedReason = translateReason(reason);
  const rows = [
    infoRow('Commande', `#${orderNumber}`, { last: true }),
  ].join('');

  const body = `
    ${title('Le paiement a échoué')}
    ${paragraph(`Le paiement de votre commande #${orderNumber} n'a pas pu être traité.${translatedReason ? ` Raison : ${translatedReason}` : ''} Aucun montant n'a été débité.`)}
    ${infoCard(rows)}
    ${securityNote("Vous pouvez réessayer le paiement depuis l'application, ou contacter notre support si le problème persiste.")}
  `;
  return wrapEmail({ title: `Échec du paiement — Commande #${orderNumber}`, bodyHtml: body });
}

module.exports = { paymentFailedEmail };
