const { wrapEmail } = require('../emailLayout');
const { title, paragraph, infoCard, infoRow, button, securityNote } = require('../emailRenderer');

function loginAlertEmail({ device, location, ip, when, resetLink }) {
  const body = `
    ${title('Nouvelle connexion détectée')}
    ${paragraph("Une connexion à votre compte DavidSTORE vient d'être effectuée depuis un nouvel appareil.")}
    ${infoCard(
      infoRow('Appareil', device || 'Inconnu') +
      infoRow('Lieu', location || 'Inconnu') +
      infoRow('Adresse IP', ip || 'Inconnue') +
      infoRow('Quand', when, { last: true })
    )}
    ${button('Sécuriser mon compte', resetLink)}
    ${securityNote("Si ce n'était pas vous, réinitialisez votre mot de passe immédiatement et contactez notre support.")}
  `;
  return wrapEmail({ title: 'Nouvelle connexion — DavidSTORE', bodyHtml: body });
}

module.exports = { loginAlertEmail };
