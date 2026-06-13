import { useCallback, useEffect, useRef, useState } from 'react';
import {
  Animated, Pressable, Text, TextInput, View,
  type TextInput as TextInputType,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { PhoneAuthProvider, signInWithCredential } from 'firebase/auth';
import { auth, isFirebaseConfigured } from '../../config/firebase';
import { useAppStore } from '../../store/useAppStore';

const OTP_LENGTH  = 6;
const RESEND_SECS = 45;

export default function OTPScreen() {
  const router          = useRouter();
  const phone           = useAppStore((s) => s.phone);
  const verificationId  = useAppStore((s) => s.verificationId);
  const setVerified     = useAppStore((s) => s.setVerified);

  const [digits, setDigits]     = useState<string[]>(Array(OTP_LENGTH).fill(''));
  const [activeIdx, setActiveIdx] = useState(0);
  const [countdown, setCountdown] = useState(RESEND_SECS);
  const [verifying, setVerifying] = useState(false);
  const [error, setError]         = useState('');
  const inputs    = useRef<(TextInputType | null)[]>([]);
  const shakeAnim = useRef(new Animated.Value(0)).current;

  // Countdown
  useEffect(() => {
    if (countdown <= 0) return;
    const id = setTimeout(() => setCountdown((c) => c - 1), 1000);
    return () => clearTimeout(id);
  }, [countdown]);

  function shake(msg = 'Incorrect code. Please try again.') {
    setError(msg);
    Animated.sequence([
      Animated.timing(shakeAnim, { toValue: 10,  duration: 50, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: -10, duration: 50, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: 8,   duration: 50, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: -8,  duration: 50, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: 0,   duration: 50, useNativeDriver: true }),
    ]).start(() => {
      setTimeout(() => {
        setError('');
        setDigits(Array(OTP_LENGTH).fill(''));
        inputs.current[0]?.focus();
        setActiveIdx(0);
      }, 800);
    });
  }

  const verify = useCallback(async (code: string) => {
    setVerifying(true);
    setError('');
    try {
      if (isFirebaseConfigured) {
        // ── Real Firebase verification ──────────────────────────────────
        const credential = PhoneAuthProvider.credential(verificationId, code);
        await signInWithCredential(auth, credential);
      } else {
        // ── Dev mock ────────────────────────────────────────────────────
        if (code.startsWith('1')) throw new Error('Invalid code (dev mock)');
        await new Promise((r) => setTimeout(r, 800)); // simulate network
      }
      setVerified(true);
      router.replace('/onboarding');
    } catch (e: any) {
      setVerifying(false);
      const msg =
        e?.code === 'auth/invalid-verification-code'
          ? 'Incorrect code. Please try again.'
          : e?.code === 'auth/code-expired'
          ? 'Code expired. Please request a new one.'
          : e?.message ?? 'Verification failed.';
      shake(msg);
    }
  }, [verificationId]);

  function handleChange(text: string, idx: number) {
    const char = text.replace(/\D/g, '').slice(-1);
    const next = [...digits];
    next[idx] = char;
    setDigits(next);

    if (char && idx < OTP_LENGTH - 1) {
      inputs.current[idx + 1]?.focus();
      setActiveIdx(idx + 1);
    }
    if (char && idx === OTP_LENGTH - 1) {
      const code = next.join('');
      if (code.length === OTP_LENGTH) verify(code);
    }
  }

  function handleKeyPress(key: string, idx: number) {
    if (key === 'Backspace' && !digits[idx] && idx > 0) {
      inputs.current[idx - 1]?.focus();
      setActiveIdx(idx - 1);
    }
  }

  function resend() {
    // Navigate back to re-trigger signInWithPhoneNumber
    router.back();
  }

  const hasError = error.length > 0;

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
          Enter the code
        </Text>
        <Text className="font-body text-sm text-secondary mb-10">
          Sent to{' '}
          <Text className="font-body-semi text-primary">{phone}</Text>
        </Text>

        {/* OTP boxes */}
        <Animated.View
          style={{ transform: [{ translateX: shakeAnim }] }}
          className="flex-row gap-3 justify-center mb-4"
        >
          {digits.map((d, i) => (
            <TextInput
              key={i}
              ref={(r) => { inputs.current[i] = r; }}
              value={d}
              onChangeText={(t) => handleChange(t, i)}
              onKeyPress={({ nativeEvent }) => handleKeyPress(nativeEvent.key, i)}
              onFocus={() => setActiveIdx(i)}
              keyboardType="numeric"
              maxLength={1}
              selectTextOnFocus
              editable={!verifying}
              className={`w-12 h-14 rounded-2xl border text-center font-heading text-xl ${
                hasError
                  ? 'border-red bg-[#FEF2F2] text-red'
                  : activeIdx === i
                  ? 'border-blue bg-tertiary text-primary'
                  : d
                  ? 'border-border bg-surface text-primary'
                  : 'border-border bg-surface text-primary'
              }`}
            />
          ))}
        </Animated.View>

        {hasError && (
          <Text className="text-red text-xs font-body-semi text-center mb-3">
            {error}
          </Text>
        )}

        {verifying && !hasError && (
          <Text className="text-blue text-xs font-body-semi text-center mb-3">
            Verifying…
          </Text>
        )}

        {/* Resend */}
        <View className="items-center mt-2">
          {countdown > 0 ? (
            <Text className="font-body text-sm text-tertxt">
              Resend code in{' '}
              <Text className="font-body-semi text-secondary">{countdown}s</Text>
            </Text>
          ) : (
            <Pressable onPress={resend} className="active:opacity-70">
              <Text className="font-body-semi text-sm text-blue">Resend code</Text>
            </Pressable>
          )}
        </View>

        {!isFirebaseConfigured && (
          <View className="mt-6 bg-[#FFF4EE] rounded-xl px-4 py-3">
            <Text className="font-body text-xs text-orange">
              Dev mode — enter any 6-digit code (except starting with "1") to proceed.
            </Text>
          </View>
        )}
      </View>
    </SafeAreaView>
  );
}
