import { useState } from 'react';
import {
  ActivityIndicator, KeyboardAvoidingView, Platform,
  Pressable, ScrollView, StyleSheet, Text, TextInput, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { supabase } from '../../lib/supabase';
import { COLORS } from '../../theme/tokens';

const SCHOOLS = ['GCTU', 'KNUST', 'UG Legon', 'UCC', 'UPSA', 'UDS'];

export default function AuthScreen() {
  const router = useRouter();
  const params = useLocalSearchParams<{ mode?: string }>();

  const [isSignUp, setIsSignUp]     = useState(params.mode === 'signup');
  const [email, setEmail]           = useState('');
  const [password, setPassword]     = useState('');
  const [fullName, setFullName]     = useState('');
  const [school, setSchool]         = useState('GCTU');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading]       = useState(false);
  const [error, setError]           = useState('');

  function toggleMode(signUp: boolean) {
    Haptics.selectionAsync();
    setError('');
    setIsSignUp(signUp);
  }

  async function handleAuth() {
    setError('');
    if (!email.trim() || !password) {
      setError('Please enter your email and password.');
      return;
    }
    if (isSignUp && !fullName.trim()) {
      setError('Please enter your full name.');
      return;
    }

    setLoading(true);
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

    try {
      if (isSignUp) {
        const { data, error: signUpErr } = await supabase.auth.signUp({
          email: email.trim(),
          password,
          options: {
            data: { full_name: fullName.trim(), school },
          },
        });
        if (signUpErr) throw signUpErr;

        // Route to onboarding or home
        if (data.session) {
          router.replace('/onboarding');
        } else {
          // Confirmation required
          router.replace('/onboarding');
        }
      } else {
        const { error: signInErr } = await supabase.auth.signInWithPassword({
          email: email.trim(),
          password,
        });
        if (signInErr) throw signInErr;
        router.replace('/(main)/home');
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <StatusBar style="dark" />
      <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={{ flex: 1 }}
        >
          <ScrollView
            contentContainerStyle={styles.scrollContent}
            showsVerticalScrollIndicator={false}
            keyboardShouldPersistTaps="handled"
          >
            {/* Nav Back Header */}
            <View style={styles.topHeader}>
              <Pressable
                onPress={() => router.back()}
                hitSlop={12}
                style={styles.backBtn}
              >
                <Ionicons name="arrow-back" size={20} color={COLORS.primary} />
              </Pressable>
              <View style={styles.logoBadge}>
                <View style={styles.logoIcon}>
                  <Text style={styles.logoText}>U</Text>
                </View>
                <Text style={styles.logoTitle}>UNIFY</Text>
              </View>
            </View>

            {/* Mode Switcher Pills */}
            <View style={styles.tabContainer}>
              <Pressable
                onPress={() => toggleMode(false)}
                style={[styles.tab, !isSignUp && styles.activeTab]}
              >
                <Text style={[styles.tabText, !isSignUp && styles.activeTabText]}>
                  Sign In
                </Text>
              </Pressable>
              <Pressable
                onPress={() => toggleMode(true)}
                style={[styles.tab, isSignUp && styles.activeTab]}
              >
                <Text style={[styles.tabText, isSignUp && styles.activeTabText]}>
                  Sign Up
                </Text>
              </Pressable>
            </View>

            {/* Title & Subtitle */}
            <View style={styles.titleSection}>
              <Text style={styles.heading}>
                {isSignUp ? 'Create your account' : 'Welcome back 👋'}
              </Text>
              <Text style={styles.subheading}>
                {isSignUp
                  ? 'Connect with verified students across campus.'
                  : 'Enter your credentials to access your UNIFY feed.'}
              </Text>
            </View>

            {/* Form Fields */}
            <View style={styles.form}>
              {/* Full Name (Sign Up only) */}
              {isSignUp && (
                <View style={styles.field}>
                  <Text style={styles.label}>Full Name</Text>
                  <View style={styles.inputWrap}>
                    <Ionicons name="person-outline" size={18} color="#9CA3AF" style={styles.inputIcon} />
                    <TextInput
                      placeholder="e.g. Kwame Acheampong"
                      placeholderTextColor="#9CA3AF"
                      value={fullName}
                      onChangeText={setFullName}
                      style={styles.input}
                    />
                  </View>
                </View>
              )}

              {/* School selection (Sign Up only) */}
              {isSignUp && (
                <View style={styles.field}>
                  <Text style={styles.label}>University / Campus</Text>
                  <ScrollView
                    horizontal
                    showsHorizontalScrollIndicator={false}
                    contentContainerStyle={{ gap: 8 }}
                  >
                    {SCHOOLS.map((s) => (
                      <Pressable
                        key={s}
                        onPress={() => setSchool(s)}
                        style={[styles.schoolChip, school === s && styles.schoolChipActive]}
                      >
                        <Text style={[styles.schoolChipText, school === s && styles.schoolChipTextActive]}>
                          {s}
                        </Text>
                      </Pressable>
                    ))}
                  </ScrollView>
                </View>
              )}

              {/* Email Address */}
              <View style={styles.field}>
                <Text style={styles.label}>Student Email</Text>
                <View style={styles.inputWrap}>
                  <Ionicons name="mail-outline" size={18} color="#9CA3AF" style={styles.inputIcon} />
                  <TextInput
                    placeholder="you@gctu.edu.gh"
                    placeholderTextColor="#9CA3AF"
                    value={email}
                    onChangeText={setEmail}
                    keyboardType="email-address"
                    autoCapitalize="none"
                    style={styles.input}
                  />
                </View>
              </View>

              {/* Password */}
              <View style={styles.field}>
                <Text style={styles.label}>Password</Text>
                <View style={styles.inputWrap}>
                  <Ionicons name="lock-closed-outline" size={18} color="#9CA3AF" style={styles.inputIcon} />
                  <TextInput
                    placeholder="Enter password"
                    placeholderTextColor="#9CA3AF"
                    value={password}
                    onChangeText={setPassword}
                    secureTextEntry={!showPassword}
                    style={[styles.input, { flex: 1 }]}
                  />
                  <Pressable
                    onPress={() => setShowPassword(!showPassword)}
                    hitSlop={8}
                    style={styles.eyeBtn}
                  >
                    <Ionicons
                      name={showPassword ? 'eye-off-outline' : 'eye-outline'}
                      size={20}
                      color="#9CA3AF"
                    />
                  </Pressable>
                </View>
              </View>

              {/* Error Banner */}
              {error ? (
                <View style={styles.errorBanner}>
                  <Ionicons name="alert-circle-outline" size={16} color="#EF4444" />
                  <Text style={styles.errorText}>{error}</Text>
                </View>
              ) : null}

              {/* Submit Button */}
              <Pressable
                onPress={handleAuth}
                disabled={loading}
                style={({ pressed }) => [
                  styles.submitBtn,
                  pressed && { opacity: 0.9 },
                  loading && { opacity: 0.6 },
                ]}
              >
                {loading ? (
                  <ActivityIndicator color="#FFFFFF" size="small" />
                ) : (
                  <Text style={styles.submitBtnText}>
                    {isSignUp ? 'Create Account' : 'Sign In'}
                  </Text>
                )}
              </Pressable>

              {/* Divider */}
              <View style={styles.dividerRow}>
                <View style={styles.dividerLine} />
                <Text style={styles.dividerText}>or continue with</Text>
                <View style={styles.dividerLine} />
              </View>

              {/* Quick Login Options */}
              <View style={styles.socialRow}>
                <Pressable style={styles.socialBtn} onPress={() => handleAuth()}>
                  <Text style={styles.socialText}>Google</Text>
                </Pressable>
                <Pressable style={styles.socialBtn} onPress={() => handleAuth()}>
                  <Text style={styles.socialText}>Phone OTP</Text>
                </Pressable>
              </View>
            </View>

            {/* Bottom Toggle Footer */}
            <View style={styles.bottomRow}>
              <Text style={styles.bottomText}>
                {isSignUp ? 'Already have an account?' : "Don't have an account?"}
              </Text>
              <Pressable onPress={() => toggleMode(!isSignUp)}>
                <Text style={styles.bottomLink}>
                  {isSignUp ? 'Sign In' : 'Sign Up'}
                </Text>
              </Pressable>
            </View>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingBottom: 32,
  },
  topHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 12,
    marginBottom: 16,
  },
  backBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#F8F9FA',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  logoBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  logoIcon: {
    width: 28,
    height: 28,
    borderRadius: 8,
    backgroundColor: '#0055FF',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '900',
  },
  logoTitle: {
    color: '#111827',
    fontSize: 16,
    fontWeight: '800',
  },

  // Tabs
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#F8F9FA',
    borderRadius: 16,
    padding: 4,
    marginBottom: 24,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  tab: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 12,
  },
  activeTab: {
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 6,
    elevation: 2,
  },
  tabText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#9CA3AF',
  },
  activeTabText: {
    color: '#111827',
  },

  // Title
  titleSection: {
    marginBottom: 24,
  },
  heading: {
    fontSize: 26,
    fontWeight: '800',
    color: '#111827',
    marginBottom: 6,
    letterSpacing: -0.5,
  },
  subheading: {
    fontSize: 14,
    color: '#4B5563',
    lineHeight: 20,
  },

  // Form
  form: {
    gap: 16,
  },
  field: {
    gap: 6,
  },
  label: {
    fontSize: 13,
    fontWeight: '600',
    color: '#374151',
  },
  inputWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    paddingHorizontal: 14,
    height: 50,
  },
  inputIcon: {
    marginRight: 10,
  },
  input: {
    flex: 1,
    fontSize: 14,
    color: '#111827',
  },
  eyeBtn: {
    padding: 4,
  },

  // School chips
  schoolChip: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#F8F9FA',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  schoolChipActive: {
    backgroundColor: '#0055FF',
    borderColor: '#0055FF',
  },
  schoolChipText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#374151',
  },
  schoolChipTextActive: {
    color: '#FFFFFF',
  },

  // Error
  errorBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: '#FEF2F2',
    borderWidth: 1,
    borderColor: '#FEE2E2',
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  errorText: {
    color: '#DC2626',
    fontSize: 12,
    fontWeight: '500',
    flex: 1,
  },

  // Submit
  submitBtn: {
    backgroundColor: '#0055FF',
    borderRadius: 16,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 8,
    shadowColor: '#0055FF',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 10,
    elevation: 4,
  },
  submitBtnText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },

  // Divider
  dividerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 12,
    gap: 12,
  },
  dividerLine: {
    flex: 1,
    height: 1,
    backgroundColor: '#E5E7EB',
  },
  dividerText: {
    fontSize: 12,
    color: '#9CA3AF',
  },

  // Social
  socialRow: {
    flexDirection: 'row',
    gap: 12,
  },
  socialBtn: {
    flex: 1,
    height: 48,
    borderRadius: 14,
    backgroundColor: '#F8F9FA',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    alignItems: 'center',
    justifyContent: 'center',
  },
  socialText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#111827',
  },

  // Bottom
  bottomRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 6,
    marginTop: 24,
  },
  bottomText: {
    fontSize: 13,
    color: '#6B7280',
  },
  bottomLink: {
    fontSize: 13,
    fontWeight: '700',
    color: '#0055FF',
  },
});
