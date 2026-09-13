const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

async function migrate() {
  console.log("🔍 Recherche des favoris sans image...");

  // Cache des produits déjà lus pour éviter des lectures répétées
  const productCache = new Map();

  async function getProductImage(productId) {
    if (productCache.has(productId)) return productCache.get(productId);
    const doc = await db.collection("products").doc(productId).get();
    const image = doc.exists ? (doc.data().images?.[0] || "") : "";
    productCache.set(productId, image);
    return image;
  }

  const favoritesSnapshot = await db.collectionGroup("favorites").get();
  console.log(`📦 ${favoritesSnapshot.size} favori(s) trouvé(s) au total.`);

  let updated = 0;
  let skipped = 0;
  let notFound = 0;

  for (const doc of favoritesSnapshot.docs) {
    const data = doc.data();

    if (data.image) {
      skipped++;
      continue;
    }

    const productId = data.productId || doc.id;
    const image = await getProductImage(productId);

    if (!image) {
      notFound++;
      console.log(`⚠️  Pas d'image trouvée pour le produit "${productId}" (favori ${doc.ref.path})`);
      continue;
    }

    await doc.ref.update({ image });
    updated++;
    console.log(`✅ ${doc.ref.path} -> image ajoutée`);
  }

  console.log("\n--- Résumé ---");
  console.log(`✅ Mis à jour : ${updated}`);
  console.log(`⏭️  Déjà à jour (skip) : ${skipped}`);
  console.log(`⚠️  Produit/image introuvable : ${notFound}`);
}

migrate()
  .then(() => {
    console.log("🎉 Migration terminée.");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Erreur:", error.message);
    process.exit(1);
  });
