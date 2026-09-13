const express = require('express');
const { sendTransactionalEmail } = require('./emails/emailService');
const { TEST_EMAIL_TOKEN } = require('./shared');

const router = express.Router();

router.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'davidstore-payment-server' });
});

router.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

router.get('/.well-known/assetlinks.json', (req, res) => {
  res.sendFile(__dirname + '/.well-known/assetlinks.json', {
    dotfiles: 'allow',
    headers: { 'Content-Type': 'application/json' },
  });
});

router.get('/orders/:orderId', (req, res) => {
  res.set('Content-Type', 'text/html');
  res.send(`<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DavidSTORE - Votre commande</title>
  <style>
    body { font-family: -apple-system, sans-serif; background: #0057B8; color: white; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 24px; text-align: center; }
    h1 { font-size: 22px; margin-bottom: 8px; }
    p { color: rgba(255,255,255,0.85); font-size: 14px; margin-bottom: 24px; }
    a { background: white; color: #0057B8; padding: 14px 28px; border-radius: 999px; text-decoration: none; font-weight: 600; }
  </style>
</head>
<body>
  <h1>Suivez votre commande</h1>
  <p>Ouvrez l'application DavidSTORE pour voir les détails de votre commande.</p>
  <a href="https://github.com/mamykalume58-sketch/My-DavidSTORE/releases/latest/download/app-arm64-v8a-release.apk">Télécharger l'application</a>
</body>
</html>`);
});

router.get('/reset-password', (req, res) => {
  res.sendFile(__dirname + '/public/reset-password.html');
});

router.post('/test-email/:type', async (req, res) => {
  if (req.query.token !== TEST_EMAIL_TOKEN.value()) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  try {
    const { to, data } = req.body;
    if (!to) return res.status(400).json({ error: 'to est requis' });
    const result = await sendTransactionalEmail({ type: req.params.type.toUpperCase(), to, data: data || {} });
    res.json(result);
  } catch (error) {
    console.error('Erreur /test-email:', error);
    res.status(500).json({ error: 'Erreur serveur lors du test email' });
  }
});

module.exports = router;
