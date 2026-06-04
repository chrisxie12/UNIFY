'use client';

import { useState, useEffect } from 'react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';
const PASSWORD  = 'unify2026';

const SCHOOLS = [
  { id: 'knust', label: 'KNUST',    color: 'text-emerald-400', ring: 'ring-emerald-400/30', bar: 'bg-emerald-400', glow: 'shadow-emerald-400/20', card: 'from-emerald-950/60 to-emerald-900/20 border-emerald-500/20' },
  { id: 'ug',    label: 'UG Legon', color: 'text-blue-400',    ring: 'ring-blue-400/30',    bar: 'bg-blue-400',    glow: 'shadow-blue-400/20',    card: 'from-blue-950/60 to-blue-900/20 border-blue-500/20' },
  { id: 'ucc',   label: 'UCC',      color: 'text-violet-400',  ring: 'ring-violet-400/30',  bar: 'bg-violet-400',  glow: 'shadow-violet-400/20',  card: 'from-violet-950/60 to-violet-900/20 border-violet-500/20' },
  { id: 'upsa',  label: 'UPSA',     color: 'text-amber-400',   ring: 'ring-amber-400/30',   bar: 'bg-amber-400',   glow: 'shadow-amber-400/20',   card: 'from-amber-950/60 to-amber-900/20 border-amber-500/20' },
  { id: 'uds',   label: 'UDS',      color: 'text-rose-400',    ring: 'ring-rose-400/30',    bar: 'bg-rose-400',    glow: 'shadow-rose-400/20',    card: 'from-rose-950/60 to-rose-900/20 border-rose-500/20' },
  { id: 'gctu',  label: 'GCTU',     color: 'text-sky-400',     ring: 'ring-sky-400/30',     bar: 'bg-sky-400',     glow: 'shadow-sky-400/20',     card: 'from-sky-950/60 to-sky-900/20 border-sky-500/20' },
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

function Skeleton({ className }) {
  return <div className={`animate-pulse rounded-xl bg-white/[0.05] ${className}`} />;
}

// ── LOGIN ────────────────────────────────────────────────────────────────────

function LoginScreen({ onLogin }) {
  const [pw, setPw]         = useState('');
  const [shake, setShake]   = useState(false);

  const submit = (e) => {
    e.preventDefault();
    if (pw === PASSWORD) { onLogin(); }
    else {
      setShake(true);
      setPw('');
      setTimeout(() => setShake(false), 600);
    }
  };

  return (
    <div className="min-h-screen bg-[#030810] flex items-center justify-center px-6 relative overflow-hidden"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>

      {/* background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-amber-400/[0.04] rounded-full blur-3xl pointer-events-none" />

      <div className={`w-full max-w-[340px] transition-all duration-150 ${shake ? 'translate-x-2' : ''}`}
        style={shake ? { animation: 'shake 0.4s ease' } : {}}>

        {/* logo */}
        <div className="flex flex-col items-center mb-10">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-amber-400 to-amber-500 flex items-center justify-center shadow-2xl shadow-amber-400/30 mb-5">
            <span className="text-2xl font-black text-[#030810]">U</span>
          </div>
          <h1 className="text-2xl font-black text-white">UNIFY</h1>
          <p className="text-white/30 text-xs mt-1 tracking-widest uppercase font-semibold">Admin · Waitlist Dashboard</p>
        </div>

        <form onSubmit={submit} className="flex flex-col gap-3">
          <div className={`relative group`}>
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-amber-400/60 transition-colors text-sm">🔒</span>
            <input
              type="password"
              value={pw}
              onChange={(e) => setPw(e.target.value)}
              placeholder="Enter password"
              autoFocus
              className="w-full bg-white/[0.04] border border-white/[0.08] focus:border-amber-400/40 rounded-2xl pl-11 pr-5 py-4 text-sm text-white placeholder-white/20 outline-none transition-all"
            />
          </div>

          <button type="submit"
            className="w-full bg-amber-400 hover:bg-amber-300 active:scale-[0.98] text-[#030810] font-black text-sm py-4 rounded-2xl transition-all shadow-lg shadow-amber-400/20 hover:shadow-amber-400/30">
            Enter Dashboard →
          </button>
        </form>

        <p className="text-center text-[11px] text-white/15 mt-8">Private · Admin access only</p>
      </div>

      <style>{`@keyframes shake{0%,100%{transform:translateX(0)}20%{transform:translateX(-8px)}40%{transform:translateX(8px)}60%{transform:translateX(-6px)}80%{transform:translateX(6px)}}`}</style>
    </div>
  );
}

// ── DASHBOARD ────────────────────────────────────────────────────────────────

export default function AdminPage() {
  const [auth, setAuth]             = useState(false);
  const [data, setData]             = useState(null);
  const [loading, setLoading]       = useState(false);
  const [error, setError]           = useState('');
  const [lastRefresh, setLastRefresh] = useState(null);

  const CACHE_KEY = 'unify_admin_cache';

  const normalise = (d) => {
    d.entries = (d.entries || []).map((e) => ({
      phone:  String(e.phone  || ''),
      school: String(e.school || ''),
      ts:     String(e.ts     || ''),
    }));
    return d;
  };

  const loadData = (background = false) => {
    if (!background) setLoading(true);
    setError('');
    fetch(`${SHEET_URL}?action=all&ts=${Date.now()}`)
      .then((r) => r.text())
      .then((text) => {
        const d = normalise(JSON.parse(text));
        setData(d);
        setLastRefresh(new Date());
        try { localStorage.setItem(CACHE_KEY, JSON.stringify({ d, ts: Date.now() })); } catch {}
      })
      .catch((err) => { if (!background) setError('Could not load data. ' + err.message); })
      .finally(() => { if (!background) setLoading(false); });
  };

  useEffect(() => {
    if (!auth) return;
    // show cached data instantly
    try {
      const cached = JSON.parse(localStorage.getItem(CACHE_KEY) || 'null');
      if (cached?.d) { setData(cached.d); setLastRefresh(new Date(cached.ts)); }
    } catch {}
    // then refresh in background
    loadData(!!data);
  }, [auth]);

  if (!auth) return <LoginScreen onLogin={() => setAuth(true)} />;

  const entries     = data?.entries || [];
  const total       = data?.count   || 0;
  const recent      = [...entries].reverse().slice(0, 100);
  const schoolStats = SCHOOLS
    .map((s) => ({ ...s, count: entries.filter((e) => e.school === s.id).length }))
    .sort((a, b) => b.count - a.count);
  const topSchool   = schoolStats[0];
  const today       = entries.filter((e) => {
    try { return new Date(e.ts).toDateString() === new Date().toDateString(); } catch { return false; }
  }).length;

  return (
    <div className="min-h-screen bg-[#030810] text-white"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>

      {/* ── TOPBAR ── */}
      <div className="sticky top-0 z-20 border-b border-white/[0.05] bg-[#030810]/90 backdrop-blur-xl">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-7 h-7 rounded-lg bg-amber-400 flex items-center justify-center flex-shrink-0">
              <span className="text-[11px] font-black text-[#030810]">U</span>
            </div>
            <span className="font-black text-sm">UNIFY</span>
            <span className="text-white/20 text-xs">/</span>
            <span className="text-white/40 text-xs font-medium">Admin</span>
          </div>
          <div className="flex items-center gap-3">
            {lastRefresh && (
              <span className="hidden md:block text-[11px] text-white/20">
                {lastRefresh.toLocaleTimeString()}
              </span>
            )}
            <button onClick={loadData} disabled={loading}
              className="flex items-center gap-1.5 text-xs font-semibold text-white/35 hover:text-white border border-white/[0.07] hover:border-white/20 px-3 py-1.5 rounded-lg transition-all disabled:opacity-30">
              <span className={loading ? 'animate-spin inline-block' : ''}>↻</span>
              <span>{loading ? 'Loading' : 'Refresh'}</span>
            </button>
            <a href="/" className="text-xs text-white/25 hover:text-white/60 transition-colors">← Site</a>
          </div>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-6 py-8">

        {error && (
          <div className="mb-6 bg-rose-500/10 border border-rose-500/20 rounded-2xl px-5 py-4 text-sm text-rose-400 flex items-center gap-3">
            <span>⚠️</span> {error}
          </div>
        )}

        {/* ── STAT CARDS ── */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">

          {/* total — hero card */}
          <div className="col-span-2 relative overflow-hidden bg-gradient-to-br from-amber-950/80 to-[#030810] border border-amber-500/20 rounded-2xl p-6 shadow-xl shadow-amber-400/5">
            <div className="absolute top-0 right-0 w-48 h-48 bg-amber-400/[0.06] rounded-full blur-3xl -translate-y-1/2 translate-x-1/4 pointer-events-none" />
            {loading && !data ? <Skeleton className="h-12 w-32 mb-2" /> : (
              <p className="text-5xl font-black tracking-tight">{total.toLocaleString()}</p>
            )}
            <p className="text-xs font-bold uppercase tracking-widest text-amber-400/70 mt-2">Total Signups</p>
            <p className="text-white/25 text-xs mt-1">across all campuses</p>
            <div className="absolute bottom-4 right-5 text-4xl opacity-10">🎓</div>
          </div>

          {/* today */}
          <div className="relative overflow-hidden bg-white/[0.03] border border-white/[0.07] rounded-2xl p-5">
            {loading && !data ? <Skeleton className="h-8 w-16 mb-2" /> : (
              <p className="text-3xl font-black">{today}</p>
            )}
            <p className="text-[10px] font-bold uppercase tracking-widest text-white/30 mt-2">Today</p>
            <p className="text-white/20 text-xs mt-0.5">{new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}</p>
          </div>

          {/* top school */}
          <div className={`relative overflow-hidden bg-gradient-to-br border rounded-2xl p-5 ${topSchool?.card || 'from-white/5 to-transparent border-white/10'}`}>
            {loading && !data ? <Skeleton className="h-8 w-20 mb-2" /> : (
              <p className={`text-2xl font-black ${topSchool?.color || 'text-white'}`}>{topSchool?.label || '—'}</p>
            )}
            <p className="text-[10px] font-bold uppercase tracking-widest text-white/30 mt-2">Top School</p>
            <p className="text-white/20 text-xs mt-0.5">{topSchool?.count || 0} signups</p>
          </div>
        </div>

        {/* ── MAIN GRID ── */}
        <div className="grid md:grid-cols-5 gap-4">

          {/* school breakdown — left */}
          <div className="md:col-span-2 bg-white/[0.02] border border-white/[0.06] rounded-2xl p-6">
            <p className="text-sm font-black mb-1">By School</p>
            <p className="text-xs text-white/25 mb-6">Signup distribution</p>

            {loading && !data ? (
              <div className="flex flex-col gap-4">
                {[1,2,3,4,5,6].map(i => <Skeleton key={i} className="h-8" />)}
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {schoolStats.map(({ id, label, count, color, bar, card, ring }) => {
                  const pct = total > 0 ? Math.round((count / total) * 100) : 0;
                  return (
                    <div key={id}>
                      <div className="flex items-center justify-between mb-1.5">
                        <span className={`text-xs font-black ${color}`}>{label}</span>
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-bold text-white/60">{count}</span>
                          <span className="text-[10px] text-white/25 w-7 text-right">{pct}%</span>
                        </div>
                      </div>
                      <div className="h-1.5 bg-white/[0.06] rounded-full overflow-hidden">
                        <div className={`h-full ${bar} rounded-full transition-all duration-1000`}
                          style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            )}

            {/* school grid badges */}
            {!loading && data && (
              <div className="grid grid-cols-3 gap-2 mt-6 pt-5 border-t border-white/[0.05]">
                {schoolStats.map(({ id, label, count, color, card }) => (
                  <div key={id} className={`bg-gradient-to-br ${card} border rounded-xl p-3 text-center`}>
                    <p className={`text-lg font-black ${color}`}>{count}</p>
                    <p className="text-[9px] text-white/30 font-semibold mt-0.5">{label}</p>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* recent entries — right */}
          <div className="md:col-span-3 bg-white/[0.02] border border-white/[0.06] rounded-2xl overflow-hidden flex flex-col">
            <div className="px-6 py-4 border-b border-white/[0.05] flex items-center justify-between flex-shrink-0">
              <div>
                <p className="text-sm font-black">Recent Signups</p>
                <p className="text-xs text-white/25 mt-0.5">Newest first · last {Math.min(recent.length, 100)}</p>
              </div>
              <div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            </div>

            {/* col headers */}
            <div className="px-6 py-2.5 grid grid-cols-12 border-b border-white/[0.04] bg-white/[0.01] flex-shrink-0">
              <span className="col-span-1 text-[10px] font-bold uppercase tracking-widest text-white/20">#</span>
              <span className="col-span-5 text-[10px] font-bold uppercase tracking-widest text-white/20">Phone</span>
              <span className="col-span-3 text-[10px] font-bold uppercase tracking-widest text-white/20">School</span>
              <span className="col-span-3 text-[10px] font-bold uppercase tracking-widest text-white/20 hidden md:block">Date</span>
            </div>

            <div className="overflow-y-auto flex-1" style={{ maxHeight: 460 }}>
              {loading && !data ? (
                <div className="flex flex-col gap-px p-4">
                  {Array.from({ length: 8 }).map((_, i) => (
                    <Skeleton key={i} className="h-10" />
                  ))}
                </div>
              ) : recent.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-20 text-center px-6">
                  <span className="text-4xl mb-4">📭</span>
                  <p className="text-white/30 text-sm font-semibold">No signups yet</p>
                  <p className="text-white/15 text-xs mt-1">Share the link to start collecting</p>
                </div>
              ) : (
                <div className="divide-y divide-white/[0.03]">
                  {recent.map((e, i) => {
                    const sc = SCHOOLS.find((s) => s.id === e.school);
                    return (
                      <div key={i} className="px-6 py-3 grid grid-cols-12 items-center hover:bg-white/[0.02] transition-colors group">
                        <span className="col-span-1 text-[11px] text-white/15 font-mono">{total - i}</span>
                        <span className="col-span-5 text-sm text-white/70 font-mono group-hover:text-white/90 transition-colors">
                          {maskPhone(e.phone)}
                        </span>
                        <span className="col-span-3">
                          <span className={`text-[10px] font-black px-2 py-0.5 rounded-full bg-gradient-to-r border ${sc?.card || 'from-white/5 to-transparent border-white/10'} ${sc?.color || 'text-white/40'}`}>
                            {sc?.label || e.school}
                          </span>
                        </span>
                        <span className="col-span-3 text-[11px] text-white/20 hidden md:block">{formatDate(e.ts)}</span>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>

        <p className="text-center text-[11px] text-white/10 mt-8">UNIFY Admin · {new Date().getFullYear()} · Ghana 🇬🇭</p>
      </div>
    </div>
  );
}
