-- ============================================================
-- UNIFY - STEP 11: Discussion Overhaul - Upvote/Downvote System
-- ============================================================
-- Adds:
--   1. post_votes table (replaces post_likes with upvote/downvote)
--   2. upvote_count, downvote_count, best_answer_id on community_posts
--   3. is_best_answer on post_comments
--   4. Auto-count triggers for post_votes
-- ============================================================

BEGIN;

-- ============================================================
-- 1. ADD NEW COLUMNS TO community_posts
-- ============================================================
ALTER TABLE community_posts
  ADD COLUMN IF NOT EXISTS upvote_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS downvote_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS best_answer_id UUID REFERENCES post_comments(id) ON DELETE SET NULL;

-- ============================================================
-- 2. ADD is_best_answer TO post_comments
-- ============================================================
ALTER TABLE post_comments
  ADD COLUMN IF NOT EXISTS is_best_answer BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_post_comments_best_answer ON post_comments(post_id, is_best_answer);

-- ============================================================
-- 3. POST VOTES TABLE (replaces post_likes)
-- ============================================================
CREATE TABLE IF NOT EXISTS post_votes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id    UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES profiles(id),
  vote_type  TEXT NOT NULL CHECK (vote_type IN ('upvote', 'downvote')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_post_votes_post ON post_votes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_votes_user ON post_votes(user_id);

-- ============================================================
-- 4. AUTO-COUNT TRIGGERS FOR POST VOTES
-- ============================================================
CREATE OR REPLACE FUNCTION update_post_vote_counts()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.vote_type = 'upvote' THEN
      UPDATE community_posts SET upvote_count = upvote_count + 1 WHERE id = NEW.post_id;
    ELSIF NEW.vote_type = 'downvote' THEN
      UPDATE community_posts SET downvote_count = downvote_count + 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.vote_type = 'upvote' THEN
      UPDATE community_posts SET upvote_count = GREATEST(upvote_count - 1, 0) WHERE id = OLD.post_id;
    ELSIF OLD.vote_type = 'downvote' THEN
      UPDATE community_posts SET downvote_count = GREATEST(downvote_count - 1, 0) WHERE id = OLD.post_id;
    END IF;
    RETURN OLD;

  ELSIF TG_OP = 'UPDATE' AND OLD.vote_type != NEW.vote_type THEN
    IF OLD.vote_type = 'upvote' THEN
      UPDATE community_posts SET upvote_count = GREATEST(upvote_count - 1, 0) WHERE id = NEW.post_id;
    ELSIF OLD.vote_type = 'downvote' THEN
      UPDATE community_posts SET downvote_count = GREATEST(downvote_count - 1, 0) WHERE id = NEW.post_id;
    END IF;
    IF NEW.vote_type = 'upvote' THEN
      UPDATE community_posts SET upvote_count = upvote_count + 1 WHERE id = NEW.post_id;
    ELSIF NEW.vote_type = 'downvote' THEN
      UPDATE community_posts SET downvote_count = downvote_count + 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS post_vote_count_trigger ON post_votes;
CREATE TRIGGER post_vote_count_trigger
  AFTER INSERT OR DELETE OR UPDATE ON post_votes FOR EACH ROW
  EXECUTE FUNCTION update_post_vote_counts();

-- ============================================================
-- 5. RLS POLICIES FOR POST VOTES
-- ============================================================
ALTER TABLE post_votes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS post_votes_manage ON post_votes;
CREATE POLICY post_votes_manage ON post_votes FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- 6. GRANT PERMISSIONS
-- ============================================================
GRANT ALL ON post_votes TO authenticated, anon, service_role;

COMMIT;
