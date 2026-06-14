import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';

const ExpoSecureStoreAdapter = {
  getItem: (key: string) => SecureStore.getItemAsync(key),
  setItem: (key: string, value: string) => SecureStore.setItemAsync(key, value),
  removeItem: (key: string) => SecureStore.deleteItemAsync(key),
};

const supabaseUrl  = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const supabaseAnon = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnon, {
  auth: {
    storage: ExpoSecureStoreAdapter,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export type Profile = {
  id: string;
  university_id: string | null;
  full_name: string;
  phone: string | null;
  gender: string | null;
  avatar_url: string | null;
  bio: string | null;
  level: string | null;
  programme: string | null;
  student_id: string | null;
  is_verified: boolean;
  role: 'student' | 'admin' | 'superadmin';
  email: string | null;
};

export type Announcement = {
  id: string;
  title: string;
  body: string;
  category: 'academic' | 'events' | 'admin' | 'general' | 'urgent';
  published_at: string;
  expires_at: string | null;
};
