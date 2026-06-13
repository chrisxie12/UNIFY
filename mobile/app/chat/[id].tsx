import { useCallback, useRef, useState } from 'react';
import {
  FlatList,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  Text,
  View,
  type FlatList as FlatListType,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { NBAvatar, NBInput } from '../../components/NB';
import type { Chat, ChatMessage } from '../../theme/tokens';

const CONTACTS: Readonly<Record<string, Omit<Chat, 'last' | 'time' | 'unread'>>> = {
  c1: { id: 'c1', name: 'Sarah',   school: 'UG Legon', match: '92%', initials: 'SA', accent: 'brand'   },
  c2: { id: 'c2', name: 'Michael', school: 'KNUST',    match: '87%', initials: 'MI', accent: 'info'    },
  c3: { id: 'c3', name: 'Efua',    school: 'UCC',      match: '84%', initials: 'EF', accent: 'success' },
  c4: { id: 'c4', name: 'Kwame',   school: 'UPSA',     match: '81%', initials: 'KW', accent: 'alert'   },
};

const SEED_MESSAGES: Readonly<Record<string, readonly ChatMessage[]>> = {
  c1: [
    { id: 'm1', mine: false, text: 'Hey! We matched 92% 🔥 Are you early bird or night owl fr?', time: '10:02' },
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
        className={`rounded-2xl px-4 py-2.5 ${
          msg.mine ? 'bg-accent rounded-br-sm' : 'bg-surface rounded-bl-sm'
        }`}
      >
        <Text
          className={`text-sm leading-[20px] font-body ${
            msg.mine ? 'text-white' : 'text-charcoal'
          }`}
        >
          {msg.text}
        </Text>
      </View>
      <Text
        className={`font-body-medium text-[9px] text-subtle mt-1 ${
          msg.mine ? 'self-end' : 'self-start'
        }`}
      >
        {msg.time}
      </Text>
    </View>
  );
}

export default function ChatThreadScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const contact = CONTACTS[id ?? ''] ?? CONTACTS['c1'];
  const [messages, setMessages] = useState<readonly ChatMessage[]>(
    SEED_MESSAGES[id ?? ''] ?? SEED_MESSAGES['c1'],
  );
  const [draft, setDraft] = useState<string>('');
  const listRef = useRef<FlatListType<ChatMessage>>(null);

  const send = useCallback(() => {
    const text = draft.trim();
    if (text.length === 0) return;
    setMessages((prev) => [
      ...prev,
      { id: `msg-${Date.now()}`, mine: true, text, time: nowTime() },
    ]);
    setDraft('');
    requestAnimationFrame(() => listRef.current?.scrollToEnd({ animated: true }));
  }, [draft]);

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Header */}
      <View className="flex-row items-center gap-3 px-5 py-3 border-b border-divider bg-white">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Go back"
          className="w-9 h-9 rounded-full bg-surface items-center justify-center active:opacity-75"
        >
          <Text className="font-heading text-base text-charcoal">←</Text>
        </Pressable>
        <NBAvatar initials={contact.initials} accent={contact.accent} size="sm" />
        <View className="flex-1">
          <Text className="font-body-bold text-sm text-charcoal">
            {contact.name}
          </Text>
          <Text className="font-body-medium text-[10px] text-muted">
            {contact.school}
          </Text>
        </View>
        <View className="bg-[#EFF6FF] rounded-full px-3 py-1">
          <Text className="text-accent text-[11px] font-body-bold">
            {contact.match} Match
          </Text>
        </View>
      </View>

      <KeyboardAvoidingView
        className="flex-1"
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <FlatList
          ref={listRef}
          data={messages as ChatMessage[]}
          keyExtractor={(m: ChatMessage) => m.id}
          contentContainerClassName="px-5 py-4"
          showsVerticalScrollIndicator={false}
          renderItem={({ item }: { item: ChatMessage }) => (
            <Bubble msg={item} />
          )}
          onContentSizeChange={() =>
            listRef.current?.scrollToEnd({ animated: false })
          }
        />

        {/* Composer */}
        <View className="flex-row items-center gap-3 px-5 py-3 border-t border-divider bg-white">
          <View className="flex-1">
            <NBInput
              placeholder="Message…"
              value={draft}
              onChangeText={setDraft}
            />
          </View>
          <Pressable
            onPress={send}
            accessibilityRole="button"
            accessibilityLabel="Send message"
            className="bg-accent w-11 h-11 rounded-full items-center justify-center active:opacity-75"
          >
            <Text className="text-white text-base">↑</Text>
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
