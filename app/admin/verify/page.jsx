'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { ArrowLeft, ChevronDown, Clock, Users, CheckCircle, XCircle, SkipForward } from 'lucide-react';
import Link from 'next/link';

const MOCK_QUEUE = [
  { id: 1,  name: 'Akosua Mensah',    school: 'KNUST',    program: 'BSc Computer Science',       hs: 'Aburi Girls',        year: 2024, vibe: ['Night Coder','Neat Freak'],    phone: '0551••••234', status: 'pending', imgBg: 'from-emerald-900 to-emerald-800' },
  { id: 2,  name: 'Kwaku Boateng',    school: 'UG Legon', program: 'BA Economics',                hs: 'Prempeh College',    year: 2024, vibe: ['Serious Vibes'],              phone: '0241••••891', status: 'pending', imgBg: 'from-blue-900 to-blue-800' },
  { id: 3,  name: 'Ama Serwaa',       school: 'UCC',      program: 'BSc Nursing',                 hs: 'Wesley Girls',       year: 2024, vibe: ['Early Riser','Study First'],   phone: '0271••••567', status: 'pending', imgBg: 'from-violet-900 to-violet-800' },
  { id: 4,  name: 'Yaw Darko',        school: 'UPSA',     program: 'BSc Accounting',              hs: 'Mfantsipim',         year: 2023, vibe: ['Tech Head'],                  phone: '0501••••123', status: 'pending', imgBg: 'from-amber-900 to-amber-800' },
  { id: 5,  name: 'Efua Asante',      school: 'KNUST',    program: 'BSc Electrical Engineering',  hs: 'Holy Child School',  year: 2024, vibe: ['Neat Freak'],                phone: '0209••••456', status: 'pending', imgBg: 'from-rose-900 to-rose-800' },
  { id: 6,  name: 'Kofi Appiah',      school: 'UG Legon', program: 'LLB Law',                     hs: 'Achimota School',    year: 2024, vibe: ['Night Coder','Tech Head'],    phone: '0556••••789', status: 'pending', imgBg: 'from-sky-900 to-sky-800' },
  { id: 7,  name: 'Abena Osei',       school: 'UCC',      program: 'BSc Education',               hs: "St. Augustine's",    year: 2023, vibe: ['Early Riser'],               phone: '0247••••321', status: 'pending', imgBg: 'from-teal-900 to-teal-800' },
  { id: 8,  name: 'Nana Adjei',       school: 'UDS',      program: 'BSc Agriculture',             hs: 'Navrongo SHS',       year: 2024, vibe: ['Serious Vibes','Study First'], phone: '0541••••654', status: 'pending', imgBg: 'from-orange-900 to-orange-800' },
  { id: 9,  name: 'Adwoa Frimpong',   school: 'GCTU',     program: 'BSc Telecom Engineering',     hs: 'Kumasi Girls',       year: 2024, vibe: ['Tech Head','Night Coder'],   phone: '0202••••987', status: 'pending', imgBg: 'from-indigo-900 to-indigo-800' },
  { id: 10, name: 'Kwame Asare',      school: 'KNUST',    program: 'BSc Mechanical Engineering',  hs: 'Opoku Ware',         year: 2023, vibe: ['Neat Freak','Early Riser'],  phone: '0244••••111', status: 'pending', imgBg: 'from-cyan-900 to-cyan-800' },
];

const VIBE_COLORS = {
  'Night Coder':   'bg-purple-500/20 text-purple-300 border-purple-500/30',
  'Neat Freak':    'bg-blue-500/20 text-blue-300 border-blue-500/30',
  'Serious Vibes': 'bg-orange-500/20 text-orange-300 border-orange-500/30',
  'Early Riser':   'bg-green-500/20 text-green-300 border-green-500/30',
  'Study First':   'bg-pink-500/20 text-pink-300 border-pink-500/30',
  'Tech Head':     'bg-sky-500/20 text-sky-300 border-sky-500/30',
};

const SCHOOL_COLORS = {
  'KNUST':    'bg-emerald-500/30 text-emerald-300',
  'UG Legon': 'bg-blue-500/30 text-blue-300',
  'UCC':      'bg-violet-500/30 text-violet-300',
  'UPSA':     'bg-amber-500/30 text-amber-300',
  'UDS':      'bg-orange-500/30 text-orange-300',
  'GCTU':     'bg-indigo-500/30 text-indigo-300',
};

const SCHOOL_DOT_COLORS = {
  'KNUST':    'bg-emerald-400',
  'UG Legon': 'bg-blue-400',
  'UCC':      'bg-violet-400',
  'UPSA':     'bg-amber-400',
  'UDS':      'bg-orange-400',
  'GCTU':     'bg-indigo-400',
};

const SCHOOLS = ['KNUST', 'UG Legon', 'UCC', 'UPSA', 'UDS', 'GCTU'];

function getInitials(name) {
  return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
}

export default function VerifyPage() {
  const [filterSchool, setFilterSchool] = useState(null);
  const [actions, setActions] = useState({});
  const [flash, setFlash] = useState(null);
  const [flashVisible, setFlashVisible] = useState(false);
  const [panelKey, setPanelKey] = useState(0);
  const [panelOpacity, setPanelOpacity] = useState(1);
  const [actionTimes, setActionTimes] = useState([]);
  const lastActionTimeRef = useRef(Date.now());
  const [showDropdown, setShowDropdown] = useState(false);
  const [complete, setComplete] = useState(false);

  // Magnifier state
  const docRef = useRef(null);
  const [magnifier, setMagnifier] = useState(null);

  const filteredQueue = filterSchool
    ? MOCK_QUEUE.filter(s => s.school === filterSchool)
    : MOCK_QUEUE;

  const pendingQueue = filteredQueue.filter(s => !actions[s.id]);
  const currentStudent = pendingQueue[0] || null;

  const approvedCount = Object.values(actions).filter(a => a === 'approved').length;
  const flaggedCount  = Object.values(actions).filter(a => a === 'flagged').length;
  const skippedCount  = Object.values(actions).filter(a => a === 'skipped').length;
  const totalVerified = approvedCount + flaggedCount;
  const progress = MOCK_QUEUE.length > 0 ? (totalVerified / MOCK_QUEUE.length) : 0;

  const avgTime = actionTimes.length > 0
    ? (actionTimes.slice(-5).reduce((a, b) => a + b, 0) / Math.min(actionTimes.length, 5) / 1000).toFixed(1)
    : null;

  const recordTime = useCallback(() => {
    const now = Date.now();
    const elapsed = now - lastActionTimeRef.current;
    lastActionTimeRef.current = now;
    setActionTimes(prev => [...prev, elapsed]);
  }, []);

  const advance = useCallback(() => {
    setPanelOpacity(0);
    setTimeout(() => {
      setPanelKey(k => k + 1);
      setPanelOpacity(1);
    }, 200);
  }, []);

  const doAction = useCallback((action) => {
    if (!currentStudent) return;
    recordTime();
    setActions(prev => ({ ...prev, [currentStudent.id]: action }));

    if (action === 'approved' || action === 'flagged') {
      setFlash(action === 'approved' ? 'approve' : 'flag');
      setFlashVisible(true);
      setTimeout(() => setFlashVisible(false), 600);
    }
    advance();
  }, [currentStudent, recordTime, advance]);

  // Queue exhaustion check
  useEffect(() => {
    if (filteredQueue.length > 0 && pendingQueue.length === 0 && Object.keys(actions).length > 0) {
      setComplete(true);
    }
  }, [filteredQueue.length, pendingQueue.length, actions]);

  // Keyboard listener
  useEffect(() => {
    const handler = (e) => {
      if (e.code === 'Space') {
        e.preventDefault();
        doAction('approved');
      } else if (e.code === 'Backspace') {
        e.preventDefault();
        doAction('flagged');
      } else if (e.code === 'ArrowRight') {
        e.preventDefault();
        doAction('skipped');
      }
    };
    document.addEventListener('keydown', handler);
    return () => document.removeEventListener('keydown', handler);
  }, [doAction]);

  // Magnifier handlers
  const handleMouseMove = useCallback((e) => {
    if (!docRef.current) return;
    const rect = docRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    setMagnifier({ x, y, rectW: rect.width, rectH: rect.height });
  }, []);

  const handleMouseLeave = useCallback(() => {
    setMagnifier(null);
  }, []);

  const resetAll = () => {
    setComplete(false);
    setActions({});
    setFilterSchool(null);
    setPanelKey(k => k + 1);
    setActionTimes([]);
    lastActionTimeRef.current = Date.now();
  };

  if (complete) {
    return (
      <div className="h-screen w-screen overflow-hidden bg-[#0B0F19] flex flex-col items-center justify-center gap-6">
        <div className="text-6xl">🎉</div>
        <h1 className="text-3xl font-bold text-white">Queue Complete!</h1>
        <p className="text-white/50 text-sm">All students in the current filter have been processed.</p>
        <div className="flex gap-6 mt-4">
          <StatCard label="Approved" value={approvedCount} color="text-emerald-400" />
          <StatCard label="Flagged"  value={flaggedCount}  color="text-red-400" />
          <StatCard label="Skipped"  value={skippedCount}  color="text-amber-400" />
          {avgTime && <StatCard label="Avg Time" value={`${avgTime}s`} color="text-sky-400" />}
        </div>
        <div className="flex gap-3 mt-4">
          <button
            onClick={resetAll}
            className="px-6 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-400 text-white font-medium transition-all duration-200"
          >
            Reset Queue
          </button>
          <Link href="/admin" className="px-6 py-2 rounded-lg bg-white/[0.08] hover:bg-white/[0.12] text-white font-medium transition-all duration-200">
            Back to Admin
          </Link>
        </div>
      </div>
    );
  }

  const nextStudents = pendingQueue.slice(1, 4);

  return (
    <div className="h-screen w-screen overflow-hidden bg-[#0B0F19] flex flex-col">

      {/* Flash Overlay */}
      {flashVisible && flash && (
        <div className={`fixed inset-0 z-50 flex items-center justify-center pointer-events-none ${flash === 'approve' ? 'bg-emerald-500/20' : 'bg-red-500/15'}`}>
          <div
            className="text-9xl font-bold"
            style={{ animation: 'flashPop 0.6s ease forwards' }}
          >
            {flash === 'approve'
              ? <span className="text-emerald-400">✓</span>
              : <span className="text-red-400">✗</span>
            }
          </div>
        </div>
      )}

      <style>{`
        @keyframes flashPop {
          0%   { transform: scale(0.5); opacity: 0; }
          50%  { transform: scale(1.2); opacity: 1; }
          100% { transform: scale(1);   opacity: 0; }
        }
      `}</style>

      {/* POWER BAR */}
      <div className="h-14 flex-shrink-0 bg-[#0B0F19]/80 backdrop-blur border-b border-white/[0.06] flex items-center px-4 gap-4 z-10">
        {/* Left */}
        <div className="flex items-center gap-3 min-w-0 flex-shrink-0">
          <Link href="/admin" className="flex items-center gap-1 text-white/50 hover:text-white transition-colors text-sm">
            <ArrowLeft size={14} />
            <span>Back</span>
          </Link>
          <span className="text-white/20">|</span>
          <span className="text-white font-semibold text-sm whitespace-nowrap">Verification Queue</span>
        </div>

        {/* Center — Progress */}
        <div className="flex-1 flex items-center gap-3 max-w-xs mx-auto">
          <span className="text-white/40 text-xs whitespace-nowrap">{totalVerified} / {MOCK_QUEUE.length} verified</span>
          <div className="flex-1 h-1.5 rounded-full bg-white/[0.06] overflow-hidden">
            <div
              className="h-full bg-emerald-400 rounded-full shadow-[0_0_6px_rgba(52,211,153,0.6)] transition-all duration-500"
              style={{ width: `${progress * 100}%` }}
            />
          </div>
        </div>

        {/* Right */}
        <div className="flex items-center gap-3 ml-auto flex-shrink-0">
          {avgTime && (
            <div className="flex items-center gap-1 text-white/40 text-xs">
              <Clock size={12} />
              <span>Avg: {avgTime}s</span>
            </div>
          )}

          {/* School Filter */}
          <div className="relative">
            <button
              onClick={() => setShowDropdown(d => !d)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-white/[0.06] hover:bg-white/[0.10] text-white/60 text-xs transition-all duration-200"
            >
              <span>{filterSchool || 'All Schools'}</span>
              <ChevronDown size={12} />
            </button>
            {showDropdown && (
              <div className="absolute right-0 top-full mt-1 w-36 rounded-lg bg-[#1a1f2e] border border-white/[0.08] overflow-hidden z-20 shadow-xl">
                <button
                  onClick={() => { setFilterSchool(null); setShowDropdown(false); setComplete(false); }}
                  className="w-full text-left px-3 py-2 text-xs text-white/60 hover:bg-white/[0.06] transition-colors"
                >
                  All Schools
                </button>
                {SCHOOLS.map(s => (
                  <button
                    key={s}
                    onClick={() => { setFilterSchool(s); setShowDropdown(false); setComplete(false); }}
                    className="w-full text-left px-3 py-2 text-xs text-white/60 hover:bg-white/[0.06] transition-colors"
                  >
                    {s}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Queue counter */}
          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-white/[0.04] border border-white/[0.06]">
            <Users size={12} className="text-white/30" />
            <span className="text-white/50 text-xs font-medium">{pendingQueue.length} left</span>
          </div>
        </div>
      </div>

      {/* SPLIT WORKSPACE */}
      <div className="flex-1 flex overflow-hidden">

        {/* LEFT PANEL — 60% */}
        <div className="w-[60%] flex flex-col bg-white/[0.03] border-r border-white/[0.06]">
          {/* Label */}
          <div className="flex-shrink-0 px-6 py-3 border-b border-white/[0.06] flex items-center justify-between">
            <span className="text-white/40 text-xs font-medium uppercase tracking-wider">ID / Placement Document</span>
            {currentStudent && (
              <span className="text-white/60 text-sm font-medium">{currentStudent.name}</span>
            )}
          </div>

          {/* Document area */}
          <div className="flex-1 relative p-5 flex flex-col overflow-hidden">
            {currentStudent ? (
              <div
                ref={docRef}
                className={`relative flex-1 rounded-xl overflow-hidden bg-gradient-to-br ${currentStudent.imgBg} cursor-crosshair select-none`}
                onMouseMove={handleMouseMove}
                onMouseLeave={handleMouseLeave}
              >
                {/* Decorative elements */}
                <div className="absolute top-0 right-0 w-32 h-32 rounded-full bg-white/5 -translate-y-16 translate-x-16" />
                <div className="absolute bottom-0 left-0 w-48 h-48 rounded-full bg-black/20 translate-y-24 -translate-x-24" />
                <div className="absolute top-1/2 left-1/2 w-64 h-64 rounded-full border border-white/5 -translate-x-1/2 -translate-y-1/2" />

                {/* Document content */}
                <div className="absolute inset-0 flex flex-col p-8 text-white overflow-hidden">
                  {/* Header */}
                  <div className="relative flex items-start gap-4 mb-5">
                    <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center border-2 border-white/30 flex-shrink-0">
                      <span className="text-lg font-bold">GH</span>
                    </div>
                    <div className="flex-1">
                      <div className="text-white font-bold text-sm tracking-widest uppercase">Ghana Education Service</div>
                      <div className="text-white/70 text-xs mt-0.5 tracking-wider">WASSCE / PLACEMENT LETTER</div>
                      <div className="text-white/50 text-xs mt-0.5">Academic Year {currentStudent.year - 1}/{currentStudent.year}</div>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <div className="text-white/40 text-xs">REF: GES/{currentStudent.year}/{String(currentStudent.id).padStart(5,'0')}</div>
                      <div className="text-white/40 text-xs mt-1">DATE: {new Date().toLocaleDateString('en-GB')}</div>
                    </div>
                  </div>

                  {/* Divider */}
                  <div className="relative border-t border-white/20 mb-5" />

                  {/* Body */}
                  <div className="relative flex-1">
                    <div className="text-white/50 text-xs uppercase tracking-wider mb-1">Student Name</div>
                    <div className="text-white text-2xl font-bold mb-5">{currentStudent.name}</div>

                    <div className="grid grid-cols-2 gap-x-6 gap-y-4 mb-5">
                      <div>
                        <div className="text-white/40 text-xs uppercase tracking-wider mb-1">Programme</div>
                        <div className="text-white font-semibold text-sm">{currentStudent.program}</div>
                      </div>
                      <div>
                        <div className="text-white/40 text-xs uppercase tracking-wider mb-1">Institution</div>
                        <div className="text-white font-semibold text-sm">{currentStudent.school}</div>
                      </div>
                      <div>
                        <div className="text-white/40 text-xs uppercase tracking-wider mb-1">Previous School</div>
                        <div className="text-white font-semibold text-sm">{currentStudent.hs}</div>
                      </div>
                      <div>
                        <div className="text-white/40 text-xs uppercase tracking-wider mb-1">Year of Completion</div>
                        <div className="text-white font-semibold text-sm">{currentStudent.year}</div>
                      </div>
                    </div>

                    {/* Fake stamp */}
                    <div className="absolute bottom-4 right-4 w-20 h-20 rounded-full border-4 border-white/20 flex items-center justify-center rotate-12">
                      <div className="text-center">
                        <div className="text-white/40 text-[8px] font-bold uppercase leading-tight">OFFICIAL</div>
                        <div className="text-white/40 text-[8px] font-bold uppercase leading-tight">DOCUMENT</div>
                      </div>
                    </div>

                    {/* Barcode simulation */}
                    <div className="flex gap-0.5 mt-2">
                      {Array.from({ length: 28 }).map((_, i) => (
                        <div
                          key={i}
                          className="bg-white/20"
                          style={{ width: i % 3 === 0 ? 3 : 2, height: 24 }}
                        />
                      ))}
                    </div>
                    <div className="text-white/30 text-[9px] mt-1 tracking-widest font-mono">
                      {String(currentStudent.id).padStart(2,'0')} {currentStudent.school.replace(' ','')} {currentStudent.year} VERIFIED
                    </div>
                  </div>
                </div>

                {/* Magnifier lens */}
                {magnifier && (
                  <div
                    className="absolute pointer-events-none z-10 rounded-full overflow-hidden border-2 border-white/40 shadow-2xl shadow-black/50"
                    style={{
                      width: 200,
                      height: 200,
                      left: magnifier.x - 100,
                      top: magnifier.y - 100,
                    }}
                  >
                    <div
                      className={`absolute inset-0 bg-gradient-to-br ${currentStudent.imgBg} flex flex-col p-4 text-white`}
                      style={{
                        width: magnifier.rectW,
                        height: magnifier.rectH,
                        transform: 'scale(2)',
                        transformOrigin: `${magnifier.x}px ${magnifier.y}px`,
                        left: -magnifier.x,
                        top: -magnifier.y,
                        position: 'absolute',
                      }}
                    >
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center border border-white/30 flex-shrink-0">
                          <span className="text-xs font-bold">GH</span>
                        </div>
                        <div>
                          <div className="text-white font-bold text-[10px] uppercase">Ghana Education Service</div>
                          <div className="text-white/60 text-[8px]">WASSCE / PLACEMENT LETTER</div>
                        </div>
                      </div>
                      <div className="border-t border-white/20 mb-2" />
                      <div className="text-white text-sm font-bold mb-1">{currentStudent.name}</div>
                      <div className="text-white/70 text-[10px]">{currentStudent.program}</div>
                      <div className="text-white/50 text-[10px]">{currentStudent.school}</div>
                    </div>
                  </div>
                )}

                {/* Hover hint */}
                <div className="absolute bottom-3 left-1/2 -translate-x-1/2 text-white/30 text-xs pointer-events-none">
                  🔍 Hover to magnify
                </div>
              </div>
            ) : (
              <div className="flex-1 flex items-center justify-center rounded-xl bg-white/[0.02] border border-white/[0.04]">
                <span className="text-white/20 text-sm">No student selected</span>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex-shrink-0 flex gap-3 mt-4">
              <button
                onClick={() => doAction('approved')}
                disabled={!currentStudent}
                className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 disabled:opacity-30 disabled:cursor-not-allowed text-white font-semibold text-sm transition-all duration-200 shadow-lg shadow-emerald-500/20"
              >
                <CheckCircle size={16} />
                Approve
              </button>
              <button
                onClick={() => doAction('skipped')}
                disabled={!currentStudent}
                className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-white/[0.08] hover:bg-white/[0.12] disabled:opacity-30 disabled:cursor-not-allowed text-white font-medium text-sm transition-all duration-200"
              >
                <SkipForward size={16} />
                Skip
              </button>
              <button
                onClick={() => doAction('flagged')}
                disabled={!currentStudent}
                className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-red-500/80 hover:bg-red-500 disabled:opacity-30 disabled:cursor-not-allowed text-white font-semibold text-sm transition-all duration-200 shadow-lg shadow-red-500/10"
              >
                <XCircle size={16} />
                Flag
              </button>
            </div>
          </div>
        </div>

        {/* RIGHT PANEL — 40% */}
        <div className="w-[40%] flex flex-col bg-white/[0.02] overflow-hidden">
          <div
            key={panelKey}
            className="flex-1 overflow-y-auto px-5 py-5"
            style={{ opacity: panelOpacity, transition: 'opacity 0.2s ease' }}
          >
            {currentStudent ? (
              <>
                {/* Avatar + Name */}
                <div className="flex items-center gap-4 mb-6">
                  <div className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm flex-shrink-0 ${SCHOOL_COLORS[currentStudent.school] || 'bg-white/10 text-white'}`}>
                    {getInitials(currentStudent.name)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-white font-semibold text-base truncate">{currentStudent.name}</div>
                    <div className="mt-1">
                      <span className="px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-300 border border-amber-500/30 text-[11px] font-medium">
                        Pending
                      </span>
                    </div>
                  </div>
                </div>

                {/* Institution */}
                <Section title="Institution">
                  <div className="flex items-center gap-2 mb-1.5">
                    <div className={`w-2 h-2 rounded-full flex-shrink-0 ${SCHOOL_DOT_COLORS[currentStudent.school] || 'bg-white/40'}`} />
                    <span className="text-white text-sm font-medium">{currentStudent.school}</span>
                  </div>
                  <div className="text-white/50 text-sm ml-4">{currentStudent.program}</div>
                </Section>

                {/* Origin */}
                <Section title="Origin">
                  <div className="text-white/80 text-sm">{currentStudent.hs}</div>
                  <div className="text-white/40 text-xs mt-1">Class of {currentStudent.year}</div>
                </Section>

                {/* Vibe Profile */}
                <Section title="Vibe Profile">
                  <div className="flex flex-wrap gap-2">
                    {currentStudent.vibe.map(v => (
                      <span
                        key={v}
                        className={`px-2.5 py-1 rounded-full text-xs font-medium border ${VIBE_COLORS[v] || 'bg-white/10 text-white/60 border-white/10'}`}
                      >
                        {v}
                      </span>
                    ))}
                  </div>
                </Section>

                {/* Contact */}
                <Section title="Contact">
                  <div className="text-white/60 text-sm font-mono">{currentStudent.phone}</div>
                </Section>

                {/* Queue Preview */}
                {nextStudents.length > 0 && (
                  <Section title="Up Next">
                    <div className="flex flex-col gap-2">
                      {nextStudents.map((s, i) => (
                        <div key={s.id} className="flex items-center gap-3 px-3 py-2 rounded-lg bg-white/[0.03] border border-white/[0.04]">
                          <div className={`w-7 h-7 rounded-full flex items-center justify-center text-[11px] font-bold flex-shrink-0 opacity-50 ${SCHOOL_COLORS[s.school] || 'bg-white/10 text-white/40'}`}>
                            {getInitials(s.name)}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="text-white/40 text-xs truncate">{s.name}</div>
                            <div className="text-white/25 text-[11px] truncate">{s.school}</div>
                          </div>
                          <span className="text-white/20 text-xs flex-shrink-0">+{i + 1}</span>
                        </div>
                      ))}
                    </div>
                  </Section>
                )}
              </>
            ) : (
              <div className="flex items-center justify-center h-full">
                <span className="text-white/20 text-sm">Queue empty</span>
              </div>
            )}
          </div>

          {/* Hotkeys Legend */}
          <div className="flex-shrink-0 border-t border-white/[0.06] px-4 py-3 flex items-center gap-4 bg-white/[0.02]">
            <span className="text-white/25 text-xs font-medium uppercase tracking-wider mr-1">Keys</span>
            <KeyChip label="SPACE" action="Approve" color="text-emerald-400" />
            <KeyChip label="→" action="Skip" color="text-amber-400" />
            <KeyChip label="⌫" action="Flag" color="text-red-400" />
          </div>
        </div>
      </div>
    </div>
  );
}

function Section({ title, children }) {
  return (
    <div className="mb-5">
      <div className="text-white/30 text-[11px] uppercase tracking-wider font-medium mb-2">{title}</div>
      {children}
    </div>
  );
}

function KeyChip({ label, action, color }) {
  return (
    <div className="flex items-center gap-1.5">
      <kbd className="px-1.5 py-0.5 rounded bg-white/[0.06] border border-white/[0.10] text-white/50 text-[11px] font-mono min-w-[28px] text-center">
        {label}
      </kbd>
      <span className={`text-xs ${color}`}>{action}</span>
    </div>
  );
}

function StatCard({ label, value, color }) {
  return (
    <div className="flex flex-col items-center gap-1 px-6 py-4 rounded-xl bg-white/[0.04] border border-white/[0.08]">
      <span className={`text-2xl font-bold ${color}`}>{value}</span>
      <span className="text-white/40 text-xs">{label}</span>
    </div>
  );
}
