import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('en-GH', { day: 'numeric', month: 'short' });
}

export default async function AdminPage() {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (!profile || !['admin', 'superadmin'].includes(profile.role)) {
    redirect('/feed');
  }

  const [{ data: announcements }, { count: studentCount }, { count: verifiedCount }] = await Promise.all([
    supabase
      .from('announcements')
      .select('*')
      .eq('university_id', profile.university_id)
      .order('created_at', { ascending: false })
      .limit(20),
    supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .eq('university_id', profile.university_id)
      .eq('role', 'student'),
    supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .eq('university_id', profile.university_id)
      .eq('is_verified', true),
  ]);

  const published = announcements?.filter(a => a.is_published).length ?? 0;
  const drafts    = announcements?.filter(a => !a.is_published).length ?? 0;

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      {/* Nav */}
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-5xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
            <span className="text-gray-300">·</span>
            <span className="text-sm font-semibold text-gray-500">Admin Dashboard</span>
          </div>
          <Link href="/feed" className="text-xs text-gray-500 hover:text-gray-900 transition-colors">
            ← Student view
          </Link>
        </div>
      </header>

      <main className="max-w-5xl mx-auto px-6 py-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="font-bold text-2xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>Dashboard</h1>
            <p className="text-gray-400 text-sm mt-0.5">GCTU · {profile.full_name}</p>
          </div>
          <Link
            href="/admin/announcements/new"
            className="inline-flex items-center gap-2 bg-[#003F8A] text-white font-semibold text-sm px-5 py-2.5 rounded-xl hover:bg-[#002d6b] active:scale-95 transition-all"
          >
            + New Announcement
          </Link>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          {[
            { label: 'Students',  value: studentCount ?? 0,  color: 'text-gray-900'   },
            { label: 'Verified',  value: verifiedCount ?? 0, color: 'text-green-600'  },
            { label: 'Published', value: published,           color: 'text-[#003F8A]' },
            { label: 'Drafts',    value: drafts,              color: 'text-orange-500' },
          ].map((s) => (
            <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5">
              <p className={`font-bold text-3xl ${s.color}`}>{s.value}</p>
              <p className="text-gray-400 text-xs mt-1">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Announcements table */}
        <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-50 flex items-center justify-between">
            <h2 className="font-semibold text-gray-900 text-sm">Announcements</h2>
            <Link href="/admin/announcements/new" className="text-xs text-[#003F8A] font-semibold hover:underline">
              Create new →
            </Link>
          </div>

          {!announcements?.length ? (
            <div className="text-center py-12 text-gray-400">
              <p className="text-3xl mb-2">📢</p>
              <p className="text-sm">No announcements yet.</p>
              <Link href="/admin/announcements/new" className="text-[#003F8A] text-sm font-semibold hover:underline mt-2 inline-block">
                Create the first one →
              </Link>
            </div>
          ) : (
            <div className="divide-y divide-gray-50">
              {announcements.map((a) => (
                <div key={a.id} className="px-6 py-4 flex items-center gap-4 hover:bg-gray-50 transition-colors">
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-gray-900 text-sm truncate">{a.title}</p>
                    <p className="text-gray-400 text-xs mt-0.5">{a.category} · {formatDate(a.created_at)}</p>
                  </div>
                  <span className={`shrink-0 text-[10px] font-bold uppercase tracking-wide px-2.5 py-1 rounded-full ${
                    a.is_published ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-500'
                  }`}>
                    {a.is_published ? 'Published' : 'Draft'}
                  </span>
                  <Link
                    href={`/admin/announcements/${a.id}`}
                    className="shrink-0 text-xs text-gray-400 hover:text-gray-900 transition-colors"
                  >
                    Edit →
                  </Link>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
