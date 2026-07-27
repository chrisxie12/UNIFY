import { Dimensions, Pressable, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';

const { height: SCREEN_H } = Dimensions.get('window');
const HERO_HEIGHT = SCREEN_H * 0.52;

const FEATURES = [
  '⚡ Official Announcements',
  '🛡️ Verified ID',
  '🏠 Roommate Match',
];

export default function GetStartedScreen() {
  const router = useRouter();

  function goSignUp() {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.push('/auth' as any);
  }

  function goLogIn() {
    Haptics.selectionAsync();
    router.push('/auth' as any);
  }

  return (
    <>
      <StatusBar style="light" />
      <View style={styles.root}>
        {/* ── Blue hero section ── */}
        <LinearGradient
          colors={['#0F2B66', '#0055FF', '#1E3A8A']}
          style={styles.hero}
        >
          {/* Top Header Logo */}
          <SafeAreaView edges={['top']} style={styles.logoRow}>
            <View style={styles.logoMark}>
              <Text style={styles.logoLetter}>U</Text>
            </View>
            <Text style={styles.logoName}>UNIFY</Text>
            <View style={styles.ghanaBadge}>
              <Text style={styles.ghanaFlag}>🇬🇭</Text>
            </View>
          </SafeAreaView>

          {/* Hero Content */}
          <View style={styles.illustrationWrap}>
            <View style={styles.illustrationCircle}>
              <Text style={styles.illustrationEmoji}>📢</Text>
            </View>
            {/* Sparkle accent */}
            <Text style={styles.sparkle}>✦</Text>
            
            {/* Feature Pills */}
            <View style={styles.pillsRow}>
              {FEATURES.map((feat) => (
                <View key={feat} style={styles.featurePill}>
                  <Text style={styles.featureText}>{feat}</Text>
                </View>
              ))}
            </View>
          </View>
        </LinearGradient>

        {/* ── White Sheet Card ── */}
        <View style={styles.sheet}>
          <Text style={styles.headline}>
            Your campus,{'\n'}connected.
          </Text>
          <Text style={styles.sub}>
            Announcements, campus hubs, and roommate matching — built for Ghanaian university students.
          </Text>

          <Pressable
            onPress={goSignUp}
            style={({ pressed }) => [styles.btnPrimary, pressed && { opacity: 0.9, transform: [{ scale: 0.98 }] }]}
          >
            <Text style={styles.btnPrimaryText}>Create an Account</Text>
          </Pressable>

          <Pressable
            onPress={goLogIn}
            style={({ pressed }) => [styles.btnSecondary, pressed && { opacity: 0.8, transform: [{ scale: 0.98 }] }]}
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
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoLetter: {
    color: '#0055FF',
    fontSize: 18,
    fontWeight: '900',
  },
  logoName: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '900',
    letterSpacing: -0.5,
  },
  ghanaBadge: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 12,
    paddingHorizontal: 6,
    paddingVertical: 2,
    marginLeft: 4,
  },
  ghanaFlag: {
    fontSize: 12,
  },
  illustrationWrap: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    paddingBottom: 20,
  },
  illustrationCircle: {
    width: 130,
    height: 130,
    borderRadius: 65,
    backgroundColor: 'rgba(255,255,255,0.18)',
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.3)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.2,
    shadowRadius: 24,
    elevation: 8,
  },
  illustrationEmoji: {
    fontSize: 64,
  },
  sparkle: {
    position: 'absolute',
    top: '12%',
    right: '20%',
    fontSize: 24,
    color: '#FFFFFF',
    opacity: 0.9,
  },
  pillsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: 6,
  },
  featurePill: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 20,
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
  },
  featureText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '600',
  },
  sheet: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    marginTop: -28,
    paddingHorizontal: 24,
    paddingTop: 32,
    paddingBottom: 24,
  },
  headline: {
    fontSize: 28,
    fontWeight: '800',
    color: '#111827',
    lineHeight: 34,
    letterSpacing: -0.5,
    marginBottom: 8,
  },
  sub: {
    fontSize: 14,
    color: '#4B5563',
    lineHeight: 20,
    marginBottom: 24,
  },
  btnPrimary: {
    backgroundColor: '#0055FF',
    borderRadius: 16,
    height: 54,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
    shadowColor: '#0055FF',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 12,
    elevation: 4,
  },
  btnPrimaryText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  btnSecondary: {
    backgroundColor: '#F8F9FA',
    borderRadius: 16,
    height: 54,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    marginBottom: 20,
  },
  btnSecondaryText: {
    color: '#1F2937',
    fontSize: 15,
    fontWeight: '600',
  },
  fine: {
    fontSize: 11,
    color: '#9CA3AF',
    textAlign: 'center',
    lineHeight: 16,
  },
  fineLink: {
    textDecorationLine: 'underline',
    color: '#4B5563',
  },
});
