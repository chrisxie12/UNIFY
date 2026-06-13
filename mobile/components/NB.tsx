// Clean Bold component library.
// White surfaces · soft shadows · charcoal text · pill buttons
// Blue (#0066FF) active/send only · Orange (#FF6B35) notifications only.

import { Pressable, Text, TextInput, View } from 'react-native';
import type { ReactNode } from 'react';
import { COLORS } from '../theme/tokens';

const PRESS = 'active:opacity-75';

// ─── Card ────────────────────────────────────────────────────────────────────

interface NBCardProps {
  children: ReactNode;
  className?: string;
}

export function NBCard({ children, className = '' }: NBCardProps) {
  return (
    <View className={`bg-white rounded-2xl shadow-card ${className}`}>
      {children}
    </View>
  );
}

interface NBPressCardProps extends NBCardProps {
  onPress: () => void;
}

export function NBPressCard({
  children,
  onPress,
  className = '',
}: NBPressCardProps) {
  return (
    <Pressable
      onPress={onPress}
      className={`bg-white rounded-2xl shadow-card ${PRESS} ${className}`}
    >
      {children}
    </Pressable>
  );
}

// ─── Button ──────────────────────────────────────────────────────────────────

type ButtonVariant = 'primary' | 'accent' | 'ghost';

interface NBButtonProps {
  label: string;
  onPress: () => void;
  variant?: ButtonVariant;
  size?: 'sm' | 'md';
  className?: string;
}

const BUTTON_BG: Record<ButtonVariant, string> = {
  primary: 'bg-charcoal',
  accent: 'bg-accent',
  ghost: 'bg-white border border-divider',
};

const BUTTON_TEXT: Record<ButtonVariant, string> = {
  primary: 'text-white',
  accent: 'text-white',
  ghost: 'text-charcoal',
};

export function NBButton({
  label,
  onPress,
  variant = 'primary',
  size = 'md',
  className = '',
}: NBButtonProps) {
  const pad = size === 'sm' ? 'px-5 py-2' : 'px-7 py-3.5';
  const textSize = size === 'sm' ? 'text-xs' : 'text-sm';
  return (
    <Pressable
      onPress={onPress}
      className={`${BUTTON_BG[variant]} rounded-full items-center justify-center ${pad} ${PRESS} ${className}`}
    >
      <Text className={`${BUTTON_TEXT[variant]} ${textSize} font-heading`}>
        {label}
      </Text>
    </Pressable>
  );
}

// ─── Badge ───────────────────────────────────────────────────────────────────

type BadgeStyle = 'default' | 'accent' | 'notif' | 'muted' | 'success';

interface NBBadgeProps {
  label: string;
  style?: BadgeStyle;
  // legacy accent prop kept for backward-compat — mapped to style
  accent?: string;
  className?: string;
}

const BADGE_BG: Record<BadgeStyle, string> = {
  default: 'bg-surface',
  accent: 'bg-accent',
  notif: 'bg-notif',
  muted: 'bg-surface',
  success: 'bg-[#D1FAE5]',
};

const BADGE_TEXT: Record<BadgeStyle, string> = {
  default: 'text-charcoal',
  accent: 'text-white',
  notif: 'text-white',
  muted: 'text-muted',
  success: 'text-[#047857]',
};

// Map legacy AccentColor values to the new BadgeStyle so callers that pass
// accent="verify" / "action" / "alert" / "brand" don't break at runtime.
function resolveStyle(accent: string | undefined, style: BadgeStyle): BadgeStyle {
  if (accent === 'verify' || accent === 'success') return 'success';
  if (accent === 'alert' || accent === 'brand') return 'notif';
  if (accent === 'action' || accent === 'info') return 'accent';
  return style;
}

export function NBBadge({
  label,
  style = 'default',
  accent,
  className = '',
}: NBBadgeProps) {
  const resolved = resolveStyle(accent, style);
  return (
    <View
      className={`${BADGE_BG[resolved]} rounded-full px-2.5 py-0.5 ${className}`}
    >
      <Text className={`${BADGE_TEXT[resolved]} text-[10px] font-body-bold`}>
        {label}
      </Text>
    </View>
  );
}

// Pop badge kept as alias — same pill style, uses the badgeStyle system.
interface NBPopBadgeProps {
  label: string;
  accent?: string;
  className?: string;
}

export function NBPopBadge({
  label,
  accent = 'blue',
  className = '',
}: NBPopBadgeProps) {
  // Map slot accent names to badge styles
  const style: BadgeStyle =
    accent === 'red'
      ? 'notif'
      : accent === 'blue'
      ? 'accent'
      : accent === 'green'
      ? 'success'
      : 'default';
  return (
    <View className={`${BADGE_BG[style]} rounded-full px-2.5 py-0.5 ${className}`}>
      <Text className={`${BADGE_TEXT[style]} text-[10px] font-body-bold`}>
        {label}
      </Text>
    </View>
  );
}

// ─── Input ───────────────────────────────────────────────────────────────────

interface NBInputProps {
  placeholder: string;
  value?: string;
  onChangeText?: (text: string) => void;
  multiline?: boolean;
  className?: string;
}

export function NBInput({
  placeholder,
  value,
  onChangeText,
  multiline = false,
  className = '',
}: NBInputProps) {
  return (
    <TextInput
      placeholder={placeholder}
      placeholderTextColor={COLORS.subtle}
      value={value}
      onChangeText={onChangeText}
      multiline={multiline}
      textAlignVertical={multiline ? 'top' : 'center'}
      className={`bg-surface rounded-xl px-4 py-3 text-sm font-body text-charcoal ${
        multiline ? 'min-h-[80px]' : ''
      } ${className}`}
    />
  );
}

// ─── Avatar ──────────────────────────────────────────────────────────────────

interface NBAvatarProps {
  initials: string;
  accent?: string;
  size?: 'sm' | 'md' | 'lg';
}

// Accent → background color (soft tint rings instead of full-saturated fills).
const AVATAR_BG: Record<string, string> = {
  brand: 'bg-[#FFE8DF]',
  info: 'bg-[#DBEAFE]',
  success: 'bg-[#D1FAE5]',
  alert: 'bg-[#FEE2E2]',
  action: 'bg-[#FEF3C7]',
  verify: 'bg-[#D1FAE5]',
};

const AVATAR_TEXT: Record<string, string> = {
  brand: 'text-notif',
  info: 'text-accent',
  success: 'text-[#047857]',
  alert: 'text-[#B91C1C]',
  action: 'text-[#B45309]',
  verify: 'text-[#047857]',
};

export function NBAvatar({
  initials,
  accent = 'brand',
  size = 'md',
}: NBAvatarProps) {
  const dims =
    size === 'sm' ? 'w-8 h-8' : size === 'lg' ? 'w-[72px] h-[72px]' : 'w-11 h-11';
  const textSize =
    size === 'sm' ? 'text-[10px]' : size === 'lg' ? 'text-2xl' : 'text-xs';
  const bg = AVATAR_BG[accent] ?? 'bg-surface';
  const fg = AVATAR_TEXT[accent] ?? 'text-charcoal';
  return (
    <View
      className={`${bg} ${dims} rounded-full items-center justify-center`}
    >
      <Text className={`${fg} ${textSize} font-heading`}>{initials}</Text>
    </View>
  );
}
