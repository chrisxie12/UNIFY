import { Tabs } from 'expo-router';
import { Pressable, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import type { BottomTabBarProps } from '@react-navigation/bottom-tabs';

interface TabConfig {
  readonly label: string;
  readonly glyph: string;
}

const TAB_CONFIG: Record<string, TabConfig> = {
  index: { label: 'Dashboard', glyph: '📊' },
  schedule: { label: 'Schedule', glyph: '🗓' },
  network: { label: 'Network', glyph: '🌐' },
};

function CleanTabBar({ state, navigation }: BottomTabBarProps) {
  const insets = useSafeAreaInsets();
  return (
    <View
      className="bg-white border-t border-divider px-4 pt-3"
      style={{ paddingBottom: Math.max(insets.bottom, 12) }}
    >
      <View className="flex-row gap-2">
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
              className={`flex-1 items-center justify-center py-2 rounded-full ${
                focused ? 'bg-accent' : ''
              } active:opacity-75`}
            >
              <Text className="text-base leading-5">{config.glyph}</Text>
              <Text
                className={`text-[10px] font-heading mt-0.5 ${
                  focused ? 'text-white' : 'text-muted'
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
      tabBar={(props: BottomTabBarProps) => <CleanTabBar {...props} />}
      screenOptions={{ headerShown: false }}
    >
      <Tabs.Screen name="index" options={{ title: 'Dashboard' }} />
      <Tabs.Screen name="schedule" options={{ title: 'Schedule' }} />
      <Tabs.Screen name="network" options={{ title: 'Network' }} />
    </Tabs>
  );
}
