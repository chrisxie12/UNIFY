import { useRef, useState } from 'react';
import { Animated, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';

type Mode = 'signup' | 'login';

export default function GetStartedScreen() {
  const router = useRouter();
  const [mode, setMode] = useState<Mode>('signup');
  const slideAnim = useRef(new Animated.Value(0)).current;

  function switchMode(next: Mode) {
    if (next === mode) return;
    setMode(next);
    Haptics.selectionAsync();
    Animated.spring(slideAnim, {
      toValue: next === 'signup' ? 0 : 1,
      useNativeDriver: false,
      tension: 80,
      friction: 12,
    }).start();
  }

  const indicatorLeft = slideAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['2%', '50%'],
  });

  function goToAuth() {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.push({ pathname: '/auth', params: { mode } });
  }

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top', 'bottom']}>
      <View className="flex-1 px-6 pt-8 pb-6 justify-between">
        {/* Header */}
        <View>
          <Text className="font-display text-[36px] leading-[42px] text-primary tracking-tight mb-2">
            {mode === 'signup'
              ? 'Stay in the loop\non campus.'
              : 'Welcome back 👋'}
          </Text>
          <Text className="font-body text-base text-secondary leading-6">
            {mode === 'signup'
              ? 'Get announcements, updates, and connect with your campus community at GCTU.'
              : 'Sign in to see what\'s happening on campus.'}
          </Text>
        </View>

        {/* Login / Sign Up toggle */}
        <View className="bg-surface rounded-2xl p-1 flex-row relative mb-2">
          <Animated.View
            style={{
              position: 'absolute',
              top: 4, bottom: 4, left: indicatorLeft, width: '48%',
              backgroundColor: '#FFFFFF',
              borderRadius: 14,
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 1 },
              shadowOpacity: 0.08,
              shadowRadius: 4,
              elevation: 2,
            }}
          />
          <Pressable onPress={() => switchMode('signup')} className="flex-1 items-center py-3 z-10">
            <Text className={`font-body-semi text-sm ${mode === 'signup' ? 'text-primary' : 'text-tertxt'}`}>
              Sign Up
            </Text>
          </Pressable>
          <Pressable onPress={() => switchMode('login')} className="flex-1 items-center py-3 z-10">
            <Text className={`font-body-semi text-sm ${mode === 'login' ? 'text-primary' : 'text-tertxt'}`}>
              Log In
            </Text>
          </Pressable>
        </View>

        {/* Auth buttons */}
        <View className="gap-3">
          {/* Apple — coming soon */}
          <Pressable
            disabled
            className="flex-row items-center justify-center gap-3 bg-white rounded-2xl py-4 border border-border opacity-40"
          >
            <Text style={{ fontSize: 20, color: '#111827' }}>🍎</Text>
            <Text className="font-body-semi text-base text-primary">
              {mode === 'login' ? 'Continue with Apple' : 'Sign up with Apple'}
            </Text>
          </Pressable>

          {/* Google — coming soon */}
          <Pressable
            disabled
            className="flex-row items-center justify-center gap-3 bg-white rounded-2xl py-4 border border-border opacity-40"
            style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 3, elevation: 1 }}
          >
            <View className="w-6 h-6 items-center justify-center">
              <Text style={{ fontFamily: 'System', fontSize: 18, color: '#4285F4', fontWeight: '700' }}>G</Text>
            </View>
            <Text className="font-body-semi text-base text-primary">
              {mode === 'login' ? 'Continue with Google' : 'Sign up with Google'}
            </Text>
          </Pressable>

          {/* Email — primary */}
          <Pressable
            onPress={goToAuth}
            className="flex-row items-center justify-center gap-3 bg-btn-primary rounded-2xl py-4 active:opacity-80"
          >
            <Text style={{ fontSize: 20 }}>✉️</Text>
            <Text className="font-body-semi text-base text-white">
              {mode === 'login' ? 'Log in with Email' : 'Sign up with Email'}
            </Text>
          </Pressable>
        </View>

        {/* Footer */}
        <Text className="font-body text-[12px] text-tertxt text-center leading-5">
          By continuing, you agree to our{' '}
          <Text className="underline">Terms of Use</Text> and{' '}
          <Text className="underline">Privacy Policy</Text>
        </Text>
      </View>
    </SafeAreaView>
  );
}
