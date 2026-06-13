import { ScrollView, Text, View, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Avatar, Badge, Card, Btn } from '../../components/UI';
import { useAppStore } from '../../store/useAppStore';

const HABIT_MAP: Record<string, string> = {
  early_bird: 'Early bird 🌅',
  night_owl:  'Night owl 🦉',
  very_tidy:  'Very tidy ✨',
  moderate:   'Moderate 👍',
  relaxed:    'Relaxed 😌',
  silent:     'Silent 🤫',
  lively:     'Lively 🎉',
  room:       'In my room 🛏',
  library:    'Library 📚',
  cafe:       'Café ☕',
  outdoor:    'Outdoors 🌳',
};

export default function ProfileScreen() {
  const router  = useRouter();
  const profile = useAppStore((s) => s.profile);

  const displayName = profile.fullName || 'Your Profile';
  const initials    = profile.fullName
    ? profile.fullName.split(' ').map((n) => n[0]).slice(0, 2).join('').toUpperCase()
    : 'ME';

  const habits = [
    profile.sleep       && { label: 'Sleep',       value: HABIT_MAP[profile.sleep]       },
    profile.cleanliness && { label: 'Cleanliness', value: HABIT_MAP[profile.cleanliness] },
    profile.noise       && { label: 'Noise',       value: HABIT_MAP[profile.noise]       },
    profile.study       && { label: 'Study',       value: HABIT_MAP[profile.study]       },
  ].filter(Boolean) as { label: string; value: string }[];

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
          {profile.school ? (
            <Text className="font-body text-sm text-secondary mt-0.5">
              {profile.school}
              {profile.level ? ` · ${profile.level}` : ''}
            </Text>
          ) : null}
          {profile.programme ? (
            <Text className="font-body text-xs text-tertxt mt-0.5">{profile.programme}</Text>
          ) : null}
          {profile.hometown ? (
            <Text className="font-body text-xs text-tertxt mt-0.5">📍 {profile.hometown}</Text>
          ) : null}
          {profile.bio ? (
            <Text className="font-body-medium text-sm text-secondary mt-3 leading-5">
              {profile.bio}
            </Text>
          ) : null}
        </View>

        {/* Stats */}
        <View className="flex-row gap-3 mx-5 mb-5">
          <Card className="flex-1 p-4 items-center">
            <Text className="font-display text-2xl text-blue">0</Text>
            <Text className="font-body text-xs text-secondary mt-0.5">Matches</Text>
          </Card>
          <Card className="flex-1 p-4 items-center">
            <Text className="font-display text-2xl text-primary">0</Text>
            <Text className="font-body text-xs text-secondary mt-0.5">Connections</Text>
          </Card>
          <Card className="flex-1 p-4 items-center">
            <Text className="font-display text-2xl text-orange">—</Text>
            <Text className="font-body text-xs text-secondary mt-0.5">Avg match</Text>
          </Card>
        </View>

        {/* Habits */}
        {habits.length > 0 && (
          <View className="mx-5 mb-5">
            <Text className="font-heading text-base text-primary mb-3">Living habits</Text>
            <Card className="p-4">
              {habits.map((h, i) => (
                <View
                  key={h.label}
                  className={`flex-row justify-between items-center py-3 ${
                    i < habits.length - 1 ? 'border-b border-border' : ''
                  }`}
                >
                  <Text className="font-body text-sm text-secondary">{h.label}</Text>
                  <Text className="font-body-semi text-sm text-primary">{h.value}</Text>
                </View>
              ))}
            </Card>
          </View>
        )}

        {/* Preferred hostels */}
        {profile.hostels.length > 0 && (
          <View className="mx-5 mb-5">
            <Text className="font-heading text-base text-primary mb-3">Preferred hostels</Text>
            <View className="flex-row flex-wrap gap-2">
              {profile.hostels.map((h) => (
                <Badge key={h} label={h} color="blue" />
              ))}
            </View>
          </View>
        )}

        {/* Empty state */}
        {!profile.fullName && (
          <View className="mx-5 mt-4 bg-tertiary rounded-2xl p-5 items-center">
            <Text className="font-heading text-base text-primary mb-1">
              Complete your profile
            </Text>
            <Text className="font-body text-sm text-secondary text-center mb-4">
              Add your details to start matching with potential roommates.
            </Text>
            <Btn label="Set up profile" onPress={() => router.push('/onboarding')} />
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
