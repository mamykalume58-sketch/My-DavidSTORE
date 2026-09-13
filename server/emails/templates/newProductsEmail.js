const { wrapEmail } = require('../emailLayout');
const { title, paragraph, productGrid, button } = require('../emailRenderer');

function newProductsEmail({ products }) {
  const body = `
    ${title('🎉 Découvrez nos nouveaux produits')}
    ${paragraph(`${products.length} nouveaux produits viennent d'arriver sur DavidSTORE. Jetez-y un coup d'œil avant qu'ils ne partent !`)}
    ${productGrid(products)}
    ${button('Voir tout le catalogue', 'https://davidstore-payment.vercel.app/catalog')}
  `;
  return wrapEmail({ title: 'Nouveaux produits DavidSTORE', bodyHtml: body });
}

module.exports = { newProductsEmail };
