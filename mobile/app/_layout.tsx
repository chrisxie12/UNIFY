import { Tabs } from 'expo-router';
import { Text, View } from 'react-native';
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
import { COLORS } from '../theme/tokens';
import '../global.css';

interface TabIconProps {
  label: string;
  glyph: string;
  focused: boolean;
}

function TabIcon({ label, glyph, focused }: TabIconProps) {
  return (
    <View
      className={`items-center justify-center min-w-[64px] px-2.5 py-0.5 rounded-none ${
        focused ? 'bg-action border-2 border-black' : ''
      }`}
    >
      <Text className="text-base">{glyph}</Text>
      <Text className="text-[9px] font-body-bold text-black uppercase tracking-wide">
        {label}
      </Text>
    </View>
  );
}

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
    <>
      <StatusBar style="dark" backgroundColor={COLORS.parchment} />
      <Tabs
        screenOptions={{
          headerShown: false,
          tabBarShowLabel: false,
          tabBarStyle: {
            backgroundColor: COLORS.parchment,
            borderTopWidth: 4,
            borderTopColor: COLORS.ink,
            height: 64,
            paddingTop: 8,
          },
        }}
      >
        <Tabs.Screen
          name="index"
          options={{
            tabBarIcon: ({ focused }: { focused: boolean }) => (
              <TabIcon label="Hubs" glyph="🏛" focused={focused} />
            ),
          }}
        />
        <Tabs.Screen
          name="chats"
          options={{
            tabBarIcon: ({ focused }: { focused: boolean }) => (
              <TabIcon label="Chats" glyph="💬" focused={focused} />
            ),
          }}
        />
        <Tabs.Screen
          name="profile"
          options={{
            tabBarIcon: ({ focused }: { focused: boolean }) => (
              <TabIcon label="Me" glyph="🎓" focused={focused} />
            ),
          }}
        />
        <Tabs.Screen name="chat/[id]" options={{ href: null }} />
        <Tabs.Screen name="thread/[id]" options={{ href: null }} />
      </Tabs>
    </>
  );
}
