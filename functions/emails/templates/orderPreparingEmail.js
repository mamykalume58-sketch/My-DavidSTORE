const { wrapEmail } = require('../emailLayout');
const { title, paragraph, progressSteps, securityNote } = require('../emailRenderer');

const STEPS = ['Reçue', 'Confirmée', 'Préparation', 'Livraison', 'Terminée'];

function orderPreparingEmail({ orderNumber }) {
  const body = `
    ${title('Votre commande est en préparation')}
    ${paragraph(`Bonne nouvelle ! Votre commande #${orderNumber} est en cours de préparation dans notre entrepôt.`)}
    ${progressSteps(STEPS, 2)}
    ${securityNote("Vous recevrez un nouvel e-mail dès que votre commande sera expédiée.")}
  `;
  return wrapEmail({ title: `Commande #${orderNumber} en préparation`, bodyHtml: body });
}

module.exports = { orderPreparingEmail };
