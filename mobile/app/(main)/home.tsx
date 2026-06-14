import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, RefreshControl, ScrollView, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { supabase, type Announcement, type Profile } from '../../lib/supabase';
import { Card, Badge } from '../../components/UI';

const CATEGORY_ICON: Record<string, string> = {
  academic: '📚',
  events:   '🎉',
  admin:    '🏛',
  general:  '📢',
  urgent:   '🚨',
};

const CATEGORY_COLOR: Record<string, 'blue' | 'default'> = {
  urgent:   'blue',
  academic: 'blue',
  events:   'default',
  admin:    'default',
  general:  'default',
};

function timeAgo(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

export default function HomeScreen() {
  const router = useRouter();

  const [profile,       setProfile]       = useState<Profile | null>(null);
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [loading,       setLoading]       = useState(true);
  const [refreshing,    setRefreshing]    = useState(false);

  const loadData = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    // Load profile and announcements in parallel
    const [profileRes, announcementsRes] = await Promise.all([
      supabase
        .from('profiles')
        .select('id, full_name, university_id, role, is_verified, level, programme')
        .eq('id', user.id)
        .single(),
      supabase
        .from('announcements')
        .select('id, title, body, category, published_at, expires_at')
        .eq('is_published', true)
        .or('expires_at.is.null,expires_at.gt.' + new Date().toISOString())
        .order('published_at', { ascending: false })
        .limit(20),
    ]);

    if (profileRes.data)       setProfile(profileRes.data as Profile);
    if (announcementsRes.data) setAnnouncements(announcementsRes.data as Announcement[]);
    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => { loadData(); }, []);

  const displayName = profile?.full_name
    ? profile.full_name.split(' ')[0]
    : 'there';

  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#003F8A" />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => { setRefreshing(true); loadData(); }}
            tintColor="#003F8A"
          />
        }
      >
        {/* Greeting */}
        <View className="pt-5 pb-4">
          <Text className="font-body text-sm text-secondary">{greeting},</Text>
          <Text className="font-display text-[28px] leading-8 text-primary">
            {displayName} 👋
          </Text>
        </View>

        {/* Verification badge */}
        {profile && !profile.is_verified && (
          <View className="bg-[#FFFBEB] rounded-2xl px-4 py-3 mb-5 flex-row items-center gap-3">
            <Text style={{ fontSize: 20 }}>⏳</Text>
            <View className="flex-1">
              <Text className="font-body-semi text-sm text-[#92400E]">Verification pending</Text>
              <Text className="font-body text-xs text-[#B45309]">Your student ID is being verified by admin.</Text>
            </View>
          </View>
        )}

        {/* Announcements */}
        <View className="flex-row items-center justify-between mb-3">
          <Text className="font-heading text-base text-primary">Announcements</Text>
          <Text className="font-body text-xs text-tertxt">{announcements.length} total</Text>
        </View>

        {announcements.length === 0 ? (
          <Card className="p-8 items-center">
            <Text style={{ fontSize: 40 }} className="mb-3">📭</Text>
            <Text className="font-heading text-sm text-primary mb-1">Nothing yet</Text>
            <Text className="font-body text-xs text-secondary text-center">
              Check back later for campus announcements.
            </Text>
          </Card>
        ) : (
          <View className="gap-3">
            {announcements.map((a) => (
              <Pressable
                key={a.id}
                className="active:opacity-90"
              >
                <Card className="p-4">
                  <View className="flex-row items-start gap-3">
                    <View className="w-10 h-10 rounded-xl bg-[#EFF6FF] items-center justify-center flex-shrink-0">
                      <Text style={{ fontSize: 20 }}>{CATEGORY_ICON[a.category] ?? '📢'}</Text>
                    </View>
                    <View className="flex-1">
                      <View className="flex-row items-center gap-2 mb-1 flex-wrap">
                        <Badge
                          label={a.category.charAt(0).toUpperCase() + a.category.slice(1)}
                          color={CATEGORY_COLOR[a.category] ?? 'default'}
                        />
                        <Text className="font-body text-[10px] text-tertxt">
                          {timeAgo(a.published_at)}
                        </Text>
                      </View>
                      <Text className="font-body-medium text-sm text-primary leading-5 mb-1">
                        {a.title}
                      </Text>
                      <Text className="font-body text-xs text-secondary leading-4" numberOfLines={2}>
                        {a.body}
                      </Text>
                    </View>
                  </View>
                </Card>
              </Pressable>
            ))}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
