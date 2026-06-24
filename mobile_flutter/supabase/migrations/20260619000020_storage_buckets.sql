-- ============================================================================
-- 20260619000020_storage_buckets.sql
--
-- Provision every Storage bucket the Flutter client actually uses. Prior to
-- this migration only the `profiles` bucket existed (20260619000019), but the
-- app uploads to ten buckets and reads them all via getPublicUrl(). Without
-- these buckets + write policies, every image/file upload (avatars, covers,
-- posts, chat, stories, resources, listings, verification, feedback) fails
-- silently.
--
-- Read access: all buckets are created public = TRUE, so getPublicUrl() works
-- without a SELECT policy (public buckets bypass RLS on read).
-- Write access: RLS still applies to INSERT/UPDATE/DELETE even on public
-- buckets, so each bucket gets explicit write policies below.
--
-- Path schemes (must match lib/ upload calls):
--   avatars                <userId>/avatar.<ext>
--   covers                 <userId>/cover.<ext>
--   snapshots              <userId>/<ts>.<ext>
--   listings               <userId>/<ts>.<ext>
--   feedback               <userId>/<ts>.jpg
--   post-images            post_images/<communityId>/<ts>.<ext>
--   chat-images            chat/<uid>/<ts>.<ext>
--   resources              community_resources/<communityId>/<file>
--   stories                stories/<uid>/<ts>.<ext>
--   verification_evidence  verification/<userId>/<ts>.<ext>
-- ============================================================================

-- ── 1. Buckets ──────────────────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('avatars',               'avatars',               TRUE, 5242880,  ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('covers',                'covers',                TRUE, 5242880,  ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('post-images',           'post-images',           TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('chat-images',           'chat-images',           TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('snapshots',             'snapshots',             TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('stories',               'stories',               TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('listings',              'listings',              TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('feedback',              'feedback',              TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','image/gif']),
  ('resources',             'resources',             TRUE, 52428800, NULL),
  ('verification_evidence', 'verification_evidence', TRUE, 10485760, ARRAY['image/png','image/jpeg','image/webp','application/pdf'])
ON CONFLICT (id) DO UPDATE
  SET public            = EXCLUDED.public,
      file_size_limit   = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ── 2. Write policies: per-user-folder buckets ──────────────────────────────
-- First path segment must equal the caller's uid. INSERT + UPDATE (for upsert)
-- + DELETE so users can replace/remove their own files.
DO $$
DECLARE b TEXT;
BEGIN
  FOREACH b IN ARRAY ARRAY['avatars','covers','snapshots','listings','feedback']
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_insert_own');
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_update_own');
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_delete_own');

    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR INSERT TO authenticated '
      'WITH CHECK (bucket_id = %L AND (storage.foldername(name))[1] = auth.uid()::text)',
      b || '_insert_own', b);
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR UPDATE TO authenticated '
      'USING (bucket_id = %L AND (storage.foldername(name))[1] = auth.uid()::text)',
      b || '_update_own', b);
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR DELETE TO authenticated '
      'USING (bucket_id = %L AND (storage.foldername(name))[1] = auth.uid()::text)',
      b || '_delete_own', b);
  END LOOP;
END $$;

-- ── 3. Write policies: literal-prefix buckets ───────────────────────────────
-- These upload under a literal first folder (post_images/, chat/, stories/,
-- community_resources/, verification/), so per-user isolation can't key on
-- foldername[1]. Allow any authenticated user to write; reads stay public.
DO $$
DECLARE b TEXT;
BEGIN
  FOREACH b IN ARRAY ARRAY['post-images','chat-images','stories','resources','verification_evidence']
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_insert_auth');
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_update_auth');

    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR INSERT TO authenticated '
      'WITH CHECK (bucket_id = %L)',
      b || '_insert_auth', b);
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR UPDATE TO authenticated '
      'USING (bucket_id = %L)',
      b || '_update_auth', b);
  END LOOP;
END $$;

-- ============================================================================
-- TODO (before public launch — NOT required for closed beta):
--   `verification_evidence` is public-readable because the client reads it via
--   getPublicUrl(). Verification documents (student IDs, etc.) should instead
--   live in a PRIVATE bucket served through createSignedUrl() with admin-only
--   read access. Harden before opening signups to the public.
-- ============================================================================
