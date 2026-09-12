const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoRow, infoCard, securityNote } = require('../emailRenderer');

function driverNearbyEmail({ orderNumber, driverName, driverPhone }) {
  const rows = [
    infoRow('Livreur', driverName || 'Non assigné'),
    infoRow('Téléphone', driverPhone || '—', { last: true }),
  ].join('');

  const body = `
    ${title('Votre livreur arrive bientôt')}
    ${paragraph(`Votre commande #${orderNumber} sera livrée dans quelques minutes. Préparez-vous à accueillir votre livreur.`)}
    ${infoCard(rows)}
    ${securityNote("Assurez-vous d'être disponible à l'adresse de livraison indiquée.")}
  `;
  return wrapEmail({ title: `Livraison imminente — Commande #${orderNumber}`, bodyHtml: body });
}

module.exports = { driverNearbyEmail };
