// UNIFY Clean Bold design tokens — single source of truth.
// Minimal palette: charcoal text, white surfaces, blue for action,
// orange for notifications/decorative marks only.

export const COLORS = {
  white: '#FFFFFF',
  surface: '#F3F4F6',
  charcoal: '#1F2937',
  muted: '#6B7280',
  subtle: '#9CA3AF',
  divider: '#E5E7EB',
  accent: '#0066FF',
  notif: '#FF6B35',
  // parchment alias stays so AppContext / layout refs resolve
  parchment: '#FFFFFF',
  ink: '#1F2937',
  text: '#1F2937',
  textMuted: '#6B7280',
} as const;

// Timetable slot accent — four soft tints for visual variety in schedule.
export const SLOT_BG: Record<SlotAccent, string> = {
  red: 'bg-slot-red',
  blue: 'bg-slot-blue',
  green: 'bg-slot-green',
  yellow: 'bg-slot-yellow',
};

export const SLOT_FG: Record<SlotAccent, string> = {
  red: 'text-slot-red-fg',
  blue: 'text-slot-blue-fg',
  green: 'text-slot-green-fg',
  yellow: 'text-slot-yellow-fg',
};

export type SlotAccent = 'red' | 'blue' | 'green' | 'yellow';

// Legacy alias kept so AppContext compiles without change.
export type PopAccent = SlotAccent;
export const POP_BG = SLOT_BG;

export type AccentColor =
  | 'action'
  | 'brand'
  | 'verify'
  | 'alert'
  | 'info'
  | 'success';

// ─── Data interfaces ────────────────────────────────────────────────────────

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
