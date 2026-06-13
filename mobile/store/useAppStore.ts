import { create } from 'zustand';

export interface GoogleUser {
  id: string;
  email: string;
  name: string;
  picture: string;
}

export interface OnboardingProfile {
  fullName: string;
  displayName: string;
  school: string;
  programme: string;
  level: string;
  hometown: string;
  phone: string;           // optional, for account recovery only
  bio: string;
  sleep: 'early_bird' | 'night_owl' | '';
  cleanliness: 'very_tidy' | 'moderate' | 'relaxed' | '';
  noise: 'silent' | 'moderate' | 'lively' | '';
  study: 'room' | 'library' | 'cafe' | 'outdoor' | '';
  hostels: string[];
}

interface AppState {
  googleUser: GoogleUser | null;
  verified: boolean;
  onboarded: boolean;
  onboardingStep: number;
  profile: OnboardingProfile;

  setGoogleUser: (user: GoogleUser) => void;
  setVerified: (v: boolean) => void;
  setOnboarded: (v: boolean) => void;
  setOnboardingStep: (step: number) => void;
  updateProfile: (data: Partial<OnboardingProfile>) => void;
  signOut: () => void;
}

const EMPTY_PROFILE: OnboardingProfile = {
  fullName: '',
  displayName: '',
  school: '',
  programme: '',
  level: '',
  hometown: '',
  phone: '',
  bio: '',
  sleep: '',
  cleanliness: '',
  noise: '',
  study: '',
  hostels: [],
};

export const useAppStore = create<AppState>((set) => ({
  googleUser: null,
  verified: false,
  onboarded: false,
  onboardingStep: 0,
  profile: EMPTY_PROFILE,

  setGoogleUser: (googleUser) => set({ googleUser, verified: true }),
  setVerified: (verified) => set({ verified }),
  setOnboarded: (onboarded) => set({ onboarded }),
  setOnboardingStep: (onboardingStep) => set({ onboardingStep }),
  updateProfile: (data) =>
    set((s) => ({ profile: { ...s.profile, ...data } })),
  signOut: () =>
    set({ googleUser: null, verified: false, onboarded: false, profile: EMPTY_PROFILE }),
}));
