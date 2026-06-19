-- UNIFY Content: posts, events, polls, discussions, snapshots, resources, reports, notifications

BEGIN;

-- ── Community Posts ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS community_posts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  author_id       UUID NOT NULL REFERENCES profiles(id),
  title           TEXT,
  body            TEXT NOT NULL,
  post_type       TEXT NOT NULL DEFAULT 'text' CHECK (post_type IN ('text','image','link','video','pdf','poll','question')),
  media_url       TEXT,
  link_url        TEXT,
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  is_announcement BOOLEAN NOT NULL DEFAULT FALSE,
  upvote_count    INTEGER NOT NULL DEFAULT 0,
  downvote_count  INTEGER NOT NULL DEFAULT 0,
  likes_count     INTEGER NOT NULL DEFAULT 0,
  comments_count  INTEGER NOT NULL DEFAULT 0,
  shares_count    INTEGER NOT NULL DEFAULT 0,
  bookmarks_count INTEGER NOT NULL DEFAULT 0,
  best_answer_id  UUID,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_posts_community ON community_posts(community_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_pinned   ON community_posts(community_id, is_pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_author   ON community_posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_community_created  ON community_posts(community_id, created_at DESC);

-- Post Comments (nested)
CREATE TABLE IF NOT EXISTS post_comments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id       UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  parent_id     UUID REFERENCES post_comments(id) ON DELETE CASCADE,
  author_id     UUID NOT NULL REFERENCES profiles(id),
  body          TEXT NOT NULL,
  is_best_answer BOOLEAN NOT NULL DEFAULT FALSE,
  likes_count   INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_post_comments_post   ON post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_parent ON post_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_best_answer ON post_comments(post_id, is_best_answer);

-- Post Votes (upvote/downvote)
CREATE TABLE IF NOT EXISTS post_votes (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id   UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  vote_type TEXT NOT NULL CHECK (vote_type IN ('upvote', 'downvote')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_post_votes_post ON post_votes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_votes_user ON post_votes(user_id);

-- Post Likes
CREATE TABLE IF NOT EXISTS post_likes (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id   UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, user_id)
);

-- Post Bookmarks
CREATE TABLE IF NOT EXISTS post_bookmarks (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id   UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON post_bookmarks(user_id, created_at DESC);

-- Comment Likes
CREATE TABLE IF NOT EXISTS comment_likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES post_comments(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);

-- Auto-count: post vote counts
CREATE OR REPLACE FUNCTION update_post_vote_counts()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.vote_type = 'upvote' THEN
      UPDATE community_posts SET upvote_count = upvote_count + 1 WHERE id = NEW.post_id;
    ELSE
      UPDATE community_posts SET downvote_count = downvote_count + 1 WHERE id = NEW.post_id;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.vote_type = 'upvote' THEN
      UPDATE community_posts SET upvote_count = GREATEST(upvote_count - 1, 0) WHERE id = OLD.post_id;
    ELSE
      UPDATE community_posts SET downvote_count = GREATEST(downvote_count - 1, 0) WHERE id = OLD.post_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS post_vote_count_trigger ON post_votes;
CREATE TRIGGER post_vote_count_trigger
  AFTER INSERT OR DELETE ON post_votes FOR EACH ROW
  EXECUTE FUNCTION update_post_vote_counts();

-- Auto-count: post likes
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS post_likes_count_trigger ON post_likes;
CREATE TRIGGER post_likes_count_trigger
  AFTER INSERT OR DELETE ON post_likes FOR EACH ROW
  EXECUTE FUNCTION update_post_likes_count();

-- Auto-count: post comments
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.parent_id IS NULL THEN
    UPDATE community_posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' AND OLD.parent_id IS NULL THEN
    UPDATE community_posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS post_comments_count_trigger ON post_comments;
CREATE TRIGGER post_comments_count_trigger
  AFTER INSERT OR DELETE ON post_comments FOR EACH ROW
  EXECUTE FUNCTION update_post_comments_count();

-- ── Community Events ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS community_events (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  creator_id      UUID NOT NULL REFERENCES profiles(id),
  title           TEXT NOT NULL,
  description     TEXT,
  location        TEXT,
  event_date      DATE NOT NULL,
  event_time      TIME,
  end_date        DATE,
  end_time        TIME,
  cover_url       TEXT,
  event_type      TEXT NOT NULL DEFAULT 'class' CHECK (event_type IN ('class','study_session','workshop','hackathon','orientation','meeting','social','other')),
  rsvp_count      INTEGER NOT NULL DEFAULT 0,
  max_attendees   INTEGER,
  is_virtual      BOOLEAN NOT NULL DEFAULT FALSE,
  meeting_link    TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_events_community ON community_events(community_id, event_date);
CREATE INDEX IF NOT EXISTS idx_community_events_date      ON community_events(event_date);

-- Event RSVPs
CREATE TABLE IF NOT EXISTS event_rsvps (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id  UUID NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  status    TEXT NOT NULL DEFAULT 'going' CHECK (status IN ('going', 'maybe', 'not_going')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_rsvps_event_user ON event_rsvps(event_id, user_id);

-- Auto-count: RSVPs
CREATE OR REPLACE FUNCTION update_event_rsvp_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'going' THEN
    UPDATE community_events SET rsvp_count = rsvp_count + 1 WHERE id = NEW.event_id;
  ELSIF TG_OP = 'DELETE' AND OLD.status = 'going' THEN
    UPDATE community_events SET rsvp_count = GREATEST(rsvp_count - 1, 0) WHERE id = OLD.event_id;
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'going' AND NEW.status != 'going' THEN
    UPDATE community_events SET rsvp_count = GREATEST(rsvp_count - 1, 0) WHERE id = NEW.event_id;
  ELSIF TG_OP = 'UPDATE' AND OLD.status != 'going' AND NEW.status = 'going' THEN
    UPDATE community_events SET rsvp_count = rsvp_count + 1 WHERE id = NEW.event_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS event_rsvp_count_trigger ON event_rsvps;
CREATE TRIGGER event_rsvp_count_trigger
  AFTER INSERT OR DELETE OR UPDATE ON event_rsvps FOR EACH ROW
  EXECUTE FUNCTION update_event_rsvp_count();

-- ── Community Polls ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS community_polls (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  creator_id      UUID NOT NULL REFERENCES profiles(id),
  question        TEXT NOT NULL,
  description     TEXT,
  poll_type       TEXT NOT NULL DEFAULT 'single' CHECK (poll_type IN ('single', 'multiple')),
  is_anonymous    BOOLEAN NOT NULL DEFAULT FALSE,
  is_locked       BOOLEAN NOT NULL DEFAULT FALSE,
  expires_at      TIMESTAMPTZ,
  total_votes     INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_polls_community ON community_polls(community_id);

CREATE TABLE IF NOT EXISTS poll_options (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id    UUID NOT NULL REFERENCES community_polls(id) ON DELETE CASCADE,
  label      TEXT NOT NULL,
  vote_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS poll_votes (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id   UUID NOT NULL REFERENCES community_polls(id) ON DELETE CASCADE,
  option_id UUID NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (poll_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_poll_votes_user   ON poll_votes(user_id);
CREATE INDEX IF NOT EXISTS idx_poll_votes_option ON poll_votes(option_id);

-- Auto-count: poll votes
CREATE OR REPLACE FUNCTION update_poll_vote_counts()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE poll_options SET vote_count = vote_count + 1 WHERE id = NEW.option_id;
    UPDATE community_polls SET total_votes = total_votes + 1 WHERE id = NEW.poll_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE poll_options SET vote_count = GREATEST(vote_count - 1, 0) WHERE id = OLD.option_id;
    UPDATE community_polls SET total_votes = GREATEST(total_votes - 1, 0) WHERE id = OLD.poll_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS poll_vote_count_trigger ON poll_votes;
CREATE TRIGGER poll_vote_count_trigger
  AFTER INSERT OR DELETE ON poll_votes FOR EACH ROW
  EXECUTE FUNCTION update_poll_vote_counts();

-- ── Community Resources ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS community_resources (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  uploader_id     UUID NOT NULL REFERENCES profiles(id),
  title           TEXT NOT NULL,
  description     TEXT,
  file_type       TEXT NOT NULL,
  file_url        TEXT NOT NULL,
  file_size       BIGINT,
  resource_type   TEXT NOT NULL DEFAULT 'other',
  download_count  INTEGER NOT NULL DEFAULT 0,
  is_approved     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_resources_community ON community_resources(community_id);
CREATE INDEX IF NOT EXISTS idx_community_resources_category  ON community_resources(resource_type);

-- ── Discussions ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS discussions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id   UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  author_id      UUID NOT NULL REFERENCES profiles(id),
  title          TEXT NOT NULL,
  body           TEXT NOT NULL,
  is_pinned      BOOLEAN NOT NULL DEFAULT FALSE,
  is_locked      BOOLEAN NOT NULL DEFAULT FALSE,
  tags           TEXT[] DEFAULT '{}',
  likes_count    INTEGER NOT NULL DEFAULT 0,
  comments_count INTEGER NOT NULL DEFAULT 0,
  view_count     INTEGER NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discussions_community ON discussions(community_id);
CREATE INDEX IF NOT EXISTS idx_discussions_author    ON discussions(author_id);
CREATE INDEX IF NOT EXISTS idx_discussions_pinned    ON discussions(community_id, is_pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_discussions_created   ON discussions(community_id, created_at DESC);

CREATE TABLE IF NOT EXISTS discussion_comments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  parent_id     UUID REFERENCES discussion_comments(id) ON DELETE CASCADE,
  author_id     UUID NOT NULL REFERENCES profiles(id),
  body          TEXT NOT NULL,
  likes_count   INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discussion_comments_discussion ON discussion_comments(discussion_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_parent     ON discussion_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_author     ON discussion_comments(author_id);

CREATE TABLE IF NOT EXISTS discussion_likes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (discussion_id, user_id)
);

CREATE TABLE IF NOT EXISTS discussion_comment_likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES discussion_comments(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);

-- Auto-count: discussion likes
CREATE OR REPLACE FUNCTION update_discussion_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE discussions SET likes_count = likes_count + 1 WHERE id = NEW.discussion_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE discussions SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.discussion_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS discussion_likes_count_trigger ON discussion_likes;
CREATE TRIGGER discussion_likes_count_trigger
  AFTER INSERT OR DELETE ON discussion_likes FOR EACH ROW
  EXECUTE FUNCTION update_discussion_likes_count();

-- Auto-count: discussion comments
CREATE OR REPLACE FUNCTION update_discussion_comments_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE discussions SET comments_count = comments_count + 1 WHERE id = NEW.discussion_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE discussions SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.discussion_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS discussion_comments_count_trigger ON discussion_comments;
CREATE TRIGGER discussion_comments_count_trigger
  AFTER INSERT OR DELETE ON discussion_comments FOR EACH ROW
  EXECUTE FUNCTION update_discussion_comments_count();

-- ── Snapshots ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS snapshots (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  community_id     UUID REFERENCES communities(id) ON DELETE CASCADE,
  type             TEXT NOT NULL CHECK (type IN ('photo','video','text','poll','question')),
  media_url        TEXT,
  caption          TEXT,
  text_content     TEXT,
  background_color TEXT,
  audience         TEXT NOT NULL DEFAULT 'public' CHECK (audience IN ('public','friends','community')),
  is_official      BOOLEAN NOT NULL DEFAULT FALSE,
  view_count       INTEGER NOT NULL DEFAULT 0,
  reaction_count   INTEGER NOT NULL DEFAULT 0,
  reply_count      INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at       TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours')
);

CREATE INDEX IF NOT EXISTS idx_snapshots_active    ON snapshots(expires_at, created_at);
CREATE INDEX IF NOT EXISTS idx_snapshots_author    ON snapshots(author_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_community ON snapshots(community_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_official  ON snapshots(is_official);

CREATE TABLE IF NOT EXISTS snapshot_poll_options (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  label       TEXT NOT NULL,
  position    INTEGER NOT NULL DEFAULT 0,
  vote_count  INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_poll_options_snapshot ON snapshot_poll_options(snapshot_id);

CREATE TABLE IF NOT EXISTS snapshot_poll_votes (
  snapshot_id UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  option_id   UUID NOT NULL REFERENCES snapshot_poll_options(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (snapshot_id, user_id)
);

CREATE TABLE IF NOT EXISTS snapshot_views (
  snapshot_id UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  viewer_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  viewed_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (snapshot_id, viewer_id)
);

CREATE TABLE IF NOT EXISTS snapshot_reactions (
  snapshot_id UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  emoji       TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (snapshot_id, user_id)
);

CREATE TABLE IF NOT EXISTS snapshot_replies (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id  UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  sender_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  body         TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_snapshot_replies_snapshot ON snapshot_replies(snapshot_id);

CREATE TABLE IF NOT EXISTS snapshot_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason      TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','reviewed','dismissed')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS snapshot_mutes (
  muter_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  muted_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (muter_id, muted_id)
);

-- Auto-count: snapshot view count
CREATE OR REPLACE FUNCTION bump_snapshot_view_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE snapshots SET view_count = view_count + 1 WHERE id = NEW.snapshot_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_snapshot_view_count ON snapshot_views;
CREATE TRIGGER trg_snapshot_view_count
  AFTER INSERT ON snapshot_views FOR EACH ROW
  EXECUTE FUNCTION bump_snapshot_view_count();

-- Auto-count: snapshot reaction count
CREATE OR REPLACE FUNCTION sync_snapshot_reaction_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE snapshots SET reaction_count = reaction_count + 1 WHERE id = NEW.snapshot_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE snapshots SET reaction_count = GREATEST(reaction_count - 1, 0) WHERE id = OLD.snapshot_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_snapshot_reaction_count ON snapshot_reactions;
CREATE TRIGGER trg_snapshot_reaction_count
  AFTER INSERT OR DELETE ON snapshot_reactions FOR EACH ROW
  EXECUTE FUNCTION sync_snapshot_reaction_count();

-- Auto-count: snapshot reply count
CREATE OR REPLACE FUNCTION bump_snapshot_reply_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE snapshots SET reply_count = reply_count + 1 WHERE id = NEW.snapshot_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_snapshot_reply_count ON snapshot_replies;
CREATE TRIGGER trg_snapshot_reply_count
  AFTER INSERT ON snapshot_replies FOR EACH ROW
  EXECUTE FUNCTION bump_snapshot_reply_count();

-- Auto-count: poll option votes in snapshots
CREATE OR REPLACE FUNCTION bump_poll_option_votes()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE snapshot_poll_options SET vote_count = vote_count + 1 WHERE id = NEW.option_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_poll_option_votes ON snapshot_poll_votes;
CREATE TRIGGER trg_poll_option_votes
  AFTER INSERT ON snapshot_poll_votes FOR EACH ROW
  EXECUTE FUNCTION bump_poll_option_votes();

-- Auto-expire: delete expired snapshots
CREATE OR REPLACE FUNCTION delete_expired_snapshots()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  DELETE FROM snapshots WHERE expires_at < NOW();
  RETURN NULL;
END;
$$;

-- ── Reports ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reports (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id     UUID NOT NULL REFERENCES profiles(id),
  report_type     TEXT NOT NULL,
  target_id       TEXT NOT NULL,
  target_owner_id UUID REFERENCES profiles(id),
  reason          TEXT NOT NULL,
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'open',
  resolved_by     UUID REFERENCES profiles(id),
  resolved_at     TIMESTAMPTZ,
  admin_notes     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_type   ON reports(report_type);

-- ── Notifications ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type            TEXT NOT NULL,
  title           TEXT NOT NULL,
  body            TEXT,
  reference_id    TEXT,
  reference_type  TEXT,
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user      ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread    ON notifications(user_id) WHERE NOT is_read;
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);

-- ── RLS Policies ─────────────────────────────────────────────────
ALTER TABLE community_posts  ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_votes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_bookmarks   ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes    ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_rsvps      ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_polls  ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_options     ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_votes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshots        ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_poll_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_views   ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_mutes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports          ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications    ENABLE ROW LEVEL SECURITY;

-- Community posts: members read
DROP POLICY IF EXISTS posts_read ON community_posts;
CREATE POLICY posts_read ON community_posts FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_posts.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS posts_insert ON community_posts;
CREATE POLICY posts_insert ON community_posts FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
);
DROP POLICY IF EXISTS posts_update ON community_posts;
CREATE POLICY posts_update ON community_posts FOR UPDATE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_posts.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS posts_delete ON community_posts;
CREATE POLICY posts_delete ON community_posts FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_posts.community_id AND user_id = auth.uid() AND role IN ('owner','manager','moderator') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Post comments
DROP POLICY IF EXISTS post_comments_read ON post_comments;
CREATE POLICY post_comments_read ON post_comments FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_posts p JOIN community_members cm ON p.community_id = cm.community_id WHERE p.id = post_comments.post_id AND cm.user_id = auth.uid())
);
DROP POLICY IF EXISTS post_comments_insert ON post_comments;
CREATE POLICY post_comments_insert ON post_comments FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_posts p JOIN community_members cm ON p.community_id = cm.community_id WHERE p.id = NEW.post_id AND cm.user_id = auth.uid())
);
DROP POLICY IF EXISTS post_comments_delete ON post_comments;
CREATE POLICY post_comments_delete ON post_comments FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers cm JOIN community_posts p ON p.community_id = cm.community_id WHERE p.id = post_comments.post_id AND cm.user_id = auth.uid() AND cm.is_active = TRUE)
);

-- Post votes: self-manage
DROP POLICY IF EXISTS post_votes_manage ON post_votes;
CREATE POLICY post_votes_manage ON post_votes FOR ALL USING (auth.uid() = user_id);

-- Post likes: self-manage
DROP POLICY IF EXISTS post_likes_manage ON post_likes;
CREATE POLICY post_likes_manage ON post_likes FOR ALL USING (auth.uid() = user_id);

-- Post bookmarks: self-manage
DROP POLICY IF EXISTS post_bookmarks_manage ON post_bookmarks;
CREATE POLICY post_bookmarks_manage ON post_bookmarks FOR ALL USING (auth.uid() = user_id);

-- Comment likes: self-manage
DROP POLICY IF EXISTS comment_likes_manage ON comment_likes;
CREATE POLICY comment_likes_manage ON comment_likes FOR ALL USING (auth.uid() = user_id);

-- Events
DROP POLICY IF EXISTS events_read ON community_events;
CREATE POLICY events_read ON community_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_events.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS events_insert ON community_events;
CREATE POLICY events_insert ON community_events FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
  AND (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
    OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = NEW.community_id AND user_id = auth.uid() AND is_active = TRUE))
);
DROP POLICY IF EXISTS events_update ON community_events;
CREATE POLICY events_update ON community_events FOR UPDATE USING (
  creator_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_events.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS events_delete ON community_events;
CREATE POLICY events_delete ON community_events FOR DELETE USING (
  creator_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_events.community_id AND user_id = auth.uid() AND role IN ('owner','manager') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Event RSVPs: self-manage
DROP POLICY IF EXISTS event_rsvps_manage ON event_rsvps;
CREATE POLICY event_rsvps_manage ON event_rsvps FOR ALL USING (auth.uid() = user_id);

-- Polls
DROP POLICY IF EXISTS polls_read ON community_polls;
CREATE POLICY polls_read ON community_polls FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_polls.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS polls_insert ON community_polls;
CREATE POLICY polls_insert ON community_polls FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
  AND (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
    OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = NEW.community_id AND user_id = auth.uid() AND is_active = TRUE))
);
DROP POLICY IF EXISTS polls_update ON community_polls;
CREATE POLICY polls_update ON community_polls FOR UPDATE USING (
  creator_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_polls.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Poll options: members read
DROP POLICY IF EXISTS poll_options_read ON poll_options;
CREATE POLICY poll_options_read ON poll_options FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_polls p JOIN community_members cm ON p.community_id = cm.community_id WHERE p.id = poll_options.poll_id AND cm.user_id = auth.uid())
);

-- Poll votes: self-manage
DROP POLICY IF EXISTS poll_votes_manage ON poll_votes;
CREATE POLICY poll_votes_manage ON poll_votes FOR ALL USING (auth.uid() = user_id);

-- Community resources: members read
DROP POLICY IF EXISTS resources_read_members ON community_resources;
CREATE POLICY resources_read_members ON community_resources FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_resources.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS resources_insert_members ON community_resources;
CREATE POLICY resources_insert_members ON community_resources FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_id AND user_id = auth.uid())
);
DROP POLICY IF EXISTS resources_update_mod ON community_resources;
CREATE POLICY resources_update_mod ON community_resources FOR UPDATE USING (
  uploader_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_resources.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussions: members read
DROP POLICY IF EXISTS discussions_read_members ON discussions;
CREATE POLICY discussions_read_members ON discussions FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = discussions.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS discussions_insert_members ON discussions;
CREATE POLICY discussions_insert_members ON discussions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_id AND user_id = auth.uid())
);
DROP POLICY IF EXISTS discussions_update_own_mod ON discussions;
CREATE POLICY discussions_update_own_mod ON discussions FOR UPDATE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = discussions.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS discussions_delete_own_mod ON discussions;
CREATE POLICY discussions_delete_own_mod ON discussions FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = discussions.community_id AND user_id = auth.uid() AND role IN ('owner','manager','moderator') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussion comments
DROP POLICY IF EXISTS discussion_comments_read ON discussion_comments;
CREATE POLICY discussion_comments_read ON discussion_comments FOR SELECT USING (
  EXISTS (SELECT 1 FROM discussions d JOIN community_members cm ON d.community_id = cm.community_id WHERE d.id = discussion_comments.discussion_id AND cm.user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS discussion_comments_insert ON discussion_comments;
CREATE POLICY discussion_comments_insert ON discussion_comments FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members cm JOIN discussions d ON cm.community_id = d.community_id WHERE d.id = discussion_id AND cm.user_id = auth.uid())
);
DROP POLICY IF EXISTS discussion_comments_delete ON discussion_comments;
CREATE POLICY discussion_comments_delete ON discussion_comments FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers cm JOIN discussions d ON cm.community_id = d.community_id WHERE d.id = discussion_comments.discussion_id AND cm.user_id = auth.uid() AND cm.is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussion likes: self-manage
DROP POLICY IF EXISTS discussion_likes_manage ON discussion_likes;
CREATE POLICY discussion_likes_manage ON discussion_likes FOR ALL USING (auth.uid() = user_id);

-- Discussion comment likes: self-manage
DROP POLICY IF EXISTS discussion_comment_likes_manage ON discussion_comment_likes;
CREATE POLICY discussion_comment_likes_manage ON discussion_comment_likes FOR ALL USING (auth.uid() = user_id);

-- Snapshots
DROP POLICY IF EXISTS snapshots_select ON snapshots;
CREATE POLICY snapshots_select ON snapshots FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS snapshots_insert ON snapshots;
CREATE POLICY snapshots_insert ON snapshots FOR INSERT WITH CHECK (author_id = auth.uid());
DROP POLICY IF EXISTS snapshots_delete ON snapshots;
CREATE POLICY snapshots_delete ON snapshots FOR DELETE USING (author_id = auth.uid());
DROP POLICY IF EXISTS poll_options_select ON snapshot_poll_options;
CREATE POLICY poll_options_select ON snapshot_poll_options FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS poll_options_insert ON snapshot_poll_options;
CREATE POLICY poll_options_insert ON snapshot_poll_options FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM snapshots WHERE id = snapshot_id AND author_id = auth.uid()));
DROP POLICY IF EXISTS poll_votes_select ON snapshot_poll_votes;
CREATE POLICY poll_votes_select ON snapshot_poll_votes FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS poll_votes_insert ON snapshot_poll_votes;
CREATE POLICY poll_votes_insert ON snapshot_poll_votes FOR INSERT WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS views_insert ON snapshot_views;
CREATE POLICY views_insert ON snapshot_views FOR INSERT WITH CHECK (viewer_id = auth.uid());
DROP POLICY IF EXISTS views_select ON snapshot_views;
CREATE POLICY views_select ON snapshot_views FOR SELECT USING (viewer_id = auth.uid() OR EXISTS (SELECT 1 FROM snapshots WHERE id = snapshot_id AND author_id = auth.uid()));
DROP POLICY IF EXISTS reactions_select ON snapshot_reactions;
CREATE POLICY reactions_select ON snapshot_reactions FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS reactions_write ON snapshot_reactions;
CREATE POLICY reactions_write ON snapshot_reactions FOR INSERT OR DELETE USING (user_id = auth.uid());
DROP POLICY IF EXISTS replies_insert ON snapshot_replies;
CREATE POLICY replies_insert ON snapshot_replies FOR INSERT WITH CHECK (sender_id = auth.uid());
DROP POLICY IF EXISTS replies_select ON snapshot_replies;
CREATE POLICY replies_select ON snapshot_replies FOR SELECT USING (sender_id = auth.uid() OR recipient_id = auth.uid());
DROP POLICY IF EXISTS reports_insert ON snapshot_reports;
CREATE POLICY reports_insert ON snapshot_reports FOR INSERT WITH CHECK (reporter_id = auth.uid());
DROP POLICY IF EXISTS mutes_write ON snapshot_mutes;
CREATE POLICY mutes_write ON snapshot_mutes FOR INSERT OR DELETE USING (muter_id = auth.uid());

-- Reports
DROP POLICY IF EXISTS reports_insert_own ON reports;
CREATE POLICY reports_insert_own ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
DROP POLICY IF EXISTS reports_select_admin ON reports;
CREATE POLICY reports_select_admin ON reports FOR SELECT USING (
  auth.uid() = reporter_id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
DROP POLICY IF EXISTS reports_update_admin ON reports;
CREATE POLICY reports_update_admin ON reports FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Notifications
DROP POLICY IF EXISTS notifications_select_own ON notifications;
CREATE POLICY notifications_select_own ON notifications FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS notifications_update_own ON notifications;
CREATE POLICY notifications_update_own ON notifications FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS notifications_insert_system ON notifications;
CREATE POLICY notifications_insert_system ON notifications FOR INSERT WITH CHECK (TRUE);

-- ── Notification Functions & Triggers ────────────────────────────
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id TEXT, p_type TEXT, p_title TEXT, p_body TEXT DEFAULT NULL,
  p_reference_id TEXT DEFAULT NULL, p_reference_type TEXT DEFAULT NULL
)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_id TEXT;
BEGIN
  INSERT INTO notifications (user_id, type, title, body, reference_id, reference_type)
  VALUES (p_user_id, p_type, p_title, p_body, p_reference_id, p_reference_type)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- Notify community approval
CREATE OR REPLACE FUNCTION notify_community_approved()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.requester_id, 'community_approved', 'Community Approved',
      'Your community "' || NEW.community_name || '" has been approved!', NEW.id, 'community_request');
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS community_approved_notification ON community_requests;
CREATE TRIGGER community_approved_notification
  AFTER UPDATE ON community_requests FOR EACH ROW
  WHEN (NEW.status = 'approved' AND OLD.status = 'pending')
  EXECUTE FUNCTION notify_community_approved();

-- Notify verification review
CREATE OR REPLACE FUNCTION notify_verification_reviewed()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.user_id, 'verification_approved', 'Verification Approved',
      'Your leadership verification has been approved!', NEW.id, 'verification_request');
  ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.user_id, 'verification_rejected', 'Verification Rejected',
      COALESCE('Your verification was rejected: ' || NEW.admin_notes, 'Your verification was rejected.'), NEW.id, 'verification_request');
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS verification_reviewed_notification ON verification_requests;
CREATE TRIGGER verification_reviewed_notification
  AFTER UPDATE ON verification_requests FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected'))
  EXECUTE FUNCTION notify_verification_reviewed();

-- Notify new post
CREATE OR REPLACE FUNCTION notify_new_post()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_community_name TEXT;
BEGIN
  SELECT name INTO v_community_name FROM communities WHERE id = NEW.community_id;
  PERFORM create_notification(
    cm.user_id, 'announcement_posted', 'New post in ' || v_community_name,
    NEW.title, NEW.id, 'community_post')
  FROM community_members cm
  WHERE cm.community_id = NEW.community_id AND cm.user_id != NEW.author_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS new_post_notification ON community_posts;
CREATE TRIGGER new_post_notification
  AFTER INSERT ON community_posts FOR EACH ROW
  EXECUTE FUNCTION notify_new_post();

-- Notify admin of new request
CREATE OR REPLACE FUNCTION notify_admin_new_request()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO notifications (user_id, type, title, body, reference_id, reference_type)
  SELECT p.id, 'admin_request', 'New ' || TG_ARGV[0] || ' Request',
    'A new request requires your review', NEW.id, TG_ARGV[0]
  FROM profiles p WHERE p.role IN ('admin', 'superadmin');
  RETURN NEW;
END;
$$;

-- Auto-count: community member count
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE communities SET member_count = member_count + 1 WHERE id = NEW.community_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = OLD.community_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS community_members_count_trigger ON community_members;
CREATE TRIGGER community_members_count_trigger
  AFTER INSERT OR DELETE ON community_members FOR EACH ROW
  EXECUTE FUNCTION update_community_member_count();

-- ── RPC Functions ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION increment_discussion_view(p_discussion_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE discussions SET view_count = view_count + 1 WHERE id = p_discussion_id;
END;
$$;

CREATE OR REPLACE FUNCTION increment_resource_download(p_resource_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE community_resources SET download_count = download_count + 1 WHERE id = p_resource_id;
END;
$$;

COMMIT;
