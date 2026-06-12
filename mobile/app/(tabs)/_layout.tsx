import { Tabs } from 'expo-router';
import { Pressable, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import type { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import { POP_BG, type PopAccent } from '../../theme/tokens';

interface TabConfig {
  readonly label: string;
  readonly glyph: string;
  readonly accent: PopAccent;
}

const TAB_CONFIG: Record<string, TabConfig> = {
  index: { label: 'Dashboard', glyph: '📊', accent: 'yellow' },
  schedule: { label: 'Schedule', glyph: '🗓', accent: 'blue' },
  network: { label: 'Network', glyph: '🌐', accent: 'green' },
};

// Fully custom tab bar: a parchment slab with a thick black top rule.
// The focused tab becomes a vibrant bordered block sitting on a hard
// shadow; unfocused tabs keep an invisible border of the same width so
// nothing shifts when focus moves.
function NBTabBar({ state, navigation }: BottomTabBarProps) {
  const insets = useSafeAreaInsets();
  return (
    <View
      className="bg-parchment border-t-4 border-black px-3 pt-2.5"
      style={{ paddingBottom: Math.max(insets.bottom, 10) }}
    >
      <View className="flex-row gap-2.5">
        {state.routes.map((route, index) => {
          const config = TAB_CONFIG[route.name];
          if (!config) return null;
          const focused = state.index === index;

          const onPress = () => {
            const event = navigation.emit({
              type: 'tabPress',
              target: route.key,
              canPreventDefault: true,
            });
            if (!focused && !event.defaultPrevented) {
              navigation.navigate(route.name, route.params);
            }
          };

          return (
            <Pressable
              key={route.key}
              onPress={onPress}
              accessibilityRole="button"
              accessibilityState={focused ? { selected: true } : {}}
              accessibilityLabel={config.label}
              className={`flex-1 items-center justify-center py-2 rounded-none ${
                focused
                  ? `${POP_BG[config.accent]} border-4 border-black shadow-nb-sm`
                  : 'border-4 border-transparent'
              }`}
            >
              <Text className="text-base">{config.glyph}</Text>
              <Text
                className={`text-[10px] font-heading uppercase tracking-tight ${
                  focused ? 'text-black' : 'text-[#555]'
                }`}
              >
                {config.label}
              </Text>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

export default function TabsLayout() {
  return (
    <Tabs
      tabBar={(props: BottomTabBarProps) => <NBTabBar {...props} />}
      screenOptions={{ headerShown: false }}
    >
      <Tabs.Screen name="index" options={{ title: 'Dashboard' }} />
      <Tabs.Screen name="schedule" options={{ title: 'Schedule' }} />
      <Tabs.Screen name="network" options={{ title: 'Network' }} />
    </Tabs>
  );
}
