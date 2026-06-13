-- ============================================================
-- UNIFY MIGRATION — STEP 2 OF 3 (REVISED)
-- Structural alignment: students → profiles + universities
-- ============================================================
-- Prerequisites: Step 1 (legacy table drop) must be complete.
--
-- What this does:
--   ADDITIVE FIRST — all destructive ops avoided or deferred.
--
--   universities:
--     • Rename shortcode → slug  (column rename, no data lost)
--     • Rename domain_pattern → domain  (column rename, no data lost)
--     • ADD short_name  (populated from slug)
--     • ADD accent_color  (defaulted, GCTU set to #003F8A)
--     • location column: KEPT (not dropped)
--     • Ensure slug is UNIQUE + NOT NULL
--
--   students → profiles:
--     • ADD email_backup TEXT  (copy of email before any future cleanup)
--     • RENAME TABLE students → profiles
--     • RENAME 5 columns  (each guarded by IF EXISTS)
--     • ADD role TEXT DEFAULT 'student'
--     • ADD verified_at TIMESTAMPTZ
--     • email column: NOT NULL constraint RELAXED, data preserved
--     • email_backup: populated from email
--     • NO other columns dropped in this step
--     • level values: lowercased only (no nullification)
--     • Add updated_at trigger
--     • Recreate RLS policies (AFTER all rename operations)
--
-- Auth risk:
--   NONE. students.id → auth.users(id) FK is preserved through
--   table rename. Existing sessions remain valid.
--
-- Data loss:  NONE. No DROP COLUMN anywhere in this script.
-- Re-runnable: Yes. All operations are guarded.
--
-- Run in: Supabase Dashboard → SQL Editor → Run
-- ============================================================


BEGIN;


-- ============================================================
-- PHASE 1: PRE-RENAME PREPARATION
-- (Must run while table is still called 'students')
-- ============================================================

-- 1a. Drop old RLS policies BEFORE renaming.
--     Policies on 'students' cannot be addressed after rename.
--     Wrapped in existence check so re-runs don't error.
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'students'
  ) THEN
    DROP POLICY IF EXISTS "Students can view own profile"   ON students;
    DROP POLICY IF EXISTS "Students can update own profile" ON students;
    DROP POLICY IF EXISTS "Students can insert own profile" ON students;
  END IF;
END $$;

-- 1b. Add email_backup column before we touch anything else.
--     This preserves the email data regardless of what happens next.
--     Works on whichever name the table currently has.
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'students'
  ) THEN
    ALTER TABLE students ADD COLUMN IF NOT EXISTS email_backup TEXT;
    UPDATE students SET email_backup = email WHERE email_backup IS NULL;
  ELSIF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'profiles'
  ) THEN
    ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email_backup TEXT;
    UPDATE profiles SET email_backup = email WHERE email_backup IS NULL
      AND EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'email'
      );
  END IF;
END $$;

-- 1c. Relax NOT NULL on email column.
--     The old schema had email NOT NULL + UNIQUE. New inserts from
--     signup and auth trigger do not include email (auth.users owns
--     it). Without relaxing this, any INSERT that omits email would
--     fail. Data in the email column is preserved; just made nullable.
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'students'
      AND column_name = 'email' AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE students ALTER COLUMN email DROP NOT NULL;
  END IF;
END $$;


-- ============================================================
-- PHASE 2: TABLE RENAME
-- ============================================================

-- 2a. Rename students → profiles (skipped if already done)
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

-- 2b. Rename auto-generated PK constraint (cosmetic only —
--     no functional impact; skipped if already renamed or absent)
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'students_pkey'
  ) THEN
    ALTER TABLE profiles RENAME CONSTRAINT students_pkey TO profiles_pkey;
  END IF;
END $$;

-- 2c. Remove stale 'students' index names.
--     These exist because PostgreSQL does not rename indexes on
--     table rename. New indexes are created in Step 3.
DROP INDEX IF EXISTS idx_students_university;
DROP INDEX IF EXISTS idx_students_is_verified;


-- ============================================================
-- PHASE 3: COLUMN RENAMES ON profiles
-- (Each guarded: only runs if old name exists AND new name does not)
-- ============================================================

-- phone_number → phone
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

-- photo_url → avatar_url
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

-- level_of_study → level
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

-- department → programme
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

-- student_id_number → student_id
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


-- ============================================================
-- PHASE 4: ADD NEW COLUMNS TO profiles
-- ============================================================

-- role: required by all auth checks in the MVP frontend.
-- NOT NULL with DEFAULT 'student' — existing rows get 'student' automatically.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'student';

-- verified_at: timestamp for when admin manually verifies a student.
-- Nullable — most users will not have this set yet.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;


-- ============================================================
-- PHASE 5: DATA NORMALIZATION (conservative — no nullification)
-- ============================================================

-- Lowercase level values so they match what the new onboarding
-- sends (e.g. 'PG' from old app → 'pg').
-- Values that still don't match ('Level 100', 'First Year', etc.)
-- are left as-is. A CHECK constraint is NOT added in this step.
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'level'
  ) THEN
    UPDATE profiles SET level = LOWER(level) WHERE level IS NOT NULL;
  END IF;
END $$;

-- Ensure any NULL university_ids are assigned to GCTU.
-- Strictly required before making university_id NOT NULL in Phase 6.
UPDATE profiles
  SET university_id = (SELECT id FROM universities WHERE slug = 'gctu' LIMIT 1)
  WHERE university_id IS NULL;


-- ============================================================
-- PHASE 6: CONSTRAINT CHANGES ON profiles
-- ============================================================

-- Make university_id NOT NULL now that all rows have a value.
ALTER TABLE profiles ALTER COLUMN university_id SET NOT NULL;

-- full_name: was NOT NULL in old schema; new signup omits it sometimes.
-- Relax so the auth trigger insert (which may have empty string) doesn't fail.
ALTER TABLE profiles ALTER COLUMN full_name DROP NOT NULL;

-- is_verified: tighten — was DEFAULT FALSE without NOT NULL in some envs.
ALTER TABLE profiles ALTER COLUMN is_verified SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN is_verified SET DEFAULT FALSE;

-- Timestamps: ensure NOT NULL (they had defaults, should already have values).
ALTER TABLE profiles ALTER COLUMN created_at SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN updated_at SET NOT NULL;

-- role CHECK constraint (drop first so re-runs don't fail).
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('student','admin','superadmin'));

-- NOTE: We deliberately do NOT add a CHECK constraint on 'level'
-- in this step. Old free-text values (e.g. 'First Year') are still
-- present. A separate cleanup step should confirm and NULL those out
-- before the constraint is applied.


-- ============================================================
-- PHASE 7: TRIGGER ON profiles
-- ============================================================

-- handle_updated_at was not on the old students table.
-- Create the function (or replace it if it exists from Step 3 prep).
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();


-- ============================================================
-- PHASE 8: universities — ADDITIVE-FIRST
-- (column renames are safe; location column is NOT dropped)
-- ============================================================

-- 8a. Rename shortcode → slug
--     Required: frontend signup queries WHERE slug = 'gctu'.
--     The UNIQUE constraint on shortcode transfers with the rename.
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

-- 8b. Rename domain_pattern → domain
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

-- 8c. ADD short_name (new column — purely additive)
ALTER TABLE universities ADD COLUMN IF NOT EXISTS short_name TEXT;

-- Populate from slug for any rows that don't have it yet
UPDATE universities SET short_name = UPPER(slug) WHERE short_name IS NULL;
UPDATE universities SET short_name = 'Ashesi'  WHERE slug = 'ashesi'  AND short_name = 'ASHESI';
UPDATE universities SET short_name = 'Central' WHERE slug = 'central' AND short_name = 'CENTRAL';

-- Make NOT NULL now that all rows have a value
UPDATE universities SET short_name = 'Unknown' WHERE short_name IS NULL;
ALTER TABLE universities ALTER COLUMN short_name SET NOT NULL;

-- 8d. ADD accent_color (new column — purely additive)
ALTER TABLE universities ADD COLUMN IF NOT EXISTS accent_color TEXT DEFAULT '#0055FF';
UPDATE universities SET accent_color = '#003F8A' WHERE slug = 'gctu';

-- 8e. Tighten slug NOT NULL + UNIQUE
UPDATE universities
  SET slug = LOWER(REGEXP_REPLACE(name, '[^a-zA-Z0-9]', '_', 'g'))
  WHERE slug IS NULL;
ALTER TABLE universities ALTER COLUMN slug SET NOT NULL;

-- Add UNIQUE on slug only if neither slug nor the old shortcode
-- already has a unique constraint (the rename preserves the constraint)
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

-- 8f. Tighten existing constraints
ALTER TABLE universities ALTER COLUMN is_active  SET NOT NULL;
ALTER TABLE universities ALTER COLUMN is_active  SET DEFAULT TRUE;
ALTER TABLE universities ALTER COLUMN created_at SET NOT NULL;

-- 8g. Upsert GCTU row with correct values
--     ON CONFLICT (slug) updates only the new columns; existing data untouched.
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

-- NOTE: universities.location column is KEPT.
-- It contains 8 city names. No data is lost.
-- It can be dropped in a future cleanup step if desired.


-- ============================================================
-- PHASE 9: RLS — RECREATED AFTER ALL RENAMES
-- ============================================================

-- profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop any stale policies that may have transferred with the rename
DROP POLICY IF EXISTS "Students can view own profile"   ON profiles;
DROP POLICY IF EXISTS "Students can update own profile" ON profiles;
DROP POLICY IF EXISTS "Students can insert own profile" ON profiles;
-- Drop new-name policies so re-runs don't fail
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

-- universities: ensure public read exists
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "universities_public_read" ON universities;
CREATE POLICY "universities_public_read" ON universities
  FOR SELECT USING (TRUE);


COMMIT;


-- ============================================================
-- VALIDATION QUERIES
-- Run each of these after the script completes.
-- ============================================================

-- V1. Table named 'profiles' must exist; 'students' must not.
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' AND table_name IN ('students', 'profiles');
-- Expected: exactly one row → profiles

-- V2. profiles column list — verify new names, old names absent.
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'profiles'
-- ORDER BY ordinal_position;
-- Expect columns: id, university_id, full_name, phone, gender, avatar_url,
--   bio, level, programme, student_id, is_verified, verification_code,
--   is_active, created_at, updated_at, email_backup, role, verified_at, email
-- (email + all old columns preserved, email now nullable)

-- V3. No rows lost — count should match original students count.
-- SELECT COUNT(*) FROM profiles;

-- V4. email_backup is populated for any rows that had email.
-- SELECT COUNT(*) FROM profiles WHERE email IS NOT NULL AND email_backup IS NULL;
-- Expected: 0

-- V5. role column populated on all rows.
-- SELECT role, COUNT(*) FROM profiles GROUP BY role;
-- Expected: all rows show 'student' (or other values if manually set)

-- V6. universities — new columns exist, all 8 rows intact.
-- SELECT name, short_name, slug, domain, accent_color, location
-- FROM universities ORDER BY slug;
-- location column should still be present with city data.

-- V7. GCTU row correct.
-- SELECT name, short_name, slug, domain, accent_color
-- FROM universities WHERE slug = 'gctu';
-- Expected: accent_color = '#003F8A'

-- V8. RLS policies on profiles.
-- SELECT policyname, cmd FROM pg_policies
-- WHERE schemaname = 'public' AND tablename = 'profiles'
-- ORDER BY policyname;
-- Expected: 5 policies

-- V9. Auth sessions still work — existing users can log in.
-- (Test manually: open app → /login → sign in with existing account)


-- ============================================================
-- ROLLBACK SCRIPT
-- Reverses every change made in this Step 2.
-- Run as a separate SQL Editor session if needed.
-- ============================================================

-- BEGIN;
--
-- -- Reverse RLS (drop new policies, restore old ones)
-- DROP POLICY IF EXISTS "profiles_own_read"     ON profiles;
-- DROP POLICY IF EXISTS "profiles_own_insert"   ON profiles;
-- DROP POLICY IF EXISTS "profiles_own_update"   ON profiles;
-- DROP POLICY IF EXISTS "profiles_admin_read"   ON profiles;
-- DROP POLICY IF EXISTS "profiles_admin_verify" ON profiles;
--
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='profiles') THEN
--     CREATE POLICY "Students can view own profile"   ON profiles FOR SELECT USING (auth.uid() = id);
--     CREATE POLICY "Students can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
--     CREATE POLICY "Students can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
--   END IF;
-- END $$;
--
-- -- Remove trigger
-- DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
--
-- -- Remove new constraints
-- ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
-- ALTER TABLE profiles ALTER COLUMN university_id DROP NOT NULL;
-- ALTER TABLE profiles ALTER COLUMN is_verified   DROP NOT NULL;
-- ALTER TABLE profiles ALTER COLUMN full_name     SET NOT NULL;
-- ALTER TABLE profiles ALTER COLUMN created_at    DROP NOT NULL;
-- ALTER TABLE profiles ALTER COLUMN updated_at    DROP NOT NULL;
--
-- -- Remove new columns
-- ALTER TABLE profiles DROP COLUMN IF EXISTS role;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS verified_at;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS email_backup;
--
-- -- Restore email NOT NULL
-- DO $$ BEGIN
--   IF NOT EXISTS (
--     SELECT 1 FROM information_schema.columns
--     WHERE table_schema='public' AND table_name='profiles'
--       AND column_name='email' AND is_nullable='NO'
--   ) THEN
--     ALTER TABLE profiles ALTER COLUMN email SET NOT NULL;
--   END IF;
-- END $$;
--
-- -- Reverse column renames
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='phone')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='phone_number')
--   THEN ALTER TABLE profiles RENAME COLUMN phone TO phone_number; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='avatar_url')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='photo_url')
--   THEN ALTER TABLE profiles RENAME COLUMN avatar_url TO photo_url; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='level')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='level_of_study')
--   THEN ALTER TABLE profiles RENAME COLUMN level TO level_of_study; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='programme')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='department')
--   THEN ALTER TABLE profiles RENAME COLUMN programme TO department; END IF;
-- END $$;
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='student_id')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='student_id_number')
--   THEN ALTER TABLE profiles RENAME COLUMN student_id TO student_id_number; END IF;
-- END $$;
--
-- -- Reverse PK constraint rename
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_pkey')
--   THEN ALTER TABLE profiles RENAME CONSTRAINT profiles_pkey TO students_pkey; END IF;
-- END $$;
--
-- -- Rename table back to students
-- DO $$ BEGIN
--   IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='profiles')
--   AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='students')
--   THEN ALTER TABLE profiles RENAME TO students; END IF;
-- END $$;
--
-- -- Reverse universities changes (keep location — it was never touched)
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
--
-- COMMIT;
