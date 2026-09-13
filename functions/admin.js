const express = require('express');
const { db, FieldValue, getAuth, getSentry } = require('./shared');

const router = express.Router();

router.get('/users', async (req, res) => {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    if (!token) return res.status(401).json({ error: 'Token manquant' });

    const decoded = await getAuth().verifyIdToken(token);
    if (decoded.admin !== true) return res.status(403).json({ error: 'Accès réservé aux administrateurs' });

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
    console.error('Erreur /admin/users:', error);
    res.status(401).json({ error: 'Token invalide ou expiré' });
  }
});

router.post('/users/:uid/disable', async (req, res) => {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    if (!token) return res.status(401).json({ error: 'Token manquant' });

    const decoded = await getAuth().verifyIdToken(token);
    if (decoded.admin !== true) return res.status(403).json({ error: 'Accès réservé aux administrateurs' });

    const { uid } = req.params;
    const { disabled } = req.body;
    if (typeof disabled !== 'boolean') return res.status(400).json({ error: 'Le champ disabled (boolean) est requis' });

    await getAuth().updateUser(uid, { disabled });
    await db.collection('securityLogs').add({
      action: disabled ? 'account_disabled' : 'account_enabled',
      userId: decoded.uid,
      targetId: uid,
      timestamp: FieldValue.serverTimestamp(),
    });

    res.json({ success: true, disabled });
  } catch (error) {
    console.error('Erreur /admin/users/:uid/disable:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la mise a jour du compte' });
  }
});

module.exports = router;
