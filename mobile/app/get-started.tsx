import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import * as Haptics from 'expo-haptics';
import { useAppStore } from '../store/useAppStore';
import { GOOGLE_WEB_CLIENT_ID } from '../config/firebase';

WebBrowser.maybeCompleteAuthSession();

export default function GetStartedScreen() {
  const router        = useRouter();
  const setGoogleUser = useAppStore((s) => s.setGoogleUser);
  const onboarded     = useAppStore((s) => s.onboarded);

  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState('');

  const [, response, promptAsync] = Google.useAuthRequest({
    webClientId: GOOGLE_WEB_CLIENT_ID,
  });

  // Handle Google OAuth result
  useEffect(() => {
    if (response?.type !== 'success') {
      if (response?.type === 'error') {
        setError('Sign-in failed. Please try again.');
        setLoading(false);
      }
      return;
    }

    const accessToken = response.authentication?.accessToken;
    if (!accessToken) return;

    setLoading(true);
    fetch('https://www.googleapis.com/userinfo/v2/me', {
      headers: { Authorization: `Bearer ${accessToken}` },
    })
      .then((r) => r.json())
      .then((info) => {
        setGoogleUser({ id: info.id, email: info.email, name: info.name, picture: info.picture });
        useAppStore.getState().updateProfile({
          fullName:    info.name,
          displayName: info.given_name ?? info.name.split(' ')[0],
        });
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
        router.replace(onboarded ? '/(main)/home' : '/onboarding');
      })
      .catch(() => {
        setError('Could not fetch your profile. Please try again.');
        setLoading(false);
      });
  }, [response]);

  async function handleGoogle() {
    setError('');
    setLoading(true);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    try {
      await promptAsync();
    } catch {
      setError('Sign-in failed. Please try again.');
      setLoading(false);
    }
  }

  function handleDevBypass() {
    setGoogleUser({ id: 'dev-001', email: 'dev@unify.gh', name: 'Dev User', picture: '' });
    useAppStore.getState().updateProfile({ fullName: 'Dev User', displayName: 'Dev' });
    router.replace('/onboarding');
  }

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top', 'bottom']}>
      <View className="flex-1 px-6 pt-10 pb-6 justify-between">
        {/* Header copy */}
        <View className="mt-4">
          <Text className="font-display text-[32px] leading-[38px] text-primary tracking-tight">
            Don't pull up to{'\n'}campus alone, fr.
          </Text>
          <Text className="font-body text-base text-secondary mt-4 leading-6">
            Find your roommate, link with coursemates,{'\n'}
            and join your school hub.
          </Text>
        </View>

        {/* Auth buttons */}
        <View className="gap-3">
          {/* Google */}
          <Pressable
            onPress={handleGoogle}
            disabled={loading}
            className="flex-row items-center justify-center gap-3 bg-white rounded-2xl py-4 border-2 border-border shadow-card active:opacity-70"
          >
            {loading ? (
              <ActivityIndicator size="small" color="#374151" />
            ) : (
              <>
                {/* Google G */}
                <View className="w-6 h-6 items-center justify-center">
                  <Text style={{ fontFamily: 'System', fontSize: 18, color: '#4285F4', fontWeight: '700' }}>G</Text>
                </View>
                <Text className="font-body-semi text-base text-primary">
                  Sign in with Google
                </Text>
              </>
            )}
          </Pressable>

          {/* Apple (placeholder — wire up expo-apple-authentication for production) */}
          <Pressable
            disabled
            className="flex-row items-center justify-center gap-3 bg-white rounded-2xl py-4 border-2 border-border opacity-40"
          >
            <Text style={{ fontSize: 20, color: '#111827' }}>🍎</Text>
            <Text className="font-body-semi text-base text-primary">
              Continue with Apple
            </Text>
          </Pressable>

          {/* Phone link */}
          <Pressable
            className="items-center py-2 active:opacity-70"
            onPress={() => {/* TODO: phone auth */}}
          >
            <Text className="font-body-semi text-sm text-blue">
              I'll use my phone number instead →
            </Text>
          </Pressable>

          {error.length > 0 && (
            <Text className="text-red text-xs font-body-semi text-center">{error}</Text>
          )}

          {/* Dev bypass */}
          {__DEV__ && (
            <Pressable
              onPress={handleDevBypass}
              className="items-center py-1 active:opacity-70"
            >
              <Text className="font-body text-[11px] text-tertxt">Dev: skip sign-in →</Text>
            </Pressable>
          )}
        </View>

        {/* Footer */}
        <Text className="font-body text-[12px] text-tertxt text-center leading-5">
          By continuing, you agree to our{' '}
          <Text className="underline">Terms</Text> and{' '}
          <Text className="underline">Privacy</Text>
        </Text>
      </View>
    </SafeAreaView>
  );
}
