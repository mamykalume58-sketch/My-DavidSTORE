const { wrapEmail } = require('../emailLayout');
const { title, paragraph, codeBlock, securityNote } = require('../emailRenderer');

function passwordResetPinEmail({ pin }) {
  const body = `
    ${title('Réinitialisation de votre mot de passe')}
    ${paragraph('Vous avez demandé la réinitialisation de votre mot de passe DavidSTORE. Voici votre code de vérification :')}
    ${codeBlock(pin)}
    ${securityNote("Ce code est valable pendant 10 minutes. Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet e-mail. Ne partagez jamais ce code avec quelqu'un.")}
  `;
  return wrapEmail({ title: 'Réinitialisation de votre mot de passe DavidSTORE', bodyHtml: body });
}

module.exports = { passwordResetPinEmail };
