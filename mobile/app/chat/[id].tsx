import { useCallback, useRef, useState } from 'react';
import {
  FlatList, KeyboardAvoidingView, Platform,
  Pressable, Text, TextInput, View,
  type FlatList as FlatListType,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Avatar } from '../../components/UI';
import { COLORS } from '../../theme/tokens';
import type { ChatMessage } from '../../theme/tokens';

const CONTACTS: Record<string, { name: string; school: string; match: string; initials: string; color: string }> = {
  c1: { name: 'Ama Serwaa',    school: 'KNUST', match: '94%', initials: 'AS', color: 'orange' },
  c2: { name: 'Michael Agyei', school: 'KNUST', match: '88%', initials: 'MA', color: 'blue'   },
  c3: { name: 'Efua Boateng',  school: 'UCC',   match: '82%', initials: 'EB', color: 'green'  },
  c4: { name: 'Yaw Mensah',    school: 'UPSA',  match: '79%', initials: 'YM', color: 'red'    },
};

const SEED_MESSAGES: Record<string, ChatMessage[]> = {
  c1: [
    { id: 'm1', mine: false, text: 'Hey! We matched 94% 🔥 Are you early bird or night owl fr?', time: '10:02' },
    { id: 'm2', mine: true,  text: 'Night owl 100%. You saw my quiz answers 😄', time: '10:04' },
    { id: 'm3', mine: false, text: 'Same! Which hostel are you looking at? I keep my side clean, promise 😂', time: '10:05' },
    { id: 'm4', mine: true,  text: 'Evandy or Brunei. There is a thread in the KNUST hub comparing them', time: '10:07' },
  ],
  c2: [
    { id: 'm1', mine: false, text: 'Library at 4pm works for me — the quiet section on the 2nd floor?', time: '09:15' },
    { id: 'm2', mine: true,  text: 'Perfect. I will bring the past papers', time: '09:17' },
  ],
  c3: [
    { id: 'm1', mine: false, text: 'Did you see the hostel listing? Prices went up again 😭', time: 'Yesterday' },
    { id: 'm2', mine: true,  text: 'I know. Brunei is still the best value for CoE students though', time: 'Yesterday' },
  ],
  c4: [
    { id: 'm1', mine: false, text: 'Orientation is on the 14th — are you staying on campus that week?', time: '1d ago' },
  ],
};

function nowTime(): string {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

function Bubble({ msg }: { msg: ChatMessage }) {
  return (
    <View className={`max-w-[78%] mb-3 ${msg.mine ? 'self-end' : 'self-start'}`}>
      <View
        className={`rounded-2xl px-4 py-3 ${
          msg.mine ? 'bg-btn-primary rounded-br-sm' : 'bg-surface rounded-bl-sm'
        }`}
      >
        <Text className={`text-sm leading-5 font-body ${msg.mine ? 'text-white' : 'text-primary'}`}>
          {msg.text}
        </Text>
      </View>
      <Text className={`font-body text-[9px] text-tertxt mt-1 ${msg.mine ? 'self-end' : 'self-start'}`}>
        {msg.time}
      </Text>
    </View>
  );
}

export default function ChatRoomScreen() {
  const router  = useRouter();
  const { id }  = useLocalSearchParams<{ id: string }>();
  const contact = CONTACTS[id ?? ''] ?? CONTACTS['c1'];
  const [messages, setMessages] = useState<ChatMessage[]>(
    SEED_MESSAGES[id ?? ''] ?? SEED_MESSAGES['c1'],
  );
  const [draft, setDraft]   = useState('');
  const [focused, setFocused] = useState(false);
  const listRef = useRef<FlatListType<ChatMessage>>(null);

  const send = useCallback(() => {
    const text = draft.trim();
    if (!text) return;
    setMessages((prev) => [...prev, { id: `m-${Date.now()}`, mine: true, text, time: nowTime() }]);
    setDraft('');
    requestAnimationFrame(() => listRef.current?.scrollToEnd({ animated: true }));
  }, [draft]);

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Header */}
      <View className="flex-row items-center gap-3 px-5 py-3 border-b border-border bg-white">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
        <Avatar initials={contact.initials} color={contact.color} size="sm" />
        <View className="flex-1">
          <Text className="font-body-semi text-sm text-primary">{contact.name}</Text>
          <Text className="font-body text-[10px] text-tertxt">{contact.school}</Text>
        </View>
        <View className="bg-[#EFF6FF] rounded-full px-3 py-1">
          <Text className="text-blue text-[11px] font-body-semi">{contact.match} Match</Text>
        </View>
      </View>

      <KeyboardAvoidingView
        className="flex-1"
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <FlatList
          ref={listRef}
          data={messages}
          keyExtractor={(m) => m.id}
          contentContainerStyle={{ paddingHorizontal: 20, paddingVertical: 16 }}
          showsVerticalScrollIndicator={false}
          renderItem={({ item }) => <Bubble msg={item} />}
          onContentSizeChange={() => listRef.current?.scrollToEnd({ animated: false })}
        />

        {/* Composer */}
        <View className="flex-row items-center gap-3 px-5 py-3 border-t border-border bg-white">
          <View className="flex-1">
            <TextInput
              placeholder="Message…"
              placeholderTextColor={COLORS.tertxt}
              value={draft}
              onChangeText={setDraft}
              onFocus={() => setFocused(true)}
              onBlur={() => setFocused(false)}
              className={`bg-surface rounded-full px-5 py-3 text-sm font-body text-primary border ${
                focused ? 'border-blue' : 'border-border'
              }`}
            />
          </View>
          <Pressable
            onPress={send}
            accessibilityRole="button"
            className="bg-blue w-11 h-11 rounded-full items-center justify-center active:opacity-80"
          >
            <Text className="text-white text-base">↑</Text>
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
