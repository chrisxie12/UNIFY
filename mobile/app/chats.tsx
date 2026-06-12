import { FlatList, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBBadge, NBInput, NBPressCard } from '../components/NB';
import type { Chat } from '../theme/tokens';

const CHATS: readonly Chat[] = [
  {
    id: 'c1',
    name: 'Sarah',
    school: 'UG Legon',
    match: '92%',
    last: 'I keep my side clean, promise 😂',
    time: '2m',
    unread: 3,
    initials: 'SA',
    accent: 'brand',
  },
  {
    id: 'c2',
    name: 'Michael',
    school: 'KNUST',
    match: '87%',
    last: 'Library at 4pm works for me',
    time: '1h',
    unread: 1,
    initials: 'MI',
    accent: 'info',
  },
  {
    id: 'c3',
    name: 'Efua',
    school: 'UCC',
    match: '84%',
    last: 'Did you see the hostel listing?',
    time: '3h',
    unread: 0,
    initials: 'EF',
    accent: 'success',
  },
  {
    id: 'c4',
    name: 'Kwame',
    school: 'UPSA',
    match: '81%',
    last: 'Orientation is on the 14th',
    time: '1d',
    unread: 0,
    initials: 'KW',
    accent: 'alert',
  },
];

interface ChatRowProps {
  chat: Chat;
  onPress: () => void;
}

function ChatRow({ chat, onPress }: ChatRowProps) {
  return (
    <NBPressCard onPress={onPress} className="mb-3 p-3 flex-row items-center gap-3">
      <NBAvatar initials={chat.initials} accent={chat.accent} />
      <View className="flex-1 min-w-0">
        <View className="flex-row items-center gap-2">
          <Text className="font-body-bold text-sm text-black">{chat.name}</Text>
          <NBBadge label={chat.match} accent="action" />
        </View>
        <Text
          numberOfLines={1}
          className="font-body text-[12.5px] text-[#555] mt-1"
        >
          {chat.last}
        </Text>
      </View>
      <View className="items-end gap-1.5">
        <Text className="font-body-medium text-[10px] text-[#555]">
          {chat.time}
        </Text>
        {chat.unread > 0 && (
          <NBBadge label={String(chat.unread)} accent="alert" />
        )}
      </View>
    </NBPressCard>
  );
}

export default function ChatsScreen() {
  const router = useRouter();
  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <View className="px-4 pt-2 pb-3">
        <Text className="font-display text-[26px] text-black uppercase tracking-tight mb-3">
          Chats
        </Text>
        <NBInput placeholder="Search matches…" />
      </View>
      <FlatList
        data={CHATS}
        keyExtractor={(c: Chat) => c.id}
        contentContainerClassName="px-4 pt-1 pb-8"
        renderItem={({ item }: { item: Chat }) => (
          <ChatRow chat={item} onPress={() => router.push(`/chat/${item.id}`)} />
        )}
      />
    </SafeAreaView>
  );
}
