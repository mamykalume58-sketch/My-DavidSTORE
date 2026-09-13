const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

/// Upload une image base64 (avec ou sans prefixe data:) vers Cloudinary et
/// retourne son URL https publique. `folder` permet de ranger les images
/// par categorie (products, livreurs, documents...).
async function uploadToCloudinary(base64Image, folder = 'davidstore') {
  const dataUri = base64Image.startsWith('data:')
    ? base64Image
    : `data:image/jpeg;base64,${base64Image}`;

  const result = await cloudinary.uploader.upload(dataUri, { folder });
  return result.secure_url;
}

module.exports = { uploadToCloudinary };
