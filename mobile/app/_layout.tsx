import { Stack } from 'expo-router';
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
import { COLORS } from '../theme/tokens';
import '../global.css';

export default function RootLayout() {
  const [loaded] = useFonts({
    ArchivoBlack: ArchivoBlack_400Regular,
    SpaceGrotesk_500Medium,
    SpaceGrotesk_700Bold,
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Inter_700Bold,
  });

  if (!loaded) return null;

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
        <Stack.Screen name="index" options={{ animation: 'none' }} />
        <Stack.Screen name="get-started" />
        <Stack.Screen name="onboarding/index" />
        <Stack.Screen name="(main)" />
        <Stack.Screen name="chat/[id]" />
        <Stack.Screen name="hub/[id]" />
        <Stack.Screen name="user/[id]" />
      </Stack>
    </>
  );
}
