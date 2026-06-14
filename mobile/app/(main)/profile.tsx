import { useCallback, useEffect, useState } from 'react';
import { Alert, ScrollView, Text, View, Pressable, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Avatar, Badge, Card, Btn } from '../../components/UI';
import { supabase, type Profile } from '../../lib/supabase';

export default function ProfileScreen() {
  const router = useRouter();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  const loadProfile = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();
    if (data) setProfile(data as Profile);
    setLoading(false);
  }, []);

  useEffect(() => { loadProfile(); }, []);

  function handleLogOut() {
    Alert.alert('Log out', 'Are you sure you want to log out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Log out',
        style: 'destructive',
        onPress: async () => {
          await supabase.auth.signOut();
          router.replace('/get-started');
        },
      },
    ]);
  }

  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#003F8A" />
      </SafeAreaView>
    );
  }

  const displayName = profile?.full_name || 'Your Profile';
  const initials    = profile?.full_name
    ? profile.full_name.split(' ').map((n) => n[0]).slice(0, 2).join('').toUpperCase()
    : 'ME';

  const levelLabel = profile?.level
    ? `Level ${profile.level.replace('level', '').trim()}`
    : null;

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <ScrollView
        contentContainerStyle={{ paddingBottom: 32 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Blue cover with settings gear */}
        <View className="bg-tertiary h-28">
          <Pressable
            onPress={() => router.push('/settings')}
            hitSlop={12}
            className="absolute top-4 right-5 w-10 h-10 rounded-full bg-white/20 items-center justify-center active:opacity-70"
          >
            <Text style={{ fontSize: 18 }}>⚙️</Text>
          </Pressable>
        </View>

        {/* Avatar overlapping cover */}
        <View className="px-5 -mt-10 mb-4 flex-row items-end justify-between">
          <View className="rounded-full border-4 border-white shadow-card">
            <Avatar initials={initials} color="blue" size="xl" />
          </View>
          <Btn
            label="Edit profile"
            variant="outline"
            size="sm"
            onPress={() => router.push('/onboarding')}
          />
        </View>

        {/* Name & info */}
        <View className="px-5 mb-5">
          <Text className="font-display text-2xl text-primary">{displayName}</Text>
          {profile?.is_verified ? (
            <View className="flex-row items-center gap-1 mt-1">
              <Text className="text-xs">✅</Text>
              <Text className="font-body text-xs text-green">Verified student</Text>
            </View>
          ) : (
            <View className="flex-row items-center gap-1 mt-1">
              <Text className="font-body text-xs text-tertxt">Verification pending</Text>
            </View>
          )}
          {profile?.programme ? (
            <Text className="font-body text-sm text-secondary mt-1">
              {profile.programme}
              {levelLabel ? ` · ${levelLabel}` : ''}
            </Text>
          ) : null}
          {profile?.student_id ? (
            <Text className="font-body text-xs text-tertxt mt-0.5">
              ID: {profile.student_id}
            </Text>
          ) : null}
          {profile?.bio ? (
            <Text className="font-body-medium text-sm text-secondary mt-3 leading-5">
              {profile.bio}
            </Text>
          ) : null}
        </View>

        {/* Role badge */}
        {profile?.role && profile.role !== 'student' && (
          <View className="px-5 mb-5">
            <Badge
              label={profile.role.charAt(0).toUpperCase() + profile.role.slice(1)}
              color="blue"
            />
          </View>
        )}

        {/* Empty state */}
        {!profile?.full_name && (
          <View className="mx-5 mt-4 bg-tertiary rounded-2xl p-5 items-center">
            <Text className="font-heading text-base text-primary mb-1">
              Complete your profile
            </Text>
            <Text className="font-body text-sm text-secondary text-center mb-4">
              Add your name, programme and year so admins can verify your account.
            </Text>
            <Btn label="Set up profile" onPress={() => router.push('/onboarding')} />
          </View>
        )}

        {/* Log out */}
        <View className="mx-5 mt-4 mb-2">
          <Pressable
            onPress={handleLogOut}
            className="rounded-full py-3.5 items-center border border-border active:opacity-70"
          >
            <Text className="font-body-semi text-sm text-red">Log Out</Text>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
