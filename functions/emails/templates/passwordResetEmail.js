const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoCard, infoRow, button, securityNote } = require('../emailRenderer');

function passwordResetEmail({ resetLink, device, location, when }) {
  const body = `
    ${title('Réinitialisation du mot de passe')}
    ${paragraph('Une demande de réinitialisation a été effectuée pour votre compte DavidSTORE.')}
    ${infoCard(
      infoRow('Appareil', device || 'Inconnu') +
      infoRow('Lieu', location || 'Inconnu') +
      infoRow('Quand', when, { last: true })
    )}
    ${button('Réinitialiser mon mot de passe', resetLink)}
    ${securityNote("Ce lien est valable pendant 30 minutes. Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet e-mail.")}
  `;
  return wrapEmail({ title: 'Réinitialisation de votre mot de passe DavidSTORE', bodyHtml: body });
}

module.exports = { passwordResetEmail };
