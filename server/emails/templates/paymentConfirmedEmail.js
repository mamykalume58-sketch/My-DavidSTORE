const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoCard, infoRow, button, securityNote } = require('../emailRenderer');
const { COLORS } = require('../emailStyles');

function paymentConfirmedEmail({ orderNumber, amount, paymentMethod }) {
  const body = `
    ${title(`Paiement confirmé — commande #${orderNumber}`)}
    ${paragraph('Votre paiement a été confirmé avec succès.')}
    ${infoCard(
      infoRow('Commande', `#${orderNumber}`) +
      infoRow('Montant payé', `${amount} FC`) +
      infoRow('Méthode', paymentMethod) +
      infoRow('Statut', 'Paiement confirmé', { color: COLORS.success, last: true })
    )}
    ${button('Voir ma commande', 'https://davidstore-757d8.firebaseapp.com/orders')}
    ${securityNote('Merci de votre confiance.')}
  `;
  return wrapEmail({ title: `Paiement confirmé — #${orderNumber}`, bodyHtml: body });
}

module.exports = { paymentConfirmedEmail };
