import { Stack, useRouter, useSegments } from 'expo-router';
import { useEffect, useState } from 'react';
import { useFonts } from 'expo-font';
import { ArchivoBlack_400Regular } from '@expo-google-fonts/archivo-black';
import {
  SpaceGrotesk_500Medium,
  SpaceGrotesk_700Bold,
} from '@expo-google-fonts/space-grotesk';
import {
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
  Inter_700Bold,
} from '@expo-google-fonts/inter';
import { StatusBar } from 'expo-status-bar';
import type { Session } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { COLORS } from '../theme/tokens';
import '../global.css';

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    ArchivoBlack: ArchivoBlack_400Regular,
    SpaceGrotesk_500Medium,
    SpaceGrotesk_700Bold,
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Inter_700Bold,
  });

  // undefined = still loading; null = no session; Session = logged in
  const [session, setSession] = useState<Session | null | undefined>(undefined);
  const router   = useRouter();
  const segments = useSegments();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (!fontsLoaded || session === undefined) return;

    const inMain      = segments[0] === '(main)';
    const inProtected = inMain;
    const inAuthFlow  = ['get-started', 'auth'].includes(segments[0] as string);
    const inOnboarding = segments[0] === 'onboarding';

    if (session && inAuthFlow) {
      router.replace('/(main)/home');
    } else if (!session && inProtected) {
      router.replace('/get-started');
    }
    // onboarding and root index manage themselves
  }, [session, fontsLoaded, segments]);

  if (!fontsLoaded || session === undefined) return null;

  return (
    <>
      <StatusBar style="dark" backgroundColor={COLORS.white} />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: COLORS.white },
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen name="index" />
        <Stack.Screen name="get-started" />
        <Stack.Screen name="auth/index" />
        <Stack.Screen name="auth/verify" />
        <Stack.Screen name="onboarding/index" />
        <Stack.Screen name="onboarding/success" options={{ animation: 'fade' }} />
        <Stack.Screen name="settings" />
        <Stack.Screen name="(main)" />
        <Stack.Screen name="chat/[id]" />
        <Stack.Screen name="hub/[id]" />
        <Stack.Screen name="user/[id]" />
      </Stack>
    </>
  );
}
