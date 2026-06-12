import { View, Text, FlatList, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBCard, NBButton, NBBadge } from '../components/NB';
import { COLORS } from '../theme/tokens';

const THREADS = [
  {
    id: 't1',
    hub: 'KNUST',
    title: 'Which hall is actually closest to the College of Engineering?',
    author: 'kwame_eng',
    level: 'Level 100',
    verified: true,
    upvotes: 128,
    comments: 43,
    time: '2h',
  },
  {
    id: 't2',
    hub: 'UG Legon',
    title: 'Roommate red flags to watch for during orientation week 🚩',
    author: 'ama.serwaa',
    level: 'Level 200',
    verified: true,
    upvotes: 96,
    comments: 31,
    time: '4h',
  },
  {
    id: 't3',
    hub: 'UCC',
    title: 'Evandy vs Brunei: honest hostel review after one semester',
    author: 'efua_b',
    level: 'Level 100',
    verified: false,
    upvotes: 74,
    comments: 22,
    time: '6h',
  },
  {
    id: 't4',
    hub: 'UPSA',
    title: 'Study group for Business Math — 12 spots left',
    author: 'yaw.mensah',
    level: 'Level 100',
    verified: true,
    upvotes: 51,
    comments: 9,
    time: '9h',
  },
];

function ThreadCard({ thread, onPress }) {
  return (
    <Pressable onPress={onPress}>
      <NBCard style={{ marginBottom: 16 }} contentStyle={{ padding: 14 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <NBBadge label={thread.hub} bg={COLORS.brand} color={COLORS.white} />
          {thread.verified && <NBBadge label="✓ Verified Student" />}
          <Text style={{ marginLeft: 'auto', fontSize: 11, color: COLORS.textMuted, fontFamily: 'Inter_500Medium' }}>
            {thread.time}
          </Text>
        </View>
        <Text style={{ fontSize: 15, lineHeight: 21, color: COLORS.text, fontFamily: 'Inter_700Bold', marginBottom: 10 }}>
          {thread.title}
        </Text>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
          <Text style={{ fontSize: 12, color: COLORS.textMuted, fontFamily: 'Inter_500Medium' }}>
            @{thread.author} · {thread.level}
          </Text>
          <Text style={{ marginLeft: 'auto', fontSize: 12, color: COLORS.text, fontFamily: 'Inter_700Bold' }}>
            ▲ {thread.upvotes}
          </Text>
          <Text style={{ fontSize: 12, color: COLORS.text, fontFamily: 'Inter_700Bold' }}>
            💬 {thread.comments}
          </Text>
        </View>
      </NBCard>
    </Pressable>
  );
}

export default function HubsScreen() {
  const router = useRouter();
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.parchment }} edges={['top']}>
      <View style={{ paddingHorizontal: 16, paddingTop: 8, paddingBottom: 12, flexDirection: 'row', alignItems: 'center' }}>
        <Text style={{ fontFamily: 'ArchivoBlack', fontSize: 26, color: COLORS.text, letterSpacing: -1 }}>
          CAMPUS HUBS
        </Text>
        <View style={{ marginLeft: 'auto' }}>
          <NBBadge label="3" bg={COLORS.alert} color={COLORS.white} />
        </View>
      </View>

      <FlatList
        data={THREADS}
        keyExtractor={(t) => t.id}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 96 }}
        renderItem={({ item }) => (
          <ThreadCard thread={item} onPress={() => router.push(`/thread/${item.id}`)} />
        )}
      />

      <View style={{ position: 'absolute', bottom: 80, right: 16 }}>
        <NBButton label="Post Thread" onPress={() => {}} />
      </View>
    </SafeAreaView>
  );
}
