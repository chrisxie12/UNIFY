import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { computeProfileCompleteness, getCommunityRecommendations } from '@/lib/activation';

const CATEGORY_STYLES = {
  urgent:   { bg: 'bg-red-50',    text: 'text-red-600',    label: 'Urgent'   },
  academic: { bg: 'bg-blue-50',   text: 'text-blue-600',   label: 'Academic' },
  events:   { bg: 'bg-purple-50', text: 'text-purple-600', label: 'Events'   },
  admin:    { bg: 'bg-yellow-50', text: 'text-yellow-700', label: 'Admin'    },
  general:  { bg: 'bg-gray-100',  text: 'text-gray-600',   label: 'General'  },
};

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('en-GH', { day: 'numeric', month: 'short', year: 'numeric' });
}

export default async function FeedPage() {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('*, universities(name, short_name, logo_url)')
    .eq('id', user.id)
    .single();

  if (!profile) redirect('/onboarding');

  const { data: announcements } = await supabase
    .from('announcements')
    .select('*')
    .eq('university_id', profile.university_id)
    .eq('is_published', true)
    .order('published_at', { ascending: false })
    .limit(50);

  const isAdmin      = ['admin', 'superadmin'].includes(profile.role);
  const isSuperAdmin = profile.role === 'superadmin';

  // Activation data — parallel, non-blocking
  const [
    { count: communityCount },
    { count: unreadNotifs },
    { count: hasPosted },
  ] = await Promise.all([
    supabase.from('community_members').select('*', { count: 'exact', head: true }).eq('user_id', user.id),
    supabase.from('notifications').select('*', { count: 'exact', head: true }).eq('user_id', user.id).eq('is_read', false),
    supabase.from('analytics_events').select('*', { count: 'exact', head: true }).eq('user_id', user.id).eq('event_name', 'post_created'),
  ]);

  const completeness = computeProfileCompleteness({ ...profile, email: user.email });
  const recommendations = (communityCount ?? 0) === 0
    ? await getCommunityRecommendations(supabase, profile, 3)
    : [];

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      {/* Nav */}
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-5 h-14 flex items-center justify-between">
          <div className="flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
          </div>
          <div className="flex items-center gap-3">
            {isSuperAdmin && (
              <Link href="/launch/founder" className="text-xs font-semibold text-orange-600 bg-orange-50 px-3 py-1.5 rounded-full hover:bg-orange-100 transition-colors">
                Founder
              </Link>
            )}
            {isAdmin && (
              <Link href="/admin" className="text-xs font-semibold text-[#003F8A] bg-blue-50 px-3 py-1.5 rounded-full hover:bg-blue-100 transition-colors">
                Admin
              </Link>
            )}
            <Link href="/notifications" className="relative w-8 h-8 rounded-full border border-gray-100 bg-white flex items-center justify-center hover:bg-gray-50 transition-colors">
              <span className="text-sm">🔔</span>
              {(unreadNotifs ?? 0) > 0 && (
                <span className="absolute -top-0.5 -right-0.5 min-w-[16px] h-4 bg-red-500 rounded-full text-[9px] font-bold text-white flex items-center justify-center px-0.5">
                  {(unreadNotifs ?? 0) > 9 ? '9+' : unreadNotifs}
                </span>
              )}
            </Link>
            <Link href="/profile" className="w-8 h-8 rounded-full bg-[#003F8A] flex items-center justify-center">
              <span className="text-white text-xs font-bold">
                {profile.full_name?.split(' ').map(n => n[0]).slice(0,2).join('') || '?'}
              </span>
            </Link>
          </div>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-5 py-6">
        {/* University header */}
        <div className="flex items-center gap-3 mb-6">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/logos/gctu.png" alt="GCTU" width={40} height={40} style={{ objectFit: 'contain' }} />
          <div>
            <p className="font-bold text-gray-900 text-sm">{profile.universities?.short_name} Announcements</p>
            <p className="text-gray-400 text-xs">{announcements?.length ?? 0} active notices</p>
          </div>
        </div>

        {/* ── Activation nudges ───────────────────────────────────────────── */}
        {completeness.score < 100 && (
          <div className="bg-blue-50 border border-blue-100 rounded-2xl p-4 mb-4">
            <div className="flex items-center justify-between mb-2">
              <p className="text-sm font-semibold text-[#003F8A]">Complete your profile</p>
              <span className="text-xs font-bold text-[#003F8A]">{completeness.score}%</span>
            </div>
            <div className="h-2 bg-blue-100 rounded-full overflow-hidden mb-2">
              <div className="h-full bg-[#003F8A] rounded-full" style={{ width: `${completeness.score}%` }} />
            </div>
            <p className="text-xs text-blue-600 mb-2.5">Missing: {completeness.missing.join(', ')}</p>
            <Link
              href="/profile"
              className="block text-center text-xs font-semibold text-[#003F8A] bg-white border border-blue-200 rounded-xl py-2 hover:bg-blue-50 transition-colors"
            >
              Update profile →
            </Link>
          </div>
        )}

        {recommendations.length > 0 && (
          <div className="bg-white border border-gray-100 rounded-2xl p-4 mb-4">
            <p className="text-sm font-semibold text-gray-900 mb-1">Find your community</p>
            <p className="text-xs text-gray-400 mb-3">Connect with classmates and get relevant updates.</p>
            <div className="flex flex-col gap-2">
              {recommendations.map((c) => (
                <div key={c.id} className="flex items-center justify-between gap-3 bg-gray-50 rounded-xl px-3 py-2.5">
                  <div className="min-w-0">
                    <p className="font-medium text-gray-900 text-sm truncate">{c.name}</p>
                    <p className="text-gray-400 text-xs">{c.member_count ?? 0} members</p>
                  </div>
                  <Link
                    href={`/communities/${c.id}`}
                    className="shrink-0 text-xs font-semibold text-[#003F8A] bg-blue-50 px-3 py-1.5 rounded-full hover:bg-blue-100 transition-colors"
                  >
                    Join
                  </Link>
                </div>
              ))}
            </div>
          </div>
        )}

        {!hasPosted && (communityCount ?? 0) > 0 && (
          <div className="bg-purple-50 border border-purple-100 rounded-2xl p-4 mb-4">
            <p className="text-sm font-semibold text-purple-900 mb-1">Make your first post</p>
            <p className="text-xs text-purple-600">
              Share a question, resource, or thought with your community.{' '}
              <Link href="/communities" className="underline font-semibold">Browse communities →</Link>
            </p>
          </div>
        )}

        {/* Announcement list */}
        {!announcements?.length ? (
          <div className="text-center py-16 text-gray-400">
            <p className="text-4xl mb-3">📢</p>
            <p className="font-semibold text-gray-600">No announcements yet</p>
            <p className="text-sm mt-1">Check back soon.</p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {announcements.map((a) => {
              const style = CATEGORY_STYLES[a.category] ?? CATEGORY_STYLES.general;
              return (
                <div key={a.id} className="bg-white rounded-2xl border border-gray-100 p-5 hover:border-gray-200 hover:shadow-sm transition-all">
                  <div className="flex items-start justify-between gap-3 mb-2">
                    <span className={`text-[10px] font-bold uppercase tracking-widest px-2.5 py-1 rounded-full ${style.bg} ${style.text}`}>
                      {style.label}
                    </span>
                    <span className="text-[11px] text-gray-400 shrink-0">{formatDate(a.published_at)}</span>
                  </div>
                  <h3 className="font-semibold text-gray-900 text-base mb-1 leading-snug">{a.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed">{a.body}</p>
                </div>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
