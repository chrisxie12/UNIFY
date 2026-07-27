-- ============================================================
-- UNIFY — Phase 2a: Ranked Feed Infrastructure
--
-- SAFETY: All alters use IF NOT EXISTS / IF EXISTS. Run against
-- dev/staging first, verify row counts below, then apply prod.
--
-- Backfill row-count checks (run BEFORE this migration):
--
--   -- profiles needing department_id backfill (free-text match)
--   SELECT COUNT(*) FROM profiles p
--   WHERE p.department IS NOT NULL
--     AND NOT EXISTS (SELECT 1 FROM departments d WHERE d.name ILIKE p.department);
--
--   -- community_posts that will get a NULL university_id (orphan check)
--   SELECT COUNT(*) FROM community_posts cp
--   WHERE NOT EXISTS (SELECT 1 FROM communities c WHERE c.id = cp.community_id);
--
--   -- community_posts that will get a non-null university_id
--   SELECT COUNT(*) FROM community_posts cp
--   JOIN communities c ON c.id = cp.community_id;
-- ============================================================

BEGIN;

-- ── 1. User follows (friendship) table ────────────────────────────────────
-- W1 (score 100) tier: content from followed authors.

CREATE TABLE IF NOT EXISTS user_follows (
  follower_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower  ON user_follows(follower_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id, created_at DESC);

ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- Authenticated users can see who follows whom (needed for feed ranking)
DROP POLICY IF EXISTS user_follows_select ON user_follows;
CREATE POLICY user_follows_select ON user_follows FOR SELECT
  USING (auth.role() = 'authenticated');

-- Users manage their own follow list
DROP POLICY IF EXISTS user_follows_insert ON user_follows;
CREATE POLICY user_follows_insert ON user_follows FOR INSERT
  WITH CHECK (follower_id = auth.uid());

DROP POLICY IF EXISTS user_follows_delete ON user_follows;
CREATE POLICY user_follows_delete ON user_follows FOR DELETE
  USING (follower_id = auth.uid());

-- ── 2. Profile additions: department FK + faculty flag ────────────────────
-- W3 (score 70) tier: same-department content.
-- W4 (score 40) tier: same-university content (university_id already exists).

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_faculty    BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_profiles_department_id ON profiles(department_id);
CREATE INDEX IF NOT EXISTS idx_profiles_is_faculty     ON profiles(is_faculty);

COMMENT ON COLUMN profiles.department_id IS 'FK to departments table; backfill from free-text department column in app logic';
COMMENT ON COLUMN profiles.is_faculty     IS 'TRUE if this user is faculty/staff rather than a student';

-- ── 3. Community posts: university_id + geo columns ───────────────────────
-- university_id avoids a join through communities for feed ranking.
-- lat/lng enable W5 (location-proximity) scoring.

ALTER TABLE community_posts
  ADD COLUMN IF NOT EXISTS university_id UUID REFERENCES universities(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS latitude      DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude     DOUBLE PRECISION;

-- Backfill university_id from the parent community
UPDATE community_posts cp
SET university_id = c.university_id
FROM communities c
WHERE c.id = cp.community_id
  AND cp.university_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_community_posts_university ON community_posts(university_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_geo         ON community_posts(latitude, longitude);

COMMENT ON COLUMN community_posts.university_id IS 'Denormalized from communities.university_id for feed-ranking join efficiency';
COMMENT ON COLUMN community_posts.latitude       IS 'WGS84 latitude for location-proximity scoring';
COMMENT ON COLUMN community_posts.longitude      IS 'WGS84 longitude for location-proximity scoring';

-- ── 4. Profiles: lat/lng for user location (W5 scoring reference) ─────────

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS latitude  DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

COMMENT ON COLUMN profiles.latitude  IS 'Last-known WGS84 latitude (set client-side via geolocator)';
COMMENT ON COLUMN profiles.longitude IS 'Last-known WGS84 longitude (set client-side via geolocator)';

COMMIT;
