-- ============================================================
-- UNIFY — Phase 2b: Personalized Feed (Ranking RPC + Seed Data)
--
-- Combines Phase 2a schema additions + department seeding +
-- the get_personalized_feed RPC function.
-- ============================================================

BEGIN;

-- ── 1a. User follows table (Phase 2a) ──────────────────────────────────────

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

DROP POLICY IF EXISTS user_follows_select ON user_follows;
CREATE POLICY user_follows_select ON user_follows FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS user_follows_insert ON user_follows;
CREATE POLICY user_follows_insert ON user_follows FOR INSERT
  WITH CHECK (follower_id = auth.uid());

DROP POLICY IF EXISTS user_follows_delete ON user_follows;
CREATE POLICY user_follows_delete ON user_follows FOR DELETE
  USING (follower_id = auth.uid());

-- ── 1b. Profile additions (Phase 2a) ──────────────────────────────────────

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_faculty    BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS latitude      DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude     DOUBLE PRECISION;

CREATE INDEX IF NOT EXISTS idx_profiles_department_id ON profiles(department_id);
CREATE INDEX IF NOT EXISTS idx_profiles_is_faculty     ON profiles(is_faculty);

COMMENT ON COLUMN profiles.department_id IS 'FK to departments table; backfill from free-text department column';
COMMENT ON COLUMN profiles.is_faculty     IS 'TRUE if this user is faculty/staff rather than a student';
COMMENT ON COLUMN profiles.latitude       IS 'Last-known WGS84 latitude (set client-side via geolocator)';
COMMENT ON COLUMN profiles.longitude      IS 'Last-known WGS84 longitude (set client-side via geolocator)';

-- ── 1c. Community posts additions (Phase 2a) ──────────────────────────────

ALTER TABLE community_posts
  ADD COLUMN IF NOT EXISTS university_id TEXT,
  ADD COLUMN IF NOT EXISTS latitude      DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude     DOUBLE PRECISION;

CREATE INDEX IF NOT EXISTS idx_community_posts_university ON community_posts(university_id, created_at DESC);

COMMENT ON COLUMN community_posts.university_id IS 'Denormalized from communities.university_id for feed-ranking join efficiency';
COMMENT ON COLUMN community_posts.latitude       IS 'WGS84 latitude for location-proximity scoring';
COMMENT ON COLUMN community_posts.longitude      IS 'WGS84 longitude for location-proximity scoring';

COMMIT;

-- ── 1a. Normalize legacy university_id slugs to UUIDs ──────────────────────
-- announcements.university_id used to store slugs ('gctu'); profiles stores UUIDs
DO $$
BEGIN
  UPDATE announcements a
  SET university_id = u.id::TEXT
  FROM universities u
  WHERE a.university_id = u.slug;
END $$;

-- ── 2. Seed GCTU Schools (faculties) + Departments ────────────────────────
-- GCTU university_id: 36add67e-50ca-4c3a-83b0-46374fb94179

DO $$
DECLARE
  v_gctu_id CONSTANT UUID := '36add67e-50ca-4c3a-83b0-46374fb94179';
  v_scis_id UUID;
  v_soe_id  UUID;
  v_sob_id  UUID;
  v_scs_id  UUID;
BEGIN

  -- Schools (faculties) — insert, silently skip if already exist
  INSERT INTO faculties (id, university_id, name, type) VALUES
    (gen_random_uuid(), v_gctu_id, 'School of Computing and Information Systems', 'school'),
    (gen_random_uuid(), v_gctu_id, 'School of Engineering',                       'school'),
    (gen_random_uuid(), v_gctu_id, 'School of Business',                          'school'),
    (gen_random_uuid(), v_gctu_id, 'School of Communication Studies',             'school')
  ON CONFLICT DO NOTHING;

  -- Fetch generated IDs
  SELECT id INTO v_scis_id FROM faculties WHERE name = 'School of Computing and Information Systems' AND university_id = v_gctu_id;
  SELECT id INTO v_soe_id  FROM faculties WHERE name = 'School of Engineering'                       AND university_id = v_gctu_id;
  SELECT id INTO v_sob_id  FROM faculties WHERE name = 'School of Business'                          AND university_id = v_gctu_id;
  SELECT id INTO v_scs_id  FROM faculties WHERE name = 'School of Communication Studies'             AND university_id = v_gctu_id;

  -- SCIS departments
  INSERT INTO departments (id, faculty_id, name) VALUES
    (gen_random_uuid(), v_scis_id, 'Computer Science'),
    (gen_random_uuid(), v_scis_id, 'Information Technology'),
    (gen_random_uuid(), v_scis_id, 'Software Engineering'),
    (gen_random_uuid(), v_scis_id, 'Mobile Computing'),
    (gen_random_uuid(), v_scis_id, 'Data Science & Analytics'),
    (gen_random_uuid(), v_scis_id, 'Cyber Security'),
    (gen_random_uuid(), v_scis_id, 'Computer Engineering')
  ON CONFLICT DO NOTHING;

  -- SoE departments
  INSERT INTO departments (id, faculty_id, name) VALUES
    (gen_random_uuid(), v_soe_id, 'Telecommunications Engineering'),
    (gen_random_uuid(), v_soe_id, 'Electrical & Electronic Engineering'),
    (gen_random_uuid(), v_soe_id, 'Renewable Energy Engineering')
  ON CONFLICT DO NOTHING;

  -- SoB departments
  INSERT INTO departments (id, faculty_id, name) VALUES
    (gen_random_uuid(), v_sob_id, 'Business Administration'),
    (gen_random_uuid(), v_sob_id, 'Accounting'),
    (gen_random_uuid(), v_sob_id, 'Finance'),
    (gen_random_uuid(), v_sob_id, 'Marketing'),
    (gen_random_uuid(), v_sob_id, 'Human Resource Management'),
    (gen_random_uuid(), v_sob_id, 'Procurement and Supply Chain Management'),
    (gen_random_uuid(), v_sob_id, 'Management')
  ON CONFLICT DO NOTHING;

  -- SCS departments
  INSERT INTO departments (id, faculty_id, name) VALUES
    (gen_random_uuid(), v_scs_id, 'Communication Studies'),
    (gen_random_uuid(), v_scs_id, 'Public Relations'),
    (gen_random_uuid(), v_scs_id, 'Journalism'),
    (gen_random_uuid(), v_scs_id, 'Digital Media')
  ON CONFLICT DO NOTHING;

  -- Backfill profiles.department_id from free-text department
  UPDATE profiles p
  SET department_id = d.id
  FROM departments d
  WHERE p.department IS NOT NULL
    AND p.department_id IS NULL
    AND d.name ILIKE p.department;

  RAISE NOTICE 'Department backfill complete';

END $$;

-- ── 3. Ranking RPC ─────────────────────────────────────────────────────────
-- placeholder weights — revisit after real usage data exists
--   w_follow     = 100  (content from followed authors)
--   w_community  =  70  (content from joined communities)
--   w_department =  70  (content from same department authors)
--   w_university =  40  (content from same university)
--   w_location   =  25  (location proximity)
--   w_engagement =  15  (engagement velocity per hour)

DROP FUNCTION IF EXISTS public.get_personalized_feed(UUID, DOUBLE PRECISION, DOUBLE PRECISION, INT, REAL, TIMESTAMPTZ) CASCADE;

CREATE FUNCTION public.get_personalized_feed(
  p_user_id         UUID,
  p_lat             DOUBLE PRECISION DEFAULT NULL,
  p_lng             DOUBLE PRECISION DEFAULT NULL,
  p_limit           INT DEFAULT 20,
  p_cursor_score    REAL DEFAULT NULL,
  p_cursor_created_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE(
  item_type     TEXT,
  id            UUID,
  title         TEXT,
  body          TEXT,
  category      TEXT,
  author_id     UUID,
  full_name     TEXT,
  avatar_url    TEXT,
  university_id TEXT,
  post_community_id  UUID,
  is_pinned     BOOLEAN,
  image_url     TEXT,
  likes_count   INT,
  comments_count INT,
  shares_count  INT,
  created_at    TIMESTAMPTZ,
  score         REAL
)
LANGUAGE plpgsql STABLE
AS $$
DECLARE
  v_user_univ_id TEXT;
  v_user_dept_id UUID;
  v_user_lat     DOUBLE PRECISION;
  v_user_lng     DOUBLE PRECISION;
BEGIN
  -- Fetch user profile data
  SELECT p.university_id, p.department_id, COALESCE(p.latitude, p_lat), COALESCE(p.longitude, p_lng)
  INTO v_user_univ_id, v_user_dept_id, v_user_lat, v_user_lng
  FROM profiles p
  WHERE p.id = p_user_id;

  -- If we still don't have a university_id, return nothing
  IF v_user_univ_id IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT * FROM (
    WITH
      followed_users AS (
        SELECT following_id FROM user_follows WHERE follower_id = p_user_id
      ),
      joined_communities AS (
        SELECT community_id FROM community_members WHERE user_id = p_user_id
      ),
      candidates AS (
        SELECT
          'announcement'::TEXT AS item_type,
          a.id,
          a.title,
          a.body,
          a.category,
          a.author_id,
          p.full_name,
          p.avatar_url,
          a.university_id,
          NULL::UUID AS community_id,
          a.is_pinned,
          a.image_url,
          a.likes_count,
          a.comments_count,
          a.shares_count,
          a.created_at,
          CASE WHEN uf.following_id IS NOT NULL THEN 1 ELSE 0 END AS is_followed,
          0 AS is_joined_community,
          CASE WHEN p.department_id IS NOT NULL AND p.department_id = v_user_dept_id THEN 1 ELSE 0 END AS is_same_dept,
          1 AS is_same_university,
          (a.likes_count + a.comments_count * 2 + a.shares_count * 1.5)::REAL AS engagement_raw,
          CASE
            WHEN v_user_lat IS NOT NULL AND v_user_lng IS NOT NULL
                 AND p.latitude IS NOT NULL AND p.longitude IS NOT NULL
            THEN 1.0 / (1.0 + (
              ACOS(
                SIN(RADIANS(v_user_lat)) * SIN(RADIANS(p.latitude))
                + COS(RADIANS(v_user_lat)) * COS(RADIANS(p.latitude))
                * COS(RADIANS(v_user_lng - p.longitude))
              ) * 6371.0 / 10.0
            ))
            ELSE 0
          END AS location_proximity
        FROM announcements a
        JOIN profiles p ON p.id = a.author_id
        LEFT JOIN followed_users uf ON uf.following_id = a.author_id
        WHERE a.university_id = v_user_univ_id

        UNION ALL

        SELECT
          'post'::TEXT AS item_type,
          cp.id,
          COALESCE(cp.title, '') AS title,
          COALESCE(cp.content, '') AS body,
          'post' AS category,
          cp.author_id,
          p.full_name,
          p.avatar_url,
          cp.university_id,
          cp.community_id,
          cp.is_pinned,
          NULL::TEXT AS image_url,
          cp.likes_count,
          cp.comments_count,
          0 AS shares_count,
          cp.created_at,
          CASE WHEN uf.following_id IS NOT NULL THEN 1 ELSE 0 END AS is_followed,
          CASE WHEN jc.community_id IS NOT NULL THEN 1 ELSE 0 END AS is_joined_community,
          CASE WHEN p.department_id IS NOT NULL AND p.department_id = v_user_dept_id THEN 1 ELSE 0 END AS is_same_dept,
          CASE WHEN cp.university_id = v_user_univ_id THEN 1 ELSE 0 END AS is_same_university,
          (cp.likes_count + cp.comments_count * 2)::REAL AS engagement_raw,
          CASE
            WHEN v_user_lat IS NOT NULL AND v_user_lng IS NOT NULL
                 AND cp.latitude IS NOT NULL AND cp.longitude IS NOT NULL
            THEN 1.0 / (1.0 + (
              ACOS(
                SIN(RADIANS(v_user_lat)) * SIN(RADIANS(cp.latitude))
                + COS(RADIANS(v_user_lat)) * COS(RADIANS(cp.latitude))
                * COS(RADIANS(v_user_lng - cp.longitude))
              ) * 6371.0 / 10.0
            ))
            ELSE 0
          END AS location_proximity
        FROM community_posts cp
        JOIN profiles p ON p.id = cp.author_id
        LEFT JOIN followed_users uf ON uf.following_id = cp.author_id
        LEFT JOIN joined_communities jc ON jc.community_id = cp.community_id
        WHERE jc.community_id IS NOT NULL OR uf.following_id IS NOT NULL
      )
    SELECT
      c.item_type,
      c.id,
      c.title,
      c.body,
      c.category,
      c.author_id,
      c.full_name,
      c.avatar_url,
      c.university_id,
      c.community_id,
      c.is_pinned,
      c.image_url,
      c.likes_count,
      c.comments_count,
      c.shares_count,
      c.created_at,
      (
        (
          c.is_followed * 100 + c.is_joined_community * 70 + c.is_same_dept * 70
          + c.is_same_university * 40 + c.location_proximity * 25
          + (c.engagement_raw / GREATEST(EXTRACT(EPOCH FROM (NOW() - c.created_at)) / 3600.0 + 2.0, 1.0)) * 15
        ) * EXP(-EXTRACT(EPOCH FROM (NOW() - c.created_at)) / 86400.0)
      )::REAL AS score
    FROM candidates c
  ) sub
  WHERE
    p_cursor_score IS NULL
    OR (sub.score < p_cursor_score OR (sub.score = p_cursor_score AND sub.created_at < p_cursor_created_at))
  ORDER BY sub.score DESC, sub.created_at DESC
  LIMIT p_limit;
END;
$$;
