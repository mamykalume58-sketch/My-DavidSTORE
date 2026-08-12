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

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Serveur DavidSTORE Payment démarré sur le port ${PORT}`);
  });
}

module.exports = app;
