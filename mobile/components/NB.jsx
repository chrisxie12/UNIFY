import { useState } from 'react';
import { View, Pressable, Text, TextInput } from 'react-native';
import { COLORS, SHADOW, BORDER, RADIUS } from '../theme/tokens';

// RN shadows blur on Android (elevation) and iOS (shadowRadius), so hard
// 0-blur offsets are built by stacking: a black backing view sits at the
// final position and the face is translated up-left by the offset. Pressing
// translates the face back to (0,0) — a physical depression, for free.

export function NBShadowBox({
  offset = SHADOW.standard,
  radius = RADIUS.none,
  backing = COLORS.ink,
  style,
  children,
}) {
  return (
    <View style={[{ backgroundColor: backing, borderRadius: radius }, style]}>
      <View
        style={{
          transform: [{ translateX: -offset }, { translateY: -offset }],
          borderRadius: radius,
        }}
      >
        {children}
      </View>
    </View>
  );
}

export function NBCard({
  offset = SHADOW.standard,
  radius = RADIUS.none,
  bg = COLORS.white,
  style,
  contentStyle,
  children,
}) {
  return (
    <NBShadowBox offset={offset} radius={radius} style={style}>
      <View
        style={[
          {
            backgroundColor: bg,
            borderWidth: BORDER.width,
            borderColor: BORDER.color,
            borderRadius: radius,
          },
          contentStyle,
        ]}
      >
        {children}
      </View>
    </NBShadowBox>
  );
}

export function NBButton({
  label,
  onPress,
  bg = COLORS.action,
  color = COLORS.text,
  offset = SHADOW.standard,
  radius = RADIUS.none,
  size = 'md',
  style,
  icon = null,
}) {
  const [pressed, setPressed] = useState(false);
  const pad = size === 'sm' ? { paddingVertical: 8, paddingHorizontal: 14 } : { paddingVertical: 14, paddingHorizontal: 22 };
  const fontSize = size === 'sm' ? 13 : 15;
  return (
    <View style={[{ backgroundColor: COLORS.ink, borderRadius: radius }, style]}>
      <Pressable
        onPress={onPress}
        onPressIn={() => setPressed(true)}
        onPressOut={() => setPressed(false)}
        style={{
          backgroundColor: bg,
          borderWidth: BORDER.width,
          borderColor: BORDER.color,
          borderRadius: radius,
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 8,
          ...pad,
          // Depressed: sit flush on the backing (shadow gone). Raised: offset up-left.
          transform: pressed
            ? [{ translateX: 0 }, { translateY: 0 }]
            : [{ translateX: -offset }, { translateY: -offset }],
        }}
      >
        {icon}
        <Text style={{ color, fontSize, fontFamily: 'SpaceGrotesk_700Bold' }}>{label}</Text>
      </Pressable>
    </View>
  );
}

export function NBBadge({ label, bg = COLORS.verify, color = COLORS.text, style }) {
  return (
    <NBShadowBox offset={SHADOW.micro} style={style}>
      <View
        style={{
          backgroundColor: bg,
          borderWidth: 1.5,
          borderColor: BORDER.color,
          paddingVertical: 2,
          paddingHorizontal: 8,
        }}
      >
        <Text style={{ color, fontSize: 10, fontFamily: 'Inter_700Bold', letterSpacing: 0.3 }}>
          {label}
        </Text>
      </View>
    </NBShadowBox>
  );
}

export function NBInput({ placeholder, value, onChangeText, multiline = false, style }) {
  const [focused, setFocused] = useState(false);
  return (
    <NBShadowBox offset={focused ? SHADOW.standard : SHADOW.micro} style={style}>
      <TextInput
        placeholder={placeholder}
        placeholderTextColor="#999999"
        value={value}
        onChangeText={onChangeText}
        multiline={multiline}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        style={{
          backgroundColor: focused ? '#FFFCE0' : COLORS.white,
          borderWidth: BORDER.width,
          borderColor: BORDER.color,
          paddingVertical: 12,
          paddingHorizontal: 14,
          fontSize: 14,
          fontFamily: 'Inter_400Regular',
          color: COLORS.text,
          minHeight: multiline ? 80 : undefined,
          textAlignVertical: multiline ? 'top' : 'center',
        }}
      />
    </NBShadowBox>
  );
}
