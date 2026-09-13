const { onRequest } = require('firebase-functions/v2/https');
const cors = require('cors');
const express = require('express');
const {
  SHWARY_MERCHANT_ID, SHWARY_MERCHANT_KEY, CALLBACK_URL,
  SHWARY_CALLBACK_TOKEN, RECONCILE_TOKEN, SENTRY_DSN,
  GEMINI_API_KEY, TEST_EMAIL_TOKEN, BREVO_API_KEY, BREVO_FROM_EMAIL,
} = require('./shared');

const CORS_OPTIONS = {
  origin: ['https://dashboard-admin-pearl-one.vercel.app', 'http://localhost:5173'],
};

function buildApp(routerPath) {
  const app = express();
  app.set('trust proxy', 1);
  app.use(cors(CORS_OPTIONS));
  app.use(express.json());
  app.use('/', require(routerPath));
  return app;
}

exports.payments = onRequest(
  { secrets: [SHWARY_MERCHANT_ID, SHWARY_MERCHANT_KEY, CALLBACK_URL, SHWARY_CALLBACK_TOKEN, RECONCILE_TOKEN, SENTRY_DSN, BREVO_API_KEY, BREVO_FROM_EMAIL] },
  buildApp('./payments')
);

exports.authRoutes = onRequest(
  { secrets: [SENTRY_DSN, BREVO_API_KEY, BREVO_FROM_EMAIL] },
  buildApp('./auth')
);

exports.admin = onRequest(
  {},
  buildApp('./admin')
);

exports.notifications = onRequest(
  { secrets: [SENTRY_DSN, BREVO_API_KEY, BREVO_FROM_EMAIL] },
  buildApp('./notifications')
);

exports.supportChat = onRequest(
  { secrets: [GEMINI_API_KEY] },
  buildApp('./supportChat')
);

exports.misc = onRequest(
  { secrets: [TEST_EMAIL_TOKEN, BREVO_API_KEY, BREVO_FROM_EMAIL] },
  buildApp('./misc')
);
