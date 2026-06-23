import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import FeatureFlagToggles from './FeatureFlagToggles';

// ── Formatting helpers ────────────────────────────────────────────────────────

function pct(num, den) {
  if (!den) return '—';
  return Math.round((num / den) * 100) + '%';
}

function fmtDuration(seconds) {
  if (seconds == null || seconds === 0) return '—';
  if (seconds < 60) return `${seconds}s`;
  const m = Math.floor(seconds / 60);
  if (m < 60) return `${m}m`;
  return `${Math.floor(m / 60)}h ${m % 60}m`;
}

function ago(iso) {
  if (!iso) return 'Never';
  const diff = Date.now() - new Date(iso).getTime();
  const m = Math.floor(diff / 60000);
  if (m < 1) return 'Just now';
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}

function fmtDate(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('en-GH', { day: 'numeric', month: 'short' });
}

function dayLabel(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString('en-GH', { weekday: 'short', day: 'numeric' });
}

function isoDateStr(date) {
  return date.toISOString().split('T')[0];
}

// ── Stat card sub-component ───────────────────────────────────────────────────

function StatCard({ label, value, sub, color = 'text-gray-900', accent }) {
  return (
    <div className={`bg-white rounded-2xl border p-4 ${accent ? 'border-[#003F8A]/20 bg-blue-50/30' : 'border-gray-100'}`}>
      <p className={`font-bold text-2xl ${color}`}>{value}</p>
      <p className="text-gray-500 text-xs mt-1 font-medium leading-tight">{label}</p>
      {sub && <p className="text-gray-400 text-[11px] mt-0.5">{sub}</p>}
    </div>
  );
}

// ── Bar chart sub-component (server-rendered) ─────────────────────────────────

function DauChart({ series }) {
  const max = Math.max(...series.map((d) => d.count), 1);
  return (
    <div className="flex items-end gap-1.5 h-24 w-full">
      {series.map((d) => {
        const heightPct = Math.round((d.count / max) * 100);
        const isToday = d.day === isoDateStr(new Date());
        return (
          <div key={d.day} className="flex-1 flex flex-col items-center gap-1 min-w-0">
            <span className="text-[10px] font-semibold text-gray-900">{d.count || ''}</span>
            <div className="w-full rounded-t-lg transition-all" style={{
              height: `${Math.max(heightPct, 4)}%`,
              backgroundColor: isToday ? '#003F8A' : '#003F8A33',
            }} />
            <span className="text-[9px] text-gray-400 truncate w-full text-center">{dayLabel(d.day)}</span>
          </div>
        );
      })}
    </div>
  );
}

// ── Funnel bar sub-component ──────────────────────────────────────────────────

function FunnelBar({ label, value, base, highlight }) {
  const width = base ? Math.round((value / base) * 100) : 0;
  return (
    <div>
      <div className="flex items-center justify-between mb-1">
        <span className="text-xs text-gray-600">{label}</span>
        <span className="text-xs font-semibold text-gray-900">{value} <span className="text-gray-400 font-normal">· {width}%</span></span>
      </div>
      <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
        <div
          className="h-full rounded-full"
          style={{ width: `${width}%`, backgroundColor: highlight ? '#003F8A' : '#003F8A99' }}
        />
      </div>
    </div>
  );
}

// ── Page ─────────────────────────────────────────────────────────────────────

export const revalidate = 0;

export default async function FounderDashboard() {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (!profile || profile.role !== 'superadmin') redirect('/feed');

  // ── Date anchors ──────────────────────────────────────────────────────────
  const now = new Date();
  const todayISO     = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString();
  const yesterdayISO = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1).toISOString();
  const sevenDaysAgoISO  = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 7).toISOString();
  const thirtyDaysAgoISO = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 30).toISOString();
  const threeDaysAgoISO  = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 3).toISOString();

  // ── All data fetched in one parallel batch ────────────────────────────────
  const [
    // Platform counts
    { count: totalUsers },
    { count: newUsersToday },
    { count: commCount },
    { count: eventCount },
    { count: mktCount },
    { count: pendingVerif },
    { count: pendingReports },
    { count: pendingCommReqs },
    { count: totalAnnouncements },

    // Beta program
    { data: testers },
    { data: inviteCodes },
    { count: inviteRedeemed },
    { data: featureFlags },
    { data: recentFeedback },

    // Readiness counts
    { count: communityCount },
    { count: announcementCount },
    { count: marketplaceCount },
    { count: activeEventCount },

    // ─── RETENTION ────────────────────────────────────────────────────────────
    // All analytics events in last 7 days (user_id + event_name + created_at)
    { data: weeklyEvents },
    // All-time funnel events (user_id + event_name)
    { data: funnelEvents },
    // Message & post activity events today
    { count: messagesToday },
    { count: postsToday },
    // Notification engagement (all time)
    { count: notifsOpened },
    { count: notifsTotal },
    // Session stats
    { count: sessionsToday },
    { data: sessionData },
    // All profiles (for dormant detection)
    { data: allProfiles },
    // Recent activity (last 3 days) for dormant detection
    { data: recentActivityUsers },
    // Community engagement
    { data: communities },
    { data: communityEventsRecent },
    // Most viewed event
    { data: topEvents },
  ] = await Promise.all([
    // Platform
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
    supabase.from('profiles').select('*', { count: 'exact', head: true }).gte('created_at', todayISO),
    supabase.from('communities').select('*', { count: 'exact', head: true }),
    supabase.from('community_events').select('*', { count: 'exact', head: true }),
    supabase.from('marketplace_listings').select('*', { count: 'exact', head: true }).eq('status', 'active'),
    supabase.from('verification_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('reports').select('*', { count: 'exact', head: true }).eq('status', 'open'),
    supabase.from('community_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('announcements').select('*', { count: 'exact', head: true }).eq('is_published', true),

    // Beta program
    supabase.from('beta_testers').select('user_id, joined_at, status, feedback_count, last_active_at').order('joined_at', { ascending: false }),
    supabase.from('invite_codes').select('id, code, type, use_count, max_uses, is_active, note, created_at').eq('type', 'beta').order('code'),
    supabase.from('invite_redemptions').select('*', { count: 'exact', head: true }),
    supabase.from('feature_flags').select('key, label, description, enabled').order('label'),
    supabase.from('feedback_items').select('id, type, title, status, created_at').order('created_at', { ascending: false }).limit(8),

    // Readiness
    supabase.from('communities').select('*', { count: 'exact', head: true }),
    supabase.from('announcements').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('marketplace_listings').select('*', { count: 'exact', head: true }).eq('status', 'active'),
    supabase.from('community_events').select('*', { count: 'exact', head: true }),

    // Retention: 7-day event stream
    supabase.from('analytics_events').select('user_id, event_name, created_at').gte('created_at', sevenDaysAgoISO).not('user_id', 'is', null),
    // Funnel: all-time specific events
    supabase.from('analytics_events').select('user_id, event_name').in('event_name', [
      'onboarding_started', 'onboarding_completed', 'community_joined',
      'first_message_sent', 'profile_completed', 'feed_viewed',
    ]).not('user_id', 'is', null),
    // Activity counts
    supabase.from('analytics_events').select('*', { count: 'exact', head: true }).eq('event_name', 'message_sent').gte('created_at', todayISO),
    supabase.from('analytics_events').select('*', { count: 'exact', head: true }).eq('event_name', 'post_created').gte('created_at', todayISO),
    // Notification engagement
    supabase.from('analytics_events').select('*', { count: 'exact', head: true }).eq('event_name', 'notification_opened'),
    supabase.from('analytics_events').select('*', { count: 'exact', head: true }).eq('event_name', 'notification_received'),
    // Sessions
    supabase.from('user_sessions').select('*', { count: 'exact', head: true }).gte('started_at', todayISO),
    supabase.from('user_sessions').select('duration_seconds, started_at').not('duration_seconds', 'is', null).gte('started_at', thirtyDaysAgoISO).order('started_at', { ascending: false }).limit(200),
    // All profiles for dormant detection
    supabase.from('profiles').select('id, full_name, email, role, created_at').neq('role', 'superadmin'),
    // Recent activity: who was active in last 3 days
    supabase.from('analytics_events').select('user_id').gte('created_at', threeDaysAgoISO).not('user_id', 'is', null),
    // Community engagement
    supabase.from('communities').select('id, name, member_count').order('member_count', { ascending: false }).limit(10),
    supabase.from('community_events').select('community_id, rsvp_count').gte('created_at', sevenDaysAgoISO),
    // Top events by RSVPs
    supabase.from('community_events').select('id, title, rsvp_count, event_date, community_id').order('rsvp_count', { ascending: false }).limit(3),
  ]);

  // ── Tester profile lookup ─────────────────────────────────────────────────
  const testerUserIds = (testers ?? []).map((t) => t.user_id);
  const { data: testerProfiles } = testerUserIds.length
    ? await supabase.from('profiles').select('id, full_name, email').in('id', testerUserIds)
    : { data: [] };
  const testerMap = Object.fromEntries((testerProfiles ?? []).map((p) => [p.id, p]));

  // ── Retention computations ────────────────────────────────────────────────

  // DAU today / yesterday
  const todayDateStr     = isoDateStr(now);
  const yesterdayDateStr = isoDateStr(new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1));

  const eventsGrouped = (weeklyEvents ?? []).reduce((acc, e) => {
    const day = e.created_at.split('T')[0];
    if (!acc[day]) acc[day] = new Set();
    acc[day].add(e.user_id);
    return acc;
  }, {});

  const dauToday     = eventsGrouped[todayDateStr]?.size ?? 0;
  const dauYesterday = eventsGrouped[yesterdayDateStr]?.size ?? 0;
  const returningToday = [...(eventsGrouped[yesterdayDateStr] ?? new Set())]
    .filter((uid) => eventsGrouped[todayDateStr]?.has(uid)).length;

  // 7-day DAU series for chart
  const dauSeries = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - (6 - i));
    const day = isoDateStr(d);
    return { day, count: eventsGrouped[day]?.size ?? 0 };
  });

  // Session duration stats
  const durations = (sessionData ?? []).map((s) => s.duration_seconds).filter(Boolean);
  const avgSessionSec = durations.length ? Math.round(durations.reduce((a, b) => a + b, 0) / durations.length) : null;

  // Dormant users: signed up 3+ days ago but no event in last 3 days
  const recentActiveSet = new Set((recentActivityUsers ?? []).map((e) => e.user_id));
  const dormantUsers = (allProfiles ?? []).filter((p) => {
    if (recentActiveSet.has(p.id)) return false;
    const signedUpDaysAgo = (Date.now() - new Date(p.created_at).getTime()) / (1000 * 60 * 60 * 24);
    return signedUpDaysAgo >= 3;
  });

  // Funnel distinct users
  const funnel = {
    signed_up:            totalUsers ?? 0,
    onboarding_started:   new Set((funnelEvents ?? []).filter((e) => e.event_name === 'onboarding_started').map((e) => e.user_id)).size,
    onboarding_completed: new Set((funnelEvents ?? []).filter((e) => e.event_name === 'onboarding_completed').map((e) => e.user_id)).size,
    profile_completed:    new Set((funnelEvents ?? []).filter((e) => e.event_name === 'profile_completed').map((e) => e.user_id)).size,
    community_joined:     new Set((funnelEvents ?? []).filter((e) => e.event_name === 'community_joined').map((e) => e.user_id)).size,
    first_message_sent:   new Set((funnelEvents ?? []).filter((e) => e.event_name === 'first_message_sent').map((e) => e.user_id)).size,
    returned_next_day:    returningToday,
  };

  // Community engagement scores
  const eventsPerComm = (communityEventsRecent ?? []).reduce((acc, e) => {
    acc[e.community_id] = (acc[e.community_id] ?? 0) + 1;
    return acc;
  }, {});
  const rsvpPerComm = (communityEventsRecent ?? []).reduce((acc, e) => {
    acc[e.community_id] = (acc[e.community_id] ?? 0) + (e.rsvp_count ?? 0);
    return acc;
  }, {});

  const commScores = (communities ?? []).map((c) => ({
    ...c,
    eventsRecent: eventsPerComm[c.id] ?? 0,
    rsvpsRecent:  rsvpPerComm[c.id] ?? 0,
    score: (c.member_count ?? 0) + (eventsPerComm[c.id] ?? 0) * 10 + (rsvpPerComm[c.id] ?? 0) * 3,
  })).sort((a, b) => b.score - a.score);

  const topCommunity = commScores[0] ?? null;
  const topEvent     = (topEvents ?? [])[0] ?? null;

  // Notification open rate
  const notifOpenRate = (notifsTotal ?? 0) > 0 ? Math.round(((notifsOpened ?? 0) / notifsTotal) * 100) : null;

  // Content readiness
  const readinessItems = [
    { label: '3+ Communities',          met: (communityCount ?? 0) >= 3,    actual: communityCount ?? 0,    need: 3 },
    { label: '2+ Events',               met: (activeEventCount ?? 0) >= 2,  actual: activeEventCount ?? 0,  need: 2 },
    { label: '5+ Announcements',        met: (announcementCount ?? 0) >= 5, actual: announcementCount ?? 0, need: 5 },
    { label: '3+ Marketplace listings', met: (marketplaceCount ?? 0) >= 3,  actual: marketplaceCount ?? 0,  need: 3 },
    { label: 'Feedback system active',  met: true,                           actual: 1,                      need: 1 },
    { label: 'Invite codes seeded',     met: (inviteCodes?.length ?? 0) >= 3, actual: inviteCodes?.length ?? 0, need: 3 },
  ];
  const readinessPct = Math.round((readinessItems.filter((r) => r.met).length / readinessItems.length) * 100);

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>

      {/* ── Nav ─────────────────────────────────────────────────────────────── */}
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
            <span className="text-gray-300">·</span>
            <span className="text-sm font-semibold text-gray-500">Founder Dashboard</span>
            <span className="ml-1 text-[10px] font-bold uppercase tracking-widest px-2 py-0.5 rounded-full bg-orange-50 text-orange-500">Beta</span>
          </div>
          <div className="flex items-center gap-4">
            <Link href="/admin" className="text-xs text-gray-400 hover:text-gray-900 transition-colors">Admin</Link>
            <Link href="/feed" className="text-xs text-gray-400 hover:text-gray-900 transition-colors">Feed</Link>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8 space-y-8">

        {/* ── Hero ─────────────────────────────────────────────────────────── */}
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="font-bold text-2xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>Founder Dashboard</h1>
            <p className="text-gray-400 text-sm mt-0.5">Closed Beta · {totalUsers ?? 0} users · {profile.full_name}</p>
          </div>
          <div className={`shrink-0 flex items-center gap-2 text-sm font-semibold px-4 py-2 rounded-xl ${
            readinessPct === 100 ? 'bg-green-50 text-green-700' : readinessPct >= 50 ? 'bg-yellow-50 text-yellow-700' : 'bg-red-50 text-red-600'
          }`}>
            {readinessPct === 100 ? '✅' : readinessPct >= 50 ? '⚠️' : '🔴'}
            Beta Readiness: {readinessPct}%
          </div>
        </div>

        {/* ── SECTION 1: Retention Pulse ──────────────────────────────────── */}
        <section>
          <h2 className="font-semibold text-gray-900 text-sm mb-3">Retention Pulse <span className="text-gray-400 font-normal">· Today</span></h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
            <StatCard
              label="Active Today"
              value={dauToday}
              sub={`${dauYesterday} yesterday`}
              color={dauToday > 0 ? 'text-green-600' : 'text-gray-400'}
              accent
            />
            <StatCard
              label="Returning Users"
              value={returningToday}
              sub={`${pct(returningToday, dauYesterday)} D1 retention`}
              color={returningToday > 0 ? 'text-[#003F8A]' : 'text-gray-400'}
            />
            <StatCard
              label="Avg Session"
              value={fmtDuration(avgSessionSec)}
              sub={`${durations.length} sessions tracked`}
              color="text-gray-900"
            />
            <StatCard
              label="Messages Today"
              value={messagesToday ?? 0}
              color={messagesToday ? 'text-blue-600' : 'text-gray-400'}
            />
            <StatCard
              label="Posts Today"
              value={postsToday ?? 0}
              color={postsToday ? 'text-purple-600' : 'text-gray-400'}
            />
            <StatCard
              label="Dormant (3d+)"
              value={dormantUsers.length}
              sub={dormantUsers.length ? 'Need re-engagement' : 'All users active'}
              color={dormantUsers.length > 0 ? 'text-red-500' : 'text-green-600'}
            />
          </div>
        </section>

        {/* ── SECTION 2: 7-Day DAU Chart ──────────────────────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <section className="bg-white rounded-2xl border border-gray-100 p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-900 text-sm">Daily Active Users <span className="text-gray-400 font-normal">· Last 7 days</span></h2>
              <span className="text-xs text-gray-400">Dark = today</span>
            </div>
            <DauChart series={dauSeries} />
          </section>

          {/* ── SECTION 3: Session Duration ──────────────────────────────── */}
          <section className="bg-white rounded-2xl border border-gray-100 p-5">
            <h2 className="font-semibold text-gray-900 text-sm mb-4">Session Analytics</h2>
            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="font-bold text-xl text-gray-900">{fmtDuration(avgSessionSec)}</p>
                <p className="text-gray-400 text-xs mt-1">Avg duration (30d)</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="font-bold text-xl text-gray-900">{sessionsToday ?? 0}</p>
                <p className="text-gray-400 text-xs mt-1">Sessions today</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="font-bold text-xl text-gray-900">{fmtDuration(Math.max(...durations.slice(0, 10), 0) || null)}</p>
                <p className="text-gray-400 text-xs mt-1">Longest session</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="font-bold text-xl text-gray-900">{durations.length}</p>
                <p className="text-gray-400 text-xs mt-1">Sessions w/ duration</p>
              </div>
            </div>
            {durations.length === 0 && (
              <p className="text-xs text-gray-400 text-center py-2">
                Sessions populate once users visit — tracking is live.
              </p>
            )}
          </section>
        </div>

        {/* ── SECTION 4: Onboarding Funnel + Notification Engagement ──────── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50">
              <h2 className="font-semibold text-gray-900 text-sm">Onboarding Completion Funnel</h2>
            </div>
            <div className="px-5 py-4 space-y-3">
              <FunnelBar label="Signed Up"             value={funnel.signed_up}            base={funnel.signed_up} highlight />
              <FunnelBar label="Onboarding Started"    value={funnel.onboarding_started}   base={funnel.signed_up} />
              <FunnelBar label="Onboarding Completed"  value={funnel.onboarding_completed} base={funnel.signed_up} />
              <FunnelBar label="Profile Complete"      value={funnel.profile_completed}    base={funnel.signed_up} />
              <FunnelBar label="Joined Community"      value={funnel.community_joined}     base={funnel.signed_up} />
              <FunnelBar label="Sent First Message"    value={funnel.first_message_sent}   base={funnel.signed_up} />
              <FunnelBar label="Returned Next Day"     value={funnel.returned_next_day}    base={dauYesterday || 1} highlight />
            </div>
          </section>

          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50">
              <h2 className="font-semibold text-gray-900 text-sm">Notification Engagement</h2>
            </div>
            <div className="px-5 py-5 space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-bold text-3xl text-gray-900">{notifsOpened ?? 0}</p>
                  <p className="text-gray-400 text-xs mt-1">Notifications opened</p>
                </div>
                <div className="text-right">
                  <p className="font-bold text-3xl text-gray-900">
                    {notifOpenRate != null ? `${notifOpenRate}%` : '—'}
                  </p>
                  <p className="text-gray-400 text-xs mt-1">Open rate</p>
                </div>
              </div>
              <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                <div
                  className="h-full bg-[#003F8A] rounded-full"
                  style={{ width: `${notifOpenRate ?? 0}%` }}
                />
              </div>
              <p className="text-xs text-gray-400">
                {(notifsTotal ?? 0) === 0
                  ? 'Tracking active — events logged when notification bell is instrumented.'
                  : `${notifsTotal} notifications delivered · ${notifsOpened} opened`
                }
              </p>

              {/* Push notification engagement breakdown */}
              <div className="border-t border-gray-50 pt-3 space-y-2">
                <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">To track push engagement:</p>
                <p className="text-xs text-gray-400">Call <code className="bg-gray-100 px-1 rounded text-[#003F8A]">Analytics.notificationOpened(id)</code> when user taps a notification.</p>
                <p className="text-xs text-gray-400">Call <code className="bg-gray-100 px-1 rounded text-[#003F8A]">Analytics.notificationReceived(type)</code> when notification is delivered.</p>
              </div>
            </div>
          </section>
        </div>

        {/* ── SECTION 5: Community Engagement + Top Event ──────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <h2 className="font-semibold text-gray-900 text-sm">Community Engagement</h2>
              <span className="text-xs text-gray-400">Score = members + events×10 + RSVPs×3</span>
            </div>
            {commScores.length === 0 ? (
              <div className="px-5 py-10 text-center text-gray-400">
                <p className="text-3xl mb-2">🏘️</p>
                <p className="text-sm">No communities yet.</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-50">
                {commScores.slice(0, 5).map((c, i) => (
                  <div key={c.id} className="px-5 py-3 flex items-center gap-3">
                    <span className={`text-xs font-bold w-5 ${i === 0 ? 'text-orange-500' : 'text-gray-300'}`}>#{i + 1}</span>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-900 text-sm truncate">{c.name}</p>
                      <p className="text-gray-400 text-xs">{c.member_count} members · {c.eventsRecent} events (7d)</p>
                    </div>
                    <span className="shrink-0 font-bold text-sm text-[#003F8A]">{c.score}</span>
                  </div>
                ))}
              </div>
            )}
          </section>

          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50">
              <h2 className="font-semibold text-gray-900 text-sm">Event Participation</h2>
            </div>
            {(topEvents ?? []).length === 0 ? (
              <div className="px-5 py-10 text-center text-gray-400">
                <p className="text-3xl mb-2">📅</p>
                <p className="text-sm">No events yet.</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-50">
                {(topEvents ?? []).map((e, i) => (
                  <div key={e.id} className="px-5 py-3 flex items-center gap-3">
                    <span className={`text-xs font-bold w-5 ${i === 0 ? 'text-orange-500' : 'text-gray-300'}`}>#{i + 1}</span>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-900 text-sm truncate">{e.title}</p>
                      <p className="text-gray-400 text-xs">{fmtDate(e.event_date)}</p>
                    </div>
                    <div className="shrink-0 text-right">
                      <p className="font-bold text-sm text-[#003F8A]">{e.rsvp_count}</p>
                      <p className="text-gray-400 text-[10px]">RSVPs</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </section>
        </div>

        {/* ── SECTION 6: Dormant Users ──────────────────────────────────────── */}
        {dormantUsers.length > 0 && (
          <section className="bg-white rounded-2xl border border-red-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-red-50 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="text-base">🔴</span>
                <h2 className="font-semibold text-gray-900 text-sm">Dormant Users</h2>
              </div>
              <span className="text-xs text-red-500 font-medium">Inactive 3+ days</span>
            </div>
            <div className="divide-y divide-gray-50">
              {dormantUsers.map((u) => (
                <div key={u.id} className="px-5 py-3 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center shrink-0">
                    <span className="text-xs font-bold text-gray-500">
                      {u.full_name?.split(' ').map((n) => n[0]).slice(0, 2).join('') || '?'}
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-gray-900 text-sm">{u.full_name || u.email}</p>
                    <p className="text-gray-400 text-xs">{u.email}</p>
                  </div>
                  <div className="shrink-0 text-right">
                    <p className="text-xs text-gray-500">Joined {fmtDate(u.created_at)}</p>
                    <p className="text-xs text-red-400 font-medium">No recent activity</p>
                  </div>
                </div>
              ))}
            </div>
            <div className="px-5 py-3 bg-red-50/50 border-t border-red-50">
              <p className="text-xs text-red-400">
                Re-engage via <Link href="/admin/announcements/new" className="underline">Broadcast Announcement</Link> or direct message.
              </p>
            </div>
          </section>
        )}

        {/* ── SECTION 7: Platform Metrics ──────────────────────────────────── */}
        <section>
          <h2 className="font-semibold text-gray-900 text-sm mb-3">Platform Metrics</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
            {[
              { label: 'Total Users',           value: totalUsers ?? 0,        color: 'text-gray-900' },
              { label: 'New Today',             value: newUsersToday ?? 0,     color: 'text-green-600' },
              { label: 'Communities',           value: commCount ?? 0,          color: 'text-purple-600' },
              { label: 'Events',                value: eventCount ?? 0,         color: 'text-indigo-600' },
              { label: 'Marketplace Listings',  value: mktCount ?? 0,           color: 'text-orange-500' },
              { label: 'Pending Verifications', value: pendingVerif ?? 0,       color: pendingVerif ? 'text-yellow-600' : 'text-gray-400' },
              { label: 'Pending Reports',       value: pendingReports ?? 0,     color: pendingReports ? 'text-red-600' : 'text-gray-400' },
              { label: 'Community Requests',    value: pendingCommReqs ?? 0,    color: pendingCommReqs ? 'text-yellow-600' : 'text-gray-400' },
              { label: 'Announcements Live',    value: totalAnnouncements ?? 0, color: 'text-[#003F8A]' },
              { label: 'Most Active Comm.',     value: topCommunity ? `${topCommunity.score}pt` : '—', color: 'text-orange-500' },
            ].map((s) => (
              <StatCard key={s.label} label={s.label} value={s.value} color={s.color} />
            ))}
          </div>
        </section>

        {/* ── SECTION 8: Quick Actions ─────────────────────────────────────── */}
        <section>
          <h2 className="font-semibold text-gray-900 text-sm mb-3">Quick Actions</h2>
          <div className="flex flex-wrap gap-3">
            {[
              { label: 'Broadcast Announcement', href: '/admin/announcements/new', icon: '📢' },
              { label: 'Open Admin Dashboard',   href: '/admin',                   icon: '⚙️' },
              { label: 'Student Feed',           href: '/feed',                    icon: '📰' },
            ].map((a) => (
              <Link
                key={a.href}
                href={a.href}
                className="flex items-center gap-2 bg-white border border-gray-100 rounded-xl px-4 py-2.5 text-sm font-medium text-gray-700 hover:border-[#003F8A] hover:text-[#003F8A] transition-all"
              >
                <span>{a.icon}</span>
                {a.label}
              </Link>
            ))}
          </div>
        </section>

        {/* ── SECTION 9: Invite Codes + Beta Tester Health ─────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <h2 className="font-semibold text-gray-900 text-sm">Invite Codes</h2>
              <span className="text-xs text-gray-400">
                {inviteRedeemed ?? 0}/{inviteCodes?.length ?? 0} used · {pct(inviteRedeemed ?? 0, inviteCodes?.length ?? 0)} conversion
              </span>
            </div>
            <div className="divide-y divide-gray-50">
              {(inviteCodes ?? []).length === 0 ? (
                <p className="px-5 py-8 text-center text-gray-400 text-sm">No invite codes yet.</p>
              ) : (inviteCodes ?? []).map((c) => (
                <div key={c.id} className="px-5 py-3 flex items-center gap-3">
                  <code className="font-mono font-bold text-sm text-[#003F8A] bg-blue-50 px-2.5 py-1 rounded-lg">{c.code}</code>
                  <span className="text-gray-400 text-xs flex-1 truncate">{c.note ?? ''}</span>
                  <span className={`shrink-0 text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${
                    c.use_count >= c.max_uses ? 'bg-gray-100 text-gray-400' : c.is_active ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-500'
                  }`}>
                    {c.use_count >= c.max_uses ? 'Used' : c.is_active ? 'Active' : 'Inactive'}
                  </span>
                </div>
              ))}
            </div>
          </section>

          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50">
              <h2 className="font-semibold text-gray-900 text-sm">Beta Tester Health</h2>
            </div>
            {(testers ?? []).length === 0 ? (
              <div className="px-5 py-10 text-center text-gray-400">
                <p className="text-3xl mb-2">👥</p>
                <p className="text-sm">No beta testers yet.</p>
                <p className="text-xs mt-1">Share an invite code to get started.</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-50 text-left">
                      <th className="px-4 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Tester</th>
                      <th className="px-4 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Status</th>
                      <th className="px-4 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Last Active</th>
                      <th className="px-4 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Feedback</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {(testers ?? []).map((t) => {
                      const p = testerMap[t.user_id];
                      return (
                        <tr key={t.user_id} className="hover:bg-gray-50 transition-colors">
                          <td className="px-4 py-3">
                            <p className="font-medium text-gray-900 text-sm">{p?.full_name ?? '—'}</p>
                            <p className="text-gray-400 text-xs truncate max-w-[120px]">{p?.email ?? '—'}</p>
                          </td>
                          <td className="px-4 py-3">
                            <span className={`text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${
                              t.status === 'active' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'
                            }`}>{t.status}</span>
                          </td>
                          <td className="px-4 py-3 text-gray-500 text-xs">{ago(t.last_active_at)}</td>
                          <td className="px-4 py-3 text-gray-900 font-semibold text-sm">{t.feedback_count}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        </div>

        {/* ── SECTION 10: Recent Feedback ──────────────────────────────────── */}
        <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <div className="px-5 py-4 border-b border-gray-50">
            <h2 className="font-semibold text-gray-900 text-sm">Recent Feedback</h2>
          </div>
          {(recentFeedback ?? []).length === 0 ? (
            <p className="px-5 py-8 text-center text-gray-400 text-sm">No feedback yet.</p>
          ) : (
            <div className="divide-y divide-gray-50">
              {(recentFeedback ?? []).map((f) => (
                <div key={f.id} className="px-5 py-3 flex items-center gap-3">
                  <span className="text-lg">{f.type === 'bug' ? '🐛' : f.type === 'feature' ? '💡' : '⚡'}</span>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-gray-900 text-sm truncate">{f.title}</p>
                    <p className="text-gray-400 text-xs">{fmtDate(f.created_at)}</p>
                  </div>
                  <span className={`shrink-0 text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${
                    f.status === 'open' ? 'bg-blue-50 text-blue-600' :
                    f.status === 'in_progress' ? 'bg-yellow-50 text-yellow-600' :
                    f.status === 'fixed' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'
                  }`}>{f.status}</span>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* ── SECTION 11: Content Readiness ────────────────────────────────── */}
        <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
            <h2 className="font-semibold text-gray-900 text-sm">Beta Readiness Checker</h2>
            <span className={`text-sm font-bold ${readinessPct === 100 ? 'text-green-600' : readinessPct >= 50 ? 'text-yellow-600' : 'text-red-500'}`}>
              {readinessPct}%
            </span>
          </div>
          <div className="divide-y divide-gray-50">
            {readinessItems.map((item) => (
              <div key={item.label} className="px-5 py-3 flex items-center gap-3">
                <span className={`text-base ${item.met ? '' : 'opacity-40'}`}>{item.met ? '✅' : '❌'}</span>
                <p className={`flex-1 text-sm font-medium ${item.met ? 'text-gray-900' : 'text-gray-500'}`}>{item.label}</p>
                <span className="text-xs text-gray-400">{item.actual}/{item.need}</span>
              </div>
            ))}
          </div>
        </section>

        {/* ── SECTION 12: Feature Flags ────────────────────────────────────── */}
        {featureFlags && featureFlags.length > 0 && (
          <section>
            <div className="flex items-center justify-between mb-3">
              <h2 className="font-semibold text-gray-900 text-sm">Feature Flags</h2>
              <span className="text-xs text-gray-400">Toggle without deploying</span>
            </div>
            <FeatureFlagToggles initialFlags={featureFlags} />
          </section>
        )}

        <p className="text-xs text-gray-300 pb-4 text-center">
          UNIFY Founder Operations · Refreshed on every load · All data live from Supabase
        </p>
      </main>
    </div>
  );
}
