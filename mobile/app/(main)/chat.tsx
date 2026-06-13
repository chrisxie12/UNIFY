import { useMemo, useState } from 'react';
import { Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Avatar, Divider } from '../../components/UI';
import { COLORS } from '../../theme/tokens';

const CHATS = [
  { id: 'c1', name: 'Ama Serwaa',    school: 'KNUST', match: '94%', initials: 'AS', color: 'orange', last: "Same! Which hostel are you looking at?",                time: '10:05', unread: 2 },
  { id: 'c2', name: 'Michael Agyei', school: 'KNUST', match: '88%', initials: 'MA', color: 'blue',   last: "Library at 4pm works for me — quiet section?",         time: '09:17', unread: 0 },
  { id: 'c3', name: 'Efua Boateng',  school: 'UCC',   match: '82%', initials: 'EB', color: 'green',  last: "Brunei is still the best value for CoE students",       time: 'Yesterday', unread: 1 },
  { id: 'c4', name: 'Yaw Mensah',    school: 'UPSA',  match: '79%', initials: 'YM', color: 'red',    last: "Orientation is on the 14th — staying on campus?",       time: '1d ago', unread: 0 },
];

export default function ChatListScreen() {
  const router  = useRouter();
  const [query, setQuery] = useState('');
  const [focused, setFocused] = useState(false);

  const totalUnread = CHATS.reduce((s, c) => s + c.unread, 0);

  const filtered = useMemo(() =>
    CHATS.filter((c) => !query || c.name.toLowerCase().includes(query.toLowerCase())),
    [query],
  );

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="px-5 pt-5 pb-3">
        <View className="flex-row items-center gap-2 mb-4">
          <Text className="font-display text-2xl text-primary">Chats</Text>
          {totalUnread > 0 && (
            <View className="bg-orange rounded-full w-5 h-5 items-center justify-center">
              <Text className="text-white text-[10px] font-body-semi">{totalUnread}</Text>
            </View>
          )}
        </View>

        {/* Search */}
        <View
          className={`flex-row items-center bg-surface rounded-2xl border h-11 px-4 gap-2 ${
            focused ? 'border-blue' : 'border-border'
          }`}
        >
          <Text className="text-tertxt">🔍</Text>
          <TextInput
            placeholder="Search conversations…"
            placeholderTextColor={COLORS.tertxt}
            value={query}
            onChangeText={setQuery}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            className="flex-1 font-body text-sm text-primary"
          />
        </View>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}>
        {filtered.length === 0 ? (
          <View className="items-center py-20">
            <Text className="font-body text-sm text-tertxt">No conversations found.</Text>
          </View>
        ) : (
          filtered.map((c, i) => (
            <View key={c.id}>
              <Pressable
                onPress={() => router.push(`/chat/${c.id}`)}
                className="flex-row items-center gap-3 px-5 py-4 active:bg-surface"
              >
                <View>
                  <Avatar initials={c.initials} color={c.color} size="md" />
                  {c.unread > 0 && (
                    <View className="absolute -top-0.5 -right-0.5 bg-orange rounded-full w-4 h-4 items-center justify-center">
                      <Text className="text-white text-[8px] font-body-semi">{c.unread}</Text>
                    </View>
                  )}
                </View>

                <View className="flex-1">
                  <View className="flex-row items-center justify-between mb-0.5">
                    <Text className={`text-sm ${c.unread > 0 ? 'font-body-semi text-primary' : 'font-body text-secondary'}`}>
                      {c.name}
                    </Text>
                    <Text className="font-body text-[10px] text-tertxt">{c.time}</Text>
                  </View>
                  <View className="flex-row items-center gap-2">
                    <View className="bg-[#EFF6FF] rounded-full px-2 py-0.5">
                      <Text className="text-blue text-[9px] font-body-semi">{c.match}</Text>
                    </View>
                    <Text
                      className={`text-xs flex-1 ${c.unread > 0 ? 'font-body-medium text-secondary' : 'font-body text-tertxt'}`}
                      numberOfLines={1}
                    >
                      {c.last}
                    </Text>
                  </View>
                </View>
              </Pressable>
              {i < filtered.length - 1 && <Divider className="mx-5" />}
            </View>
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
