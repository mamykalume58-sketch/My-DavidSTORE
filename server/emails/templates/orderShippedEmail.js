const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoRow, infoCard, securityNote } = require('../emailRenderer');

function orderShippedEmail({ orderNumber, driverName, driverPhone }) {
  const rows = [
    infoRow('Livreur', driverName || 'Non assigné'),
    infoRow('Téléphone', driverPhone || '—', { last: true }),
  ].join('');

  const body = `
    ${title('Votre commande est en route')}
    ${paragraph(`Votre commande #${orderNumber} a été expédiée et est maintenant en route vers vous.`)}
    ${infoCard(rows)}
    ${securityNote("Vous pouvez contacter votre livreur directement au numéro ci-dessus en cas de besoin.")}
  `;
  return wrapEmail({ title: `Commande #${orderNumber} expédiée`, bodyHtml: body });
}

module.exports = { orderShippedEmail };
