'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import {
  Send, Users, ChevronRight, School, CheckCircle, AlertCircle,
  MessageSquare, Zap, DollarSign, Clock, Filter, X, ChevronDown,
  Radio, Smartphone, ScrollText
} from 'lucide-react';

// ─── Mock Data ────────────────────────────────────────────────────────────────
const SCHOOL_COUNTS = { knust: 3841, ug: 2910, ucc: 2203, upsa: 1847, uds: 987, gctu: 612 };
const TOTAL_ALL = 12400;

const SCHOOL_OPTIONS = [
  { key: 'all',  label: 'All Schools', count: TOTAL_ALL },
  { key: 'knust',label: 'KNUST',       count: SCHOOL_COUNTS.knust },
  { key: 'ug',   label: 'UG Legon',    count: SCHOOL_COUNTS.ug },
  { key: 'ucc',  label: 'UCC',         count: SCHOOL_COUNTS.ucc },
  { key: 'upsa', label: 'UPSA',        count: SCHOOL_COUNTS.upsa },
  { key: 'uds',  label: 'UDS',         count: SCHOOL_COUNTS.uds },
  { key: 'gctu', label: 'GCTU',        count: SCHOOL_COUNTS.gctu },
];

const STATUS_OPTIONS = [
  { key: 'all',        label: 'All Students'   },
  { key: 'unverified', label: 'Unverified Only' },
  { key: 'verified',   label: 'Verified Only'  },
];

const SCHOOL_COLORS = {
  KNUST:      'bg-yellow-500/20 text-yellow-300 border-yellow-500/30',
  'UG Legon': 'bg-blue-500/20 text-blue-300 border-blue-500/30',
  UCC:        'bg-purple-500/20 text-purple-300 border-purple-500/30',
  UPSA:       'bg-pink-500/20 text-pink-300 border-pink-500/30',
  UDS:        'bg-emerald-500/20 text-emerald-300 border-emerald-500/30',
  GCTU:       'bg-orange-500/20 text-orange-300 border-orange-500/30',
  All:        'bg-white/10 text-white/60 border-white/20',
};

const TEMPLATES = [
  { name: 'Hub Launch',     text: "Hey {{fresher_name}}! Your {{school_name}} hub is now LIVE on UNIFY 🎓 Claim your handle: {{hub_link}} — Free forever. Don't sleep on it!" },
  { name: '48hr Warning',   text: "Final 48hrs! {{fresher_name}}, your {{school_name}} hub closes for early access soon. Secure your spot: {{hub_link}}" },
  { name: 'Roommate Match', text: "{{fresher_name}}, you have a new roommate match on UNIFY! Open your {{school_name}} hub to connect: {{hub_link}}" },
  { name: 'Verification',   text: "Hi {{fresher_name}}, your UNIFY profile needs verification. Complete it here: {{hub_link}} — takes 2 mins." },
];

const TAGS = ['{{fresher_name}}', '{{school_name}}', '{{handle}}', '{{hub_link}}'];

const INITIAL_CAMPAIGNS = [
  { id: 1, name: 'KNUST Hub 48hr Warning',  recipients: 3841,  delivered: 3809,  cost: 114.23, date: '2 Jun 2026',  school: 'KNUST',    status: 'delivered' },
  { id: 2, name: 'UG Legon Launch Alert',   recipients: 2910,  delivered: 2884,  cost: 86.52,  date: '1 Jun 2026',  school: 'UG Legon', status: 'delivered' },
  { id: 3, name: 'All Schools Welcome SMS', recipients: 12400, delivered: 12201, cost: 372.00, date: '28 May 2026', school: 'All',      status: 'delivered' },
  { id: 4, name: 'UCC Verification Nudge',  recipients: 2203,  delivered: 2190,  cost: 65.09,  date: '25 May 2026', school: 'UCC',      status: 'delivered' },
];

// ─── Helpers ──────────────────────────────────────────────────────────────────
function fmt(n) {
  return n.toLocaleString();
}

function getRecipients(schoolKey, statusKey) {
  const base = schoolKey === 'all' ? TOTAL_ALL : (SCHOOL_COUNTS[schoolKey] ?? 0);
  if (statusKey === 'all')        return base;
  if (statusKey === 'verified')   return Math.round(base * 0.68);
  if (statusKey === 'unverified') return Math.round(base * 0.32);
  return base;
}

function renderPreview(text, schoolLabel) {
  return text
    .replace(/\{\{fresher_name\}\}/g, 'Akosua')
    .replace(/\{\{school_name\}\}/g, schoolLabel === 'All Schools' ? 'your school' : schoolLabel)
    .replace(/\{\{hub_link\}\}/g, 'unify.app/join')
    .replace(/\{\{handle\}\}/g, '@akosua_30');
}

// ─── Sub-components ───────────────────────────────────────────────────────────
function StatCell({ label, value, warn, icon }) {
  return (
    <div className="bg-black/20 rounded-xl p-3 flex flex-col gap-1">
      <span className="text-white/40 text-[10px] uppercase tracking-widest font-semibold">{label}</span>
      <span className={`text-sm font-bold flex items-center gap-1 ${warn ? 'text-amber-400' : 'text-white'}`}>
        {warn && icon}
        {value}
      </span>
    </div>
  );
}

function CampaignRow({ campaign }) {
  const pct = Math.round((campaign.delivered / campaign.recipients) * 100);
  const colorClass = SCHOOL_COLORS[campaign.school] ?? SCHOOL_COLORS['All'];
  return (
    <div className="bg-white/[0.03] border border-white/[0.07] rounded-2xl px-5 py-4 flex items-center gap-5">
      {/* Left */}
      <div className="flex-1 min-w-0">
        <p className="text-white/90 text-sm font-semibold truncate">{campaign.name}</p>
        <span className={`inline-block mt-1 text-[10px] font-semibold px-2 py-0.5 rounded-full border ${colorClass}`}>
          {campaign.school}
        </span>
      </div>
      {/* Center */}
      <div className="w-40 shrink-0">
        <div className="flex justify-between text-[10px] text-white/40 mb-1">
          <span>{fmt(campaign.delivered)} delivered</span>
          <span>{pct}%</span>
        </div>
        <div className="h-1.5 rounded-full bg-white/[0.06] overflow-hidden">
          <div
            className="h-full bg-emerald-400 rounded-full transition-all"
            style={{ width: `${pct}%` }}
          />
        </div>
      </div>
      {/* Right */}
      <div className="text-right shrink-0">
        <p className="text-white/50 text-xs">{campaign.date}</p>
        <p className="text-white/80 text-sm font-semibold mt-0.5">GH₵ {campaign.cost.toFixed(2)}</p>
        <p className="text-white/30 text-[10px] mt-0.5">{fmt(campaign.recipients)} recipients</p>
      </div>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────
export default function SMSLaunchpadPage() {
  // All hooks declared unconditionally at the top
  const [schoolKey,   setSchoolKey]   = useState('all');
  const [statusKey,   setStatusKey]   = useState('all');
  const [message,     setMessage]     = useState('');
  const [showModal,   setShowModal]   = useState(false);
  const [holding,     setHolding]     = useState(false);
  const [holdPct,     setHoldPct]     = useState(0);
  const [toast,       setToast]       = useState(null);
  const [campaigns,   setCampaigns]   = useState(INITIAL_CAMPAIGNS);
  const [currentTime, setCurrentTime] = useState('');

  const textareaRef = useRef(null);
  const holdTimer   = useRef(null);
  const holdStart   = useRef(null);
  const historyRef  = useRef(null);

  // Live clock
  useEffect(() => {
    const tick = () => {
      const d = new Date();
      setCurrentTime(d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
    };
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, []);

  // Hold progress animation
  useEffect(() => {
    if (!holding) {
      setHoldPct(0);
      if (holdTimer.current) { cancelAnimationFrame(holdTimer.current); holdTimer.current = null; }
      return;
    }
    holdStart.current = performance.now();
    const DURATION = 2000;
    const animate = (now) => {
      const elapsed = now - holdStart.current;
      const pct = Math.min((elapsed / DURATION) * 100, 100);
      setHoldPct(pct);
      if (pct < 100) {
        holdTimer.current = requestAnimationFrame(animate);
      } else {
        fireHandleSend();
      }
    };
    holdTimer.current = requestAnimationFrame(animate);
    return () => { if (holdTimer.current) cancelAnimationFrame(holdTimer.current); };
  }, [holding]); // eslint-disable-line react-hooks/exhaustive-deps

  const school     = SCHOOL_OPTIONS.find(s => s.key === schoolKey);
  const recipients = getRecipients(schoolKey, statusKey);
  const len        = message.length;
  const pages      = Math.max(1, Math.ceil(len / 160));
  const cost       = recipients * pages * 0.03;

  // Using a ref-based send to avoid stale closures in the hold animation effect
  const sendDataRef = useRef({ school, recipients, cost });
  sendDataRef.current = { school, recipients, cost };

  const fireHandleSend = useCallback(() => {
    const { school: s, recipients: r, cost: c } = sendDataRef.current;
    setHolding(false);
    setShowModal(false);
    const newCampaign = {
      id:         Date.now(),
      name:       `${s.label} Campaign`,
      recipients: r,
      delivered:  Math.round(r * 0.985),
      cost:       parseFloat(c.toFixed(2)),
      date:       new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }),
      school:     s.label === 'All Schools' ? 'All' : s.label,
      status:     'delivered',
    };
    setCampaigns(prev => [newCampaign, ...prev]);
    setMessage('');
    setToast({ text: `Campaign launched! Sending to ${fmt(r)} students.` });
    setTimeout(() => setToast(null), 4000);
  }, []);

  const insertTag = useCallback((tag) => {
    const el = textareaRef.current;
    if (!el) return;
    const start  = el.selectionStart;
    const end    = el.selectionEnd;
    setMessage(prev => {
      const newVal = prev.slice(0, start) + tag + prev.slice(end);
      requestAnimationFrame(() => {
        el.focus();
        el.setSelectionRange(start + tag.length, start + tag.length);
      });
      return newVal;
    });
  }, []);

  const statusLabel = STATUS_OPTIONS.find(s => s.key === statusKey)?.label ?? '';

  return (
    <div className="min-h-screen flex flex-col" style={{ background: '#0B0F19', fontFamily: 'system-ui, Inter, sans-serif' }}>

      {/* ── HEADER ── */}
      <header className="sticky top-0 z-30 h-14 flex items-center justify-between px-6 bg-[#0B0F19]/80 backdrop-blur border-b border-white/[0.06]">
        {/* Left */}
        <div className="flex items-center gap-3">
          <a href="/admin" className="flex items-center gap-1 text-white/40 hover:text-white/70 text-sm transition-colors">
            <ChevronRight className="w-3.5 h-3.5 rotate-180" />
            <span>Admin</span>
          </a>
          <span className="text-white/20 text-xs">›</span>
          <div className="flex items-center gap-2">
            <MessageSquare className="w-4 h-4 text-amber-400" />
            <span className="text-white font-bold text-sm tracking-tight">SMS Launchpad</span>
            <span className="text-[10px] font-black tracking-widest px-2 py-0.5 rounded-full bg-amber-400/15 text-amber-400 border border-amber-400/25">
              BETA
            </span>
          </div>
        </div>
        {/* Right */}
        <div className="flex items-center gap-3">
          <button
            onClick={() => historyRef.current?.scrollIntoView({ behavior: 'smooth' })}
            className="flex items-center gap-2 text-white/50 hover:text-white/80 text-xs font-semibold transition-colors"
          >
            <ScrollText className="w-4 h-4" />
            Campaign History
          </button>
          <div className="h-4 w-px bg-white/10" />
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20">
            <DollarSign className="w-3.5 h-3.5 text-emerald-400" />
            <span className="text-emerald-300 text-xs font-bold">GH₵ 500.00 credit</span>
          </div>
        </div>
      </header>

      {/* ── MAIN CONTENT ── */}
      <div className="flex-1 px-6 py-6">
        <div className="flex gap-5 items-start">

          {/* ── LEFT COLUMN (55%) ── */}
          <div className="flex-[55] min-w-0 flex flex-col gap-4">
            <div className="bg-white/[0.05] backdrop-blur-xl border border-white/[0.08] rounded-3xl p-6 flex flex-col gap-6">

              {/* Section 1 — Target Segmentation */}
              <div>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4 text-amber-400" />
                    <span className="text-white/90 text-sm font-bold">Target Audience</span>
                  </div>
                  <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-amber-400/15 text-amber-400 border border-amber-400/25">
                    {fmt(recipients)} recipients
                  </span>
                </div>
                {/* School pills */}
                <div className="flex flex-wrap gap-2 mb-2">
                  {SCHOOL_OPTIONS.map(s => (
                    <button
                      key={s.key}
                      onClick={() => setSchoolKey(s.key)}
                      className={`text-xs font-semibold px-3 py-1.5 rounded-full transition-all ${
                        schoolKey === s.key
                          ? 'bg-amber-400 text-[#0B0F19] font-black'
                          : 'bg-white/[0.06] text-white/50 border border-white/[0.08] hover:text-white/70 hover:border-white/20'
                      }`}
                    >
                      {s.label} ({fmt(s.count)})
                    </button>
                  ))}
                </div>
                {/* Status pills */}
                <div className="flex flex-wrap gap-2">
                  {STATUS_OPTIONS.map(s => (
                    <button
                      key={s.key}
                      onClick={() => setStatusKey(s.key)}
                      className={`text-xs font-semibold px-3 py-1.5 rounded-full transition-all ${
                        statusKey === s.key
                          ? 'bg-[#7B2FBE] text-white font-bold'
                          : 'bg-white/[0.06] text-white/50 border border-white/[0.08] hover:text-white/70 hover:border-white/20'
                      }`}
                    >
                      {s.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Section 2 — Templates */}
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <Zap className="w-4 h-4 text-blue-400" />
                  <span className="text-white/90 text-sm font-bold">Quick Templates</span>
                </div>
                <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
                  {TEMPLATES.map(t => (
                    <button
                      key={t.name}
                      onClick={() => setMessage(t.text)}
                      className="shrink-0 bg-white/[0.04] border border-white/[0.07] rounded-xl px-3 py-2 text-xs font-semibold text-white/60 hover:text-white hover:border-white/20 transition-all"
                    >
                      {t.name}
                    </button>
                  ))}
                </div>
              </div>

              {/* Section 3 — Tag Pills */}
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <Filter className="w-4 h-4 text-blue-300" />
                  <span className="text-white/90 text-sm font-bold">Insert Variable</span>
                </div>
                <div className="flex flex-wrap gap-2">
                  {TAGS.map(tag => (
                    <button
                      key={tag}
                      onClick={() => insertTag(tag)}
                      className="bg-blue-500/15 text-blue-300 border border-blue-500/25 rounded-lg px-2.5 py-1 text-xs font-mono cursor-pointer hover:bg-blue-500/25 transition-all"
                    >
                      {tag}
                    </button>
                  ))}
                </div>
              </div>

              {/* Section 4 — Textarea */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <MessageSquare className="w-4 h-4 text-white/40" />
                    <span className="text-white/90 text-sm font-bold">Message</span>
                  </div>
                  <span className={`text-xs font-mono ${len > 160 ? 'text-amber-400' : 'text-white/30'}`}>
                    {len} / 160
                  </span>
                </div>
                <textarea
                  ref={textareaRef}
                  value={message}
                  onChange={e => setMessage(e.target.value)}
                  placeholder="Type your message here, or use a template above..."
                  className="bg-black/30 border border-white/[0.08] focus:border-amber-400/40 rounded-2xl p-4 text-sm text-white placeholder-white/20 resize-none h-36 w-full outline-none transition-colors"
                />
              </div>

              {/* Section 5 — Stats Grid */}
              <div className="grid grid-cols-2 gap-2">
                <StatCell
                  label="Characters"
                  value={`${len} / 160`}
                  warn={len > 160}
                  icon={<AlertCircle className="w-3.5 h-3.5" />}
                />
                <StatCell
                  label="SMS Pages"
                  value={`${pages} page${pages > 1 ? 's' : ''}`}
                  warn={pages > 1}
                  icon={<AlertCircle className="w-3.5 h-3.5" />}
                />
                <StatCell
                  label="Recipients"
                  value={fmt(recipients)}
                  warn={false}
                />
                <StatCell
                  label="Est. Cost"
                  value={`GH₵ ${cost.toFixed(2)}`}
                  warn={cost > 200}
                  icon={<AlertCircle className="w-3.5 h-3.5" />}
                />
              </div>
            </div>
          </div>

          {/* ── RIGHT COLUMN (45%) ── */}
          <div className="flex-[45] min-w-0 flex flex-col gap-4">

            {/* Phone Mockup */}
            <div className="bg-white/[0.05] backdrop-blur-xl border border-white/[0.08] rounded-3xl p-6">
              <div className="flex items-center gap-2 mb-5">
                <Smartphone className="w-4 h-4 text-white/40" />
                <span className="text-white/90 text-sm font-bold">Live Preview</span>
              </div>
              <div className="bg-[#111827] border border-white/10 rounded-[2.5rem] p-3 w-[240px] mx-auto shadow-2xl shadow-black/50">
                {/* Notch */}
                <div className="w-20 h-1.5 bg-white/10 rounded-full mx-auto mb-3" />
                {/* Screen */}
                <div className="bg-[#1a1a2e] rounded-[1.8rem] p-4 min-h-[380px] flex flex-col">
                  {/* Status bar */}
                  <div className="flex justify-between items-center mb-4 px-1">
                    <span className="text-white/40 text-[10px]">{currentTime}</span>
                    <div className="flex gap-1">
                      <Radio className="w-3 h-3 text-white/30" />
                    </div>
                  </div>
                  {/* Sender header */}
                  <div className="flex items-center gap-2 mb-4">
                    <div className="w-8 h-8 rounded-full bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center shrink-0">
                      <span className="text-[10px] font-black text-emerald-400">U</span>
                    </div>
                    <div>
                      <div className="flex items-center gap-1.5">
                        <span className="text-white text-xs font-bold">UNIFY</span>
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block" />
                      </div>
                      <span className="text-white/30 text-[9px]">Business SMS</span>
                    </div>
                  </div>
                  {/* SMS bubble */}
                  <div className="flex-1">
                    <div className="bg-[#1e3a2f] border border-emerald-500/20 rounded-2xl rounded-tl-none p-3 text-[10px] text-white/80 leading-relaxed max-w-[90%]">
                      {message
                        ? renderPreview(message, school.label)
                        : <span className="text-white/30 italic">Your message preview will appear here...</span>
                      }
                    </div>
                    <div className="flex items-center gap-1 mt-1.5 ml-1">
                      <span className="text-white/25 text-[9px]">Just now</span>
                      <span className="text-emerald-400 text-[9px] font-bold">✓✓</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Launch Trigger */}
            <div className="bg-white/[0.05] backdrop-blur-xl border border-white/[0.08] rounded-3xl p-6">
              <div className="flex items-center gap-2 mb-4">
                <Send className="w-4 h-4 text-emerald-400" />
                <span className="text-white/90 text-sm font-bold">Launch Campaign</span>
              </div>
              <button
                disabled={!message.trim()}
                onClick={() => setShowModal(true)}
                className={`w-full rounded-2xl px-6 py-4 font-black text-sm transition-all flex items-center justify-center gap-2 ${
                  message.trim()
                    ? 'bg-emerald-500 hover:bg-emerald-400 text-white cursor-pointer'
                    : 'bg-white/[0.06] text-white/20 cursor-not-allowed'
                }`}
              >
                <Send className="w-4 h-4" />
                {message.trim()
                  ? `Send to ${fmt(recipients)} · GH₵ ${cost.toFixed(2)}`
                  : 'Initialize Launch'
                }
              </button>
              {!message.trim() && (
                <p className="text-white/30 text-xs text-center mt-2">Write a message to enable sending</p>
              )}
            </div>
          </div>
        </div>

        {/* ── CAMPAIGN LOG ── */}
        <div ref={historyRef} className="mt-6">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <ScrollText className="w-4 h-4 text-white/50" />
              <span className="text-white/90 font-bold">Campaign History</span>
              <span className="text-xs font-bold px-2.5 py-0.5 rounded-full bg-white/[0.06] text-white/40 border border-white/[0.08]">
                {campaigns.length} campaigns
              </span>
            </div>
          </div>
          <div className="flex flex-col gap-3">
            {campaigns.map(c => <CampaignRow key={c.id} campaign={c} />)}
          </div>
        </div>
      </div>

      {/* ── CONFIRM MODAL ── */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#111827] border border-white/10 rounded-3xl p-8 max-w-md w-full shadow-2xl">
            {/* Modal header */}
            <div className="flex items-start justify-between mb-6">
              <div>
                <h2 className="text-white font-black text-lg">Confirm Campaign Launch</h2>
                <p className="text-white/40 text-sm mt-1">Review details before sending</p>
              </div>
              <button
                onClick={() => { setShowModal(false); setHolding(false); }}
                className="w-8 h-8 rounded-xl bg-white/[0.06] flex items-center justify-center text-white/50 hover:text-white transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Summary cards */}
            <div className="flex flex-col gap-3 mb-6">
              <div className="bg-white/[0.04] border border-white/[0.07] rounded-2xl p-4 flex items-center gap-3">
                <Filter className="w-4 h-4 text-white/40 shrink-0" />
                <div>
                  <p className="text-white/40 text-[10px] uppercase tracking-widest font-semibold">Target</p>
                  <p className="text-white text-sm font-semibold">{school.label} · {statusLabel}</p>
                </div>
              </div>
              <div className="bg-white/[0.04] border border-white/[0.07] rounded-2xl p-4 flex items-center gap-3">
                <Users className="w-4 h-4 text-blue-400 shrink-0" />
                <div>
                  <p className="text-white/40 text-[10px] uppercase tracking-widest font-semibold">Recipients</p>
                  <p className="text-white text-sm font-semibold">{fmt(recipients)} students</p>
                </div>
              </div>
              <div className={`border rounded-2xl p-4 flex items-center gap-3 ${cost > 100 ? 'bg-amber-500/10 border-amber-500/20' : 'bg-white/[0.04] border-white/[0.07]'}`}>
                <DollarSign className={`w-4 h-4 shrink-0 ${cost > 100 ? 'text-amber-400' : 'text-emerald-400'}`} />
                <div>
                  <p className="text-white/40 text-[10px] uppercase tracking-widest font-semibold">Total Cost</p>
                  <p className={`text-sm font-semibold ${cost > 100 ? 'text-amber-400' : 'text-white'}`}>
                    GH₵ {cost.toFixed(2)}
                    {cost > 100 && <span className="text-amber-400/70 text-xs ml-1">(high spend)</span>}
                  </p>
                </div>
              </div>
              <div className="bg-white/[0.04] border border-white/[0.07] rounded-2xl p-4 flex items-start gap-3">
                <MessageSquare className="w-4 h-4 text-white/40 mt-0.5 shrink-0" />
                <div className="min-w-0">
                  <p className="text-white/40 text-[10px] uppercase tracking-widest font-semibold mb-1">Message Preview</p>
                  <p className="text-white/70 text-xs leading-relaxed break-words">
                    {message.slice(0, 80)}{message.length > 80 ? '…' : ''}
                  </p>
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button
                onClick={() => { setShowModal(false); setHolding(false); }}
                className="flex-1 px-4 py-3 rounded-2xl bg-white/[0.06] text-white/60 font-semibold text-sm hover:bg-white/[0.10] transition-all"
              >
                Cancel
              </button>
              {/* Hold-to-send button */}
              <div
                className="flex-[2] relative overflow-hidden rounded-2xl cursor-pointer select-none"
                onMouseDown={() => setHolding(true)}
                onMouseUp={() => setHolding(false)}
                onMouseLeave={() => setHolding(false)}
                onTouchStart={() => setHolding(true)}
                onTouchEnd={() => setHolding(false)}
              >
                {/* Base background */}
                <div className="absolute inset-0 bg-emerald-700/60" />
                {/* Progress fill */}
                <div
                  className="absolute inset-0 bg-emerald-500 transition-none origin-left"
                  style={{ width: `${holdPct}%` }}
                />
                {/* Label */}
                <div className="relative flex items-center justify-center gap-2 px-4 py-3 z-10">
                  <Send className="w-4 h-4 text-white" />
                  <span className="text-white font-black text-sm">
                    {holding
                      ? holdPct < 100 ? `Hold… ${Math.round(holdPct)}%` : 'Sending!'
                      : 'Hold to Send'
                    }
                  </span>
                </div>
              </div>
            </div>
            <p className="text-white/20 text-[10px] text-center mt-3">Hold the button for 2 seconds to confirm send</p>
          </div>
        </div>
      )}

      {/* ── TOAST ── */}
      {toast && (
        <div className="fixed top-5 right-5 z-50 sms-toast-enter">
          <div className="bg-emerald-500/20 border border-emerald-500/30 text-emerald-300 px-5 py-3.5 rounded-2xl shadow-2xl flex items-center gap-3 max-w-sm">
            <CheckCircle className="w-4 h-4 shrink-0" />
            <span className="text-sm font-semibold">{toast.text}</span>
            <button onClick={() => setToast(null)} className="ml-auto text-emerald-400/60 hover:text-emerald-300">
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      )}

      <style jsx global>{`
        @keyframes sms-slide-in {
          from { opacity: 0; transform: translateX(100%); }
          to   { opacity: 1; transform: translateX(0); }
        }
        .sms-toast-enter { animation: sms-slide-in 0.3s ease-out forwards; }
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
      `}</style>
    </div>
  );
}
