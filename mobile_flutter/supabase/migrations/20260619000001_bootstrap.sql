-- UNIFY Bootstrap: universities, profiles, announcements, auth triggers, seed data
-- All FKs reference profiles(id) not users(id) — users(id) does not exist in public schema.

BEGIN;

-- ── Universities ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS universities (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  short_name   TEXT NOT NULL,
  slug         TEXT UNIQUE NOT NULL,
  domain       TEXT,
  logo_url     TEXT,
  accent_color TEXT DEFAULT '#0055FF',
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Profiles ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id                   UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  university_id        UUID NOT NULL REFERENCES universities(id),
  full_name            TEXT,
  student_id           TEXT,
  programme            TEXT,
  level                TEXT CHECK (level IN ('100','200','300','400','pg','staff')),
  phone                TEXT,
  avatar_url           TEXT,
  role                 TEXT NOT NULL DEFAULT 'student'
                          CHECK (role IN ('student','admin','superadmin')),
  is_verified          BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at          TIMESTAMPTZ,
  email_backup         TEXT,
  verification_status  TEXT NOT NULL DEFAULT 'none',
  is_verified_leader   BOOLEAN NOT NULL DEFAULT FALSE,
  leadership_role      TEXT,
  represented_class    TEXT,
  represented_department TEXT,
  academic_year        TEXT,
  faculty              TEXT,
  department           TEXT,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Announcements ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id  UUID NOT NULL REFERENCES universities(id),
  author_id      UUID NOT NULL REFERENCES profiles(id),
  title          TEXT NOT NULL,
  body           TEXT NOT NULL,
  category       TEXT NOT NULL DEFAULT 'general'
                   CHECK (category IN ('academic','events','admin','general','urgent')),
  is_published   BOOLEAN NOT NULL DEFAULT FALSE,
  published_at   TIMESTAMPTZ,
  expires_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS announcement_reads (
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  read_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);

-- ── Helper: updated_at trigger ───────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- ── Trigger: auto-set published_at ───────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_announcement_publish()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_published = TRUE AND OLD.is_published = FALSE THEN
    NEW.published_at = NOW();
  END IF;
  RETURN NEW;
END; $$;

CREATE TRIGGER announcements_publish_timestamp
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE public.handle_announcement_publish();

-- ── Auth trigger: auto-create profile on sign-up ─────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
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

-- ── RLS ──────────────────────────────────────────────────────────
ALTER TABLE universities      ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements     ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_reads ENABLE ROW LEVEL SECURITY;

-- Universities: public read
DROP POLICY IF EXISTS universities_public_read ON universities;
CREATE POLICY universities_public_read ON universities
  FOR SELECT USING (TRUE);

-- Profiles: own full access
DROP POLICY IF EXISTS profiles_own_read ON profiles;
CREATE POLICY profiles_own_read ON profiles FOR SELECT USING (auth.uid() = id);
DROP POLICY IF EXISTS profiles_own_insert ON profiles;
CREATE POLICY profiles_own_insert ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS profiles_own_update ON profiles;
CREATE POLICY profiles_own_update ON profiles FOR UPDATE USING (auth.uid() = id);

-- Profiles: admin read
DROP POLICY IF EXISTS profiles_admin_read ON profiles;
CREATE POLICY profiles_admin_read ON profiles FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles admin_p WHERE admin_p.id = auth.uid()
    AND admin_p.role IN ('admin','superadmin')
    AND admin_p.university_id = profiles.university_id)
);

-- Profiles: admin verify
DROP POLICY IF EXISTS profiles_admin_verify ON profiles;
CREATE POLICY profiles_admin_verify ON profiles FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles admin_p WHERE admin_p.id = auth.uid()
    AND admin_p.role IN ('admin','superadmin')
    AND admin_p.university_id = profiles.university_id)
);

-- Announcements: student read
DROP POLICY IF EXISTS announcements_student_read ON announcements;
CREATE POLICY announcements_student_read ON announcements FOR SELECT USING (
  is_published = TRUE
  AND (expires_at IS NULL OR expires_at > NOW())
  AND university_id = (SELECT university_id FROM profiles WHERE id = auth.uid())
);

-- Announcements: admin all
DROP POLICY IF EXISTS announcements_admin_all ON announcements;
CREATE POLICY announcements_admin_all ON announcements FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid()
    AND p.role IN ('admin','superadmin')
    AND p.university_id = announcements.university_id)
);

-- Announcement reads: own
DROP POLICY IF EXISTS reads_own_insert ON announcement_reads;
CREATE POLICY reads_own_insert ON announcement_reads FOR INSERT WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS reads_own_read ON announcement_reads;
CREATE POLICY reads_own_read ON announcement_reads FOR SELECT USING (user_id = auth.uid());

-- Announcement reads: admin
DROP POLICY IF EXISTS reads_admin_read ON announcement_reads;
CREATE POLICY reads_admin_read ON announcement_reads FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles p JOIN announcements a ON a.university_id = p.university_id
    WHERE p.id = auth.uid() AND p.role IN ('admin','superadmin') AND a.id = announcement_reads.announcement_id)
);

-- ── Indexes ──────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_university ON profiles(university_id);
CREATE INDEX IF NOT EXISTS idx_profiles_role       ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_verified   ON profiles(is_verified);
CREATE INDEX IF NOT EXISTS idx_announcements_uni   ON announcements(university_id);
CREATE INDEX IF NOT EXISTS idx_announcements_pub   ON announcements(is_published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_announcements_cat   ON announcements(category);
CREATE INDEX IF NOT EXISTS idx_reads_announcement  ON announcement_reads(announcement_id);

-- ── Seed data ────────────────────────────────────────────────────
INSERT INTO universities (name, short_name, slug, domain, accent_color) VALUES
  ('Ghana Communication Technology University', 'GCTU', 'gctu', 'gctu.edu.gh', '#003F8A')
ON CONFLICT (slug) DO NOTHING;

COMMIT;
