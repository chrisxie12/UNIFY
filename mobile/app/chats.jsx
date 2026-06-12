import { View, Text, FlatList, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBCard, NBBadge, NBInput } from '../components/NB';
import { COLORS } from '../theme/tokens';

const CHATS = [
  { id: 'c1', name: 'Sarah', school: 'UG Legon', match: '92%', last: 'I keep my side clean, promise 😂', time: '2m', unread: 3, initials: 'SA', color: COLORS.brand },
  { id: 'c2', name: 'Michael', school: 'KNUST', match: '87%', last: 'Library at 4pm works for me', time: '1h', unread: 1, initials: 'MI', color: '#0066FF' },
  { id: 'c3', name: 'Efua', school: 'UCC', match: '84%', last: 'Did you see the hostel listing?', time: '3h', unread: 0, initials: 'EF', color: '#16a34a' },
  { id: 'c4', name: 'Kwame', school: 'UPSA', match: '81%', last: 'Orientation is on the 14th', time: '1d', unread: 0, initials: 'KW', color: '#9333ea' },
];

function ChatRow({ chat, onPress }) {
  return (
    <Pressable onPress={onPress}>
      <NBCard style={{ marginBottom: 12 }} contentStyle={{ padding: 12, flexDirection: 'row', alignItems: 'center', gap: 12 }}>
        <View
          style={{
            width: 44, height: 44,
            backgroundColor: chat.color,
            borderWidth: 2, borderColor: COLORS.ink,
            alignItems: 'center', justifyContent: 'center',
          }}
        >
          <Text style={{ color: COLORS.white, fontFamily: 'SpaceGrotesk_700Bold', fontSize: 13 }}>
            {chat.initials}
          </Text>
        </View>
        <View style={{ flex: 1, minWidth: 0 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 14, color: COLORS.text }}>{chat.name}</Text>
            <NBBadge label={chat.match} bg={COLORS.action} />
          </View>
          <Text numberOfLines={1} style={{ fontFamily: 'Inter_400Regular', fontSize: 12.5, color: COLORS.textMuted, marginTop: 3 }}>
            {chat.last}
          </Text>
        </View>
        <View style={{ alignItems: 'flex-end', gap: 6 }}>
          <Text style={{ fontFamily: 'Inter_500Medium', fontSize: 10, color: COLORS.textMuted }}>{chat.time}</Text>
          {chat.unread > 0 && <NBBadge label={String(chat.unread)} bg={COLORS.alert} color={COLORS.white} />}
        </View>
      </NBCard>
    </Pressable>
  );
}

export default function ChatsScreen() {
  const router = useRouter();
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.parchment }} edges={['top']}>
      <View style={{ paddingHorizontal: 16, paddingTop: 8, paddingBottom: 12 }}>
        <Text style={{ fontFamily: 'ArchivoBlack', fontSize: 26, color: COLORS.text, letterSpacing: -1, marginBottom: 12 }}>
          CHATS
        </Text>
        <NBInput placeholder="Search matches…" />
      </View>
      <FlatList
        data={CHATS}
        keyExtractor={(c) => c.id}
        contentContainerStyle={{ paddingHorizontal: 16, paddingTop: 4, paddingBottom: 32 }}
        renderItem={({ item }) => (
          <ChatRow chat={item} onPress={() => router.push(`/chat/${item.id}`)} />
        )}
      />
    </SafeAreaView>
  );
}
