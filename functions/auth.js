const express = require('express');
const fetch = require('node-fetch');
const crypto = require('crypto');
const { db, FieldValue, getAuth, getSentry } = require('./shared');
const { sendTransactionalEmail } = require('./emails/emailService');
const { parseUserAgent } = require('./emails/parseUserAgent');

const router = express.Router();

function generateResetPin() {
  return crypto.randomInt(0, 1000000).toString().padStart(6, '0');
}
function hashResetPin(pin) {
  return crypto.createHash('sha256').update(pin).digest('hex');
}

router.post('/welcome', async (req, res) => {
  try {
    const { email, name } = req.body;
    if (!email) return res.status(400).json({ error: 'email est requis' });
    await sendTransactionalEmail({ type: 'WELCOME', to: email, data: { name } });
    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /auth/welcome:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'envoi de l\'email de bienvenue' });
  }
});

router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'email est requis' });

    const device = parseUserAgent(req.headers['user-agent']);
    let location = 'Inconnu';
    try {
      const clientIp = (req.headers['x-forwarded-for'] || req.ip || '').split(',')[0].trim();
      const geoRes = await fetch(`https://ipapi.co/${clientIp}/json/`);
      const geoData = await geoRes.json();
      if (geoData && geoData.city) {
        location = `${geoData.city}, ${geoData.country_name || ''}`.trim();
      }
    } catch (geoError) {
      console.error('Erreur geolocalisation IP:', geoError);
    }

    const userRecord = await getAuth().getUserByEmail(email);
    const token = crypto.randomBytes(32).toString('hex');
    await db.collection('passwordResets').doc(token).set({
      uid: userRecord.uid,
      email,
      used: false,
      createdAt: FieldValue.serverTimestamp(),
      expiresAt: Date.now() + 30 * 60 * 1000,
    });

    const resetLink = `https://davidstore-payment.vercel.app/reset-password?token=${token}`;
    const when = new Date().toLocaleString('fr-FR', { timeZone: 'Africa/Kinshasa' }) + ' (heure de Kinshasa)';
    await sendTransactionalEmail({ type: 'PASSWORD_RESET', to: email, data: { resetLink, device, location, when } });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /auth/forgot-password:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la reinitialisation du mot de passe' });
  }
});

router.post('/reset-password', async (req, res) => {
  try {
    const { token, newPassword } = req.body;
    if (!token || !newPassword) return res.status(400).json({ error: 'token et newPassword sont requis' });
    if (newPassword.length < 6) return res.status(400).json({ error: 'Le mot de passe doit contenir au moins 6 caracteres' });

    const resetDoc = await db.collection('passwordResets').doc(token).get();
    if (!resetDoc.exists) return res.status(400).json({ error: 'Lien invalide ou deja utilise' });
    const resetData = resetDoc.data();
    if (resetData.used) return res.status(400).json({ error: 'Ce lien a deja ete utilise' });
    if (Date.now() > resetData.expiresAt) return res.status(400).json({ error: 'Ce lien a expire, demandez-en un nouveau' });

    await getAuth().updateUser(resetData.uid, { password: newPassword });
    await db.collection('passwordResets').doc(token).update({ used: true });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /auth/reset-password:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la reinitialisation du mot de passe' });
  }
});

router.post('/send-verification', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'email est requis' });

    const actionCodeSettings = { url: 'https://davidstore-757d8.firebaseapp.com', handleCodeInApp: false };
    const verificationLink = await getAuth().generateEmailVerificationLink(email, actionCodeSettings);
    await sendTransactionalEmail({ type: 'EMAIL_VERIFICATION', to: email, data: { verificationLink } });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /auth/send-verification:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'envoi de la verification' });
  }
});

router.post('/forgot-password-pin', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'email est requis' });

    try {
      const userRecord = await getAuth().getUserByEmail(email);
      const pin = generateResetPin();
      const requestRef = db.collection('passwordResetPins').doc();
      await requestRef.set({
        uid: userRecord.uid,
        email,
        pinHash: hashResetPin(pin),
        attempts: 0,
        verified: false,
        used: false,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: Date.now() + 10 * 60 * 1000,
      });
      await sendTransactionalEmail({ type: 'PASSWORD_RESET_PIN', to: email, data: { pin } });
      return res.json({ success: true, requestId: requestRef.id });
    } catch (lookupError) {
      return res.json({ success: true, requestId: crypto.randomBytes(16).toString('hex') });
    }
  } catch (error) {
    console.error('Erreur /auth/forgot-password-pin:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'envoi du code' });
  }
});

router.post('/verify-reset-pin', async (req, res) => {
  try {
    const { requestId, pin } = req.body;
    if (!requestId || !pin) return res.status(400).json({ error: 'requestId et pin sont requis' });

    const requestRef = db.collection('passwordResetPins').doc(requestId);
    const requestDoc = await requestRef.get();
    if (!requestDoc.exists) return res.status(400).json({ error: 'Code incorrect. Verifiez le code recu par e-mail.' });
    const data = requestDoc.data();

    if (data.used) return res.status(400).json({ error: 'Ce code a deja ete utilise.' });
    if (Date.now() > data.expiresAt) return res.status(400).json({ error: 'Ce code a expire, demandez un nouveau code.' });
    if (data.attempts >= 5) return res.status(400).json({ error: 'Trop de tentatives. Demandez un nouveau code.' });

    if (hashResetPin(pin) !== data.pinHash) {
      await requestRef.update({ attempts: FieldValue.increment(1) });
      return res.status(400).json({ error: 'Code incorrect. Verifiez le code recu par e-mail.' });
    }

    const authToken = crypto.randomBytes(32).toString('hex');
    await requestRef.update({ verified: true, authToken, authTokenExpiresAt: Date.now() + 10 * 60 * 1000 });

    res.json({ success: true, resetToken: authToken });
  } catch (error) {
    console.error('Erreur /auth/verify-reset-pin:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la verification du code' });
  }
});

router.post('/reset-password-pin', async (req, res) => {
  try {
    const { requestId, resetToken, newPassword } = req.body;
    if (!requestId || !resetToken || !newPassword) return res.status(400).json({ error: 'requestId, resetToken et newPassword sont requis' });
    if (newPassword.length < 8) return res.status(400).json({ error: 'Le mot de passe doit contenir au moins 8 caracteres' });

    const requestRef = db.collection('passwordResetPins').doc(requestId);
    const requestDoc = await requestRef.get();
    if (!requestDoc.exists) return res.status(400).json({ error: 'Demande invalide.' });
    const data = requestDoc.data();

    if (data.used) return res.status(400).json({ error: 'Ce code a deja ete utilise.' });
    if (!data.verified || data.authToken !== resetToken) return res.status(400).json({ error: 'Autorisation invalide.' });
    if (Date.now() > data.authTokenExpiresAt) return res.status(400).json({ error: 'Cette autorisation a expire, recommencez.' });

    await getAuth().updateUser(data.uid, { password: newPassword });
    await requestRef.update({ used: true });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /auth/reset-password-pin:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la reinitialisation du mot de passe' });
  }
});

router.post('/login-alert', async (req, res) => {
  try {
    const { email, uid } = req.body;
    if (!email) return res.status(400).json({ error: 'email est requis' });

    const device = parseUserAgent(req.headers['user-agent']);
    const clientIp = (req.headers['x-forwarded-for'] || req.ip || '').split(',')[0].trim();
    let location = 'Inconnu';
    try {
      const geoRes = await fetch(`https://ipapi.co/${clientIp}/json/`);
      const geoData = await geoRes.json();
      if (geoData && geoData.city) {
        location = `${geoData.city}, ${geoData.country_name || ''}`.trim();
      }
    } catch (geoError) {
      console.error('Erreur geolocalisation IP:', geoError);
    }

    const actionCodeSettings = { url: 'https://davidstore-757d8.firebaseapp.com', handleCodeInApp: false };
    const resetLink = await getAuth().generatePasswordResetLink(email, actionCodeSettings);
    const when = new Date().toLocaleString('fr-FR', { timeZone: 'Africa/Kinshasa' }) + ' (heure de Kinshasa)';
    await sendTransactionalEmail({ type: 'LOGIN_ALERT', to: email, data: { device, location, ip: clientIp, when, resetLink }, relatedUserId: uid });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /auth/login-alert:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: "Erreur serveur lors de l'alerte de connexion" });
  }
});

module.exports = router;
