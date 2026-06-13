import { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { Card, PressCard, Avatar, Badge, SectionHeader } from '../../components/UI';
import { useAppStore } from '../../store/useAppStore';

const SUGGESTIONS = [
  { id: 's1', name: 'Ama Serwaa',    school: 'KNUST', programme: 'BSc Computer Sci',  level: 'Level 200', matchPct: 94, initials: 'AS', color: 'orange', sleep: 'Night owl', clean: 'Very tidy'  },
  { id: 's2', name: 'Michael Agyei', school: 'KNUST', programme: 'BSc Elect. Eng',     level: 'Level 100', matchPct: 88, initials: 'MA', color: 'blue',   sleep: 'Night owl', clean: 'Moderate'   },
  { id: 's3', name: 'Efua Boateng',  school: 'UCC',   programme: 'BSc Civil Eng',      level: 'Level 200', matchPct: 82, initials: 'EB', color: 'green',  sleep: 'Early bird', clean: 'Very tidy' },
];

const HUB_POSTS = [
  { id: 'h1', hub: 'KNUST', hubId: 'knust', title: 'Evandy hostel allocation opens Monday',    time: '2h', type: 'announcement' as const },
  { id: 'h2', hub: 'UG',    hubId: 'ug',    title: 'Study group for MATH 101 — 4 spots left', time: '5h', type: 'thread' as const      },
];

export default function HomeScreen() {
  const router  = useRouter();
  const profile = useAppStore((s) => s.profile);
  const name    = profile.displayName || 'there';

  const [sentRequests, setSentRequests] = useState<string[]>([]);
  const [passedCards, setPassedCards]   = useState<string[]>([]);

  const visibleSuggestions = SUGGESTIONS.filter((s) => !passedCards.includes(s.id));

  function handleRequest(id: string) {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSentRequests((r) => [...r, id]);
  }

  function handlePass(id: string) {
    Haptics.selectionAsync();
    setPassedCards((p) => [...p, id]);
  }

  const profileIncomplete = !profile.fullName || !profile.school;

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

        {/* Quick action — complete profile */}
        {profileIncomplete && (
          <Pressable
            onPress={() => router.push('/onboarding')}
            className="bg-[#EFF6FF] rounded-2xl px-4 py-3 mb-5 flex-row items-center gap-3 active:opacity-80"
          >
            <Text style={{ fontSize: 24 }}>✏️</Text>
            <View className="flex-1">
              <Text className="font-body-semi text-sm text-blue">Complete your profile</Text>
              <Text className="font-body text-xs text-secondary">Add your school and habits to start matching.</Text>
            </View>
            <Text className="text-blue text-base">›</Text>
          </Pressable>
        )}

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
        {visibleSuggestions.length === 0 ? (
          <View className="mb-6 bg-surface rounded-2xl py-6 items-center">
            <Text className="font-body text-sm text-tertxt">No more suggestions right now.</Text>
          </View>
        ) : (
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 12 }}
            className="mb-6"
          >
            {visibleSuggestions.map((s) => {
              const requested = sentRequests.includes(s.id);
              return (
                <Pressable
                  key={s.id}
                  onPress={() => router.push(`/user/${s.id}` as any)}
                  className="w-48 active:opacity-90"
                >
                  <Card className="p-4">
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
                    {/* Action buttons */}
                    <View className="flex-row gap-2 mt-3">
                      <Pressable
                        onPress={(e) => { e.stopPropagation(); handlePass(s.id); }}
                        className="flex-1 py-2 rounded-full border border-border items-center active:opacity-70"
                      >
                        <Text className="text-red text-xs font-body-semi">Pass</Text>
                      </Pressable>
                      <Pressable
                        onPress={(e) => { e.stopPropagation(); handleRequest(s.id); }}
                        disabled={requested}
                        className={`flex-1 py-2 rounded-full items-center active:opacity-80 ${requested ? 'bg-[#ECFDF5]' : 'bg-blue'}`}
                      >
                        <Text className={`text-xs font-body-semi ${requested ? 'text-green' : 'text-white'}`}>
                          {requested ? '✓ Sent' : 'Request'}
                        </Text>
                      </Pressable>
                    </View>
                  </Card>
                </Pressable>
              );
            })}
          </ScrollView>
        )}

        {/* Hub feed */}
        <SectionHeader
          title="Campus hub"
          action="All hubs"
          onAction={() => router.push('/(main)/explore')}
        />
        <View className="gap-3">
          {HUB_POSTS.map((p) => (
            <PressCard
              key={p.id}
              onPress={() => router.push(`/hub/${p.hubId}` as any)}
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
