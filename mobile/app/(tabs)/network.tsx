import { FlatList, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBBadge, NBButton, NBPressCard } from '../../components/NB';
import type { Thread } from '../../theme/tokens';

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
    <NBPressCard onPress={onPress} className="mb-3 p-4">
      <View className="flex-row items-center gap-2 mb-2.5">
        <View className="bg-[#EFF6FF] rounded-full px-2.5 py-0.5">
          <Text className="text-accent text-[10px] font-body-bold">
            {thread.hub}
          </Text>
        </View>
        {thread.verified && (
          <View className="bg-[#D1FAE5] rounded-full px-2.5 py-0.5">
            <Text className="text-[#047857] text-[10px] font-body-bold">
              ✓ Verified
            </Text>
          </View>
        )}
        <Text className="ml-auto text-[11px] font-body-medium text-muted">
          {thread.time}
        </Text>
      </View>
      <Text className="text-[15px] leading-[22px] font-body-bold text-charcoal mb-2.5">
        {thread.title}
      </Text>
      <View className="flex-row items-center gap-3">
        <Text className="text-xs font-body-medium text-muted">
          @{thread.author} · {thread.level}
        </Text>
        <Text className="ml-auto text-xs font-body-bold text-muted">
          ▲ {thread.upvotes}
        </Text>
        <Text className="text-xs font-body-bold text-muted">
          💬 {thread.comments}
        </Text>
      </View>
    </NBPressCard>
  );
}

export default function NetworkScreen() {
  const router = useRouter();
  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="flex-row items-end px-5 pt-5 pb-4">
        <View className="flex-1">
          <Text className="font-display text-[13px] text-notif uppercase tracking-widest mb-0.5">
            UNIFY
          </Text>
          <Text className="font-heading text-2xl text-charcoal">Network</Text>
        </View>
        <NBButton
          label="Chats"
          size="sm"
          variant="ghost"
          onPress={() => router.push('/chats')}
        />
      </View>

      <FlatList
        data={THREADS}
        keyExtractor={(t: Thread) => t.id}
        contentContainerClassName="px-5 pb-24"
        showsVerticalScrollIndicator={false}
        renderItem={({ item }: { item: Thread }) => (
          <ThreadCard
            thread={item}
            onPress={() => router.push(`/thread/${item.id}`)}
          />
        )}
      />

      <View className="absolute bottom-6 right-5">
        <NBButton label="Post" onPress={() => undefined} variant="primary" />
      </View>
    </SafeAreaView>
  );
}
