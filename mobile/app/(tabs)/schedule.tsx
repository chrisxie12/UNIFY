import { useMemo, useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { NBCard, NBPopBadge } from '../../components/NB';
import { POP_BG } from '../../theme/tokens';
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

// Two slots conflict when their intervals overlap, or when they start
// inside the same hour window (< 60 min apart) — both make the second
// class unreachable in practice.
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
    <View className="flex-row bg-white border-4 border-black rounded-none shadow-nb mb-3">
      <View
        className={`${POP_BG[slot.accent]} w-[76px] items-center justify-center border-r-4 border-black py-3`}
      >
        <Text className="font-heading text-[13px] text-black">{slot.start}</Text>
        <Text className="font-body-bold text-[10px] text-black">—</Text>
        <Text className="font-heading text-[13px] text-black">{slot.end}</Text>
      </View>
      <View className="flex-1 p-3 justify-center">
        <Text className="font-body-bold text-[13.5px] text-black mb-1.5">
          {slot.course}
        </Text>
        <View className="flex-row gap-2">
          <NBPopBadge label={slot.room} accent={slot.accent} />
          {conflicted && <NBPopBadge label="⚠ Conflict" accent="red" />}
        </View>
      </View>
    </View>
  );
}

function ConflictWarning({ conflicts }: { conflicts: readonly ConflictPair[] }) {
  return (
    <View className="bg-pop-red border-4 border-black rounded-none shadow-nb p-3.5 mb-4">
      <Text className="font-display text-[15px] text-black uppercase tracking-tight mb-1.5">
        ⚠ Schedule Overlap Detected
      </Text>
      {conflicts.map((pair) => (
        <Text
          key={`${pair.a.id}-${pair.b.id}`}
          className="font-body-bold text-xs text-black leading-[18px]"
        >
          {pair.a.course} ({pair.a.start}–{pair.a.end}) clashes with{' '}
          {pair.b.course} ({pair.b.start}–{pair.b.end})
        </Text>
      ))}
      <Text className="font-body-medium text-[11px] text-black mt-1.5">
        Move one of these slots — you can't be in two rooms at once.
      </Text>
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
    <SafeAreaView className="flex-1 bg-parchment" edges={['top']}>
      <View className="px-4 pt-2 pb-3">
        <Text className="font-display text-[26px] text-black uppercase tracking-tight">
          Timetable
        </Text>
        <Text className="font-body-medium text-xs text-[#555]">
          Semester 2 · Week 8
        </Text>
      </View>

      {/* Day selector: active day = aggressive blue block, the rest stay
          plain text so the focused slab dominates the strip */}
      <View className="flex-row gap-2 px-4 mb-4">
        {WEEKDAYS.map((weekday) => {
          const selected = weekday === day;
          return (
            <Pressable
              key={weekday}
              onPress={() => setDay(weekday)}
              accessibilityRole="button"
              accessibilityState={selected ? { selected: true } : {}}
              className={`flex-1 items-center py-2.5 rounded-none ${
                selected
                  ? 'bg-pop-blue border-4 border-black shadow-nb active:translate-x-[2px] active:translate-y-[2px] active:shadow-none'
                  : 'border-4 border-transparent'
              }`}
            >
              <Text
                className={`font-heading text-xs uppercase ${
                  selected ? 'text-black' : 'text-[#555]'
                }`}
              >
                {weekday}
              </Text>
            </Pressable>
          );
        })}
      </View>

      <ScrollView contentContainerClassName="px-4 pb-8">
        {conflicts.length > 0 && <ConflictWarning conflicts={conflicts} />}

        {slots.length === 0 ? (
          <NBCard className="p-5 items-center">
            <Text className="font-heading text-base text-black uppercase mb-1">
              No Classes
            </Text>
            <Text className="font-body-medium text-[13px] text-[#555]">
              Free day — library or touch grass 📚
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
