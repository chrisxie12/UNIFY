import { useState } from 'react';
import { View, Text, ScrollView, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBCard, NBBadge, NBInput, NBButton } from '../../components/NB';
import { COLORS } from '../../theme/tokens';

const COMMENTS = [
  {
    id: 'k1', author: 'ama.serwaa', level: 'Level 200', verified: true, upvotes: 34, depth: 0,
    text: 'Unity Hall is the closest, about 5 min walk. Brunei is 12-15 min but the rooms are better maintained.',
  },
  {
    id: 'k2', author: 'kwame_eng', level: 'Level 100', verified: true, upvotes: 12, depth: 1,
    text: 'This. And Unity gets loud during hall week — factor that in if you study in your room.',
  },
  {
    id: 'k3', author: 'efua_b', level: 'Level 100', verified: false, upvotes: 8, depth: 0,
    text: 'Nobody mentions the shuttle. If you are in Brunei the 7:20am shuttle gets you to CoE before first lecture.',
  },
];

function Comment({ c }) {
  return (
    <View style={{ marginLeft: c.depth * 18, marginBottom: 12 }}>
      <NBCard offset={2} contentStyle={{ padding: 12 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 6 }}>
          <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 12, color: COLORS.text }}>@{c.author}</Text>
          <NBBadge label={c.level} bg={COLORS.action} />
          {c.verified && <NBBadge label="✓" />}
        </View>
        <Text style={{ fontFamily: 'Inter_400Regular', fontSize: 13.5, lineHeight: 20, color: COLORS.text, marginBottom: 8 }}>
          {c.text}
        </Text>
        <View style={{ flexDirection: 'row', gap: 14 }}>
          <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 12, color: COLORS.text }}>▲ {c.upvotes}</Text>
          <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 12, color: COLORS.textMuted }}>Reply</Text>
        </View>
      </NBCard>
    </View>
  );
}

export default function ThreadDetail() {
  const router = useRouter();
  const [reply, setReply] = useState('');

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.parchment }} edges={['top']}>
      <View
        style={{
          flexDirection: 'row', alignItems: 'center', gap: 12,
          paddingHorizontal: 16, paddingVertical: 10,
          borderBottomWidth: 2, borderBottomColor: COLORS.ink,
        }}
      >
        <Pressable onPress={() => router.back()}>
          <Text style={{ fontFamily: 'SpaceGrotesk_700Bold', fontSize: 18, color: COLORS.text }}>←</Text>
        </Pressable>
        <NBBadge label="KNUST" bg={COLORS.brand} color={COLORS.white} />
        <Text style={{ fontFamily: 'Inter_500Medium', fontSize: 12, color: COLORS.textMuted }}>Hub Thread</Text>
      </View>

      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 32 }}>
        {/* Original post */}
        <NBCard style={{ marginBottom: 20 }} contentStyle={{ padding: 16 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 12, color: COLORS.text }}>@kwame_eng</Text>
            <NBBadge label="Level 100" bg={COLORS.action} />
            <NBBadge label="✓ Verified Student" />
          </View>
          <Text style={{ fontFamily: 'SpaceGrotesk_700Bold', fontSize: 18, lineHeight: 24, color: COLORS.text, marginBottom: 10 }}>
            Which hall is actually closest to the College of Engineering?
          </Text>
          <Text style={{ fontFamily: 'Inter_400Regular', fontSize: 14, lineHeight: 21, color: COLORS.text, marginBottom: 12 }}>
            Admission letter came through 🎉 Trying to pick a hall before orientation. Google Maps
            says one thing, seniors say another. Anyone in CoE who can settle this?
          </Text>
          <View style={{ flexDirection: 'row', gap: 16 }}>
            <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 13, color: COLORS.text }}>▲ 128</Text>
            <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 13, color: COLORS.text }}>💬 43</Text>
          </View>
        </NBCard>

        <Text style={{ fontFamily: 'SpaceGrotesk_700Bold', fontSize: 14, color: COLORS.text, marginBottom: 12, textTransform: 'uppercase', letterSpacing: 0.5 }}>
          43 Comments
        </Text>
        {COMMENTS.map((c) => <Comment key={c.id} c={c} />)}

        <View style={{ marginTop: 12, gap: 12 }}>
          <NBInput placeholder="Add a comment…" value={reply} onChangeText={setReply} multiline />
          <NBButton label="Post Comment" onPress={() => setReply('')} />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
