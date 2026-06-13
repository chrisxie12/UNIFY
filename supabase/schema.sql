-- ============================================================
-- UNIFY DATABASE SCHEMA — MVP (GCTU Launch)
-- ============================================================
-- Architecture: single-university now, multi-university ready.
-- University is a first-class entity on every table.
-- Adding new universities later = insert a row + update RLS.
-- ============================================================


-- ── 1. UNIVERSITIES ──────────────────────────────────────────
-- One row per institution. GCTU seeded below.
CREATE TABLE universities (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  short_name   TEXT NOT NULL,          -- "GCTU"
  slug         TEXT UNIQUE NOT NULL,   -- "gctu" — used in URLs & lookups
  domain       TEXT,                   -- "gctu.edu.gh"
  logo_url     TEXT,
  accent_color TEXT DEFAULT '#0055FF',
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ── 2. PROFILES ──────────────────────────────────────────────
-- One row per auth.users account. Created on first sign-in.
-- Role controls access: student | admin | superadmin
CREATE TABLE profiles (
  id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  university_id  UUID NOT NULL REFERENCES universities(id),
  full_name      TEXT,
  student_id     TEXT,                 -- index number / student ID card number
  programme      TEXT,
  level          TEXT CHECK (level IN ('100','200','300','400','pg','staff')),
  phone          TEXT,
  avatar_url     TEXT,
  role           TEXT NOT NULL DEFAULT 'student'
                   CHECK (role IN ('student','admin','superadmin')),
  is_verified    BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at    TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();


-- ── 3. ANNOUNCEMENTS ─────────────────────────────────────────
-- Created by admins, scoped to a university.
-- is_published controls visibility to students.
CREATE TABLE announcements (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id  UUID NOT NULL REFERENCES universities(id),
  author_id      UUID NOT NULL REFERENCES profiles(id),
  title          TEXT NOT NULL,
  body           TEXT NOT NULL,
  category       TEXT NOT NULL DEFAULT 'general'
                   CHECK (category IN ('academic','events','admin','general','urgent')),
  is_published   BOOLEAN NOT NULL DEFAULT FALSE,
  published_at   TIMESTAMPTZ,         -- set when is_published flips to TRUE
  expires_at     TIMESTAMPTZ,         -- optional: auto-hide after date
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- Trigger: auto-set published_at when announcement is published
CREATE OR REPLACE FUNCTION handle_announcement_publish()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_published = TRUE AND OLD.is_published = FALSE THEN
    NEW.published_at = NOW();
  END IF;
  RETURN NEW;
END; $$;

CREATE TRIGGER announcements_publish_timestamp
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE PROCEDURE handle_announcement_publish();


-- ── 4. ANNOUNCEMENT READS ────────────────────────────────────
-- Tracks which student read which announcement.
-- Used for engagement analytics (open rates, reach).
CREATE TABLE announcement_reads (
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  read_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);


-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE universities      ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements     ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_reads ENABLE ROW LEVEL SECURITY;


-- ── universities: public read ─────────────────────────────────
CREATE POLICY "universities_public_read" ON universities
  FOR SELECT USING (TRUE);


-- ── profiles ─────────────────────────────────────────────────
-- Own profile: full access
CREATE POLICY "profiles_own_read"   ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_own_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_own_update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Admins: read all profiles in their university
CREATE POLICY "profiles_admin_read" ON profiles FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM profiles admin_p
    WHERE admin_p.id = auth.uid()
      AND admin_p.role IN ('admin','superadmin')
      AND admin_p.university_id = profiles.university_id
  )
);

-- Admins: update verification status of other students
CREATE POLICY "profiles_admin_verify" ON profiles FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM profiles admin_p
    WHERE admin_p.id = auth.uid()
      AND admin_p.role IN ('admin','superadmin')
      AND admin_p.university_id = profiles.university_id
  )
);


-- ── announcements ────────────────────────────────────────────
-- Students: read published announcements from their university
CREATE POLICY "announcements_student_read" ON announcements FOR SELECT USING (
  is_published = TRUE
  AND (expires_at IS NULL OR expires_at > NOW())
  AND university_id = (
    SELECT university_id FROM profiles WHERE id = auth.uid()
  )
);

-- Admins: full CRUD on their university's announcements
CREATE POLICY "announcements_admin_all" ON announcements FOR ALL USING (
  EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = auth.uid()
      AND p.role IN ('admin','superadmin')
      AND p.university_id = announcements.university_id
  )
);


-- ── announcement_reads ───────────────────────────────────────
-- Students: insert and read their own reads
CREATE POLICY "reads_own_insert" ON announcement_reads FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "reads_own_read"   ON announcement_reads FOR SELECT USING (user_id = auth.uid());

-- Admins: read all reads for their university's announcements
CREATE POLICY "reads_admin_read" ON announcement_reads FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM profiles p
    JOIN announcements a ON a.university_id = p.university_id
    WHERE p.id = auth.uid()
      AND p.role IN ('admin','superadmin')
      AND a.id = announcement_reads.announcement_id
  )
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_profiles_university   ON profiles(university_id);
CREATE INDEX idx_profiles_role         ON profiles(role);
CREATE INDEX idx_profiles_verified     ON profiles(is_verified);
CREATE INDEX idx_announcements_uni     ON announcements(university_id);
CREATE INDEX idx_announcements_pub     ON announcements(is_published, published_at DESC);
CREATE INDEX idx_announcements_cat     ON announcements(category);
CREATE INDEX idx_reads_announcement    ON announcement_reads(announcement_id);


-- ============================================================
-- SEED DATA — GCTU (launch university)
-- ============================================================

INSERT INTO universities (name, short_name, slug, domain, accent_color) VALUES
  (
    'Ghana Communication Technology University',
    'GCTU',
    'gctu',
    'gctu.edu.gh',
    '#003F8A'   -- GCTU navy blue
  );
