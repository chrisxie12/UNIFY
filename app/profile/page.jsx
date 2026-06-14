import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export default async function ProfilePage() {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('*, universities(name, short_name)')
    .eq('id', user.id)
    .single();

  if (!profile) redirect('/onboarding');

  const initials = profile.full_name?.split(' ').map((n) => n[0]).slice(0, 2).join('') || '?';

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
