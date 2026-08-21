const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoRow, infoCard, securityNote } = require('../emailRenderer');

function orderCancelledEmail({ orderNumber, reason, refundAmount }) {
  const rows = [
    infoRow('Commande', `#${orderNumber}`, refundAmount ? {} : { last: true }),
    refundAmount ? infoRow('Remboursement', `${refundAmount} FC`, { last: true }) : '',
  ].filter(Boolean).join('');

  const body = `
    ${title('Votre commande a été annulée')}
    ${paragraph(`Votre commande #${orderNumber} a été annulée.${reason ? ` Raison : ${reason}` : ''}`)}
    ${infoCard(rows)}
    ${securityNote(refundAmount
      ? "Le remboursement sera traité sous quelques jours ouvrés."
      : "Si vous n'êtes pas à l'origine de cette annulation, contactez notre support.")}
  `;
  return wrapEmail({ title: `Commande #${orderNumber} annulée`, bodyHtml: body });
}

module.exports = { orderCancelledEmail };
