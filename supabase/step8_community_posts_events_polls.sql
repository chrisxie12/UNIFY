-- ============================================================
-- UNIFY - STEP 8: Community Posts, Events, Polls, Bookmarks
-- ============================================================

BEGIN;

-- ============================================================
-- 1. COMMUNITY POSTS (extending discussions)
-- ============================================================
CREATE TABLE IF NOT EXISTS community_posts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  author_id       UUID NOT NULL REFERENCES profiles(id),
  title           TEXT,
  body            TEXT NOT NULL,
  post_type       TEXT NOT NULL DEFAULT 'text' CHECK (post_type IN (
                    'text', 'image', 'link', 'video', 'pdf', 'poll', 'question'
                  )),
  media_url       TEXT,
  link_url        TEXT,
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  is_announcement BOOLEAN NOT NULL DEFAULT FALSE,
  likes_count     INTEGER NOT NULL DEFAULT 0,
  comments_count  INTEGER NOT NULL DEFAULT 0,
  shares_count    INTEGER NOT NULL DEFAULT 0,
  bookmarks_count INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_posts_community ON community_posts(community_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_pinned   ON community_posts(community_id, is_pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_author   ON community_posts(author_id);

-- Post comments (nested replies)
CREATE TABLE IF NOT EXISTS post_comments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id         UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  parent_id       UUID REFERENCES post_comments(id) ON DELETE CASCADE,
  author_id       UUID NOT NULL REFERENCES profiles(id),
  body            TEXT NOT NULL,
  likes_count     INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_post_comments_post   ON post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_parent ON post_comments(parent_id);

-- Post likes
CREATE TABLE IF NOT EXISTS post_likes (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id   UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, user_id)
);

-- Post bookmarks
CREATE TABLE IF NOT EXISTS post_bookmarks (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id   UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, user_id)
);

-- Comment likes
CREATE TABLE IF NOT EXISTS comment_likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES post_comments(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);

-- ============================================================
-- 2. EVENTS
-- ============================================================
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
  event_type      TEXT NOT NULL DEFAULT 'class' CHECK (event_type IN (
                    'class', 'study_session', 'workshop', 'hackathon',
                    'orientation', 'meeting', 'social', 'other'
                  )),
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

-- ============================================================
-- 3. POLLS
-- ============================================================
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

-- Poll options
CREATE TABLE IF NOT EXISTS poll_options (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id   UUID NOT NULL REFERENCES community_polls(id) ON DELETE CASCADE,
  label     TEXT NOT NULL,
  vote_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Poll votes
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

-- ============================================================
-- 4. AUTO-COUNT TRIGGERS
-- ============================================================

-- Post likes count
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS post_likes_count_trigger ON post_likes;
CREATE TRIGGER post_likes_count_trigger
  AFTER INSERT OR DELETE ON post_likes FOR EACH ROW
  EXECUTE FUNCTION update_post_likes_count();

-- Post comments count
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

-- Event RSVP count
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

-- Poll vote count
CREATE OR REPLACE FUNCTION update_poll_vote_counts()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE poll_options SET vote_count = vote_count + 1 WHERE id = NEW.option_id;
    UPDATE community_polls SET total_votes = total_votes + 1 WHERE id = NEW.poll_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE poll_options SET vote_count = GREATEST(vote_count - 1, 0) WHERE id = OLD.option_id;
    UPDATE community_polls SET total_votes = GREATEST(total_votes - 1, 0) WHERE id = OLD.poll_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS poll_vote_count_trigger ON poll_votes;
CREATE TRIGGER poll_vote_count_trigger
  AFTER INSERT OR DELETE ON poll_votes FOR EACH ROW
  EXECUTE FUNCTION update_poll_vote_counts();

-- ============================================================
-- 5. RLS POLICIES
-- ============================================================

ALTER TABLE community_posts  ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_bookmarks   ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes    ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_rsvps      ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_polls  ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_options     ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_votes       ENABLE ROW LEVEL SECURITY;

-- Community posts: members read, members insert, own update/delete
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
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_posts.community_id AND user_id = auth.uid() AND role IN ('owner', 'manager', 'moderator') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Post comments: members read/insert, own delete
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

-- Post likes: self-manage
DROP POLICY IF EXISTS post_likes_manage ON post_likes;
CREATE POLICY post_likes_manage ON post_likes FOR ALL USING (auth.uid() = user_id);

-- Post bookmarks: self-manage
DROP POLICY IF EXISTS post_bookmarks_manage ON post_bookmarks;
CREATE POLICY post_bookmarks_manage ON post_bookmarks FOR ALL USING (auth.uid() = user_id);

-- Comment likes: self-manage
DROP POLICY IF EXISTS comment_likes_manage ON comment_likes;
CREATE POLICY comment_likes_manage ON comment_likes FOR ALL USING (auth.uid() = user_id);

-- Events: members read, reps create, own update/delete
DROP POLICY IF EXISTS events_read ON community_events;
CREATE POLICY events_read ON community_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_events.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS events_insert ON community_events;
CREATE POLICY events_insert ON community_events FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
  AND (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
    OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = NEW.community_id AND user_id = auth.uid() AND is_active = TRUE)
  )
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
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_events.community_id AND user_id = auth.uid() AND role IN ('owner', 'manager') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Event RSVPs: self-manage
DROP POLICY IF EXISTS event_rsvps_manage ON event_rsvps;
CREATE POLICY event_rsvps_manage ON event_rsvps FOR ALL USING (auth.uid() = user_id);

-- Polls: members read, reps create
DROP POLICY IF EXISTS polls_read ON community_polls;
CREATE POLICY polls_read ON community_polls FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_polls.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS polls_insert ON community_polls;
CREATE POLICY polls_insert ON community_polls FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
  AND (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
    OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = NEW.community_id AND user_id = auth.uid() AND is_active = TRUE)
  )
);

DROP POLICY IF EXISTS polls_update ON community_polls;
CREATE POLICY polls_update ON community_polls FOR UPDATE USING (
  creator_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_polls.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Poll options: public read on visible polls
DROP POLICY IF EXISTS poll_options_read ON poll_options;
CREATE POLICY poll_options_read ON poll_options FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_polls p JOIN community_members cm ON p.community_id = cm.community_id WHERE p.id = poll_options.poll_id AND cm.user_id = auth.uid())
);

-- Poll votes: self-manage
DROP POLICY IF EXISTS poll_votes_manage ON poll_votes;
CREATE POLICY poll_votes_manage ON poll_votes FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- 6. NOTIFICATION TRIGGERS FOR NEW ACTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION notify_new_post()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_community_name TEXT;
BEGIN
  SELECT name INTO v_community_name FROM communities WHERE id = NEW.community_id;
  PERFORM create_notification(
    cm.user_id, 'announcement_posted',
    'New post in ' || v_community_name,
    NEW.title, NEW.id, 'community_post'
  )
  FROM community_members cm
  WHERE cm.community_id = NEW.community_id AND cm.user_id != NEW.author_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS new_post_notification ON community_posts;
CREATE TRIGGER new_post_notification
  AFTER INSERT ON community_posts FOR EACH ROW
  EXECUTE FUNCTION notify_new_post();

COMMIT;
