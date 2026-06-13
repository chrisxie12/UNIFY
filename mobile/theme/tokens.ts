export const COLORS = {
  // Surfaces
  white:    '#FFFFFF',
  surface:  '#F8F9FA',
  tertiary: '#F0F7FF',
  // Text
  primary:   '#FFFFFF',
  secondary: '#374151',
  tertxt:    '#9CA3AF',
  // Accents
  blue:   '#0066FF',
  orange: '#FF6B35',
  green:  '#10B981',
  red:    '#EF4444',
  // UI
  btnPrimary: '#1F2937',
  border:     '#E5E7EB',
  // Backwards-compat
  charcoal: '#1F2937',
  muted:    '#6B7280',
  subtle:   '#9CA3AF',
  divider:  '#E5E7EB',
  accent:   '#0066FF',
  notif:    '#FF6B35',
  parchment:'#FFFFFF',
  ink:      '#1F2937',
  text:     '#111827',
  textMuted:'#6B7280',
} as const;

export type AccentColor = 'blue' | 'orange' | 'green' | 'red';

export interface Chat {
  id: string;
  name: string;
  school: string;
  match: string;
  last: string;
  time: string;
  unread: number;
  initials: string;
  accent: string;
}

export interface ChatMessage {
  id: string;
  mine: boolean;
  text: string;
  time: string;
}

export interface StudentProfile {
  id: string;
  name: string;
  displayName: string;
  school: string;
  programme: string;
  level: string;
  hometown: string;
  bio: string;
  matchPct: number;
  initials: string;
  sleep: string;
  cleanliness: string;
  noise: string;
  study: string;
  hostels: string[];
}
