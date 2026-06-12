import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBCard, NBPopBadge } from '../../components/NB';
import { POP_BG, type PopAccent } from '../../theme/tokens';
import {
  useApp,
  type Assignment,
  type GpaModule,
  type LetterGrade,
  type Weekday,
} from '../../context/AppContext';

const GRADE_ACCENT: Record<LetterGrade, PopAccent> = {
  A: 'green',
  'B+': 'blue',
  B: 'blue',
  'C+': 'yellow',
  C: 'yellow',
  'D+': 'red',
  D: 'red',
  F: 'red',
};

// getDay(): 0 = Sunday … 6 = Saturday; weekends have no timetable.
const WEEKDAY_BY_GETDAY: readonly (Weekday | null)[] = [
  null,
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  null,
];

function ModuleRow({ module }: { module: GpaModule }) {
  return (
    <View className="flex-row items-center gap-3 py-2 border-b-2 border-black/10">
      <View
        className={`${POP_BG[GRADE_ACCENT[module.grade]]} w-9 h-9 border-2 border-black items-center justify-center`}
      >
        <Text className="font-heading text-xs text-black">{module.grade}</Text>
      </View>
      <View className="flex-1">
        <Text className="font-body-bold text-[13px] text-black">
          {module.code} · {module.title}
        </Text>
        <Text className="font-body-medium text-[11px] text-[#555]">
          {module.credits} credits
        </Text>
      </View>
    </View>
  );
}

interface AssignmentRowProps {
  assignment: Assignment;
  onToggle: () => void;
}

function AssignmentRow({ assignment, onToggle }: AssignmentRowProps) {
  return (
    <Pressable
      onPress={onToggle}
      className="flex-row items-center gap-3 bg-white border-4 border-black rounded-none shadow-nb-sm px-3 py-2.5 mb-2.5 active:translate-x-[2px] active:translate-y-[2px] active:shadow-none"
    >
      <View
        className={`w-6 h-6 border-2 border-black items-center justify-center ${
          assignment.completed ? 'bg-pop-green' : 'bg-white'
        }`}
      >
        {assignment.completed && (
          <Text className="font-body-bold text-xs text-black">✓</Text>
        )}
      </View>
      <View className="flex-1">
        <Text
          className={`font-body-bold text-[13px] ${
            assignment.completed ? 'text-[#555] line-through' : 'text-black'
          }`}
        >
          {assignment.title}
        </Text>
        <Text className="font-body-medium text-[11px] text-[#555]">
          {assignment.course} · due {assignment.due}
        </Text>
      </View>
      {!assignment.completed && <NBPopBadge label="Due" accent="red" />}
    </Pressable>
  );
}

export default function DashboardScreen() {
  const router = useRouter();
  const {
    modules,
    assignments,
    timetable,
    profile,
    gpa,
    totalCredits,
    pendingAssignments,
    toggleAssignment,
  } = useApp();

  const today = WEEKDAY_BY_GETDAY[new Date().getDay()] ?? null;
  const classesToday =
    today === null ? 0 : timetable.filter((slot) => slot.day === today).length;

  return (
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <ScrollView contentContainerClassName="p-4 pb-8">
        {/* Header */}
        <View className="flex-row items-center mb-4">
          <View>
            <Text className="font-display text-[26px] text-black uppercase tracking-tight">
              Dashboard
            </Text>
            <Text className="font-body-medium text-xs text-[#555]">
              {profile.school} · {profile.level}
            </Text>
          </View>
          <Pressable
            onPress={() => router.push('/profile')}
            className="ml-auto"
            accessibilityRole="button"
            accessibilityLabel="Open profile"
          >
            <NBAvatar initials={profile.initials} accent="brand" />
          </Pressable>
        </View>

        {/* GPA hero */}
        <View className="bg-pop-yellow border-4 border-black rounded-none shadow-nb p-4 mb-4">
          <Text className="font-heading text-xs text-black uppercase tracking-wide mb-1">
            Cumulative GPA
          </Text>
          <View className="flex-row items-end gap-2">
            <Text className="font-display text-[44px] leading-[48px] text-black">
              {gpa.toFixed(2)}
            </Text>
            <Text className="font-body-bold text-sm text-black mb-1.5">
              / 4.00
            </Text>
          </View>
          <Text className="font-body-medium text-xs text-black mt-1">
            {modules.length} modules · {totalCredits} credits this semester
          </Text>
        </View>

        {/* Quick stats */}
        <View className="flex-row gap-3 mb-5">
          <View className="flex-1 bg-pop-red border-4 border-black rounded-none shadow-nb p-3">
            <Text className="font-display text-[28px] leading-8 text-black">
              {pendingAssignments}
            </Text>
            <Text className="font-heading text-[10px] text-black uppercase tracking-wide">
              Assignments Due
            </Text>
          </View>
          <View className="flex-1 bg-pop-blue border-4 border-black rounded-none shadow-nb p-3">
            <Text className="font-display text-[28px] leading-8 text-black">
              {classesToday}
            </Text>
            <Text className="font-heading text-[10px] text-black uppercase tracking-wide">
              Classes Today
            </Text>
          </View>
        </View>

        {/* Modules */}
        <Text className="font-heading text-sm text-black uppercase tracking-wide mb-2.5">
          Current Modules
        </Text>
        <NBCard className="px-3.5 py-1.5 mb-5">
          {modules.map((module) => (
            <ModuleRow key={module.id} module={module} />
          ))}
        </NBCard>

        {/* Assignments */}
        <Text className="font-heading text-sm text-black uppercase tracking-wide mb-2.5">
          Assignment Schedule
        </Text>
        {assignments.map((assignment) => (
          <AssignmentRow
            key={assignment.id}
            assignment={assignment}
            onToggle={() => toggleAssignment(assignment.id)}
          />
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}
