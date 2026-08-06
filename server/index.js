require('dotenv').config();
const express = require('express');
const fetch = require('node-fetch');
const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

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

const app = express();
app.use(express.json());

const SHWARY_BASE_URL = 'https://api.shwary.com/api/v1';
const SHWARY_MERCHANT_ID = process.env.SHWARY_MERCHANT_ID;
const SHWARY_MERCHANT_KEY = process.env.SHWARY_MERCHANT_KEY;
const CALLBACK_URL = process.env.CALLBACK_URL;

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'davidstore-payment-server' });
});

app.post('/api/shwary/pay', async (req, res) => {
  try {
    const { amount, clientPhoneNumber, orderId, sandbox } = req.body;

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
      body: JSON.stringify({ amount, clientPhoneNumber, callbackUrl: CALLBACK_URL }),
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
    });

    res.json({ transactionId: data.id, status: data.status });
  } catch (error) {
    console.error('Erreur initiation paiement:', error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'initiation du paiement' });
  }
});

app.post('/api/shwary/callback', async (req, res) => {
  try {
    const transaction = req.body;
    const { id, status, failureReason, txHash, completedAt } = transaction;

    if (!id || !status) {
      return res.status(400).json({ error: 'Payload invalide' });
    }

    const transactionRef = db.collection('transactions').doc(id);
    const transactionDoc = await transactionRef.get();

    if (!transactionDoc.exists) {
      console.warn(`Transaction inconnue reçue en callback: ${id}`);
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
    }

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Erreur callback Shwary:', error);
    res.status(500).json({ error: 'Erreur serveur lors du traitement du callback' });
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

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Serveur DavidSTORE Payment démarré sur le port ${PORT}`);
  });
}

module.exports = app;
