const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoCard, infoRow, button, securityNote } = require('../emailRenderer');
const { COLORS } = require('../emailStyles');

function deliveryCompletedEmail({ name, orderId, orderNumber, deliveryDate }) {
  const greeting = name ? `Bonjour ${name},` : 'Bonjour,';
  const body = `
    ${title(`Commande #${orderNumber} livrée avec succès`)}
    ${paragraph(`${greeting} votre commande a été livrée avec succès. Merci d'avoir choisi DavidSTORE.`)}
    ${infoCard(
      infoRow('Commande', `#${orderNumber}`) +
      infoRow('Date de livraison', deliveryDate) +
      infoRow('Statut', 'Livraison terminée', { color: COLORS.success, last: true })
    )}
    ${button('Donner mon avis', `https://davidstore-payment.vercel.app/orders/${orderId}`)}
    ${securityNote('Merci pour votre confiance.')}
  `;
  return wrapEmail({ title: `Commande #${orderNumber} livrée`, bodyHtml: body });
}

module.exports = { deliveryCompletedEmail };
