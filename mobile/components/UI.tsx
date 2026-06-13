import { Pressable, Text, TextInput, View } from 'react-native';
import type { ReactNode } from 'react';
import { COLORS } from '../theme/tokens';

const PRESS = 'active:opacity-70';

// ─── Card ────────────────────────────────────────────────────────────────────

interface CardProps { children: ReactNode; className?: string }

export function Card({ children, className = '' }: CardProps) {
  return (
    <View className={`bg-white rounded-2xl shadow-card ${className}`}>
      {children}
    </View>
  );
}

export function PressCard({
  children, onPress, className = '',
}: CardProps & { onPress: () => void }) {
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

type BtnVariant = 'primary' | 'blue' | 'ghost' | 'outline';

const BTN_BG: Record<BtnVariant, string> = {
  primary: 'bg-btn-primary',
  blue:    'bg-blue',
  ghost:   'bg-surface',
  outline: 'bg-white border border-border',
};
const BTN_TEXT: Record<BtnVariant, string> = {
  primary: 'text-white',
  blue:    'text-white',
  ghost:   'text-primary',
  outline: 'text-primary',
};

interface BtnProps {
  label: string;
  onPress: () => void;
  variant?: BtnVariant;
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  className?: string;
}

export function Btn({
  label, onPress, variant = 'primary', size = 'md', disabled = false, className = '',
}: BtnProps) {
  const pad = size === 'sm' ? 'px-5 py-2.5' : size === 'lg' ? 'px-8 py-4' : 'px-6 py-3.5';
  const txt = size === 'sm' ? 'text-xs' : size === 'lg' ? 'text-base' : 'text-sm';
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      className={`${BTN_BG[variant]} rounded-full items-center justify-center ${pad} ${PRESS} ${disabled ? 'opacity-40' : ''} ${className}`}
    >
      <Text className={`${BTN_TEXT[variant]} ${txt} font-body-semi`}>{label}</Text>
    </Pressable>
  );
}

// ─── Input ───────────────────────────────────────────────────────────────────

interface InputProps {
  placeholder: string;
  value?: string;
  onChangeText?: (t: string) => void;
  multiline?: boolean;
  keyboardType?: 'default' | 'numeric' | 'phone-pad' | 'email-address';
  secureTextEntry?: boolean;
  autoFocus?: boolean;
  maxLength?: number;
  className?: string;
}

export function Input({
  placeholder, value, onChangeText, multiline = false,
  keyboardType = 'default', secureTextEntry, autoFocus, maxLength, className = '',
}: InputProps) {
  return (
    <TextInput
      placeholder={placeholder}
      placeholderTextColor={COLORS.tertxt}
      value={value}
      onChangeText={onChangeText}
      multiline={multiline}
      keyboardType={keyboardType}
      secureTextEntry={secureTextEntry}
      autoFocus={autoFocus}
      maxLength={maxLength}
      textAlignVertical={multiline ? 'top' : 'center'}
      className={`bg-surface rounded-2xl px-5 py-3.5 text-sm font-body text-primary border border-border ${
        multiline ? 'min-h-[90px]' : 'h-14'
      } ${className}`}
    />
  );
}

// ─── Avatar ──────────────────────────────────────────────────────────────────

const AVATAR_BG: Record<string, string> = {
  blue:    'bg-[#DBEAFE]',
  orange:  'bg-[#FFE8DF]',
  green:   'bg-[#D1FAE5]',
  red:     'bg-[#FEE2E2]',
  purple:  'bg-[#EDE9FE]',
  default: 'bg-surface',
};
const AVATAR_FG: Record<string, string> = {
  blue:    'text-blue',
  orange:  'text-orange',
  green:   'text-green',
  red:     'text-red',
  purple:  'text-[#7C3AED]',
  default: 'text-primary',
};

interface AvatarProps {
  initials: string;
  color?: string;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

export function Avatar({ initials, color = 'blue', size = 'md', className = '' }: AvatarProps) {
  const dims =
    size === 'xs' ? 'w-7 h-7'  :
    size === 'sm' ? 'w-9 h-9'  :
    size === 'lg' ? 'w-16 h-16':
    size === 'xl' ? 'w-20 h-20':
    'w-12 h-12';
  const txtSize =
    size === 'xs' ? 'text-[9px]'  :
    size === 'sm' ? 'text-[11px]' :
    size === 'lg' ? 'text-xl'     :
    size === 'xl' ? 'text-2xl'    :
    'text-sm';
  const bg = AVATAR_BG[color] ?? AVATAR_BG.default;
  const fg = AVATAR_FG[color] ?? AVATAR_FG.default;
  return (
    <View className={`${bg} ${dims} rounded-full items-center justify-center ${className}`}>
      <Text className={`${fg} ${txtSize} font-heading`}>{initials}</Text>
    </View>
  );
}

// ─── Badge ───────────────────────────────────────────────────────────────────

interface BadgeProps {
  label: string;
  color?: 'blue' | 'orange' | 'green' | 'red' | 'default';
  className?: string;
}

const BADGE_BG: Record<string, string> = {
  blue:    'bg-[#EFF6FF]',
  orange:  'bg-[#FFF4EE]',
  green:   'bg-[#ECFDF5]',
  red:     'bg-[#FEF2F2]',
  default: 'bg-surface',
};
const BADGE_FG: Record<string, string> = {
  blue:    'text-blue',
  orange:  'text-orange',
  green:   'text-green',
  red:     'text-red',
  default: 'text-secondary',
};

export function Badge({ label, color = 'default', className = '' }: BadgeProps) {
  return (
    <View className={`${BADGE_BG[color]} rounded-full px-3 py-1 ${className}`}>
      <Text className={`${BADGE_FG[color]} text-[11px] font-body-semi`}>{label}</Text>
    </View>
  );
}

// ─── Chip (selectable pill) ──────────────────────────────────────────────────

interface ChipProps {
  label: string;
  selected: boolean;
  onPress: () => void;
}

export function Chip({ label, selected, onPress }: ChipProps) {
  return (
    <Pressable
      onPress={onPress}
      className={`rounded-full px-4 py-2 border ${
        selected ? 'bg-blue border-blue' : 'bg-white border-border'
      } ${PRESS}`}
    >
      <Text className={`text-xs font-body-semi ${selected ? 'text-white' : 'text-secondary'}`}>
        {label}
      </Text>
    </Pressable>
  );
}

// ─── Divider ─────────────────────────────────────────────────────────────────

export function Divider({ className = '' }: { className?: string }) {
  return <View className={`h-px bg-border ${className}`} />;
}

// ─── Section header ──────────────────────────────────────────────────────────

export function SectionHeader({ title, action, onAction }: {
  title: string; action?: string; onAction?: () => void
}) {
  return (
    <View className="flex-row items-center justify-between mb-3">
      <Text className="font-heading text-base text-primary">{title}</Text>
      {action && (
        <Pressable onPress={onAction} className={PRESS}>
          <Text className="text-xs font-body-semi text-blue">{action}</Text>
        </Pressable>
      )}
    </View>
  );
}
