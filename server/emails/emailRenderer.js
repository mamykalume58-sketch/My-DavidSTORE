const { COLORS } = require('./emailStyles');

function escapeHtml(str) {
  if (str === undefined || str === null) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function title(text) {
  return `<h1 style="font-size:19px;font-weight:600;color:${COLORS.textPrimary};margin:0 0 12px;line-height:1.4;">${escapeHtml(text)}</h1>`;
}

function paragraph(text) {
  return `<p style="font-size:14px;color:${COLORS.textSecondary};line-height:1.7;margin:0 0 20px;">${escapeHtml(text)}</p>`;
}

function infoRow(label, value, opts = {}) {
  const valueColor = opts.color || COLORS.textPrimary;
  const border = opts.last ? '' : `border-bottom:0.5px solid ${COLORS.divider};`;
  return `<div style="display:flex;justify-content:space-between;padding:6px 0;${border}">
    <span style="font-size:13px;color:${COLORS.textSecondary};">${escapeHtml(label)}</span>
    <span style="font-size:13px;color:${valueColor};font-weight:600;">${escapeHtml(value)}</span>
  </div>`;
}

function infoCard(rowsHtml) {
  return `<div style="background:${COLORS.cardBgSecondary};border-radius:10px;padding:16px 18px;margin-bottom:20px;">
    ${rowsHtml}
  </div>`;
}

function button(label, url) {
  return `<a href="${escapeHtml(url)}" style="display:block;background:${COLORS.navy};border-radius:8px;padding:12px;text-align:center;text-decoration:none;margin-bottom:20px;" target="_blank">
    <span style="font-size:14px;font-weight:600;color:${COLORS.white} !important;mso-line-height-rule:exactly;">${escapeHtml(label)}</span>
  </a>`;
}

function securityNote(text) {
  return `<p style="font-size:12px;color:${COLORS.textMuted};line-height:1.6;margin:0;">${escapeHtml(text)}</p>`;
}

function codeBlock(code) {
  return `<div style="background:${COLORS.cardBgSecondary};border-radius:10px;padding:20px;margin-bottom:20px;text-align:center;">
    <span style="font-size:32px;font-weight:700;letter-spacing:8px;color:${COLORS.navy};font-family:monospace;">${escapeHtml(code)}</span>
  </div>`;
}

function progressSteps(steps, currentIndex) {
  const items = steps.map((label, i) => {
    const active = i === currentIndex;
    const done = i < currentIndex;
    const color = active || done ? COLORS.gold : COLORS.divider;
    const textColor = active ? COLORS.gold : COLORS.textSecondary;
    return `<div style="text-align:center;flex:1;">
      <div style="width:10px;height:10px;border-radius:50%;background:${color};margin:0 auto 6px;"></div>
      <span style="font-size:10px;color:${textColor};">${escapeHtml(label)}</span>
    </div>`;
  }).join('');
  return `<div style="display:flex;justify-content:space-between;margin-bottom:20px;">${items}</div>`;
}

function productGrid(products) {
  const cards = products.map((p) => {
    const image = p.images && p.images[0] ? p.images[0] : '';
    const hasPromo = p.promoPrice != null && p.promoPrice < p.price;
    const priceHtml = hasPromo
      ? `<span style="font-size:13px;color:${COLORS.textMuted};text-decoration:line-through;margin-right:6px;">${p.price} FC</span><span style="font-size:14px;color:${COLORS.gold};font-weight:700;">${p.promoPrice} FC</span>`
      : `<span style="font-size:14px;color:${COLORS.gold};font-weight:700;">${p.price} FC</span>`;
    return `<td width="50%" style="padding:6px;vertical-align:top;">
      <div style="background:${COLORS.cardBgSecondary};border-radius:10px;overflow:hidden;">
        <img src="${escapeHtml(image)}" alt="${escapeHtml(p.name)}" style="width:100%;height:140px;object-fit:cover;display:block;" />
        <div style="padding:10px 12px;">
          <p style="font-size:12.5px;color:${COLORS.textPrimary};margin:0 0 6px;font-weight:600;line-height:1.3;">${escapeHtml(p.name)}</p>
          ${priceHtml}
        </div>
      </div>
    </td>`;
  });

  const rows = [];
  for (let i = 0; i < cards.length; i += 2) {
    rows.push(`<tr>${cards[i]}${cards[i + 1] || '<td width="50%"></td>'}</tr>`);
  }

  return `<table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:20px;"><tbody>${rows.join('')}</tbody></table>`;
}

module.exports = { escapeHtml, title, paragraph, infoRow, infoCard, button, securityNote, progressSteps, codeBlock, productGrid };
