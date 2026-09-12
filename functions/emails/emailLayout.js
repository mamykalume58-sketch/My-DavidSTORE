const { COLORS, FONT_STACK, LOGO_URL, SUPPORT_EMAIL, SUPPORT_WHATSAPP, SUPPORT_WHATSAPP_LINK } = require('./emailStyles');

function wrapEmail({ title, bodyHtml }) {
  return `<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${title}</title>
</head>
<body style="margin:0;padding:0;background:${COLORS.cardBg};">
<div style="max-width:480px;margin:0 auto;font-family:${FONT_STACK};">

  <div style="background:${COLORS.navy};padding:28px 24px 20px;border-radius:12px 12px 0 0;text-align:center;">
    <img src="${LOGO_URL}" alt="DavidSTORE" style="max-width:180px;height:auto;" />
  </div>

  <div style="background:${COLORS.cardBg};padding:28px 24px;">
    ${bodyHtml}
  </div>

  <div style="background:${COLORS.navy};padding:18px 24px;border-radius:0 0 12px 12px;text-align:center;">
    <p style="font-size:12px;color:${COLORS.white};margin:0 0 4px;font-weight:600;">DAVIDSTORE</p>
    <p style="font-size:11px;color:${COLORS.textSecondary};margin:0 0 10px;">Achetez plus. Payez moins. Nous livrons.</p>
    <p style="font-size:11px;color:${COLORS.textSecondary};margin:0;">Support : <a href="mailto:${SUPPORT_EMAIL}" style="color:${COLORS.white};text-decoration:none;">${SUPPORT_EMAIL}</a></p>
    <p style="font-size:11px;color:${COLORS.textSecondary};margin:4px 0 0;">WhatsApp : <a href="${SUPPORT_WHATSAPP_LINK}" style="color:${COLORS.white};text-decoration:none;">${SUPPORT_WHATSAPP}</a></p>
  </div>

</div>
</body>
</html>`;
}

module.exports = { wrapEmail };
