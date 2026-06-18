-- ============================================================
-- Step 2 FIX: Handle partial migration state
-- ============================================================

-- Rename shortcode -> slug if shortcode exists and slug doesn't
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='shortcode')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='slug') THEN
    ALTER TABLE universities RENAME COLUMN shortcode TO slug;
  END IF;
END $$;

-- Rename domain_pattern -> domain if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='domain_pattern')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='domain') THEN
    ALTER TABLE universities RENAME COLUMN domain_pattern TO domain;
  END IF;
END $$;

-- Add short_name if missing
ALTER TABLE universities ADD COLUMN IF NOT EXISTS short_name TEXT;
UPDATE universities SET short_name = UPPER(LEFT(slug, 3)) WHERE short_name IS NULL;

-- Add accent_color if missing
ALTER TABLE universities ADD COLUMN IF NOT EXISTS accent_color TEXT DEFAULT '#2563EB';
UPDATE universities SET accent_color = '#003F8A' WHERE slug = 'gctu' AND accent_color = '#2563EB';

-- Ensure slug is unique + not null
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'universities_slug_key') THEN
    ALTER TABLE universities ADD CONSTRAINT universities_slug_key UNIQUE (slug);
  END IF;
END $$;
ALTER TABLE universities ALTER COLUMN slug SET NOT NULL;

-- Add profile columns that might be missing
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email_backup TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'student';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;

-- Update profiles with university_id from slug
UPDATE profiles SET university_id = (SELECT id FROM universities WHERE slug = 'gctu' LIMIT 1)
WHERE university_id IS NULL AND EXISTS (SELECT 1 FROM universities WHERE slug = 'gctu');

-- Drop legacy profiles policies and recreate
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;

CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create universities RLS
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Universities are viewable by everyone" ON universities;
CREATE POLICY "Universities are viewable by everyone" ON universities
  FOR SELECT USING (true);

-- Create the updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
