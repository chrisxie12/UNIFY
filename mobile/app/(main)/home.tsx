import { ScrollView, Text, View, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Card, PressCard, Avatar, Badge, SectionHeader } from '../../components/UI';
import { useAppStore } from '../../store/useAppStore';

const SUGGESTIONS = [
  { id: 's1', name: 'Ama Serwaa',    school: 'KNUST',    programme: 'BSc Computer Sci',    level: 'Level 200', matchPct: 94, initials: 'AS', color: 'orange', sleep: 'Night owl', clean: 'Very tidy'  },
  { id: 's2', name: 'Michael Agyei', school: 'KNUST',    programme: 'BSc Elect. Eng',       level: 'Level 100', matchPct: 88, initials: 'MA', color: 'blue',   sleep: 'Night owl', clean: 'Moderate'   },
  { id: 's3', name: 'Efua Boateng',  school: 'KNUST',    programme: 'BSc Civil Eng',        level: 'Level 200', matchPct: 82, initials: 'EB', color: 'green',  sleep: 'Early bird', clean: 'Very tidy' },
];

const HUB_POSTS = [
  { id: 'h1', hub: 'KNUST', title: 'Evandy hostel allocation opens Monday',    time: '2h', type: 'announcement' as const },
  { id: 'h2', hub: 'UG',    title: 'Study group for MATH 101 — 4 spots left', time: '5h', type: 'thread' as const      },
];

export default function HomeScreen() {
  const router  = useRouter();
  const profile = useAppStore((s) => s.profile);
  const name    = profile.displayName || 'there';

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Greeting */}
        <View className="pt-5 pb-4">
          <Text className="font-body text-sm text-secondary">Good morning,</Text>
          <Text className="font-display text-[28px] leading-8 text-primary">
            {name} 👋
          </Text>
        </View>

        {/* Quick stats row */}
        <View className="flex-row gap-3 mb-6">
          <Card className="flex-1 p-4">
            <Text className="font-display text-2xl text-primary">3</Text>
            <Text className="font-body text-xs text-secondary mt-0.5">New matches</Text>
          </Card>
          <Card className="flex-1 p-4">
            <Text className="font-display text-2xl text-blue">2</Text>
            <Text className="font-body text-xs text-secondary mt-0.5">Unread chats</Text>
          </Card>
          <Card className="flex-1 p-4">
            <Text className="font-display text-2xl text-orange">12</Text>
            <Text className="font-body text-xs text-secondary mt-0.5">Hub posts</Text>
          </Card>
        </View>

        {/* Roommate suggestions */}
        <SectionHeader
          title="Suggested roommates"
          action="See all"
          onAction={() => router.push('/(main)/match')}
        />
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{ gap: 12 }}
          className="mb-6"
        >
          {SUGGESTIONS.map((s) => (
            <PressCard
              key={s.id}
              onPress={() => router.push('/(main)/match')}
              className="w-48 p-4"
            >
              <View className="items-center mb-3">
                <Avatar initials={s.initials} color={s.color} size="lg" />
                <View className="mt-2 bg-[#EFF6FF] rounded-full px-3 py-0.5">
                  <Text className="text-blue text-[11px] font-body-semi">
                    {s.matchPct}% match
                  </Text>
                </View>
              </View>
              <Text className="font-heading text-sm text-primary text-center" numberOfLines={1}>
                {s.name}
              </Text>
              <Text className="font-body text-[11px] text-secondary text-center" numberOfLines={1}>
                {s.school}
              </Text>
              <View className="flex-row gap-1 mt-2 flex-wrap justify-center">
                <Badge label={s.sleep} color="default" />
                <Badge label={s.clean} color="default" />
              </View>
            </PressCard>
          ))}
        </ScrollView>

        {/* Hub feed */}
        <SectionHeader title="Campus hub" action="All hubs" />
        <View className="gap-3">
          {HUB_POSTS.map((p) => (
            <PressCard
              key={p.id}
              onPress={() => {}}
              className="p-4 flex-row items-start gap-3"
            >
              <View className="bg-[#EFF6FF] rounded-xl w-10 h-10 items-center justify-center">
                <Text className="text-blue text-lg">
                  {p.type === 'announcement' ? '📢' : '💬'}
                </Text>
              </View>
              <View className="flex-1">
                <View className="flex-row items-center gap-2 mb-1">
                  <Badge label={p.hub} color="blue" />
                  <Text className="font-body text-[10px] text-tertxt">{p.time}</Text>
                </View>
                <Text className="font-body-medium text-sm text-primary leading-5">
                  {p.title}
                </Text>
              </View>
            </PressCard>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
