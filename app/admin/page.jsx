'use client';

import { useState, useEffect } from 'react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';
const PASSWORD  = 'unify2026';

const SCHOOLS = [
  { id: 'knust', label: 'KNUST',    color: 'text-green-400',  bg: 'bg-green-400/10 border-green-400/20',  bar: 'bg-green-400' },
  { id: 'ug',    label: 'UG Legon', color: 'text-blue-400',   bg: 'bg-blue-400/10 border-blue-400/20',    bar: 'bg-blue-400' },
  { id: 'ucc',   label: 'UCC',      color: 'text-purple-400', bg: 'bg-purple-400/10 border-purple-400/20',bar: 'bg-purple-400' },
  { id: 'upsa',  label: 'UPSA',     color: 'text-amber-400',  bg: 'bg-amber-400/10 border-amber-400/20',  bar: 'bg-amber-400' },
  { id: 'uds',   label: 'UDS',      color: 'text-red-400',    bg: 'bg-red-400/10 border-red-400/20',      bar: 'bg-red-400' },
  { id: 'gctu',  label: 'GCTU',     color: 'text-sky-400',    bg: 'bg-sky-400/10 border-sky-400/20',      bar: 'bg-sky-400' },
];

function formatDate(ts) {
  try {
    const d = new Date(ts);
    if (isNaN(d)) return String(ts);
    return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
  } catch { return String(ts); }
}

function maskPhone(phone) {
  const s = String(phone || '');
  if (s.length < 6) return s;
  return s.slice(0, 4) + '••••' + s.slice(-3);
}

export default function AdminPage() {
  const [auth, setAuth]       = useState(false);
  const [pw, setPw]           = useState('');
  const [pwError, setPwError] = useState(false);
  const [data, setData]       = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState('');
  const [lastRefresh, setLastRefresh] = useState(null);

  const login = (e) => {
    e.preventDefault();
    if (pw === PASSWORD) { setAuth(true); }
    else { setPwError(true); setPw(''); setTimeout(() => setPwError(false), 1500); }
  };

  const loadData = () => {
    setLoading(true);
    setError('');
    fetch(`${SHEET_URL}?action=all&ts=${Date.now()}`)
      .then((r) => r.text())
      .then((text) => {
        const d = JSON.parse(text);
        d.entries = (d.entries || []).map((e) => ({
          phone:  String(e.phone  || ''),
          school: String(e.school || ''),
          ts:     String(e.ts     || ''),
        }));
        setData(d);
        setLastRefresh(new Date());
      })
      .catch((err) => setError('Failed to load data. ' + err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => { if (auth) loadData(); }, [auth]);

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  if (!auth) {
    return (
      <div
        className="min-h-screen bg-[#050d20] text-white flex items-center justify-center px-6"
        style={{ fontFamily: "'Inter', system-ui, sans-serif" }}
      >
        <div className="w-full max-w-[360px]">
          {/* logo */}
          <div className="text-center mb-10">
            <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-amber-400 mb-4">
              <span className="text-2xl font-black text-[#050d20]">U</span>
            </div>
            <h1 className="text-xl font-black">UNIFY Admin</h1>
            <p className="text-white/30 text-sm mt-1">Waitlist Dashboard</p>
          </div>

          <form onSubmit={login} className="flex flex-col gap-3">
            <div className={`bg-white/[0.04] border rounded-2xl px-5 py-3.5 flex items-center gap-3 transition-colors ${pwError ? 'border-red-400/50' : 'border-white/[0.08] focus-within:border-amber-400/40'}`}>
              <span className="text-white/25 text-sm">🔒</span>
              <input
                type="password"
                value={pw}
                onChange={(e) => setPw(e.target.value)}
                placeholder="Enter password"
                autoFocus
                className="flex-1 bg-transparent text-sm text-white placeholder-white/25 outline-none"
              />
            </div>
            {pwError && <p className="text-xs text-red-400 pl-1">Incorrect password</p>}
            <button
              type="submit"
              className="bg-amber-400 hover:bg-amber-300 active:scale-95 text-[#050d20] font-black text-sm py-3.5 rounded-2xl transition-all mt-1"
            >
              Enter Dashboard →
            </button>
          </form>

          <p className="text-center text-xs text-white/15 mt-8">UNIFY · Admin access only</p>
        </div>
      </div>
    );
  }

  // ── DASHBOARD ─────────────────────────────────────────────────────────────
  const entries = data?.entries || [];
  const total   = data?.count   || 0;
  const recent  = [...entries].reverse().slice(0, 100);

  const schoolStats = SCHOOLS.map((s) => ({
    ...s,
    count: entries.filter((e) => e.school === s.id).length,
  })).sort((a, b) => b.count - a.count);

  const topSchool = schoolStats[0];

  return (
    <div
      className="min-h-screen bg-[#050d20] text-white"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}
    >
      {/* ── TOP BAR ── */}
      <div className="border-b border-white/[0.06] bg-[#050d20]/90 backdrop-blur sticky top-0 z-10">
        <div className="max-w-5xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-7 h-7 rounded-lg bg-amber-400 flex items-center justify-center">
              <span className="text-[11px] font-black text-[#050d20]">U</span>
            </div>
            <span className="text-sm font-black">UNIFY Admin</span>
            <span className="hidden md:block text-xs text-white/20 border border-white/[0.08] px-2 py-0.5 rounded-full">Waitlist</span>
          </div>
          <div className="flex items-center gap-3">
            {lastRefresh && (
              <span className="hidden md:block text-[11px] text-white/25">
                Updated {lastRefresh.toLocaleTimeString()}
              </span>
            )}
            <button
              onClick={loadData}
              disabled={loading}
              className="text-xs font-bold text-white/40 hover:text-white border border-white/[0.08] hover:border-white/20 px-3 py-1.5 rounded-xl transition-all disabled:opacity-40"
            >
              {loading ? 'Refreshing...' : '↻ Refresh'}
            </button>
            <a href="/" className="text-xs text-white/25 hover:text-white transition-colors">← Site</a>
          </div>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-6 py-8">

        {error && (
          <div className="bg-red-400/10 border border-red-400/20 rounded-2xl px-5 py-4 text-sm text-red-400 mb-6">{error}</div>
        )}

        {loading && !data && (
          <div className="flex items-center justify-center py-24">
            <p className="text-white/30 text-sm">Loading data...</p>
          </div>
        )}

        {data && (
          <>
            {/* ── STAT CARDS ── */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
              <div className="col-span-2 bg-amber-400/[0.08] border border-amber-400/20 rounded-2xl p-6">
                <p className="text-xs font-bold uppercase tracking-widest text-amber-400 mb-1">Total Signups</p>
                <p className="text-5xl font-black">{total.toLocaleString()}</p>
                <p className="text-xs text-white/30 mt-2">across all schools</p>
              </div>
              <div className="bg-white/[0.03] border border-white/[0.07] rounded-2xl p-6">
                <p className="text-xs font-bold uppercase tracking-widest text-white/30 mb-1">Top School</p>
                <p className={`text-2xl font-black ${topSchool?.color}`}>{topSchool?.label || '—'}</p>
                <p className="text-xs text-white/30 mt-2">{topSchool?.count || 0} signups</p>
              </div>
              <div className="bg-white/[0.03] border border-white/[0.07] rounded-2xl p-6">
                <p className="text-xs font-bold uppercase tracking-widest text-white/30 mb-1">Latest Signup</p>
                <p className="text-sm font-black text-white/80 leading-snug">
                  {recent[0] ? SCHOOLS.find(s => s.id === recent[0].school)?.label || recent[0].school : '—'}
                </p>
                <p className="text-xs text-white/30 mt-2">{recent[0] ? formatDate(recent[0].ts) : '—'}</p>
              </div>
            </div>

            {/* ── SCHOOL BREAKDOWN ── */}
            <div className="bg-white/[0.02] border border-white/[0.07] rounded-2xl p-6 mb-6">
              <p className="text-sm font-black mb-5">Signups by School</p>
              <div className="flex flex-col gap-3">
                {schoolStats.map(({ id, label, count, color, bar }) => (
                  <div key={id} className="flex items-center gap-4">
                    <span className={`text-xs font-black w-20 flex-shrink-0 ${color}`}>{label}</span>
                    <div className="flex-1 h-2 bg-white/[0.06] rounded-full overflow-hidden">
                      <div
                        className={`h-full ${bar} rounded-full transition-all duration-700`}
                        style={{ width: total > 0 ? `${(count / total) * 100}%` : '0%' }}
                      />
                    </div>
                    <span className="text-xs font-bold text-white/60 w-8 text-right">{count}</span>
                    <span className="text-[10px] text-white/25 w-8 text-right">
                      {total > 0 ? `${Math.round((count / total) * 100)}%` : '0%'}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* ── RECENT ENTRIES ── */}
            <div className="bg-white/[0.02] border border-white/[0.07] rounded-2xl overflow-hidden">
              <div className="px-6 py-4 border-b border-white/[0.06] flex items-center justify-between">
                <div>
                  <p className="text-sm font-black">Recent Signups</p>
                  <p className="text-xs text-white/25 mt-0.5">Showing last {recent.length} entries · newest first</p>
                </div>
              </div>

              {/* table header */}
              <div className="px-6 py-2 grid grid-cols-3 border-b border-white/[0.04]">
                <span className="text-[10px] font-bold uppercase tracking-widest text-white/25">#</span>
                <span className="text-[10px] font-bold uppercase tracking-widest text-white/25">Phone</span>
                <span className="text-[10px] font-bold uppercase tracking-widest text-white/25">School · Date</span>
              </div>

              <div className="divide-y divide-white/[0.04] max-h-[480px] overflow-y-auto">
                {recent.map((e, i) => {
                  const sc = SCHOOLS.find(s => s.id === e.school);
                  return (
                    <div key={i} className="px-6 py-3 grid grid-cols-3 items-center hover:bg-white/[0.02] transition-colors">
                      <span className="text-xs text-white/20 font-mono">{total - i}</span>
                      <span className="text-sm text-white/80 font-medium font-mono">{maskPhone(e.phone)}</span>
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${sc?.bg || 'bg-white/10 border-white/10'} ${sc?.color || 'text-white/40'}`}>
                          {sc?.label || e.school}
                        </span>
                        <span className="text-[10px] text-white/25 hidden md:block">{formatDate(e.ts)}</span>
                      </div>
                    </div>
                  );
                })}
                {recent.length === 0 && (
                  <div className="px-6 py-16 text-center">
                    <p className="text-white/20 text-sm">No signups yet.</p>
                    <p className="text-white/15 text-xs mt-1">Share the link to start collecting.</p>
                  </div>
                )}
              </div>
            </div>

          </>
        )}
      </div>
    </div>
  );
}
