import { useRef, useState } from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { FirebaseRecaptchaVerifierModal } from 'expo-firebase-recaptcha';
import { PhoneAuthProvider } from 'firebase/auth';
import { auth, firebaseConfig, isFirebaseConfigured } from '../../config/firebase';
import { useAppStore } from '../../store/useAppStore';
import { COLORS } from '../../theme/tokens';

export default function PhoneAuthScreen() {
  const router           = useRouter();
  const setPhone         = useAppStore((s) => s.setPhone);
  const setVerificationId = useAppStore((s) => s.setVerificationId);
  const setOtpSent       = useAppStore((s) => s.setOtpSent);

  const recaptchaRef = useRef<FirebaseRecaptchaVerifierModal>(null);

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
      if (isFirebaseConfigured) {
        // ── Real Firebase Phone Auth ──────────────────────────────────────
        const provider      = new PhoneAuthProvider(auth);
        const verificationId = await provider.verifyPhoneNumber(
          fullPhone,
          recaptchaRef.current!,
        );
        setVerificationId(verificationId);
      } else {
        // ── Dev mock (no Firebase config) ─────────────────────────────────
        setVerificationId('dev-mock-verification-id');
      }

      setPhone(fullPhone);
      setOtpSent(true);
      router.push('/auth/verify');
    } catch (e: any) {
      setError(e?.message ?? 'Failed to send code. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <SafeAreaView className="flex-1 bg-white">
      {/* Invisible reCAPTCHA — renders a modal only when challenge needed */}
      <FirebaseRecaptchaVerifierModal
        ref={recaptchaRef}
        firebaseConfig={firebaseConfig}
        attemptInvisibleVerification
      />

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

        {!isFirebaseConfigured && (
          <View className="mt-3 bg-[#FFF4EE] rounded-xl px-4 py-3">
            <Text className="font-body text-xs text-orange">
              Dev mode — Firebase not configured. Any code except ones starting with "1" will work.
            </Text>
          </View>
        )}

        {/* Continue button */}
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
