const express = require('express');
const fetch = require('node-fetch');
const {
  db, FieldValue, getAuth, getSentry, sendPushNotification,
  SHWARY_BASE_URL, SHWARY_MERCHANT_ID, SHWARY_MERCHANT_KEY,
  CALLBACK_URL, SHWARY_CALLBACK_TOKEN, RECONCILE_TOKEN,
} = require('./shared');
const { sendTransactionalEmail } = require('./emails/emailService');

const router = express.Router();

router.get('/test-status/:transactionId', async (req, res) => {
  try {
    const response = await fetch(
      `${SHWARY_BASE_URL}/merchants/transactions/${req.params.transactionId}`,
      { headers: { 'x-merchant-id': SHWARY_MERCHANT_ID.value(), 'x-merchant-key': SHWARY_MERCHANT_KEY.value() } }
    );
    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    console.error('Erreur test-status Shwary:', error);
    res.status(500).json({ error: error.message });
  }
});

router.post('/pay', async (req, res) => {
  try {
    const { clientPhoneNumber, orderId, paymentMethod } = req.body;

    if (!clientPhoneNumber || !orderId) {
      return res.status(400).json({ error: 'clientPhoneNumber et orderId sont requis' });
    }
    if (!/^\+243\d{9}$/.test(clientPhoneNumber)) {
      return res.status(400).json({ error: 'Numero de telephone invalide (format attendu: +243XXXXXXXXX)' });
    }

    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) {
      return res.status(404).json({ error: 'Commande introuvable' });
    }
    const orderData = orderDoc.data();
    const amount = orderData.total;
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Montant de la commande invalide' });
    }
    if (orderData.paymentStatus === 'completed') {
      return res.status(409).json({ error: 'Cette commande a deja ete payee' });
    }

    const endpoint = `${SHWARY_BASE_URL}/merchants/payment/DRC`;
    const shwaryResponse = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-merchant-id': SHWARY_MERCHANT_ID.value(),
        'x-merchant-key': SHWARY_MERCHANT_KEY.value(),
      },
      body: JSON.stringify({ amount, clientPhoneNumber, callbackUrl: `${CALLBACK_URL.value()}?token=${SHWARY_CALLBACK_TOKEN.value()}` }),
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
      isSandbox: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    await db.collection('orders').doc(orderId).update({
      transactionId: data.id,
      paymentStatus: data.status || 'pending',
      paymentMethod: paymentMethod || null,
    });

    await db.collection('securityLogs').add({
      action: 'payment_created',
      userId: orderData.userId || null,
      targetId: orderId,
      timestamp: FieldValue.serverTimestamp(),
      metadata: { amount, transactionId: data.id },
    });

    res.json({ transactionId: data.id, status: data.status });
  } catch (error) {
    console.error('Erreur initiation paiement:', error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'initiation du paiement' });
  }
});

router.post('/callback', async (req, res) => {
  try {
    if (req.query.token !== SHWARY_CALLBACK_TOKEN.value()) {
      console.warn('Callback Shwary refuse : token invalide ou manquant');
      getSentry().captureMessage('Callback Shwary refuse : token invalide', { level: 'warning' });
      return res.status(401).json({ error: 'Non autorise' });
    }

    const transaction = req.body;
    const { id, status, failureReason, txHash, completedAt } = transaction;
    if (!id || !status) {
      return res.status(400).json({ error: 'Payload invalide' });
    }

    const transactionRef = db.collection('transactions').doc(id);
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
      getSentry().captureMessage(`Callback Shwary orphelin : transaction ${id} introuvable`, { level: 'error', extra: { payload: transaction } });
      await db.collection('orphan_callbacks').doc(id).set({ payload: transaction, receivedAt: FieldValue.serverTimestamp() });
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
      await db.collection('orders').doc(orderId).update({ paymentStatus: status, failureReason: failureReason || null });

      if (status === 'completed') {
        const orderDoc = await db.collection('orders').doc(orderId).get();
        const orderUserId = orderDoc.data()?.userId;
        if (orderUserId) {
          await sendPushNotification(orderUserId, 'Paiement confirmé', 'Votre paiement a été confirmé, votre commande est en cours de préparation.', { type: 'payment_completed', orderId });
          try {
            const orderNumber = orderDoc.data()?.orderNumber || orderId;
            const customerEmail = (await getAuth().getUser(orderUserId)).email;
            if (customerEmail) {
              await db.collection('securityLogs').add({ action: 'payment_confirmed', userId: orderUserId, targetId: orderId, timestamp: FieldValue.serverTimestamp(), metadata: { amount: orderDoc.data()?.total } });
              await sendTransactionalEmail({ type: 'PAYMENT_CONFIRMED', to: customerEmail, data: { orderId, orderNumber, amount: orderDoc.data()?.total, paymentMethod: orderDoc.data()?.paymentMethod } });
            }
          } catch (emailError) {
            console.error('Erreur envoi email confirmation paiement:', emailError);
            getSentry().captureException(emailError);
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
              await db.collection('securityLogs').add({ action: 'payment_failed', userId: orderUserId, targetId: orderId, timestamp: FieldValue.serverTimestamp(), metadata: { reason: failureReason || null } });
              await sendTransactionalEmail({ type: 'PAYMENT_FAILED', to: customerEmail, data: { orderNumber, reason: failureReason || null } });
            }
          } catch (emailError) {
            console.error('Erreur envoi email echec paiement:', emailError);
            getSentry().captureException(emailError);
          }
        }
      }
    }

    getSentry().captureMessage(`Callback Shwary traite : transaction ${id}, statut ${status}`, { level: 'info', extra: { orderId, status, failureReason } });
    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Erreur callback Shwary:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors du traitement du callback' });
  }
});

router.get('/reconcile', async (req, res) => {
  try {
    if (req.query.token !== RECONCILE_TOKEN.value()) {
      return res.status(401).json({ error: 'Non autorise' });
    }
    const cutoff = new Date(Date.now() - 3 * 60 * 1000);
    const snapshot = await db.collection('transactions').where('status', '==', 'pending').get();
    const results = [];

    for (const doc of snapshot.docs) {
      const tx = doc.data();
      const createdAt = tx.createdAt?.toDate?.();
      if (!createdAt || createdAt > cutoff) continue;

      try {
        const shwaryResponse = await fetch(`${SHWARY_BASE_URL}/merchants/transactions/${doc.id}`, {
          headers: { 'x-merchant-id': SHWARY_MERCHANT_ID.value(), 'x-merchant-key': SHWARY_MERCHANT_KEY.value() },
        });
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
            await db.collection('orders').doc(tx.orderId).update({ paymentStatus: shwaryData.status, failureReason: shwaryData.failureReason || null });

            if (shwaryData.status === 'completed') {
              const orderDoc = await db.collection('orders').doc(tx.orderId).get();
              const orderUserId = orderDoc.data()?.userId;
              if (orderUserId) {
                await sendPushNotification(orderUserId, 'Paiement confirmé', 'Votre paiement a été confirmé, votre commande est en cours de préparation.', { type: 'payment_completed', orderId: tx.orderId });
                try {
                  const orderNumber = orderDoc.data()?.orderNumber || tx.orderId;
                  const customerEmail = (await getAuth().getUser(orderUserId)).email;
                  if (customerEmail) {
                    await sendTransactionalEmail({ type: 'PAYMENT_CONFIRMED', to: customerEmail, data: { orderId: tx.orderId, orderNumber, amount: orderDoc.data()?.total, paymentMethod: orderDoc.data()?.paymentMethod } });
                  }
                } catch (emailError) {
                  console.error('Erreur envoi email confirmation paiement (reconcile):', emailError);
                  getSentry().captureException(emailError);
                }
              }
            } else if (shwaryData.status === 'failed') {
              const orderDoc = await db.collection('orders').doc(tx.orderId).get();
              const orderUserId = orderDoc.data()?.userId;
              if (orderUserId) {
                try {
                  const orderNumber = orderDoc.data()?.orderNumber || tx.orderId;
                  const customerEmail = (await getAuth().getUser(orderUserId)).email;
                  if (customerEmail) {
                    await sendTransactionalEmail({ type: 'PAYMENT_FAILED', to: customerEmail, data: { orderNumber, reason: shwaryData.failureReason || null } });
                  }
                } catch (emailError) {
                  console.error('Erreur envoi email echec paiement (reconcile):', emailError);
                  getSentry().captureException(emailError);
                }
              }
            }
          }

          getSentry().captureMessage(`Reconciliation Shwary : transaction ${doc.id} mise a jour vers ${shwaryData.status}`, { level: 'info' });
          results.push({ id: doc.id, oldStatus: 'pending', newStatus: shwaryData.status });
        }
      } catch (err) {
        console.error(`Erreur reconciliation transaction ${doc.id}:`, err);
        getSentry().captureException(err);
      }
    }

    res.json({ checked: snapshot.size, updated: results.length, results });
  } catch (error) {
    console.error('Erreur reconciliation:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la reconciliation' });
  }
});

router.get('/status/:transactionId', async (req, res) => {
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

module.exports = router;
