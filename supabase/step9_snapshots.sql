-- ============================================================
-- STEP 9 — Campus Snapshots (24-hour disappearing stories)
-- ============================================================
-- Personal / Community / Verified-Leader snapshots with photo,
-- text, poll and question types. Views, reactions, replies,
-- poll votes, reports and author mutes. Auto-expire after 24h.
-- ============================================================

-- ── Snapshots ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS snapshots (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id        UUID        NOT NULL REFERENCES profiles(id)    ON DELETE CASCADE,
  community_id     UUID                 REFERENCES communities(id) ON DELETE CASCADE,
  type             TEXT        NOT NULL CHECK (type IN ('photo','video','text','poll','question')),
  media_url        TEXT,
  caption          TEXT,
  text_content     TEXT,
  background_color TEXT,                              -- e.g. '#1E40AF'
  audience         TEXT        NOT NULL DEFAULT 'public'
                     CHECK (audience IN ('public','friends','community')),
  is_official      BOOLEAN     NOT NULL DEFAULT false, -- verified-leader story
  view_count       INTEGER     NOT NULL DEFAULT 0,
  reaction_count   INTEGER     NOT NULL DEFAULT 0,
  reply_count      INTEGER     NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at       TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '24 hours')
);

CREATE INDEX IF NOT EXISTS idx_snapshots_active        ON snapshots (expires_at, created_at);
CREATE INDEX IF NOT EXISTS idx_snapshots_author        ON snapshots (author_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_community     ON snapshots (community_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_official      ON snapshots (is_official);

-- ── Poll options & votes ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS snapshot_poll_options (
  id           UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id  UUID    NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  label        TEXT    NOT NULL,
  position     INTEGER NOT NULL DEFAULT 0,
  vote_count   INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_poll_options_snapshot ON snapshot_poll_options (snapshot_id);

CREATE TABLE IF NOT EXISTS snapshot_poll_votes (
  snapshot_id  UUID        NOT NULL REFERENCES snapshots(id)            ON DELETE CASCADE,
  option_id    UUID        NOT NULL REFERENCES snapshot_poll_options(id) ON DELETE CASCADE,
  user_id      UUID        NOT NULL REFERENCES profiles(id)             ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (snapshot_id, user_id)            -- one vote per snapshot
);

-- ── Views (read receipts / analytics) ─────────────────────────

CREATE TABLE IF NOT EXISTS snapshot_views (
  snapshot_id  UUID        NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  viewer_id    UUID        NOT NULL REFERENCES profiles(id)  ON DELETE CASCADE,
  viewed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (snapshot_id, viewer_id)
);

-- ── Reactions (one per user per snapshot) ─────────────────────

CREATE TABLE IF NOT EXISTS snapshot_reactions (
  snapshot_id  UUID        NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  user_id      UUID        NOT NULL REFERENCES profiles(id)  ON DELETE CASCADE,
  emoji        TEXT        NOT NULL,                 -- 👍 🔥 😂 👏 ❤️ 🎉
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (snapshot_id, user_id)
);

-- ── Replies (private — become a DM to the author) ─────────────

CREATE TABLE IF NOT EXISTS snapshot_replies (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id  UUID        NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  sender_id    UUID        NOT NULL REFERENCES profiles(id)  ON DELETE CASCADE,
  recipient_id UUID        NOT NULL REFERENCES profiles(id)  ON DELETE CASCADE,
  body         TEXT        NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_snapshot_replies_snapshot ON snapshot_replies (snapshot_id);

-- ── Safety: reports & author mutes ────────────────────────────

CREATE TABLE IF NOT EXISTS snapshot_reports (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id  UUID        NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  reporter_id  UUID        NOT NULL REFERENCES profiles(id)  ON DELETE CASCADE,
  reason       TEXT        NOT NULL,
  status       TEXT        NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','reviewed','dismissed')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS snapshot_mutes (
  muter_id   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  muted_id   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (muter_id, muted_id)
);

-- ============================================================
-- Triggers — keep counters in sync
-- ============================================================

CREATE OR REPLACE FUNCTION bump_snapshot_view_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE snapshots SET view_count = view_count + 1 WHERE id = NEW.snapshot_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_snapshot_view_count ON snapshot_views;
CREATE TRIGGER trg_snapshot_view_count
  AFTER INSERT ON snapshot_views
  FOR EACH ROW EXECUTE FUNCTION bump_snapshot_view_count();

CREATE OR REPLACE FUNCTION sync_snapshot_reaction_count()
RETURNS TRIGGER AS $$
DECLARE
  sid UUID := COALESCE(NEW.snapshot_id, OLD.snapshot_id);
BEGIN
  UPDATE snapshots
     SET reaction_count = (SELECT count(*) FROM snapshot_reactions WHERE snapshot_id = sid)
   WHERE id = sid;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_snapshot_reaction_count ON snapshot_reactions;
CREATE TRIGGER trg_snapshot_reaction_count
  AFTER INSERT OR DELETE OR UPDATE ON snapshot_reactions
  FOR EACH ROW EXECUTE FUNCTION sync_snapshot_reaction_count();

CREATE OR REPLACE FUNCTION bump_snapshot_reply_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE snapshots SET reply_count = reply_count + 1 WHERE id = NEW.snapshot_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_snapshot_reply_count ON snapshot_replies;
CREATE TRIGGER trg_snapshot_reply_count
  AFTER INSERT ON snapshot_replies
  FOR EACH ROW EXECUTE FUNCTION bump_snapshot_reply_count();

CREATE OR REPLACE FUNCTION bump_poll_option_votes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE snapshot_poll_options SET vote_count = vote_count + 1 WHERE id = NEW.option_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_poll_option_votes ON snapshot_poll_votes;
CREATE TRIGGER trg_poll_option_votes
  AFTER INSERT ON snapshot_poll_votes
  FOR EACH ROW EXECUTE FUNCTION bump_poll_option_votes();

-- ============================================================
-- Cleanup — call from a scheduled job (pg_cron) every hour
-- ============================================================

CREATE OR REPLACE FUNCTION delete_expired_snapshots()
RETURNS void AS $$
  DELETE FROM snapshots WHERE expires_at <= now();
$$ LANGUAGE sql;

-- ============================================================
-- Row Level Security
-- ============================================================

ALTER TABLE snapshots             ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_poll_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_poll_votes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_views        ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_reactions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_replies      ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_reports      ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshot_mutes        ENABLE ROW LEVEL SECURITY;

-- snapshots
DROP POLICY IF EXISTS snapshots_select ON snapshots;
CREATE POLICY snapshots_select ON snapshots
  FOR SELECT TO authenticated
  USING (expires_at > now());

DROP POLICY IF EXISTS snapshots_insert ON snapshots;
CREATE POLICY snapshots_insert ON snapshots
  FOR INSERT TO authenticated
  WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS snapshots_delete ON snapshots;
CREATE POLICY snapshots_delete ON snapshots
  FOR DELETE TO authenticated
  USING (author_id = auth.uid());

-- poll options
DROP POLICY IF EXISTS poll_options_select ON snapshot_poll_options;
CREATE POLICY poll_options_select ON snapshot_poll_options
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS poll_options_insert ON snapshot_poll_options;
CREATE POLICY poll_options_insert ON snapshot_poll_options
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM snapshots s WHERE s.id = snapshot_id AND s.author_id = auth.uid()));

-- poll votes
DROP POLICY IF EXISTS poll_votes_select ON snapshot_poll_votes;
CREATE POLICY poll_votes_select ON snapshot_poll_votes
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS poll_votes_insert ON snapshot_poll_votes;
CREATE POLICY poll_votes_insert ON snapshot_poll_votes
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- views
DROP POLICY IF EXISTS views_insert ON snapshot_views;
CREATE POLICY views_insert ON snapshot_views
  FOR INSERT TO authenticated
  WITH CHECK (viewer_id = auth.uid());

DROP POLICY IF EXISTS views_select ON snapshot_views;
CREATE POLICY views_select ON snapshot_views
  FOR SELECT TO authenticated
  USING (
    viewer_id = auth.uid()
    OR EXISTS (SELECT 1 FROM snapshots s WHERE s.id = snapshot_id AND s.author_id = auth.uid())
  );

-- reactions
DROP POLICY IF EXISTS reactions_select ON snapshot_reactions;
CREATE POLICY reactions_select ON snapshot_reactions
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS reactions_write ON snapshot_reactions;
CREATE POLICY reactions_write ON snapshot_reactions
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- replies
DROP POLICY IF EXISTS replies_insert ON snapshot_replies;
CREATE POLICY replies_insert ON snapshot_replies
  FOR INSERT TO authenticated
  WITH CHECK (sender_id = auth.uid());

DROP POLICY IF EXISTS replies_select ON snapshot_replies;
CREATE POLICY replies_select ON snapshot_replies
  FOR SELECT TO authenticated
  USING (sender_id = auth.uid() OR recipient_id = auth.uid());

-- reports
DROP POLICY IF EXISTS reports_insert ON snapshot_reports;
CREATE POLICY reports_insert ON snapshot_reports
  FOR INSERT TO authenticated
  WITH CHECK (reporter_id = auth.uid());

-- mutes
DROP POLICY IF EXISTS mutes_write ON snapshot_mutes;
CREATE POLICY mutes_write ON snapshot_mutes
  FOR ALL TO authenticated
  USING (muter_id = auth.uid())
  WITH CHECK (muter_id = auth.uid());

-- ============================================================
-- Storage bucket for snapshot media (run once; ignore if exists)
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('snapshots', 'snapshots', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "snapshot media read" ON storage.objects;
CREATE POLICY "snapshot media read" ON storage.objects
  FOR SELECT TO public USING (bucket_id = 'snapshots');

DROP POLICY IF EXISTS "snapshot media write" ON storage.objects;
CREATE POLICY "snapshot media write" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'snapshots');
