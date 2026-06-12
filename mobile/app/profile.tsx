import { ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { NBAvatar, NBBadge, NBButton, NBCard } from '../components/NB';

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
  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <ScrollView contentContainerClassName="p-4 pb-12">
        <Text className="font-display text-[26px] text-black uppercase tracking-tight mb-4">
          My Profile
        </Text>

        <NBCard className="mb-4 p-4 items-center">
          <View className="mb-3">
            <NBAvatar initials="KE" accent="brand" size="lg" />
          </View>
          <Text className="font-heading text-xl text-black">Kwame E.</Text>
          <Text className="font-body-medium text-[13px] text-[#555] mb-2.5">
            KNUST · BSc Computer Engineering
          </Text>
          <View className="flex-row gap-2">
            <NBBadge label="✓ Verified" accent="verify" />
            <NBBadge label="Level 100" accent="action" />
          </View>
        </NBCard>

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
