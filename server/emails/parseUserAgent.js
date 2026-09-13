function parseUserAgent(ua) {
  if (!ua || ua === 'Inconnu') return 'Inconnu';

  let os = 'Appareil inconnu';
  if (/android/i.test(ua)) os = 'Android';
  else if (/iphone|ipad|ipod/i.test(ua)) os = 'iOS';
  else if (/windows/i.test(ua)) os = 'Windows';
  else if (/mac os/i.test(ua)) os = 'Mac';
  else if (/linux/i.test(ua)) os = 'Linux';

  let browser = '';
  if (/chrome/i.test(ua) && !/edg/i.test(ua)) browser = 'Chrome';
  else if (/firefox/i.test(ua)) browser = 'Firefox';
  else if (/safari/i.test(ua) && !/chrome/i.test(ua)) browser = 'Safari';
  else if (/edg/i.test(ua)) browser = 'Edge';
  else if (/curl/i.test(ua)) browser = 'Test technique';

  if (browser && os !== 'Appareil inconnu') return `${browser} sur ${os}`;
  if (browser) return browser;
  return os;
}

module.exports = { parseUserAgent };
