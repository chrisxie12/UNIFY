-- =============================================================================
-- Beta Launch Sprint — Foundation Migration
-- Date: 2026-06-23
--
-- 1. Fix is_super_admin() — schema uses 'superadmin', not 'super_admin'
-- 2. Seed Beta Tester badge
-- 3. Seed GYAN001–GYAN003 invite codes
-- 4. Fix feature_flags update policy to use corrected superadmin check
-- =============================================================================

-- ── Fix is_super_admin() helper ───────────────────────────────────────────────
-- The previous definition checked role = 'super_admin' which never matches;
-- the schema CHECK constraint and all existing data use 'superadmin'.

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
      and role = 'superadmin'
  );
$$;

grant execute on function is_super_admin() to authenticated;

-- ── Seed Beta Tester badge ────────────────────────────────────────────────────

insert into badges (name, slug, description, category, is_system) values
  ('Beta Tester', 'beta_tester', 'Joined UNIFY as an early beta tester', 'milestone', true)
on conflict (slug) do nothing;

-- ── Seed invite codes for roommates ──────────────────────────────────────────
-- Codes are inserted with no created_by (will be updated by founder after launch).
-- max_uses = 1 per code, type = 'beta'.

insert into invite_codes (code, type, max_uses, is_active, note) values
  ('GYAN001', 'beta', 1, true, 'Roommate invite 1'),
  ('GYAN002', 'beta', 1, true, 'Roommate invite 2'),
  ('GYAN003', 'beta', 1, true, 'Roommate invite 3')
on conflict (code) do nothing;

-- ── Fix feature_flags update policy ──────────────────────────────────────────
-- Drop the old policy that used the broken is_super_admin() definition,
-- then re-create after the fix above takes effect.

drop policy if exists "Super admins can toggle feature_flags" on feature_flags;

create policy "Super admins can toggle feature_flags"
  on feature_flags for update
  to authenticated
  using (is_super_admin())
  with check (is_super_admin());

-- ── Allow super admins to insert new feature flags ───────────────────────────

drop policy if exists "Super admins can insert feature_flags" on feature_flags;

create policy "Super admins can insert feature_flags"
  on feature_flags for insert
  to authenticated
  with check (is_super_admin());
