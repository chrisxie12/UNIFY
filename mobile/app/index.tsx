import { FlatList, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBBadge, NBButton, NBPressCard } from '../components/NB';
import type { Thread } from '../theme/tokens';

const THREADS: readonly Thread[] = [
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

interface ThreadCardProps {
  thread: Thread;
  onPress: () => void;
}

function ThreadCard({ thread, onPress }: ThreadCardProps) {
  return (
    <NBPressCard onPress={onPress} className="mb-4 p-3.5">
      <View className="flex-row items-center gap-2 mb-2">
        <NBBadge label={thread.hub} accent="brand" />
        {thread.verified && <NBBadge label="✓ Verified" accent="verify" />}
        <Text className="ml-auto text-[11px] font-body-medium text-[#555]">
          {thread.time}
        </Text>
      </View>
      <Text className="text-[15px] leading-[21px] font-body-bold text-black mb-2.5">
        {thread.title}
      </Text>
      <View className="flex-row items-center gap-3">
        <Text className="text-xs font-body-medium text-[#555]">
          @{thread.author} · {thread.level}
        </Text>
        <Text className="ml-auto text-xs font-body-bold text-black">
          ▲ {thread.upvotes}
        </Text>
        <Text className="text-xs font-body-bold text-black">
          💬 {thread.comments}
        </Text>
      </View>
    </NBPressCard>
  );
}

export default function HubsScreen() {
  const router = useRouter();
  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <View className="flex-row items-center px-4 pt-2 pb-3">
        <Text className="font-display text-[26px] text-black uppercase tracking-tight">
          Campus Hubs
        </Text>
        <NBBadge label="3" accent="alert" className="ml-auto" />
      </View>

      <FlatList
        data={THREADS}
        keyExtractor={(t: Thread) => t.id}
        contentContainerClassName="px-4 pb-24"
        renderItem={({ item }: { item: Thread }) => (
          <ThreadCard
            thread={item}
            onPress={() => router.push(`/thread/${item.id}`)}
          />
        )}
      />

      <View className="absolute bottom-20 right-4">
        <NBButton label="Post Thread" onPress={() => undefined} />
      </View>
    </SafeAreaView>
  );
}
