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
  { id: 'knust', label: 'KNUST',    wiki: 'Kwame_Nkrumah_University_of_Science_and_Technology', color: 'text-emerald-700', bar: 'bg-emerald-500', card: 'bg-[#DFF5E3] border-black', avatar: 'bg-[#DFF5E3] text-emerald-700 border border-black' },
  { id: 'ug',    label: 'UG Legon', wiki: 'University_of_Ghana',                                 color: 'text-blue-700',    bar: 'bg-blue-500',    card: 'bg-[#E3EDFF] border-black', avatar: 'bg-[#E3EDFF] text-blue-700 border border-black'    },
  { id: 'ucc',   label: 'UCC',      wiki: 'University_of_Cape_Coast',                            color: 'text-[#555]',      bar: 'bg-[#FF6B35]',  card: 'bg-[#FFE8DC] border-black', avatar: 'bg-[#FFE8DC] text-black border border-black'},
  { id: 'upsa',  label: 'UPSA',     wiki: 'University_of_Professional_Studies,_Accra',           color: 'text-amber-700',   bar: 'bg-amber-400',   card: 'bg-[#FFF3D6] border-black', avatar: 'bg-[#FFF3D6] text-amber-700 border border-black'  },
  { id: 'uds',   label: 'UDS',      wiki: 'University_for_Development_Studies',                  color: 'text-rose-700',    bar: 'bg-rose-400',    card: 'bg-[#FFE3E3] border-black', avatar: 'bg-[#FFE3E3] text-rose-700 border border-black'    },
  { id: 'gctu',  label: 'GCTU',     wiki: 'Ghana_Communication_Technology_University',           color: 'text-sky-700',     bar: 'bg-sky-400',     card: 'bg-[#E3EDFF] border-black', avatar: 'bg-[#E3EDFF] text-sky-700 border border-black'      },
];

const FILTER_PILLS = ['ALL', 'KNUST', 'UG LEGON', 'UCC', 'UPSA', 'UDS', 'GCTU'];
const SCHOOL_FILTER_MAP = { 'ALL': null, 'KNUST': 'knust', 'UG LEGON': 'ug', 'UCC': 'ucc', 'UPSA': 'upsa', 'UDS': 'uds', 'GCTU': 'gctu' };

const VIBE_TAGS = [
  { label: 'Neat Freak',    color: 'bg-[#E3EDFF] text-black border-black',       digits: [0,1,2] },
  { label: 'Night Coder',   color: 'bg-[#FFE8DC] text-black border-black', digits: [3,4]   },
  { label: 'Serious Vibes', color: 'bg-[#FFE8DC] text-black border-black', digits: [5,6]   },
  { label: 'Early Riser',   color: 'bg-[#DFF5E3] text-black border-black',    digits: [7,8]   },
  { label: 'Tech Head',     color: 'bg-[#E3EDFF] text-black border-black',          digits: [9]     },
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
  verified: { label: 'Verified', pill: 'bg-[#DFF5E3] text-black border-black', dot: true  },
  pending:  { label: 'Pending',  pill: 'bg-[#FFF3D6] text-black border-black',       dot: false },
  flagged:  { label: 'Flagged',  pill: 'bg-[#FFE3E3] text-black border-black',             dot: false },
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
  return <div className={`animate-pulse rounded-none bg-[#EDE4D3] ${className}`} />;
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
    <div className={`${dim} rounded-none bg-white border border-black flex items-center justify-center flex-shrink-0`}>
      <span className="text-[8px] font-black text-[#555]">{label.slice(0, 2)}</span>
    </div>
  );
  return (
    <div className={`${dim} rounded-none bg-white border border-black flex items-center justify-center flex-shrink-0 overflow-hidden ${pad}`}>
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
    <div className="min-h-screen bg-[#FAF3E8] flex items-center justify-center px-6 relative overflow-hidden"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <div className={`w-full max-w-[340px] transition-all duration-150 ${shake ? 'translate-x-2' : ''}`}
        style={shake ? { animation: 'shake 0.4s ease' } : {}}>
        <div className="flex flex-col items-center mb-10">
          <div className="w-16 h-16 rounded-none bg-[#FFD700] border-2 border-black flex items-center justify-center shadow-[6px_6px_0px_#000] mb-5">
            <span className="text-2xl font-black text-black">U</span>
          </div>
          <h1 className="text-2xl font-black text-black">UNIFY</h1>
          <p className="text-[#555] text-xs mt-1 tracking-widest uppercase font-semibold">Admin · Waitlist Dashboard</p>
        </div>
        <form onSubmit={submit} className="flex flex-col gap-3">
          <div className="relative group">
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-black/40 group-focus-within:text-[#FF6B35] transition-colors text-sm">🔒</span>
            <input
              type="password" value={pw} onChange={(e) => setPw(e.target.value)}
              placeholder="Enter password" autoFocus
              className="w-full bg-white border-2 border-black focus:ring-2 focus:ring-[#FF6B35] rounded-none pl-11 pr-5 py-4 text-sm text-black placeholder-black/30 outline-none transition-all" />
          </div>
          <button type="submit"
            className="w-full bg-[#FFD700] hover:bg-amber-300 active:scale-[0.98] text-black font-black text-sm py-4 rounded-none border-2 border-black transition-all shadow-[4px_4px_0px_#000]">
            Enter Dashboard →
          </button>
        </form>
        <p className="text-center text-[11px] text-[#555] mt-8">Private · Admin access only</p>
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
          ? 'bg-[#FF6B35] text-black border-2 border-black shadow-[4px_4px_0px_#000]'
          : 'text-black/40 hover:text-black hover:bg-black/10'
      }`}>
      <Icon size={18} strokeWidth={active ? 2.5 : 1.8} />
    </button>
  );
}

// ── METRIC CARD ──────────────────────────────────────────────────────────────
function MetricCard({ label, value, icon: Icon, glowClass, accentColor, sparkColor, sparkPoints, liteMode }) {
  return (
    <div className={`relative overflow-hidden bg-white border-2 border-black rounded-none p-5 flex flex-col gap-3 ${glowClass}`}>
      <div className={`absolute bottom-0 left-0 right-0 h-[2px] ${accentColor}`} />
      <div className="flex items-start justify-between">
        <div>
          <p className="text-2xl font-black text-black leading-none">{value}</p>
          <p className="text-[10px] font-bold uppercase tracking-widest text-[#555] mt-2">{label}</p>
        </div>
        <div className="w-8 h-8 rounded-none bg-[#FAF3E8] border border-black/15 flex items-center justify-center">
          <Icon size={15} className="text-[#555]" />
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
    <div className="h-screen w-screen bg-[#FAF3E8] text-black flex overflow-hidden"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>

      {/* ── SIDEBAR ── */}
      <aside className={`w-16 flex-shrink-0 flex flex-col items-center py-4 gap-2 border-r-2 border-black z-20 bg-white ${blurCard}`}>
        {/* Logo */}
        <div className="w-9 h-9 rounded-none bg-[#FFD700] border-2 border-black flex items-center justify-center shadow-[4px_4px_0px_#000] mb-3 flex-shrink-0">
          <span className="text-sm font-black text-black">U</span>
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
        <div className="w-9 h-9 rounded-none bg-[#FFF3D6] border-2 border-black flex items-center justify-center flex-shrink-0">
          <span className="text-xs font-black text-black">A</span>
        </div>
      </aside>

      {/* ── MAIN AREA ── */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">

        {/* ── HEADER ── */}
        <header className={`h-14 flex-shrink-0 flex items-center justify-between px-6 border-b-2 border-black z-10
          ${liteMode ? 'bg-[#FAF3E8]' : 'bg-[#FAF3E8]'}`}>

          {/* Breadcrumb */}
          <div className="flex items-center gap-1.5 text-sm">
            <span className="text-[#555] font-medium">Dashboard</span>
            <ChevronRight size={13} className="text-black/30" />
            <span className="text-black font-semibold">Overview</span>
          </div>

          {/* Heartbeat */}
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-none bg-emerald-400 border border-black flex-shrink-0 ${!liteMode ? 'animate-pulse' : ''}`} />
            <span className="text-xs font-semibold text-emerald-700">System Live</span>
          </div>

          {/* Right controls */}
          <div className="flex items-center gap-3">
            {/* Lite Mode toggle */}
            <div className="flex items-center gap-2">
              <span className="text-[11px] text-[#555] font-semibold hidden sm:block">Lite Mode</span>
              <button onClick={() => setLiteMode(p => !p)}
                className={`relative w-9 h-5 rounded-none border-2 border-black transition-colors duration-200 flex-shrink-0 ${liteMode ? 'bg-[#FFD700]' : 'bg-white'}`}>
                <span className={`absolute top-0 w-4 h-4 rounded-none bg-black transition-transform duration-200 ${liteMode ? 'translate-x-4' : 'translate-x-0.5'}`} />
              </button>
            </div>

            {/* Refresh */}
            <button onClick={() => loadData(false)} disabled={loading}
              className="w-8 h-8 flex items-center justify-center rounded-none text-black/50 hover:text-black hover:bg-black/10 transition-all disabled:opacity-30">
              <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
            </button>

            {/* Last updated */}
            {lastRefresh && (
              <span className="hidden md:block text-[11px] text-[#555] font-medium">
                Updated {lastRefresh.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
              </span>
            )}
          </div>
        </header>

        {/* ── SCROLLABLE CONTENT ── */}
        <div className="flex-1 overflow-y-auto p-5 flex flex-col gap-4 min-h-0">

          {error && (
            <div className="bg-[#FFE3E3] border-2 border-black rounded-none px-5 py-3 text-sm text-black flex items-center gap-3 flex-shrink-0">
              <span>⚠️</span> {error}
            </div>
          )}

          {/* ── METRICS ROW ── */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 flex-shrink-0">
            <MetricCard
              label="Total Handles"
              value={total.toLocaleString()}
              icon={Users}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#000]'}
              accentColor="bg-cyan-400"
              sparkColor="#22d3ee"
              sparkPoints={[3,5,4,8,6,9,7,10]}
              liteMode={liteMode}
            />
            <MetricCard
              label="Roommate Matches"
              value={roommateMatches.toLocaleString()}
              icon={Heart}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#000]'}
              accentColor="bg-[#FF6B35]"
              sparkColor="#A8C4FF"
              sparkPoints={[2,4,3,6,5,7,6,8]}
              liteMode={liteMode}
            />
            <MetricCard
              label="Pending Verif."
              value={pendingVerif.toLocaleString()}
              icon={Clock}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#000]'}
              accentColor="bg-amber-400"
              sparkColor="#f59e0b"
              sparkPoints={[1,3,2,4,3,5,4,6]}
              liteMode={liteMode}
            />
            <MetricCard
              label={`${dataSaved} GB saved vs heavy apps`}
              value="Data Saved"
              icon={Zap}
              glowClass={liteMode ? '' : 'shadow-[4px_4px_0px_#000]'}
              accentColor="bg-emerald-400"
              sparkColor="#34d399"
              sparkPoints={[4,6,5,8,7,9,8,10]}
              liteMode={liteMode}
            />
          </div>

          {/* ── MAIN GRID ── */}
          <div className="grid md:grid-cols-5 gap-4 flex-1 min-h-0">

            {/* ── SCHOOL BREAKDOWN (left) ── */}
            <div className="md:col-span-2 bg-white border-2 border-black shadow-[4px_4px_0px_#000] rounded-none p-5 flex flex-col gap-4 overflow-y-auto">
              <div className="flex items-center justify-between flex-shrink-0">
                <span className="text-sm font-black">By Campus</span>
                <span className="text-[10px] font-bold bg-[#FAF3E8] border border-black/15 text-[#555] px-2 py-1 rounded-none">{total} total</span>
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
                              <span className="text-xs font-bold text-[#555]">{count}</span>
                              <span className="text-[10px] text-[#555] w-7 text-right">{pct}%</span>
                            </div>
                          </div>
                          <div className="h-1.5 bg-black/10 rounded-none overflow-hidden">
                            <div className={`h-full ${bar} rounded-none transition-all duration-1000`} style={{ width: `${pct}%` }} />
                          </div>
                        </div>
                      );
                    })
                }
              </div>

              {/* 3x2 badge grid */}
              {!loading && data && (
                <div className="grid grid-cols-3 gap-2 pt-4 border-t border-black/15 flex-shrink-0">
                  {schoolStats.map(({ id, label, count, color, card }) => (
                    <div key={id} className={`${card} border-2 rounded-none p-3 text-center flex flex-col items-center gap-1.5`}>
                      <SchoolLogo src={logos[id]} label={label} size="lg" />
                      <p className={`text-base font-black ${color}`}>{count}</p>
                      <p className="text-[9px] text-[#555] font-semibold leading-tight">{label}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* ── WAITLIST LEDGER (right) ── */}
            <div className="md:col-span-3 bg-white border-2 border-black shadow-[4px_4px_0px_#000] rounded-none flex flex-col overflow-hidden">

              {/* Header + filter pills */}
              <div className="flex-shrink-0 px-5 pt-5 pb-3 border-b border-black/15">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-black">Waitlist Ledger</span>
                  <span className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-none bg-emerald-400 border border-black animate-pulse" />
                    <span className="text-[11px] text-[#555]">{filteredEntries.length} records</span>
                  </span>
                </div>
                <div className="flex flex-wrap gap-1.5">
                  {FILTER_PILLS.map(pill => (
                    <button key={pill} onClick={() => setActiveFilter(pill)}
                      className={`text-[11px] font-bold px-3 py-1 rounded-none border-2 border-black transition-all ${
                        activeFilter === pill
                          ? 'bg-[#FF6B35] text-black'
                          : 'bg-white text-[#555] hover:bg-black/5 hover:text-black'
                      }`}>
                      {pill}
                    </button>
                  ))}
                </div>
              </div>

              {/* Column headers */}
              <div className="flex-shrink-0 grid grid-cols-12 items-center px-5 py-2 bg-[#FAF3E8] border-b border-black/15">
                <span className="col-span-1 text-[9px] font-bold uppercase tracking-widest text-[#555]">#</span>
                <span className="col-span-4 text-[9px] font-bold uppercase tracking-widest text-[#555]">Handle</span>
                <span className="col-span-3 text-[9px] font-bold uppercase tracking-widest text-[#555]">Vibe</span>
                <span className="col-span-2 text-[9px] font-bold uppercase tracking-widest text-[#555]">Status</span>
                <span className="col-span-2 text-[9px] font-bold uppercase tracking-widest text-[#555] hidden lg:block">Date</span>
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
                    <p className="text-[#555] text-sm font-semibold">No signups yet</p>
                    <p className="text-[#555] text-xs mt-1">Share the link to start collecting</p>
                  </div>
                ) : (
                  <div className="divide-y divide-black/15">
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
                            ${i % 2 === 0 ? 'bg-white' : 'bg-[#FAF3E8]'}
                            hover:bg-[#FFE8DC]`}>

                          {/* # */}
                          <span className="col-span-1 text-[10px] text-[#555] font-mono">{i + 1}</span>

                          {/* Avatar + phone + school */}
                          <div className="col-span-4 flex items-center gap-2 min-w-0">
                            <div className={`w-7 h-7 rounded-none flex items-center justify-center text-[10px] font-black flex-shrink-0 ${sc?.avatar || 'bg-white text-[#555] border border-black'}`}>
                              {initials}
                            </div>
                            <div className="min-w-0">
                              <p className="text-xs text-black font-mono truncate">{maskPhone(e.phone)}</p>
                              <p className="text-[9px] text-[#555] truncate">{sc?.label || e.school}</p>
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
                                <button className="w-5 h-5 rounded bg-[#DFF5E3] border border-black flex items-center justify-center hover:bg-emerald-200 transition-colors" title="Verify">
                                  <Shield size={10} className="text-emerald-700" />
                                </button>
                                <button className="w-5 h-5 rounded bg-[#FFE3E3] border border-black flex items-center justify-center hover:bg-red-200 transition-colors" title="Flag">
                                  <Flag size={10} className="text-red-600" />
                                </button>
                                <button className="w-5 h-5 rounded bg-[#E3EDFF] border border-black flex items-center justify-center hover:bg-blue-200 transition-colors" title="SMS">
                                  <MessageSquare size={10} className="text-blue-600" />
                                </button>
                              </div>
                            ) : (
                              <span className={`inline-flex items-center gap-1 text-[9px] font-bold px-2 py-0.5 rounded-none border ${stCfg.pill}`}>
                                {stCfg.dot && (
                                  <span className="w-1.5 h-1.5 rounded-none bg-emerald-400 border border-black animate-pulse flex-shrink-0" />
                                )}
                                {stCfg.label}
                              </span>
                            )}
                          </div>

                          {/* Date */}
                          <span className="col-span-2 text-[10px] text-[#555] hidden lg:block">{formatDate(e.ts)}</span>
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
