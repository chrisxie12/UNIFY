import { Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';

export default function CheckEmailScreen() {
  const router = useRouter();
  const { email } = useLocalSearchParams<{ email?: string }>();

  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-row items-center px-5 pt-4 pb-2">
        <Pressable
          onPress={() => router.replace('/auth')}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
      </View>

      <View className="flex-1 px-6 justify-center items-center">
        <View className="w-24 h-24 rounded-full bg-[#EFF6FF] items-center justify-center mb-6">
          <Text style={{ fontSize: 48 }}>📬</Text>
        </View>

        <Text className="font-display text-[28px] leading-8 text-primary text-center mb-3">
          Check your email
        </Text>

        <Text className="font-body text-sm text-secondary text-center leading-6 mb-2">
          We sent a confirmation link to
        </Text>
        {email ? (
          <Text className="font-body-semi text-sm text-primary text-center mb-6">
            {email}
          </Text>
        ) : null}
        <Text className="font-body text-sm text-secondary text-center leading-6 mb-10">
          Click the link in your email to verify your account, then come back to sign in.
        </Text>

        <Pressable
          onPress={() => router.replace('/auth')}
          className="bg-btn-primary rounded-full py-4 px-10 items-center active:opacity-80"
        >
          <Text className="font-body-semi text-base text-white">Back to Sign In</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}
