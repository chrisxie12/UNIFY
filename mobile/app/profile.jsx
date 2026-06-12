import { View, Text, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { NBCard, NBBadge, NBButton } from '../components/NB';
import { COLORS } from '../theme/tokens';

export default function ProfileScreen() {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.parchment }} edges={['top']}>
      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 48 }}>
        <Text style={{ fontFamily: 'ArchivoBlack', fontSize: 26, color: COLORS.text, letterSpacing: -1, marginBottom: 16 }}>
          MY PROFILE
        </Text>

        <NBCard style={{ marginBottom: 16 }} contentStyle={{ padding: 16, alignItems: 'center' }}>
          <View
            style={{
              width: 72, height: 72, backgroundColor: COLORS.brand,
              borderWidth: 2, borderColor: COLORS.ink,
              alignItems: 'center', justifyContent: 'center', marginBottom: 12,
            }}
          >
            <Text style={{ color: COLORS.white, fontFamily: 'ArchivoBlack', fontSize: 24 }}>KE</Text>
          </View>
          <Text style={{ fontFamily: 'SpaceGrotesk_700Bold', fontSize: 20, color: COLORS.text }}>Kwame E.</Text>
          <Text style={{ fontFamily: 'Inter_500Medium', fontSize: 13, color: COLORS.textMuted, marginBottom: 10 }}>
            KNUST · BSc Computer Engineering
          </Text>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <NBBadge label="✓ Verified Student" />
            <NBBadge label="Level 100" bg={COLORS.action} />
          </View>
        </NBCard>

        <NBCard style={{ marginBottom: 16 }} contentStyle={{ padding: 16 }}>
          <Text style={{ fontFamily: 'SpaceGrotesk_700Bold', fontSize: 14, color: COLORS.text, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 12 }}>
            Roommate Quiz
          </Text>
          {[
            ['Sleep schedule', 'Night Owl'],
            ['Cleanliness', 'Very tidy'],
            ['Budget', 'GHS 2,500–4,000 / yr'],
            ['Study style', 'Library, evenings'],
          ].map(([k, v]) => (
            <View key={k} style={{ flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 7, borderBottomWidth: 1.5, borderBottomColor: '#00000020' }}>
              <Text style={{ fontFamily: 'Inter_500Medium', fontSize: 13, color: COLORS.textMuted }}>{k}</Text>
              <Text style={{ fontFamily: 'Inter_700Bold', fontSize: 13, color: COLORS.text }}>{v}</Text>
            </View>
          ))}
        </NBCard>

        <NBButton label="Retake Quiz" onPress={() => {}} />
      </ScrollView>
    </SafeAreaView>
  );
}
