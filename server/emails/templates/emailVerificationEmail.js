const { wrapEmail } = require('../emailLayout');
const { title, paragraph, button, securityNote } = require('../emailRenderer');

function emailVerificationEmail({ verificationLink }) {
  const body = `
    ${title('Confirmez votre adresse email')}
    ${paragraph('Merci de vous être inscrit sur DavidSTORE. Confirmez votre adresse email pour securiser votre compte et recevoir toutes nos notifications importantes.')}
    ${button('Confirmer mon email', verificationLink)}
    ${securityNote("Si vous n'etes pas a l'origine de cette inscription, vous pouvez ignorer cet e-mail.")}
  `;
  return wrapEmail({ title: 'Confirmez votre adresse email DavidSTORE', bodyHtml: body });
}

module.exports = { emailVerificationEmail };
