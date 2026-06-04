'use client';

import { useState, useEffect } from 'react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

const SCHOOL_LABELS = {
  knust: 'KNUST', ug: 'UG Legon', ucc: 'UCC',
  upsa: 'UPSA', uds: 'UDS', gctu: 'GCTU',
};

const SCHOOL_COLORS = {
  knust: 'bg-green-500/20 text-green-300',
  ug:   'bg-blue-500/20 text-blue-300',
  ucc:  'bg-purple-500/20 text-purple-300',
  upsa: 'bg-amber-500/20 text-amber-300',
  uds:  'bg-red-500/20 text-red-300',
  gctu: 'bg-sky-500/20 text-sky-300',
};

const PASSWORD = 'unify2026';

export default function AdminPage() {
  const [auth, setAuth] = useState(false);
  const [pw, setPw] = useState('');
  const [pwError, setPwError] = useState(false);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const login = (e) => {
    e.preventDefault();
    if (pw === PASSWORD) { setAuth(true); }
    else { setPwError(true); setTimeout(() => setPwError(false), 1500); }
  };

  useEffect(() => {
    if (!auth) return;
    setLoading(true);
    fetch(`${SHEET_URL}?action=all&ts=admin`)
      .then((r) => r.json())
      .then((d) => setData(d))
      .catch(() => setError('Failed to load data.'))
      .finally(() => setLoading(false));
  }, [auth]);

  if (!auth) {
    return (
      <div className="min-h-screen bg-[#050d20] text-white flex items-center justify-center px-6"
        style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
        <div className="w-full max-w-sm">
          <div className="text-center mb-8">
            <span className="text-2xl font-black">UNIFY</span>
            <p className="text-white/30 text-sm mt-1">Admin Dashboard</p>
          </div>
          <form onSubmit={login} className="flex flex-col gap-3">
            <input
              type="password"
              value={pw}
              onChange={(e) => setPw(e.target.value)}
              placeholder="Password"
              className={`bg-white/[0.06] border rounded-2xl px-5 py-3.5 text-sm text-white placeholder-white/25 outline-none transition-colors ${pwError ? 'border-red-400/60' : 'border-white/[0.1] focus:border-amber-400/50'}`}
            />
            {pwError && <p className="text-xs text-red-400 pl-1">Wrong password</p>}
            <button type="submit" className="bg-amber-400 hover:bg-amber-300 text-[#050d20] font-black text-sm py-3.5 rounded-2xl transition-all active:scale-95">
              Enter →
            </button>
          </form>
        </div>
      </div>
    );
  }

  const entries = data?.entries || [];
  const total   = data?.count || 0;

  const bySchool = Object.entries(SCHOOL_LABELS).map(([id, label]) => ({
    id, label,
    count: entries.filter((e) => e.school === id).length,
  })).sort((a, b) => b.count - a.count);

  const recent = [...entries].reverse().slice(0, 50);

  return (
    <div className="min-h-screen bg-[#050d20] text-white px-6 py-10"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <div className="max-w-4xl mx-auto">

        {/* header */}
        <div className="flex items-center justify-between mb-10">
          <div>
            <span className="text-xl font-black">UNIFY</span>
            <p className="text-white/30 text-xs mt-0.5">Admin Dashboard</p>
          </div>
          <a href="/" className="text-xs text-white/30 hover:text-white transition-colors">← Back to site</a>
        </div>

        {loading && <p className="text-white/40 text-sm">Loading data...</p>}
        {error   && <p className="text-red-400 text-sm">{error}</p>}

        {data && (
          <>
            {/* total */}
            <div className="bg-amber-400/10 border border-amber-400/20 rounded-3xl p-8 mb-6 text-center">
              <p className="text-xs font-bold uppercase tracking-widest text-amber-400 mb-2">Total Signups</p>
              <p className="text-6xl font-black text-white">{total.toLocaleString()}</p>
            </div>

            {/* by school */}
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3 mb-8">
              {bySchool.map(({ id, label, count }) => (
                <div key={id} className="bg-white/[0.03] border border-white/[0.07] rounded-2xl p-5">
                  <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full ${SCHOOL_COLORS[id] || 'bg-white/10 text-white/50'} mb-3 inline-block`}>
                    {label}
                  </span>
                  <p className="text-3xl font-black">{count}</p>
                  <p className="text-xs text-white/30 mt-1">
                    {total > 0 ? Math.round((count / total) * 100) : 0}% of total
                  </p>
                </div>
              ))}
            </div>

            {/* recent signups */}
            <div className="bg-white/[0.02] border border-white/[0.07] rounded-3xl overflow-hidden">
              <div className="px-6 py-4 border-b border-white/[0.06]">
                <p className="text-sm font-black">Recent Signups</p>
                <p className="text-xs text-white/30 mt-0.5">Last {recent.length} entries</p>
              </div>
              <div className="divide-y divide-white/[0.04]">
                {recent.map((e, i) => (
                  <div key={i} className="px-6 py-3.5 flex items-center justify-between gap-4">
                    <span className="text-sm text-white/80 font-medium">{e.phone}</span>
                    <div className="flex items-center gap-3 flex-shrink-0">
                      <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full ${SCHOOL_COLORS[e.school] || 'bg-white/10 text-white/40'}`}>
                        {SCHOOL_LABELS[e.school] || e.school}
                      </span>
                      <span className="text-xs text-white/25 hidden md:block">
                        {new Date(e.ts).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
                      </span>
                    </div>
                  </div>
                ))}
                {recent.length === 0 && (
                  <p className="px-6 py-8 text-sm text-white/25 text-center">No signups yet.</p>
                )}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
