const { wrapEmail } = require('../emailLayout');
const { title, paragraph, button, securityNote } = require('../emailRenderer');

function welcomeEmail({ name }) {
  const greeting = name ? `Bienvenue chez DavidSTORE, ${name} !` : 'Bienvenue chez DavidSTORE !';
  const body = `
    ${title(greeting)}
    ${paragraph("Votre compte a bien été créé. Vous pouvez dès maintenant parcourir nos produits et payer en toute simplicité via Mobile Money.")}
    ${button('Découvrir DavidSTORE', 'https://davidstore-payment.vercel.app')}
    ${securityNote("Si vous n'êtes pas à l'origine de cette inscription, contactez notre support.")}
  `;
  return wrapEmail({ title: 'Bienvenue sur DavidSTORE', bodyHtml: body });
}

module.exports = { welcomeEmail };
