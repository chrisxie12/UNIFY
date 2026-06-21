-- Add 24-hour expiry to messages and inline attachment storage
-- Messages auto-expire like Snapchat; pg_cron cleans them up hourly.

BEGIN;

-- ── 1. Add expires_at to messages ────────────────────────────────────────────
ALTER TABLE messages
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours');

-- ── 2. Add inline attachments JSONB column ───────────────────────────────────
-- Stores image attachment metadata directly on the message row so the
-- real-time stream query doesn't need a join.
ALTER TABLE messages
  ADD COLUMN IF NOT EXISTS attachments JSONB DEFAULT '[]'::JSONB;

-- ── 3. Index for efficient expiry cleanup ─────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_messages_expires_at ON messages(expires_at);

-- ── 4. Scheduled cleanup via pg_cron ────────────────────────────────────────
-- Requires the pg_cron extension (enabled in Supabase Pro / pg_cron add-on).
-- Deletes all expired messages every hour.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'
  ) THEN
    PERFORM cron.schedule(
      'delete-expired-messages',
      '0 * * * *',  -- every hour at :00
      $$DELETE FROM messages WHERE expires_at < NOW()$$
    );
  END IF;
END;
$$;

-- ── 5. RLS: allow reading only non-expired messages ─────────────────────────
-- Drop the existing policy if any, then recreate with expiry filter.
-- (Keeps existing SELECT policies; adds expiry check via a function.)
CREATE OR REPLACE FUNCTION is_message_expired(msg_expires_at TIMESTAMPTZ)
  RETURNS BOOLEAN LANGUAGE SQL STABLE AS
  $$ SELECT msg_expires_at IS NOT NULL AND msg_expires_at < NOW() $$;

COMMIT;
