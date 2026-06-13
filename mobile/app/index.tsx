import { useEffect, useRef, useState } from 'react';
import { Animated, Pressable, Text, View, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import { useAppStore } from '../store/useAppStore';
import { GOOGLE_WEB_CLIENT_ID } from '../config/firebase';

// Required for the OAuth redirect to complete inside the app.
WebBrowser.maybeCompleteAuthSession();

const HAS_CLIENT_ID = GOOGLE_WEB_CLIENT_ID.length > 0;

export default function SplashScreen() {
  const router        = useRouter();
  const setGoogleUser = useAppStore((s) => s.setGoogleUser);
  const onboarded     = useAppStore((s) => s.onboarded);
  const verified      = useAppStore((s) => s.verified);

  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState('');

  const fadeAnim  = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(28)).current;
  const btnAnim   = useRef(new Animated.Value(0)).current;

  // expo-auth-session Google hook
  const [, response, promptAsync] = Google.useAuthRequest({
    webClientId: GOOGLE_WEB_CLIENT_ID,
  });

  // Entrance animation
  useEffect(() => {
    Animated.sequence([
      Animated.parallel([
        Animated.timing(fadeAnim,  { toValue: 1, duration: 650, useNativeDriver: true }),
        Animated.timing(slideAnim, { toValue: 0, duration: 650, useNativeDriver: true }),
      ]),
      Animated.timing(btnAnim, { toValue: 1, duration: 350, delay: 80, useNativeDriver: true }),
    ]).start();
  }, []);

  // Handle Google OAuth response
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
        setGoogleUser({
          id:      info.id,
          email:   info.email,
          name:    info.name,
          picture: info.picture,
        });
        // Pre-fill display name from Google
        useAppStore.getState().updateProfile({
          fullName:    info.name,
          displayName: info.given_name ?? info.name.split(' ')[0],
        });
        router.replace(onboarded ? '/(main)/home' : '/onboarding');
      })
      .catch(() => {
        setError('Could not fetch profile. Please try again.');
        setLoading(false);
      });
  }, [response]);

  // Already signed in — skip straight through
  useEffect(() => {
    if (verified) {
      router.replace(onboarded ? '/(main)/home' : '/onboarding');
    }
  }, []);

  async function handleGoogleSignIn() {
    setError('');
    setLoading(true);
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
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-1 px-8 justify-center">
        <Animated.View style={{ opacity: fadeAnim, transform: [{ translateY: slideAnim }] }}>
          <Text className="font-display text-[58px] leading-[62px] text-primary tracking-tight">
            UNIFY
          </Text>
          <View className="h-[5px] w-28 bg-orange rounded-full mt-1" />
          <Text className="font-body-medium text-lg text-secondary mt-5 leading-7">
            Find your people,{'\n'}find your place.
          </Text>
          <Text className="font-body text-sm text-tertxt mt-3 leading-6">
            Match with roommates. Join your campus hub.{'\n'}
            Built for Ghanaian students.
          </Text>
        </Animated.View>

        <Animated.View style={{ opacity: btnAnim }} className="mt-14 gap-3">
          {/* Google Sign-In button */}
          <Pressable
            onPress={handleGoogleSignIn}
            disabled={loading || (!HAS_CLIENT_ID)}
            className="bg-white rounded-full py-4 px-6 flex-row items-center justify-center gap-3 border border-border shadow-card active:opacity-70"
          >
            {loading ? (
              <ActivityIndicator size="small" color="#0066FF" />
            ) : (
              <>
                <Text className="text-xl">G</Text>
                <Text className="font-body-semi text-base text-primary">
                  Continue with Google
                </Text>
              </>
            )}
          </Pressable>

          {!HAS_CLIENT_ID && (
            <View className="bg-[#FFF4EE] rounded-2xl px-4 py-3">
              <Text className="font-body text-xs text-orange text-center leading-5">
                Add EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID to .env{'\n'}
                (Firebase Console → Auth → Google → Web client ID)
              </Text>
            </View>
          )}

          {/* Dev bypass — always visible during development */}
          {__DEV__ && (
            <Pressable
              onPress={handleDevBypass}
              className="items-center py-3 active:opacity-70"
            >
              <Text className="font-body text-xs text-tertxt">
                Dev: skip sign-in →
              </Text>
            </Pressable>
          )}

          {error.length > 0 && (
            <Text className="text-red text-xs font-body-semi text-center">{error}</Text>
          )}
        </Animated.View>
      </View>

      <View className="px-8 pb-8">
        <Text className="text-[11px] font-body text-tertxt text-center">
          By continuing you agree to our Terms of Service
        </Text>
      </View>
    </SafeAreaView>
  );
}
