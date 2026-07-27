import { useEffect, useRef } from 'react';
import { Animated, Dimensions, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { supabase } from '../lib/supabase';

const { width } = Dimensions.get('window');

export default function SplashScreen() {
  const router   = useRouter();
  const logoScale = useRef(new Animated.Value(0.8)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const textOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Entrance animations
    Animated.parallel([
      Animated.spring(logoScale, {
        toValue: 1,
        tension: 50,
        friction: 7,
        useNativeDriver: true,
      }),
      Animated.timing(logoOpacity, {
        toValue: 1,
        duration: 600,
        useNativeDriver: true,
      }),
    ]).start();

    Animated.timing(textOpacity, {
      toValue: 1,
      duration: 800,
      delay: 300,
      useNativeDriver: true,
    }).start();

    // Check session & navigate
    const timer = setTimeout(async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session) {
        router.replace('/(main)/home');
      } else {
        router.replace('/get-started');
      }
    }, 2000);

    return () => clearTimeout(timer);
  }, []);

  return (
    <>
      <StatusBar style="light" />
      <LinearGradient
        colors={['#0F2B66', '#0055FF', '#003F8A']}
        locations={[0, 0.6, 1]}
        style={styles.container}
      >
        {/* Decorative background circle */}
        <View style={styles.bgGlow} />

        <View style={styles.centerContent}>
          {/* Animated Logo Mark */}
          <Animated.View
            style={[
              styles.logoWrap,
              { opacity: logoOpacity, transform: [{ scale: logoScale }] },
            ]}
          >
            <View style={styles.iconCircle}>
              <Text style={styles.iconText}>U</Text>
            </View>
            <Text style={styles.wordmark}>UNIFY</Text>
          </Animated.View>

          {/* Subtitle / Tagline */}
          <Animated.View style={{ opacity: textOpacity }}>
            <View style={styles.badge}>
              <Text style={styles.badgeText}>GHANA CAMPUS NETWORK</Text>
            </View>
            <Text style={styles.tagline}>
              Verified Student Identity & Announcements
            </Text>
          </Animated.View>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <View style={styles.dotRow}>
            <View style={[styles.dot, styles.activeDot]} />
            <View style={styles.dot} />
            <View style={styles.dot} />
          </View>
        </View>
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
  bgGlow: {
    position: 'absolute',
    width: width * 1.2,
    height: width * 1.2,
    borderRadius: (width * 1.2) / 2,
    backgroundColor: 'rgba(255, 255, 255, 0.04)',
    top: '20%',
  },
  centerContent: {
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  logoWrap: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: 14,
    marginBottom: 20,
  },
  iconCircle: {
    width: 52,
    height: 52,
    borderRadius: 16,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.15,
    shadowRadius: 16,
    elevation: 8,
  },
  iconText: {
    color: '#0055FF',
    fontSize: 28,
    fontWeight: '900',
    letterSpacing: -0.5,
  },
  wordmark: {
    color: '#FFFFFF',
    fontSize: 38,
    fontWeight: '900',
    letterSpacing: -1,
  },
  badge: {
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 20,
    alignSelf: 'center',
    marginBottom: 8,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.25)',
  },
  badgeText: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1,
  },
  tagline: {
    color: 'rgba(255, 255, 255, 0.85)',
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
    lineHeight: 20,
  },
  footer: {
    position: 'absolute',
    bottom: 48,
    alignItems: 'center',
  },
  dotRow: {
    flexDirection: 'row',
    gap: 6,
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
  },
  activeDot: {
    width: 18,
    backgroundColor: '#FFFFFF',
  },
});
