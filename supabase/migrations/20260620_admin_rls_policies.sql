-- =============================================================================
-- Security Hardening: Admin RLS Policies
-- Sprint: Security Hardening
-- Date: 2026-06-20
--
-- Adds Row Level Security policies to tables that contain sensitive admin data.
-- All policies enforce role-based access using the profiles.role column.
--
-- Role values: 'student' (default) | 'admin' | 'super_admin'
--
-- Run this migration AFTER ensuring auth.uid() is available in your Supabase
-- project (it is available by default in all Supabase projects).
-- =============================================================================

-- ── Helper function: is current user an admin? ────────────────────────────────

create or replace function is_admin()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1
    from profiles
    where id = auth.uid()
      and role in ('admin', 'super_admin')
  );
$$;

-- ── Helper function: is current user a super_admin? ───────────────────────────

create or replace function is_super_admin()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1
    from profiles
    where id = auth.uid()
      and role = 'super_admin'
  );
$$;

-- =============================================================================
-- TABLE: reports
-- Students can create reports (any type). Only admins can read all reports
-- or update report status. Users can read their own submitted reports.
-- =============================================================================

alter table reports enable row level security;

-- Students can submit reports
drop policy if exists "reports_insert_any_user" on reports;
create policy "reports_insert_any_user" on reports
  for insert
  with check (auth.uid() = reporter_id);

-- Students can only read their own submitted reports
drop policy if exists "reports_select_own" on reports;
create policy "reports_select_own" on reports
  for select
  using (auth.uid() = reporter_id OR is_admin());

-- Only admins can update report status
drop policy if exists "reports_update_admin_only" on reports;
create policy "reports_update_admin_only" on reports
  for update
  using (is_admin())
  with check (is_admin());

-- =============================================================================
-- TABLE: moderation_queue
-- Only admins can read or update the moderation queue.
-- Any user can insert (system inserts reports into queue, not users directly).
-- =============================================================================

alter table moderation_queue enable row level security;

drop policy if exists "moderation_select_admin_only" on moderation_queue;
create policy "moderation_select_admin_only" on moderation_queue
  for select
  using (is_admin());

drop policy if exists "moderation_update_admin_only" on moderation_queue;
create policy "moderation_update_admin_only" on moderation_queue
  for update
  using (is_admin())
  with check (is_admin());

drop policy if exists "moderation_insert_system" on moderation_queue;
create policy "moderation_insert_system" on moderation_queue
  for insert
  with check (auth.uid() is not null);

-- =============================================================================
-- TABLE: marketplace_reports
-- Any user can file a report. Only admins can read all reports or resolve them.
-- Reporter can view their own filed reports.
-- =============================================================================

alter table marketplace_reports enable row level security;

drop policy if exists "marketplace_reports_insert_any_user" on marketplace_reports;
create policy "marketplace_reports_insert_any_user" on marketplace_reports
  for insert
  with check (auth.uid() = reporter_id);

drop policy if exists "marketplace_reports_select_admin_or_own" on marketplace_reports;
create policy "marketplace_reports_select_admin_or_own" on marketplace_reports
  for select
  using (auth.uid() = reporter_id OR is_admin());

drop policy if exists "marketplace_reports_update_admin_only" on marketplace_reports;
create policy "marketplace_reports_update_admin_only" on marketplace_reports
  for update
  using (is_admin())
  with check (is_admin());

-- =============================================================================
-- TABLE: verification_requests
-- Students can submit and view their own requests.
-- Only admins can view all requests and update (approve/reject) them.
-- =============================================================================

alter table verification_requests enable row level security;

drop policy if exists "verification_insert_own" on verification_requests;
create policy "verification_insert_own" on verification_requests
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "verification_select_own_or_admin" on verification_requests;
create policy "verification_select_own_or_admin" on verification_requests
  for select
  using (auth.uid() = user_id OR is_admin());

drop policy if exists "verification_update_admin_only" on verification_requests;
create policy "verification_update_admin_only" on verification_requests
  for update
  using (is_admin())
  with check (is_admin());

-- =============================================================================
-- TABLE: universities
-- Anyone can read university data (needed for signup flows).
-- Only super_admins can create, update, or delete universities.
-- =============================================================================

alter table universities enable row level security;

drop policy if exists "universities_select_all" on universities;
create policy "universities_select_all" on universities
  for select
  using (true);

drop policy if exists "universities_insert_super_admin" on universities;
create policy "universities_insert_super_admin" on universities
  for insert
  with check (is_super_admin());

drop policy if exists "universities_update_super_admin" on universities;
create policy "universities_update_super_admin" on universities
  for update
  using (is_super_admin())
  with check (is_super_admin());

drop policy if exists "universities_delete_super_admin" on universities;
create policy "universities_delete_super_admin" on universities
  for delete
  using (is_super_admin());

-- =============================================================================
-- TABLE: faculties
-- Anyone can read. Only super_admins can mutate.
-- =============================================================================

alter table faculties enable row level security;

drop policy if exists "faculties_select_all" on faculties;
create policy "faculties_select_all" on faculties
  for select
  using (true);

drop policy if exists "faculties_mutate_super_admin" on faculties;
create policy "faculties_mutate_super_admin" on faculties
  for all
  using (is_super_admin())
  with check (is_super_admin());

-- =============================================================================
-- TABLE: departments
-- Anyone can read. Only super_admins can mutate.
-- =============================================================================

alter table departments enable row level security;

drop policy if exists "departments_select_all" on departments;
create policy "departments_select_all" on departments
  for select
  using (true);

drop policy if exists "departments_mutate_super_admin" on departments;
create policy "departments_mutate_super_admin" on departments
  for all
  using (is_super_admin())
  with check (is_super_admin());

-- =============================================================================
-- TABLE: audit_logs
-- Only admins can read audit logs.
-- Only the system (via service role / RPC) should write to audit_logs.
-- Direct client inserts are blocked for non-admins.
-- =============================================================================

alter table audit_logs enable row level security;

drop policy if exists "audit_logs_select_admin_only" on audit_logs;
create policy "audit_logs_select_admin_only" on audit_logs
  for select
  using (is_admin());

-- Writes are handled by the log_admin_action RPC which uses security definer.
-- Prevent direct client inserts from non-admins:
drop policy if exists "audit_logs_insert_admin_only" on audit_logs;
create policy "audit_logs_insert_admin_only" on audit_logs
  for insert
  with check (is_admin());

-- =============================================================================
-- TABLE: admin_roles / university_administrators
-- Only admins can read. Only super_admins can mutate.
-- =============================================================================

alter table university_administrators enable row level security;

drop policy if exists "university_admins_select_admin" on university_administrators;
create policy "university_admins_select_admin" on university_administrators
  for select
  using (is_admin());

drop policy if exists "university_admins_mutate_super_admin" on university_administrators;
create policy "university_admins_mutate_super_admin" on university_administrators
  for all
  using (is_super_admin())
  with check (is_super_admin());

-- =============================================================================
-- Ensure the log_admin_action RPC runs as security definer so it can bypass
-- RLS when writing audit log entries on behalf of admin users.
-- =============================================================================

-- If you have a log_admin_action function, update it to be SECURITY DEFINER:
-- (run this only if the function exists with SECURITY INVOKER)
-- alter function log_admin_action(...) security definer;

-- =============================================================================
-- Grant execute on helper functions to authenticated role
-- =============================================================================

grant execute on function is_admin() to authenticated;
grant execute on function is_super_admin() to authenticated;
