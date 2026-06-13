import { useCallback, useRef, useState } from 'react';
import { Pressable, ScrollView, Text, View, type ScrollView as ScrollViewType } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { NBBadge, NBButton, NBCard, NBInput, NBPopBadge } from '../../components/NB';
import type { Thread, ThreadComment } from '../../theme/tokens';

interface ThreadPost extends Thread {
  readonly body: string;
}

const THREAD_DATA: Readonly<Record<string, ThreadPost>> = {
  t1: {
    id: 't1', hub: 'KNUST', author: 'kwame_eng', level: 'Level 100', verified: true,
    upvotes: 128, comments: 43, time: '2h',
    title: 'Which hall is actually closest to the College of Engineering?',
    body: 'Admission letter came through 🎉 Trying to pick a hall before orientation. Google Maps says one thing, seniors say another. Anyone in CoE who can settle this?',
  },
  t2: {
    id: 't2', hub: 'UG Legon', author: 'ama.serwaa', level: 'Level 200', verified: true,
    upvotes: 96, comments: 31, time: '4h',
    title: 'Roommate red flags to watch for during orientation week 🚩',
    body: "Seen a lot of posts asking about roommates so here's what I learned after a full year. Some things look small at first but become huge deals when you're sharing a room for 9 months.",
  },
  t3: {
    id: 't3', hub: 'UCC', author: 'efua_b', level: 'Level 100', verified: false,
    upvotes: 74, comments: 22, time: '6h',
    title: 'Evandy vs Brunei: honest hostel review after one semester',
    body: 'Did a full semester in Evandy then moved to Brunei. Here is an honest comparison with no sponsored bias.',
  },
  t4: {
    id: 't4', hub: 'UPSA', author: 'yaw.mensah', level: 'Level 100', verified: true,
    upvotes: 51, comments: 9, time: '9h',
    title: 'Study group for Business Math — 12 spots left',
    body: 'We are running a structured study group for Business Math 101. Sessions are twice a week, library room 4. DM to join — first session is Friday.',
  },
};

const SEED_COMMENTS: Readonly<Record<string, readonly ThreadComment[]>> = {
  t1: [
    { id: 'k1', author: 'ama.serwaa', level: 'Level 200', verified: true,  upvotes: 34, depth: 0, text: 'Unity Hall is the closest, about 5 min walk. Brunei is 12–15 min but the rooms are better maintained.' },
    { id: 'k2', author: 'kwame_eng',  level: 'Level 100', verified: true,  upvotes: 12, depth: 1, text: 'This. And Unity gets loud during hall week — factor that in if you study in your room.' },
    { id: 'k3', author: 'efua_b',     level: 'Level 100', verified: false, upvotes: 8,  depth: 0, text: 'Nobody mentions the shuttle. If you are in Brunei the 7:20am shuttle gets you to CoE before first lecture.' },
  ],
  t2: [
    { id: 'k1', author: 'yaw.mensah', level: 'Level 100', verified: true,  upvotes: 21, depth: 0, text: 'The one that stresses me most: someone who is always in the room when you need quiet. Set expectations day one.' },
    { id: 'k2', author: 'efua_b',     level: 'Level 100', verified: false, upvotes: 9,  depth: 1, text: 'This exactly. Also agree on lights-out times before you move in, not after.' },
  ],
  t3: [
    { id: 'k1', author: 'kwame_eng',  level: 'Level 100', verified: true,  upvotes: 17, depth: 0, text: 'Brunei bathroom situation improved a lot since last year. Good write-up.' },
  ],
  t4: [
    { id: 'k1', author: 'ama.serwaa', level: 'Level 200', verified: true,  upvotes: 5,  depth: 0, text: 'Sent you a DM! Business Math broke me last semester, need this.' },
  ],
};

function nowTime(): string {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

interface CommentCardProps {
  comment: ThreadComment;
  upvoted: boolean;
  onUpvote: () => void;
  onReply: () => void;
}

function CommentCard({ comment, upvoted, onUpvote, onReply }: CommentCardProps) {
  return (
    <View className="mb-3" style={{ marginLeft: comment.depth * 20 }}>
      <View className="bg-white border-2 border-black rounded-none shadow-nb-sm p-3">
        <View className="flex-row items-center gap-2 mb-1.5 flex-wrap">
          <Text className="font-body-bold text-xs text-black">
            @{comment.author}
          </Text>
          <NBBadge label={comment.level} accent="action" />
          {comment.verified && <NBBadge label="✓" accent="verify" />}
        </View>
        <Text className="font-body text-[13.5px] leading-[21px] text-black mb-2">
          {comment.text}
        </Text>
        <View className="flex-row gap-3.5 items-center">
          <Pressable
            onPress={onUpvote}
            accessibilityRole="button"
            accessibilityLabel={upvoted ? 'Remove upvote' : 'Upvote'}
            className="flex-row items-center gap-1"
          >
            <Text className={`font-body-bold text-xs ${upvoted ? 'text-brand' : 'text-black'}`}>
              ▲ {comment.upvotes + (upvoted ? 1 : 0)}
            </Text>
          </Pressable>
          <Pressable
            onPress={onReply}
            accessibilityRole="button"
            accessibilityLabel={`Reply to ${comment.author}`}
          >
            <Text className="font-body-bold text-xs text-[#555] uppercase">
              Reply
            </Text>
          </Pressable>
          {comment.depth === 0 && (
            <NBPopBadge
              label={`${comment.upvotes + (upvoted ? 1 : 0) >= 20 ? 'Hot' : 'New'}`}
              accent={comment.upvotes + (upvoted ? 1 : 0) >= 20 ? 'red' : 'blue'}
            />
          )}
        </View>
      </View>
    </View>
  );
}

export default function ThreadDetailScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const thread = THREAD_DATA[id ?? 't1'] ?? THREAD_DATA['t1'];

  const [comments, setComments] = useState<readonly ThreadComment[]>(
    SEED_COMMENTS[thread.id] ?? [],
  );
  const [upvotedCommentIds, setUpvotedCommentIds] = useState<ReadonlySet<string>>(
    new Set(),
  );
  const [threadUpvoted, setThreadUpvoted] = useState<boolean>(false);
  const [replyText, setReplyText] = useState<string>('');
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const scrollRef = useRef<ScrollViewType>(null);

  const toggleCommentUpvote = useCallback((commentId: string) => {
    setUpvotedCommentIds((prev) => {
      const next = new Set(prev);
      if (next.has(commentId)) {
        next.delete(commentId);
      } else {
        next.add(commentId);
      }
      return next;
    });
  }, []);

  const startReply = useCallback((author: string) => {
    setReplyingTo(author);
    setReplyText(`@${author} `);
    requestAnimationFrame(() => scrollRef.current?.scrollToEnd({ animated: true }));
  }, []);

  const postComment = useCallback(() => {
    const text = replyText.trim();
    if (text.length === 0) return;
    const newComment: ThreadComment = {
      id: `c-${Date.now()}`,
      author: 'kwame_eng',
      level: 'Level 100',
      verified: true,
      upvotes: 0,
      depth: replyingTo !== null ? 1 : 0,
      text,
    };
    setComments((prev) => [...prev, newComment]);
    setReplyText('');
    setReplyingTo(null);
    requestAnimationFrame(() => scrollRef.current?.scrollToEnd({ animated: true }));
  }, [replyText, replyingTo]);

  const totalUpvotes = thread.upvotes + (threadUpvoted ? 1 : 0);
  const totalComments = thread.comments + comments.length - (SEED_COMMENTS[thread.id]?.length ?? 0);

  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <View className="flex-row items-center gap-3 px-4 py-2.5 border-b-4 border-black">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Go back"
        >
          <Text className="font-heading text-lg text-black">←</Text>
        </Pressable>
        <NBBadge label={thread.hub} accent="brand" />
        <Text className="font-body-medium text-xs text-[#555] uppercase">
          Hub Thread
        </Text>
      </View>

      <ScrollView ref={scrollRef} contentContainerClassName="p-4 pb-8">
        {/* Original post */}
        <NBCard className="mb-5 p-4">
          <View className="flex-row items-center gap-2 mb-2.5 flex-wrap">
            <Text className="font-body-bold text-xs text-black">
              @{thread.author}
            </Text>
            <NBBadge label={thread.level} accent="action" />
            {thread.verified && <NBBadge label="✓ Verified" accent="verify" />}
            <Text className="ml-auto font-body-medium text-[10px] text-[#555]">
              {thread.time}
            </Text>
          </View>
          <Text className="font-heading text-lg leading-6 text-black mb-2.5">
            {thread.title}
          </Text>
          <Text className="font-body text-sm leading-[21px] text-black mb-3">
            {thread.body}
          </Text>
          <View className="flex-row gap-4 items-center">
            <Pressable
              onPress={() => setThreadUpvoted((v) => !v)}
              accessibilityRole="button"
              accessibilityLabel={threadUpvoted ? 'Remove upvote' : 'Upvote post'}
              className="flex-row items-center gap-1.5"
            >
              <Text
                className={`font-body-bold text-[13px] ${threadUpvoted ? 'text-brand' : 'text-black'}`}
              >
                ▲ {totalUpvotes}
              </Text>
            </Pressable>
            <Text className="font-body-bold text-[13px] text-black">
              💬 {totalComments}
            </Text>
            {threadUpvoted && (
              <NBPopBadge label="Upvoted" accent="green" className="ml-auto" />
            )}
          </View>
        </NBCard>

        {/* Comment count */}
        <Text className="font-heading text-sm text-black uppercase tracking-wide mb-3">
          {totalComments} {totalComments === 1 ? 'Comment' : 'Comments'}
        </Text>

        {comments.map((comment) => (
          <CommentCard
            key={comment.id}
            comment={comment}
            upvoted={upvotedCommentIds.has(comment.id)}
            onUpvote={() => toggleCommentUpvote(comment.id)}
            onReply={() => startReply(comment.author)}
          />
        ))}

        {/* Composer */}
        <View className="mt-3 gap-3">
          {replyingTo !== null && (
            <View className="flex-row items-center gap-2 bg-white border-2 border-black rounded-none px-3 py-2">
              <Text className="font-body-bold text-xs text-black flex-1">
                Replying to @{replyingTo}
              </Text>
              <Pressable
                onPress={() => {
                  setReplyingTo(null);
                  setReplyText('');
                }}
                accessibilityRole="button"
                accessibilityLabel="Cancel reply"
              >
                <Text className="font-body-bold text-xs text-[#555]">✕</Text>
              </Pressable>
            </View>
          )}
          <NBInput
            placeholder={
              replyingTo !== null
                ? `Reply to @${replyingTo}…`
                : 'Add a comment…'
            }
            value={replyText}
            onChangeText={setReplyText}
            multiline
          />
          <NBButton label="Post Comment" onPress={postComment} accent="verify" />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
