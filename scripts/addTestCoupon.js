const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

const coupon = {
  code: "BIENVENUE10",
  type: "percent",
  value: 10,
  validity: Timestamp.fromDate(new Date("2026-12-31")),
  minOrder: 50000,
  color: "F59E0B",
  active: true,
};

db.collection("coupons")
  .add(coupon)
  .then((docRef) => {
    console.log(`✅ Coupon de test ajouté avec l'ID: ${docRef.id}`);
    console.log(coupon);
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Erreur:", error.message);
    process.exit(1);
  });
