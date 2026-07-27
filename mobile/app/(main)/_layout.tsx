import { Tabs } from 'expo-router';
import { Pressable, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import type { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { COLORS } from '../../theme/tokens';

const TABS = [
  { name: 'home',    label: 'Home',    activeIcon: 'home',                    inactiveIcon: 'home-outline' },
  { name: 'explore', label: 'Explore', activeIcon: 'compass',                 inactiveIcon: 'compass-outline' },
  { name: 'match',   label: 'Match',   activeIcon: 'people',                  inactiveIcon: 'people-outline' },
  { name: 'chat',    label: 'Chat',    activeIcon: 'chatbubble-ellipses',     inactiveIcon: 'chatbubble-ellipses-outline' },
  { name: 'profile', label: 'Profile', activeIcon: 'person',                  inactiveIcon: 'person-outline' },
] as const;

function MainTabBar({ state, navigation }: BottomTabBarProps) {
  const insets = useSafeAreaInsets();

  return (
    <View
      style={{ paddingBottom: insets.bottom + 4 }}
      className="flex-row bg-white border-t border-border px-2 pt-2"
    >
      {state.routes.map((route, i) => {
        const tab = TABS.find((t) => t.name === route.name);
        if (!tab) return null;
        const active = state.index === i;
        const iconName = (active ? tab.activeIcon : tab.inactiveIcon) as keyof typeof Ionicons.glyphMap;

        return (
          <Pressable
            key={route.key}
            onPress={() => navigation.navigate(route.name)}
            className="flex-1 items-center py-1 active:opacity-70"
          >
            <View
              className={`w-10 h-10 rounded-full items-center justify-center ${
                active ? 'bg-blue' : 'bg-transparent'
              }`}
            >
              <Ionicons
                name={iconName}
                size={22}
                color={active ? COLORS.white : COLORS.tertxt}
              />
            </View>
            <Text
              className={`text-[10px] mt-0.5 ${
                active ? 'font-body-semi text-blue' : 'font-body text-tertxt'
              }`}
            >
              {tab.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

export default function MainLayout() {
  return (
    <Tabs
      tabBar={(props) => <MainTabBar {...props} />}
      screenOptions={{ headerShown: false }}
    >
      <Tabs.Screen name="home" />
      <Tabs.Screen name="explore" />
      <Tabs.Screen name="match" />
      <Tabs.Screen name="chat" />
      <Tabs.Screen name="profile" />
    </Tabs>
  );
}
