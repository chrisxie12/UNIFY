import { useState } from 'react';
import { Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAppStore } from '../../store/useAppStore';
import { COLORS } from '../../theme/tokens';

const STEPS = ['Who are you?', 'Where are you headed?', 'How do you live?'] as const;

const SCHOOLS = [
  'KNUST', 'UG Legon', 'UCC', 'UPSA', 'UDS', 'UEW', 'UENR',
  'Ashesi University', 'GIMPA', 'Ghana Tech University',
];

const LEVELS = ['Level 100', 'Level 200', 'Level 300', 'Level 400'];

const SLEEP_OPTS = [
  { value: 'early_bird', label: '🌅  Early bird', sub: 'Up by 6am' },
  { value: 'night_owl',  label: '🦉  Night owl',  sub: 'Bed after midnight' },
];
const CLEAN_OPTS = [
  { value: 'very_tidy',  label: '✨  Very tidy'  },
  { value: 'moderate',   label: '👍  Moderate'   },
  { value: 'relaxed',    label: '😌  Relaxed'    },
];
const NOISE_OPTS = [
  { value: 'silent',   label: '🤫  Silent'    },
  { value: 'moderate', label: '🎶  Moderate'  },
  { value: 'lively',   label: '🎉  Lively'    },
];
const STUDY_OPTS = [
  { value: 'room',    label: '🛏  In my room'  },
  { value: 'library', label: '📚  Library'     },
  { value: 'cafe',    label: '☕  Café'        },
  { value: 'outdoor', label: '🌳  Outdoors'    },
];
const HOSTEL_OPTS = [
  'Unity Hall', 'Brunei Hostel', 'Evandy Hostel', 'Independence Hall',
  'Queens Hall', 'University Hotel', 'Republic Hall', 'Katanga Hall',
];

interface PillSelectProps {
  options: readonly { value: string; label: string; sub?: string }[];
  value: string;
  onChange: (v: string) => void;
  multi?: boolean;
  values?: string[];
  onMultiChange?: (v: string[]) => void;
}

function PillSelect({ options, value, onChange, multi = false, values = [], onMultiChange }: PillSelectProps) {
  return (
    <View className="flex-row flex-wrap gap-2">
      {options.map((opt) => {
        const sel = multi ? values.includes(opt.value) : value === opt.value;
        return (
          <Pressable
            key={opt.value}
            onPress={() => {
              if (multi && onMultiChange) {
                onMultiChange(
                  sel ? values.filter((v) => v !== opt.value) : [...values, opt.value],
                );
              } else {
                onChange(opt.value);
              }
            }}
            className={`rounded-full px-4 py-2.5 border ${
              sel ? 'bg-blue border-blue' : 'bg-white border-border'
            } active:opacity-70`}
          >
            <Text className={`font-body-semi text-sm ${sel ? 'text-white' : 'text-secondary'}`}>
              {opt.label}
            </Text>
            {opt.sub ? (
              <Text className={`font-body text-[10px] ${sel ? 'text-[#BFD6FF]' : 'text-tertxt'}`}>
                {opt.sub}
              </Text>
            ) : null}
          </Pressable>
        );
      })}
    </View>
  );
}

function SchoolPicker({ value, onChange }: { value: string; onChange: (s: string) => void }) {
  return (
    <View className="flex-row flex-wrap gap-2">
      {SCHOOLS.map((s) => (
        <Pressable
          key={s}
          onPress={() => onChange(s)}
          className={`rounded-full px-4 py-2 border ${
            value === s ? 'bg-btn-primary border-btn-primary' : 'bg-white border-border'
          } active:opacity-70`}
        >
          <Text className={`font-body-semi text-sm ${value === s ? 'text-white' : 'text-secondary'}`}>
            {s}
          </Text>
        </Pressable>
      ))}
    </View>
  );
}

export default function OnboardingScreen() {
  const router = useRouter();
  const { updateProfile, setOnboarded } = useAppStore();

  const [step, setStep] = useState(0);
  // Step 0
  const [fullName, setFullName]   = useState('');
  const [handle, setHandle]       = useState('');
  const [school, setSchool]       = useState('');
  const [programme, setProgramme] = useState('');
  const [level, setLevel]         = useState('');
  // Step 1
  const [hometown, setHometown] = useState('');
  const [bio, setBio]           = useState('');
  // Step 2
  const [sleep, setSleep]           = useState('');
  const [cleanliness, setCleanliness] = useState('');
  const [noise, setNoise]           = useState('');
  const [study, setStudy]           = useState('');
  const [hostels, setHostels]       = useState<string[]>([]);

  function canAdvance(): boolean {
    if (step === 0) return fullName.trim().length > 1 && handle.trim().length > 1 && school !== '' && level !== '';
    if (step === 1) return true; // optional
    if (step === 2) return sleep !== '' && cleanliness !== '';
    return false;
  }

  function handleNext() {
    if (step < STEPS.length - 1) {
      setStep((s) => s + 1);
    } else {
      updateProfile({
        fullName, displayName: handle || fullName.split(' ')[0], school,
        programme, level, hometown, bio, sleep: sleep as any,
        cleanliness: cleanliness as any, noise: noise as any,
        study: study as any, hostels,
      });
      setOnboarded(true);
      router.replace('/onboarding/success');
    }
  }

  return (
    <SafeAreaView className="flex-1 bg-white">
      {/* Header */}
      <View className="flex-row items-center justify-between px-5 pt-4 pb-2">
        {step > 0 ? (
          <Pressable
            onPress={() => setStep((s) => s - 1)}
            hitSlop={12}
            className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
          >
            <Text className="font-heading text-base text-primary">←</Text>
          </Pressable>
        ) : <View className="w-10" />}

        {/* Progress dots */}
        <View className="flex-row gap-2 items-center">
          {STEPS.map((_, i) => (
            <View
              key={i}
              className={`h-2 rounded-full ${
                i === step ? 'w-6 bg-blue' : i < step ? 'w-2 bg-blue opacity-40' : 'w-2 bg-border'
              }`}
            />
          ))}
        </View>

        <View className="w-10" />
      </View>

      <ScrollView
        className="flex-1"
        contentContainerStyle={{ paddingHorizontal: 24, paddingBottom: 120 }}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        <Text className="font-display text-[28px] leading-8 text-primary mt-4 mb-1">
          {STEPS[step]}
        </Text>
        <Text className="font-body text-sm text-secondary mb-8">
          Step {step + 1} of {STEPS.length}
        </Text>

        {step === 0 && (
          <View className="gap-5">
            <View>
              <Text className="font-body-semi text-sm text-primary mb-2">Full name</Text>
              <TextInput
                placeholder="e.g. Kwame Acheampong"
                placeholderTextColor={COLORS.tertxt}
                value={fullName}
                onChangeText={setFullName}
                autoFocus
                className="bg-surface rounded-2xl border border-border px-5 h-14 font-body text-sm text-primary"
              />
            </View>

            <View>
              <Text className="font-body-semi text-sm text-primary mb-2">
                Username{' '}
                <Text className="text-tertxt font-body">(your @handle)</Text>
              </Text>
              <View className="bg-surface rounded-2xl border border-border flex-row items-center px-5 h-14">
                <Text className="font-body text-sm text-tertxt">@</Text>
                <TextInput
                  placeholder="kwame.acheampong"
                  placeholderTextColor={COLORS.tertxt}
                  value={handle}
                  onChangeText={(t) => setHandle(t.toLowerCase().replace(/\s/g, ''))}
                  autoCapitalize="none"
                  className="flex-1 font-body text-sm text-primary ml-1"
                />
              </View>
            </View>

            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">School</Text>
              <SchoolPicker value={school} onChange={setSchool} />
            </View>

            <View>
              <Text className="font-body-semi text-sm text-primary mb-2">Programme</Text>
              <TextInput
                placeholder="e.g. BSc Computer Engineering"
                placeholderTextColor={COLORS.tertxt}
                value={programme}
                onChangeText={setProgramme}
                className="bg-surface rounded-2xl border border-border px-5 h-14 font-body text-sm text-primary"
              />
            </View>

            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">Year</Text>
              <View className="flex-row gap-2">
                {LEVELS.map((l) => (
                  <Pressable
                    key={l}
                    onPress={() => setLevel(l)}
                    className={`rounded-full px-4 py-2.5 border flex-1 items-center ${
                      level === l ? 'bg-btn-primary border-btn-primary' : 'bg-white border-border'
                    } active:opacity-70`}
                  >
                    <Text className={`font-body-semi text-xs ${level === l ? 'text-white' : 'text-secondary'}`}>
                      {l.replace('Level ', 'L')}
                    </Text>
                  </Pressable>
                ))}
              </View>
            </View>
          </View>
        )}

        {step === 1 && (
          <View className="gap-5">
            <View>
              <Text className="font-body-semi text-sm text-primary mb-2">Hometown</Text>
              <TextInput
                placeholder="e.g. Kumasi"
                placeholderTextColor={COLORS.tertxt}
                value={hometown}
                onChangeText={setHometown}
                autoFocus
                className="bg-surface rounded-2xl border border-border px-5 h-14 font-body text-sm text-primary"
              />
            </View>

            <View>
              <Text className="font-body-semi text-sm text-primary mb-2">
                Bio <Text className="text-tertxt font-body">(optional)</Text>
              </Text>
              <TextInput
                placeholder="Tell future roommates a bit about yourself…"
                placeholderTextColor={COLORS.tertxt}
                value={bio}
                onChangeText={setBio}
                multiline
                textAlignVertical="top"
                maxLength={200}
                className="bg-surface rounded-2xl border border-border px-5 py-4 font-body text-sm text-primary min-h-[100px]"
              />
              <Text className="font-body text-xs text-tertxt mt-1 text-right">
                {bio.length}/200
              </Text>
            </View>
          </View>
        )}

        {step === 2 && (
          <View className="gap-6">
            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">Sleep schedule</Text>
              <PillSelect options={SLEEP_OPTS} value={sleep} onChange={setSleep} />
            </View>
            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">Cleanliness</Text>
              <PillSelect options={CLEAN_OPTS} value={cleanliness} onChange={setCleanliness} />
            </View>
            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">Noise level</Text>
              <PillSelect options={NOISE_OPTS} value={noise} onChange={setNoise} />
            </View>
            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">Where do you study?</Text>
              <PillSelect options={STUDY_OPTS} value={study} onChange={setStudy} />
            </View>
            <View>
              <Text className="font-body-semi text-sm text-primary mb-3">
                Preferred hostels{' '}
                <Text className="text-tertxt font-body">(pick any)</Text>
              </Text>
              <PillSelect
                options={HOSTEL_OPTS.map((h) => ({ value: h, label: h }))}
                value=""
                onChange={() => undefined}
                multi
                values={hostels}
                onMultiChange={setHostels}
              />
            </View>
          </View>
        )}
      </ScrollView>

      {/* Fixed bottom button */}
      <View className="absolute bottom-0 left-0 right-0 bg-white border-t border-border px-6 pb-8 pt-4">
        <Pressable
          onPress={handleNext}
          disabled={!canAdvance()}
          className={`rounded-full py-4 items-center ${
            canAdvance() ? 'bg-btn-primary active:opacity-80' : 'bg-surface'
          }`}
        >
          <Text className={`font-body-semi text-base ${canAdvance() ? 'text-white' : 'text-tertxt'}`}>
            {step < STEPS.length - 1 ? 'Continue' : 'Finish setup'}
          </Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}
