require('dotenv').config();
const express = require('express');
const fetch = require('node-fetch');
const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { getMessaging } = require('firebase-admin/messaging');
const cors = require('cors');
const { sendTransactionalEmail } = require('./emails/emailService');
const { parseUserAgent } = require('./emails/parseUserAgent');

const Sentry = require('@sentry/node');
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
});

let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
} else {
  serviceAccount = require('./serviceAccountKey.json');
}

if (!getApps().length) {
  initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function sendPushNotification(userId, title, body, data) {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    const token = userDoc.data()?.fcmToken;
    if (!token) return;

    await getMessaging().send({
      token,
      notification: { title, body },
      data: data || {},
    });
  } catch (error) {
    console.error('Erreur envoi notification push:', error);
    Sentry.captureException(error);
  }
}

async function sendBroadcastNotification(title, body, data) {
  try {
    const usersSnapshot = await db.collection('users').where('fcmToken', '!=', null).get();
    const tokens = usersSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter(Boolean);

    if (tokens.length === 0) return { sent: 0 };

    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: data || {},
    });
    return { sent: response.successCount, failed: response.failureCount };
  } catch (error) {
    console.error('Erreur envoi notification broadcast:', error);
    Sentry.captureException(error);
    return { sent: 0, error: error.message };
  }
}

const app = express();
app.use(cors({
  origin: [
    'https://dashboard-admin-pearl-one.vercel.app',
    'http://localhost:5173',
  ],
}));
app.use(express.json());

const SHWARY_BASE_URL = 'https://api.shwary.com/api/v1';
const SHWARY_MERCHANT_ID = process.env.SHWARY_MERCHANT_ID;
const SHWARY_MERCHANT_KEY = process.env.SHWARY_MERCHANT_KEY;
const CALLBACK_URL = process.env.CALLBACK_URL;
const SHWARY_CALLBACK_TOKEN = process.env.SHWARY_CALLBACK_TOKEN;

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'davidstore-payment-server' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/shwary/test-status/:transactionId', async (req, res) => {
  try {
    const response = await fetch(
      `https://api.shwary.com/api/v1/merchants/transactions/${req.params.transactionId}`,
      {
        headers: {
          'x-merchant-id': SHWARY_MERCHANT_ID,
          'x-merchant-key': SHWARY_MERCHANT_KEY,
        },
      }
    );
    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    console.error('Erreur test-status Shwary:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/shwary/pay', async (req, res) => {
  try {
    const { amount, clientPhoneNumber, orderId, sandbox, paymentMethod } = req.body;

    if (!amount || !clientPhoneNumber || !orderId) {
      return res.status(400).json({ error: 'amount, clientPhoneNumber et orderId sont requis' });
    }

    const endpoint = sandbox
      ? `${SHWARY_BASE_URL}/merchants/payment/sandbox/DRC`
      : `${SHWARY_BASE_URL}/merchants/payment/DRC`;

    const shwaryResponse = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-merchant-id': SHWARY_MERCHANT_ID,
        'x-merchant-key': SHWARY_MERCHANT_KEY,
      },
      body: JSON.stringify({ amount, clientPhoneNumber, callbackUrl: `${CALLBACK_URL}?token=${SHWARY_CALLBACK_TOKEN}` }),
    });

    const data = await shwaryResponse.json();

    if (!shwaryResponse.ok) {
      return res.status(shwaryResponse.status).json({ error: data.message || 'Erreur Shwary' });
    }

    await db.collection('transactions').doc(data.id).set({
      shwaryTransactionId: data.id,
      orderId,
      amount,
      clientPhoneNumber,
      status: data.status || 'pending',
      isSandbox: !!sandbox,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    await db.collection('orders').doc(orderId).update({
      transactionId: data.id,
      paymentStatus: data.status || 'pending',
      paymentMethod: paymentMethod || null,
    });

    res.json({ transactionId: data.id, status: data.status });
  } catch (error) {
    console.error('Erreur initiation paiement:', error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'initiation du paiement' });
  }
});

app.post('/api/shwary/callback', async (req, res) => {
  try {
    if (req.query.token !== SHWARY_CALLBACK_TOKEN) {
      console.warn('Callback Shwary refuse : token invalide ou manquant');
      Sentry.captureMessage('Callback Shwary refuse : token invalide', { level: 'warning' });
      return res.status(401).json({ error: 'Non autorise' });
    }

    const transaction = req.body;
    const { id, status, failureReason, txHash, completedAt } = transaction;

    if (!id || !status) {
      return res.status(400).json({ error: 'Payload invalide' });
    }

    const transactionRef = db.collection('transactions').doc(id);

    // Race condition connue : Shwary peut envoyer le callback "pending" avant
    // que notre propre écriture Firestore (faite dans /api/shwary/pay) ne soit
    // terminée. On retente plusieurs fois avec un court délai avant d'abandonner,
    // en restant largement sous le timeout de 10s de Shwary.
    let transactionDoc = null;
    const maxAttempts = 5;
    const delayMs = 700;

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      const doc = await transactionRef.get();
      if (doc.exists) {
        transactionDoc = doc;
        break;
      }
      if (attempt < maxAttempts) {
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      }
    }

    if (!transactionDoc) {
      console.warn(`Transaction inconnue reçue en callback après ${maxAttempts} tentatives: ${id}`);
      Sentry.captureMessage(`Callback Shwary orphelin : transaction ${id} introuvable`, { level: 'error', extra: { payload: transaction } });
      // Filet de sécurité : on garde une trace du callback orphelin pour
      // réconciliation manuelle plutôt que de le perdre silencieusement.
      await db.collection('orphan_callbacks').doc(id).set({
        payload: transaction,
        receivedAt: FieldValue.serverTimestamp(),
      });
      return res.status(200).json({ received: true });
    }

    await transactionRef.update({
      status,
      failureReason: failureReason || null,
      txHash: txHash || null,
      completedAt: completedAt || null,
      updatedAt: FieldValue.serverTimestamp(),
    });

    const orderId = transactionDoc.data().orderId;
    if (orderId) {
      await db.collection('orders').doc(orderId).update({ paymentStatus: status });

      if (status === 'completed') {
        const orderDoc = await db.collection('orders').doc(orderId).get();
        const orderUserId = orderDoc.data()?.userId;
        if (orderUserId) {
          await sendPushNotification(
            orderUserId,
            'Paiement confirmé',
            'Votre paiement a été confirmé, votre commande est en cours de préparation.',
            { type: 'payment_completed', orderId }
          );

          try {
            const orderNumber = orderDoc.data()?.orderNumber || orderId;
            const customerEmail = (await getAuth().getUser(orderUserId)).email;
            if (customerEmail) {
              await sendTransactionalEmail({
                type: 'PAYMENT_CONFIRMED',
                to: customerEmail,
                data: { orderNumber, amount: orderDoc.data()?.amount, paymentMethod: orderDoc.data()?.paymentMethod },
              });
            }
          } catch (emailError) {
            console.error('Erreur envoi email confirmation paiement:', emailError);
            Sentry.captureException(emailError);
          }
        }
} else if (status === 'failed') {
        const orderDoc = await db.collection('orders').doc(orderId).get();
        const orderUserId = orderDoc.data()?.userId;
        if (orderUserId) {
          try {
            const orderNumber = orderDoc.data()?.orderNumber || orderId;
            const customerEmail = (await getAuth().getUser(orderUserId)).email;
            if (customerEmail) {
              await sendTransactionalEmail({
                type: 'PAYMENT_FAILED',
                to: customerEmail,
                data: { orderNumber, reason: failureReason || null },
              });
            }
          } catch (emailError) {
            console.error('Erreur envoi email echec paiement:', emailError);
            Sentry.captureException(emailError);
          }
        }
      }
    }
    Sentry.captureMessage(`Callback Shwary traite : transaction ${id}, statut ${status}`, { level: 'info', extra: { orderId, status, failureReason } });

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Erreur callback Shwary:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors du traitement du callback' });
  }
});
app.get('/api/shwary/reconcile', async (req, res) => {
  try {
    const cutoff = new Date(Date.now() - 3 * 60 * 1000); // 3 minutes
    const snapshot = await db.collection('transactions')
      .where('status', '==', 'pending')
      .get();

    const results = [];

    for (const doc of snapshot.docs) {
      const tx = doc.data();
      const createdAt = tx.createdAt?.toDate?.();
      if (!createdAt || createdAt > cutoff) continue;

      try {
        const shwaryResponse = await fetch(
          `${SHWARY_BASE_URL}/merchants/transactions/${doc.id}`,
          {
            headers: {
              'x-merchant-id': SHWARY_MERCHANT_ID,
              'x-merchant-key': SHWARY_MERCHANT_KEY,
            },
          }
        );
        const shwaryData = await shwaryResponse.json();

        if (shwaryResponse.ok && shwaryData.status && shwaryData.status !== 'pending') {
          await doc.ref.update({
            status: shwaryData.status,
            failureReason: shwaryData.failureReason || null,
            txHash: shwaryData.txHash || null,
            completedAt: shwaryData.completedAt || null,
            updatedAt: FieldValue.serverTimestamp(),
            reconciledManually: true,
          });

          if (tx.orderId) {
            await db.collection('orders').doc(tx.orderId).update({ paymentStatus: shwaryData.status });

            if (shwaryData.status === 'completed') {
              const orderDoc = await db.collection('orders').doc(tx.orderId).get();
              const orderUserId = orderDoc.data()?.userId;
              if (orderUserId) {
                await sendPushNotification(
                  orderUserId,
                  'Paiement confirmé',
                  'Votre paiement a été confirmé, votre commande est en cours de préparation.',
                  { type: 'payment_completed', orderId: tx.orderId }
                );
              }
            }
          }

          Sentry.captureMessage(`Reconciliation Shwary : transaction ${doc.id} mise a jour vers ${shwaryData.status}`, { level: 'info' });
          results.push({ id: doc.id, oldStatus: 'pending', newStatus: shwaryData.status });
        }
      } catch (err) {
        console.error(`Erreur reconciliation transaction ${doc.id}:`, err);
        Sentry.captureException(err);
      }
    }

    res.json({ checked: snapshot.size, updated: results.length, results });
  } catch (error) {
    console.error('Erreur reconciliation:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la reconciliation' });
  }
});

app.get('/api/shwary/status/:transactionId', async (req, res) => {
  try {
    const { transactionId } = req.params;
    const doc = await db.collection('transactions').doc(transactionId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Transaction introuvable' });
    }

    res.json(doc.data());
  } catch (error) {
    console.error('Erreur récupération statut:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

const { GoogleGenerativeAI } = require('@google/generative-ai');
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const searchProductsTool = {
  functionDeclarations: [
    {
      name: 'searchProducts',
      description: "Recherche des produits dans le catalogue DAVIDSTORE par nom, categorie ou mot-cle. A utiliser des que le client demande a voir un produit, une categorie, ou pose une question du type 'avez-vous...' / 'est-ce que vous vendez...'.",
      parameters: {
        type: 'OBJECT',
        properties: {
          query: { type: 'STRING', description: 'Mot-cle, nom ou categorie de produit a rechercher' },
        },
        required: ['query'],
      },
    },
  ],
};

async function searchProductsInFirestore(query) {
  const snapshot = await db.collection('products').where('active', '==', true).get();
  const q = (query || '').toLowerCase();
  const matches = [];
  snapshot.forEach((doc) => {
    const data = doc.data();
    const haystack = `${data.name || ''} ${data.category || ''}`.toLowerCase();
    if (!q || haystack.includes(q)) {
      matches.push({
        id: doc.id,
        name: data.name || '',
        category: data.category || '',
        price: data.price || 0,
        promoPrice: data.promoPrice || null,
        image: (data.images && data.images[0]) || null,
        description: data.description || '',
      });
    }
  });
  return matches.slice(0, 5);
}

app.post('/api/support-chat', async (req, res) => {
  try {
    const { message, history } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'message est requis' });
    }

    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      systemInstruction:
        "Tu es Nicole, l'assistante du support client de DAVIDSTORE, une boutique en ligne. Ne revele jamais que tu es une intelligence artificielle ou un programme ; comporte-toi comme une veritable membre de l'equipe support. Reponds en francais, de facon breve, polie et utile. Quand un client demande a voir un produit, une categorie, ou demande si un article existe, utilise l'outil searchProducts puis presente brievement ce que tu as trouve (les fiches produits detaillees s'afficheront automatiquement a l'ecran, ne les redecris pas en detail). Si tu ne peux pas resoudre le probleme, invite le client a contacter le support humain via WhatsApp.",
      tools: [searchProductsTool],
    });

    const chat = model.startChat({
      history: Array.isArray(history) ? history : [],
    });

    let result = await chat.sendMessage(message);
    let products = [];

    const functionCalls = result.response.functionCalls ? result.response.functionCalls() : null;

    if (functionCalls && functionCalls.length > 0) {
      const call = functionCalls[0];
      const foundProducts = await searchProductsInFirestore(call.args && call.args.query);
      products = foundProducts;

      result = await chat.sendMessage([
        {
          functionResponse: {
            name: 'searchProducts',
            response: { products: foundProducts.map((p) => ({ name: p.name, category: p.category, price: p.price })) },
          },
        },
      ]);
    }

    const reply = result.response.text();

    res.json({ reply, products });
  } catch (error) {
    console.error('Erreur chat support:', error);
    res.status(500).json({ error: 'Erreur lors de la generation de la reponse' });
  }
});


app.get('/api/admin/users', async (req, res) => {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

    if (!token) {
      return res.status(401).json({ error: 'Token manquant' });
    }

    const decoded = await getAuth().verifyIdToken(token);

    if (decoded.admin !== true) {
      return res.status(403).json({ error: 'Accès réservé aux administrateurs' });
    }

    const listResult = await getAuth().listUsers(1000);
    const users = listResult.users.map((u) => ({
      uid: u.uid,
      email: u.email || null,
      displayName: u.displayName || null,
      phoneNumber: u.phoneNumber || null,
      disabled: u.disabled,
      createdAt: u.metadata.creationTime,
    }));

    res.json({ users });
  } catch (error) {
    console.error('Erreur /api/admin/users:', error);
    res.status(401).json({ error: 'Token invalide ou expiré' });
  }
});
app.post('/api/notify-new-product', async (req, res) => {
  try {
    const { productName, productId } = req.body;
    if (!productName) {
      return res.status(400).json({ error: 'productName est requis' });
    }

    const result = await sendBroadcastNotification(
      '🎉 Nouveau produit disponible !',
      `Découvrez ${productName} et commandez dès maintenant sur DavidSTORE.`,
      { type: 'new_product', productId: productId || '' }
    );

    res.json(result);
  } catch (error) {
    console.error('Erreur /api/notify-new-product:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'envoi de la notification' });
  }
});

app.post('/api/auth/welcome', async (req, res) => {
  try {
    const { email, name } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'email est requis' });
    }

    await sendTransactionalEmail({ type: 'WELCOME', to: email, data: { name } });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /api/auth/welcome:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'envoi de l\'email de bienvenue' });
  }
});

app.post('/api/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'email est requis' });
    }

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

    const actionCodeSettings = {
      url: 'https://davidstore-757d8.firebaseapp.com',
      handleCodeInApp: false,
    };
    const resetLink = await getAuth().generatePasswordResetLink(email, actionCodeSettings);
    const when = new Date().toLocaleString('fr-FR', { timeZone: 'Africa/Kinshasa' }) + ' (heure de Kinshasa)';
    await sendTransactionalEmail({ type: 'PASSWORD_RESET', to: email, data: { resetLink, device, location, when } });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /api/auth/forgot-password:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la reinitialisation du mot de passe' });
  }
});

app.post('/api/auth/login-alert', async (req, res) => {
  try {
    const { email, uid } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'email est requis' });
    }

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

    const actionCodeSettings = {
      url: 'https://davidstore-757d8.firebaseapp.com',
      handleCodeInApp: false,
    };
    const resetLink = await getAuth().generatePasswordResetLink(email, actionCodeSettings);
    const when = new Date().toLocaleString('fr-FR', { timeZone: 'Africa/Kinshasa' }) + ' (heure de Kinshasa)';
    await sendTransactionalEmail({ type: 'LOGIN_ALERT', to: email, data: { device, location, ip: clientIp, when, resetLink }, relatedUserId: uid });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /api/auth/login-alert:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: "Erreur serveur lors de l'alerte de connexion" });
  }
});

app.post('/api/test-email/:type', async (req, res) => {
  if (req.query.token !== process.env.TEST_EMAIL_TOKEN) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  try {
    const { to, data } = req.body;
    if (!to) {
      return res.status(400).json({ error: 'to est requis' });
    }
    const result = await sendTransactionalEmail({ type: req.params.type.toUpperCase(), to, data: data || {} });
    res.json(result);
  } catch (error) {
    console.error('Erreur /api/test-email:', error);
    res.status(500).json({ error: 'Erreur serveur lors du test email' });
  }
});

app.post('/api/orders/:orderId/notify-driver-nearby', async (req, res) => {
  try {
    const { orderId } = req.params;
    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) {
      return res.status(404).json({ error: 'Commande introuvable' });
    }

    const orderData = orderDoc.data();
    const userId = orderData.userId;
    const orderNumber = orderData.orderNumber || orderId;

    if (!userId) {
      return res.json({ skipped: true, reason: 'userId absent de la commande' });
    }

    const customerEmail = (await getAuth().getUser(userId)).email;
    if (!customerEmail) {
      return res.json({ skipped: true, reason: 'Email client introuvable' });
    }

    const driverName = orderData.deliveryPerson?.name || null;
    const driverPhone = orderData.deliveryPerson?.phone || null;

    await sendTransactionalEmail({
      type: 'DRIVER_NEARBY',
      to: customerEmail,
      data: { orderNumber, driverName, driverPhone },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /api/orders/notify-driver-nearby:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification livreur proche' });
  }
});

app.post('/api/orders/notify-received', async (req, res) => {
  try {
    const { email, name, orderNumber, total, paymentMethod, deliveryAddress } = req.body;
    if (!email || !orderNumber) {
      return res.status(400).json({ error: 'email et orderNumber sont requis' });
    }

    const date = new Date().toLocaleDateString('fr-FR', { timeZone: 'Africa/Kinshasa' });
    const addressLabel = deliveryAddress
      ? `${deliveryAddress.address || ''}, ${deliveryAddress.commune || ''} ${deliveryAddress.city || ''}`.trim()
      : 'Non precise';

    await sendTransactionalEmail({
      type: 'ORDER_RECEIVED',
      to: email,
      data: { name, orderNumber, date, total, paymentMethod: paymentMethod || 'Non precise', deliveryAddress: addressLabel },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /api/orders/notify-received:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification de commande recue' });
  }
});

const STATUS_EMAIL_MAP = {
  preparing: 'ORDER_PREPARING',
  shipped: 'ORDER_SHIPPED',
  delivered: 'DELIVERY_COMPLETED',
  cancelled: 'ORDER_CANCELLED',
};

app.post('/api/orders/:orderId/notify-status', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status, extra } = req.body;

    const templateType = STATUS_EMAIL_MAP[status];
    if (!templateType) {
      return res.json({ skipped: true, reason: 'Aucun email associe a ce statut' });
    }

    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) {
      return res.status(404).json({ error: 'Commande introuvable' });
    }

    const orderData = orderDoc.data();
    const userId = orderData.userId;
    const orderNumber = orderData.orderNumber || orderId;

    if (!userId) {
      return res.json({ skipped: true, reason: 'userId absent de la commande' });
    }

    const customerEmail = (await getAuth().getUser(userId)).email;
    if (!customerEmail) {
      return res.json({ skipped: true, reason: 'Email client introuvable' });
    }

    let data = { orderNumber, ...(extra || {}) };
    if (templateType === 'DELIVERY_COMPLETED') {
      data.deliveryDate = new Date().toLocaleDateString('fr-FR', { timeZone: 'Africa/Kinshasa' });
    }

    await sendTransactionalEmail({ type: templateType, to: customerEmail, data });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /api/orders/notify-status:', error);
    Sentry.captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification de statut' });
  }
});

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Serveur DavidSTORE Payment démarré sur le port ${PORT}`);
  });
}

module.exports = app;
