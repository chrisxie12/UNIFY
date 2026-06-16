-- ============================================================
-- UNIFY — STEP 6: EXTENDED COMMUNITY SYSTEM & ANNOUNCEMENT REQS
-- ============================================================
-- Adds:
--   1. programme column to profiles
--   2. Extended community types (course, hostel, hall, residence,
--      church, sports, entrepreneurship, technology, gaming,
--      photography, music, campus_jobs, scholarships)
--   3. Community managers table (verified leaders who manage communities)
--   4. Announcement requests table (class reps submit for admin approval)
--   5. Updated RLS policies for new tables
--   6. Seed badges for new verified badges
-- ============================================================

-- ── 1. Add programme column to profiles ─────────────────────
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS programme       TEXT,
  ADD COLUMN IF NOT EXISTS faculty         TEXT,
  ADD COLUMN IF NOT EXISTS department      TEXT,
  ADD COLUMN IF NOT EXISTS level           TEXT,
  ADD COLUMN IF NOT EXISTS academic_year   TEXT;

-- ── 2. Update community_requests CHECK constraint ────────────
ALTER TABLE community_requests
  DROP CONSTRAINT IF EXISTS community_requests_community_type_check;

ALTER TABLE community_requests
  ADD CONSTRAINT community_requests_community_type_check
  CHECK (community_type IN (
    -- Academic
    'class', 'level', 'course', 'programme',
    'department', 'faculty', 'university',
    -- Residential
    'hostel', 'hall', 'residence',
    -- Student Life
    'church', 'sports', 'entrepreneurship',
    'technology', 'gaming', 'photography', 'music',
    -- Other
    'campus_jobs', 'scholarships', 'club'
  ));

-- ── 3. Update communities CHECK constraint ──────────────────
ALTER TABLE communities
  DROP CONSTRAINT IF EXISTS communities_community_type_check;

ALTER TABLE communities
  ADD CONSTRAINT communities_community_type_check
  CHECK (community_type IN (
    -- Academic
    'class', 'level', 'course', 'programme',
    'department', 'faculty', 'university',
    -- Residential
    'hostel', 'hall', 'residence',
    -- Student Life
    'church', 'sports', 'entrepreneurship',
    'technology', 'gaming', 'photography', 'music',
    -- Other
    'campus_jobs', 'scholarships', 'club'
  ));

-- ── 4. COMMUNITY MANAGERS ────────────────────────────────────
-- Verified leaders who manage/own a community (separate from general members)
CREATE TABLE IF NOT EXISTS community_managers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id  UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'manager'
                  CHECK (role IN ('owner', 'manager', 'moderator')),
  assigned_by   UUID REFERENCES profiles(id),
  assigned_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (community_id, user_id)
);

-- ── 5. ANNOUNCEMENT REQUESTS ─────────────────────────────────
-- Class reps submit announcements that require admin approval.
CREATE TABLE IF NOT EXISTS announcement_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id    UUID NOT NULL REFERENCES profiles(id),
  university_id   UUID NOT NULL REFERENCES universities(id),
  community_id    UUID REFERENCES communities(id),
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  category        TEXT NOT NULL DEFAULT 'general'
                    CHECK (category IN (
                      'lecture', 'quiz', 'assignment',
                      'project', 'seminar', 'workshop',
                      'exam', 'emergency', 'general'
                    )),
  is_urgent       BOOLEAN NOT NULL DEFAULT FALSE,
  target_audience TEXT, -- 'class', 'department', 'faculty', 'all'
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_notes     TEXT,
  reviewed_by     UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER IF NOT EXISTS announcement_requests_updated_at
  BEFORE UPDATE ON announcement_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── 6. Add programme to verification_requests ───────────────
ALTER TABLE verification_requests
  ADD COLUMN IF NOT EXISTS programme TEXT,
  ADD COLUMN IF NOT EXISTS level     TEXT,
  ADD COLUMN IF NOT EXISTS faculty   TEXT;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE community_managers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_requests   ENABLE ROW LEVEL SECURITY;

-- community_managers: public read, admin all, managers can manage
CREATE POLICY "community_managers_public_read" ON community_managers FOR SELECT USING (TRUE);
CREATE POLICY "community_managers_admin_all" ON community_managers FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- announcement_requests: own CRUD, admin all
CREATE POLICY "announcement_requests_own" ON announcement_requests FOR ALL USING (
  auth.uid() = requester_id
);
CREATE POLICY "announcement_requests_admin_all" ON announcement_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_community_managers_community ON community_managers(community_id);
CREATE INDEX IF NOT EXISTS idx_community_managers_user      ON community_managers(user_id);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_status  ON announcement_requests(status);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_creator ON announcement_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_community ON announcement_requests(community_id);

-- ============================================================
-- SEED DATA — Additional Badges for Verified Roles
-- ============================================================

INSERT INTO badges (name, slug, description, category, is_system) VALUES
  ('Administrator',   'admin',        'UNIFY platform administrator',          'verification', TRUE),
  ('Verified Student','verified_student', 'Identity verified as a real student', 'verification', TRUE)
ON CONFLICT (slug) DO NOTHING;
