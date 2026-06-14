-- ============================================================
-- UNIFY — GCTU MVP MIGRATION SCRIPT
-- ============================================================
-- Migrates the existing roommate-matching schema to the GCTU
-- Announcement MVP without losing any university or student data.
--
-- Safe to re-run: every destructive operation is guarded.
--
-- Run in: Supabase Dashboard → SQL Editor → Paste → Run
-- ============================================================


BEGIN;


-- ============================================================
-- SECTION 1: DROP OLD FEATURE TABLES
-- ============================================================
-- Drop children before parents (FK dependency order).
-- CASCADE handles any remaining dependent objects.

DROP TABLE IF EXISTS chats                  CASCADE;
DROP TABLE IF EXISTS verification_requests  CASCADE;
DROP TABLE IF EXISTS matches                CASCADE;
DROP TABLE IF EXISTS housing_listings       CASCADE;
DROP TABLE IF EXISTS roommate_quiz          CASCADE;

-- Drop old indexes that lived on the students table.
-- They survive the table rename and would duplicate the new ones.
DROP INDEX IF EXISTS idx_students_university;
DROP INDEX IF EXISTS idx_students_is_verified;


-- ============================================================
-- SECTION 2: MODIFY universities TABLE
-- ============================================================
-- Preserve all 8 existing rows.
-- Changes: rename shortcode→slug, rename domain_pattern→domain,
-- add short_name, add accent_color, drop location.

-- 2a. Rename shortcode → slug (skipped if already renamed)
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'universities'
      AND column_name = 'shortcode'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'universities'
      AND column_name = 'slug'
  ) THEN
    ALTER TABLE universities RENAME COLUMN shortcode TO slug;
  END IF;
END $$;

-- 2b. Rename domain_pattern → domain (skipped if already renamed)
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'universities'
      AND column_name = 'domain_pattern'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'universities'
      AND column_name = 'domain'
  ) THEN
    ALTER TABLE universities RENAME COLUMN domain_pattern TO domain;
  END IF;
END $$;

-- 2c. Drop location column (not in new schema)
ALTER TABLE universities DROP COLUMN IF EXISTS location;

-- 2d. Add short_name column
ALTER TABLE universities ADD COLUMN IF NOT EXISTS short_name TEXT;

-- 2e. Add accent_color column
ALTER TABLE universities ADD COLUMN IF NOT EXISTS accent_color TEXT DEFAULT '#0055FF';

-- 2f. Populate short_name from slug for all rows that don't have it yet
UPDATE universities SET short_name = UPPER(slug) WHERE short_name IS NULL;

-- 2g. Override short_names that UPPER(slug) gets wrong
UPDATE universities SET short_name = 'Ashesi'  WHERE slug = 'ashesi'  AND short_name = 'ASHESI';
UPDATE universities SET short_name = 'Central' WHERE slug = 'central' AND short_name = 'CENTRAL';
UPDATE universities SET short_name = 'CSU'     WHERE slug = 'csu';

-- 2h. Set GCTU accent colour
UPDATE universities SET accent_color = '#003F8A' WHERE slug = 'gctu';

-- 2i. Fill any null slugs before making NOT NULL
UPDATE universities
  SET slug = LOWER(REGEXP_REPLACE(name, '[^a-zA-Z0-9]', '_', 'g'))
  WHERE slug IS NULL;
ALTER TABLE universities ALTER COLUMN slug SET NOT NULL;

-- 2j. short_name NOT NULL
UPDATE universities SET short_name = 'Unknown' WHERE short_name IS NULL;
ALTER TABLE universities ALTER COLUMN short_name SET NOT NULL;

-- 2k. Tighten existing NOT NULL / DEFAULT
ALTER TABLE universities ALTER COLUMN is_active SET NOT NULL;
ALTER TABLE universities ALTER COLUMN is_active SET DEFAULT TRUE;
ALTER TABLE universities ALTER COLUMN created_at SET NOT NULL;

-- 2l. Ensure UNIQUE constraint on slug exists (the old UNIQUE on shortcode
--     transfers when the column is renamed, but add it if somehow missing).
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t      ON t.oid = c.conrelid
    JOIN pg_namespace n  ON n.oid = t.relnamespace
    JOIN pg_attribute a  ON a.attrelid = c.conrelid
                        AND a.attnum = c.conkey[1]
    WHERE n.nspname = 'public'
      AND t.relname = 'universities'
      AND c.contype = 'u'
      AND a.attname IN ('slug', 'shortcode')
  ) THEN
    ALTER TABLE universities ADD CONSTRAINT universities_slug_key UNIQUE (slug);
  END IF;
END $$;


-- ============================================================
-- SECTION 3: RENAME students → profiles + COLUMN CHANGES
-- ============================================================

-- 3a. Rename table (skipped if already done)
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'students'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'profiles'
  ) THEN
    ALTER TABLE students RENAME TO profiles;
  END IF;
END $$;

-- 3b. Drop old RLS policies that transferred with the rename
--     (they're no longer valid for the new access model)
DROP POLICY IF EXISTS "Students can view own profile"   ON profiles;
DROP POLICY IF EXISTS "Students can update own profile" ON profiles;
DROP POLICY IF EXISTS "Students can insert own profile" ON profiles;

-- 3c. Rename columns (each guarded against being already renamed)

DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'phone_number'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'phone'
  ) THEN
    ALTER TABLE profiles RENAME COLUMN phone_number TO phone;
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'photo_url'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'avatar_url'
  ) THEN
    ALTER TABLE profiles RENAME COLUMN photo_url TO avatar_url;
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'level_of_study'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'level'
  ) THEN
    ALTER TABLE profiles RENAME COLUMN level_of_study TO level;
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'department'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'programme'
  ) THEN
    ALTER TABLE profiles RENAME COLUMN department TO programme;
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'student_id_number'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'student_id'
  ) THEN
    ALTER TABLE profiles RENAME COLUMN student_id_number TO student_id;
  END IF;
END $$;

-- 3d. Drop obsolete columns
ALTER TABLE profiles DROP COLUMN IF EXISTS email;
ALTER TABLE profiles DROP COLUMN IF EXISTS gender;
ALTER TABLE profiles DROP COLUMN IF EXISTS bio;
ALTER TABLE profiles DROP COLUMN IF EXISTS verification_code;
ALTER TABLE profiles DROP COLUMN IF EXISTS is_active;

-- 3e. Add new columns (idempotent)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'student';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
-- avatar_url may exist from rename above, or may be new
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 3f. Normalise level values before adding CHECK constraint.
--     The old onboarding used '100','200','300','400','PG','Staff' —
--     lowercase them; NULL out any other free-text values.
UPDATE profiles SET level = LOWER(level) WHERE level IS NOT NULL;
UPDATE profiles
  SET level = NULL
  WHERE level NOT IN ('100','200','300','400','pg','staff')
    AND level IS NOT NULL;

-- 3g. Add / replace CHECK constraint on role
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('student','admin','superadmin'));

-- 3h. Add / replace CHECK constraint on level
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_level_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_level_check
  CHECK (level IN ('100','200','300','400','pg','staff'));

-- 3i. university_id: assign any NULLs to GCTU, then make NOT NULL
UPDATE profiles
  SET university_id = (SELECT id FROM universities WHERE slug = 'gctu' LIMIT 1)
  WHERE university_id IS NULL;
ALTER TABLE profiles ALTER COLUMN university_id SET NOT NULL;

-- 3j. full_name: was NOT NULL in old schema; new schema allows NULL
ALTER TABLE profiles ALTER COLUMN full_name DROP NOT NULL;

-- 3k. Tighten NOT NULL / DEFAULT on remaining columns
ALTER TABLE profiles ALTER COLUMN is_verified SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN is_verified SET DEFAULT FALSE;
ALTER TABLE profiles ALTER COLUMN created_at  SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN updated_at  SET NOT NULL;


-- ============================================================
-- SECTION 4: SHARED TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END; $$;

-- profiles updated_at trigger
DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();


-- ============================================================
-- SECTION 5: CREATE announcements TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS announcements (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id  UUID        NOT NULL REFERENCES universities(id),
  author_id      UUID        NOT NULL REFERENCES profiles(id),
  title          TEXT        NOT NULL,
  body           TEXT        NOT NULL,
  category       TEXT        NOT NULL DEFAULT 'general'
                               CHECK (category IN ('academic','events','admin','general','urgent')),
  is_published   BOOLEAN     NOT NULL DEFAULT FALSE,
  published_at   TIMESTAMPTZ,
  expires_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- announcements updated_at trigger
DROP TRIGGER IF EXISTS announcements_updated_at ON announcements;
CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Auto-stamp published_at when is_published flips TRUE
CREATE OR REPLACE FUNCTION public.handle_announcement_publish()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_published = TRUE AND OLD.is_published = FALSE THEN
    NEW.published_at = NOW();
  END IF;
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS announcements_publish_timestamp ON announcements;
CREATE TRIGGER announcements_publish_timestamp
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE public.handle_announcement_publish();


-- ============================================================
-- SECTION 6: CREATE announcement_reads TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS announcement_reads (
  announcement_id UUID        NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES profiles(id)      ON DELETE CASCADE,
  read_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);


-- ============================================================
-- SECTION 7: ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE universities       ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements      ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_reads ENABLE ROW LEVEL SECURITY;

-- ── universities ─────────────────────────────────────────────
DROP POLICY IF EXISTS "universities_public_read" ON universities;
CREATE POLICY "universities_public_read" ON universities
  FOR SELECT USING (TRUE);

-- ── profiles: own profile ────────────────────────────────────
DROP POLICY IF EXISTS "profiles_own_read"   ON profiles;
DROP POLICY IF EXISTS "profiles_own_insert" ON profiles;
DROP POLICY IF EXISTS "profiles_own_update" ON profiles;

CREATE POLICY "profiles_own_read"   ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_own_insert" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_own_update" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- ── profiles: admin read all in their university ─────────────
DROP POLICY IF EXISTS "profiles_admin_read" ON profiles;
CREATE POLICY "profiles_admin_read" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles admin_p
      WHERE admin_p.id = auth.uid()
        AND admin_p.role IN ('admin','superadmin')
        AND admin_p.university_id = profiles.university_id
    )
  );

-- ── profiles: admin update (e.g. verification) ───────────────
DROP POLICY IF EXISTS "profiles_admin_verify" ON profiles;
CREATE POLICY "profiles_admin_verify" ON profiles
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles admin_p
      WHERE admin_p.id = auth.uid()
        AND admin_p.role IN ('admin','superadmin')
        AND admin_p.university_id = profiles.university_id
    )
  );

-- ── announcements: students read published ───────────────────
DROP POLICY IF EXISTS "announcements_student_read" ON announcements;
CREATE POLICY "announcements_student_read" ON announcements
  FOR SELECT USING (
    is_published = TRUE
    AND (expires_at IS NULL OR expires_at > NOW())
    AND university_id = (
      SELECT university_id FROM profiles WHERE id = auth.uid()
    )
  );

-- ── announcements: admins full CRUD ─────────────────────────
DROP POLICY IF EXISTS "announcements_admin_all" ON announcements;
CREATE POLICY "announcements_admin_all" ON announcements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
        AND p.role IN ('admin','superadmin')
        AND p.university_id = announcements.university_id
    )
  );

-- ── announcement_reads: students own reads ───────────────────
DROP POLICY IF EXISTS "reads_own_insert" ON announcement_reads;
DROP POLICY IF EXISTS "reads_own_read"   ON announcement_reads;

CREATE POLICY "reads_own_insert" ON announcement_reads
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "reads_own_read" ON announcement_reads
  FOR SELECT USING (user_id = auth.uid());

-- ── announcement_reads: admins read all for their university ─
DROP POLICY IF EXISTS "reads_admin_read" ON announcement_reads;
CREATE POLICY "reads_admin_read" ON announcement_reads
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM profiles p
      JOIN announcements a ON a.university_id = p.university_id
      WHERE p.id = auth.uid()
        AND p.role IN ('admin','superadmin')
        AND a.id = announcement_reads.announcement_id
    )
  );


-- ============================================================
-- SECTION 8: INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_profiles_university ON profiles(university_id);
CREATE INDEX IF NOT EXISTS idx_profiles_role       ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_verified   ON profiles(is_verified);

CREATE INDEX IF NOT EXISTS idx_announcements_uni ON announcements(university_id);
CREATE INDEX IF NOT EXISTS idx_announcements_pub ON announcements(is_published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_announcements_cat ON announcements(category);

CREATE INDEX IF NOT EXISTS idx_reads_announcement ON announcement_reads(announcement_id);


-- ============================================================
-- SECTION 9: AUTH TRIGGER — auto-create profile on sign-up
-- ============================================================
-- SECURITY DEFINER lets this run as the function owner (postgres)
-- so it can write to public.profiles even during auth.users insert.
-- ON CONFLICT DO NOTHING makes it safe if the app also inserts manually.

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, university_id, full_name, role)
  VALUES (
    NEW.id,
    (SELECT id FROM public.universities WHERE slug = 'gctu' LIMIT 1),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END; $$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- ============================================================
-- SECTION 10: UPSERT GCTU SEED DATA
-- ============================================================
-- Updates the existing GCTU row from the old seed with the
-- correct new-schema values. INSERT ... ON CONFLICT is safe
-- whether GCTU already exists or was somehow missing.

INSERT INTO universities (name, short_name, slug, domain, accent_color)
VALUES (
  'Ghana Communication Technology University',
  'GCTU',
  'gctu',
  'gctu.edu.gh',
  '#003F8A'
)
ON CONFLICT (slug) DO UPDATE SET
  name         = EXCLUDED.name,
  short_name   = EXCLUDED.short_name,
  domain       = EXCLUDED.domain,
  accent_color = EXCLUDED.accent_color;


-- ============================================================
-- POST-MIGRATION VERIFICATION QUERIES
-- ============================================================
-- Uncomment and run these after migration to confirm results.

-- Table inventory:
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' ORDER BY table_name;

-- Universities (should show 8 rows with slug + short_name):
-- SELECT id, name, short_name, slug, domain, accent_color, is_active FROM universities;

-- Profiles column check:
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'profiles'
-- ORDER BY ordinal_position;

-- Row counts:
-- SELECT
--   (SELECT COUNT(*) FROM universities)       AS universities,
--   (SELECT COUNT(*) FROM profiles)           AS profiles,
--   (SELECT COUNT(*) FROM announcements)      AS announcements,
--   (SELECT COUNT(*) FROM announcement_reads) AS reads;

-- RLS policies:
-- SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public';

-- Auth trigger:
-- SELECT trigger_name FROM information_schema.triggers
-- WHERE event_object_schema = 'auth' AND event_object_table = 'users';


COMMIT;
