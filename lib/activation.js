// Server-side activation utilities. All functions require a Supabase server client.

// ── Profile completeness ──────────────────────────────────────────────────────

const COMPLETENESS_FIELDS = [
  { key: 'full_name',  label: 'Full name'  },
  { key: 'email',      label: 'Email'      },
  { key: 'student_id', label: 'Student ID' },
  { key: 'programme',  label: 'Programme'  },
  { key: 'level',      label: 'Year/Level' },
  { key: 'phone',      label: 'Phone'      },
];

export function computeProfileCompleteness(profile) {
  const checks = COMPLETENESS_FIELDS.map((f) => ({
    ...f,
    filled: !!(profile[f.key] && String(profile[f.key]).trim()),
  }));
  const filled = checks.filter((c) => c.filled).length;
  const score  = Math.round((filled / checks.length) * 100);
  const missing = checks.filter((c) => !c.filled).map((c) => c.label);
  return { score, filled, total: checks.length, missing };
}

// ── Community recommendations ─────────────────────────────────────────────────
// Returns communities the user hasn't joined, ranked by programme/level match
// and by member count. Scoped to the user's university.

export async function getCommunityRecommendations(supabase, profile, limit = 4) {
  const [{ data: memberOf }, { data: allComms }] = await Promise.all([
    supabase
      .from('community_members')
      .select('community_id')
      .eq('user_id', profile.id),
    supabase
      .from('communities')
      .select('id, name, description, community_type, member_count, programme, level')
      .eq('university_id', profile.university_id)
      .eq('is_active', true)
      .order('member_count', { ascending: false })
      .limit(20),
  ]);

  const joinedIds = new Set((memberOf ?? []).map((m) => m.community_id));
  const userProg  = (profile.programme ?? '').toLowerCase();
  const userLevel = (profile.level ?? '').toLowerCase();

  return (allComms ?? [])
    .filter((c) => !joinedIds.has(c.id))
    .map((c) => {
      let score = c.member_count ?? 0;
      const commProg = (c.programme ?? '').toLowerCase();
      const commLevel = (c.level ?? '').toLowerCase();
      // Boost for programme keyword match
      if (commProg && userProg && userProg.includes(commProg.split(' ')[0])) score += 60;
      // Boost for level match
      if (commLevel && userLevel && commLevel === userLevel) score += 40;
      return { ...c, relevanceScore: score };
    })
    .sort((a, b) => b.relevanceScore - a.relevanceScore)
    .slice(0, limit);
}

// ── Cohort retention: D1 / D3 / D7 ──────────────────────────────────────────
// For each non-admin user, checks if they had any analytics event on exactly
// day 1, 3, and 7 after their signup date.

export async function getCohortRetention(supabase) {
  const [{ data: profiles }, { data: events }] = await Promise.all([
    supabase
      .from('profiles')
      .select('id, created_at')
      .not('role', 'in', '("admin","superadmin")'),
    supabase
      .from('analytics_events')
      .select('user_id, created_at')
      .not('user_id', 'is', null),
  ]);

  if (!profiles?.length) {
    return { d1: null, d3: null, d7: null, activationRate: null, totalCohort: 0 };
  }

  // Group event dates by user_id
  const eventDaysByUser = {};
  (events ?? []).forEach((e) => {
    const day = e.created_at.split('T')[0];
    if (!eventDaysByUser[e.user_id]) eventDaysByUser[e.user_id] = new Set();
    eventDaysByUser[e.user_id].add(day);
  });

  function addDays(isoDate, n) {
    const d = new Date(isoDate);
    d.setDate(d.getDate() + n);
    return d.toISOString().split('T')[0];
  }

  const now = Date.now();
  let activated = 0;
  let d1Eligible = 0, d1Retained = 0;
  let d3Eligible = 0, d3Retained = 0;
  let d7Eligible = 0, d7Retained = 0;

  profiles.forEach((p) => {
    const signupDay   = p.created_at.split('T')[0];
    const daysSince   = (now - new Date(p.created_at).getTime()) / 86400000;
    const userDays    = eventDaysByUser[p.id] ?? new Set();

    // Activation: any analytics event at all
    if (userDays.size > 0) activated++;

    // D1
    if (daysSince >= 1) {
      d1Eligible++;
      if (userDays.has(addDays(signupDay, 1))) d1Retained++;
    }
    // D3
    if (daysSince >= 3) {
      d3Eligible++;
      if (userDays.has(addDays(signupDay, 3))) d3Retained++;
    }
    // D7
    if (daysSince >= 7) {
      d7Eligible++;
      if (userDays.has(addDays(signupDay, 7))) d7Retained++;
    }
  });

  return {
    activationRate : Math.round((activated  / profiles.length) * 100),
    d1             : d1Eligible ? Math.round((d1Retained / d1Eligible) * 100) : null,
    d3             : d3Eligible ? Math.round((d3Retained / d3Eligible) * 100) : null,
    d7             : d7Eligible ? Math.round((d7Retained / d7Eligible) * 100) : null,
    totalCohort    : profiles.length,
    d1Eligible, d1Retained,
    d3Eligible, d3Retained,
    d7Eligible, d7Retained,
  };
}

// ── Growth series ────────────────────────────────────────────────────────────
// Returns daily counts for key metrics over the last N days.

export async function getGrowthSeries(supabase, days = 14) {
  const since = new Date();
  since.setDate(since.getDate() - (days - 1));
  since.setHours(0, 0, 0, 0);
  const sinceISO = since.toISOString();

  const [
    { data: userJoins },
    { data: postEvents },
    { data: messageEvents },
    { data: communityJoinEvents },
    { data: eventRsvps },
  ] = await Promise.all([
    supabase.from('profiles').select('created_at').gte('created_at', sinceISO),
    supabase.from('analytics_events').select('created_at').eq('event_name', 'post_created').gte('created_at', sinceISO),
    supabase.from('analytics_events').select('created_at').eq('event_name', 'message_sent').gte('created_at', sinceISO),
    supabase.from('analytics_events').select('created_at').eq('event_name', 'community_joined').gte('created_at', sinceISO),
    supabase.from('analytics_events').select('created_at').eq('event_name', 'event_rsvp').gte('created_at', sinceISO),
  ]);

  const countByDay = (arr, dayStr) =>
    (arr ?? []).filter((r) => r.created_at.startsWith(dayStr)).length;

  return Array.from({ length: days }, (_, i) => {
    const d = new Date(since);
    d.setDate(d.getDate() + i);
    const day = d.toISOString().split('T')[0];
    return {
      day,
      users:       countByDay(userJoins, day),
      posts:       countByDay(postEvents, day),
      messages:    countByDay(messageEvents, day),
      communities: countByDay(communityJoinEvents, day),
      rsvps:       countByDay(eventRsvps, day),
    };
  });
}

// ── Cumulative totals over a growth series ────────────────────────────────────

export function cumulateSeries(series) {
  let totals = { users: 0, posts: 0, messages: 0, communities: 0, rsvps: 0 };
  return series.map((d) => {
    totals = {
      users:       totals.users       + d.users,
      posts:       totals.posts       + d.posts,
      messages:    totals.messages    + d.messages,
      communities: totals.communities + d.communities,
      rsvps:       totals.rsvps       + d.rsvps,
    };
    return { day: d.day, ...totals };
  });
}
