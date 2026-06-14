-- ============================================================
-- UNIFY MIGRATION — STEP 3 OF 3
-- Create announcements, announcement_reads, indexes,
-- remaining RLS policies, and auth trigger
-- ============================================================
-- Prerequisites: Steps 1 and 2 must be complete.
--   • profiles table must exist
--   • universities table must have slug column
--
-- What this does:
--   • Creates announcements table
--   • Creates announcement_reads table
--   • Creates all performance indexes
--   • Creates RLS policies for both new tables
--   • Creates handle_new_user() auth trigger so new signups
--     automatically get a profiles row
--
-- Auth risk:   NONE. Adds new tables and a trigger; nothing removed.
-- Data loss:   NONE. Purely additive.
-- Re-runnable: Yes. IF NOT EXISTS and DROP IF EXISTS guards throughout.
--
-- Run in: Supabase Dashboard → SQL Editor → Run
-- ============================================================


BEGIN;


-- ────────────────────────────────────────────────────────────
-- PART A: announcements
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS announcements (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id UUID        NOT NULL REFERENCES universities(id),
  author_id     UUID        NOT NULL REFERENCES profiles(id),
  title         TEXT        NOT NULL,
  body          TEXT        NOT NULL,
  category      TEXT        NOT NULL DEFAULT 'general'
                              CHECK (category IN ('academic','events','admin','general','urgent')),
  is_published  BOOLEAN     NOT NULL DEFAULT FALSE,
  published_at  TIMESTAMPTZ,
  expires_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- updated_at trigger
DROP TRIGGER IF EXISTS announcements_updated_at ON announcements;
CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Auto-stamp published_at the moment is_published flips to TRUE
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


-- ────────────────────────────────────────────────────────────
-- PART B: announcement_reads
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS announcement_reads (
  announcement_id UUID        NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES profiles(id)      ON DELETE CASCADE,
  read_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);


-- ────────────────────────────────────────────────────────────
-- PART C: RLS for new tables
-- ────────────────────────────────────────────────────────────

ALTER TABLE announcements      ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_reads ENABLE ROW LEVEL SECURITY;

-- Students: read published, non-expired announcements for their university
DROP POLICY IF EXISTS "announcements_student_read" ON announcements;
CREATE POLICY "announcements_student_read" ON announcements
  FOR SELECT USING (
    is_published = TRUE
    AND (expires_at IS NULL OR expires_at > NOW())
    AND university_id = (
      SELECT university_id FROM profiles WHERE id = auth.uid()
    )
  );

-- Admins: full CRUD on their university's announcements
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

-- Students: insert and read their own read-receipts
DROP POLICY IF EXISTS "reads_own_insert" ON announcement_reads;
DROP POLICY IF EXISTS "reads_own_read"   ON announcement_reads;
CREATE POLICY "reads_own_insert" ON announcement_reads
  FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "reads_own_read" ON announcement_reads
  FOR SELECT USING (user_id = auth.uid());

-- Admins: read all read-receipts for their university's announcements
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


-- ────────────────────────────────────────────────────────────
-- PART D: Indexes
-- ────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_profiles_university ON profiles(university_id);
CREATE INDEX IF NOT EXISTS idx_profiles_role       ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_verified   ON profiles(is_verified);

CREATE INDEX IF NOT EXISTS idx_announcements_uni ON announcements(university_id);
CREATE INDEX IF NOT EXISTS idx_announcements_pub ON announcements(is_published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_announcements_cat ON announcements(category);

CREATE INDEX IF NOT EXISTS idx_reads_announcement ON announcement_reads(announcement_id);


-- ────────────────────────────────────────────────────────────
-- PART E: Auth trigger — auto-create profile row on signup
-- ────────────────────────────────────────────────────────────
-- SECURITY DEFINER: runs as function owner (postgres) so it can
-- write to public.profiles during the auth.users INSERT.
-- ON CONFLICT DO NOTHING: safe even if the app also inserts manually.

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


COMMIT;


-- ============================================================
-- VERIFY (run after the script above)
-- ============================================================

-- 1. New tables exist:
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' ORDER BY table_name;
-- Expected: announcements, announcement_reads, profiles, universities

-- 2. announcements columns:
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'announcements'
-- ORDER BY ordinal_position;

-- 3. All RLS policies:
-- SELECT tablename, policyname, cmd
-- FROM pg_policies WHERE schemaname = 'public'
-- ORDER BY tablename, policyname;

-- 4. All indexes:
-- SELECT indexname, tablename FROM pg_indexes
-- WHERE schemaname = 'public' ORDER BY tablename, indexname;

-- 5. Auth trigger exists:
-- SELECT trigger_name, event_object_table
-- FROM information_schema.triggers
-- WHERE event_object_schema = 'auth' AND event_object_table = 'users';
-- Expected: on_auth_user_created


-- ============================================================
-- ROLLBACK
-- ============================================================
-- Step 3 is fully reversible — it only adds things.
-- Run this block to undo everything in Step 3:
--
-- BEGIN;
-- DROP TRIGGER  IF EXISTS on_auth_user_created         ON auth.users;
-- DROP FUNCTION IF EXISTS public.handle_new_user();
-- DROP FUNCTION IF EXISTS public.handle_announcement_publish() CASCADE;
-- DROP TABLE    IF EXISTS announcement_reads CASCADE;
-- DROP TABLE    IF EXISTS announcements      CASCADE;
-- DROP INDEX    IF EXISTS idx_profiles_university;
-- DROP INDEX    IF EXISTS idx_profiles_role;
-- DROP INDEX    IF EXISTS idx_profiles_verified;
-- COMMIT;
--
-- Note: handle_updated_at() is NOT dropped here because it was
-- created in Step 2 and is still used by the profiles table.
