-- ============================================================
-- Fix: Allow authenticated users to search other profiles
-- ============================================================
-- Previously, only admins could see non-own profiles (profiles_admin_read).
-- This broke the user search for messaging and global search.
-- ============================================================

-- Allow any authenticated user to read profiles (for search/browse)
DROP POLICY IF EXISTS profiles_search_read ON profiles;
CREATE POLICY profiles_search_read ON profiles FOR SELECT
  USING (auth.role() = 'authenticated');

-- NOTE: If you want to restrict search to same-university only,
-- replace the policy above with:
--
-- DROP POLICY IF EXISTS profiles_search_read ON profiles;
-- CREATE POLICY profiles_search_read ON profiles FOR SELECT
--   USING (
--     auth.role() = 'authenticated'
--     AND (
--       university_id = (SELECT p.university_id FROM profiles p WHERE p.id = auth.uid())
--       OR id = auth.uid()
--     )
--   );
