import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { computeProfileCompleteness } from '@/lib/activation';

const BADGE_META = {
  beta_tester: { name: 'Beta Tester', icon: '🧪', description: 'Joined UNIFY as an early beta tester' },
};

export default async function ProfilePage() {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const [{ data: profile }, { data: rawBadges }] = await Promise.all([
    supabase.from('profiles').select('*, universities(name, short_name)').eq('id', user.id).single(),
    supabase.from('user_badges').select('badge_slug, awarded_at').eq('user_id', user.id),
  ]);

  if (!profile) redirect('/onboarding');

  const initials = profile.full_name?.split(' ').map((n) => n[0]).slice(0, 2).join('') || '?';
  const completeness = computeProfileCompleteness({ ...profile, email: user.email });
  const badges = (rawBadges ?? []).map((b) => ({
    slug: b.badge_slug,
    awardedAt: b.awarded_at,
    ...(BADGE_META[b.badge_slug] ?? { name: b.badge_slug, icon: '🏅', description: '' }),
  }));

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-5 h-14 flex items-center justify-between">
          <div className="flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
          </div>
          <a href="/feed" className="text-xs text-gray-500 hover:text-gray-900 transition-colors">
            ← Feed
          </a>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-5 py-8">
        {/* Avatar + name */}
        <div className="flex items-center gap-4 mb-8">
          <div className="w-16 h-16 rounded-2xl bg-[#003F8A] flex items-center justify-center shrink-0">
            <span className="text-white text-xl font-bold">{initials}</span>
          </div>
          <div>
            <p className="font-bold text-gray-900 text-lg" style={{ letterSpacing: '-0.02em' }}>{profile.full_name}</p>
            <p className="text-gray-400 text-sm">{profile.universities?.short_name} · {profile.role}</p>
          </div>
        </div>

        {/* Profile completeness */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5 mb-4">
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm font-semibold text-gray-900">Profile completeness</p>
            <span className={`text-sm font-bold ${completeness.score === 100 ? 'text-green-600' : 'text-[#003F8A]'}`}>
              {completeness.score}%
            </span>
          </div>
          <div className="h-2 bg-gray-100 rounded-full overflow-hidden mb-2">
            <div
              className={`h-full rounded-full ${completeness.score === 100 ? 'bg-green-500' : 'bg-[#003F8A]'}`}
              style={{ width: `${completeness.score}%` }}
            />
          </div>
          {completeness.missing.length > 0 ? (
            <p className="text-xs text-gray-400">Missing: {completeness.missing.join(', ')}</p>
          ) : (
            <p className="text-xs text-green-600 font-medium">Profile complete ✓</p>
          )}
        </div>

        {/* Badges */}
        {badges.length > 0 && (
          <div className="bg-white rounded-2xl border border-gray-100 p-5 mb-4">
            <p className="text-sm font-semibold text-gray-900 mb-3">Badges</p>
            <div className="flex flex-wrap gap-2">
              {badges.map((b) => (
                <div key={b.slug} className="flex items-center gap-2 bg-yellow-50 border border-yellow-100 rounded-xl px-3 py-2">
                  <span className="text-lg">{b.icon}</span>
                  <div>
                    <p className="text-xs font-semibold text-gray-900">{b.name}</p>
                    <p className="text-[10px] text-gray-400">{b.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Details card */}
        <div className="bg-white rounded-2xl border border-gray-100 divide-y divide-gray-50">
          {[
            { label: 'Email',       value: user.email },
            { label: 'Student ID',  value: profile.student_id || '—' },
            { label: 'Programme',   value: profile.programme   || '—' },
            { label: 'Level',       value: profile.level       || '—' },
            { label: 'Phone',       value: profile.phone       || '—' },
            { label: 'Verified',    value: profile.is_verified ? 'Yes' : 'Pending' },
          ].map(({ label, value }) => (
            <div key={label} className="px-5 py-4 flex items-center justify-between">
              <span className="text-xs font-semibold text-gray-500">{label}</span>
              <span className="text-sm text-gray-900">{value}</span>
            </div>
          ))}
        </div>

        {/* Sign out */}
        <form action="/api/auth/signout" method="POST" className="mt-6">
          <button
            type="submit"
            className="w-full h-11 rounded-xl border border-gray-200 text-sm font-semibold text-gray-600 hover:bg-gray-100 transition-colors"
          >
            Sign out
          </button>
        </form>
      </main>
    </div>
  );
}
