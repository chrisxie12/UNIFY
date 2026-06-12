// UNIFY Neubrutalism design tokens — single source of truth.
// 90% calm canvas (parchment/white reading zones), 10% loud accents.

export const COLORS = {
  // Canvas
  parchment: '#F4F4F0',
  white: '#FFFFFF',
  ink: '#000000',
  text: '#111111',
  textMuted: '#555555',
  darkBase: '#121212',
  // Loud accents
  action: '#FFE600', // neon yellow — primary actions
  brand: '#FF6B35', // UNIFY orange
  verify: '#00FF66', // neon green — identity/verification
  alert: '#FF007A', // hot pink — unread/notifications
  info: '#0066FF',
  success: '#16a34a',
} as const;

export type AccentColor = keyof Pick<
  typeof COLORS,
  'action' | 'brand' | 'verify' | 'alert' | 'info' | 'success'
>;

export interface Thread {
  id: string;
  hub: string;
  title: string;
  author: string;
  level: string;
  verified: boolean;
  upvotes: number;
  comments: number;
  time: string;
}

export interface ThreadComment {
  id: string;
  author: string;
  level: string;
  verified: boolean;
  upvotes: number;
  depth: number;
  text: string;
}

export interface Chat {
  id: string;
  name: string;
  school: string;
  match: string;
  last: string;
  time: string;
  unread: number;
  initials: string;
  accent: AccentColor;
}

export interface ChatMessage {
  id: string;
  mine: boolean;
  text: string;
  time: string;
}
