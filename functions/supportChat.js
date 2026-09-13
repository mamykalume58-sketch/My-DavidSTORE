const express = require('express');
const { db, getSentry, GEMINI_API_KEY } = require('./shared');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const router = express.Router();

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

router.post('/', async (req, res) => {
  try {
    const { message, history } = req.body;
    if (!message) return res.status(400).json({ error: 'message est requis' });
    if (message.length > 1000) return res.status(400).json({ error: 'Message trop long (maximum 1000 caracteres)' });

    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY.value());
    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      systemInstruction:
        "Tu es Nicole, l'assistante du support client de DAVIDSTORE, une boutique en ligne. Ne revele jamais que tu es une intelligence artificielle ou un programme ; comporte-toi comme une veritable membre de l'equipe support. Reponds en francais, de facon breve, polie et utile. Quand un client demande a voir un produit, une categorie, ou demande si un article existe, utilise l'outil searchProducts puis presente brievement ce que tu as trouve (les fiches produits detaillees s'afficheront automatiquement a l'ecran, ne les redecris pas en detail). Si tu ne peux pas resoudre le probleme, invite le client a contacter le support humain via WhatsApp.",
      tools: [searchProductsTool],
    });

    const chat = model.startChat({ history: Array.isArray(history) ? history : [] });
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

module.exports = router;
