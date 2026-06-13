import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBButton, NBCard } from '../components/NB';
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
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="flex-row items-center gap-3 px-5 pt-5 pb-3">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Go back"
          className="w-9 h-9 rounded-full bg-surface items-center justify-center active:opacity-75"
        >
          <Text className="font-heading text-base text-charcoal">←</Text>
        </Pressable>
        <Text className="font-heading text-2xl text-charcoal">Profile</Text>
      </View>

      <ScrollView
        contentContainerClassName="px-5 pb-12"
        showsVerticalScrollIndicator={false}
      >
        {/* Identity card */}
        <NBCard className="mb-4 p-6 items-center">
          <View className="mb-3">
            <NBAvatar initials={profile.initials} accent="brand" size="lg" />
          </View>
          <Text className="font-heading text-xl text-charcoal">
            {profile.name}
          </Text>
          <Text className="font-body-medium text-sm text-muted mb-3">
            {profile.school} · {profile.programme}
          </Text>
          <View className="flex-row gap-2">
            {profile.verified && (
              <View className="bg-[#D1FAE5] rounded-full px-3 py-1">
                <Text className="text-[#047857] text-[11px] font-body-bold">
                  ✓ Verified
                </Text>
              </View>
            )}
            <View className="bg-surface rounded-full px-3 py-1">
              <Text className="text-charcoal text-[11px] font-body-bold">
                {profile.level}
              </Text>
            </View>
          </View>
        </NBCard>

        {/* Academic metrics */}
        <View className="flex-row gap-3 mb-4">
          <NBCard className="flex-1 p-4">
            <Text className="font-display text-[26px] leading-8 text-charcoal">
              {gpa.toFixed(2)}
            </Text>
            <Text className="font-body-medium text-xs text-muted mt-0.5">GPA</Text>
          </NBCard>
          <NBCard className="flex-1 p-4">
            <Text className="font-display text-[26px] leading-8 text-charcoal">
              {totalCredits}
            </Text>
            <Text className="font-body-medium text-xs text-muted mt-0.5">
              Credits
            </Text>
          </NBCard>
          <NBCard className="flex-1 p-4">
            <Text className="font-display text-[26px] leading-8 text-charcoal">
              {modules.length}
            </Text>
            <Text className="font-body-medium text-xs text-muted mt-0.5">
              Modules
            </Text>
          </NBCard>
        </View>

        {pendingAssignments > 0 && (
          <View className="flex-row items-center gap-3 bg-[#FFF1F2] rounded-2xl px-4 py-3 mb-4">
            <View className="bg-notif rounded-full w-6 h-6 items-center justify-center">
              <Text className="text-white text-xs font-body-bold">
                {pendingAssignments}
              </Text>
            </View>
            <Text className="font-body-medium text-sm text-[#B91C1C]">
              {pendingAssignments === 1
                ? 'assignment still due this week'
                : 'assignments still due this week'}
            </Text>
          </View>
        )}

        {/* Roommate quiz */}
        <NBCard className="mb-5 p-5">
          <Text className="font-heading text-base text-charcoal mb-3">
            Roommate Quiz
          </Text>
          {QUIZ_ANSWERS.map((answer, index) => (
            <View
              key={answer.label}
              className={`flex-row justify-between py-3 ${
                index < QUIZ_ANSWERS.length - 1 ? 'border-b border-divider' : ''
              }`}
            >
              <Text className="font-body-medium text-[13px] text-muted">
                {answer.label}
              </Text>
              <Text className="font-body-bold text-[13px] text-charcoal">
                {answer.value}
              </Text>
            </View>
          ))}
        </NBCard>

        <NBButton label="Retake Quiz" onPress={() => undefined} variant="ghost" />
      </ScrollView>
    </SafeAreaView>
  );
}
