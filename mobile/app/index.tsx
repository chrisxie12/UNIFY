import { useCallback, useEffect, useRef } from 'react';
import { Pressable } from 'react-native';
import Animated, {
  Easing,
  runOnJS,
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withTiming,
} from 'react-native-reanimated';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';

export default function SplashScreen() {
  const router    = useRouter();
  const navigated = useRef(false);

  // Animated values
  const screenOpacity  = useSharedValue(1);
  const logoOpacity    = useSharedValue(0);
  const logoScale      = useSharedValue(0.85);
  const logoY          = useSharedValue(20);
  const subtextOpacity = useSharedValue(0);
  const subtextY       = useSharedValue(10);

  const SPRING = { easing: Easing.bezier(0.16, 1, 0.3, 1) } as const;

  // Entrance animation
  useEffect(() => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    logoOpacity.value = withTiming(1, { duration: 800, ...SPRING });
    logoScale.value   = withTiming(1, { duration: 800, ...SPRING });
    logoY.value       = withTiming(0, { duration: 800, ...SPRING });

    subtextOpacity.value = withDelay(400, withTiming(1, { duration: 600 }));
    subtextY.value       = withDelay(400, withTiming(0, { duration: 600 }));

    // Auto-advance after 2.5s
    const timer = setTimeout(handleContinue, 2500);
    return () => clearTimeout(timer);
  }, []);

  const navigate = useCallback(() => {
    router.replace('/get-started');
  }, []);

  const handleContinue = useCallback(() => {
    if (navigated.current) return;
    navigated.current = true;

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

    // Exit animation
    screenOpacity.value = withTiming(0, { duration: 500 });
    logoScale.value     = withTiming(
      1.05,
      { duration: 500 },
      (done) => { 'worklet'; if (done) runOnJS(navigate)(); },
    );
  }, [navigate]);

  // Animated styles
  const screenStyle = useAnimatedStyle(() => ({
    opacity: screenOpacity.value,
  }));
  const logoStyle = useAnimatedStyle(() => ({
    opacity:   logoOpacity.value,
    transform: [{ scale: logoScale.value }, { translateY: logoY.value }],
  }));
  const subtextStyle = useAnimatedStyle(() => ({
    opacity:   subtextOpacity.value,
    transform: [{ translateY: subtextY.value }],
  }));

  return (
    <Animated.View style={[{ flex: 1, backgroundColor: '#0A0A0A' }, screenStyle]}>
      <Pressable
        onPress={handleContinue}
        style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}
      >
        {/* Wordmark */}
        <Animated.Text
          style={[
            {
              color: '#FFFFFF',
              fontSize: 56,
              letterSpacing: -2,
              fontFamily: 'ArchivoBlack',
            },
            logoStyle,
          ]}
        >
          UNIFY
        </Animated.Text>

        {/* Subtext */}
        <Animated.Text
          style={[
            {
              position: 'absolute',
              bottom: 48,
              left: 0,
              right: 0,
              textAlign: 'center',
              color: 'rgba(255,255,255,0.40)',
              fontSize: 14,
              fontFamily: 'Inter_500Medium',
            },
            subtextStyle,
          ]}
        >
          Built for Ghana's Class of '30
        </Animated.Text>
      </Pressable>
    </Animated.View>
  );
}
