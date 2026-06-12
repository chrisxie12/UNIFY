import { useState } from 'react';
import {
  FlatList,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBBadge, NBButton, NBInput } from '../../components/NB';
import type { ChatMessage } from '../../theme/tokens';

const MESSAGES: readonly ChatMessage[] = [
  {
    id: 'm1',
    mine: false,
    text: 'Hey! We matched 92% 🔥 Are you early bird or night owl fr?',
    time: '10:02',
  },
  {
    id: 'm2',
    mine: true,
    text: 'Night owl 100%. You saw my quiz answers 😄',
    time: '10:04',
  },
  {
    id: 'm3',
    mine: false,
    text: 'Same! Which hostel are you looking at? I keep my side clean, promise 😂',
    time: '10:05',
  },
  {
    id: 'm4',
    mine: true,
    text: 'Evandy or Brunei. There is a thread in the KNUST hub comparing them',
    time: '10:07',
  },
];

// Bubbles live in the calm reading zone: white / tinted surfaces, never neon.
function Bubble({ msg }: { msg: ChatMessage }) {
  return (
    <View className={`max-w-[80%] mb-3 ${msg.mine ? 'self-end' : 'self-start'}`}>
      <View
        className={`border-2 border-black rounded-none shadow-nb-sm px-3 py-2 ${
          msg.mine ? 'bg-action/20' : 'bg-white'
        }`}
      >
        <Text className="font-body text-sm leading-5 text-black">{msg.text}</Text>
      </View>
      <Text
        className={`font-body-medium text-[9px] text-[#555] mt-1 ${
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
  const [draft, setDraft] = useState<string>('');

  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      {/* Header */}
      <View className="flex-row items-center gap-3 px-4 py-2.5 border-b-4 border-black bg-parchment">
        <Pressable onPress={() => router.back()} hitSlop={12}>
          <Text className="font-heading text-lg text-black">←</Text>
        </Pressable>
        <NBAvatar initials="SA" accent="brand" size="sm" />
        <View>
          <Text className="font-body-bold text-sm text-black">Sarah</Text>
          <Text className="font-body-medium text-[10px] text-[#555]">
            UG Legon
          </Text>
        </View>
        <NBBadge label="92% Match" accent="action" className="ml-auto" />
      </View>

      <KeyboardAvoidingView
        className="flex-1"
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <FlatList
          data={MESSAGES}
          keyExtractor={(m: ChatMessage) => m.id}
          contentContainerClassName="p-4"
          renderItem={({ item }: { item: ChatMessage }) => <Bubble msg={item} />}
        />

        {/* Composer */}
        <View className="flex-row items-center gap-2.5 px-4 py-3 border-t-4 border-black">
          <View className="flex-1">
            <NBInput placeholder="Message…" value={draft} onChangeText={setDraft} />
          </View>
          <NBButton label="Send" size="sm" onPress={() => setDraft('')} />
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
