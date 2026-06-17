-- ============================================================
-- STEP 8 — Community Events, Polls & Post Bookmarks
-- ============================================================

-- ── Events ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS community_events (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id  UUID        NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  creator_id    UUID        NOT NULL REFERENCES profiles(id)    ON DELETE CASCADE,
  title         TEXT        NOT NULL,
  description   TEXT,
  location      TEXT,
  event_date    DATE        NOT NULL,
  event_time    TEXT,          -- e.g. '14:00', stored as text for simplicity
  rsvp_count    INTEGER     NOT NULL DEFAULT 0,
  is_cancelled  BOOLEAN     NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS event_rsvps (
  event_id    UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  status      TEXT        NOT NULL DEFAULT 'going',   -- going | maybe
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (event_id, user_id)
);

-- ── Polls ─────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS community_polls (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id  UUID        NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  creator_id    UUID        NOT NULL REFERENCES profiles(id)    ON DELETE CASCADE,
  question      TEXT        NOT NULL,
  is_active     BOOLEAN     NOT NULL DEFAULT true,
  expires_at    TIMESTAMPTZ,
  total_votes   INTEGER     NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS poll_options (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id        UUID    NOT NULL REFERENCES community_polls(id) ON DELETE CASCADE,
  option_text    TEXT    NOT NULL,
  vote_count     INTEGER NOT NULL DEFAULT 0,
  display_order  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS poll_votes (
  poll_id     UUID        NOT NULL REFERENCES community_polls(id)  ON DELETE CASCADE,
  option_id   UUID        NOT NULL REFERENCES poll_options(id)     ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (poll_id, user_id)
);

-- ── Post bookmarks ────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS post_bookmarks (
  user_id     UUID        NOT NULL REFERENCES profiles(id)          ON DELETE CASCADE,
  post_id     UUID        NOT NULL REFERENCES community_posts(id)   ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);

-- ── RLS ───────────────────────────────────────────────────────

ALTER TABLE community_events  ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_rsvps       ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_polls   ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_options      ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_votes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_bookmarks    ENABLE ROW LEVEL SECURITY;

-- Events: any authenticated user can read; members can insert
CREATE POLICY "events_select" ON community_events FOR SELECT TO authenticated USING (true);
CREATE POLICY "events_insert" ON community_events FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM community_members
      WHERE community_id = community_events.community_id
        AND user_id = auth.uid()
        AND role IN ('owner', 'moderator')
    )
  );
CREATE POLICY "events_update" ON community_events FOR UPDATE TO authenticated
  USING (creator_id = auth.uid());
CREATE POLICY "events_delete" ON community_events FOR DELETE TO authenticated
  USING (creator_id = auth.uid());

-- RSVPs: members can manage their own
CREATE POLICY "rsvps_select" ON event_rsvps FOR SELECT TO authenticated USING (true);
CREATE POLICY "rsvps_insert" ON event_rsvps FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "rsvps_delete" ON event_rsvps FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- Polls: any authenticated user can read; members can create
CREATE POLICY "polls_select"   ON community_polls FOR SELECT TO authenticated USING (true);
CREATE POLICY "options_select" ON poll_options    FOR SELECT TO authenticated USING (true);
CREATE POLICY "votes_select"   ON poll_votes      FOR SELECT TO authenticated USING (true);

CREATE POLICY "polls_insert" ON community_polls FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM community_members
      WHERE community_id = community_polls.community_id
        AND user_id = auth.uid()
        AND role IN ('owner', 'moderator')
    )
  );
CREATE POLICY "options_insert" ON poll_options FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "votes_insert"   ON poll_votes   FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "votes_delete"   ON poll_votes   FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- Bookmarks: private per user
CREATE POLICY "bookmarks_select" ON post_bookmarks FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY "bookmarks_insert" ON post_bookmarks FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "bookmarks_delete" ON post_bookmarks FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- ── Triggers ─────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_event_rsvp_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_events SET rsvp_count = rsvp_count + 1 WHERE id = NEW.event_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_events SET rsvp_count = GREATEST(rsvp_count - 1, 0) WHERE id = OLD.event_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_event_rsvp_count ON event_rsvps;
CREATE TRIGGER trg_event_rsvp_count
  AFTER INSERT OR DELETE ON event_rsvps
  FOR EACH ROW EXECUTE FUNCTION update_event_rsvp_count();

CREATE OR REPLACE FUNCTION update_poll_vote_counts()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE poll_options  SET vote_count  = vote_count  + 1 WHERE id = NEW.option_id;
    UPDATE community_polls SET total_votes = total_votes + 1 WHERE id = NEW.poll_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE poll_options  SET vote_count  = GREATEST(vote_count  - 1, 0) WHERE id = OLD.option_id;
    UPDATE community_polls SET total_votes = GREATEST(total_votes - 1, 0) WHERE id = OLD.poll_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_poll_vote_counts ON poll_votes;
CREATE TRIGGER trg_poll_vote_counts
  AFTER INSERT OR DELETE ON poll_votes
  FOR EACH ROW EXECUTE FUNCTION update_poll_vote_counts();

-- ── Indexes ───────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_events_community  ON community_events (community_id, event_date);
CREATE INDEX IF NOT EXISTS idx_rsvps_event       ON event_rsvps      (event_id);
CREATE INDEX IF NOT EXISTS idx_rsvps_user        ON event_rsvps      (user_id);
CREATE INDEX IF NOT EXISTS idx_polls_community   ON community_polls  (community_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_options_poll      ON poll_options     (poll_id, display_order);
CREATE INDEX IF NOT EXISTS idx_votes_poll        ON poll_votes       (poll_id);
CREATE INDEX IF NOT EXISTS idx_votes_user        ON poll_votes       (user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user    ON post_bookmarks   (user_id, created_at DESC);
