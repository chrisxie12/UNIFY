import { Dimensions, Pressable, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';

const { height: SCREEN_H } = Dimensions.get('window');
const HERO_HEIGHT = SCREEN_H * 0.52;

export default function GetStartedScreen() {
  const router = useRouter();

  function goSignUp() {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.push({ pathname: '/auth', params: { mode: 'signup' } });
  }

  function goLogIn() {
    Haptics.selectionAsync();
    router.push({ pathname: '/auth', params: { mode: 'login' } });
  }

  return (
    <>
      <StatusBar style="light" />
      <View style={styles.root}>
        {/* ── Blue hero half ── */}
        <LinearGradient
          colors={['#1D4ED8', '#1E3A8A']}
          style={styles.hero}
        >
          {/* Top-left logo */}
          <SafeAreaView edges={['top']} style={styles.logoRow}>
            <View style={styles.logoMark}>
              <Text style={styles.logoLetter}>U</Text>
            </View>
            <Text style={styles.logoName}>UNIFY</Text>
          </SafeAreaView>

          {/* 3D-style hero illustration */}
          <View style={styles.illustrationWrap}>
            <View style={styles.illustrationCircle}>
              <Text style={styles.illustrationEmoji}>📢</Text>
            </View>
            {/* Sparkle accent */}
            <Text style={styles.sparkle}>✦</Text>
          </View>
        </LinearGradient>

        {/* ── White CTA half ── */}
        <View style={styles.sheet}>
          <Text style={styles.headline}>
            Your campus,{'\n'}connected.
          </Text>
          <Text style={styles.sub}>
            Announcements, updates, and community — built for GCTU students.
          </Text>

          <Pressable
            onPress={goSignUp}
            style={({ pressed }) => [styles.btnPrimary, pressed && { opacity: 0.85 }]}
          >
            <Text style={styles.btnPrimaryText}>Get Started</Text>
          </Pressable>

          <Pressable
            onPress={goLogIn}
            style={({ pressed }) => [styles.btnSecondary, pressed && { opacity: 0.7 }]}
          >
            <Text style={styles.btnSecondaryText}>I already have an account</Text>
          </Pressable>

          <Text style={styles.fine}>
            By continuing, you agree to our{' '}
            <Text style={styles.fineLink}>Terms of Service</Text> and{' '}
            <Text style={styles.fineLink}>Privacy Policy</Text>.
          </Text>
        </View>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },

  // Hero
  hero: {
    height: HERO_HEIGHT,
    paddingHorizontal: 24,
  },
  logoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  logoMark: {
    width: 32,
    height: 32,
    borderRadius: 9,
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderWidth: 1.5,
    borderColor: 'rgba(255,255,255,0.35)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoLetter: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '900',
  },
  logoName: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '800',
    letterSpacing: -0.3,
  },

  // Illustration
  illustrationWrap: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  illustrationCircle: {
    width: 160,
    height: 160,
    borderRadius: 80,
    backgroundColor: 'rgba(255,255,255,0.15)',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 20 },
    shadowOpacity: 0.3,
    shadowRadius: 40,
    elevation: 12,
  },
  illustrationEmoji: {
    fontSize: 80,
  },
  sparkle: {
    position: 'absolute',
    top: '15%',
    right: '18%',
    fontSize: 28,
    color: '#FFFFFF',
    opacity: 0.9,
  },

  // White sheet
  sheet: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    marginTop: -28,
    paddingHorizontal: 24,
    paddingTop: 32,
    paddingBottom: 20,
  },
  headline: {
    fontSize: 28,
    fontWeight: '800',
    color: '#111827',
    lineHeight: 34,
    letterSpacing: -0.5,
    marginBottom: 10,
  },
  sub: {
    fontSize: 14,
    color: '#6B7280',
    lineHeight: 20,
    marginBottom: 28,
  },

  // Buttons
  btnPrimary: {
    backgroundColor: '#111827',
    borderRadius: 14,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  btnPrimaryText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '700',
    letterSpacing: 0.1,
  },
  btnSecondary: {
    backgroundColor: '#F3F4F6',
    borderRadius: 14,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
  },
  btnSecondaryText: {
    color: '#374151',
    fontSize: 15,
    fontWeight: '600',
  },

  // Fine print
  fine: {
    fontSize: 11,
    color: '#9CA3AF',
    textAlign: 'center',
    lineHeight: 16,
  },
  fineLink: {
    textDecorationLine: 'underline',
  },
});
