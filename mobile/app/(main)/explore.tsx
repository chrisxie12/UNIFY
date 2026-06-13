import { useMemo, useState } from 'react';
import { Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Avatar, Badge, Card, Chip } from '../../components/UI';
import { COLORS } from '../../theme/tokens';

const FILTERS = ['All', 'Engineering', 'Science', 'Business', 'Arts', 'Law'];

const STUDENTS = [
  { id: 'u1', name: 'Ama Serwaa',       school: 'KNUST', prog: 'Computer Science',   level: '200', matchPct: 94, initials: 'AS', color: 'orange', verified: true  },
  { id: 'u2', name: 'Michael Agyei',     school: 'KNUST', prog: 'Electrical Eng.',    level: '100', matchPct: 88, initials: 'MA', color: 'blue',   verified: true  },
  { id: 'u3', name: 'Efua Boateng',      school: 'UCC',   prog: 'Civil Engineering',  level: '200', matchPct: 82, initials: 'EB', color: 'green',  verified: false },
  { id: 'u4', name: 'Yaw Mensah',        school: 'UPSA',  prog: 'Business Admin',     level: '100', matchPct: 79, initials: 'YM', color: 'red',    verified: true  },
  { id: 'u5', name: 'Adwoa Kyei',        school: 'UG',    prog: 'Law',                level: '300', matchPct: 75, initials: 'AK', color: 'purple', verified: true  },
  { id: 'u6', name: 'Kofi Asante',       school: 'KNUST', prog: 'Mechanical Eng.',    level: '100', matchPct: 73, initials: 'KA', color: 'blue',   verified: false },
  { id: 'u7', name: 'Abena Frimpong',    school: 'UG',    prog: 'Economics',          level: '200', matchPct: 70, initials: 'AF', color: 'orange', verified: true  },
  { id: 'u8', name: 'Kweku Amponsah',    school: 'GIMPA', prog: 'MBA',                level: '100', matchPct: 66, initials: 'KA', color: 'green',  verified: false },
];

export default function ExploreScreen() {
  const router = useRouter();
  const [query, setQuery]   = useState('');
  const [filter, setFilter] = useState('All');
  const [focused, setFocused] = useState(false);

  const results = useMemo(() => {
    return STUDENTS.filter((s) => {
      const q = query.toLowerCase();
      const matchesQ = !q || s.name.toLowerCase().includes(q) || s.school.toLowerCase().includes(q) || s.prog.toLowerCase().includes(q);
      const matchesF = filter === 'All' || s.prog.toLowerCase().includes(filter.toLowerCase());
      return matchesQ && matchesF;
    });
  }, [query, filter]);

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Header */}
      <View className="px-5 pt-5 pb-3">
        <Text className="font-display text-2xl text-primary mb-4">Explore</Text>

        {/* Search */}
        <View
          className={`flex-row items-center bg-surface rounded-2xl border h-12 px-4 gap-3 ${
            focused ? 'border-blue' : 'border-border'
          }`}
        >
          <Text className="text-tertxt">🔍</Text>
          <TextInput
            placeholder="Search name, school, programme…"
            placeholderTextColor={COLORS.tertxt}
            value={query}
            onChangeText={setQuery}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            className="flex-1 font-body text-sm text-primary"
          />
          {query.length > 0 && (
            <Pressable onPress={() => setQuery('')} hitSlop={8}>
              <Text className="text-tertxt text-base">✕</Text>
            </Pressable>
          )}
        </View>
      </View>

      {/* Filter chips */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 20, gap: 8, paddingBottom: 4 }}
        className="mb-3"
      >
        {FILTERS.map((f) => (
          <Chip key={f} label={f} selected={filter === f} onPress={() => setFilter(f)} />
        ))}
      </ScrollView>

      {/* Results grid */}
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
      >
        <Text className="font-body text-xs text-tertxt mb-3 px-1">
          {results.length} student{results.length !== 1 ? 's' : ''} found
        </Text>
        <View className="flex-row flex-wrap gap-3">
          {results.map((s) => (
            <Pressable
              key={s.id}
              onPress={() => {}}
              className="w-[47%] active:opacity-70"
            >
              <Card className="p-4 items-center">
                <Avatar initials={s.initials} color={s.color} size="lg" />
                {s.verified && (
                  <View className="absolute top-3 right-3 bg-[#ECFDF5] rounded-full px-1.5 py-0.5">
                    <Text className="text-green text-[9px] font-body-semi">✓</Text>
                  </View>
                )}
                <View className="mt-2 bg-[#EFF6FF] rounded-full px-2.5 py-0.5 mb-1">
                  <Text className="text-blue text-[10px] font-body-semi">
                    {s.matchPct}% match
                  </Text>
                </View>
                <Text className="font-heading text-sm text-primary text-center" numberOfLines={1}>
                  {s.name}
                </Text>
                <Text className="font-body text-[11px] text-secondary text-center mt-0.5" numberOfLines={1}>
                  {s.school} · L{s.level}
                </Text>
                <Text className="font-body text-[10px] text-tertxt text-center mt-0.5" numberOfLines={2}>
                  {s.prog}
                </Text>
              </Card>
            </Pressable>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
