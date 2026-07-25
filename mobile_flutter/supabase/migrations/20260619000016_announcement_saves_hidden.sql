-- ============================================================
-- UNIFY — Step 16: Announcement Saves + Hidden Posts
--
-- 1. announcement_saves — bookmark posts for later
-- 2. hidden_posts — per-user local hide/dismiss
-- 3. RLS policies for both
-- ============================================================

BEGIN;

-- ── 1. announcement_saves ────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS announcement_saves (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID        NOT NULL REFERENCES announcements(id)  ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES profiles(id)        ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (announcement_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_ann_saves_ann  ON announcement_saves(announcement_id);
CREATE INDEX IF NOT EXISTS idx_ann_saves_user ON announcement_saves(user_id);

ALTER TABLE announcement_saves ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ann_saves_select ON announcement_saves;
CREATE POLICY ann_saves_select ON announcement_saves FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS ann_saves_insert ON announcement_saves;
CREATE POLICY ann_saves_insert ON announcement_saves FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS ann_saves_delete ON announcement_saves;
CREATE POLICY ann_saves_delete ON announcement_saves FOR DELETE USING (user_id = auth.uid());

-- ── 2. hidden_posts ──────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS hidden_posts (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID        NOT NULL REFERENCES announcements(id)  ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES profiles(id)        ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (announcement_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_hidden_posts_user ON hidden_posts(user_id);

ALTER TABLE hidden_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS hidden_posts_select ON hidden_posts;
CREATE POLICY hidden_posts_select ON hidden_posts FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS hidden_posts_insert ON hidden_posts;
CREATE POLICY hidden_posts_insert ON hidden_posts FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS hidden_posts_delete ON hidden_posts;
CREATE POLICY hidden_posts_delete ON hidden_posts FOR DELETE USING (user_id = auth.uid());

COMMIT;
