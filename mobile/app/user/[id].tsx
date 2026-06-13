import { useState } from 'react';
import { Alert, Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { Avatar, Badge, Btn, Card } from '../../components/UI';

const PROFILES: Record<string, {
  id: string; name: string; initials: string; color: string;
  school: string; level: string; programme: string; hometown: string;
  matchPct: number; verified: boolean; bio: string;
  sleep: string; clean: string; noise: string; study: string;
  hostels: string[]; matches: number; hubs: number; avgMatch: number;
  mutual: { id: string; name: string; initials: string; color: string }[];
  connected: boolean;
}> = {
  c1: { id: 'c1', name: 'Ama Serwaa', initials: 'AS', color: 'orange', school: 'KNUST', level: 'Level 200', programme: 'BSc Computer Science', hometown: 'Kumasi', matchPct: 94, verified: true, bio: 'CS student who loves hackathons, Afrobeats, and early morning runs. Looking for a tidy and focused roommate.', sleep: 'Night owl 🦉', clean: 'Very tidy ✨', noise: 'Moderate 🎶', study: 'Library 📚', hostels: ['Evandy Hostel', 'Brunei Hostel'], matches: 12, hubs: 3, avgMatch: 91, mutual: [{ id: 'c3', name: 'Efua B.', initials: 'EB', color: 'green' }], connected: false },
  c2: { id: 'c2', name: 'Michael Agyei', initials: 'MA', color: 'blue', school: 'KNUST', level: 'Level 100', programme: 'BSc Electrical Engineering', hometown: 'Accra', matchPct: 88, verified: true, bio: 'Electrical Eng student. Gym rat, football fan, and occasional chef. Chill roommate, just keep it decent.', sleep: 'Night owl 🦉', clean: 'Moderate 👍', noise: 'Lively 🎉', study: 'Café ☕', hostels: ['Unity Hall', 'Republic Hall'], matches: 7, hubs: 2, avgMatch: 85, mutual: [], connected: false },
  c3: { id: 'c3', name: 'Efua Boateng', initials: 'EB', color: 'green', school: 'UCC', level: 'Level 200', programme: 'BSc Civil Engineering', hometown: 'Cape Coast', matchPct: 82, verified: false, bio: 'Civil engineer in the making. Love quiet spaces, Afro-fusion cooking, and weekend beach trips from Cape Coast.', sleep: 'Early bird 🌅', clean: 'Very tidy ✨', noise: 'Silent 🤫', study: 'In my room 🛏', hostels: ['Queens Hall'], matches: 5, hubs: 1, avgMatch: 80, mutual: [{ id: 'c1', name: 'Ama S.', initials: 'AS', color: 'orange' }], connected: true },
  s1: { id: 's1', name: 'Ama Serwaa', initials: 'AS', color: 'orange', school: 'KNUST', level: 'Level 200', programme: 'BSc Computer Science', hometown: 'Kumasi', matchPct: 94, verified: true, bio: 'CS student who loves hackathons, Afrobeats, and early morning runs.', sleep: 'Night owl 🦉', clean: 'Very tidy ✨', noise: 'Moderate 🎶', study: 'Library 📚', hostels: ['Evandy Hostel'], matches: 12, hubs: 3, avgMatch: 91, mutual: [], connected: false },
  m2: { id: 'm2', name: 'Ama Serwaa', initials: 'AS', color: 'orange', school: 'KNUST', level: 'Level 200', programme: 'BSc Computer Science', hometown: 'Kumasi', matchPct: 94, verified: true, bio: 'CS student, hub admin, and campus event organiser.', sleep: 'Night owl 🦉', clean: 'Very tidy ✨', noise: 'Moderate 🎶', study: 'Library 📚', hostels: ['Evandy Hostel'], matches: 20, hubs: 4, avgMatch: 90, mutual: [], connected: false },
};

const FALLBACK = PROFILES['c1'];

export default function UserProfileScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();

  const user = PROFILES[id ?? ''] ?? FALLBACK;
  const [connected, setConnected] = useState(user.connected);

  function handleConnect() {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    setConnected(true);
  }

  function handleReport() {
    Alert.alert('Report or Block', 'What would you like to do?', [
      { text: 'Block this user', style: 'destructive', onPress: () => {} },
      { text: 'Report this user', style: 'destructive', onPress: () => {} },
      { text: 'Cancel', style: 'cancel' },
    ]);
  }

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Nav bar */}
      <View className="flex-row items-center px-5 pt-4 pb-2 border-b border-border">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
        <Text className="font-heading text-lg text-primary ml-3 flex-1" numberOfLines={1}>
          {user.name}
        </Text>
        <Pressable onPress={handleReport} hitSlop={12} className="p-2 active:opacity-70">
          <Text className="text-tertxt text-base">⋯</Text>
        </Pressable>
      </View>

      <ScrollView
        contentContainerStyle={{ paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Cover + Avatar */}
        <View className="bg-[#EFF6FF] h-24" />
        <View className="px-5 -mt-8 mb-4 flex-row items-end justify-between">
          <View className="rounded-full border-4 border-white">
            <Avatar initials={user.initials} color={user.color} size="xl" />
          </View>
          <View className="bg-[#EFF6FF] rounded-full px-4 py-1 mt-8">
            <Text className="text-blue font-body-semi text-sm">{user.matchPct}% match</Text>
          </View>
        </View>

        {/* Identity */}
        <View className="px-5 mb-5">
          <View className="flex-row items-center gap-2 mb-0.5">
            <Text className="font-display text-2xl text-primary">{user.name}</Text>
            {user.verified && (
              <View className="bg-[#ECFDF5] rounded-full w-5 h-5 items-center justify-center">
                <Text className="text-green text-[10px] font-body-semi">✓</Text>
              </View>
            )}
          </View>
          <Text className="font-body text-sm text-secondary">
            {user.school} · {user.level}
          </Text>
          <Text className="font-body text-xs text-tertxt mt-0.5">{user.programme}</Text>
          <Text className="font-body text-xs text-tertxt">📍 {user.hometown}</Text>
          {user.bio ? (
            <Text className="font-body text-sm text-secondary mt-3 leading-5">{user.bio}</Text>
          ) : null}
        </View>

        {/* Stats */}
        <View className="flex-row gap-3 mx-5 mb-5">
          <Card className="flex-1 p-3 items-center">
            <Text className="font-display text-xl text-blue">{user.matches}</Text>
            <Text className="font-body text-[11px] text-secondary">Matches</Text>
          </Card>
          <Card className="flex-1 p-3 items-center">
            <Text className="font-display text-xl text-primary">{user.hubs}</Text>
            <Text className="font-body text-[11px] text-secondary">Hubs</Text>
          </Card>
          <Card className="flex-1 p-3 items-center">
            <Text className="font-display text-xl text-orange">{user.avgMatch}%</Text>
            <Text className="font-body text-[11px] text-secondary">Avg match</Text>
          </Card>
        </View>

        {/* Habits */}
        <View className="mx-5 mb-5">
          <Text className="font-heading text-base text-primary mb-3">Living habits</Text>
          <Card className="p-4">
            {[
              { label: 'Sleep', value: user.sleep },
              { label: 'Cleanliness', value: user.clean },
              { label: 'Noise', value: user.noise },
              { label: 'Studies', value: user.study },
            ].map((row, i, arr) => (
              <View
                key={row.label}
                className={`flex-row justify-between items-center py-3 ${
                  i < arr.length - 1 ? 'border-b border-border' : ''
                }`}
              >
                <Text className="font-body text-sm text-secondary">{row.label}</Text>
                <Text className="font-body-semi text-sm text-primary">{row.value}</Text>
              </View>
            ))}
          </Card>
        </View>

        {/* Preferred hostels */}
        {user.hostels.length > 0 && (
          <View className="mx-5 mb-5">
            <Text className="font-heading text-base text-primary mb-3">Preferred hostels</Text>
            <View className="flex-row flex-wrap gap-2">
              {user.hostels.map((h) => (
                <Badge key={h} label={h} color="blue" />
              ))}
            </View>
          </View>
        )}

        {/* Mutual connections */}
        {user.mutual.length > 0 && (
          <View className="mx-5 mb-5">
            <Text className="font-heading text-base text-primary mb-3">Mutual connections</Text>
            <View className="flex-row gap-3">
              {user.mutual.map((m) => (
                <Pressable
                  key={m.id}
                  onPress={() => router.push(`/user/${m.id}` as any)}
                  className="items-center active:opacity-70"
                >
                  <Avatar initials={m.initials} color={m.color} size="md" />
                  <Text className="font-body text-[11px] text-secondary mt-1">{m.name}</Text>
                </Pressable>
              ))}
            </View>
          </View>
        )}

        {/* CTA buttons */}
        <View className="mx-5 gap-3 mb-6">
          {connected ? (
            <Btn
              label="Message →"
              onPress={() => router.push('/chat/c1' as any)}
            />
          ) : (
            <Btn
              label="Send Match Request"
              onPress={handleConnect}
            />
          )}
        </View>

        {/* Block/Report */}
        <View className="items-center mb-4">
          <Pressable onPress={handleReport} className="py-2 active:opacity-70">
            <Text className="font-body text-xs text-tertxt">Block or Report {user.name.split(' ')[0]}</Text>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
