'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';

const CATEGORIES = [
  { value: 'urgent',   label: '🚨 Urgent'   },
  { value: 'academic', label: '📚 Academic'  },
  { value: 'events',   label: '🎉 Events'    },
  { value: 'admin',    label: '🏛️ Admin'     },
  { value: 'general',  label: '📢 General'   },
];

export default function NewAnnouncementPage() {
  const router = useRouter();
  const [title, setTitle]         = useState('');
  const [body, setBody]           = useState('');
  const [category, setCategory]   = useState('general');
  const [publish, setPublish]     = useState(false);
  const [status, setStatus]       = useState('idle');
  const [error, setError]         = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    if (!title.trim() || !body.trim()) {
      setError('Title and body are required.');
      return;
    }
    setStatus('loading');
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { router.push('/login'); return; }

    const { data: profile } = await supabase
      .from('profiles')
      .select('university_id, role')
      .eq('id', user.id)
      .single();

    if (!profile || !['admin','superadmin'].includes(profile.role)) {
      setError('You do not have admin access.');
      setStatus('idle');
      return;
    }

    const { error: insertError } = await supabase.from('announcements').insert({
      university_id: profile.university_id,
      author_id:     user.id,
      title:         title.trim(),
      body:          body.trim(),
      category,
      is_published:  publish,
    });

    if (insertError) { setError(insertError.message); setStatus('idle'); return; }
    router.push('/admin');
  }

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-3xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
          </div>
          <Link href="/admin" className="text-xs text-gray-500 hover:text-gray-900 transition-colors">
            ← Back to dashboard
          </Link>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-6 py-8">
        <h1 className="font-bold text-2xl text-gray-900 mb-1" style={{ letterSpacing: '-0.02em' }}>New Announcement</h1>
        <p className="text-gray-400 text-sm mb-8">This will be sent to all GCTU students on UNIFY.</p>

        <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-gray-100 p-6 flex flex-col gap-5">
          {/* Category */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-2">Category</label>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map((c) => (
                <button
                  key={c.value} type="button" onClick={() => setCategory(c.value)}
                  className={`px-4 py-2 rounded-xl text-sm font-medium border transition-all ${
                    category === c.value
                      ? 'bg-[#003F8A] text-white border-[#003F8A]'
                      : 'bg-white text-gray-600 border-gray-200 hover:border-[#003F8A]'
                  }`}
                >
                  {c.label}
                </button>
              ))}
            </div>
          </div>

          {/* Title */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Title</label>
            <input
              type="text" value={title} onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Exam timetable update — Semester 2"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>

          {/* Body */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Message</label>
            <textarea
              value={body} onChange={(e) => setBody(e.target.value)}
              placeholder="Write the full announcement here…"
              rows={6}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all resize-none"
            />
            <p className="text-xs text-gray-400 mt-1 text-right">{body.length} characters</p>
          </div>

          {/* Publish toggle */}
          <label className="flex items-center gap-3 cursor-pointer select-none">
            <div
              onClick={() => setPublish(!publish)}
              className={`w-10 h-6 rounded-full transition-colors duration-200 flex items-center px-0.5 ${publish ? 'bg-[#003F8A]' : 'bg-gray-200'}`}
            >
              <div className={`w-5 h-5 rounded-full bg-white shadow-sm transition-transform duration-200 ${publish ? 'translate-x-4' : 'translate-x-0'}`} />
            </div>
            <span className="text-sm font-medium text-gray-700">
              {publish ? 'Publish immediately' : 'Save as draft'}
            </span>
          </label>

          {error && <p className="text-red-500 text-sm">{error}</p>}

          <div className="flex gap-3 pt-2">
            <button
              type="submit" disabled={status === 'loading'}
              className="flex-1 h-11 bg-[#003F8A] text-white font-semibold rounded-xl text-sm hover:bg-[#002d6b] active:scale-95 transition-all disabled:opacity-50"
            >
              {status === 'loading' ? 'Saving…' : publish ? 'Publish Announcement' : 'Save Draft'}
            </button>
            <Link
              href="/admin"
              className="h-11 px-5 flex items-center justify-center border border-gray-200 text-gray-600 font-semibold rounded-xl text-sm hover:border-gray-400 transition-all"
            >
              Cancel
            </Link>
          </div>
        </form>
      </main>
    </div>
  );
}
