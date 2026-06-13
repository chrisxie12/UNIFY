import { useMemo, useState } from 'react';
import { Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Avatar, Badge, Card, Chip } from '../../components/UI';
import { COLORS } from '../../theme/tokens';

const PROGRAM_FILTERS = ['All', 'Engineering', 'Science', 'Business', 'Arts', 'Law'];

const STUDENTS = [
  { id: 'u1', name: 'Ama Serwaa',    school: 'KNUST', prog: 'Computer Science',  level: '200', matchPct: 94, initials: 'AS', color: 'orange', verified: true  },
  { id: 'u2', name: 'Michael Agyei', school: 'KNUST', prog: 'Electrical Eng.',   level: '100', matchPct: 88, initials: 'MA', color: 'blue',   verified: true  },
  { id: 'u3', name: 'Efua Boateng',  school: 'UCC',   prog: 'Civil Engineering', level: '200', matchPct: 82, initials: 'EB', color: 'green',  verified: false },
  { id: 'u4', name: 'Yaw Mensah',    school: 'UPSA',  prog: 'Business Admin',    level: '100', matchPct: 79, initials: 'YM', color: 'red',    verified: true  },
  { id: 'u5', name: 'Adwoa Kyei',    school: 'UG',    prog: 'Law',               level: '300', matchPct: 75, initials: 'AK', color: 'purple', verified: true  },
  { id: 'u6', name: 'Kofi Asante',   school: 'KNUST', prog: 'Mechanical Eng.',   level: '100', matchPct: 73, initials: 'KA', color: 'blue',   verified: false },
  { id: 'u7', name: 'Abena Frimpong',school: 'UG',    prog: 'Economics',         level: '200', matchPct: 70, initials: 'AF', color: 'orange', verified: true  },
  { id: 'u8', name: 'Kweku Amponsah',school: 'GIMPA', prog: 'MBA',               level: '100', matchPct: 66, initials: 'KA', color: 'green',  verified: false },
];

const HUBS = [
  { id: 'knust', name: 'KNUST Hub',      emoji: '🎓', school: 'KNUST', members: 2340, category: 'University', desc: 'Official hub for all KNUST students.' },
  { id: 'ug',    name: 'UG Legon Hub',   emoji: '🦁', school: 'UG',    members: 3100, category: 'University', desc: 'Connect with fellow Legonites.' },
  { id: 'cs',    name: 'CS Students',    emoji: '💻', school: 'KNUST', members: 510,  category: 'Department', desc: 'CS and Engineering — hackathons, internships, code talk.' },
  { id: 'law',   name: 'Law Society',    emoji: '⚖️', school: 'UG',    members: 290,  category: 'Department', desc: 'Moot court, internships, exam prep.' },
  { id: 'hostel',name: 'Hostel Hunters', emoji: '🏠', school: 'All',   members: 1450, category: 'Lifestyle',  desc: 'Find the best off-campus deals. Tips, reviews, listings.' },
];

const HUB_FILTERS = ['All', 'University', 'Department', 'Lifestyle'];

type ViewMode = 'People' | 'Hubs';

export default function ExploreScreen() {
  const router = useRouter();
  const [query, setQuery]       = useState('');
  const [filter, setFilter]     = useState('All');
  const [hubFilter, setHubFilter] = useState('All');
  const [focused, setFocused]   = useState(false);
  const [viewMode, setViewMode] = useState<ViewMode>('People');

  const students = useMemo(() => {
    const q = query.toLowerCase();
    return STUDENTS.filter((s) => {
      const matchQ = !q || s.name.toLowerCase().includes(q) || s.school.toLowerCase().includes(q) || s.prog.toLowerCase().includes(q);
      const matchF = filter === 'All' || s.prog.toLowerCase().includes(filter.toLowerCase());
      return matchQ && matchF;
    });
  }, [query, filter]);

  const hubs = useMemo(() => {
    const q = query.toLowerCase();
    return HUBS.filter((h) => {
      const matchQ = !q || h.name.toLowerCase().includes(q) || h.school.toLowerCase().includes(q);
      const matchF = hubFilter === 'All' || h.category === hubFilter;
      return matchQ && matchF;
    });
  }, [query, hubFilter]);

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
            placeholder={viewMode === 'People' ? 'Search name, school, programme…' : 'Search hubs…'}
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

      {/* People | Hubs toggle */}
      <View className="flex-row mx-5 mb-3 bg-surface rounded-2xl p-1">
        {(['People', 'Hubs'] as ViewMode[]).map((m) => (
          <Pressable
            key={m}
            onPress={() => { setViewMode(m); setQuery(''); setFilter('All'); setHubFilter('All'); }}
            className={`flex-1 py-2.5 rounded-xl items-center ${viewMode === m ? 'bg-white shadow-sm' : ''}`}
          >
            <Text className={`font-body-semi text-sm ${viewMode === m ? 'text-primary' : 'text-tertxt'}`}>
              {m === 'People' ? `👤 People` : `🏫 Hubs`}
            </Text>
          </Pressable>
        ))}
      </View>

      {/* Filter chips */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: 20, gap: 8, paddingBottom: 4 }}
        className="mb-3 flex-grow-0"
      >
        {(viewMode === 'People' ? PROGRAM_FILTERS : HUB_FILTERS).map((f) => (
          <Chip
            key={f}
            label={f}
            selected={(viewMode === 'People' ? filter : hubFilter) === f}
            onPress={() => viewMode === 'People' ? setFilter(f) : setHubFilter(f)}
          />
        ))}
      </ScrollView>

      {/* Results */}
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
      >
        {viewMode === 'People' ? (
          <>
            <Text className="font-body text-xs text-tertxt mb-3 px-1">
              {students.length} student{students.length !== 1 ? 's' : ''} found
            </Text>
            <View className="flex-row flex-wrap gap-3">
              {students.map((s) => (
                <Pressable
                  key={s.id}
                  onPress={() => router.push(`/user/${s.id}` as any)}
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
          </>
        ) : (
          <>
            <Text className="font-body text-xs text-tertxt mb-3 px-1">
              {hubs.length} hub{hubs.length !== 1 ? 's' : ''} found
            </Text>
            <View className="gap-3">
              {hubs.map((h) => (
                <Pressable
                  key={h.id}
                  onPress={() => router.push(`/hub/${h.id}` as any)}
                  className="active:opacity-70"
                >
                  <Card className="p-4 flex-row items-center gap-3">
                    <View className="w-12 h-12 bg-[#EFF6FF] rounded-2xl items-center justify-center">
                      <Text style={{ fontSize: 22 }}>{h.emoji}</Text>
                    </View>
                    <View className="flex-1">
                      <View className="flex-row items-center gap-2 mb-0.5">
                        <Text className="font-heading text-sm text-primary">{h.name}</Text>
                        <Badge label={h.category} color="blue" />
                      </View>
                      <Text className="font-body text-xs text-secondary" numberOfLines={1}>{h.desc}</Text>
                      <Text className="font-body text-[10px] text-tertxt mt-0.5">
                        {h.members.toLocaleString()} members · {h.school}
                      </Text>
                    </View>
                    <Text className="text-tertxt text-base">›</Text>
                  </Card>
                </Pressable>
              ))}
            </View>
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
