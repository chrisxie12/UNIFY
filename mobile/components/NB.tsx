import { Pressable, Text, TextInput, View } from 'react-native';
import type { ReactNode } from 'react';
import { COLORS, POP_BG, type AccentColor, type PopAccent } from '../theme/tokens';

// Hard 0-blur shadows (shadow-nb / shadow-nb-sm / shadow-nb-lg) require the
// RN new-architecture boxShadow style (RN 0.76+), which NativeWind compiles
// these utilities down to. The press interaction is purely class-driven:
// active: shifts the element INTO its shadow footprint and drops the shadow,
// simulating a physical block being pressed down.

const PRESS_DEPRESSION =
  'active:translate-x-[4px] active:translate-y-[4px] active:shadow-none';
const PRESS_DEPRESSION_SM =
  'active:translate-x-[2px] active:translate-y-[2px] active:shadow-none';

const ACCENT_BG: Record<AccentColor, string> = {
  action: 'bg-action',
  brand: 'bg-brand',
  verify: 'bg-verify',
  alert: 'bg-alert',
  info: 'bg-info',
  success: 'bg-[#16a34a]',
};

// Black text on neon surfaces, white on the saturated darks — readability first.
const ACCENT_TEXT: Record<AccentColor, string> = {
  action: 'text-black',
  brand: 'text-black',
  verify: 'text-black',
  alert: 'text-white',
  info: 'text-white',
  success: 'text-white',
};

interface NBCardProps {
  children: ReactNode;
  className?: string;
}

export function NBCard({ children, className = '' }: NBCardProps) {
  return (
    <View
      className={`bg-white border-4 border-black rounded-none shadow-nb ${className}`}
    >
      {children}
    </View>
  );
}

interface NBPressCardProps extends NBCardProps {
  onPress: () => void;
}

export function NBPressCard({ children, onPress, className = '' }: NBPressCardProps) {
  return (
    <Pressable
      onPress={onPress}
      className={`bg-white border-4 border-black rounded-none shadow-nb ${PRESS_DEPRESSION} ${className}`}
    >
      {children}
    </Pressable>
  );
}

interface NBButtonProps {
  label: string;
  onPress: () => void;
  accent?: AccentColor;
  size?: 'sm' | 'md';
  className?: string;
}

export function NBButton({
  label,
  onPress,
  accent = 'action',
  size = 'md',
  className = '',
}: NBButtonProps) {
  const pad = size === 'sm' ? 'px-4 py-2' : 'px-6 py-3.5';
  const text = size === 'sm' ? 'text-xs' : 'text-sm';
  return (
    <Pressable
      onPress={onPress}
      className={`${ACCENT_BG[accent]} border-4 border-black rounded-none shadow-nb items-center justify-center ${pad} ${PRESS_DEPRESSION} ${className}`}
    >
      <Text
        className={`${ACCENT_TEXT[accent]} ${text} font-heading uppercase tracking-tight`}
      >
        {label}
      </Text>
    </Pressable>
  );
}

interface NBBadgeProps {
  label: string;
  accent?: AccentColor;
  className?: string;
}

export function NBBadge({ label, accent = 'verify', className = '' }: NBBadgeProps) {
  return (
    <View
      className={`${ACCENT_BG[accent]} border-2 border-black rounded-none shadow-nb-sm px-2 py-0.5 ${className}`}
    >
      <Text
        className={`${ACCENT_TEXT[accent]} text-[10px] font-body-bold uppercase tracking-wide`}
      >
        {label}
      </Text>
    </View>
  );
}

interface NBPopBadgeProps {
  label: string;
  accent?: PopAccent;
  className?: string;
}

// Badge in the pop palette (red/blue/green/yellow) — all four surfaces
// are light, so the text is always black.
export function NBPopBadge({
  label,
  accent = 'yellow',
  className = '',
}: NBPopBadgeProps) {
  return (
    <View
      className={`${POP_BG[accent]} border-2 border-black rounded-none shadow-nb-sm px-2 py-0.5 ${className}`}
    >
      <Text className="text-black text-[10px] font-body-bold uppercase tracking-wide">
        {label}
      </Text>
    </View>
  );
}

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
      placeholderTextColor={COLORS.textMuted}
      value={value}
      onChangeText={onChangeText}
      multiline={multiline}
      textAlignVertical={multiline ? 'top' : 'center'}
      className={`bg-white border-4 border-black rounded-none shadow-nb-sm px-3.5 py-3 text-sm font-body text-black focus:bg-action/20 focus:shadow-nb ${multiline ? 'min-h-[80px]' : ''} ${className}`}
    />
  );
}

interface NBAvatarProps {
  initials: string;
  accent?: AccentColor;
  size?: 'sm' | 'md' | 'lg';
}

export function NBAvatar({ initials, accent = 'brand', size = 'md' }: NBAvatarProps) {
  const dims = size === 'sm' ? 'w-7 h-7' : size === 'lg' ? 'w-[72px] h-[72px]' : 'w-11 h-11';
  const text = size === 'sm' ? 'text-[9px]' : size === 'lg' ? 'text-2xl' : 'text-xs';
  return (
    <View
      className={`${ACCENT_BG[accent]} ${dims} border-2 border-black rounded-none items-center justify-center`}
    >
      <Text className={`${ACCENT_TEXT[accent]} ${text} font-heading uppercase`}>
        {initials}
      </Text>
    </View>
  );
}
