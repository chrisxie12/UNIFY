import { useState } from 'react';
import { Pressable, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { Avatar, Badge, Card, PressCard } from '../../components/UI';

const HUBS: Record<string, {
  id: string; name: string; school: string; emoji: string;
  desc: string; members: number; online: number; category: string;
}> = {
  knust: { id: 'knust', name: 'KNUST Hub',      school: 'KNUST', emoji: '🎓', desc: 'The official hub for all KNUST students — announcements, study groups, hostel tips and more.', members: 2340, online: 87, category: 'University' },
  ug:    { id: 'ug',    name: 'UG Legon Hub',   school: 'UG',    emoji: '🦁', desc: 'Connect with fellow Legonites. Share campus news, find study partners, and stay in the loop.', members: 3100, online: 120, category: 'University' },
  cs:    { id: 'cs',    name: 'CS Students',    school: 'KNUST', emoji: '💻', desc: 'For Computer Science and Engineering students. Hackathons, internships, and code talk.', members: 510, online: 34, category: 'Department' },
  law:   { id: 'law',   name: 'Law Society',    school: 'UG',    emoji: '⚖️', desc: 'Ghana law students — moot court, internships, exam prep and legal aid clinics.', members: 290, online: 18, category: 'Department' },
  hostel:{ id: 'hostel',name: 'Hostel Hunters', school: 'All',   emoji: '🏠', desc: 'Find the best off-campus accommodation deals. Tips, reviews, and room listings.', members: 1450, online: 56, category: 'Lifestyle' },
};

const FEED: {
  id: string; hubId: string; author: string; initials: string;
  color: string; time: string; title: string; body: string;
  type: 'announcement' | 'thread' | 'event'; replies: number; likes: number;
}[] = [
  { id: 'f1', hubId: 'knust', author: 'Hub Admin',    initials: 'HA', color: 'blue',   time: '2h',  title: 'Evandy hostel allocation opens Monday', body: 'Level 100 and Level 200 students can now apply for Evandy hostel allocation through the student portal. Deadline is Friday 5pm.', type: 'announcement', replies: 24, likes: 89 },
  { id: 'f2', hubId: 'knust', author: 'Kwame B.',     initials: 'KB', color: 'green',  time: '5h',  title: 'Anyone forming MATH 203 study group?', body: 'Looking for 4–5 people serious about MATH 203. Planning to meet at the library Tuesday evenings. Drop your number.', type: 'thread', replies: 8, likes: 22 },
  { id: 'f3', hubId: 'knust', author: 'Events Team',  initials: 'ET', color: 'orange', time: '1d',  title: 'KNUST Innovation Expo — Register Now', body: 'The annual KNUST Innovation Expo is accepting project submissions. Cash prizes for top 3 teams. Deadline June 20.', type: 'event', replies: 41, likes: 115 },
  { id: 'f4', hubId: 'knust', author: 'Ama Serwaa',   initials: 'AS', color: 'purple', time: '2d',  title: 'PSA: Free printing in the engineering block', body: 'Room 104 of the SRC building has a working printer and the paper is free this week. First come first served!', type: 'thread', replies: 5, likes: 67 },
];

const MEMBERS = [
  { id: 'm1', name: 'Hub Admin',    initials: 'HA', color: 'blue',   role: 'Admin',  school: 'KNUST' },
  { id: 'm2', name: 'Ama Serwaa',   initials: 'AS', color: 'orange', role: 'Member', school: 'KNUST' },
  { id: 'm3', name: 'Michael Agyei',initials: 'MA', color: 'blue',   role: 'Member', school: 'KNUST' },
  { id: 'm4', name: 'Yaw Mensah',   initials: 'YM', color: 'red',    role: 'Member', school: 'KNUST' },
  { id: 'm5', name: 'Adwoa Kyei',   initials: 'AK', color: 'purple', role: 'Member', school: 'KNUST' },
];

const EVENTS = [
  { id: 'e1', title: 'KNUST Innovation Expo', date: 'Sat, Jun 22', time: '9:00 AM', location: 'Engineering Auditorium', going: 134 },
  { id: 'e2', title: 'Hostel Allocation Info Session', date: 'Mon, Jun 17', time: '3:00 PM', location: 'SRC Pavilion', going: 87 },
  { id: 'e3', title: 'MATH 203 Study Bootcamp', date: 'Tue, Jun 18', time: '6:00 PM', location: 'Main Library, Floor 2', going: 22 },
];

type Tab = 'Feed' | 'Members' | 'About' | 'Events';

export default function HubScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();

  const hubKey = (id ?? 'knust').toLowerCase().replace(/\s+/g, '');
  const hub = HUBS[hubKey] ?? HUBS['knust'];

  const [joined, setJoined]   = useState(false);
  const [activeTab, setTab]   = useState<Tab>('Feed');

  const feed = FEED.filter((f) => f.hubId === hub.id || hub.id === 'knust');

  function toggleJoin() {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setJoined((j) => !j);
  }

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Header bar */}
      <View className="flex-row items-center px-5 pt-4 pb-3 border-b border-border">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
        <Text className="font-heading text-lg text-primary ml-3 flex-1" numberOfLines={1}>
          {hub.name}
        </Text>
        <Pressable
          onPress={toggleJoin}
          className={`rounded-full px-4 py-2 ${joined ? 'bg-surface border border-border' : 'bg-blue'} active:opacity-80`}
        >
          <Text className={`font-body-semi text-sm ${joined ? 'text-secondary' : 'text-white'}`}>
            {joined ? 'Joined ✓' : 'Join Hub'}
          </Text>
        </Pressable>
      </View>

      {/* Hub info card */}
      <View className="px-5 py-4 border-b border-border">
        <View className="flex-row items-center gap-3 mb-2">
          <View className="w-12 h-12 bg-[#EFF6FF] rounded-2xl items-center justify-center">
            <Text style={{ fontSize: 24 }}>{hub.emoji}</Text>
          </View>
          <View className="flex-1">
            <View className="flex-row items-center gap-2">
              <Text className="font-heading text-base text-primary">{hub.name}</Text>
              <Badge label={hub.category} color="blue" />
            </View>
            <Text className="font-body text-xs text-secondary">
              {hub.members.toLocaleString()} members · {hub.online} online now
            </Text>
          </View>
        </View>
      </View>

      {/* Tabs */}
      <View className="flex-row border-b border-border">
        {(['Feed', 'Members', 'About', 'Events'] as Tab[]).map((tab) => (
          <Pressable
            key={tab}
            onPress={() => setTab(tab)}
            className="flex-1 items-center py-3"
          >
            <Text className={`font-body-semi text-sm ${activeTab === tab ? 'text-blue' : 'text-tertxt'}`}>
              {tab}
            </Text>
            {activeTab === tab && (
              <View className="absolute bottom-0 left-4 right-4 h-0.5 bg-blue rounded-full" />
            )}
          </Pressable>
        ))}
      </View>

      <ScrollView
        className="flex-1"
        contentContainerStyle={{ padding: 20, paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        {/* ── FEED ── */}
        {activeTab === 'Feed' && (
          <View className="gap-3">
            {feed.map((post) => (
              <PressCard
                key={post.id}
                onPress={() => {}}
                className="p-4"
              >
                <View className="flex-row items-center gap-2 mb-2">
                  <Avatar initials={post.initials} color={post.color} size="sm" />
                  <View className="flex-1">
                    <Text className="font-body-semi text-xs text-primary">{post.author}</Text>
                    <Text className="font-body text-[10px] text-tertxt">{post.time} ago</Text>
                  </View>
                  <Badge
                    label={post.type === 'announcement' ? '📢 Announcement' : post.type === 'event' ? '🗓 Event' : '💬 Thread'}
                    color={post.type === 'announcement' ? 'orange' : post.type === 'event' ? 'blue' : 'default'}
                  />
                </View>
                <Text className="font-heading text-sm text-primary mb-1">{post.title}</Text>
                <Text className="font-body text-xs text-secondary leading-4" numberOfLines={2}>
                  {post.body}
                </Text>
                <View className="flex-row gap-4 mt-3 pt-3 border-t border-border">
                  <Text className="font-body text-xs text-tertxt">💬 {post.replies} replies</Text>
                  <Text className="font-body text-xs text-tertxt">❤️ {post.likes}</Text>
                </View>
              </PressCard>
            ))}
          </View>
        )}

        {/* ── MEMBERS ── */}
        {activeTab === 'Members' && (
          <View className="gap-3">
            {MEMBERS.map((m) => (
              <Pressable
                key={m.id}
                onPress={() => router.push(`/user/${m.id}` as any)}
                className="flex-row items-center gap-3 py-2 active:opacity-70"
              >
                <Avatar initials={m.initials} color={m.color} size="md" />
                <View className="flex-1">
                  <Text className="font-body-semi text-sm text-primary">{m.name}</Text>
                  <Text className="font-body text-xs text-secondary">{m.school}</Text>
                </View>
                {m.role === 'Admin' && <Badge label="Admin" color="orange" />}
              </Pressable>
            ))}
          </View>
        )}

        {/* ── ABOUT ── */}
        {activeTab === 'About' && (
          <View className="gap-4">
            <Card className="p-4">
              <Text className="font-heading text-sm text-primary mb-2">About this hub</Text>
              <Text className="font-body text-sm text-secondary leading-5">{hub.desc}</Text>
            </Card>
            <Card className="p-4 gap-3">
              <View className="flex-row justify-between items-center">
                <Text className="font-body text-sm text-secondary">School</Text>
                <Text className="font-body-semi text-sm text-primary">{hub.school}</Text>
              </View>
              <View className="h-px bg-border" />
              <View className="flex-row justify-between items-center">
                <Text className="font-body text-sm text-secondary">Category</Text>
                <Text className="font-body-semi text-sm text-primary">{hub.category}</Text>
              </View>
              <View className="h-px bg-border" />
              <View className="flex-row justify-between items-center">
                <Text className="font-body text-sm text-secondary">Members</Text>
                <Text className="font-body-semi text-sm text-primary">{hub.members.toLocaleString()}</Text>
              </View>
              <View className="h-px bg-border" />
              <View className="flex-row justify-between items-center">
                <Text className="font-body text-sm text-secondary">Online now</Text>
                <View className="flex-row items-center gap-1.5">
                  <View className="w-2 h-2 rounded-full bg-green" />
                  <Text className="font-body-semi text-sm text-primary">{hub.online}</Text>
                </View>
              </View>
            </Card>
          </View>
        )}

        {/* ── EVENTS ── */}
        {activeTab === 'Events' && (
          <View className="gap-3">
            {EVENTS.map((ev) => (
              <Card key={ev.id} className="p-4">
                <View className="flex-row gap-4 items-start">
                  <View className="bg-[#EFF6FF] rounded-xl px-3 py-2 items-center min-w-[52px]">
                    <Text className="font-body text-[10px] text-blue uppercase">
                      {ev.date.split(',')[0]}
                    </Text>
                    <Text className="font-display text-xl text-blue leading-5">
                      {ev.date.split(' ')[1]}
                    </Text>
                  </View>
                  <View className="flex-1">
                    <Text className="font-heading text-sm text-primary mb-0.5">{ev.title}</Text>
                    <Text className="font-body text-xs text-secondary">{ev.time} · {ev.location}</Text>
                    <Text className="font-body text-xs text-tertxt mt-1">{ev.going} going</Text>
                  </View>
                </View>
              </Card>
            ))}
          </View>
        )}
      </ScrollView>

      {/* FAB — Create Post (Feed tab only) */}
      {activeTab === 'Feed' && (
        <Pressable
          onPress={() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium)}
          className="absolute bottom-8 right-6 w-14 h-14 bg-blue rounded-full items-center justify-center shadow-card-lg active:opacity-80"
        >
          <Text className="text-white text-2xl leading-none">+</Text>
        </Pressable>
      )}
    </SafeAreaView>
  );
}
