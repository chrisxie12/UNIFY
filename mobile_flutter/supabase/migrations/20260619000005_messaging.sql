-- UNIFY Messaging & Campus Chat System
-- All FKs reference profiles(id) — users(id) does not exist in public schema.

BEGIN;

-- ── Conversations ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('direct', 'group', 'channel', 'study_group', 'announcement')),
  title TEXT,
  avatar_url TEXT,
  community_id UUID REFERENCES communities(id) ON DELETE CASCADE,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  is_verified BOOLEAN DEFAULT FALSE,
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('member', 'admin', 'moderator', 'announcer')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  last_read_at TIMESTAMPTZ DEFAULT NOW(),
  is_muted BOOLEAN DEFAULT FALSE,
  UNIQUE(conversation_id, user_id)
);

-- ── Channels (Discord-style, within a conversation) ────────────
CREATE TABLE IF NOT EXISTS channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'announcement', 'voice')),
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  position INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Messages ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  channel_id UUID REFERENCES channels(id) ON DELETE SET NULL,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT,
  reply_to UUID REFERENCES messages(id) ON DELETE SET NULL,
  forwarded_from UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_system_message BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Attachments ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('image', 'video', 'audio', 'document', 'voice_note')),
  url TEXT NOT NULL,
  name TEXT,
  size BIGINT,
  mime_type TEXT,
  width INTEGER,
  height INTEGER,
  duration INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Reactions ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reaction TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(message_id, user_id, reaction)
);

-- ── Message Requests (for DMs between non-connected users) ──────
CREATE TABLE IF NOT EXISTS message_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  to_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
  preview_content TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Chat Polls ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_polls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  is_multiple_choice BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_poll_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id UUID NOT NULL REFERENCES chat_polls(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  option_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(poll_id, user_id, option_index)
);

-- ── Read Receipts ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS message_read_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, message_id)
);

-- ── Mentions ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mentions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  mention_type TEXT CHECK (mention_type IN ('user', 'role', 'everyone', 'moderators')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Blocks ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS blocked_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id)
);

-- ── Indexes ──────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_channel ON messages(channel_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_user ON conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_conv ON conversation_participants(conversation_id);
CREATE INDEX IF NOT EXISTS idx_channels_conv ON channels(conversation_id, position);
CREATE INDEX IF NOT EXISTS idx_message_reactions_message ON message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_mentions_user ON mentions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_message_requests_to ON message_requests(to_user_id, status);
CREATE INDEX IF NOT EXISTS idx_read_receipts_user_conv ON message_read_receipts(user_id, conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_pinned ON messages(conversation_id) WHERE is_pinned = TRUE;

-- ── RLS ──────────────────────────────────────────────────────────
ALTER TABLE conversations             ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_attachments       ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reactions         ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_requests          ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_polls                ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_poll_votes           ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_read_receipts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentions                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users             ENABLE ROW LEVEL SECURITY;

-- Conversations: participant can view
DROP POLICY IF EXISTS conversations_select ON conversations;
CREATE POLICY conversations_select ON conversations FOR SELECT
  USING (EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = id AND user_id = auth.uid()));

DROP POLICY IF EXISTS conversations_insert ON conversations;
CREATE POLICY conversations_insert ON conversations FOR INSERT
  WITH CHECK (TRUE);

-- Messages: participant can view
DROP POLICY IF EXISTS messages_select ON messages;
CREATE POLICY messages_select ON messages FOR SELECT
  USING (EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()));

DROP POLICY IF EXISTS messages_insert ON messages;
CREATE POLICY messages_insert ON messages FOR INSERT
  WITH CHECK (sender_id = auth.uid() AND EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()));

DROP POLICY IF EXISTS messages_update ON messages;
CREATE POLICY messages_update ON messages FOR UPDATE
  USING (sender_id = auth.uid())
  WITH CHECK (sender_id = auth.uid());

-- Channels: participant of parent conversation can view
DROP POLICY IF EXISTS channels_select ON channels;
CREATE POLICY channels_select ON channels FOR SELECT
  USING (EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = channels.conversation_id AND user_id = auth.uid()));

-- Reactions: participant can manage own
DROP POLICY IF EXISTS reactions_select ON message_reactions;
CREATE POLICY reactions_select ON message_reactions FOR SELECT
  USING (EXISTS (SELECT 1 FROM conversation_participants cp JOIN messages m ON m.conversation_id = cp.conversation_id WHERE m.id = message_reactions.message_id AND cp.user_id = auth.uid()));

DROP POLICY IF EXISTS reactions_insert ON message_reactions;
CREATE POLICY reactions_insert ON message_reactions FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS reactions_delete ON message_reactions;
CREATE POLICY reactions_delete ON message_reactions FOR DELETE
  USING (user_id = auth.uid());

-- Message requests: sender/recipient can see
DROP POLICY IF EXISTS requests_select ON message_requests;
CREATE POLICY requests_select ON message_requests FOR SELECT
  USING (to_user_id = auth.uid() OR from_user_id = auth.uid());

DROP POLICY IF EXISTS requests_insert ON message_requests;
CREATE POLICY requests_insert ON message_requests FOR INSERT
  WITH CHECK (from_user_id = auth.uid());

DROP POLICY IF EXISTS requests_update ON message_requests;
CREATE POLICY requests_update ON message_requests FOR UPDATE
  USING (to_user_id = auth.uid())
  WITH CHECK (to_user_id = auth.uid());

-- Mentions: mentioned user can see
DROP POLICY IF EXISTS mentions_select ON mentions;
CREATE POLICY mentions_select ON mentions FOR SELECT
  USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM conversation_participants cp JOIN messages m ON m.conversation_id = cp.conversation_id WHERE m.id = mentions.message_id AND cp.user_id = auth.uid()));

-- Blocks: user can manage their blocks
DROP POLICY IF EXISTS blocks_select ON blocked_users;
CREATE POLICY blocks_select ON blocked_users FOR SELECT
  USING (blocker_id = auth.uid());

DROP POLICY IF EXISTS blocks_insert ON blocked_users;
CREATE POLICY blocks_insert ON blocked_users FOR INSERT
  WITH CHECK (blocker_id = auth.uid());

DROP POLICY IF EXISTS blocks_delete ON blocked_users FOR DELETE
  USING (blocker_id = auth.uid());

-- Read receipts: user can manage own
DROP POLICY IF EXISTS read_receipts_select ON message_read_receipts;
CREATE POLICY read_receipts_select ON message_read_receipts FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS read_receipts_insert ON message_read_receipts;
CREATE POLICY read_receipts_insert ON message_read_receipts FOR INSERT
  WITH CHECK (user_id = auth.uid());

COMMIT;
