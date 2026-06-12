import { useState } from 'react';
import { View, Text, FlatList, KeyboardAvoidingView, Platform, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { NBBadge, NBInput, NBButton } from '../../components/NB';
import { COLORS } from '../../theme/tokens';

const MESSAGES = [
  { id: 'm1', mine: false, text: 'Hey! We matched 92% 🔥 Are you early bird or night owl fr?', time: '10:02' },
  { id: 'm2', mine: true, text: 'Night owl 100%. You saw my quiz answers 😄', time: '10:04' },
  { id: 'm3', mine: false, text: 'Same! Which hostel are you looking at? I keep my side clean, promise 😂', time: '10:05' },
  { id: 'm4', mine: true, text: 'Evandy or Brunei. There is a thread in the KNUST hub comparing them', time: '10:07' },
];

// Chat bubbles live in the 90% reading zone: white/parchment surfaces,
// black borders, micro shadows — no neon fills behind body text.
function Bubble({ msg }) {
  return (
    <View
      style={{
        alignSelf: msg.mine ? 'flex-end' : 'flex-start',
        maxWidth: '80%',
        marginBottom: 12,
      }}
    >
      <View style={{ backgroundColor: COLORS.ink }}>
        <View
          style={{
            backgroundColor: msg.mine ? '#FFF4EC' : COLORS.white,
            borderWidth: 2,
            borderColor: COLORS.ink,
            paddingVertical: 9,
            paddingHorizontal: 12,
            transform: [{ translateX: -2 }, { translateY: -2 }],
          }}
        >
          <Text style={{ fontFamily: 'Inter_400Regular', fontSize: 14, lineHeight: 20, color: COLORS.text }}>
            {msg.text}
          </Text>
        </View>
      </View>
      <Text
        style={{
          fontFamily: 'Inter_500Medium',
          fontSize: 9,
          color: COLORS.textMuted,
          marginTop: 3,
          alignSelf: msg.mine ? 'flex-end' : 'flex-start',
        }}
      >
        {msg.time}
      </Text>
    </View>
  );
}

export default function ChatThread() {
  const { id } = useLocalSearchParams();
  const router = useRouter();
  const [draft, setDraft] = useState('');

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.parchment }} edges={['top']}>
      {/* Header */}
      <View
        style={{
          flexDirection: 'row', alignItems: 'center', gap: 12,
          paddingHorizontal: 16, paddingVertical: 10,
          borderBottomWidth: 2, borderBottomColor: COLORS.ink,
          backgroundColor: COLORS.parchment,
        }}
      >
        <Pressable onPress={() => router.back()}>
          <Text style={{ fontFamily: 'SpaceGrotesk_700Bold', fontSize: 18, color: COLORS.text }}>←</Text>
        </Pressable>
        <View
          style={{
            width: 36, height: 36, backgroundColor: COLORS.brand,
            borderWidth: 2, borderColor: COLORS.ink,
            alignItems: 'center', justifyContent: 'center',
          }}
        >
          <Text style={{ color: COLORS.white, fontFamily: 'SpaceGrotesk_700Bold', fontSize: 11 }}>SA</Text>
        </View>
        <View>
          <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 14, color: COLORS.text }}>Sarah</Text>
          <Text style={{ fontFamily: 'Inter_500Medium', fontSize: 10, color: COLORS.textMuted }}>UG Legon</Text>
        </View>
        <View style={{ marginLeft: 'auto' }}>
          <NBBadge label="92% Match" bg={COLORS.action} />
        </View>
      </View>

      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <FlatList
          data={MESSAGES}
          keyExtractor={(m) => m.id}
          contentContainerStyle={{ padding: 16 }}
          renderItem={({ item }) => <Bubble msg={item} />}
        />

        {/* Composer */}
        <View
          style={{
            flexDirection: 'row', alignItems: 'center', gap: 10,
            paddingHorizontal: 16, paddingVertical: 12,
            borderTopWidth: 2, borderTopColor: COLORS.ink,
          }}
        >
          <View style={{ flex: 1 }}>
            <NBInput placeholder="Message…" value={draft} onChangeText={setDraft} />
          </View>
          <NBButton label="Send" size="sm" onPress={() => setDraft('')} />
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
