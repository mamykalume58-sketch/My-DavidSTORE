const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoRow, infoCard, securityNote } = require('../emailRenderer');

function paymentFailedEmail({ orderNumber, reason }) {
  const rows = [
    infoRow('Commande', `#${orderNumber}`, { last: true }),
  ].join('');

  const body = `
    ${title('Le paiement a échoué')}
    ${paragraph(`Le paiement de votre commande #${orderNumber} n'a pas pu être traité.${reason ? ` Raison : ${reason}` : ''} Aucun montant n'a été débité.`)}
    ${infoCard(rows)}
    ${securityNote("Vous pouvez réessayer le paiement depuis l'application, ou contacter notre support si le problème persiste.")}
  `;
  return wrapEmail({ title: `Échec du paiement — Commande #${orderNumber}`, bodyHtml: body });
}

module.exports = { paymentFailedEmail };
