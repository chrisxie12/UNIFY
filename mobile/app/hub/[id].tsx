import { Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';

export default function HubScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="flex-row items-center px-5 pt-4 pb-2">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
        <Text className="font-heading text-xl text-primary ml-3">Hub</Text>
      </View>
      <View className="flex-1 items-center justify-center px-8">
        <Text className="text-4xl mb-4">🏫</Text>
        <Text className="font-heading text-lg text-primary text-center mb-2">
          Campus Hub
        </Text>
        <Text className="font-body text-sm text-secondary text-center">
          Hub threads coming in Week 3.
        </Text>
      </View>
    </SafeAreaView>
  );
}
