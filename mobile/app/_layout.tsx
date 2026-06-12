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
  Inter_700Bold,
} from '@expo-google-fonts/inter';
import { StatusBar } from 'expo-status-bar';
import { AppProvider } from '../context/AppContext';
import { COLORS } from '../theme/tokens';
import '../global.css';

export default function RootLayout() {
  const [loaded] = useFonts({
    ArchivoBlack: ArchivoBlack_400Regular,
    SpaceGrotesk_500Medium,
    SpaceGrotesk_700Bold,
    Inter_400Regular,
    Inter_500Medium,
    Inter_700Bold,
  });

  if (!loaded) return null;

  return (
    <AppProvider>
      <StatusBar style="dark" backgroundColor={COLORS.parchment} />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: COLORS.parchment },
        }}
      >
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="chats" />
        <Stack.Screen name="profile" />
        <Stack.Screen name="chat/[id]" />
        <Stack.Screen name="thread/[id]" />
      </Stack>
    </AppProvider>
  );
}
