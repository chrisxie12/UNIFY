'use client';

import { useState } from 'react';
import { usePathname } from 'next/navigation';
import { createBrowserClient } from '@supabase/ssr';
import { Analytics } from '@/lib/analytics';

const HIDDEN_PATHS = ['/', '/login', '/signup', '/onboarding'];
const TYPES = [
  { value: 'bug',           label: 'Bug Report',     icon: '🐛' },
  { value: 'feature',       label: 'Feature Request', icon: '💡' },
  { value: 'problem',       label: 'Improvement',     icon: '⚡' },
];

export default function FeedbackButton() {
  const pathname = usePathname();
  const [open, setOpen]       = useState(false);
  const [type, setType]       = useState('bug');
  const [title, setTitle]     = useState('');
  const [desc, setDesc]       = useState('');
  const [loading, setLoading] = useState(false);
  const [done, setDone]       = useState(false);

  const shouldHide = HIDDEN_PATHS.some((p) => pathname === p || pathname?.startsWith('/['));

  if (shouldHide) return null;

  function reset() {
    setTitle('');
    setDesc('');
    setType('bug');
    setDone(false);
  }

  async function submit(e) {
    e.preventDefault();
    if (!title.trim() || !desc.trim()) return;
    setLoading(true);

    try {
      const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
      );
      const { data: { user } } = await supabase.auth.getUser();

      await supabase.from('feedback_items').insert({
        user_id: user?.id ?? null,
        type,
        title: title.trim(),
        description: desc.trim(),
        platform: 'web',
        app_version: '1.0.0-beta',
        device_info: navigator.userAgent.slice(0, 200),
        status: 'open',
      });

      Analytics.feedbackSubmitted(type);
      setDone(true);
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      {/* Floating trigger */}
      <button
        onClick={() => { reset(); setOpen(true); }}
        className="fixed bottom-6 right-6 z-50 w-12 h-12 rounded-full bg-[#003F8A] text-white shadow-lg flex items-center justify-center hover:bg-[#002d6b] active:scale-95 transition-all"
        aria-label="Send feedback"
        title="Send feedback"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
      </button>

      {/* Modal */}
      {open && (
        <div
          className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 backdrop-blur-sm px-4 pb-6 sm:pb-0"
          onClick={(e) => { if (e.target === e.currentTarget) setOpen(false); }}
        >
          <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl overflow-hidden">
            {/* Header */}
            <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
              <h2 className="font-bold text-gray-900 text-base" style={{ letterSpacing: '-0.02em' }}>
                Send Feedback
              </h2>
              <button onClick={() => setOpen(false)} className="text-gray-400 hover:text-gray-700 transition-colors">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </button>
            </div>

            {done ? (
              <div className="px-5 py-12 text-center">
                <p className="text-4xl mb-3">✅</p>
                <p className="font-semibold text-gray-900">Thanks for the feedback!</p>
                <p className="text-gray-400 text-sm mt-1">We read every submission.</p>
                <button
                  onClick={() => setOpen(false)}
                  className="mt-6 text-sm font-semibold text-[#003F8A] hover:underline"
                >
                  Close
                </button>
              </div>
            ) : (
              <form onSubmit={submit} className="px-5 py-4 flex flex-col gap-4">
                {/* Type selector */}
                <div className="flex gap-2">
                  {TYPES.map((t) => (
                    <button
                      key={t.value}
                      type="button"
                      onClick={() => setType(t.value)}
                      className={`flex-1 flex flex-col items-center gap-1 py-2.5 rounded-xl border text-xs font-semibold transition-all ${
                        type === t.value
                          ? 'border-[#003F8A] bg-blue-50 text-[#003F8A]'
                          : 'border-gray-200 text-gray-500 hover:border-gray-300'
                      }`}
                    >
                      <span className="text-xl">{t.icon}</span>
                      {t.label}
                    </button>
                  ))}
                </div>

                {/* Title */}
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1.5">Title</label>
                  <input
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder={type === 'bug' ? 'e.g. Feed not loading' : type === 'feature' ? 'e.g. Dark mode' : 'e.g. Faster onboarding'}
                    maxLength={100}
                    required
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-1 focus:ring-[#003F8A] transition-colors"
                  />
                </div>

                {/* Description */}
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1.5">Description</label>
                  <textarea
                    value={desc}
                    onChange={(e) => setDesc(e.target.value)}
                    placeholder="What happened? What did you expect?"
                    rows={4}
                    maxLength={1000}
                    required
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-1 focus:ring-[#003F8A] transition-colors resize-none"
                  />
                </div>

                <button
                  type="submit"
                  disabled={loading || !title.trim() || !desc.trim()}
                  className="w-full bg-[#003F8A] text-white font-semibold text-sm py-3 rounded-xl hover:bg-[#002d6b] active:scale-95 disabled:opacity-50 disabled:scale-100 transition-all"
                >
                  {loading ? 'Sending…' : 'Send Feedback'}
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </>
  );
}
