-- ============================================================
-- UNIFY — Step 10: Bootstrap Super Admin
-- One-time migration that promotes an existing auth.users
-- account to platform Super Admin.
--
-- HOW TO USE:
--   Replace the placeholder below with your actual Supabase
--   Auth UID (found in Supabase Dashboard → Authentication →
--   Users). Then paste this entire script into the SQL Editor.
--
--   Alternatively, set ADMIN_EMAIL and the DO block will find
--   the UID automatically from auth.users.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_user_id     UUID;
  v_university_id UUID;
  v_role_id     UUID;
  v_admin_email TEXT := 'gyanchris131@gmail.com';  -- ← your email
BEGIN

  -- ── 1. Resolve user UID from email ───────────────────────────
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = v_admin_email
  LIMIT 1;

  IF v_user_id IS NULL THEN
    -- Diagnostic: list all registered emails to help find the right one
    RAISE NOTICE '=== auth.users diagnostic ===';
    FOR v_user_id IN
      SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 10
    LOOP
      RAISE NOTICE 'UID: % | email: %', v_user_id,
        (SELECT email FROM auth.users WHERE id = v_user_id);
    END LOOP;
    RAISE EXCEPTION
      'Super Admin bootstrap failed: no auth.users row found for email ''%''. '
      'See NOTICE lines above for registered accounts. '
      'Update v_admin_email to the correct address, or replace the email lookup '
      'with: v_user_id := ''<your-uid-uuid>'';',
      v_admin_email;
  END IF;

  RAISE NOTICE 'Bootstrapping Super Admin for UID: %', v_user_id;

  -- ── 2. Resolve default university (GCTU) ─────────────────────
  --    Super admin spans all universities, but the profiles table
  --    requires a non-null university_id.  We use the platform's
  --    seed university as the "home" university for the profile row.
  SELECT id INTO v_university_id
  FROM universities
  WHERE slug = 'gctu'
  LIMIT 1;

  IF v_university_id IS NULL THEN
    -- Fallback: use any available university
    SELECT id INTO v_university_id FROM universities LIMIT 1;
  END IF;

  IF v_university_id IS NULL THEN
    RAISE EXCEPTION
      'No universities found. Run the bootstrap migration first.';
  END IF;

  -- ── 3. Upsert profile row ─────────────────────────────────────
  --    • role = 'superadmin'  (matches profiles CHECK constraint +
  --                            Pattern-A RLS that checks profiles.role)
  --    • is_verified = TRUE
  --    • verification_status = 'approved'
  INSERT INTO profiles (
    id,
    university_id,
    full_name,
    role,
    is_verified,
    verified_at,
    verification_status
  )
  VALUES (
    v_user_id,
    v_university_id,
    'Super Admin',         -- overwritten when user completes profile
    'superadmin',
    TRUE,
    NOW(),
    'approved'
  )
  ON CONFLICT (id) DO UPDATE SET
    role                = 'superadmin',
    is_verified         = TRUE,
    verified_at         = COALESCE(profiles.verified_at, NOW()),
    verification_status = 'approved',
    updated_at          = NOW();

  RAISE NOTICE 'profiles.role set to superadmin for %', v_user_id;

  -- ── 4. Ensure admin_roles seed row exists ────────────────────
  INSERT INTO admin_roles (role, description)
  VALUES
    ('super_admin',        'Platform owner — full access across all universities'),
    ('university_admin',   'Manages a single university'),
    ('faculty_admin',      'Manages a single faculty'),
    ('department_admin',   'Manages a single department'),
    ('moderator',          'Moderates content within assigned scope'),
    ('analyst',            'Read-only analytics access')
  ON CONFLICT (role) DO NOTHING;

  -- ── 5. Resolve super_admin role ID ───────────────────────────
  SELECT id INTO v_role_id
  FROM admin_roles
  WHERE role = 'super_admin';

  IF v_role_id IS NULL THEN
    RAISE EXCEPTION 'admin_roles seed failed — super_admin row missing';
  END IF;

  -- ── 6. Insert university_administrators row ───────────────────
  --    • university_id = NULL  → platform-wide scope (not scoped to
  --                              any single university)
  --    • faculty_id / department_id = NULL
  --    • assigned_by = NULL    → self-bootstrap
  --    • is_active = TRUE
  INSERT INTO university_administrators (
    user_id,
    role_id,
    university_id,
    faculty_id,
    department_id,
    assigned_by,
    is_active
  )
  VALUES (
    v_user_id,
    v_role_id,
    NULL,   -- super admin is not scoped to one university
    NULL,
    NULL,
    NULL,   -- no assigner on initial bootstrap
    TRUE
  )
  ON CONFLICT (user_id, role_id) DO UPDATE SET
    is_active  = TRUE,
    university_id = NULL;   -- ensure scope stays platform-wide

  RAISE NOTICE 'university_administrators row upserted for %', v_user_id;

  -- ── 7. Verification summary ───────────────────────────────────
  RAISE NOTICE '=== Super Admin Bootstrap Complete ===';
  RAISE NOTICE 'UID              : %', v_user_id;
  RAISE NOTICE 'profiles.role    : superadmin';
  RAISE NOTICE 'is_verified      : TRUE';
  RAISE NOTICE 'admin_roles.role : super_admin';
  RAISE NOTICE 'university scope : platform-wide (NULL)';
  RAISE NOTICE 'is_active        : TRUE';

END $$;

-- ── 8. Spot-check query (run separately if desired) ───────────────
--
-- SELECT
--   p.id,
--   p.full_name,
--   p.role            AS profile_role,
--   p.is_verified,
--   p.verification_status,
--   ar.role           AS admin_role,
--   ua.is_active,
--   ua.university_id  AS scope
-- FROM profiles p
-- JOIN university_administrators ua ON ua.user_id = p.id
-- JOIN admin_roles ar ON ar.id = ua.role_id
-- WHERE ar.role = 'super_admin';

COMMIT;
