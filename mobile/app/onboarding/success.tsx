import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';

export default function OnboardingSuccessScreen() {
  const router = useRouter();

  const scaleAnim   = useRef(new Animated.Value(0.6)).current;
  const opacityAnim = useRef(new Animated.Value(0)).current;
  const textAnim    = useRef(new Animated.Value(20)).current;
  const textOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

    Animated.parallel([
      Animated.spring(scaleAnim, { toValue: 1, tension: 60, friction: 8, useNativeDriver: true }),
      Animated.timing(opacityAnim, { toValue: 1, duration: 400, useNativeDriver: true }),
    ]).start();

    Animated.sequence([
      Animated.delay(200),
      Animated.parallel([
        Animated.timing(textAnim, { toValue: 0, duration: 500, useNativeDriver: true }),
        Animated.timing(textOpacity, { toValue: 1, duration: 500, useNativeDriver: true }),
      ]),
    ]).start();

    const timer = setTimeout(() => {
      Animated.timing(opacityAnim, { toValue: 0, duration: 400, useNativeDriver: true }).start(() => {
        router.replace('/(main)/home');
      });
    }, 1800);

    return () => clearTimeout(timer);
  }, []);

  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-1 items-center justify-center px-8">
        <Animated.View style={{ transform: [{ scale: scaleAnim }], opacity: opacityAnim }}>
          <View className="w-32 h-32 rounded-full bg-[#ECFDF5] items-center justify-center mb-6">
            <Text style={{ fontSize: 64 }}>🔥</Text>
          </View>
        </Animated.View>

        <Animated.View style={{ opacity: textOpacity, transform: [{ translateY: textAnim }] }}>
          <Text className="font-display text-[36px] text-primary text-center leading-tight mb-3">
            You&apos;re in!
          </Text>
          <Text className="font-body text-base text-secondary text-center leading-6">
            Your profile is set up.{'\n'}
            Time to find your campus fam.
          </Text>
        </Animated.View>
      </View>
    </SafeAreaView>
  );
}
