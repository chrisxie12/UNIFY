import { useState } from 'react';
import {
  Alert, KeyboardAvoidingView, Platform,
  Pressable, ScrollView, Text, TextInput, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { supabase } from '../../lib/supabase';
import { COLORS } from '../../theme/tokens';

type Mode = 'login' | 'signup';

export default function AuthScreen() {
  const router = useRouter();
  const { mode: initialMode } = useLocalSearchParams<{ mode?: string }>();

  const [mode, setMode]         = useState<Mode>((initialMode as Mode) || 'signup');
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [loading, setLoading]   = useState(false);

  const canSubmit =
    email.trim().includes('@') &&
    password.length >= 6 &&
    (mode === 'login' || fullName.trim().length > 1);

  async function handleSubmit() {
    if (!canSubmit || loading) return;
    setLoading(true);

    if (mode === 'login') {
      const { error } = await supabase.auth.signInWithPassword({
        email: email.trim().toLowerCase(),
        password,
      });
      setLoading(false);
      if (error) {
        Alert.alert('Sign in failed', error.message);
      } else {
        router.replace('/(main)/home');
      }
    } else {
      const { error } = await supabase.auth.signUp({
        email: email.trim().toLowerCase(),
        password,
        options: {
          data: { full_name: fullName.trim() },
        },
      });
      setLoading(false);
      if (error) {
        Alert.alert('Sign up failed', error.message);
      } else {
        // Auth trigger auto-creates profile row; go to onboarding
        router.replace('/onboarding');
      }
    }
  }

  return (
    <SafeAreaView className="flex-1 bg-white">
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <ScrollView
          contentContainerStyle={{ flexGrow: 1 }}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* Header */}
          <View className="flex-row items-center px-5 pt-4 pb-2">
            <Pressable
              onPress={() => router.back()}
              hitSlop={12}
              className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
            >
              <Text className="font-heading text-base text-primary">←</Text>
            </Pressable>
          </View>

          <View className="flex-1 px-6 pt-4 pb-10">
            <Text className="font-display text-[32px] leading-9 text-primary mb-1">
              {mode === 'login' ? 'Welcome back' : 'Create account'}
            </Text>
            <Text className="font-body text-sm text-secondary mb-8 leading-5">
              {mode === 'login'
                ? 'Sign in to your UNIFY account.'
                : 'Join GCTU — your campus hub awaits.'}
            </Text>

            {/* Mode toggle */}
            <View className="bg-surface rounded-2xl p-1 flex-row mb-8">
              {(['signup', 'login'] as Mode[]).map((m) => (
                <Pressable
                  key={m}
                  onPress={() => setMode(m)}
                  className={`flex-1 py-2.5 rounded-xl items-center ${
                    mode === m ? 'bg-white' : ''
                  }`}
                  style={mode === m ? {
                    shadowColor: '#000',
                    shadowOffset: { width: 0, height: 1 },
                    shadowOpacity: 0.08,
                    shadowRadius: 3,
                    elevation: 2,
                  } : undefined}
                >
                  <Text className={`font-body-semi text-sm ${
                    mode === m ? 'text-primary' : 'text-tertxt'
                  }`}>
                    {m === 'signup' ? 'Sign Up' : 'Log In'}
                  </Text>
                </Pressable>
              ))}
            </View>

            {/* Fields */}
            <View className="gap-4">
              {mode === 'signup' && (
                <View>
                  <Text className="font-body-semi text-sm text-primary mb-2">Full name</Text>
                  <TextInput
                    placeholder="e.g. Kwame Acheampong"
                    placeholderTextColor={COLORS.tertxt}
                    value={fullName}
                    onChangeText={setFullName}
                    autoCapitalize="words"
                    returnKeyType="next"
                    className="bg-surface rounded-2xl border border-border px-5 h-14 font-body text-sm text-primary"
                  />
                </View>
              )}

              <View>
                <Text className="font-body-semi text-sm text-primary mb-2">Email</Text>
                <TextInput
                  placeholder="you@students.gctu.edu.gh"
                  placeholderTextColor={COLORS.tertxt}
                  value={email}
                  onChangeText={setEmail}
                  autoCapitalize="none"
                  keyboardType="email-address"
                  autoComplete="email"
                  returnKeyType="next"
                  className="bg-surface rounded-2xl border border-border px-5 h-14 font-body text-sm text-primary"
                />
              </View>

              <View>
                <Text className="font-body-semi text-sm text-primary mb-2">Password</Text>
                <TextInput
                  placeholder={mode === 'signup' ? 'At least 6 characters' : '••••••••'}
                  placeholderTextColor={COLORS.tertxt}
                  value={password}
                  onChangeText={setPassword}
                  secureTextEntry
                  returnKeyType="done"
                  onSubmitEditing={handleSubmit}
                  className="bg-surface rounded-2xl border border-border px-5 h-14 font-body text-sm text-primary"
                />
              </View>
            </View>

            <Pressable
              onPress={handleSubmit}
              disabled={!canSubmit || loading}
              className={`mt-8 rounded-full py-4 items-center ${
                canSubmit ? 'bg-btn-primary active:opacity-80' : 'bg-surface'
              }`}
            >
              <Text className={`font-body-semi text-base ${
                canSubmit ? 'text-white' : 'text-tertxt'
              }`}>
                {loading
                  ? mode === 'login' ? 'Signing in…' : 'Creating account…'
                  : mode === 'login' ? 'Sign In' : 'Create Account'}
              </Text>
            </Pressable>

            {mode === 'login' && (
              <Pressable className="mt-4 items-center active:opacity-70">
                <Text className="font-body text-sm text-blue">Forgot password?</Text>
              </Pressable>
            )}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
