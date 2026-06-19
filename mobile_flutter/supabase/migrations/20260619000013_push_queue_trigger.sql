-- ============================================================
-- UNIFY — Step 13: Push Notification Queue Trigger
--
-- Whenever a row is inserted into `notifications` and the
-- recipient has push_enabled = TRUE, enqueue a push notification
-- in push_notification_queue for the Edge Function to deliver.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION enqueue_push_notification()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM notification_preferences
     WHERE user_id     = NEW.user_id::UUID
       AND push_enabled = TRUE
  ) THEN
    INSERT INTO push_notification_queue (user_id, title, body, data)
    VALUES (
      NEW.user_id::UUID,
      NEW.title,
      COALESCE(NEW.body, ''),
      COALESCE(NEW.data, '{}'::jsonb) || jsonb_build_object('type', NEW.type)
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS push_notification_on_insert ON notifications;
CREATE TRIGGER push_notification_on_insert
  AFTER INSERT ON notifications
  FOR EACH ROW
  EXECUTE FUNCTION enqueue_push_notification();

COMMIT;
