'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';

const CATEGORIES = ['urgent', 'academic', 'events', 'admin', 'general'];

export default function EditAnnouncementPage() {
  const router = useRouter();
  const { id } = useParams();

  const [title, setTitle]         = useState('');
  const [body, setBody]           = useState('');
  const [category, setCategory]   = useState('general');
  const [published, setPublished] = useState(false);
  const [status, setStatus]       = useState('loading');
  const [error, setError]         = useState('');

  useEffect(() => {
    async function load() {
      const supabase = createClient();
      const { data, error: fetchError } = await supabase
        .from('announcements')
        .select('*')
        .eq('id', id)
        .single();

      if (fetchError || !data) { setError('Announcement not found.'); setStatus('idle'); return; }
      setTitle(data.title);
      setBody(data.body);
      setCategory(data.category);
      setPublished(data.is_published);
      setStatus('idle');
    }
    load();
  }, [id]);

  async function handleSave(e) {
    e.preventDefault();
    setError('');
    if (!title.trim() || !body.trim()) { setError('Title and body are required.'); return; }
    setStatus('saving');
    const supabase = createClient();
    const { error: updateError } = await supabase
      .from('announcements')
      .update({ title: title.trim(), body: body.trim(), category, is_published: published })
      .eq('id', id);

    if (updateError) { setError(updateError.message); setStatus('idle'); return; }
    router.push('/admin');
  }

  async function handleDelete() {
    if (!confirm('Delete this announcement? This cannot be undone.')) return;
    setStatus('deleting');
    const supabase = createClient();
    await supabase.from('announcements').delete().eq('id', id);
    router.push('/admin');
  }

  if (status === 'loading') {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p className="text-gray-400 text-sm">Loading…</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-lg" />
            <span className="font-bold text-base text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
            <span className="text-gray-300">·</span>
            <span className="text-sm font-semibold text-gray-500">Edit Announcement</span>
          </div>
          <Link href="/admin" className="text-xs text-gray-500 hover:text-gray-900 transition-colors">
            ← Dashboard
          </Link>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-6 py-8">
        <form onSubmit={handleSave} className="flex flex-col gap-5">
          {/* Category */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-2">Category</label>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map((c) => (
                <button
                  key={c} type="button" onClick={() => setCategory(c)}
                  className={`px-4 py-2 rounded-xl text-xs font-semibold border capitalize transition-all ${
                    category === c
                      ? 'bg-[#003F8A] text-white border-[#003F8A]'
                      : 'bg-white text-gray-600 border-gray-200 hover:border-[#003F8A]'
                  }`}
                >
                  {c}
                </button>
              ))}
            </div>
          </div>

          {/* Title */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Title</label>
            <input
              type="text" value={title} onChange={(e) => setTitle(e.target.value)}
              placeholder="Announcement title"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>

          {/* Body */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Body</label>
            <textarea
              value={body} onChange={(e) => setBody(e.target.value)}
              rows={6} placeholder="Write the full announcement here…"
              className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all resize-none"
            />
          </div>

          {/* Publish toggle */}
          <div className="flex items-center justify-between bg-white rounded-2xl border border-gray-100 px-5 py-4">
            <div>
              <p className="font-semibold text-gray-900 text-sm">Published</p>
              <p className="text-gray-400 text-xs mt-0.5">Visible to all students</p>
            </div>
            <button
              type="button" onClick={() => setPublished((v) => !v)}
              className={`relative w-11 h-6 rounded-full transition-colors ${published ? 'bg-[#003F8A]' : 'bg-gray-200'}`}
              aria-pressed={published}
            >
              <span className={`absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white shadow transition-transform ${published ? 'translate-x-5' : 'translate-x-0'}`} />
            </button>
          </div>

          {error && <p className="text-red-500 text-xs">{error}</p>}

          <div className="flex gap-3">
            <button
              type="submit" disabled={status === 'saving' || status === 'deleting'}
              className="flex-1 h-11 bg-[#003F8A] text-white font-semibold rounded-xl text-sm hover:bg-[#002d6b] active:scale-95 transition-all disabled:opacity-50"
            >
              {status === 'saving' ? 'Saving…' : 'Save Changes'}
            </button>
            <button
              type="button" onClick={handleDelete} disabled={status === 'saving' || status === 'deleting'}
              className="h-11 px-5 bg-red-50 text-red-600 font-semibold rounded-xl text-sm hover:bg-red-100 active:scale-95 transition-all disabled:opacity-50"
            >
              {status === 'deleting' ? 'Deleting…' : 'Delete'}
            </button>
          </div>
        </form>
      </main>
    </div>
  );
}
