import { create } from 'zustand';

export interface OnboardingProfile {
  fullName: string;
  displayName: string;
  school: string;
  programme: string;
  level: string;
  hometown: string;
  bio: string;
  sleep: 'early_bird' | 'night_owl' | '';
  cleanliness: 'very_tidy' | 'moderate' | 'relaxed' | '';
  noise: 'silent' | 'moderate' | 'lively' | '';
  study: 'room' | 'library' | 'cafe' | 'outdoor' | '';
  hostels: string[];
}

interface AppState {
  // Auth flow
  phone: string;
  otpSent: boolean;
  verified: boolean;
  onboarded: boolean;
  // Onboarding
  onboardingStep: number;
  profile: OnboardingProfile;
  // Actions
  setPhone: (phone: string) => void;
  setOtpSent: (v: boolean) => void;
  setVerified: (v: boolean) => void;
  setOnboarded: (v: boolean) => void;
  setOnboardingStep: (step: number) => void;
  updateProfile: (data: Partial<OnboardingProfile>) => void;
}

const EMPTY_PROFILE: OnboardingProfile = {
  fullName: '',
  displayName: '',
  school: '',
  programme: '',
  level: '',
  hometown: '',
  bio: '',
  sleep: '',
  cleanliness: '',
  noise: '',
  study: '',
  hostels: [],
};

export const useAppStore = create<AppState>((set) => ({
  phone: '',
  otpSent: false,
  verified: false,
  onboarded: false,
  onboardingStep: 0,
  profile: EMPTY_PROFILE,

  setPhone: (phone) => set({ phone }),
  setOtpSent: (otpSent) => set({ otpSent }),
  setVerified: (verified) => set({ verified }),
  setOnboarded: (onboarded) => set({ onboarded }),
  setOnboardingStep: (onboardingStep) => set({ onboardingStep }),
  updateProfile: (data) =>
    set((s) => ({ profile: { ...s.profile, ...data } })),
}));
