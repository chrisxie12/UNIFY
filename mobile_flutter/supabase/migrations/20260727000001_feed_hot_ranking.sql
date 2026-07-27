CREATE OR REPLACE FUNCTION public.get_feed_ranked(
  p_hidden_ids TEXT[] DEFAULT '{}',
  p_cursor_score REAL DEFAULT NULL,
  p_cursor_created_at TIMESTAMPTZ DEFAULT NULL,
  p_limit INT DEFAULT 20
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  body TEXT,
  category TEXT,
  author_id UUID,
  full_name TEXT,
  avatar_url TEXT,
  is_verified_leader BOOLEAN,
  leadership_role TEXT,
  university_id TEXT,
  is_pinned BOOLEAN,
  is_urgent BOOLEAN,
  image_url TEXT,
  view_count INT,
  likes_count INT,
  comments_count INT,
  shares_count INT,
  created_at TIMESTAMPTZ,
  hot_score REAL
)
LANGUAGE plpgsql STABLE
AS $$
BEGIN
  RETURN QUERY
  WITH scored AS (
    SELECT
      a.id,
      a.title,
      a.body,
      a.category,
      a.author_id,
      p.full_name,
      p.avatar_url,
      p.is_verified_leader,
      p.leadership_role,
      a.university_id,
      a.is_pinned,
      a.is_urgent,
      a.image_url,
      a.view_count,
      a.likes_count,
      a.comments_count,
      a.shares_count,
      a.created_at,
      ((a.likes_count * 1.0 + a.comments_count * 2.0 + a.shares_count * 1.5)
        / POWER(EXTRACT(EPOCH FROM (NOW() - a.created_at)) / 3600.0 + 2.0, 1.5))::REAL AS hot_score
    FROM announcements a
    LEFT JOIN profiles p ON p.id = a.author_id
    WHERE p_hidden_ids IS NULL
       OR array_length(p_hidden_ids, 1) IS NULL
       OR NOT (a.id::text = ANY(p_hidden_ids))
  )
  SELECT * FROM scored s
  WHERE
    p_cursor_score IS NULL
    OR (
      NOT s.is_pinned
      AND (s.hot_score < p_cursor_score OR (s.hot_score = p_cursor_score AND s.created_at < p_cursor_created_at))
    )
  ORDER BY s.is_pinned DESC, s.hot_score DESC, s.created_at DESC
  LIMIT p_limit;
END;
$$;
