-- UNIFY Beta Readiness Fixes
-- Addresses 5 critical blockers from Beta Readiness Audit.
-- Applied via: supabase migration up (or SQL Editor in order)

BEGIN;

-- ═══════════════════════════════════════════════════════════════════
-- FIX 1: Profiles RLS — allow public and university-scoped reads
-- ═══════════════════════════════════════════════════════════════════

-- Add privacy_level column if not present
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS privacy_level TEXT NOT NULL DEFAULT 'public'
  CHECK (privacy_level IN ('public', 'university', 'friends'));

-- Drop and recreate profiles_own_read to allow scoped cross-user reads
DROP POLICY IF EXISTS profiles_own_read ON profiles;
CREATE POLICY profiles_own_read ON profiles FOR SELECT
  USING (
    auth.uid() = id
    OR privacy_level = 'public'
    OR (privacy_level = 'university'
        AND university_id = (SELECT p.university_id FROM profiles p WHERE p.id = auth.uid())
       )
  );

-- ═══════════════════════════════════════════════════════════════════
-- FIX 2: conversation_participants RLS — add missing policies
-- ═══════════════════════════════════════════════════════════════════

-- SELECT: participant can see their own rows (required for conversations() streaming)
DROP POLICY IF EXISTS conversation_participants_select ON conversation_participants;
CREATE POLICY conversation_participants_select ON conversation_participants FOR SELECT
  USING (user_id = auth.uid());

-- INSERT: participant can join if they are the inserted user
DROP POLICY IF EXISTS conversation_participants_insert ON conversation_participants;
CREATE POLICY conversation_participants_insert ON conversation_participants FOR INSERT
  WITH CHECK (
    -- Self-insert OR creator of parent conversation can add others
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = conversation_id
        AND c.created_by = auth.uid()
    )
  );

-- UPDATE: participant can update own row (mute, typing, role, last_read_at)
--         Conversation creator can update others' roles
DROP POLICY IF EXISTS conversation_participants_update ON conversation_participants;
CREATE POLICY conversation_participants_update ON conversation_participants FOR UPDATE
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = conversation_id
        AND c.created_by = auth.uid()
    )
  );

-- DELETE: participant can remove self; conversation creator can remove others
DROP POLICY IF EXISTS conversation_participants_delete ON conversation_participants;
CREATE POLICY conversation_participants_delete ON conversation_participants FOR DELETE
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = conversation_id
        AND c.created_by = auth.uid()
    )
  );

-- ═══════════════════════════════════════════════════════════════════
-- FIX 3: conversation_participants — add is_typing and muted_until
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS is_typing BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS muted_until TIMESTAMPTZ;

-- ═══════════════════════════════════════════════════════════════════
-- FIX 4: Add missing indexes for beta performance
-- ═══════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_conversation_participants_typing
  ON conversation_participants(conversation_id, is_typing)
  WHERE is_typing = TRUE;

CREATE INDEX IF NOT EXISTS idx_profiles_privacy_level
  ON profiles(privacy_level, university_id)
  WHERE privacy_level IN ('public', 'university');

-- ═══════════════════════════════════════════════════════════════════
-- FIX 5: Also ensure unread RPC function has proper fallback
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_unread_count(p_user_id UUID)
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM messages m
  WHERE m.conversation_id IN (
    SELECT cp.conversation_id FROM conversation_participants cp WHERE cp.user_id = p_user_id
  )
  AND m.created_at > COALESCE(
    (SELECT cp.last_read_at FROM conversation_participants cp
     WHERE cp.user_id = p_user_id AND cp.conversation_id = m.conversation_id),
    '1970-01-01'
  )
  AND m.sender_id != p_user_id;
  RETURN v_count;
END; $$;

COMMIT;
