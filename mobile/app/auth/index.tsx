import { useState } from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import type { ApplicationVerifier } from 'firebase/auth';
import { useAppStore } from '../../store/useAppStore';
import { getFirebaseAuth } from '../../config/firebase';
import { COLORS } from '../../theme/tokens';

// expo-firebase-recaptcha requires expo-firebase-core native module which is
// NOT bundled in Expo Go. Use a mock verifier instead — this works with
// Firebase test phone numbers configured in the Firebase console.
// For production builds, replace with a real RecaptchaVerifier or dev client.
const MOCK_VERIFIER: ApplicationVerifier = {
  type: 'recaptcha',
  verify: () => Promise.resolve('expo-go-mock-token'),
};

export default function PhoneAuthScreen() {
  const router            = useRouter();
  const setPhone          = useAppStore((s) => s.setPhone);
  const setVerificationId = useAppStore((s) => s.setVerificationId);
  const setOtpSent        = useAppStore((s) => s.setOtpSent);

  const [number, setNumber]   = useState('');
  const [loading, setLoading] = useState(false);
  const [focused, setFocused] = useState(false);
  const [error, setError]     = useState('');

  const digits      = number.replace(/\D/g, '');
  const canContinue = digits.length >= 9 && !loading;
  const fullPhone   = `+233${digits}`;

  async function handleContinue() {
    if (!canContinue) return;
    setError('');
    setLoading(true);
    try {
      const { signInWithPhoneNumber } = require('firebase/auth') as typeof import('firebase/auth');
      const auth = getFirebaseAuth();
      const result = await signInWithPhoneNumber(auth, fullPhone, MOCK_VERIFIER);
      setVerificationId(result.verificationId);
      setPhone(fullPhone);
      setOtpSent(true);
      router.push('/auth/verify');
    } catch (e: any) {
      const msg =
        e?.code === 'auth/invalid-phone-number'
          ? 'Invalid phone number. Include country code +233.'
          : e?.code === 'auth/too-many-requests'
          ? 'Too many attempts. Please wait and try again.'
          : e?.message ?? 'Failed to send code. Please try again.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-row items-center px-5 pt-4 pb-2">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
      </View>

      <View className="flex-1 px-6 pt-6">
        <Text className="font-display text-[32px] leading-9 text-primary mb-2">
          What's your{'\n'}number?
        </Text>
        <Text className="font-body text-sm text-secondary mb-10 leading-5">
          We'll send a 6-digit code to verify your identity.
        </Text>

        {/* Phone input */}
        <View
          className={`flex-row items-center bg-surface rounded-2xl border h-14 px-4 ${
            error ? 'border-red' : focused ? 'border-blue' : 'border-border'
          }`}
        >
          <View className="flex-row items-center gap-2 pr-3 border-r border-border mr-3">
            <Text className="text-xl">🇬🇭</Text>
            <Text className="font-body-semi text-sm text-primary">+233</Text>
          </View>
          <TextInput
            placeholder="XX XXX XXXX"
            placeholderTextColor={COLORS.tertxt}
            value={number}
            onChangeText={(t) => { setNumber(t); setError(''); }}
            keyboardType="phone-pad"
            maxLength={12}
            autoFocus
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            className="flex-1 font-body-semi text-base text-primary"
          />
        </View>

        {error ? (
          <Text className="font-body text-xs text-red mt-2">{error}</Text>
        ) : (
          <Text className="font-body text-xs text-tertxt mt-2">
            Standard SMS rates may apply.
          </Text>
        )}

        <Pressable
          onPress={handleContinue}
          disabled={!canContinue}
          className={`mt-10 rounded-full py-4 items-center ${
            canContinue ? 'bg-btn-primary active:opacity-80' : 'bg-surface'
          }`}
        >
          <Text className={`font-body-semi text-base ${canContinue ? 'text-white' : 'text-tertxt'}`}>
            {loading ? 'Sending…' : 'Continue'}
          </Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}
