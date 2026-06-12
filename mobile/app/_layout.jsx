import { Tabs } from 'expo-router';
import { Text, View } from 'react-native';
import { useFonts } from 'expo-font';
import { ArchivoBlack_400Regular } from '@expo-google-fonts/archivo-black';
import { SpaceGrotesk_500Medium, SpaceGrotesk_700Bold } from '@expo-google-fonts/space-grotesk';
import { Inter_400Regular, Inter_500Medium, Inter_700Bold } from '@expo-google-fonts/inter';
import { StatusBar } from 'expo-status-bar';
import { COLORS } from '../theme/tokens';
import '../global.css';

function TabIcon({ label, glyph, focused }) {
  return (
    <View
      style={{
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: focused ? COLORS.action : 'transparent',
        borderWidth: focused ? 2 : 0,
        borderColor: COLORS.ink,
        paddingHorizontal: 10,
        paddingVertical: 2,
        minWidth: 64,
      }}
    >
      <Text style={{ fontSize: 16 }}>{glyph}</Text>
      <Text
        style={{
          fontSize: 9,
          fontFamily: 'Inter_700Bold',
          color: COLORS.text,
          textTransform: 'uppercase',
          letterSpacing: 0.5,
        }}
      >
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
            borderTopWidth: 2,
            borderTopColor: COLORS.ink,
            height: 64,
            paddingTop: 8,
          },
        }}
      >
        <Tabs.Screen
          name="index"
          options={{
            tabBarIcon: ({ focused }) => <TabIcon label="Hubs" glyph="🏛" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="chats"
          options={{
            tabBarIcon: ({ focused }) => <TabIcon label="Chats" glyph="💬" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="profile"
          options={{
            tabBarIcon: ({ focused }) => <TabIcon label="Me" glyph="🎓" focused={focused} />,
          }}
        />
        <Tabs.Screen name="chat/[id]" options={{ href: null }} />
        <Tabs.Screen name="thread/[id]" options={{ href: null }} />
      </Tabs>
    </>
  );
}
