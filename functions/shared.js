const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { getMessaging } = require('firebase-admin/messaging');
const { defineSecret } = require('firebase-functions/params');

initializeApp();
const db = getFirestore();

const SENTRY_DSN = defineSecret('SENTRY_DSN');
const SHWARY_MERCHANT_ID = defineSecret('SHWARY_MERCHANT_ID');
const SHWARY_MERCHANT_KEY = defineSecret('SHWARY_MERCHANT_KEY');
const CALLBACK_URL = defineSecret('CALLBACK_URL');
const SHWARY_CALLBACK_TOKEN = defineSecret('SHWARY_CALLBACK_TOKEN');
const RECONCILE_TOKEN = defineSecret('RECONCILE_TOKEN');
const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
const TEST_EMAIL_TOKEN = defineSecret('TEST_EMAIL_TOKEN');
const BREVO_API_KEY = defineSecret('BREVO_API_KEY');
const BREVO_FROM_EMAIL = defineSecret('BREVO_FROM_EMAIL');

const SHWARY_BASE_URL = 'https://api.shwary.com/api/v1';

let sentryInitialized = false;
function getSentry() {
  const Sentry = require('@sentry/node');
  if (!sentryInitialized) {
    Sentry.init({ dsn: SENTRY_DSN.value(), tracesSampleRate: 0.1 });
    sentryInitialized = true;
  }
  return Sentry;
}

async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const idToken = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!idToken) {
    return res.status(401).json({ error: 'Authentification requise' });
  }
  try {
    const decoded = await getAuth().verifyIdToken(idToken);
    req.uid = decoded.uid;
    req.isAdmin = decoded.admin === true;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token invalide' });
  }
}

async function sendPushNotification(userId, title, body, data) {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    const token = userDoc.data()?.fcmToken;
    if (!token) return;
    await getMessaging().send({ token, notification: { title, body }, data: data || {} });
  } catch (error) {
    console.error('Erreur envoi notification push:', error);
    getSentry().captureException(error);
  }
}

async function sendBroadcastNotification(title, body, data) {
  try {
    const usersSnapshot = await db.collection('users').where('fcmToken', '!=', null).get();
    const tokens = usersSnapshot.docs.map((doc) => doc.data().fcmToken).filter(Boolean);
    if (tokens.length === 0) return { sent: 0 };
    const response = await getMessaging().sendEachForMulticast({ tokens, notification: { title, body }, data: data || {} });
    return { sent: response.successCount, failed: response.failureCount };
  } catch (error) {
    console.error('Erreur envoi notification broadcast:', error);
    getSentry().captureException(error);
    return { sent: 0, error: error.message };
  }
}

async function sendPushToDriver(driverId, title, body, data) {
  try {
    const driverDoc = await db.collection('livreurs').doc(driverId).get();
    const token = driverDoc.data()?.fcmToken;
    if (!token) return;
    await getMessaging().send({ token, notification: { title, body }, data: data || {} });
  } catch (error) {
    console.error('Erreur envoi notification push livreur:', error);
    getSentry().captureException(error);
  }
}

module.exports = {
  db, FieldValue, getAuth, getMessaging, getSentry, requireAuth,
  sendPushNotification, sendBroadcastNotification, sendPushToDriver,
  SHWARY_BASE_URL, SHWARY_MERCHANT_ID, SHWARY_MERCHANT_KEY, CALLBACK_URL,
  SHWARY_CALLBACK_TOKEN, RECONCILE_TOKEN, GEMINI_API_KEY, TEST_EMAIL_TOKEN, SENTRY_DSN, BREVO_API_KEY, BREVO_FROM_EMAIL,
};
