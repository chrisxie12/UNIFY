-- conversation_participants had RLS enabled but ZERO policies
-- Every SELECT/INSERT was blocked, breaking getOrCreateDirectConversation
CREATE POLICY participants_select ON conversation_participants FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY participants_insert ON conversation_participants FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY participants_update ON conversation_participants FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY participants_delete ON conversation_participants FOR DELETE
  USING (user_id = auth.uid());

-- conversations SELECT policy had a bugged subquery:
--   WHERE conversation_participants.conversation_id = conversation_participants.id
-- This compares two columns on the same row (always false).
-- Fix: use id IN (SELECT conversation_id FROM conversation_participants WHERE ...)
DROP POLICY IF EXISTS conversations_select ON conversations;
CREATE POLICY conversations_select ON conversations FOR SELECT
  USING (
    id IN (
      SELECT conversation_id FROM conversation_participants WHERE user_id = auth.uid()
    )
  );
