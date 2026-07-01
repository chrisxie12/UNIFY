-- ───────────────────────────────────────────────────────────────────
-- 20260619000019 — Beta Launch Fixes
-- ───────────────────────────────────────────────────────────────────
-- Adds columns to `profiles` that onboarding and profile models
-- expect but were never added to the schema.
-- Also adds the `profiles` storage bucket for avatar uploads.
-- ───────────────────────────────────────────────────────────────────

-- 1. Add missing columns to profiles table
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS headline             TEXT,
  ADD COLUMN IF NOT EXISTS goals                JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS interests            JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS onboarding_complete  BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS user_type            TEXT,
  ADD COLUMN IF NOT EXISTS school_name          TEXT,
  ADD COLUMN IF NOT EXISTS year_completed       INTEGER,
  ADD COLUMN IF NOT EXISTS status               TEXT,
  ADD COLUMN IF NOT EXISTS university_name      TEXT,
  ADD COLUMN IF NOT EXISTS display_name         TEXT;

-- Backfill display_name from full_name for AppUserModel compatibility
UPDATE profiles SET display_name = full_name WHERE display_name IS NULL AND full_name IS NOT NULL;

-- 2. Relax level CHECK constraint to accept parsed values
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_level_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_level_check
  CHECK (level IS NULL OR level IN ('100','200','300','400','pg','staff'));

-- 3. Create profiles storage bucket for avatar uploads
INSERT INTO storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
VALUES ('profiles', 'profiles', TRUE, FALSE, 5242880, ARRAY['image/png','image/jpeg','image/webp'])
ON CONFLICT (id) DO NOTHING;

-- 4. Storage RLS: authenticated users can upload to their own folder
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'profiles' AND (storage.foldername(name))[1] = 'avatars');

DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
CREATE POLICY "Anyone can view avatars"
  ON storage.objects FOR SELECT TO anon, authenticated
  USING (bucket_id = 'profiles');

-- 5. Make university_id nullable (onboarding resolves it at submit time)
ALTER TABLE profiles ALTER COLUMN university_id DROP NOT NULL;

-- 6. Update handle_new_user trigger to handle missing GCTU gracefully
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, university_id, full_name, role)
  VALUES (
    NEW.id,
    (SELECT id FROM public.universities WHERE slug = 'gctu' LIMIT 1),
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;
