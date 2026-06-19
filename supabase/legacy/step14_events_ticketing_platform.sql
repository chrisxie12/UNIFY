-- ============================================================
-- STEP 14 — Events & Ticketing Platform
-- Enhances community_events, adds tickets, check-in,
-- discussions, media gallery, reminders, certificates
-- ============================================================

-- ── 1. Enhance existing community_events ────────────────────

ALTER TABLE community_events ADD COLUMN IF NOT EXISTS category          TEXT NOT NULL DEFAULT 'community_activities';
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS end_date          DATE;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS end_time          TIME;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS capacity          INTEGER;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS registration_type TEXT NOT NULL DEFAULT 'free';
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS ticket_type       TEXT; -- general | vip | early_bird
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS contact_info      TEXT;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS scope             TEXT NOT NULL DEFAULT 'community'; -- community | faculty | university | campus
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS university        TEXT;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS faculty           TEXT;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS department        TEXT;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS organizer_type    TEXT; -- src_executive | course_rep | faculty_exec | club_leader | admin
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS attendee_count    INTEGER NOT NULL DEFAULT 0;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS is_featured       BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE community_events ADD COLUMN IF NOT EXISTS is_approved       BOOLEAN NOT NULL DEFAULT false;

-- ── 2. Event tickets (QR code check-in) ─────────────────────

CREATE TABLE IF NOT EXISTS event_tickets (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_number         TEXT        NOT NULL UNIQUE,
  event_id              UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  user_id               UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  qr_code               TEXT        NOT NULL UNIQUE,
  registration_timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  attended              BOOLEAN     NOT NULL DEFAULT false,
  checked_in_at         TIMESTAMPTZ,
  checked_in_by         UUID        REFERENCES profiles(id),
  UNIQUE (event_id, user_id)
);

-- ── 3. Event saves (bookmarks) ──────────────────────────────

CREATE TABLE IF NOT EXISTS event_saves (
  user_id   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id  UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  saved_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, event_id)
);

-- ── 4. Event discussions (Q&A / comments) ───────────────────

CREATE TABLE IF NOT EXISTS event_discussions (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id   UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  user_id    UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  content    TEXT        NOT NULL,
  parent_id  UUID        REFERENCES event_discussions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- ── 5. Event media gallery ──────────────────────────────────

CREATE TABLE IF NOT EXISTS event_media (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id    UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  uploaded_by UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  media_type  TEXT        NOT NULL, -- photo | video
  url         TEXT        NOT NULL,
  caption     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 6. Event reminders ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS event_reminders (
  id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id  UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  user_id   UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  remind_at TIMESTAMPTZ NOT NULL,
  sent      BOOLEAN     NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 7. Event certificates (future) ──────────────────────────

CREATE TABLE IF NOT EXISTS event_certificates (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id         UUID        NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  user_id          UUID        NOT NULL REFERENCES profiles(id)         ON DELETE CASCADE,
  certificate_type TEXT        NOT NULL, -- participation | workshop | training
  title            TEXT        NOT NULL,
  issued_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  certificate_url  TEXT,
  UNIQUE (event_id, user_id, certificate_type)
);

-- ── RLS: event_tickets ─────────────────────────────────────

ALTER TABLE event_tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tickets_select_own" ON event_tickets
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "tickets_select_organizer" ON event_tickets
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM community_events e
      WHERE e.id = event_tickets.event_id
        AND e.creator_id = auth.uid()
    )
  );

CREATE POLICY "tickets_insert" ON event_tickets
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "tickets_update_checkin" ON event_tickets
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM community_events e
      WHERE e.id = event_tickets.event_id
        AND e.creator_id = auth.uid()
    )
  );

-- ── RLS: event_saves ───────────────────────────────────────

ALTER TABLE event_saves ENABLE ROW LEVEL SECURITY;

CREATE POLICY "saves_select" ON event_saves
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "saves_insert" ON event_saves
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "saves_delete" ON event_saves
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- ── RLS: event_discussions ─────────────────────────────────

ALTER TABLE event_discussions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "discussions_select" ON event_discussions
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "discussions_insert" ON event_discussions
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "discussions_update" ON event_discussions
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "discussions_delete" ON event_discussions
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- ── RLS: event_media ───────────────────────────────────────

ALTER TABLE event_media ENABLE ROW LEVEL SECURITY;

CREATE POLICY "media_select" ON event_media
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "media_insert" ON event_media
  FOR INSERT TO authenticated
  WITH CHECK (uploaded_by = auth.uid());

CREATE POLICY "media_delete" ON event_media
  FOR DELETE TO authenticated
  USING (uploaded_by = auth.uid());

-- ── RLS: event_reminders ───────────────────────────────────

ALTER TABLE event_reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reminders_select" ON event_reminders
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "reminders_insert" ON event_reminders
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "reminders_delete" ON event_reminders
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- ── RLS: event_certificates ────────────────────────────────

ALTER TABLE event_certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "certificates_select" ON event_certificates
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "certificates_insert" ON event_certificates
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM community_events e
      WHERE e.id = event_certificates.event_id
        AND e.creator_id = auth.uid()
    )
  );

-- ── Indexes ────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_tickets_event ON event_tickets(event_id);
CREATE INDEX IF NOT EXISTS idx_tickets_user ON event_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_saves_user ON event_saves(user_id);
CREATE INDEX IF NOT EXISTS idx_saves_event ON event_saves(event_id);
CREATE INDEX IF NOT EXISTS idx_discussions_event ON event_discussions(event_id);
CREATE INDEX IF NOT EXISTS idx_discussions_parent ON event_discussions(parent_id);
CREATE INDEX IF NOT EXISTS idx_media_event ON event_media(event_id);
CREATE INDEX IF NOT EXISTS idx_reminders_event ON event_reminders(event_id);
CREATE INDEX IF NOT EXISTS idx_reminders_user ON event_reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_user ON event_certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON community_events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_scope ON community_events(scope);
CREATE INDEX IF NOT EXISTS idx_events_category ON community_events(category);
CREATE INDEX IF NOT EXISTS idx_events_creator ON community_events(creator_id);
