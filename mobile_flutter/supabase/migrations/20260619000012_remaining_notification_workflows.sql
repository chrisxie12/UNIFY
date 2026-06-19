-- ============================================================
-- UNIFY — Step 12: Remaining Notification Workflows
--
-- Implements the 3 remaining in-app notification triggers:
--
--   1. Event registration  — fires on event_tickets INSERT
--   2. New message         — fires on messages INSERT for all
--                            non-sender, non-muted participants
--                            (de-duped: one notif per conversation
--                             per recipient per 5 minutes)
--   3. Admin broadcast     — fires on admin_announcements INSERT,
--                            fans out per scope_type
--
-- Marketplace inquiry: the "Contact Seller" flow routes through the
-- general messaging screen.  The new_message trigger above covers it;
-- no dedicated marketplace_inquiry table exists to trigger from.
-- ============================================================

BEGIN;

-- ── 1. Event registration ────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION notify_event_registration()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_title TEXT;
  v_date  DATE;
BEGIN
  SELECT e.title, e.event_date
    INTO v_title, v_date
    FROM community_events e
   WHERE e.id = NEW.event_id;

  PERFORM create_notification(
    NEW.user_id::TEXT,
    'event_registration',
    'You''re registered!',
    'Your ticket for "' || COALESCE(v_title, 'the event') || '"' ||
      CASE WHEN v_date IS NOT NULL
           THEN ' on ' || to_char(v_date, 'Mon DD, YYYY')
           ELSE ''
      END || ' is confirmed.',
    NEW.event_id::TEXT,
    'event',
    jsonb_build_object('event_id', NEW.event_id, 'ticket_id', NEW.id)
  );
  RETURN NEW;
END;
$$;

DROP   TRIGGER IF EXISTS event_registration_notification ON event_tickets;
CREATE TRIGGER event_registration_notification
  AFTER INSERT ON event_tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_event_registration();

-- ── 2. New message ───────────────────────────────────────────────────────────
--
-- Sends one in-app notification per recipient per conversation per 5 minutes.
-- Skips: system messages, muted participants, and recipients who already
-- received a new_message notification for this conversation recently.

CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_sender TEXT;
  v_body   TEXT;
BEGIN
  -- Skip system messages
  IF COALESCE(NEW.is_system_message, FALSE) THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(full_name, 'Someone') INTO v_sender
    FROM profiles WHERE id = NEW.sender_id;

  v_body := CASE
    WHEN NEW.content IS NULL OR trim(NEW.content) = '' THEN 'Sent you a message'
    WHEN length(NEW.content) > 100 THEN left(NEW.content, 97) || '…'
    ELSE NEW.content
  END;

  -- Fan out to non-sender, non-muted participants.
  -- The NOT EXISTS guard prevents notification floods when many messages
  -- arrive quickly in the same conversation.
  PERFORM create_notification(
    cp.user_id::TEXT,
    'new_message',
    'New message from ' || v_sender,
    v_body,
    NEW.conversation_id::TEXT,
    'conversation',
    jsonb_build_object('conversation_id', NEW.conversation_id)
  )
  FROM conversation_participants cp
  WHERE cp.conversation_id = NEW.conversation_id
    AND cp.user_id        != NEW.sender_id
    AND cp.is_muted        = FALSE
    AND NOT EXISTS (
      SELECT 1 FROM notifications n
      WHERE  n.user_id       = cp.user_id
        AND  n.type          = 'new_message'
        AND  n.reference_id  = NEW.conversation_id::TEXT
        AND  n.created_at   > NOW() - INTERVAL '5 minutes'
    );

  RETURN NEW;
END;
$$;

DROP   TRIGGER IF EXISTS new_message_notification ON messages;
CREATE TRIGGER new_message_notification
  AFTER INSERT ON messages
  FOR EACH ROW
  WHEN (NOT COALESCE(NEW.is_system_message, FALSE))
  EXECUTE FUNCTION notify_new_message();

-- ── 3. Admin broadcast fan-out ───────────────────────────────────────────────
--
-- Scope resolution:
--   all         → every profile except the sender
--   university  → profiles.university_id = scope_id
--   faculty     → profiles in the named faculty within that university
--   department  → profiles in the named department
--   community   → community_members of scope_id
--
-- Each call goes through create_notification() which enforces
-- the recipient's admin_notices preference before inserting.

CREATE OR REPLACE FUNCTION notify_admin_announcement()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_data JSONB;
  v_body TEXT;
BEGIN
  v_data := jsonb_build_object('announcement_id', NEW.id);
  v_body := left(NEW.body, 200);

  CASE NEW.scope_type

    WHEN 'all' THEN
      PERFORM create_notification(
        p.id::TEXT, 'admin_broadcast', NEW.title, v_body,
        NEW.id::TEXT, 'announcement', v_data
      )
      FROM profiles p
      WHERE p.id != NEW.sender_id;

    WHEN 'university' THEN
      PERFORM create_notification(
        p.id::TEXT, 'admin_broadcast', NEW.title, v_body,
        NEW.id::TEXT, 'announcement', v_data
      )
      FROM profiles p
      WHERE p.university_id = NEW.scope_id
        AND p.id != NEW.sender_id;

    WHEN 'faculty' THEN
      PERFORM create_notification(
        p.id::TEXT, 'admin_broadcast', NEW.title, v_body,
        NEW.id::TEXT, 'announcement', v_data
      )
      FROM profiles p
      JOIN faculties f ON f.id = NEW.scope_id
      WHERE p.university_id = f.university_id
        AND p.faculty       = f.name
        AND p.id != NEW.sender_id;

    WHEN 'department' THEN
      PERFORM create_notification(
        p.id::TEXT, 'admin_broadcast', NEW.title, v_body,
        NEW.id::TEXT, 'announcement', v_data
      )
      FROM profiles p
      JOIN departments d ON d.id = NEW.scope_id
      WHERE p.department = d.name
        AND p.id != NEW.sender_id;

    WHEN 'community' THEN
      PERFORM create_notification(
        cm.user_id::TEXT, 'admin_broadcast', NEW.title, v_body,
        NEW.id::TEXT, 'announcement', v_data
      )
      FROM community_members cm
      WHERE cm.community_id = NEW.scope_id
        AND cm.user_id != NEW.sender_id;

    ELSE NULL;
  END CASE;

  RETURN NEW;
END;
$$;

DROP   TRIGGER IF EXISTS admin_announcement_notification ON admin_announcements;
CREATE TRIGGER admin_announcement_notification
  AFTER INSERT ON admin_announcements
  FOR EACH ROW
  EXECUTE FUNCTION notify_admin_announcement();

COMMIT;
