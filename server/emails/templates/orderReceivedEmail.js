const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoCard, infoRow, button, securityNote } = require('../emailRenderer');

function orderReceivedEmail({ name, orderId, orderNumber, date, total, paymentMethod, deliveryAddress }) {
  const greeting = name ? `Bonjour ${name},` : 'Bonjour,';
  const body = `
    ${title(`Votre commande #${orderNumber} a été reçue`)}
    ${paragraph(`${greeting} nous avons bien reçu votre commande.`)}
    ${infoCard(
      infoRow('Commande', `#${orderNumber}`) +
      infoRow('Date', date) +
      infoRow('Montant', `${total} FC`) +
      infoRow('Paiement', paymentMethod) +
      infoRow('Livraison', deliveryAddress, { last: true })
    )}
    ${button('Suivre ma commande', `https://davidstore-payment.vercel.app/orders/${orderId}`)}
    ${securityNote('Vous recevrez une confirmation à chaque étape de votre commande.')}
  `;
  return wrapEmail({ title: `Commande #${orderNumber} reçue`, bodyHtml: body });
}

module.exports = { orderReceivedEmail };
