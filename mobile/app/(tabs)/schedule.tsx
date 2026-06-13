import { useMemo, useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { NBCard } from '../../components/NB';
import { SLOT_BG, SLOT_FG } from '../../theme/tokens';
import {
  currentWeekday,
  useApp,
  type TimetableSlot,
  type Weekday,
} from '../../context/AppContext';

const WEEKDAYS: readonly Weekday[] = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

interface ConflictPair {
  readonly a: TimetableSlot;
  readonly b: TimetableSlot;
}

function toMinutes(time: string): number {
  const [hours = 0, minutes = 0] = time.split(':').map(Number);
  return hours * 60 + minutes;
}

function findConflicts(slots: readonly TimetableSlot[]): ConflictPair[] {
  const pairs: ConflictPair[] = [];
  for (let i = 0; i < slots.length; i += 1) {
    for (let j = i + 1; j < slots.length; j += 1) {
      const a = slots[i];
      const b = slots[j];
      const overlap =
        toMinutes(a.start) < toMinutes(b.end) &&
        toMinutes(b.start) < toMinutes(a.end);
      const sameHourWindow =
        Math.abs(toMinutes(a.start) - toMinutes(b.start)) < 60;
      if (overlap || sameHourWindow) {
        pairs.push({ a, b });
      }
    }
  }
  return pairs;
}

interface SlotCardProps {
  slot: TimetableSlot;
  conflicted: boolean;
}

function SlotCard({ slot, conflicted }: SlotCardProps) {
  return (
    <NBCard className="flex-row mb-3 overflow-hidden">
      {/* Coloured time column */}
      <View
        className={`${SLOT_BG[slot.accent]} w-[4px] rounded-l-2xl`}
      />
      <View
        className={`${SLOT_BG[slot.accent]} w-[72px] items-center justify-center py-4`}
      >
        <Text className={`${SLOT_FG[slot.accent]} font-heading text-[12px]`}>
          {slot.start}
        </Text>
        <Text className={`${SLOT_FG[slot.accent]} font-body-medium text-[10px] my-0.5`}>
          –
        </Text>
        <Text className={`${SLOT_FG[slot.accent]} font-heading text-[12px]`}>
          {slot.end}
        </Text>
      </View>
      <View className="flex-1 px-4 py-4 justify-center">
        <Text className="font-body-bold text-[13.5px] text-charcoal mb-1">
          {slot.course}
        </Text>
        <View className="flex-row items-center gap-2">
          <Text className="font-body-medium text-xs text-muted">{slot.room}</Text>
          {conflicted && (
            <View className="bg-[#FEE2E2] rounded-full px-2 py-0.5">
              <Text className="text-[#B91C1C] text-[10px] font-body-bold">
                ⚠ Conflict
              </Text>
            </View>
          )}
        </View>
      </View>
    </NBCard>
  );
}

function ConflictAlert({ conflicts }: { conflicts: readonly ConflictPair[] }) {
  return (
    <View className="bg-[#FFF1F2] rounded-2xl p-4 mb-4 shadow-card">
      <Text className="font-heading text-sm text-[#B91C1C] mb-1.5">
        Schedule Conflict Detected
      </Text>
      {conflicts.map((pair) => (
        <Text
          key={`${pair.a.id}-${pair.b.id}`}
          className="font-body-medium text-xs text-[#B91C1C] leading-5"
        >
          {pair.a.course} ({pair.a.start}–{pair.a.end}) overlaps with{' '}
          {pair.b.course} ({pair.b.start}–{pair.b.end})
        </Text>
      ))}
    </View>
  );
}

export default function ScheduleScreen() {
  const { timetable } = useApp();
  const [day, setDay] = useState<Weekday>(() => currentWeekday() ?? 'Mon');

  const slots = useMemo(
    () =>
      timetable
        .filter((slot) => slot.day === day)
        .sort((a, b) => toMinutes(a.start) - toMinutes(b.start)),
    [timetable, day],
  );

  const conflicts = useMemo(() => findConflicts(slots), [slots]);
  const conflictedIds = useMemo(
    () => new Set(conflicts.flatMap((pair) => [pair.a.id, pair.b.id])),
    [conflicts],
  );

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="px-5 pt-5 pb-4">
        <Text className="font-display text-[13px] text-notif uppercase tracking-widest mb-0.5">
          UNIFY
        </Text>
        <Text className="font-heading text-2xl text-charcoal">Timetable</Text>
        <Text className="font-body-medium text-sm text-muted">
          Semester 2 · Week 8
        </Text>
      </View>

      {/* Day selector */}
      <View className="flex-row gap-1.5 px-5 mb-5">
        {WEEKDAYS.map((weekday) => {
          const selected = weekday === day;
          return (
            <Pressable
              key={weekday}
              onPress={() => setDay(weekday)}
              accessibilityRole="button"
              accessibilityState={selected ? { selected: true } : {}}
              className={`flex-1 items-center py-2.5 rounded-full ${
                selected ? 'bg-accent' : 'bg-surface'
              } active:opacity-75`}
            >
              <Text
                className={`font-heading text-[11px] ${
                  selected ? 'text-white' : 'text-muted'
                }`}
              >
                {weekday}
              </Text>
            </Pressable>
          );
        })}
      </View>

      <ScrollView
        contentContainerClassName="px-5 pb-10"
        showsVerticalScrollIndicator={false}
      >
        {conflicts.length > 0 && <ConflictAlert conflicts={conflicts} />}

        {slots.length === 0 ? (
          <NBCard className="p-6 items-center">
            <Text className="font-heading text-base text-charcoal mb-1">
              No Classes
            </Text>
            <Text className="font-body-medium text-sm text-muted">
              Free day — use it well 📚
            </Text>
          </NBCard>
        ) : (
          slots.map((slot) => (
            <SlotCard
              key={slot.id}
              slot={slot}
              conflicted={conflictedIds.has(slot.id)}
            />
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
