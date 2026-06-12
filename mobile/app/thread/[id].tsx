import { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBBadge, NBButton, NBCard, NBInput } from '../../components/NB';
import type { ThreadComment } from '../../theme/tokens';

const COMMENTS: readonly ThreadComment[] = [
  {
    id: 'k1',
    author: 'ama.serwaa',
    level: 'Level 200',
    verified: true,
    upvotes: 34,
    depth: 0,
    text: 'Unity Hall is the closest, about 5 min walk. Brunei is 12-15 min but the rooms are better maintained.',
  },
  {
    id: 'k2',
    author: 'kwame_eng',
    level: 'Level 100',
    verified: true,
    upvotes: 12,
    depth: 1,
    text: 'This. And Unity gets loud during hall week — factor that in if you study in your room.',
  },
  {
    id: 'k3',
    author: 'efua_b',
    level: 'Level 100',
    verified: false,
    upvotes: 8,
    depth: 0,
    text: 'Nobody mentions the shuttle. If you are in Brunei the 7:20am shuttle gets you to CoE before first lecture.',
  },
];

function Comment({ comment }: { comment: ThreadComment }) {
  return (
    <View className="mb-3" style={{ marginLeft: comment.depth * 18 }}>
      <View className="bg-white border-2 border-black rounded-none shadow-nb-sm p-3">
        <View className="flex-row items-center gap-2 mb-1.5">
          <Text className="font-body-bold text-xs text-black">
            @{comment.author}
          </Text>
          <NBBadge label={comment.level} accent="action" />
          {comment.verified && <NBBadge label="✓" accent="verify" />}
        </View>
        <Text className="font-body text-[13.5px] leading-5 text-black mb-2">
          {comment.text}
        </Text>
        <View className="flex-row gap-3.5">
          <Text className="font-body-bold text-xs text-black">
            ▲ {comment.upvotes}
          </Text>
          <Text className="font-body-bold text-xs text-[#555] uppercase">
            Reply
          </Text>
        </View>
      </View>
    </View>
  );
}

export default function ThreadDetailScreen() {
  const router = useRouter();
  const [reply, setReply] = useState<string>('');

  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <View className="flex-row items-center gap-3 px-4 py-2.5 border-b-4 border-black">
        <Pressable onPress={() => router.back()} hitSlop={12}>
          <Text className="font-heading text-lg text-black">←</Text>
        </Pressable>
        <NBBadge label="KNUST" accent="brand" />
        <Text className="font-body-medium text-xs text-[#555] uppercase">
          Hub Thread
        </Text>
      </View>

      <ScrollView contentContainerClassName="p-4 pb-8">
        {/* Original post */}
        <NBCard className="mb-5 p-4">
          <View className="flex-row items-center gap-2 mb-2.5 flex-wrap">
            <Text className="font-body-bold text-xs text-black">@kwame_eng</Text>
            <NBBadge label="Level 100" accent="action" />
            <NBBadge label="✓ Verified" accent="verify" />
          </View>
          <Text className="font-heading text-lg leading-6 text-black mb-2.5">
            Which hall is actually closest to the College of Engineering?
          </Text>
          <Text className="font-body text-sm leading-[21px] text-black mb-3">
            Admission letter came through 🎉 Trying to pick a hall before
            orientation. Google Maps says one thing, seniors say another. Anyone
            in CoE who can settle this?
          </Text>
          <View className="flex-row gap-4">
            <Text className="font-body-bold text-[13px] text-black">▲ 128</Text>
            <Text className="font-body-bold text-[13px] text-black">💬 43</Text>
          </View>
        </NBCard>

        <Text className="font-heading text-sm text-black uppercase tracking-wide mb-3">
          43 Comments
        </Text>
        {COMMENTS.map((c) => (
          <Comment key={c.id} comment={c} />
        ))}

        <View className="mt-3 gap-3">
          <NBInput
            placeholder="Add a comment…"
            value={reply}
            onChangeText={setReply}
            multiline
          />
          <NBButton label="Post Comment" onPress={() => setReply('')} />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
