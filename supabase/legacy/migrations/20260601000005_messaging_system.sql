-- ============================================================
-- UNIFY — Step 5: Messaging system
-- Creates conversations, channels, messages, and related tables.
-- All user FKs reference auth.users(id) (Supabase convention).
-- ============================================================

BEGIN;

-- ─── Conversations ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS conversations (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type           TEXT NOT NULL CHECK (type IN ('direct', 'group', 'channel', 'study_group', 'announcement')),
  title          TEXT,
  avatar_url     TEXT,
  community_id   UUID REFERENCES communities(id) ON DELETE CASCADE,
  created_by     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  is_verified    BOOLEAN DEFAULT FALSE,
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Conversation participants ────────────────────────────────
CREATE TABLE IF NOT EXISTS conversation_participants (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role            TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  is_muted        BOOLEAN DEFAULT FALSE,
  is_typing       BOOLEAN DEFAULT FALSE,
  last_read_at    TIMESTAMPTZ,
  joined_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

-- ─── Channels ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS channels (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT,
  type            TEXT DEFAULT 'text' CHECK (type IN ('text', 'voice', 'announcement')),
  position        INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Messages ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  channel_id      UUID REFERENCES channels(id) ON DELETE CASCADE,
  sender_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content         TEXT,
  reply_to_id     UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_pinned       BOOLEAN DEFAULT FALSE,
  edited_at       TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Message attachments ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_attachments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id  UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN ('image', 'video', 'audio', 'file', 'gif', 'sticker')),
  url         TEXT NOT NULL,
  file_name   TEXT,
  file_size   BIGINT,
  mime_type   TEXT,
  width       INTEGER,
  height      INTEGER,
  duration    INTEGER,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Message reactions ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_reactions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id  UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reaction    TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(message_id, user_id, reaction)
);

-- ─── Message requests ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  to_user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  preview_content TEXT,
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(from_user_id, to_user_id)
);

-- Add preview_content to existing table if it was created without it
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'message_requests'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'message_requests' AND column_name = 'preview_content'
  ) THEN
    ALTER TABLE message_requests ADD COLUMN preview_content TEXT;
  END IF;
END $$;

-- ─── Chat polls ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_polls (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id        UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  question          TEXT NOT NULL,
  options           JSONB NOT NULL,
  is_multiple_choice BOOLEAN DEFAULT FALSE,
  expires_at        TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_poll_votes (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id      UUID NOT NULL REFERENCES chat_polls(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  option_index INTEGER NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(poll_id, user_id, option_index)
);

-- ─── Read receipts ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_read_receipts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message_id      UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  read_at         TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, message_id)
);

-- ─── Mentions ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mentions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id   UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  mention_type TEXT CHECK (mention_type IN ('user', 'role', 'everyone', 'moderators')),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Blocked users ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS blocked_users (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id)
);

-- ─── Indexes ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_channel ON messages(channel_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conv_participants_user ON conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_conv_participants_conv ON conversation_participants(conversation_id);
CREATE INDEX IF NOT EXISTS idx_channels_conv ON channels(conversation_id, position);
CREATE INDEX IF NOT EXISTS idx_message_reactions_msg ON message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_mentions_user ON mentions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_message_requests_to ON message_requests(to_user_id, status);
CREATE INDEX IF NOT EXISTS idx_read_receipts_user_conv ON message_read_receipts(user_id, conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);

-- ─── RLS ─────────────────────────────────────────────────────
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_read_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentions ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;

-- Conversations: participants only
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'conversations' AND policyname = 'conversations_select') THEN
    CREATE POLICY conversations_select ON conversations FOR SELECT
      USING (EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'conversations' AND policyname = 'conversations_insert') THEN
    CREATE POLICY conversations_insert ON conversations FOR INSERT WITH CHECK (true);
  END IF;
END $$;

-- Messages: conversation participants
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'messages_select') THEN
    CREATE POLICY messages_select ON messages FOR SELECT
      USING (EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'messages_insert') THEN
    CREATE POLICY messages_insert ON messages FOR INSERT
      WITH CHECK (sender_id = auth.uid() AND EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'messages_update') THEN
    CREATE POLICY messages_update ON messages FOR UPDATE
      USING (sender_id = auth.uid()) WITH CHECK (sender_id = auth.uid());
  END IF;
END $$;

-- Channels: participants of parent conversation
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'channels' AND policyname = 'channels_select') THEN
    CREATE POLICY channels_select ON channels FOR SELECT
      USING (EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = channels.conversation_id AND user_id = auth.uid()));
  END IF;
END $$;

-- Message requests: sender or recipient
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'message_requests' AND policyname = 'requests_select') THEN
    CREATE POLICY requests_select ON message_requests FOR SELECT
      USING (to_user_id = auth.uid() OR from_user_id = auth.uid());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'message_requests' AND policyname = 'requests_insert') THEN
    CREATE POLICY requests_insert ON message_requests FOR INSERT
      WITH CHECK (from_user_id = auth.uid());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'message_requests' AND policyname = 'requests_update') THEN
    CREATE POLICY requests_update ON message_requests FOR UPDATE
      USING (to_user_id = auth.uid()) WITH CHECK (to_user_id = auth.uid());
  END IF;
END $$;

-- Reactions: participants
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'message_reactions' AND policyname = 'reactions_select') THEN
    CREATE POLICY reactions_select ON message_reactions FOR SELECT
      USING (EXISTS (
        SELECT 1 FROM conversation_participants cp
        JOIN messages m ON m.conversation_id = cp.conversation_id
        WHERE m.id = message_reactions.message_id AND cp.user_id = auth.uid()
      ));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'message_reactions' AND policyname = 'reactions_insert') THEN
    CREATE POLICY reactions_insert ON message_reactions FOR INSERT WITH CHECK (user_id = auth.uid());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'message_reactions' AND policyname = 'reactions_delete') THEN
    CREATE POLICY reactions_delete ON message_reactions FOR DELETE USING (user_id = auth.uid());
  END IF;
END $$;

-- Blocked users: own blocks
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'blocked_users' AND policyname = 'blocks_select') THEN
    CREATE POLICY blocks_select ON blocked_users FOR SELECT USING (blocker_id = auth.uid());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'blocked_users' AND policyname = 'blocks_insert') THEN
    CREATE POLICY blocks_insert ON blocked_users FOR INSERT WITH CHECK (blocker_id = auth.uid());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'blocked_users' AND policyname = 'blocks_delete') THEN
    CREATE POLICY blocks_delete ON blocked_users FOR DELETE USING (blocker_id = auth.uid());
  END IF;
END $$;

-- ─── Unread count helper ─────────────────────────────────────
CREATE OR REPLACE FUNCTION get_unread_count(p_user_id UUID)
RETURNS INTEGER LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT COUNT(*)::INTEGER
  FROM messages m
  JOIN conversation_participants cp
    ON cp.conversation_id = m.conversation_id AND cp.user_id = p_user_id
  WHERE m.created_at > COALESCE(cp.last_read_at, '1970-01-01'::TIMESTAMPTZ)
    AND m.sender_id <> p_user_id;
$$;

-- Notify PostgREST to reload schema cache
NOTIFY pgrst, 'reload schema';

COMMIT;
