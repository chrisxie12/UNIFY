-- ============================================================
-- UNIFY MIGRATION — STEP 2 OF 3
-- Align universities + rename students → profiles
-- ============================================================
-- Prerequisites: Step 1 must be complete.
--
-- What this does:
--   A. universities: rename shortcode→slug, domain_pattern→domain,
--      add short_name + accent_color, drop location column.
--   B. students → profiles: rename table, rename 5 columns,
--      add role + verified_at, drop 5 obsolete columns,
--      refresh RLS policies, add updated_at trigger.
--
-- Auth risk:
--   LOW. The students.id → auth.users(id) FK is preserved through
--   the table rename. Existing sessions remain valid. Supabase Auth
--   does NOT reference the students/profiles table name directly.
--
-- Data loss (permanent):
--   • students.email       (auth.users still owns email — app reads
--                           it from session, not from this column)
--   • students.gender
--   • students.bio
--   • students.verification_code
--   • students.is_active
--   • universities.location
--   • level values not in ('100','200','300','400','pg','staff')
--     → set to NULL, not deleted
--
-- Re-runnable: Yes. All operations guarded by existence checks.
--
-- Run in: Supabase Dashboard → SQL Editor → Run
-- ============================================================


BEGIN;


-- ────────────────────────────────────────────────────────────
-- PART A: universities
-- ────────────────────────────────────────────────────────────

-- A1. Rename shortcode → slug
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

-- A2. Rename domain_pattern → domain
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

-- A3. Drop location column
ALTER TABLE universities DROP COLUMN IF EXISTS location;

-- A4. Add short_name
ALTER TABLE universities ADD COLUMN IF NOT EXISTS short_name TEXT;

-- A5. Populate short_name from slug (UPPER gives: UG, KNUST, UCC, UDS, GCTU, CSU)
UPDATE universities SET short_name = UPPER(slug) WHERE short_name IS NULL;
-- Fix the two that UPPER gets wrong
UPDATE universities SET short_name = 'Ashesi'  WHERE slug = 'ashesi'  AND short_name = 'ASHESI';
UPDATE universities SET short_name = 'Central' WHERE slug = 'central' AND short_name = 'CENTRAL';
-- Make NOT NULL now that all rows have a value
ALTER TABLE universities ALTER COLUMN short_name SET NOT NULL;

-- A6. Add accent_color
ALTER TABLE universities ADD COLUMN IF NOT EXISTS accent_color TEXT DEFAULT '#0055FF';
UPDATE universities SET accent_color = '#003F8A' WHERE slug = 'gctu';

-- A7. Tighten existing constraints
ALTER TABLE universities ALTER COLUMN slug         SET NOT NULL;
ALTER TABLE universities ALTER COLUMN is_active    SET NOT NULL;
ALTER TABLE universities ALTER COLUMN is_active    SET DEFAULT TRUE;
ALTER TABLE universities ALTER COLUMN created_at   SET NOT NULL;

-- A8. Ensure UNIQUE constraint exists on slug column
--     (transfers from shortcode on rename, but add if somehow absent)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t     ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
    WHERE n.nspname = 'public'
      AND t.relname  = 'universities'
      AND c.contype  = 'u'
      AND a.attname IN ('slug', 'shortcode')
  ) THEN
    ALTER TABLE universities ADD CONSTRAINT universities_slug_key UNIQUE (slug);
  END IF;
END $$;

-- A9. Upsert GCTU row with correct new-schema values
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


-- ────────────────────────────────────────────────────────────
-- PART B: students → profiles
-- ────────────────────────────────────────────────────────────

-- B1. Drop old RLS policies BEFORE rename (must use current table name)
DROP POLICY IF EXISTS "Students can view own profile"   ON students;
DROP POLICY IF EXISTS "Students can update own profile" ON students;
DROP POLICY IF EXISTS "Students can insert own profile" ON students;

-- B2. Rename table
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

-- B3. Rename the auto-generated PK constraint (cosmetic, no functional impact)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'students_pkey') THEN
    ALTER TABLE profiles RENAME CONSTRAINT students_pkey TO profiles_pkey;
  END IF;
END $$;

-- B4. Drop old indexes that were named after 'students'
--     (new ones will be created in Step 3)
DROP INDEX IF EXISTS idx_students_university;
DROP INDEX IF EXISTS idx_students_is_verified;

-- B5. Column renames (each guarded)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='phone_number')
  AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='phone')
  THEN ALTER TABLE profiles RENAME COLUMN phone_number TO phone; END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='photo_url')
  AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='avatar_url')
  THEN ALTER TABLE profiles RENAME COLUMN photo_url TO avatar_url; END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='level_of_study')
  AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='level')
  THEN ALTER TABLE profiles RENAME COLUMN level_of_study TO level; END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='department')
  AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='programme')
  THEN ALTER TABLE profiles RENAME COLUMN department TO programme; END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='student_id_number')
  AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='student_id')
  THEN ALTER TABLE profiles RENAME COLUMN student_id_number TO student_id; END IF;
END $$;

-- B6. Drop obsolete columns
ALTER TABLE profiles DROP COLUMN IF EXISTS email;
ALTER TABLE profiles DROP COLUMN IF EXISTS gender;
ALTER TABLE profiles DROP COLUMN IF EXISTS bio;
ALTER TABLE profiles DROP COLUMN IF EXISTS verification_code;
ALTER TABLE profiles DROP COLUMN IF EXISTS is_active;

-- B7. Add new columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role       TEXT NOT NULL DEFAULT 'student';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;

-- B8. Normalise level before adding CHECK constraint.
--     Old onboarding used '100','200','300','400','PG','Staff'.
--     Lowercase first; NULL out anything that still doesn't fit.
UPDATE profiles SET level = LOWER(level) WHERE level IS NOT NULL;
UPDATE profiles
  SET level = NULL
  WHERE level NOT IN ('100','200','300','400','pg','staff')
    AND level IS NOT NULL;

-- B9. CHECK constraints (drop first so re-runs don't error)
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('student','admin','superadmin'));

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_level_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_level_check
  CHECK (level IN ('100','200','300','400','pg','staff'));

-- B10. Assign any NULL university_ids to GCTU, then make NOT NULL
UPDATE profiles
  SET university_id = (SELECT id FROM universities WHERE slug = 'gctu' LIMIT 1)
  WHERE university_id IS NULL;
ALTER TABLE profiles ALTER COLUMN university_id SET NOT NULL;

-- B11. Relax full_name NOT NULL (was required in old schema, nullable in new)
ALTER TABLE profiles ALTER COLUMN full_name DROP NOT NULL;

-- B12. Tighten remaining constraints
ALTER TABLE profiles ALTER COLUMN is_verified SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN is_verified SET DEFAULT FALSE;
ALTER TABLE profiles ALTER COLUMN created_at  SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN updated_at  SET NOT NULL;

-- B13. updated_at trigger (didn't exist in old schema)
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- B14. Enable RLS (safe to call again if already enabled)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- B15. New RLS policies for profiles
DROP POLICY IF EXISTS "profiles_own_read"     ON profiles;
DROP POLICY IF EXISTS "profiles_own_insert"   ON profiles;
DROP POLICY IF EXISTS "profiles_own_update"   ON profiles;
DROP POLICY IF EXISTS "profiles_admin_read"   ON profiles;
DROP POLICY IF EXISTS "profiles_admin_verify" ON profiles;

CREATE POLICY "profiles_own_read" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_own_insert" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_own_update" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "profiles_admin_read" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles admin_p
      WHERE admin_p.id = auth.uid()
        AND admin_p.role IN ('admin','superadmin')
        AND admin_p.university_id = profiles.university_id
    )
  );

CREATE POLICY "profiles_admin_verify" ON profiles
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles admin_p
      WHERE admin_p.id = auth.uid()
        AND admin_p.role IN ('admin','superadmin')
        AND admin_p.university_id = profiles.university_id
    )
  );

-- B16. universities RLS (public read — ensure it exists)
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "universities_public_read" ON universities;
CREATE POLICY "universities_public_read" ON universities
  FOR SELECT USING (TRUE);


COMMIT;


-- ============================================================
-- VERIFY (run after the script above)
-- ============================================================

-- 1. Table should now be called 'profiles', not 'students':
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' ORDER BY table_name;

-- 2. Check profiles columns — expect new names, no email/gender/bio:
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'profiles'
-- ORDER BY ordinal_position;

-- 3. Check universities columns — expect slug, short_name, domain, accent_color:
-- SELECT column_name FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'universities'
-- ORDER BY ordinal_position;

-- 4. Verify GCTU row looks correct:
-- SELECT name, short_name, slug, domain, accent_color FROM universities WHERE slug = 'gctu';

-- 5. Check existing user rows survived with correct data:
-- SELECT id, university_id, full_name, role, is_verified FROM profiles LIMIT 10;

-- 6. Verify RLS policies:
-- SELECT policyname, cmd FROM pg_policies WHERE tablename = 'profiles';
-- SELECT policyname FROM pg_policies WHERE tablename = 'universities';


-- ============================================================
-- ROLLBACK
-- ============================================================
-- Run this block to undo Step 2 if needed.
-- WARNING: Columns dropped in B6 (email, gender, bio,
-- verification_code, is_active) and universities.location
-- CANNOT be recovered — their data is gone.
-- All other changes below are reversible.
--
-- BEGIN;
--
-- -- Reverse table rename
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='profiles')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='students')
--   THEN ALTER TABLE profiles RENAME TO students; END IF;
-- END $$;
--
-- -- Reverse PK constraint rename
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_pkey')
--   THEN ALTER TABLE students RENAME CONSTRAINT profiles_pkey TO students_pkey; END IF;
-- END $$;
--
-- -- Reverse column renames
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='students' AND column_name='phone')
--   THEN ALTER TABLE students RENAME COLUMN phone TO phone_number; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='students' AND column_name='avatar_url')
--   THEN ALTER TABLE students RENAME COLUMN avatar_url TO photo_url; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='students' AND column_name='level')
--   THEN ALTER TABLE students RENAME COLUMN level TO level_of_study; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='students' AND column_name='programme')
--   THEN ALTER TABLE students RENAME COLUMN programme TO department; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='students' AND column_name='student_id')
--   THEN ALTER TABLE students RENAME COLUMN student_id TO student_id_number; END IF;
-- END $$;
--
-- -- Drop added columns
-- ALTER TABLE students DROP COLUMN IF EXISTS role;
-- ALTER TABLE students DROP COLUMN IF EXISTS verified_at;
--
-- -- Drop new constraints
-- ALTER TABLE students DROP CONSTRAINT IF EXISTS profiles_role_check;
-- ALTER TABLE students DROP CONSTRAINT IF EXISTS profiles_level_check;
-- ALTER TABLE students ALTER COLUMN university_id DROP NOT NULL;
-- ALTER TABLE students ALTER COLUMN full_name SET NOT NULL;
--
-- -- Drop trigger
-- DROP TRIGGER IF EXISTS profiles_updated_at ON students;
--
-- -- Restore old RLS policies
-- DROP POLICY IF EXISTS "profiles_own_read"     ON students;
-- DROP POLICY IF EXISTS "profiles_own_insert"   ON students;
-- DROP POLICY IF EXISTS "profiles_own_update"   ON students;
-- DROP POLICY IF EXISTS "profiles_admin_read"   ON students;
-- DROP POLICY IF EXISTS "profiles_admin_verify" ON students;
-- CREATE POLICY "Students can view own profile"   ON students FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Students can update own profile" ON students FOR UPDATE USING (auth.uid() = id);
-- CREATE POLICY "Students can insert own profile" ON students FOR INSERT WITH CHECK (auth.uid() = id);
--
-- -- Reverse universities changes
-- ALTER TABLE universities DROP COLUMN IF EXISTS short_name;
-- ALTER TABLE universities DROP COLUMN IF EXISTS accent_color;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='slug')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='shortcode')
--   THEN ALTER TABLE universities RENAME COLUMN slug TO shortcode; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='domain')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='universities' AND column_name='domain_pattern')
--   THEN ALTER TABLE universities RENAME COLUMN domain TO domain_pattern; END IF;
-- END $$;
-- -- Note: universities.location data is gone and cannot be restored here.
--
-- COMMIT;
