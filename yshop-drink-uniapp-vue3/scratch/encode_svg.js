const svgs = {
  takeout_large: `<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="38" cy="18" r="4" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M30 26L36 22L42 27L38 35H30" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M18 42H44L38 34" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="20" cy="48" r="6" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="44" cy="48" r="6" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M44 48L46 32H42" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="12" y="24" width="12" height="14" rx="2" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M4 22H8M2 28H8M4 34H6" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  takeout_small: `<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M22 42H48L42 34" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="24" cy="48" r="5" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="46" cy="48" r="5" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M46 48L48 30H44" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="14" y="26" width="10" height="12" rx="1.5" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M6 18H14M4 26H12M8 34H12" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  takein_small: `<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 22H52" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round"/>
    <path d="M14 22L18 12H46L50 22" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 22C14 22 15 24 17 24C19 24 20 22 22 22C24 22 25 24 27 24C29 24 30 22 32 22C34 22 35 24 37 24C39 24 40 22 42 22C44 22 45 24 47 24C49 24 50 22 52 22" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round"/>
    <path d="M16 24V52H48V24" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M26 52V36H38V52" stroke="#D4AF37" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="24" y="14" width="16" height="5" rx="1" fill="#D4AF37"/>
  </svg>`,

  stat_coin: `<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="12" cy="12" r="8" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <line x1="12" y1="8" x2="12" y2="16" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <line x1="8" y1="12" x2="16" y2="12" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  stat_wallet: `<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="2" y="4" width="20" height="16" rx="2" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 11h8v2h-8z" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  stat_ticket: `<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M15 4H9M15 20H9M20 9v6M4 9v6" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="2" y="4" width="20" height="16" rx="2" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  beer_glass_inactive: `<svg viewBox="0 0 24 30" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M6 8V24C6 25.1 6.9 26 8 26H16C17.1 26 18 25.1 18 24V8" stroke="#333333" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M18 11H20.5C21.3 11 22 11.7 22 12.5V19.5C22 20.3 21.3 21 20.5 21H18" stroke="#333333" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  beer_glass_active: `<svg viewBox="0 0 24 30" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M6 8V24C6 25.1 6.9 26 8 26H16C17.1 26 18 25.1 18 24V8" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M18 11H20.5C21.3 11 22 11.7 22 12.5V19.5C22 20.3 21.3 21 20.5 21H18" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M5 8C5 6.9 5.9 6 7 6H17C18.1 6 19 6.9 19 8C19 8.55 18.55 9 18 9H6C5.45 9 5 8.55 5 8Z" fill="#FFFFFF"/>
    <path d="M7 10V24H17V10H7Z" fill="#D4AF37"/>
  </svg>`,

  grid_coupons: `<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M2 9V6a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v3a2 2 0 0 0 0 4v3a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2v-3a2 2 0 0 0 0-4Z" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 4v16" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="2 2" />
  </svg>`,

  grid_score: `<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="12" cy="8" r="6" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 14c-4.4 0-8 2-8 4v2h16v-2c0-2-3.6-4-8-4Z" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M9 8h6M12 5v6" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,

  grid_invite: `<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20 12v10H4V12" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="2" y="7" width="20" height="5" rx="1" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 22V7" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 7c-1.5-3-4.5-3-4.5 0S10.5 7 12 7Z" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 7c1.5-3 4.5-3 4.5 0S13.5 7 12 7Z" stroke="#D4AF37" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`
};

for (const [key, value] of Object.entries(svgs)) {
  const clean = value.replace(/\s+/g, ' ').trim();
  const b64 = Buffer.from(clean).toString('base64');
  console.log(`${key}: "data:image/svg+xml;base64,${b64}",`);
}
