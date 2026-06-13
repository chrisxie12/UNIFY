import { useRef, useState } from 'react';
import {
  Animated, Modal, PanResponder, Pressable, Text, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { Avatar, Badge } from '../../components/UI';

const DECK = [
  { id: 'c1', name: 'Ama Serwaa',    school: 'KNUST', prog: 'BSc Computer Science',   level: 'Level 200', matchPct: 94, initials: 'AS', color: 'orange', hometown: 'Kumasi',  sleep: 'Night owl', clean: 'Very tidy',  noise: 'Moderate', study: 'Library', verified: true  },
  { id: 'c2', name: 'Michael Agyei', school: 'KNUST', prog: 'BSc Electrical Eng.',    level: 'Level 100', matchPct: 88, initials: 'MA', color: 'blue',   hometown: 'Accra',   sleep: 'Night owl', clean: 'Moderate',   noise: 'Lively',   study: 'Café',    verified: true  },
  { id: 'c3', name: 'Efua Boateng',  school: 'UCC',   prog: 'BSc Civil Engineering',  level: 'Level 200', matchPct: 82, initials: 'EB', color: 'green',  hometown: 'Cape Coast', sleep: 'Early bird', clean: 'Very tidy', noise: 'Silent', study: 'Room',    verified: false },
  { id: 'c4', name: 'Yaw Mensah',    school: 'UPSA',  prog: 'BSc Business Admin',     level: 'Level 100', matchPct: 79, initials: 'YM', color: 'red',    hometown: 'Tema',    sleep: 'Early bird', clean: 'Relaxed',   noise: 'Lively',   study: 'Library', verified: true  },
  { id: 'c5', name: 'Adwoa Kyei',    school: 'UG',    prog: 'LLB Law',                level: 'Level 300', matchPct: 75, initials: 'AK', color: 'purple', hometown: 'Tamale',  sleep: 'Night owl', clean: 'Moderate',   noise: 'Silent',   study: 'Library', verified: true  },
];

const CARD_W  = 320;
const SWIPE_THRESHOLD = 100;

type MatchedUser = typeof DECK[number];

export default function MatchScreen() {
  const router = useRouter();
  const [deck, setDeck]             = useState(DECK);
  const [matched, setMatched]       = useState<string[]>([]);
  const [matchModal, setMatchModal] = useState<MatchedUser | null>(null);
  const pan    = useRef(new Animated.ValueXY()).current;
  const rotate = pan.x.interpolate({ inputRange: [-200, 0, 200], outputRange: ['-12deg', '0deg', '12deg'] });
  const likeOpacity = pan.x.interpolate({ inputRange: [0, SWIPE_THRESHOLD], outputRange: [0, 1], extrapolate: 'clamp' });
  const passOpacity = pan.x.interpolate({ inputRange: [-SWIPE_THRESHOLD, 0], outputRange: [1, 0], extrapolate: 'clamp' });

  const panResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => true,
    onPanResponderMove: Animated.event([null, { dx: pan.x, dy: pan.y }], { useNativeDriver: false }),
    onPanResponderRelease: (_, gesture) => {
      if (gesture.dx > SWIPE_THRESHOLD) {
        // Super-like / Request
        Animated.timing(pan, { toValue: { x: 500, y: gesture.dy }, duration: 250, useNativeDriver: true })
          .start(() => next('like'));
      } else if (gesture.dx < -SWIPE_THRESHOLD) {
        // Pass
        Animated.timing(pan, { toValue: { x: -500, y: gesture.dy }, duration: 250, useNativeDriver: true })
          .start(() => next('pass'));
      } else {
        Animated.spring(pan, { toValue: { x: 0, y: 0 }, useNativeDriver: true }).start();
      }
    },
  });

  function next(action: 'like' | 'pass') {
    const top = deck[0];
    if (action === 'like' && top) {
      setMatched((m) => [...m, top.id]);
      setTimeout(() => {
        setMatchModal(top);
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      }, 300);
    }
    setDeck((d) => d.slice(1));
    pan.setValue({ x: 0, y: 0 });
  }

  const top = deck[0];
  const second = deck[1];

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      <View className="px-5 pt-5 pb-2">
        <Text className="font-display text-2xl text-primary">Match</Text>
        <Text className="font-body text-sm text-secondary">
          {deck.length} potential roommates
        </Text>
      </View>

      {/* Card stack */}
      <View className="flex-1 items-center justify-center">
        {deck.length === 0 ? (
          <View className="items-center px-8">
            <Text className="text-5xl mb-4">✨</Text>
            <Text className="font-heading text-xl text-primary text-center mb-2">
              You've seen everyone!
            </Text>
            <Text className="font-body text-sm text-secondary text-center">
              Check back soon — new students join daily.
            </Text>
          </View>
        ) : (
          <View className="items-center" style={{ height: 480 }}>
            {/* Second card (behind) */}
            {second && (
              <View
                className="absolute bg-white rounded-3xl shadow-card-md p-6"
                style={{ width: CARD_W, top: 12, transform: [{ scale: 0.95 }] }}
              >
                <View className="items-center">
                  <Avatar initials={second.initials} color={second.color} size="xl" />
                </View>
              </View>
            )}

            {/* Top card */}
            <Animated.View
              {...panResponder.panHandlers}
              style={{
                width: CARD_W,
                position: 'absolute',
                top: 0,
                transform: [
                  { translateX: pan.x },
                  { translateY: pan.y },
                  { rotate },
                ],
              }}
              className="bg-white rounded-3xl shadow-card-lg p-6"
            >
              {/* Like / Pass overlays */}
              <Animated.View
                style={{ opacity: likeOpacity }}
                className="absolute top-6 right-6 bg-green rounded-xl px-3 py-1 z-10 border-2 border-green"
              >
                <Text className="text-white font-heading text-lg">REQUEST</Text>
              </Animated.View>
              <Animated.View
                style={{ opacity: passOpacity }}
                className="absolute top-6 left-6 bg-red rounded-xl px-3 py-1 z-10 border-2 border-red"
              >
                <Text className="text-white font-heading text-lg">PASS</Text>
              </Animated.View>

              {/* Profile content */}
              <View className="items-center mb-4">
                <Avatar initials={top.initials} color={top.color} size="xl" />
                <View className="mt-3 bg-[#EFF6FF] rounded-full px-4 py-1">
                  <Text className="text-blue font-body-semi text-sm">
                    {top.matchPct}% match
                  </Text>
                </View>
              </View>

              <View className="items-center mb-4">
                <View className="flex-row items-center gap-2">
                  <Text className="font-heading text-xl text-primary">{top.name}</Text>
                  {top.verified && (
                    <View className="bg-[#ECFDF5] rounded-full w-5 h-5 items-center justify-center">
                      <Text className="text-green text-[10px] font-body-semi">✓</Text>
                    </View>
                  )}
                </View>
                <Text className="font-body text-sm text-secondary mt-0.5">
                  {top.school} · {top.level}
                </Text>
                <Text className="font-body text-xs text-tertxt mt-0.5">{top.prog}</Text>
                <Text className="font-body text-xs text-tertxt">📍 {top.hometown}</Text>
              </View>

              {/* Habit tags */}
              <View className="flex-row flex-wrap gap-2 justify-center">
                <Badge label={`🌙 ${top.sleep}`} color="default" />
                <Badge label={`✨ ${top.clean}`} color="default" />
                <Badge label={`🔊 ${top.noise}`} color="default" />
                <Badge label={`📚 ${top.study}`} color="default" />
              </View>
            </Animated.View>
          </View>
        )}
      </View>

      {/* Action buttons */}
      {deck.length > 0 && (
        <View className="flex-row justify-center gap-5 pb-8 px-5">
          <Pressable
            onPress={() => next('pass')}
            className="w-16 h-16 rounded-full bg-white shadow-card-md items-center justify-center border border-border active:opacity-70"
          >
            <Text className="text-red text-2xl">✕</Text>
          </Pressable>
          <Pressable
            onPress={() => next('like')}
            className="w-16 h-16 rounded-full bg-blue shadow-card-md items-center justify-center active:opacity-80"
          >
            <Text className="text-white text-2xl">+</Text>
          </Pressable>
          <Pressable
            onPress={() => next('like')}
            className="w-16 h-16 rounded-full bg-orange shadow-card-md items-center justify-center active:opacity-80"
          >
            <Text className="text-white text-2xl">★</Text>
          </Pressable>
        </View>
      )}

      {matched.length > 0 && (
        <View className="mx-5 mb-4 bg-[#ECFDF5] rounded-2xl px-4 py-3">
          <Text className="font-body-semi text-sm text-green text-center">
            🎉 {matched.length} request{matched.length !== 1 ? 's' : ''} sent
          </Text>
        </View>
      )}

      <Modal visible={!!matchModal} transparent animationType="fade">
        <View className="flex-1 bg-black/60 items-center justify-center px-8">
          <View className="bg-white rounded-3xl p-8 w-full items-center">
            <Text style={{ fontSize: 56 }}>🔥</Text>
            <Text className="font-display text-3xl text-primary mt-4 mb-2">It's a Match!</Text>
            <Text className="font-body text-sm text-secondary text-center mb-6">
              You and {matchModal?.name} both want to connect.
            </Text>
            {matchModal && <Avatar initials={matchModal.initials} color={matchModal.color} size="xl" />}
            <View className="gap-3 w-full mt-6">
              <Pressable
                onPress={() => { setMatchModal(null); router.push('/chat/c1' as any); }}
                className="bg-btn-primary rounded-full py-4 items-center active:opacity-80"
              >
                <Text className="text-white font-body-semi text-base">Start Chat →</Text>
              </Pressable>
              <Pressable
                onPress={() => setMatchModal(null)}
                className="py-3 items-center active:opacity-70"
              >
                <Text className="font-body-semi text-sm text-tertxt">Keep Browsing</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}
