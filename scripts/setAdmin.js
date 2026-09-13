const { initializeApp, cert } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount),
});

const email = "davstore4@gmail.com";

getAuth().getUserByEmail(email)
  .then((user) => {
    return getAuth().setCustomUserClaims(user.uid, { admin: true });
  })
  .then(() => {
    console.log(`✅ Rôle admin attribué avec succès à ${email}`);
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Erreur:", error.message);
    process.exit(1);
  });
