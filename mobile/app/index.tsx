import { useEffect, useRef } from 'react';
import { Animated, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { supabase } from '../lib/supabase';

export default function SplashScreen() {
  const router   = useRouter();
  const logoAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Fade logo in
    Animated.timing(logoAnim, {
      toValue: 1,
      duration: 600,
      useNativeDriver: true,
    }).start();

    // After 1.8s check session and navigate
    const timer = setTimeout(async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session) {
        router.replace('/(main)/home');
      } else {
        router.replace('/get-started');
      }
    }, 1800);

    return () => clearTimeout(timer);
  }, []);

  return (
    <>
      <StatusBar style="light" />
      <LinearGradient
        colors={['#1D4ED8', '#1E3A8A']}
        style={styles.container}
      >
        <Animated.View style={[styles.logoWrap, { opacity: logoAnim }]}>
          {/* Icon mark */}
          <View style={styles.iconCircle}>
            <Text style={styles.iconText}>U</Text>
          </View>
          <Text style={styles.wordmark}>UNIFY</Text>
        </Animated.View>
      </LinearGradient>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoWrap: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: 12,
  },
  iconCircle: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1.5,
    borderColor: 'rgba(255,255,255,0.4)',
  },
  iconText: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '900',
    letterSpacing: -0.5,
  },
  wordmark: {
    color: '#FFFFFF',
    fontSize: 32,
    fontWeight: '900',
    letterSpacing: -0.5,
  },
});
