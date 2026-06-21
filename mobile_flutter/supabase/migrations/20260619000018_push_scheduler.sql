-- ============================================================
-- UNIFY — Step 18: Push Notification Queue Scheduler
--
-- Wires up a pg_cron + pg_net job that calls the
-- send_push_notification Edge Function every minute to drain
-- the push_notification_queue table.
--
-- REQUIRED BEFORE RUNNING THIS MIGRATION:
-- 1. Deploy the Edge Function:
--      supabase functions deploy send_push_notification --project-ref unify-b92fd
--
-- 2. Set the Google service account secret:
--      supabase secrets set GOOGLE_SERVICE_ACCOUNT_JSON='<json>' --project-ref unify-b92fd
--
-- 3. Store connection info as Postgres settings (run in SQL Editor):
--      ALTER DATABASE postgres SET app.supabase_url = 'https://unify-b92fd.supabase.co';
--      ALTER DATABASE postgres SET app.service_role_key = '<your_service_role_key>';
--      SELECT pg_reload_conf();
--
-- EXTENSIONS REQUIRED: pg_cron, pg_net (both enabled by default on Supabase)
-- ============================================================

BEGIN;

-- Ensure pg_net is available (Supabase enables it by default)
CREATE EXTENSION IF NOT EXISTS pg_net SCHEMA extensions;

-- ── Schedule the push-queue processor to run every minute ────────────────────

SELECT cron.schedule(
  'process-push-queue',       -- job name (unique)
  '* * * * *',               -- every minute
  $cron$
  SELECT extensions.http_post(
    url     := current_setting('app.supabase_url') || '/functions/v1/send_push_notification',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.service_role_key')
               ),
    body    := '{}'::jsonb
  );
  $cron$
);

-- ── Add UPDATE/DELETE RLS for queue self-management ──────────────────────────
-- The Edge Function uses the service-role key (bypasses RLS), so these
-- policies are for completeness / future admin tooling only.

CREATE POLICY "push_queue_update_system" ON push_notification_queue
  FOR UPDATE TO service_role USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY "push_queue_delete_system" ON push_notification_queue
  FOR DELETE TO service_role USING (TRUE);

COMMIT;
