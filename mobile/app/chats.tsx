import { useMemo, useState } from 'react';
import { FlatList, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBInput, NBPressCard } from '../components/NB';
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
    <NBPressCard
      onPress={onPress}
      className="mb-3 p-4 flex-row items-center gap-3"
    >
      <NBAvatar initials={chat.initials} accent={chat.accent} />
      <View className="flex-1 min-w-0">
        <View className="flex-row items-center gap-2 mb-0.5">
          <Text className="font-body-bold text-sm text-charcoal">{chat.name}</Text>
          <View className="bg-[#EFF6FF] rounded-full px-2 py-0.5">
            <Text className="text-accent text-[10px] font-body-bold">
              {chat.match}
            </Text>
          </View>
        </View>
        <Text numberOfLines={1} className="font-body text-[12.5px] text-muted">
          {chat.last}
        </Text>
      </View>
      <View className="items-end gap-1.5">
        <Text className="font-body-medium text-[10px] text-subtle">
          {chat.time}
        </Text>
        {chat.unread > 0 && (
          <View className="bg-notif rounded-full w-5 h-5 items-center justify-center">
            <Text className="text-white text-[10px] font-body-bold">
              {chat.unread}
            </Text>
          </View>
        )}
      </View>
    </NBPressCard>
  );
}

export default function ChatsScreen() {
  const router = useRouter();
  const [query, setQuery] = useState<string>('');

  const visibleChats = useMemo(() => {
    const needle = query.trim().toLowerCase();
    if (needle.length === 0) return CHATS;
    return CHATS.filter(
      (chat) =>
        chat.name.toLowerCase().includes(needle) ||
        chat.school.toLowerCase().includes(needle),
    );
  }, [query]);

  const totalUnread = CHATS.reduce((sum, chat) => sum + chat.unread, 0);

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="px-5 pt-5 pb-4">
        <View className="flex-row items-center gap-3 mb-4">
          <Pressable
            onPress={() => router.back()}
            hitSlop={12}
            accessibilityRole="button"
            accessibilityLabel="Go back"
            className="w-9 h-9 rounded-full bg-surface items-center justify-center active:opacity-75"
          >
            <Text className="font-heading text-base text-charcoal">←</Text>
          </Pressable>
          <Text className="font-heading text-2xl text-charcoal">Messages</Text>
          {totalUnread > 0 && (
            <View className="ml-auto bg-notif rounded-full px-2.5 py-0.5">
              <Text className="text-white text-[10px] font-body-bold">
                {totalUnread} new
              </Text>
            </View>
          )}
        </View>
        <NBInput
          placeholder="Search by name or school…"
          value={query}
          onChangeText={setQuery}
        />
      </View>

      <FlatList
        data={visibleChats}
        keyExtractor={(chat: Chat) => chat.id}
        contentContainerClassName="px-5 pb-10"
        showsVerticalScrollIndicator={false}
        renderItem={({ item }: { item: Chat }) => (
          <ChatRow
            chat={item}
            onPress={() => router.push(`/chat/${item.id}`)}
          />
        )}
        ListEmptyComponent={
          <View className="bg-white rounded-2xl shadow-card p-6 items-center">
            <Text className="font-heading text-base text-charcoal mb-1">
              No results
            </Text>
            <Text className="font-body-medium text-sm text-muted">
              Try a different name or school.
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}
