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

module.exports = { escapeHtml, title, paragraph, infoRow, infoCard, button, securityNote, progressSteps };
