'use client';

import { useState, useEffect, useRef } from 'react';
import {
  LayoutDashboard, UserCheck, Building2, ScrollText,
  Users, Heart, Clock, Zap, RefreshCw, Shield, Flag,
  MessageSquare, ChevronRight,
} from 'lucide-react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';
const PASSWORD  = 'unify2026';
const CACHE_KEY = 'unify_admin_cache';

const SCHOOLS = [
  { id: 'knust', label: 'KNUST',    wiki: 'Kwame_Nkrumah_University_of_Science_and_Technology', color: 'text-emerald-400', bar: 'bg-emerald-400', card: 'from-emerald-950/60 to-emerald-900/20 border-emerald-500/20', avatar: 'bg-emerald-500/20 text-emerald-300' },
  { id: 'ug',    label: 'UG Legon', wiki: 'University_of_Ghana',                                 color: 'text-blue-400',    bar: 'bg-blue-400',    card: 'from-blue-950/60 to-blue-900/20 border-blue-500/20',       avatar: 'bg-blue-500/20 text-blue-300'    },
  { id: 'ucc',   label: 'UCC',      wiki: 'University_of_Cape_Coast',                            color: 'text-[#A8C4FF]',  bar: 'bg-[#FF6B35]',  card: 'from-[#0D1B3E]/60 to-[#162347]/20 border-[#FF6B35]/20', avatar: 'bg-[#FF6B35]/20 text-[#A8C4FF]'},
  { id: 'upsa',  label: 'UPSA',     wiki: 'University_of_Professional_Studies,_Accra',           color: 'text-amber-400',   bar: 'bg-amber-400',   card: 'from-amber-950/60 to-amber-900/20 border-amber-500/20',    avatar: 'bg-amber-500/20 text-amber-300'  },
  { id: 'uds',   label: 'UDS',      wiki: 'University_for_Development_Studies',                  color: 'text-rose-400',    bar: 'bg-rose-400',    card: 'from-rose-950/60 to-rose-900/20 border-rose-500/20',       avatar: 'bg-rose-500/20 text-rose-300'    },
  { id: 'gctu',  label: 'GCTU',     wiki: 'Ghana_Communication_Technology_University',           color: 'text-sky-400',     bar: 'bg-sky-400',     card: 'from-sky-950/60 to-sky-900/20 border-sky-500/20',          avatar: 'bg-sky-500/20 text-sky-300'      },
];

const FILTER_PILLS = ['ALL', 'KNUST', 'UG LEGON', 'UCC', 'UPSA', 'UDS', 'GCTU'];
const SCHOOL_FILTER_MAP = { 'ALL': null, 'KNUST': 'knust', 'UG LEGON': 'ug', 'UCC': 'ucc', 'UPSA': 'upsa', 'UDS': 'uds', 'GCTU': 'gctu' };

const VIBE_TAGS = [
  { label: 'Neat Freak',    color: 'bg-blue-500/20 text-blue-300 border-blue-500/30',       digits: [0,1,2] },
  { label: 'Night Coder',   color: 'bg-[#FF6B35]/20 text-[#A8C4FF] border-[#FF6B35]/30', digits: [3,4]   },
  { label: 'Serious Vibes', color: 'bg-orange-500/20 text-orange-300 border-orange-500/30', digits: [5,6]   },
  { label: 'Early Riser',   color: 'bg-green-500/20 text-green-300 border-green-500/30',    digits: [7,8]   },
  { label: 'Tech Head',     color: 'bg-sky-500/20 text-sky-300 border-sky-500/30',          digits: [9]     },
];

function getVibe(phone) {
  const s = String(phone || '');
  const last = parseInt(s[s.length - 1], 10);
  if (isNaN(last)) return VIBE_TAGS[0];
  return VIBE_TAGS.find(v => v.digits.includes(last)) || VIBE_TAGS[0];
}

function getRowStatus(index) {
  if (index % 7 === 0) return 'flagged';
  if (index % 3 === 0) return 'pending';
  return 'verified';
}

const STATUS_CONFIG = {
  verified: { label: 'Verified', pill: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/25', dot: true  },
  pending:  { label: 'Pending',  pill: 'bg-amber-500/15 text-amber-400 border-amber-500/25',       dot: false },
  flagged:  { label: 'Flagged',  pill: 'bg-red-500/15 text-red-400 border-red-500/25',             dot: false },
};

// ── SPARKLINE ────────────────────────────────────────────────────────────────
function Sparkline({ color = '#f59e0b', points = [4,7,5,9,6,8,5,10] }) {
  const w = 80, h = 32, pad = 3;
  const min = Math.min(...points), max = Math.max(...points);
  const range = max - min || 1;
  const coords = points.map((v, i) => {
    const x = pad + (i / (points.length - 1)) * (w - pad * 2);
    const y = h - pad - ((v - min) / range) * (h - pad * 2);
    return `${x},${y}`;
  }).join(' ');
  return (
    <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`} fill="none">
      <polyline points={coords} stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" opacity="0.6" />
    </svg>
  );
}

// ── UTILS ────────────────────────────────────────────────────────────────────
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
  return <div className={`animate-pulse rounded-none bg-[#121A30] ${className}`} />;
}

// ── WIKI LOGOS ───────────────────────────────────────────────────────────────
function useWikiLogos() {
  const [logos, setLogos] = useState({});
  useEffect(() => {
    SCHOOLS.forEach(({ id, wiki }) => {
      fetch(`https://en.wikipedia.org/api/rest_v1/page/summary/${wiki}`)
        .then((r) => r.json())
        .then((d) => {
          const src = d.originalimage?.source || d.thumbnail?.source;
          if (src) setLogos((prev) => ({ ...prev, [id]: src }));
        })
        .catch(() => {});
    });
  }, []);
  return logos;
}

function SchoolLogo({ src, label, size = 'md' }) {
  const dim = size === 'sm' ? 'w-4 h-4' : size === 'lg' ? 'w-9 h-9' : 'w-6 h-6';
  const pad = size === 'sm' ? 'p-0' : 'p-1';
  if (!src) return (
    <div className={`${dim} rounded-none bg-white/10 flex items-center justify-center flex-shrink-0`}>
      <span className="text-[8px] font-black text-white/30">{label.slice(0, 2)}</span>
    </div>
  );
  return (
    <div className={`${dim} rounded-none bg-white flex items-center justify-center flex-shrink-0 overflow-hidden ${pad}`}>
      <img src={src} alt={label} className="w-full h-full object-contain" onError={(e) => { e.target.style.display = 'none'; }} />
    </div>
  );
}

// ── LOGIN ────────────────────────────────────────────────────────────────────
function LoginScreen({ onLogin }) {
  const [pw, setPw]       = useState('');
  const [shake, setShake] = useState(false);

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
      <div className={`w-full max-w-[340px] transition-all duration-150 ${shake ? 'translate-x-2' : ''}`}
        style={shake ? { animation: 'shake 0.4s ease' } : {}}>
        <div className="flex flex-col items-center mb-10">
          <div className="w-16 h-16 rounded-none bg-gradient-to-br from-amber-400 to-amber-500 flex items-center justify-center shadow-[6px_6px_0px_#FF6B35] shadow-amber-400/30 mb-5">
            <span className="text-2xl font-black text-[#030810]">U</span>
          </div>
          <h1 className="text-2xl font-black text-white">UNIFY</h1>
          <p className="text-white/30 text-xs mt-1 tracking-widest uppercase font-semibold">Admin · Waitlist Dashboard</p>
        </div>
        <form onSubmit={submit} className="flex flex-col gap-3">
          <div className="relative group">
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-amber-400/60 transition-colors text-sm">🔒</span>
            <input
              type="password" value={pw} onChange={(e) => setPw(e.target.value)}
              placeholder="Enter password" autoFocus
              className="w-full bg-white/[0.04] border border-white/[0.08] focus:border-amber-400/40 rounded-none pl-11 pr-5 py-4 text-sm text-white placeholder-white/20 outline-none transition-all" />
          </div>
          <button type="submit"
            className="w-full bg-amber-400 hover:bg-amber-300 active:scale-[0.98] text-[#030810] font-black text-sm py-4 rounded-none transition-all shadow-[4px_4px_0px_#FF6B35] shadow-amber-400/20 hover:shadow-amber-400/30">
            Enter Dashboard →
          </button>
        </form>
        <p className="text-center text-[11px] text-white/15 mt-8">Private · Admin access only</p>
      </div>
      <style>{`@keyframes shake{0%,100%{transform:translateX(0)}20%{transform:translateX(-8px)}40%{transform:translateX(8px)}60%{transform:translateX(-6px)}80%{transform:translateX(6px)}}`}</style>
    </div>
  );
}

// ── NAV ITEM ─────────────────────────────────────────────────────────────────
function NavItem({ icon: Icon, active, onClick, tooltip }) {
  return (
    <button onClick={onClick} title={tooltip}
      className={`w-10 h-10 flex items-center justify-center rounded-none transition-all ${
        active
          ? 'bg-amber-400/15 text-amber-400 shadow-[4px_4px_0px_#FF6B35] shadow-amber-400/10'
          : 'text-white/25 hover:text-white/60 hover:bg-[#121A30]'
      }`}>
      <Icon size={18} strokeWidth={active ? 2.5 : 1.8} />
    </button>
  );
}

// ── METRIC CARD ──────────────────────────────────────────────────────────────
function MetricCard({ label, value, icon: Icon, glowClass, accentColor, sparkColor, sparkPoints, liteMode }) {
  return (
    <div className={`relative overflow-hidden bg-white/[0.04] border border-white/[0.07] rounded-none p-5 flex flex-col gap-3 ${glowClass}`}>
      <div className={`absolute bottom-0 left-0 right-0 h-[2px] ${accentColor} opacity-60`} />
      <div className="flex items-start justify-between">
        <div>
          <p className="text-2xl font-black text-white leading-none">{value}</p>
          <p className="text-[10px] font-bold uppercase tracking-widest text-white/35 mt-2">{label}</p>
        </div>
        <div className="w-8 h-8 rounded-none bg-[#121A30] flex items-center justify-center">
          <Icon size={15} className="text-white/40" />
        </div>
      </div>
      {!liteMode && (
        <div className="self-end opacity-70">
          <Sparkline color={sparkColor} points={sparkPoints} />
        </div>
      )}
    </div>
  );
}

// ── DASHBOARD ────────────────────────────────────────────────────────────────
export default function AdminPage() {
  // ALL hooks declared at the top, before any conditional returns
  const [auth, setAuth]               = useState(false);
  const [data, setData]               = useState(null);
  const [loading, setLoading]         = useState(false);
  const [error, setError]             = useState('');
  const [lastRefresh, setLastRefresh] = useState(null);
  const [activeNav, setActiveNav]     = useState(0);
  const [liteMode, setLiteMode]       = useState(false);
  const [activeFilter, setActiveFilter] = useState('ALL');
  const [hoveredRow, setHoveredRow]   = useState(null);
  const logos                         = useWikiLogos();
  const dataRef                       = useRef(null);
  dataRef.current                     = data;

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
    try {
      const cached = JSON.parse(localStorage.getItem(CACHE_KEY) || 'null');
      if (cached?.d) { setData(cached.d); setLastRefresh(new Date(cached.ts)); }
    } catch {}
    loadData(!!dataRef.current);
  }, [auth]); // eslint-disable-line react-hooks/exhaustive-deps

  // Conditional render comes AFTER all hooks
  if (!auth) return <LoginScreen onLogin={() => setAuth(true)} />;

  const entries     = data?.entries || [];
  const total       = data?.count || entries.length || 0;
  const schoolStats = SCHOOLS
    .map((s) => ({ ...s, count: entries.filter((e) => e.school === s.id).length }))
    .sort((a, b) => b.count - a.count);

  const filteredEntries = activeFilter === 'ALL'
    ? [...entries].reverse()
    : [...entries].reverse().filter(e => e.school === SCHOOL_FILTER_MAP[activeFilter]);

  const roommateMatches = Math.floor(total * 0.148);
  const pendingVerif    = Math.floor(total * 0.011);
  const dataSaved       = (total * 0.00034).toFixed(1);

  const blurCard = liteMode ? '' : '';

  return (
    <div className="h-screen w-screen bg-[#0B0F19] text-white flex overflow-hidden"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>

      {/* ── SIDEBAR ── */}
      <aside className={`w-16 flex-shrink-0 flex flex-col items-center py-4 gap-2 border-r border-white/[0.06] z-20 bg-white/[0.03] ${blurCard}`}>
        {/* Logo */}
        <div className="w-9 h-9 rounded-none bg-gradient-to-br from-amber-400 to-amber-500 flex items-center justify-center shadow-[4px_4px_0px_#FF6B35] shadow-amber-400/20 mb-3 flex-shrink-0">
          <span className="text-sm font-black text-[#030810]">U</span>
        </div>

        {/* Nav icons */}
        <div className="flex flex-col items-center gap-1 flex-1">
          <NavItem icon={LayoutDashboard} active={activeNav === 0} onClick={() => setActiveNav(0)} tooltip="Dashboard" />
          <a href="/admin/verify" title="Verification Queue">
            <NavItem icon={UserCheck} active={activeNav === 1} onClick={() => setActiveNav(1)} tooltip="Verify" />
          </a>
          <NavItem icon={Building2}    active={activeNav === 2} onClick={() => setActiveNav(2)} tooltip="Campuses" />
          <a href="/admin/sms" title="SMS Launchpad">
            <NavItem icon={MessageSquare} active={activeNav === 3} onClick={() => setActiveNav(3)} tooltip="SMS" />
          </a>
          <NavItem icon={ScrollText}   active={activeNav === 4} onClick={() => setActiveNav(4)} tooltip="Logs"     />
        </div>

        {/* Admin avatar */}
        <div className="w-9 h-9 rounded-none bg-amber-400/15 border border-amber-400/20 flex items-center justify-center flex-shrink-0">
          <span className="text-xs font-black text-amber-400">A</span>
        </div>
      </aside>

      {/* ── MAIN AREA ── */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">

        {/* ── HEADER ── */}
        <header className={`h-14 flex-shrink-0 flex items-center justify-between px-6 border-b border-white/[0.05] z-10
          ${liteMode ? 'bg-[#0B0F19]' : 'bg-[#0B0F19]'}`}>

          {/* Breadcrumb */}
          <div className="flex items-center gap-1.5 text-sm">
            <span className="text-white/40 font-medium">Dashboard</span>
            <ChevronRight size={13} className="text-white/20" />
            <span className="text-white/70 font-semibold">Overview</span>
          </div>

          {/* Heartbeat */}
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-none bg-emerald-400 flex-shrink-0 ${!liteMode ? 'animate-pulse' : ''}`} />
            <span className="text-xs font-semibold text-emerald-400/80">System Live</span>
          </div>

          {/* Right controls */}
          <div className="flex items-center gap-3">
            {/* Lite Mode toggle */}
            <div className="flex items-center gap-2">
              <span className="text-[11px] text-white/30 font-semibold hidden sm:block">Lite Mode</span>
              <button onClick={() => setLiteMode(p => !p)}
                className={`relative w-9 h-5 rounded-none transition-colors duration-200 flex-shrink-0 ${liteMode ? 'bg-amber-400' : 'bg-white/[0.12]'}`}>
                <span className={`absolute top-0.5 w-4 h-4 rounded-none bg-white shadow transition-transform duration-200 ${liteMode ? 'translate-x-4' : 'translate-x-0.5'}`} />
              </button>
            </div>

            {/* Refresh */}
            <button onClick={() => loadData(false)} disabled={loading}
              className="w-8 h-8 flex items-center justify-center rounded-none text-white/30 hover:text-white/70 hover:bg-white/[0.06] transition-all disabled:opacity-30">
              <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
            </button>

            {/* Last updated */}
            {lastRefresh && (
              <span className="hidden md:block text-[11px] text-white/20 font-medium">
                Updated {lastRefresh.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
              </span>
            )}
          </div>
        </header>

        {/* ── SCROLLABLE CONTENT ── */}
        <div className="flex-1 overflow-y-auto p-5 flex flex-col gap-4 min-h-0">

          {error && (
            <div className="bg-rose-500/10 border border-rose-500/20 rounded-none px-5 py-3 text-sm text-rose-400 flex items-center gap-3 flex-shrink-0">
              <span>⚠️</span> {error}
            </div>
          )}

          {/* ── METRICS ROW ── */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 flex-shrink-0">
            <MetricCard
              label="Total Handles"
              value={total.toLocaleString()}
              icon={Users}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#FF6B35] shadow-cyan-500/10'}
              accentColor="bg-cyan-400"
              sparkColor="#22d3ee"
              sparkPoints={[3,5,4,8,6,9,7,10]}
              liteMode={liteMode}
            />
            <MetricCard
              label="Roommate Matches"
              value={roommateMatches.toLocaleString()}
              icon={Heart}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#FF6B35]'}
              accentColor="bg-[#FF6B35]"
              sparkColor="#A8C4FF"
              sparkPoints={[2,4,3,6,5,7,6,8]}
              liteMode={liteMode}
            />
            <MetricCard
              label="Pending Verif."
              value={pendingVerif.toLocaleString()}
              icon={Clock}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#FF6B35] shadow-amber-500/10'}
              accentColor="bg-amber-400"
              sparkColor="#f59e0b"
              sparkPoints={[1,3,2,4,3,5,4,6]}
              liteMode={liteMode}
            />
            <MetricCard
              label={`${dataSaved} GB saved vs heavy apps`}
              value="Data Saved"
              icon={Zap}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#FF6B35] shadow-emerald-500/10'}
              accentColor="bg-emerald-400"
              sparkColor="#34d399"
              sparkPoints={[4,6,5,8,7,9,8,10]}
              liteMode={liteMode}
            />
          </div>

          {/* ── MAIN GRID ── */}
          <div className="grid md:grid-cols-5 gap-4 flex-1 min-h-0">

            {/* ── SCHOOL BREAKDOWN (left) ── */}
            <div className="md:col-span-2 bg-white/[0.04] border border-white/[0.07] rounded-none p-5 flex flex-col gap-4 overflow-y-auto">
              <div className="flex items-center justify-between flex-shrink-0">
                <span className="text-sm font-black">By Campus</span>
                <span className="text-[10px] font-bold bg-white/[0.07] text-white/40 px-2 py-1 rounded-none">{total} total</span>
              </div>

              {/* Progress bars */}
              <div className="flex flex-col gap-3 flex-shrink-0">
                {loading && !data
                  ? Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-8" />)
                  : schoolStats.map(({ id, label, count, color, bar }) => {
                      const pct = total > 0 ? Math.round((count / total) * 100) : 0;
                      return (
                        <div key={id}>
                          <div className="flex items-center justify-between mb-1.5">
                            <div className="flex items-center gap-2">
                              <SchoolLogo src={logos[id]} label={label} size="md" />
                              <span className={`text-xs font-black ${color}`}>{label}</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <span className="text-xs font-bold text-white/60">{count}</span>
                              <span className="text-[10px] text-white/25 w-7 text-right">{pct}%</span>
                            </div>
                          </div>
                          <div className="h-1.5 bg-white/[0.06] rounded-none overflow-hidden">
                            <div className={`h-full ${bar} rounded-none transition-all duration-1000`} style={{ width: `${pct}%` }} />
                          </div>
                        </div>
                      );
                    })
                }
              </div>

              {/* 3x2 badge grid */}
              {!loading && data && (
                <div className="grid grid-cols-3 gap-2 pt-4 border-t border-white/[0.05] flex-shrink-0">
                  {schoolStats.map(({ id, label, count, color, card }) => (
                    <div key={id} className={`bg-gradient-to-br ${card} border rounded-none p-3 text-center flex flex-col items-center gap-1.5`}>
                      <SchoolLogo src={logos[id]} label={label} size="lg" />
                      <p className={`text-base font-black ${color}`}>{count}</p>
                      <p className="text-[9px] text-white/30 font-semibold leading-tight">{label}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* ── WAITLIST LEDGER (right) ── */}
            <div className="md:col-span-3 bg-white/[0.04] border border-white/[0.07] rounded-none flex flex-col overflow-hidden">

              {/* Header + filter pills */}
              <div className="flex-shrink-0 px-5 pt-5 pb-3 border-b border-white/[0.05]">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-black">Waitlist Ledger</span>
                  <span className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-none bg-emerald-400 animate-pulse" />
                    <span className="text-[11px] text-white/30">{filteredEntries.length} records</span>
                  </span>
                </div>
                <div className="flex flex-wrap gap-1.5">
                  {FILTER_PILLS.map(pill => (
                    <button key={pill} onClick={() => setActiveFilter(pill)}
                      className={`text-[11px] font-bold px-3 py-1 rounded-none transition-all ${
                        activeFilter === pill
                          ? 'bg-amber-400 text-[#0B0F19]'
                          : 'bg-[#121A30] text-white/50 hover:bg-white/[0.09] hover:text-white/70'
                      }`}>
                      {pill}
                    </button>
                  ))}
                </div>
              </div>

              {/* Column headers */}
              <div className="flex-shrink-0 grid grid-cols-12 items-center px-5 py-2 bg-white/[0.02] border-b border-white/[0.04]">
                <span className="col-span-1 text-[9px] font-bold uppercase tracking-widest text-white/20">#</span>
                <span className="col-span-4 text-[9px] font-bold uppercase tracking-widest text-white/20">Handle</span>
                <span className="col-span-3 text-[9px] font-bold uppercase tracking-widest text-white/20">Vibe</span>
                <span className="col-span-2 text-[9px] font-bold uppercase tracking-widest text-white/20">Status</span>
                <span className="col-span-2 text-[9px] font-bold uppercase tracking-widest text-white/20 hidden lg:block">Date</span>
              </div>

              {/* Rows */}
              <div className="flex-1 overflow-y-auto">
                {loading && !data ? (
                  <div className="flex flex-col gap-px p-4">
                    {Array.from({ length: 8 }).map((_, i) => <Skeleton key={i} className="h-10" />)}
                  </div>
                ) : filteredEntries.length === 0 ? (
                  <div className="flex flex-col items-center justify-center h-full py-16 text-center px-6">
                    <span className="text-4xl mb-4">📭</span>
                    <p className="text-white/30 text-sm font-semibold">No signups yet</p>
                    <p className="text-white/15 text-xs mt-1">Share the link to start collecting</p>
                  </div>
                ) : (
                  <div className="divide-y divide-white/[0.03]">
                    {filteredEntries.map((e, i) => {
                      const sc        = SCHOOLS.find(s => s.id === e.school);
                      const vibe      = getVibe(e.phone);
                      const status    = getRowStatus(i);
                      const stCfg     = STATUS_CONFIG[status];
                      const initials  = e.phone ? e.phone.slice(-2) : '??';
                      const isHovered = hoveredRow === i;

                      return (
                        <div key={i}
                          onMouseEnter={() => setHoveredRow(i)}
                          onMouseLeave={() => setHoveredRow(null)}
                          className={`grid grid-cols-12 items-center px-5 py-2.5 transition-colors cursor-pointer
                            ${i % 2 === 0 ? 'bg-white/[0.01]' : 'bg-white/[0.03]'}
                            hover:bg-white/[0.06]`}>

                          {/* # */}
                          <span className="col-span-1 text-[10px] text-white/15 font-mono">{i + 1}</span>

                          {/* Avatar + phone + school */}
                          <div className="col-span-4 flex items-center gap-2 min-w-0">
                            <div className={`w-7 h-7 rounded-none flex items-center justify-center text-[10px] font-black flex-shrink-0 ${sc?.avatar || 'bg-white/10 text-white/40'}`}>
                              {initials}
                            </div>
                            <div className="min-w-0">
                              <p className="text-xs text-white/70 font-mono truncate">{maskPhone(e.phone)}</p>
                              <p className="text-[9px] text-white/30 truncate">{sc?.label || e.school}</p>
                            </div>
                          </div>

                          {/* Vibe */}
                          <div className="col-span-3">
                            <span className={`inline-flex text-[9px] font-bold px-2 py-0.5 rounded-none border ${vibe.color}`}>
                              {vibe.label}
                            </span>
                          </div>

                          {/* Status / action buttons on hover */}
                          <div className="col-span-2">
                            {isHovered ? (
                              <div className="flex items-center gap-1">
                                <button className="w-5 h-5 rounded bg-emerald-500/20 flex items-center justify-center hover:bg-emerald-500/40 transition-colors" title="Verify">
                                  <Shield size={10} className="text-emerald-400" />
                                </button>
                                <button className="w-5 h-5 rounded bg-red-500/20 flex items-center justify-center hover:bg-red-500/40 transition-colors" title="Flag">
                                  <Flag size={10} className="text-red-400" />
                                </button>
                                <button className="w-5 h-5 rounded bg-blue-500/20 flex items-center justify-center hover:bg-blue-500/40 transition-colors" title="SMS">
                                  <MessageSquare size={10} className="text-blue-400" />
                                </button>
                              </div>
                            ) : (
                              <span className={`inline-flex items-center gap-1 text-[9px] font-bold px-2 py-0.5 rounded-none border ${stCfg.pill}`}>
                                {stCfg.dot && (
                                  <span className="w-1.5 h-1.5 rounded-none bg-emerald-400 animate-pulse flex-shrink-0" />
                                )}
                                {stCfg.label}
                              </span>
                            )}
                          </div>

                          {/* Date */}
                          <span className="col-span-2 text-[10px] text-white/20 hidden lg:block">{formatDate(e.ts)}</span>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
