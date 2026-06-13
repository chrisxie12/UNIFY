import { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { NBAvatar, NBButton, NBCard, NBInput } from '../../components/NB';
import {
  currentWeekday,
  useApp,
  type Assignment,
  type GpaModule,
  type LetterGrade,
} from '../../context/AppContext';

const GRADE_COLOR: Record<LetterGrade, string> = {
  A: 'text-[#047857]',
  'B+': 'text-accent',
  B: 'text-accent',
  'C+': 'text-[#B45309]',
  C: 'text-[#B45309]',
  'D+': 'text-[#B91C1C]',
  D: 'text-[#B91C1C]',
  F: 'text-[#B91C1C]',
};

const GRADE_BG: Record<LetterGrade, string> = {
  A: 'bg-[#D1FAE5]',
  'B+': 'bg-[#DBEAFE]',
  B: 'bg-[#DBEAFE]',
  'C+': 'bg-[#FEF3C7]',
  C: 'bg-[#FEF3C7]',
  'D+': 'bg-[#FEE2E2]',
  D: 'bg-[#FEE2E2]',
  F: 'bg-[#FEE2E2]',
};

const GRADE_OPTIONS: readonly LetterGrade[] = ['A', 'B+', 'B', 'C+', 'C', 'D', 'F'];
const CREDIT_OPTIONS: readonly number[] = [1, 2, 3, 4];

function ModuleRow({ module }: { module: GpaModule }) {
  return (
    <View className="flex-row items-center gap-3 py-3 border-b border-divider">
      <View
        className={`${GRADE_BG[module.grade]} w-9 h-9 rounded-full items-center justify-center`}
      >
        <Text className={`${GRADE_COLOR[module.grade]} text-xs font-heading`}>
          {module.grade}
        </Text>
      </View>
      <View className="flex-1">
        <Text className="font-body-bold text-[13px] text-charcoal">
          {[module.code, module.title].filter(Boolean).join(' · ')}
        </Text>
        <Text className="font-body-medium text-[11px] text-muted">
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
      className="flex-row items-center gap-3 bg-white rounded-xl shadow-card px-4 py-3.5 mb-2.5 active:opacity-75"
    >
      <View
        className={`w-5 h-5 rounded-full border-2 items-center justify-center ${
          assignment.completed
            ? 'bg-accent border-accent'
            : 'bg-white border-divider'
        }`}
      >
        {assignment.completed && (
          <Text className="text-white text-[9px] font-body-bold">✓</Text>
        )}
      </View>
      <View className="flex-1">
        <Text
          className={`font-body-bold text-[13px] ${
            assignment.completed ? 'text-muted line-through' : 'text-charcoal'
          }`}
        >
          {assignment.title}
        </Text>
        <Text className="font-body-medium text-[11px] text-muted">
          {assignment.course} · due {assignment.due}
        </Text>
      </View>
      {!assignment.completed && (
        <View className="bg-[#FEE2E2] rounded-full px-2.5 py-0.5">
          <Text className="text-[#B91C1C] text-[10px] font-body-bold">Due</Text>
        </View>
      )}
    </Pressable>
  );
}

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
      setError('Pick a grade.');
      return;
    }
    addModule({ title, credits, grade });
    setCourseName('');
    setGrade(null);
    setCredits(3);
    setError(null);
  };

  return (
    <NBCard className="mb-5 p-5">
      <Text className="font-heading text-base text-charcoal mb-4">
        Log a Module
      </Text>

      <Text className="font-body-bold text-[11px] text-muted uppercase tracking-wide mb-1.5">
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

      <Text className="font-body-bold text-[11px] text-muted uppercase tracking-wide mb-1.5">
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
              className={`min-w-[44px] items-center px-3 py-2 rounded-full ${
                selected ? 'bg-accent' : 'bg-surface'
              } active:opacity-75`}
            >
              <Text
                className={`font-heading text-[13px] ${
                  selected ? 'text-white' : 'text-charcoal'
                }`}
              >
                {option}
              </Text>
            </Pressable>
          );
        })}
      </View>

      <Text className="font-body-bold text-[11px] text-muted uppercase tracking-wide mb-1.5">
        Credits
      </Text>
      <View className="flex-row gap-2 mb-5">
        {CREDIT_OPTIONS.map((option) => {
          const selected = option === credits;
          return (
            <Pressable
              key={option}
              onPress={() => setCredits(option)}
              accessibilityRole="button"
              accessibilityState={selected ? { selected: true } : {}}
              className={`flex-1 items-center py-2.5 rounded-full ${
                selected ? 'bg-charcoal' : 'bg-surface'
              } active:opacity-75`}
            >
              <Text
                className={`font-heading text-[13px] ${
                  selected ? 'text-white' : 'text-charcoal'
                }`}
              >
                {option}
              </Text>
            </Pressable>
          );
        })}
      </View>

      {error !== null && (
        <View className="bg-[#FEE2E2] rounded-lg px-3 py-2 mb-4">
          <Text className="font-body-medium text-xs text-[#B91C1C]">
            {error}
          </Text>
        </View>
      )}

      <NBButton label="Save Module" onPress={submit} variant="accent" />
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
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <ScrollView
        contentContainerClassName="px-5 pb-10"
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View className="flex-row items-center pt-5 pb-6">
          <View className="flex-1">
            <Text className="font-display text-[13px] text-notif uppercase tracking-widest mb-0.5">
              UNIFY
            </Text>
            <Text className="font-heading text-2xl text-charcoal">
              Good morning, {profile.name.split(' ')[0]}
            </Text>
            <Text className="font-body-medium text-sm text-muted">
              {profile.school} · {profile.level}
            </Text>
          </View>
          <Pressable
            onPress={() => router.push('/profile')}
            accessibilityRole="button"
            accessibilityLabel="Open profile"
            className="active:opacity-75"
          >
            <NBAvatar initials={profile.initials} accent="brand" size="md" />
          </Pressable>
        </View>

        {/* GPA hero */}
        <NBCard className="p-5 mb-4">
          <Text className="font-body-medium text-sm text-muted mb-1">
            Cumulative GPA
          </Text>
          <View className="flex-row items-end gap-1.5 mb-2">
            <Text className="font-display text-[48px] leading-[52px] text-charcoal">
              {gpa.toFixed(2)}
            </Text>
            <Text className="font-body-medium text-base text-muted mb-2">
              / 4.00
            </Text>
          </View>
          <Text className="font-body-medium text-xs text-muted">
            {modules.length} modules · {totalCredits} credits this semester
          </Text>
        </NBCard>

        {/* Quick stats */}
        <View className="flex-row gap-3 mb-5">
          <NBCard className="flex-1 p-4">
            <Text className="font-display text-[28px] leading-8 text-[#B91C1C]">
              {pendingAssignments}
            </Text>
            <Text className="font-body-medium text-xs text-muted mt-0.5">
              Due
            </Text>
          </NBCard>
          <NBCard className="flex-1 p-4">
            <Text className="font-display text-[28px] leading-8 text-accent">
              {classesToday}
            </Text>
            <Text className="font-body-medium text-xs text-muted mt-0.5">
              Classes today
            </Text>
          </NBCard>
        </View>

        {/* Module form */}
        <ModuleMetricsForm />

        {/* Modules */}
        <Text className="font-heading text-base text-charcoal mb-3">
          Modules
        </Text>
        <NBCard className="px-4 mb-5">
          {modules.map((module) => (
            <ModuleRow key={module.id} module={module} />
          ))}
        </NBCard>

        {/* Assignments */}
        <Text className="font-heading text-base text-charcoal mb-3">
          Assignments
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
