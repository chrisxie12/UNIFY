import { useEffect, useRef } from 'react';
import { Animated, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';

export default function SplashScreen() {
  const router = useRouter();
  const fadeAnim  = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(32)).current;
  const btnAnim   = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.sequence([
      Animated.parallel([
        Animated.timing(fadeAnim,  { toValue: 1, duration: 700, useNativeDriver: true }),
        Animated.timing(slideAnim, { toValue: 0, duration: 700, useNativeDriver: true }),
      ]),
      Animated.timing(btnAnim, { toValue: 1, duration: 400, delay: 100, useNativeDriver: true }),
    ]).start();
  }, []);

  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-1 px-8 justify-center">
        {/* Wordmark */}
        <Animated.View style={{ opacity: fadeAnim, transform: [{ translateY: slideAnim }] }}>
          <View className="mb-2">
            <Text className="font-display text-[56px] leading-[60px] text-primary tracking-tight">
              UNIFY
            </Text>
            {/* Orange scribble underline */}
            <View className="h-[5px] w-28 bg-orange rounded-full mt-1" />
          </View>

          <Text className="font-body-medium text-lg text-secondary mt-5 leading-7">
            Find your people,{'\n'}find your place.
          </Text>

          <Text className="font-body text-sm text-tertxt mt-3 leading-6">
            Match with roommates. Join your campus hub.{'\n'}
            Built for Ghanaian students.
          </Text>
        </Animated.View>

        {/* CTA */}
        <Animated.View style={{ opacity: btnAnim }} className="mt-14">
          <Pressable
            onPress={() => router.push('/get-started')}
            className="bg-btn-primary rounded-full py-4 items-center active:opacity-80"
          >
            <Text className="text-white font-body-semi text-base">Get Started</Text>
          </Pressable>

          <Pressable
            onPress={() => router.push('/get-started')}
            className="mt-4 items-center active:opacity-70"
          >
            <Text className="text-tertxt text-sm font-body">
              Already have an account?{' '}
              <Text className="text-blue font-body-semi">Sign in</Text>
            </Text>
          </Pressable>
        </Animated.View>
      </View>

      {/* Bottom decoration */}
      <View className="px-8 pb-8">
        <Text className="text-[11px] font-body text-tertxt text-center">
          By continuing you agree to our Terms of Service
        </Text>
      </View>
    </SafeAreaView>
  );
}
