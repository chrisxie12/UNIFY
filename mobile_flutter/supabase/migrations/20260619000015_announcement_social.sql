-- ============================================================
-- UNIFY — Step 15: Announcement Social Features + Story RLS
--
-- 1. Add social columns to announcements table
-- 2. Create announcement_likes with auto-count trigger
-- 3. Create announcement_comments with auto-count trigger
-- 4. RLS policies for both tables
-- 5. Snapshots / Stories RLS policies
-- ============================================================

BEGIN;

-- ── 1. Add social columns to announcements ─────────────────────────────────

ALTER TABLE announcements
  ADD COLUMN IF NOT EXISTS is_pinned       BOOLEAN     NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_urgent       BOOLEAN     NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS image_url       TEXT,
  ADD COLUMN IF NOT EXISTS view_count      INTEGER     NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS likes_count     INTEGER     NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS comments_count  INTEGER     NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS shares_count    INTEGER     NOT NULL DEFAULT 0;

-- ── 2. announcement_likes ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS announcement_likes (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID        NOT NULL REFERENCES announcements(id)  ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES profiles(id)        ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (announcement_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_ann_likes_ann  ON announcement_likes(announcement_id);
CREATE INDEX IF NOT EXISTS idx_ann_likes_user ON announcement_likes(user_id);

CREATE OR REPLACE FUNCTION handle_announcement_like_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE announcements SET likes_count = likes_count + 1        WHERE id = NEW.announcement_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE announcements SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.announcement_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_announcement_like_count ON announcement_likes;
CREATE TRIGGER trg_announcement_like_count
  AFTER INSERT OR DELETE ON announcement_likes
  FOR EACH ROW EXECUTE FUNCTION handle_announcement_like_count();

-- ── 3. announcement_comments ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS announcement_comments (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID        NOT NULL REFERENCES announcements(id)  ON DELETE CASCADE,
  author_id       UUID        NOT NULL REFERENCES profiles(id)        ON DELETE CASCADE,
  body            TEXT        NOT NULL CHECK (length(body) > 0),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ann_comments_ann  ON announcement_comments(announcement_id);
CREATE INDEX IF NOT EXISTS idx_ann_comments_auth ON announcement_comments(author_id);

CREATE OR REPLACE FUNCTION handle_announcement_comment_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE announcements SET comments_count = comments_count + 1              WHERE id = NEW.announcement_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE announcements SET comments_count = GREATEST(0, comments_count - 1) WHERE id = OLD.announcement_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_announcement_comment_count ON announcement_comments;
CREATE TRIGGER trg_announcement_comment_count
  AFTER INSERT OR DELETE ON announcement_comments
  FOR EACH ROW EXECUTE FUNCTION handle_announcement_comment_count();

-- ── 4. RLS policies ───────────────────────────────────────────────────────

ALTER TABLE announcement_likes    ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_comments ENABLE ROW LEVEL SECURITY;

-- Likes: visible to any authenticated university member; own row only for write
DROP POLICY IF EXISTS ann_likes_select ON announcement_likes;
CREATE POLICY ann_likes_select ON announcement_likes FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM announcements a
    JOIN   profiles p ON p.university_id = a.university_id
    WHERE  a.id = announcement_id
    AND    p.id = auth.uid()
  )
);

DROP POLICY IF EXISTS ann_likes_insert ON announcement_likes;
CREATE POLICY ann_likes_insert ON announcement_likes FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS ann_likes_delete ON announcement_likes;
CREATE POLICY ann_likes_delete ON announcement_likes FOR DELETE
  USING (user_id = auth.uid());

-- Comments: visible to university members; insert own only; delete own or admin
DROP POLICY IF EXISTS ann_comments_select ON announcement_comments;
CREATE POLICY ann_comments_select ON announcement_comments FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM announcements a
    JOIN   profiles p ON p.university_id = a.university_id
    WHERE  a.id = announcement_id
    AND    p.id = auth.uid()
  )
);

DROP POLICY IF EXISTS ann_comments_insert ON announcement_comments;
CREATE POLICY ann_comments_insert ON announcement_comments FOR INSERT
  WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS ann_comments_delete ON announcement_comments;
CREATE POLICY ann_comments_delete ON announcement_comments FOR DELETE
  USING (
    author_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
  );

-- ── 5. Snapshots / Stories RLS ────────────────────────────────────────────

ALTER TABLE snapshots          ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_views     ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_replies   ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_poll_votes ENABLE ROW LEVEL SECURITY;

-- Active public snapshots from same university
DROP POLICY IF EXISTS snapshots_select ON snapshots;
CREATE POLICY snapshots_select ON snapshots FOR SELECT USING (
  audience = 'public'
  AND expires_at > NOW()
  AND EXISTS (
    SELECT 1
    FROM   profiles viewer
    JOIN   profiles author ON author.id = snapshots.author_id
    WHERE  viewer.id             = auth.uid()
    AND    viewer.university_id  = author.university_id
  )
);

DROP POLICY IF EXISTS snapshots_insert ON snapshots;
CREATE POLICY snapshots_insert ON snapshots FOR INSERT
  WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS snapshots_delete ON snapshots;
CREATE POLICY snapshots_delete ON snapshots FOR DELETE
  USING (author_id = auth.uid());

-- Snapshot views
DROP POLICY IF EXISTS snap_views_select ON snapshot_views;
CREATE POLICY snap_views_select ON snapshot_views FOR SELECT
  USING (
    viewer_id = auth.uid()
    OR EXISTS (SELECT 1 FROM snapshots WHERE id = snapshot_id AND author_id = auth.uid())
  );

DROP POLICY IF EXISTS snap_views_insert ON snapshot_views;
CREATE POLICY snap_views_insert ON snapshot_views FOR INSERT
  WITH CHECK (viewer_id = auth.uid());

-- Snapshot replies
DROP POLICY IF EXISTS snap_replies_select ON snapshot_replies;
CREATE POLICY snap_replies_select ON snapshot_replies FOR SELECT
  USING (sender_id = auth.uid() OR recipient_id = auth.uid());

DROP POLICY IF EXISTS snap_replies_insert ON snapshot_replies;
CREATE POLICY snap_replies_insert ON snapshot_replies FOR INSERT
  WITH CHECK (sender_id = auth.uid());

-- Poll votes
DROP POLICY IF EXISTS snap_poll_votes_select ON snapshot_poll_votes;
CREATE POLICY snap_poll_votes_select ON snapshot_poll_votes FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS snap_poll_votes_insert ON snapshot_poll_votes;
CREATE POLICY snap_poll_votes_insert ON snapshot_poll_votes FOR INSERT
  WITH CHECK (user_id = auth.uid());

COMMIT;
