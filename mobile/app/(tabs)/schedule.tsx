import { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { NBCard, NBPopBadge } from '../../components/NB';
import { POP_BG } from '../../theme/tokens';
import {
  useApp,
  type TimetableSlot,
  type Weekday,
} from '../../context/AppContext';

const WEEKDAYS: readonly Weekday[] = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

function SlotCard({ slot }: { slot: TimetableSlot }) {
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
        <View className="flex-row">
          <NBPopBadge label={slot.room} accent={slot.accent} />
        </View>
      </View>
    </View>
  );
}

export default function ScheduleScreen() {
  const { timetable } = useApp();
  const [day, setDay] = useState<Weekday>('Mon');

  const slots = timetable
    .filter((slot) => slot.day === day)
    .sort((a, b) => a.start.localeCompare(b.start));

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

      {/* Day selector */}
      <View className="flex-row gap-2 px-4 mb-4">
        {WEEKDAYS.map((weekday) => {
          const selected = weekday === day;
          return (
            <Pressable
              key={weekday}
              onPress={() => setDay(weekday)}
              accessibilityRole="button"
              accessibilityState={selected ? { selected: true } : {}}
              className={`flex-1 items-center py-2 rounded-none border-4 ${
                selected
                  ? 'bg-pop-blue border-black shadow-nb-sm'
                  : 'bg-white border-black/20'
              } active:translate-x-[2px] active:translate-y-[2px] active:shadow-none`}
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
          slots.map((slot) => <SlotCard key={slot.id} slot={slot} />)
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
