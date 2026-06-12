import { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBCard, NBInput, NBPopBadge } from '../../components/NB';
import { POP_BG, type PopAccent } from '../../theme/tokens';
import {
  currentWeekday,
  useApp,
  type Assignment,
  type GpaModule,
  type LetterGrade,
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

const GRADE_OPTIONS: readonly LetterGrade[] = ['A', 'B+', 'B', 'C+', 'C', 'D', 'F'];
const CREDIT_OPTIONS: readonly number[] = [1, 2, 3, 4];

const PRESS_SM =
  'active:translate-x-[2px] active:translate-y-[2px] active:shadow-none';

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
          {[module.code, module.title].filter(Boolean).join(' · ')}
        </Text>
        <Text className="font-body-medium text-[11px] text-[#555]">
          {module.credits} {module.credits === 1 ? 'credit' : 'credits'}
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
      className={`flex-row items-center gap-3 bg-white border-4 border-black rounded-none shadow-nb-sm px-3 py-2.5 mb-2.5 ${PRESS_SM}`}
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

// Neubrutalist module-metrics form: course name input, grade button
// matrix, credit stepper row, heavy green submit. Wired straight into
// the global addModule action so the GPA hero re-derives instantly.
function ModuleMetricsForm() {
  const { addModule } = useApp();
  const [courseName, setCourseName] = useState<string>('');
  const [grade, setGrade] = useState<LetterGrade | null>(null);
  const [credits, setCredits] = useState<number>(3);
  const [error, setError] = useState<string | null>(null);

  const submit = () => {
    const title = courseName.trim();
    if (title.length === 0) {
      setError('Enter a course name first.');
      return;
    }
    if (grade === null) {
      setError('Pick a grade from the matrix.');
      return;
    }
    addModule({ title, credits, grade });
    setCourseName('');
    setGrade(null);
    setCredits(3);
    setError(null);
  };

  return (
    <NBCard className="p-4 mb-5">
      <Text className="font-heading text-sm text-black uppercase tracking-wide mb-3">
        Log a Module
      </Text>

      <Text className="font-body-bold text-[11px] text-black uppercase tracking-wide mb-1.5">
        Course Name
      </Text>
      <NBInput
        placeholder="e.g. COE 254 · Digital Systems"
        value={courseName}
        onChangeText={(text) => {
          setCourseName(text);
          if (error !== null) setError(null);
        }}
        className="mb-4"
      />

      <Text className="font-body-bold text-[11px] text-black uppercase tracking-wide mb-1.5">
        Grade
      </Text>
      <View className="flex-row flex-wrap gap-2 mb-4">
        {GRADE_OPTIONS.map((option) => {
          const selected = option === grade;
          return (
            <Pressable
              key={option}
              onPress={() => {
                setGrade(option);
                if (error !== null) setError(null);
              }}
              accessibilityRole="button"
              accessibilityState={selected ? { selected: true } : {}}
              className={`min-w-[44px] items-center px-3 py-2 rounded-none ${
                selected
                  ? `${POP_BG[GRADE_ACCENT[option]]} border-4 border-black shadow-nb-sm`
                  : 'bg-white border-2 border-black'
              } ${PRESS_SM}`}
            >
              <Text className="font-heading text-[13px] text-black">
                {option}
              </Text>
            </Pressable>
          );
        })}
      </View>

      <Text className="font-body-bold text-[11px] text-black uppercase tracking-wide mb-1.5">
        Credits
      </Text>
      <View className="flex-row gap-2 mb-4">
        {CREDIT_OPTIONS.map((option) => {
          const selected = option === credits;
          return (
            <Pressable
              key={option}
              onPress={() => setCredits(option)}
              accessibilityRole="button"
              accessibilityState={selected ? { selected: true } : {}}
              className={`flex-1 items-center py-2 rounded-none ${
                selected
                  ? 'bg-pop-blue border-4 border-black shadow-nb-sm'
                  : 'bg-white border-2 border-black'
              } ${PRESS_SM}`}
            >
              <Text className="font-heading text-[13px] text-black">
                {option}
              </Text>
            </Pressable>
          );
        })}
      </View>

      {error !== null && (
        <View className="bg-pop-red border-2 border-black rounded-none px-3 py-2 mb-3.5">
          <Text className="font-body-bold text-xs text-black">⚠ {error}</Text>
        </View>
      )}

      <Pressable
        onPress={submit}
        accessibilityRole="button"
        className="bg-pop-green border-4 border-black rounded-none shadow-nb items-center py-3.5 active:translate-x-[4px] active:translate-y-[4px] active:shadow-none"
      >
        <Text className="font-heading text-sm text-black uppercase tracking-tight">
          Log Module Metrics
        </Text>
      </Pressable>
    </NBCard>
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

  const today = currentWeekday();
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

        {/* GPA hero — re-derives live whenever a module is logged */}
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

        {/* Module metrics form */}
        <ModuleMetricsForm />

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
