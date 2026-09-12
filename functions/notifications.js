const express = require('express');
const { db, getAuth, getSentry, requireAuth, sendBroadcastNotification, sendPushToDriver } = require('./shared');
const { sendTransactionalEmail } = require('./emails/emailService');

const router = express.Router();

router.post('/notify-new-product', requireAuth, async (req, res) => {
  try {
    const { productName, productId } = req.body;
    if (!productName) return res.status(400).json({ error: 'productName est requis' });

    const result = await sendBroadcastNotification(
      '🎉 Nouveau produit disponible !',
      `Découvrez ${productName} et commandez dès maintenant sur DavidSTORE.`,
      { type: 'new_product', productId: productId || '' }
    );

    res.json(result);
  } catch (error) {
    console.error('Erreur /notify-new-product:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'envoi de la notification' });
  }
});

router.post('/orders/:orderId/notify-driver-nearby', requireAuth, async (req, res) => {
  try {
    const { orderId } = req.params;
    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) return res.status(404).json({ error: 'Commande introuvable' });

    const orderData = orderDoc.data();
    const userId = orderData.userId;
    const orderNumber = orderData.orderNumber || orderId;

    if (!userId) return res.json({ skipped: true, reason: 'userId absent de la commande' });

    const customerEmail = (await getAuth().getUser(userId)).email;
    if (!customerEmail) return res.json({ skipped: true, reason: 'Email client introuvable' });

    const driverName = orderData.deliveryPerson?.name || null;
    const driverPhone = orderData.deliveryPerson?.phone || null;

    await sendTransactionalEmail({ type: 'DRIVER_NEARBY', to: customerEmail, data: { orderNumber, driverName, driverPhone } });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /orders/notify-driver-nearby:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification livreur proche' });
  }
});

router.post('/orders/notify-received', requireAuth, async (req, res) => {
  try {
    const { email, name, orderId, orderNumber, total, paymentMethod, deliveryAddress } = req.body;
    if (!email || !orderNumber) return res.status(400).json({ error: 'email et orderNumber sont requis' });

    const date = new Date().toLocaleDateString('fr-FR', { timeZone: 'Africa/Kinshasa' });
    const addressLabel = deliveryAddress
      ? `${deliveryAddress.address || ''}, ${deliveryAddress.commune || ''} ${deliveryAddress.city || ''}`.trim()
      : 'Non precise';

    await sendTransactionalEmail({
      type: 'ORDER_RECEIVED',
      to: email,
      data: { name, orderId, orderNumber, date, total, paymentMethod: paymentMethod || 'Non precise', deliveryAddress: addressLabel },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /orders/notify-received:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification de commande recue' });
  }
});

const STATUS_EMAIL_MAP = {
  preparing: 'ORDER_PREPARING',
  shipped: 'ORDER_SHIPPED',
  delivered: 'DELIVERY_COMPLETED',
  cancelled: 'ORDER_CANCELLED',
};

router.post('/orders/:orderId/notify-status', requireAuth, async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status, extra } = req.body;

    const templateType = STATUS_EMAIL_MAP[status];
    if (!templateType) return res.json({ skipped: true, reason: 'Aucun email associe a ce statut' });

    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) return res.status(404).json({ error: 'Commande introuvable' });

    const orderData = orderDoc.data();
    const userId = orderData.userId;
    const orderNumber = orderData.orderNumber || orderId;

    if (!userId) return res.json({ skipped: true, reason: 'userId absent de la commande' });

    const customerEmail = (await getAuth().getUser(userId)).email;
    if (!customerEmail) return res.json({ skipped: true, reason: 'Email client introuvable' });

    let data = { orderId, orderNumber, ...(extra || {}) };
    if (templateType === 'DELIVERY_COMPLETED') {
      data.deliveryDate = new Date().toLocaleDateString('fr-FR', { timeZone: 'Africa/Kinshasa' });
    }

    await sendTransactionalEmail({ type: templateType, to: customerEmail, data });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /orders/notify-status:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification de statut' });
  }
});

router.post('/orders/:orderId/notify-driver', requireAuth, async (req, res) => {
  try {
    const { orderId } = req.params;
    const { type, title, body } = req.body;
    if (!title || !body) return res.status(400).json({ error: 'title et body requis' });

    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) return res.status(404).json({ error: 'Commande introuvable' });

    const driverId = orderDoc.data()?.driverId;
    if (!driverId) return res.json({ skipped: true, reason: 'driverId absent de la commande' });

    await sendPushToDriver(driverId, title, body, { type: type || 'generic', orderId });

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur /orders/notify-driver:', error);
    getSentry().captureException(error);
    res.status(500).json({ error: 'Erreur serveur lors de la notification livreur' });
  }
});

module.exports = router;
