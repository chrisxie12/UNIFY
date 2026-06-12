import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBBadge, NBButton, NBCard, NBPopBadge } from '../components/NB';
import { useApp } from '../context/AppContext';

interface QuizAnswer {
  readonly label: string;
  readonly value: string;
}

const QUIZ_ANSWERS: readonly QuizAnswer[] = [
  { label: 'Sleep schedule', value: 'Night Owl' },
  { label: 'Cleanliness', value: 'Very tidy' },
  { label: 'Budget', value: 'GHS 2,500–4,000 / yr' },
  { label: 'Study style', value: 'Library, evenings' },
];

export default function ProfileScreen() {
  const router = useRouter();
  const { profile, gpa, totalCredits, modules, pendingAssignments } = useApp();

  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <View className="flex-row items-center gap-3 px-4 pt-2 pb-3">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Go back"
        >
          <Text className="font-heading text-lg text-black">←</Text>
        </Pressable>
        <Text className="font-display text-[26px] text-black uppercase tracking-tight">
          My Profile
        </Text>
      </View>

      <ScrollView contentContainerClassName="px-4 pb-12">
        <NBCard className="mb-4 p-4 items-center">
          <View className="mb-3">
            <NBAvatar initials={profile.initials} accent="brand" size="lg" />
          </View>
          <Text className="font-heading text-xl text-black">{profile.name}</Text>
          <Text className="font-body-medium text-[13px] text-[#555] mb-2.5">
            {profile.school} · {profile.programme}
          </Text>
          <View className="flex-row gap-2">
            {profile.verified && <NBBadge label="✓ Verified" accent="verify" />}
            <NBBadge label={profile.level} accent="action" />
          </View>
        </NBCard>

        {/* Academic metrics — live from the same context the dashboard uses */}
        <View className="flex-row gap-3 mb-4">
          <View className="flex-1 bg-pop-yellow border-4 border-black rounded-none shadow-nb p-3">
            <Text className="font-display text-[24px] leading-7 text-black">
              {gpa.toFixed(2)}
            </Text>
            <Text className="font-heading text-[10px] text-black uppercase tracking-wide">
              GPA
            </Text>
          </View>
          <View className="flex-1 bg-pop-green border-4 border-black rounded-none shadow-nb p-3">
            <Text className="font-display text-[24px] leading-7 text-black">
              {totalCredits}
            </Text>
            <Text className="font-heading text-[10px] text-black uppercase tracking-wide">
              Credits
            </Text>
          </View>
          <View className="flex-1 bg-pop-blue border-4 border-black rounded-none shadow-nb p-3">
            <Text className="font-display text-[24px] leading-7 text-black">
              {modules.length}
            </Text>
            <Text className="font-heading text-[10px] text-black uppercase tracking-wide">
              Modules
            </Text>
          </View>
        </View>

        {pendingAssignments > 0 && (
          <View className="flex-row items-center gap-2.5 bg-white border-4 border-black rounded-none shadow-nb-sm px-3 py-2.5 mb-4">
            <NBPopBadge label={String(pendingAssignments)} accent="red" />
            <Text className="font-body-bold text-[13px] text-black">
              {pendingAssignments === 1
                ? 'assignment still due this week'
                : 'assignments still due this week'}
            </Text>
          </View>
        )}

        <NBCard className="mb-4 p-4">
          <Text className="font-heading text-sm text-black uppercase tracking-wide mb-3">
            Roommate Quiz
          </Text>
          {QUIZ_ANSWERS.map((answer) => (
            <View
              key={answer.label}
              className="flex-row justify-between py-1.5 border-b-2 border-black/10"
            >
              <Text className="font-body-medium text-[13px] text-[#555]">
                {answer.label}
              </Text>
              <Text className="font-body-bold text-[13px] text-black">
                {answer.value}
              </Text>
            </View>
          ))}
        </NBCard>

        <NBButton label="Retake Quiz" onPress={() => undefined} />
      </ScrollView>
    </SafeAreaView>
  );
}
