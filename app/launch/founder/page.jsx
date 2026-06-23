import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import FeatureFlagToggles from './FeatureFlagToggles';

function pct(num, den) {
  if (!den) return '—';
  return Math.round((num / den) * 100) + '%';
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

export const revalidate = 0; // always fresh

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

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const todayISO = todayStart.toISOString();

  // ── All metrics fetched in parallel ──────────────────────────────────────────
  const [
    { count: totalUsers },
    { count: newUsersToday },
    { count: commCount },
    { count: eventCount },
    { count: mktCount },
    { count: pendingVerif },
    { count: pendingReports },
    { count: pendingCommReqs },
    { count: totalAnnouncements },
    { data: testers },
    { data: inviteCodes },
    { count: inviteRedeemed },
    { data: featureFlags },
    // Funnel events
    { data: funnelEvents },
    // Content readiness
    { count: communityCount },
    { count: announcementCount },
    { count: marketplaceCount },
    { count: activeEventCount },
    // Messages today (via analytics_events to avoid needing messages table direct access)
    { count: msgToday },
    // Recent feedback
    { data: recentFeedback },
  ] = await Promise.all([
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
    supabase.from('profiles').select('*', { count: 'exact', head: true }).gte('created_at', todayISO),
    supabase.from('communities').select('*', { count: 'exact', head: true }),
    supabase.from('community_events').select('*', { count: 'exact', head: true }),
    supabase.from('marketplace_listings').select('*', { count: 'exact', head: true }).eq('status', 'active'),
    supabase.from('verification_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('reports').select('*', { count: 'exact', head: true }).eq('status', 'open'),
    supabase.from('community_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('announcements').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('beta_testers').select('user_id, joined_at, status, feedback_count, last_active_at').order('joined_at', { ascending: false }),
    supabase.from('invite_codes').select('id, code, type, use_count, max_uses, is_active, note, created_at').eq('type', 'beta').order('code'),
    supabase.from('invite_redemptions').select('*', { count: 'exact', head: true }),
    supabase.from('feature_flags').select('key, label, description, enabled').order('label'),
    supabase.from('analytics_events').select('user_id, event_name').in('event_name', [
      'onboarding_started', 'onboarding_completed', 'community_joined',
      'first_message_sent', 'feed_viewed',
    ]),
    supabase.from('communities').select('*', { count: 'exact', head: true }),
    supabase.from('announcements').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('marketplace_listings').select('*', { count: 'exact', head: true }).eq('status', 'active'),
    supabase.from('community_events').select('*', { count: 'exact', head: true }),
    supabase.from('analytics_events').select('*', { count: 'exact', head: true }).eq('event_name', 'first_message_sent').gte('created_at', todayISO),
    supabase.from('feedback_items').select('id, type, title, status, created_at').order('created_at', { ascending: false }).limit(8),
  ]);

  // Fetch profile data for beta testers
  const testerUserIds = (testers ?? []).map((t) => t.user_id);
  const { data: testerProfiles } = testerUserIds.length
    ? await supabase.from('profiles').select('id, full_name, email, university_id').in('id', testerUserIds)
    : { data: [] };

  const testerMap = Object.fromEntries((testerProfiles ?? []).map((p) => [p.id, p]));

  // ── Funnel calculation ────────────────────────────────────────────────────────
  const funnel = {
    signed_up:            totalUsers ?? 0,
    onboarding_started:   new Set((funnelEvents ?? []).filter((e) => e.event_name === 'onboarding_started').map((e) => e.user_id)).size,
    onboarding_completed: new Set((funnelEvents ?? []).filter((e) => e.event_name === 'onboarding_completed').map((e) => e.user_id)).size,
    community_joined:     new Set((funnelEvents ?? []).filter((e) => e.event_name === 'community_joined').map((e) => e.user_id)).size,
    first_message_sent:   new Set((funnelEvents ?? []).filter((e) => e.event_name === 'first_message_sent').map((e) => e.user_id)).size,
  };

  // ── Content readiness score ───────────────────────────────────────────────────
  const readinessItems = [
    { label: '3+ Communities',         met: (communityCount ?? 0) >= 3,    actual: communityCount ?? 0,    need: 3    },
    { label: '2+ Events',              met: (activeEventCount ?? 0) >= 2,  actual: activeEventCount ?? 0,  need: 2    },
    { label: '5+ Announcements',       met: (announcementCount ?? 0) >= 5, actual: announcementCount ?? 0, need: 5    },
    { label: '3+ Marketplace listings',met: (marketplaceCount ?? 0) >= 3,  actual: marketplaceCount ?? 0,  need: 3    },
    { label: 'Feedback system active', met: true,                           actual: 1,                      need: 1    },
    { label: 'Invite codes seeded',    met: (inviteCodes?.length ?? 0) >= 3, actual: inviteCodes?.length ?? 0, need: 3 },
  ];
  const readinessPct = Math.round((readinessItems.filter((r) => r.met).length / readinessItems.length) * 100);

  // ── Stat cards ────────────────────────────────────────────────────────────────
  const stats = [
    { label: 'Total Users',              value: totalUsers ?? 0,      color: 'text-gray-900'   },
    { label: 'New Today',                value: newUsersToday ?? 0,   color: 'text-green-600'  },
    { label: 'Messages Today',           value: msgToday ?? 0,        color: 'text-blue-600'   },
    { label: 'Communities',              value: commCount ?? 0,        color: 'text-purple-600' },
    { label: 'Events',                   value: eventCount ?? 0,       color: 'text-indigo-600' },
    { label: 'Marketplace Listings',     value: mktCount ?? 0,         color: 'text-orange-500' },
    { label: 'Pending Verifications',    value: pendingVerif ?? 0,     color: pendingVerif ? 'text-yellow-600' : 'text-gray-400' },
    { label: 'Pending Reports',          value: pendingReports ?? 0,   color: pendingReports ? 'text-red-600' : 'text-gray-400' },
    { label: 'Community Requests',       value: pendingCommReqs ?? 0,  color: pendingCommReqs ? 'text-yellow-600' : 'text-gray-400' },
    { label: 'Announcements Live',       value: totalAnnouncements ?? 0, color: 'text-[#003F8A]' },
  ];

  const quickActions = [
    { label: 'Broadcast Announcement', href: '/admin/announcements/new', icon: '📢' },
    { label: 'Open Admin Dashboard',   href: '/admin',                   icon: '⚙️' },
    { label: 'Student Feed',           href: '/feed',                    icon: '📰' },
  ];

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      {/* Nav */}
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
            <span className="text-gray-300">·</span>
            <span className="text-sm font-semibold text-gray-500">Founder Dashboard</span>
            <span className="ml-1 text-[10px] font-bold uppercase tracking-widest px-2 py-0.5 rounded-full bg-orange-50 text-orange-500">
              Beta
            </span>
          </div>
          <div className="flex items-center gap-3">
            <Link href="/admin" className="text-xs text-gray-500 hover:text-gray-900 transition-colors">Admin</Link>
            <Link href="/feed" className="text-xs text-gray-500 hover:text-gray-900 transition-colors">Feed</Link>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8 space-y-8">

        {/* Hero */}
        <div className="flex items-start justify-between">
          <div>
            <h1 className="font-bold text-2xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>
              Founder Dashboard
            </h1>
            <p className="text-gray-400 text-sm mt-0.5">
              Closed Beta · {totalUsers ?? 0} users · {profile.full_name}
            </p>
          </div>
          <div className={`flex items-center gap-2 text-sm font-semibold px-4 py-2 rounded-xl ${
            readinessPct === 100 ? 'bg-green-50 text-green-700' : readinessPct >= 50 ? 'bg-yellow-50 text-yellow-700' : 'bg-red-50 text-red-600'
          }`}>
            <span>{readinessPct === 100 ? '✅' : readinessPct >= 50 ? '⚠️' : '🔴'}</span>
            Readiness: {readinessPct}%
          </div>
        </div>

        {/* Stats Grid */}
        <section>
          <h2 className="font-semibold text-gray-900 text-sm mb-3">Platform Metrics</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
            {stats.map((s) => (
              <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-4">
                <p className={`font-bold text-2xl ${s.color}`}>{s.value}</p>
                <p className="text-gray-400 text-xs mt-1 leading-tight">{s.label}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Quick Actions */}
        <section>
          <h2 className="font-semibold text-gray-900 text-sm mb-3">Quick Actions</h2>
          <div className="flex flex-wrap gap-3">
            {quickActions.map((a) => (
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

        {/* Invite System + Beta Funnel (side by side on large screens) */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

          {/* Invite Codes */}
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
                  <code className="font-mono font-bold text-sm text-[#003F8A] bg-blue-50 px-2.5 py-1 rounded-lg">
                    {c.code}
                  </code>
                  <span className="text-gray-400 text-xs flex-1 truncate">{c.note ?? ''}</span>
                  <span className={`shrink-0 text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${
                    c.use_count >= c.max_uses
                      ? 'bg-gray-100 text-gray-400'
                      : c.is_active
                      ? 'bg-green-50 text-green-600'
                      : 'bg-red-50 text-red-500'
                  }`}>
                    {c.use_count >= c.max_uses ? 'Used' : c.is_active ? 'Active' : 'Inactive'}
                  </span>
                </div>
              ))}
            </div>
          </section>

          {/* Beta Funnel */}
          <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50">
              <h2 className="font-semibold text-gray-900 text-sm">Activation Funnel</h2>
            </div>
            <div className="px-5 py-4 space-y-3">
              {[
                { label: 'Signed Up',            value: funnel.signed_up,            base: funnel.signed_up },
                { label: 'Onboarding Started',   value: funnel.onboarding_started,   base: funnel.signed_up },
                { label: 'Onboarding Completed', value: funnel.onboarding_completed, base: funnel.signed_up },
                { label: 'Joined a Community',   value: funnel.community_joined,     base: funnel.signed_up },
                { label: 'Sent First Message',   value: funnel.first_message_sent,   base: funnel.signed_up },
              ].map((step) => {
                const width = step.base ? Math.round((step.value / step.base) * 100) : 0;
                return (
                  <div key={step.label}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs text-gray-600">{step.label}</span>
                      <span className="text-xs font-semibold text-gray-900">{step.value} · {width}%</span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-[#003F8A] rounded-full transition-all"
                        style={{ width: `${width}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        </div>

        {/* Beta Tester Health */}
        <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <div className="px-5 py-4 border-b border-gray-50">
            <h2 className="font-semibold text-gray-900 text-sm">Beta Tester Health</h2>
          </div>
          {(testers ?? []).length === 0 ? (
            <div className="px-5 py-10 text-center text-gray-400">
              <p className="text-3xl mb-2">👥</p>
              <p className="text-sm">No beta testers yet.</p>
              <p className="text-xs mt-1">Share an invite code above to get started.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-50 text-left">
                    <th className="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Tester</th>
                    <th className="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Status</th>
                    <th className="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Joined</th>
                    <th className="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Last Active</th>
                    <th className="px-5 py-3 text-xs font-semibold text-gray-400 uppercase tracking-wide">Feedback</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {(testers ?? []).map((t) => {
                    const p = testerMap[t.user_id];
                    return (
                      <tr key={t.user_id} className="hover:bg-gray-50 transition-colors">
                        <td className="px-5 py-3">
                          <p className="font-medium text-gray-900">{p?.full_name ?? '—'}</p>
                          <p className="text-gray-400 text-xs">{p?.email ?? '—'}</p>
                        </td>
                        <td className="px-5 py-3">
                          <span className={`text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${
                            t.status === 'active' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'
                          }`}>
                            {t.status}
                          </span>
                        </td>
                        <td className="px-5 py-3 text-gray-500 text-xs">{fmtDate(t.joined_at)}</td>
                        <td className="px-5 py-3 text-gray-500 text-xs">{ago(t.last_active_at)}</td>
                        <td className="px-5 py-3 text-gray-900 font-semibold text-sm">{t.feedback_count}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </section>

        {/* Recent Feedback */}
        <section className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <div className="px-5 py-4 border-b border-gray-50">
            <h2 className="font-semibold text-gray-900 text-sm">Recent Feedback</h2>
          </div>
          {(recentFeedback ?? []).length === 0 ? (
            <p className="px-5 py-8 text-center text-gray-400 text-sm">No feedback yet. Use the chat button to submit some.</p>
          ) : (
            <div className="divide-y divide-gray-50">
              {(recentFeedback ?? []).map((f) => (
                <div key={f.id} className="px-5 py-3 flex items-center gap-3">
                  <span className="text-lg">
                    {f.type === 'bug' ? '🐛' : f.type === 'feature' ? '💡' : '⚡'}
                  </span>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-gray-900 text-sm truncate">{f.title}</p>
                    <p className="text-gray-400 text-xs">{fmtDate(f.created_at)}</p>
                  </div>
                  <span className={`shrink-0 text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${
                    f.status === 'open' ? 'bg-blue-50 text-blue-600' :
                    f.status === 'in_progress' ? 'bg-yellow-50 text-yellow-600' :
                    f.status === 'fixed' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'
                  }`}>
                    {f.status}
                  </span>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Content Readiness */}
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
                <span className={`text-base ${item.met ? '' : 'opacity-40'}`}>
                  {item.met ? '✅' : '❌'}
                </span>
                <div className="flex-1">
                  <p className={`text-sm font-medium ${item.met ? 'text-gray-900' : 'text-gray-500'}`}>
                    {item.label}
                  </p>
                </div>
                <span className="text-xs text-gray-400">
                  {item.actual}/{item.need}
                </span>
              </div>
            ))}
          </div>
        </section>

        {/* Feature Flags */}
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
          UNIFY Founder Operations — Refreshed on every load · Data from Supabase
        </p>
      </main>
    </div>
  );
}
