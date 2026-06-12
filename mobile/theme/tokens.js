// UNIFY Neo-Brutalist design tokens — single source of truth.
// 90% canvas / 10% loud accent architecture.

export const COLORS = {
  // 90% canvas (reading zones)
  parchment: '#F4F4F0',
  white: '#FFFFFF',
  ink: '#000000',
  text: '#111111',
  textMuted: '#555555',
  darkBase: '#121212',
  darkCard: '#000000',
  // 10% loud accents (actions & status)
  action: '#FFE600',   // primary action
  brand: '#FF6B35',    // UNIFY brand orange
  verify: '#00FF66',   // identity & verification badges
  alert: '#FF007A',    // notifications & unread counts
};

export const SHADOW = {
  // Hard offsets, zero blur. Built with the stacked-view technique in
  // components/NB.jsx because RN shadows blur on Android.
  standard: 4,
  micro: 2,
};

export const BORDER = {
  width: 2,
  color: COLORS.ink,
};

export const RADIUS = {
  none: 0,
  md: 4,
};
