import { useState } from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAppStore } from '../../store/useAppStore';
import { COLORS } from '../../theme/tokens';

export default function PhoneAuthScreen() {
  const router  = useRouter();
  const setPhone   = useAppStore((s) => s.setPhone);
  const setOtpSent = useAppStore((s) => s.setOtpSent);

  const [number, setNumber] = useState('');
  const [loading, setLoading] = useState(false);
  const [focused, setFocused] = useState(false);

  const digits = number.replace(/\D/g, '');
  const canContinue = digits.length >= 9;

  function handleContinue() {
    if (!canContinue || loading) return;
    setLoading(true);
    setPhone(`+233${digits}`);
    setTimeout(() => {
      setOtpSent(true);
      setLoading(false);
      router.push('/auth/verify');
    }, 900);
  }

  return (
    <SafeAreaView className="flex-1 bg-white">
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
            focused ? 'border-blue' : 'border-border'
          }`}
        >
          {/* Ghana flag + prefix */}
          <View className="flex-row items-center gap-2 pr-3 border-r border-border mr-3">
            <Text className="text-xl">🇬🇭</Text>
            <Text className="font-body-semi text-sm text-primary">+233</Text>
          </View>

          <TextInput
            placeholder="XX XXX XXXX"
            placeholderTextColor={COLORS.tertxt}
            value={number}
            onChangeText={setNumber}
            keyboardType="phone-pad"
            maxLength={12}
            autoFocus
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            className="flex-1 font-body-semi text-base text-primary"
          />
        </View>

        <Text className="font-body text-xs text-tertxt mt-3">
          Standard SMS rates may apply.
        </Text>

        {/* Continue button */}
        <Pressable
          onPress={handleContinue}
          disabled={!canContinue || loading}
          className={`mt-10 rounded-full py-4 items-center ${
            canContinue ? 'bg-btn-primary active:opacity-80' : 'bg-surface'
          }`}
        >
          <Text
            className={`font-body-semi text-base ${
              canContinue ? 'text-white' : 'text-tertxt'
            }`}
          >
            {loading ? 'Sending…' : 'Continue'}
          </Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}
