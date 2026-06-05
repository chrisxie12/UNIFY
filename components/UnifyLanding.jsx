'use client';

/**
 * UNIFY — Ghana's peer-to-peer university transition network
 * iOS "Clear" glassmorphism redesign with Lucide icons and CSS entrance animations.
 *
 * Dependencies:
 *   npm install lucide-react
 *   Tailwind CSS configured with the custom `ticker` animation below.
 *
 * Add to tailwind.config.js → theme.extend:
 *   animation: { ticker: 'ticker 35s linear infinite' },
 *   keyframes: { ticker: { '0%': { transform: 'translateX(0)' }, '100%': { transform: 'translateX(-50%)' } } },
 */

import { useState, useEffect } from 'react';
import { MapPin, CheckCircle, ArrowRight, ChevronDown, Users2, GraduationCap, Building2, Sparkles, Star, MessageCircle, Bell } from 'lucide-react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

const SCHOOLS = [
  { id: 'knust', label: 'KNUST', full: 'Kwame Nkrumah University of Science & Technology' },
  { id: 'ug',   label: 'UG Legon', full: 'University of Ghana' },
  { id: 'ucc',  label: 'UCC', full: 'University of Cape Coast' },
  { id: 'upsa', label: 'UPSA', full: 'University of Professional Studies' },
  { id: 'uds',  label: 'UDS', full: 'University for Development Studies' },
  { id: 'gctu', label: 'GCTU', full: 'Ghana Communication Technology University' },
];

const SCHOOL_CONFIG = {
  knust: {
    id: 'knust', name: 'KNUST',
    full: 'Kwame Nkrumah University of Science & Technology',
    badge: "KNUST Freshers · Class of '30",
    headline: "Don't Pull Up To Kotei Alone,",
    sub: "The fresher network built for KNUST. Find your roommate around Brunei, Kotei, or Unity Hall — link with coursemates in Engineering, CS, and Medicine before lectures even start.",
    hostels: ['Brunei', 'Kotei', 'Unity Hall', 'Evandy', 'TF Hostel'],
  },
  ug: {
    id: 'ug', name: 'UG Legon',
    full: 'University of Ghana',
    badge: "UG Legon Freshers · Class of '30",
    headline: "Don't Walk Into Legon Alone,",
    sub: "The fresher network built for UG Legon. Find your roommate at Volta, Limann, or Commonwealth — link with coursemates in Business, Law, and Social Sciences before orientation week.",
    hostels: ['Volta Hall', 'Limann Hall', 'Commonwealth Hall', 'Mensah Sarbah'],
  },
  ucc: {
    id: 'ucc', name: 'UCC',
    full: 'University of Cape Coast',
    badge: "UCC Freshers · Class of '30",
    headline: "Don't Pull Up To Cape Coast Alone,",
    sub: "The fresher network built for UCC. Find your roommate around Casford or Atlantic Hall — link with coursemates in Education, Nursing, and Sciences before matriculation day.",
    hostels: ['Casford Hall', 'Atlantic Hall', 'Oguaa Hall'],
  },
  upsa: {
    id: 'upsa', name: 'UPSA',
    full: 'University of Professional Studies',
    badge: "UPSA Freshers · Class of '30",
    headline: "Don't Start UPSA Alone,",
    sub: "The fresher network built for UPSA. Connect with fellow Business, Accounting, and Law freshers — find your people before the semester kicks off.",
    hostels: ['On-campus hostel', 'Legon area'],
  },
  uds: {
    id: 'uds', name: 'UDS',
    full: 'University for Development Studies',
    badge: "UDS Freshers · Class of '30",
    headline: "Don't Pull Up To Tamale Alone,",
    sub: "The fresher network built for UDS. Connect with Agriculture, Medicine, and Law freshers across Tamale, Wa, and Navrongo campuses.",
    hostels: ['Tamale campus', 'Wa campus', 'Navrongo campus'],
  },
  gctu: {
    id: 'gctu', name: 'GCTU',
    full: 'Ghana Communication Technology University',
    badge: "GCTU Freshers · Class of '30",
    headline: "Don't Start GCTU Alone,",
    sub: "The fresher network built for GCTU. Link up with Tech, Telecom, and Business freshers — find your people and secure your spot before the hub fills up.",
    hostels: ['On-campus hostel', 'Accra area'],
  },
};

const TICKER_ITEMS = [
  "🔥 45 freshers from Prempeh College just claimed their handles",
  "⚡️ 120 roomies matched for KNUST Brunei & Kotei hostels",
  "🎓 Legon Class of '30 hubs are officially live",
  "🔥 32 girls just joined the Volta Hall fresher network",
  "⚡️ Avoid the portal rush — 210 students linked up early",
  "🏠 Evandy & TF hostel threads trending in UCC hub",
  "🎓 KNUST Engineering Circle just hit 88 verified members",
  "🔥 UPSA Business fresher hub is growing fast — claim your spot",
  "⚡️ 67 Law freshers linked up at Legon before lectures even start",
  "🏠 Katanga & Unity Hall residents dropping real hostel intel",
  "🎓 Achimota Class of '30 placement group: 340 members and counting",
  "🔥 Wesley Girls intake crew already planning Legon orientation week",
];

const TESTIMONIALS = [
  {
    quote: "I found my roommate on UNIFY before I even got my admission letter. We're already planning our room setup. This app is different fr.",
    name: 'Ama K.', role: 'KNUST CS Fresher', initials: 'AK', stars: 5,
  },
  {
    quote: "The KNUST hub had real hostel intel nobody else was sharing. I knew which blocks had water issues before I even moved in.",
    name: 'Yaw B.', role: 'UG Legon Fresher', initials: 'YB', stars: 5,
  },
  {
    quote: "Joined the UCC hub and linked with 3 girls from my faculty. We're sharing a room in Evandy. Couldn't have done it without UNIFY.",
    name: 'Abena M.', role: 'UCC Nursing', initials: 'AM', stars: 4,
  },
];

const FAQS_NEW = [
  { q: 'What is UNIFY?', a: "UNIFY is Ghana's peer-to-peer university transition network. It helps freshers find roommates, link with coursemates, and join their official campus hub — all before matriculation day." },
  { q: 'When do campus hubs go live?', a: "We notify you 48 hours before your school hub opens. KNUST, UG Legon, UCC, and UPSA hubs are launching first in 2026. You'll get a message the moment yours is ready." },
  { q: 'Is UNIFY free for freshers?', a: "100% free. No subscription, no hidden charges, no premium tier. We're building this for Ghana's freshers — not to extract money from students already stretched thin." },
  { q: 'How does roommate matching work?', a: "You fill in your habits — neatness, sleep schedule, study preferences, hostel area — and our engine pairs you with compatible freshers. No brokers, no random guessing, no group chat chaos." },
];

// ─── HOOKS ───────────────────────────────────────────────────────────────────

function useSignupCount() {
  const [count, setCount] = useState(null);
  useEffect(() => {
    fetch(`${SHEET_URL}?ts=count`)
      .then((r) => r.json())
      .then((d) => { if (d.count > 0) setCount(d.count); })
      .catch(() => {});
  }, []);
  return count;
}

// ─── DECORATIVE SVGs ──────────────────────────────────────────────────────────

function BlueDoodle() {
  return (
    <svg viewBox="0 0 40 40" className="w-8 h-8 text-[#0066FF]" fill="none">
      <line x1="20" y1="2" x2="20" y2="10" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="20" y1="30" x2="20" y2="38" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="2" y1="20" x2="10" y2="20" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="30" y1="20" x2="38" y2="20" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="6" y1="6" x2="12" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
      <line x1="28" y1="28" x2="34" y2="34" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
      <line x1="34" y1="6" x2="28" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
      <line x1="6" y1="34" x2="12" y2="28" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
    </svg>
  );
}

function OrangeDoodle() {
  return (
    <svg viewBox="0 0 40 40" className="w-8 h-8" fill="none">
      <line x1="20" y1="2" x2="20" y2="10" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="20" y1="30" x2="20" y2="38" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="2" y1="20" x2="10" y2="20" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="30" y1="20" x2="38" y2="20" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="6" y1="6" x2="12" y2="12" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="28" y1="28" x2="34" y2="34" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="34" y1="6" x2="28" y2="12" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="6" y1="34" x2="12" y2="28" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
    </svg>
  );
}

function SquiggleUnderline() {
  return (
    <svg viewBox="0 0 120 10" className="w-24 h-2.5 mt-0.5" fill="none">
      <path d="M0,5 C10,1 20,9 30,5 C40,1 50,9 60,5 C70,1 80,9 90,5 C100,1 110,9 120,5"
        stroke="#FF6B35" strokeWidth="3" strokeLinecap="round"/>
    </svg>
  );
}

function BlueSwirl({ className = '' }) {
  return (
    <svg viewBox="0 0 80 200" className={`w-16 h-40 text-[#0066FF] opacity-20 ${className}`} fill="none">
      <path d="M60,10 C80,40 20,60 40,90 C60,120 80,140 40,170 C20,185 10,190 20,195"
        stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
    </svg>
  );
}

// ─── SUB-COMPONENTS ──────────────────────────────────────────────────────────

function CopyButton({ text }) {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard?.writeText(text).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  };
  return (
    <button
      onClick={copy}
      className={`shrink-0 text-[10px] font-bold px-2.5 py-1 rounded-full border transition-all backdrop-blur-sm ${copied ? 'bg-green-50 border-green-200 text-green-700' : 'bg-white/60 border-white/70 text-[#6B7280] hover:border-[#111827]'}`}
    >
      {copied ? 'Copied!' : 'Copy'}
    </button>
  );
}

function WaitlistForm({ id, defaultSchool = '' }) {
  const [phone, setPhone] = useState('');
  const [school, setSchool] = useState(defaultSchool);
  const [done, setDone] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [noSchool, setNoSchool] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!school) { setNoSchool(true); return; }
    if (!phone.trim()) return;
    setNoSchool(false);
    setLoading(true);
    setError('');
    try {
      const params = new URLSearchParams({ phone: phone.trim(), school, ts: new Date().toISOString() });
      await fetch(`${SHEET_URL}?${params}`, { method: 'GET', mode: 'no-cors' });
      setDone(true);
    } catch {
      setError('No connection. Try again.');
    } finally {
      setLoading(false);
    }
  };

  if (done) {
    const schoolLabel = SCHOOLS.find((s) => s.id === school)?.label || 'your school';
    const refCode = phone.trim().replace(/\D/g, '').slice(-6) || Math.random().toString(36).slice(2, 8);
    const refLink = `https://unify-lake.vercel.app/ref/${refCode}`;
    const waText = encodeURIComponent(`Bro 👀 I just claimed my spot on UNIFY — Ghana's fresher network for ${schoolLabel}. Find roommates, link with coursemates, and join your campus hub before matriculation. It's free fr. Join via my link: ${refLink}`);
    return (
      <div className="flex flex-col gap-3">
        <div className="flex items-center gap-3 bg-green-50 border border-green-200 rounded-2xl px-5 py-4">
          <CheckCircle className="text-green-600 w-5 h-5 flex-shrink-0" />
          <div>
            <p className="text-green-800 font-bold text-sm">You&apos;re on the list! 🎉</p>
            <p className="text-green-700/60 text-xs mt-0.5">We&apos;ll hit you 48hrs before your {schoolLabel} hub opens.</p>
          </div>
        </div>
        <div className="bg-white/60 backdrop-blur-sm border border-white/70 rounded-2xl px-4 py-3">
          <p className="text-[10px] font-bold text-[#9CA3AF] uppercase tracking-widest mb-2">Your referral link</p>
          <div className="flex items-center gap-2">
            <span className="flex-1 text-xs text-[#0066FF] font-mono truncate">{refLink}</span>
            <CopyButton text={refLink} />
          </div>
          <p className="text-[10px] text-[#9CA3AF] mt-2">Every friend who joins via your link moves you up the waitlist.</p>
        </div>
        <a
          href={`https://wa.me/?text=${waText}`}
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center justify-center gap-2.5 bg-[#25D366]/10 hover:bg-[#25D366]/20 border border-[#25D366]/30 text-[#25D366] font-black text-sm px-5 py-3.5 rounded-full transition-all active:scale-95"
        >
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current flex-shrink-0">
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
          </svg>
          Share your referral link on WhatsApp
        </a>
      </div>
    );
  }

  return (
    <form id={id} onSubmit={handleSubmit} className="flex flex-col gap-2.5">
      <p className="text-[11px] font-bold text-[#9CA3AF] uppercase tracking-widest mb-0.5">Pick your school</p>
      <div className={`flex flex-wrap gap-2 p-2 rounded-2xl border transition-colors ${noSchool ? 'border-red-300 bg-red-50' : 'border-transparent'}`}>
        {SCHOOLS.map((s) => (
          <button
            key={s.id}
            type="button"
            onClick={() => { setSchool(s.id); setNoSchool(false); }}
            className={`text-xs font-black px-3.5 py-2 rounded-full border transition-all ${
              school === s.id
                ? 'bg-[#0066FF] text-white border-[#0066FF]'
                : 'bg-white/60 backdrop-blur-sm text-[#6B7280] border-white/70 hover:border-[#0066FF] hover:text-[#0066FF]'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>
      {noSchool && <p className="text-[11px] text-red-500 pl-1">Please select your school first</p>}
      <div className="flex flex-col sm:flex-row gap-2.5 mt-1">
        <input
          type="text"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          placeholder="Enter phone number (e.g., 055...)"
          required
          className="flex-1 bg-white/70 backdrop-blur-sm border border-white/60 rounded-full px-5 py-3.5 text-sm text-[#111827] placeholder-[#9CA3AF] outline-none focus:bg-white/90 focus:border-[#0066FF]/60 focus:ring-2 focus:ring-[#0066FF]/10 transition-all"
        />
        <button
          type="submit"
          disabled={loading}
          className="bg-[#1F2937] hover:bg-[#111827] active:scale-95 disabled:opacity-60 text-white font-black text-sm px-7 py-3.5 rounded-full transition-all hover:-translate-y-0.5 whitespace-nowrap shadow-[0_4px_14px_rgba(31,41,55,0.35)] hover:shadow-[0_8px_24px_rgba(31,41,55,0.45)]"
        >
          {loading ? 'Saving...' : 'Claim Your Handle →'}
        </button>
      </div>
      {error && <p className="text-[11px] text-red-500 pl-1">{error}</p>}
    </form>
  );
}

function Ticker() {
  const items = [...TICKER_ITEMS, ...TICKER_ITEMS];
  return (
    <div className="overflow-hidden bg-white/50 backdrop-blur-sm border-y border-white/40 py-3 relative">
      <div className="pointer-events-none absolute left-0 top-0 bottom-0 w-20 z-10 bg-gradient-to-r from-white/50 to-transparent" />
      <div className="pointer-events-none absolute right-0 top-0 bottom-0 w-20 z-10 bg-gradient-to-l from-white/50 to-transparent" />
      <div className="flex gap-10 whitespace-nowrap w-max animate-[ticker_35s_linear_infinite]">
        {items.map((item, i) => (
          <span key={i} className="text-[11px] font-semibold text-[#6B7280] tracking-wide">
            {item}
          </span>
        ))}
      </div>
    </div>
  );
}

function ExitModal() {
  const [visible, setVisible] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    const onMouseLeave = (e) => {
      if (e.clientY <= 0 && !dismissed) setVisible(true);
    };
    document.addEventListener('mouseleave', onMouseLeave);
    return () => document.removeEventListener('mouseleave', onMouseLeave);
  }, [dismissed]);

  const close = () => { setVisible(false); setDismissed(true); };

  if (!visible) return null;

  return (
    <div className="hidden md:flex fixed inset-0 z-[100] items-center justify-center px-6" onClick={close}>
      <div className="absolute inset-0 bg-black/30 backdrop-blur-sm" />
      <div
        className="relative bg-white/80 backdrop-blur-2xl border border-white/70 rounded-3xl max-w-lg w-full shadow-xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="h-1 w-full bg-gradient-to-r from-red-600 via-[#FF6B35] to-green-600" />
        <div className="p-8">
          <button
            onClick={close}
            className="absolute top-5 right-5 w-8 h-8 flex items-center justify-center rounded-full bg-white/60 backdrop-blur-sm hover:bg-white/80 text-[#9CA3AF] hover:text-[#111827] text-lg transition-all"
            aria-label="Close"
          >
            ×
          </button>
          <div className="flex items-start gap-4 mb-6">
            <span className="text-3xl">👀</span>
            <div>
              <h3 className="text-xl font-black text-[#111827] leading-tight mb-1">
                Hold on — your spot isn&apos;t saved yet.
              </h3>
              <p className="text-[#6B7280] text-sm leading-relaxed">
                Freshers who sign up early get 48-hour priority access before their school hub opens to everyone.
              </p>
            </div>
          </div>
          <div className="border-t border-white/30 mb-6" />
          <WaitlistForm id="exit-form" />
          <p className="text-[11px] text-[#9CA3AF] mt-4 text-center">
            🔒 Free forever · No spam · Built by Ghanaians
          </p>
        </div>
      </div>
    </div>
  );
}

function StickyBar() {
  const [visible, setVisible] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    const onScroll = () => setVisible(window.scrollY > 500);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  if (dismissed || !visible) return null;

  return (
    <div className="md:hidden fixed bottom-0 left-0 right-0 z-50 px-4 pb-5 pt-3">
      <div className="flex items-center gap-2 bg-white/75 backdrop-blur-2xl border border-white/60 shadow-lg rounded-full px-4 py-3">
        <div className="flex-1 min-w-0">
          <p className="text-xs font-black text-[#111827] truncate">Secure your spot 🎓</p>
          <p className="text-[10px] text-[#6B7280] truncate">Join Ghana&apos;s fresher network — free</p>
        </div>
        <a
          href="#waitlist"
          className="bg-[#1F2937] hover:bg-[#111827] text-white font-black text-xs px-4 py-2.5 rounded-full whitespace-nowrap flex-shrink-0 active:scale-95 transition-all shadow-[0_4px_14px_rgba(31,41,55,0.35)]"
        >
          Claim Handle →
        </a>
        <button
          onClick={() => setDismissed(true)}
          className="text-[#9CA3AF] hover:text-[#6B7280] text-lg leading-none flex-shrink-0 pl-1"
          aria-label="Dismiss"
        >
          ×
        </button>
      </div>
    </div>
  );
}

// ─── PHONE MOCKUP ─────────────────────────────────────────────────────────────

function PhoneMockup() {
  return (
    <div className="relative w-64 h-[520px] mx-auto">
      <div className="absolute inset-0 rounded-[40px] bg-white/70 backdrop-blur-xl border border-white/60 shadow-[0_30px_60px_rgba(0,66,255,0.15)]" />
      <div className="absolute inset-[3px] rounded-[38px] overflow-hidden bg-white/85 backdrop-blur-xl p-4 flex flex-col gap-3">
        <div className="flex justify-between text-[10px] text-[#9CA3AF] px-1">
          <span>9:41</span><span>●●●</span>
        </div>
        <div className="text-[#111827] text-sm font-bold">Find your campus fam 👋</div>
        {[
          { name: 'Ama O.', school: 'KNUST', tag: 'Roommate' },
          { name: 'Kofi B.', school: 'UG Legon', tag: 'Coursemates' },
        ].map((p) => (
          <div key={p.name} className="bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.8)] rounded-2xl p-3 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/20 flex items-center justify-center text-xs font-bold text-[#0066FF]">
              {p.name[0]}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[#111827] text-xs font-semibold">{p.name}</p>
              <p className="text-[#9CA3AF] text-[10px]">{p.school}</p>
            </div>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/20 text-[#0066FF]">{p.tag}</span>
          </div>
        ))}
        <div className="bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08)] rounded-2xl p-3">
          <p className="text-[#9CA3AF] text-[10px] mb-2">YOUR HUB</p>
          <p className="text-[#111827] text-xs font-bold">KNUST Brunei Hub</p>
          <p className="text-[#9CA3AF] text-[10px]">420 freshers · Active</p>
          <div className="mt-2 w-full bg-[#1F2937] text-white text-[10px] font-black rounded-full py-1 text-center">Join Hub →</div>
        </div>
        <div className="mt-auto bg-[#0066FF]/8 border border-[#0066FF]/15 rounded-2xl p-3 text-center">
          <p className="text-[#0066FF] text-xs font-black">#247 on waitlist</p>
          <p className="text-[#9CA3AF] text-[10px]">Refer friends to move up</p>
        </div>
      </div>
    </div>
  );
}

// ─── GHANA MAP VIZ ────────────────────────────────────────────────────────────

function GhanaMapViz() {
  return (
    <div className="relative w-full h-72 md:h-full min-h-[300px]">
      <div className="absolute inset-0 flex items-center justify-center">
        <svg viewBox="0 0 200 240" className="h-full w-auto opacity-10 fill-[#111827]">
          <path d="M60,10 L140,10 L160,30 L170,60 L165,90 L170,120 L160,150 L155,180 L140,200 L120,220 L100,230 L80,220 L60,200 L45,180 L40,150 L30,120 L35,90 L30,60 L40,30 Z" />
        </svg>
      </div>
      {/* Pin: UG Legon */}
      <div className="absolute bottom-8 right-8 bg-white/70 backdrop-blur-sm border border-white/80 rounded-2xl p-2 flex items-center gap-2 shadow-sm">
        <div className="w-8 h-8 rounded-full bg-[#0066FF]/10 flex items-center justify-center text-[#0066FF] font-bold text-xs">U</div>
        <div>
          <p className="text-[#111827] text-xs font-bold">UG Legon</p>
          <p className="text-[#6B7280] text-[10px]">310 freshers</p>
        </div>
      </div>
      {/* Pin: KNUST */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-white/70 backdrop-blur-sm border border-white/80 rounded-2xl p-2 flex items-center gap-2 shadow-sm">
        <div className="w-8 h-8 rounded-full bg-[#0066FF]/10 flex items-center justify-center text-[#0066FF] font-bold text-xs">K</div>
        <div>
          <p className="text-[#111827] text-xs font-bold">KNUST Hub</p>
          <p className="text-[#6B7280] text-[10px]">420 freshers</p>
        </div>
      </div>
      {/* Pin: UCC */}
      <div className="absolute bottom-16 left-6 bg-white/70 backdrop-blur-sm border border-white/80 rounded-2xl p-2 flex items-center gap-2 shadow-sm">
        <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center text-green-700 font-bold text-xs">C</div>
        <div>
          <p className="text-[#111827] text-xs font-bold">UCC Hub</p>
          <p className="text-[#6B7280] text-[10px]">185 freshers</p>
        </div>
      </div>
    </div>
  );
}

// ─── FAQ ACCORDION ────────────────────────────────────────────────────────────

function FAQAccordion({ items }) {
  const [open, setOpen] = useState(null);
  return (
    <div className="flex flex-col divide-y divide-white/30">
      {items.map((faq, i) => (
        <div key={i} className="py-4">
          <button
            className="w-full text-left flex items-center justify-between gap-4"
            onClick={() => setOpen(open === i ? null : i)}
          >
            <span className="font-semibold text-sm text-[#111827]">{faq.q}</span>
            <span className={`flex-shrink-0 w-6 h-6 rounded-full border border-[#0066FF]/40 flex items-center justify-center transition-transform duration-200 ${open === i ? 'rotate-180 bg-[#0066FF]/10' : ''}`}>
              <ChevronDown className="w-3.5 h-3.5 text-[#0066FF]" />
            </span>
          </button>
          {open === i && (
            <p className="text-sm text-[#6B7280] leading-relaxed mt-3 pr-8">{faq.a}</p>
          )}
        </div>
      ))}
    </div>
  );
}

// ─── MAIN COMPONENT ──────────────────────────────────────────────────────────

export default function UnifyLanding({ schoolId } = {}) {
  const count = useSignupCount();
  const [faqPhone, setFaqPhone] = useState('');
  const [faqDone, setFaqDone] = useState(false);
  const [faqLoading, setFaqLoading] = useState(false);

  const sc = SCHOOL_CONFIG[schoolId] || null;
  const heroHeadline = sc ? sc.headline : "Don't Pull Up To Campus Alone,";

  const handleFaqSubmit = async (e) => {
    e.preventDefault();
    if (!faqPhone.trim()) return;
    setFaqLoading(true);
    try {
      const params = new URLSearchParams({ phone: faqPhone.trim(), school: 'general', ts: new Date().toISOString() });
      await fetch(`${SHEET_URL}?${params}`, { method: 'GET', mode: 'no-cors' });
      setFaqDone(true);
    } catch {
      // silent
    } finally {
      setFaqLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen p-4 md:p-8 antialiased"
         style={{ background: 'linear-gradient(135deg, #EEF1F8 0%, #D1D5DB 50%, #E8EEFF 100%)', fontFamily: "'Inter', system-ui, sans-serif" }}>

      <style>{`
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(28px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes slideRight {
          from { opacity: 0; transform: translateX(-20px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes scaleIn {
          from { opacity: 0; transform: scale(0.93); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes glowPulse {
          0%, 100% { box-shadow: 0 0 20px rgba(0,102,255,0.15); }
          50%       { box-shadow: 0 0 40px rgba(0,102,255,0.30); }
        }
        @keyframes floatBadge {
          0%, 100% { transform: translateY(0px); }
          50%       { transform: translateY(-6px); }
        }
        .anim-fade-up    { animation: fadeUp 0.6s ease-out both; }
        .anim-slide-right { animation: slideRight 0.6s ease-out both; }
        .anim-scale-in   { animation: scaleIn 0.5s ease-out both; }
        .anim-glow       { animation: glowPulse 3s ease-in-out infinite; }
        .anim-float      { animation: floatBadge 4s ease-in-out infinite; }
        .delay-100 { animation-delay: 0.1s; }
        .delay-200 { animation-delay: 0.2s; }
        .delay-300 { animation-delay: 0.3s; }
        .delay-400 { animation-delay: 0.4s; }
        .delay-500 { animation-delay: 0.5s; }
      `}</style>

      {/* Fixed ambient blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
        <div className="absolute -top-1/4 -right-1/4 w-[700px] h-[700px] rounded-full bg-[#0066FF]/[0.07] blur-[120px]" />
        <div className="absolute -bottom-1/4 -left-1/4 w-[600px] h-[600px] rounded-full bg-indigo-400/[0.06] blur-[100px]" />
        <div className="absolute top-1/3 left-1/3 w-[400px] h-[400px] rounded-full bg-blue-200/[0.05] blur-[80px]" />
      </div>

      {/* Browser wrapper */}
      <div className="max-w-7xl mx-auto bg-white/75 backdrop-blur-2xl border border-white/60 shadow-[0_40px_100px_rgba(0,66,255,0.10),0_0_0_1px_rgba(255,255,255,0.5)] rounded-[32px] overflow-hidden">

        {/* ── NAVIGATION ──────────────────────────────────────────────── */}
        <nav className="sticky top-0 z-50 bg-white/60 backdrop-blur-2xl border-b border-white/50">
          <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-lg font-black tracking-tight text-[#111827]">UNIFY</span>
              <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/25 text-[#0066FF]">GH</span>
            </div>
            <div className="hidden md:flex items-center gap-6 text-sm text-[#111827]/70 font-medium">
              <a href="#" className="relative text-[#111827] font-semibold">
                Home
                <span className="absolute -bottom-0.5 left-0 right-0 h-0.5 rounded-full bg-[#0066FF]" />
              </a>
              <a href="/hubs" className="hover:text-[#111827] transition-colors">Hubs</a>
              <a href="/match" className="hover:text-[#111827] transition-colors">Match</a>
              <a href="#schools" className="hover:text-[#111827] transition-colors">Schools</a>
              <a href="#faq" className="hover:text-[#111827] transition-colors">FAQ</a>
            </div>
            <div className="flex items-center gap-2">
              <button className="hidden md:inline-flex text-sm font-semibold text-[#111827] px-4 py-2 rounded-full border border-white/60 bg-white/60 backdrop-blur-sm hover:border-[#111827] transition-colors">
                Sign In
              </button>
              <a
                href="#waitlist"
                className="bg-[#1F2937] hover:bg-[#111827] text-white text-xs font-black px-4 py-2.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)]"
              >
                Get Early Access →
              </a>
            </div>
          </div>
        </nav>

        {/* ── HERO — 55/45 asymmetric ─────────────────────────────────── */}
        <section className="bg-white pt-16 md:pt-24 pb-12 md:pb-20 px-6">
          <div className="max-w-6xl mx-auto grid md:grid-cols-[55fr_45fr] gap-10 md:gap-16 items-center">
            {/* Left */}
            <div className="anim-slide-right">
              <div className="anim-float inline-flex items-center gap-2 bg-[#0066FF]/8 border border-[#0066FF]/20 text-[#0066FF] text-xs font-bold px-3.5 py-2 rounded-full mb-7">
                <span className="w-1.5 h-1.5 rounded-full bg-[#0066FF] animate-pulse" />
                {sc ? sc.badge : "Built for Ghana's Freshers · Launching 2026"}
              </div>

              <div className="flex items-start gap-3 mb-2">
                <h1 className="anim-fade-up delay-100 text-[2.4rem] md:text-[3.4rem] font-black leading-[1.05] tracking-tight text-[#111827]">
                  {heroHeadline}
                  <br />
                  <span className="text-[#0066FF]">fr.</span>
                </h1>
                <BlueDoodle />
              </div>
              <SquiggleUnderline />

              <p className="anim-fade-up delay-200 text-base md:text-lg text-[#6B7280] leading-relaxed mb-8 max-w-[440px] mt-5">
                {sc ? sc.sub : "The ZeeMee for Ghana. Find your roommate, link with coursemates, and tap into your official campus hub before matriculation."}
              </p>

              <a
                href="#waitlist"
                className="anim-fade-up delay-300 anim-glow inline-flex items-center gap-2 bg-[#1F2937] hover:bg-[#111827] text-white font-black text-base px-8 py-4 rounded-full transition-all hover:-translate-y-0.5 hover:shadow-xl hover:shadow-[#1F2937]/20 mb-7 shadow-[0_4px_14px_rgba(31,41,55,0.35)]"
              >
                Get Early Access <ArrowRight className="w-4 h-4" />
              </a>

              <div className="anim-fade-up delay-400 flex items-center gap-3 mb-5">
                <div className="flex -space-x-2">
                  {['KA', 'YM', 'FA', 'EB', 'AO'].map((i) => (
                    <div
                      key={i}
                      className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-blue-700 border-2 border-white/60 flex items-center justify-center text-[8px] font-black text-white"
                    >
                      {i}
                    </div>
                  ))}
                </div>
                <p className="text-sm text-[#6B7280]">
                  <strong className="text-[#111827] font-bold">{count ? `${count.toLocaleString()}+` : '12,400+'}</strong> freshers already holding their spot
                </p>
              </div>

              <div className="flex flex-wrap gap-2">
                {['✓ 100% Free', '✓ Works on 2G', '✓ Verified students'].map((t) => (
                  <span key={t} className="text-[11px] font-semibold text-[#6B7280] bg-white/60 backdrop-blur-sm border border-white/70 px-3 py-1 rounded-full">
                    {t}
                  </span>
                ))}
              </div>
            </div>

            {/* Right: phone mockup */}
            <div className="hidden md:block anim-scale-in delay-300">
              <PhoneMockup />
            </div>
          </div>
        </section>

        {/* ── TICKER ──────────────────────────────────────────────────── */}
        <Ticker />

        {/* ── STATS BAR ───────────────────────────────────────────────── */}
        <div className="bg-[#0066FF]/90 backdrop-blur-xl py-10 px-6">
          <div className="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-6 text-center divide-x divide-white/20">
            {[
              { num: '180+', label: 'Universities' },
              { num: '12K+', label: 'Freshers Waiting' },
              { num: '847',  label: 'Roommates Matched' },
              { num: '4.8',  label: 'Overall Rating' },
            ].map((s) => (
              <div key={s.label} className="px-4 anim-scale-in">
                <p className="text-3xl md:text-4xl font-black text-white">{s.num}</p>
                <p className="text-white/70 text-sm mt-1">{s.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* ── FEATURES ────────────────────────────────────────────────── */}
        <section id="features" className="bg-white py-16 md:py-28 px-6 border-t border-[#E5E7EB]">
          <div className="max-w-6xl mx-auto">
            <div className="grid md:grid-cols-2 gap-10 md:gap-16 items-start mb-14">
              <div>
                <div className="flex items-center gap-3 mb-4">
                  <BlueDoodle />
                  <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#0066FF]">Why UNIFY</span>
                </div>
                <h2 className="text-4xl md:text-5xl font-black text-[#111827] leading-tight mb-4">
                  That&apos;s The Way<br />To Fresher.
                </h2>
                <p className="text-[#6B7280] text-base leading-relaxed max-w-sm">
                  Not a copy-paste Western social app. Every decision built around the real Ghanaian fresher experience.
                </p>
              </div>

              <div className="flex flex-col gap-4">
                {[
                  { icon: <Users2 className="w-5 h-5 text-[#0066FF]" />, title: '180+ Campus Hubs', body: 'Official hubs for KNUST, UG Legon, UCC, UPSA and 180+ schools across Ghana.', delay: 'delay-100' },
                  { icon: <GraduationCap className="w-5 h-5 text-[#0066FF]" />, title: 'Habit-Matched Roommates', body: 'Our matching engine pairs you with compatible freshers before orientation chaos starts.', delay: 'delay-200' },
                  { icon: <Building2 className="w-5 h-5 text-[#0066FF]" />, title: 'Verified Students Only', body: 'Every profile is ID-verified. No fake accounts, no strangers — just real Ghana freshers.', delay: 'delay-300' },
                ].map((f) => (
                  <div key={f.title} className={`anim-fade-up ${f.delay} bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.8)] rounded-3xl p-6 flex items-start gap-4 hover:bg-white/80 hover:-translate-y-1.5 hover:shadow-[0_16px_48px_rgba(0,0,0,0.12)] transition-all duration-300`}>
                    <div className="w-11 h-11 rounded-2xl bg-[#0066FF]/8 border border-[#0066FF]/15 flex items-center justify-center flex-shrink-0">
                      {f.icon}
                    </div>
                    <div>
                      <h3 className="font-black text-[#111827] mb-1">{f.title}</h3>
                      <p className="text-sm text-[#6B7280] leading-relaxed">{f.body}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Ghana map visualization */}
            <div className="relative rounded-3xl overflow-hidden bg-white/40 backdrop-blur-sm border border-white/30 p-6 h-72">
              <GhanaMapViz />
              <div className="absolute top-4 left-6">
                <p className="text-[10px] font-bold uppercase tracking-widest text-[#9CA3AF]">Campus Map · Ghana</p>
              </div>
            </div>
          </div>
        </section>

        {/* ── SCHOOL SEARCH ────────────────────────────────────────────── */}
        <section id="schools" className="bg-white py-16 md:py-28 px-6 border-t border-[#E5E7EB]">
          <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-10 md:gap-16 items-center">
            <div className="hidden md:block h-80 rounded-3xl overflow-hidden bg-white/40 backdrop-blur-sm border border-white/30 relative">
              <GhanaMapViz />
            </div>
            <div className="relative">
              <BlueSwirl className="absolute -right-4 top-0" />
              <h2 className="text-4xl md:text-5xl font-black text-[#111827] leading-tight mb-4">
                Find Your Campus,<br />Find Your People.
              </h2>
              <p className="text-[#6B7280] text-base leading-relaxed mb-7">
                Browse 180+ Ghana universities. Pick your school and claim your handle before your classmates do.
              </p>
              <div className="flex items-center gap-2 bg-white/70 backdrop-blur-sm border border-white/60 rounded-2xl shadow-sm p-2 pl-5 mb-5">
                <MapPin className="w-4 h-4 text-[#FF6B35] shrink-0" />
                <select className="flex-1 bg-transparent text-[#111827] text-sm outline-none">
                  <option value="">Choose your school</option>
                  <option>KNUST</option>
                  <option>UG Legon</option>
                  <option>UCC</option>
                  <option>UPSA</option>
                  <option>UDS</option>
                  <option>GCTU</option>
                </select>
                <a
                  href="/hubs"
                  className="bg-[#1F2937] text-white font-black text-sm px-5 py-2 rounded-full hover:bg-[#111827] transition-colors whitespace-nowrap shadow-[0_4px_14px_rgba(31,41,55,0.35)]"
                >
                  Find Hub →
                </a>
              </div>
              <div className="flex flex-wrap gap-3">
                <a href="/hubs" className="inline-flex items-center gap-1.5 text-sm font-semibold text-[#6B7280] hover:text-[#111827] px-4 py-2 rounded-full border border-white/60 bg-white/60 backdrop-blur-sm hover:border-[#111827] transition-all">
                  Browse all hubs <ArrowRight className="w-3.5 h-3.5" />
                </a>
                <a href="/match" className="inline-flex items-center gap-1.5 text-sm font-semibold text-[#6B7280] hover:text-[#111827] px-4 py-2 rounded-full border border-white/60 bg-white/60 backdrop-blur-sm hover:border-[#111827] transition-all">
                  Find a roommate <ArrowRight className="w-3.5 h-3.5" />
                </a>
              </div>
            </div>
          </div>
        </section>

        {/* ── COMMUNITY ────────────────────────────────────────────────── */}
        <section className="bg-white py-16 md:py-28 px-6 border-t border-[#E5E7EB]">
          <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-10 md:gap-16 items-center">
            <div>
              <div className="flex items-center gap-3 mb-4">
                <OrangeDoodle />
                <Sparkles className="w-5 h-5 text-[#FF6B35]" />
              </div>
              <h2 className="text-4xl md:text-5xl font-black text-[#111827] leading-tight mb-4">
                Your Campus Fam<br />Is Calling.
                <br />
                <span className="text-[#6B7280] text-3xl md:text-4xl font-bold">Don&apos;t Miss Orientation.</span>
              </h2>
              <p className="text-[#6B7280] text-base leading-relaxed mb-8">
                Join the official WhatsApp community for your school. Real freshers, real intel, zero spam.
              </p>
              <a
                href="https://wa.me/233000000000"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 bg-[#1F2937] hover:bg-[#111827] text-white font-black text-sm px-7 py-3.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)]"
              >
                <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                </svg>
                Join Community →
              </a>
            </div>

            <div className="relative h-72 flex items-center justify-center">
              {[
                { initials: 'AA', bg: 'bg-blue-100', text: 'text-blue-700', top: '10%', left: '30%' },
                { initials: 'KB', bg: 'bg-green-100', text: 'text-green-700', top: '10%', left: '55%' },
                { initials: 'SM', bg: 'bg-purple-100', text: 'text-purple-700', top: '38%', left: '15%' },
                { initials: 'EO', bg: 'bg-orange-100', text: 'text-orange-700', top: '38%', left: '42%' },
                { initials: 'FA', bg: 'bg-pink-100', text: 'text-pink-700', top: '38%', left: '68%' },
                { initials: 'YM', bg: 'bg-cyan-100', text: 'text-cyan-700', top: '65%', left: '30%' },
              ].map((a) => (
                <div
                  key={a.initials}
                  className={`absolute w-12 h-12 rounded-full ${a.bg} border-2 border-white/60 flex items-center justify-center text-xs font-black ${a.text} shadow-sm`}
                  style={{ top: a.top, left: a.left }}
                >
                  {a.initials}
                </div>
              ))}
              <div className="absolute top-2 right-0 bg-white/70 backdrop-blur-sm border border-white/80 rounded-2xl rounded-tl-sm px-3 py-1.5 text-xs font-semibold text-[#111827] shadow-sm">
                Already linked! 🔥
              </div>
              <div className="absolute bottom-8 right-4 bg-[#0066FF]/8 border border-[#0066FF]/20 rounded-2xl rounded-br-sm px-3 py-1.5 text-xs font-semibold text-[#0066FF] shadow-sm">
                Found my roomie!
              </div>
              <div className="absolute bottom-2 left-0 bg-white/70 backdrop-blur-sm border border-white/80 rounded-2xl rounded-bl-sm px-3 py-1.5 text-xs font-semibold text-[#111827] shadow-sm">
                Best app fr 🇬🇭
              </div>
              <div className="absolute top-1/2 right-0 -translate-y-1/2 flex flex-col gap-2">
                {['W', 'IG', 'X'].map((s) => (
                  <div key={s} className="w-8 h-8 rounded-full bg-white/60 backdrop-blur-sm border border-white/70 flex items-center justify-center text-[9px] font-black text-[#6B7280]">
                    {s}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* ── TESTIMONIALS ─────────────────────────────────────────────── */}
        <section className="bg-white py-16 md:py-28 px-6 border-t border-[#E5E7EB]">
          <div className="max-w-6xl mx-auto">
            <div className="flex items-center justify-between mb-10">
              <div>
                <div className="flex items-center gap-3 mb-2">
                  <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#0066FF]">Reviews</span>
                  <Star className="w-4 h-4 text-[#0066FF]" />
                </div>
                <h2 className="text-4xl md:text-5xl font-black text-[#111827]">
                  Satisfied Freshers Are<br />Our Best Ads.
                </h2>
              </div>
              <div className="hidden md:flex items-center gap-2">
                <button className="w-10 h-10 rounded-full border border-white/60 bg-white/60 backdrop-blur-sm hover:border-[#111827] flex items-center justify-center text-[#111827] transition-all">
                  ←
                </button>
                <button className="w-10 h-10 rounded-full border border-white/60 bg-white/60 backdrop-blur-sm hover:border-[#111827] flex items-center justify-center text-[#111827] transition-all">
                  →
                </button>
              </div>
            </div>
            <div className="grid md:grid-cols-3 gap-5">
              {TESTIMONIALS.map((t) => (
                <div key={t.name} className="bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.8)] rounded-3xl p-8 flex flex-col hover:bg-white/80 hover:-translate-y-1.5 hover:shadow-[0_16px_48px_rgba(0,0,0,0.12)] transition-all duration-300">
                  <div className="text-6xl font-black text-[#0066FF] leading-none mb-4">&ldquo;</div>
                  <p className="text-[#6B7280] text-sm leading-relaxed flex-1 mb-6">{t.quote}</p>
                  <div className="border-t border-white/30 pt-5 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/20 flex items-center justify-center text-xs font-black text-[#0066FF] flex-shrink-0">
                      {t.initials}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-[#111827] text-sm">{t.name}</p>
                      <p className="text-[#9CA3AF] text-xs">{t.role}</p>
                    </div>
                    <div className="text-[#FF6B35] text-xs">
                      {'⭐'.repeat(t.stars)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── WAITLIST CTA ─────────────────────────────────────────────── */}
        <section id="waitlist" className="bg-[#F9FAFB] py-16 md:py-28 px-6 border-t border-[#E5E7EB]">
          <div className="max-w-2xl mx-auto text-center">
            <span className="text-5xl block mb-6">🇬🇭</span>
            <div className="inline-flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 text-xs font-bold px-4 py-2 rounded-full mb-7">
              <CheckCircle className="w-3.5 h-3.5" strokeWidth={2} />
              100% free · No subscriptions · Ever
            </div>
            <h2 className="text-4xl md:text-5xl font-black text-[#111827] tracking-tight mb-5 leading-tight">
              Stop hunting for broken<br />
              <span className="text-[#0066FF]">WhatsApp group links.</span>
            </h2>
            <p className="text-[#6B7280] text-lg mb-10 max-w-md mx-auto leading-relaxed">
              Secure your spot in the official Class of &apos;30 network today. Your campus people are already inside.
            </p>
            <WaitlistForm id="cta-form" defaultSchool={schoolId || ''} />
            <p className="text-xs text-[#9CA3AF] mt-5">🔒 Free forever · No spam · Built by Ghanaians in Ghana</p>
          </div>
        </section>

        {/* ── FAQ + CONTACT ─────────────────────────────────────────────── */}
        <section id="faq" className="bg-white py-16 md:py-28 px-6 border-t border-[#E5E7EB]">
          <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-10 md:gap-16 items-start">
            <div className="relative">
              <BlueSwirl className="absolute -left-4 -top-4" />
              <div className="flex items-center gap-3 mb-4">
                <OrangeDoodle />
                <MessageCircle className="w-5 h-5 text-[#0066FF]" />
                <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#0066FF]">Get in touch</span>
              </div>
              <h2 className="text-4xl md:text-5xl font-black text-[#111827] leading-tight mb-4">
                Got A Question<br />For UNIFY?
              </h2>
              <p className="text-[#6B7280] text-base leading-relaxed mb-7">
                We&apos;ll answer everything. Drop your number and we&apos;ll reach out.
              </p>
              {faqDone ? (
                <div className="flex items-center gap-3 bg-green-50 border border-green-200 rounded-full px-5 py-4">
                  <CheckCircle className="text-green-600 w-5 h-5 flex-shrink-0" />
                  <p className="text-green-800 font-bold text-sm">Got it! We&apos;ll reach out soon. 🎉</p>
                </div>
              ) : (
                <form onSubmit={handleFaqSubmit} className="flex items-center bg-white/70 backdrop-blur-sm border border-white/60 rounded-full overflow-hidden pr-1.5 focus-within:bg-white/90 focus-within:border-[#0066FF]/60">
                  <input
                    type="text"
                    value={faqPhone}
                    onChange={(e) => setFaqPhone(e.target.value)}
                    placeholder="Your phone number..."
                    required
                    className="flex-1 bg-transparent px-5 py-3.5 text-sm text-[#111827] placeholder-[#9CA3AF] outline-none"
                  />
                  <button
                    type="submit"
                    disabled={faqLoading}
                    className="bg-[#1F2937] hover:bg-[#111827] text-white font-black text-sm px-5 py-2.5 rounded-full transition-colors disabled:opacity-60 whitespace-nowrap shadow-[0_4px_14px_rgba(31,41,55,0.35)]"
                  >
                    {faqLoading ? '...' : 'Submit'}
                  </button>
                </form>
              )}
            </div>

            <div>
              <p className="text-sm text-[#6B7280] mb-4">Check if your question is already answered:</p>
              <FAQAccordion items={FAQS_NEW} />
            </div>
          </div>
        </section>

        {/* ── FOOTER ──────────────────────────────────────────────────── */}
        <footer className="bg-[#0066FF]/95 backdrop-blur-xl px-6 pt-12 pb-8">
          <div className="max-w-6xl mx-auto">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-8 pb-10 border-b border-white/20">
              <div className="col-span-2 md:col-span-1">
                <div className="flex items-center gap-2 mb-3">
                  <span className="text-xl font-black text-white">UNIFY</span>
                  <span className="text-3xl">🇬🇭</span>
                </div>
                <p className="text-sm text-white/70 leading-relaxed max-w-[200px]">
                  Ghana&apos;s peer-to-peer university transition network.
                </p>
              </div>
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Explore</p>
                <div className="flex flex-col gap-2.5">
                  {[
                    { label: 'Home', href: '#' },
                    { label: 'Hubs', href: '/hubs' },
                    { label: 'Match', href: '/match' },
                    { label: 'Schools', href: '#schools' },
                  ].map((l) => (
                    <a key={l.label} href={l.href} className="text-sm text-white/80 hover:text-white transition-colors">{l.label}</a>
                  ))}
                </div>
              </div>
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Support</p>
                <div className="flex flex-col gap-2.5">
                  {['FAQ', 'Contact', 'Privacy', 'Terms'].map((l) => (
                    <a key={l} href="#" className="text-sm text-white/80 hover:text-white transition-colors">{l}</a>
                  ))}
                </div>
              </div>
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Connect</p>
                <div className="flex gap-2 mb-4">
                  {[
                    { label: 'WA', href: 'https://wa.me/233000000000' },
                    { label: 'IG', href: '#' },
                    { label: 'X', href: '#' },
                  ].map((s) => (
                    <a
                      key={s.label}
                      href={s.href}
                      className="w-9 h-9 rounded-full bg-white/10 border border-white/20 flex items-center justify-center text-[10px] font-black text-white hover:bg-white/20 transition-all"
                    >
                      {s.label}
                    </a>
                  ))}
                </div>
                <a href="mailto:hello@unify.gh" className="text-xs text-white/70 hover:text-white transition-colors">hello@unify.gh</a>
              </div>
            </div>
            <div className="flex flex-col md:flex-row items-center justify-between gap-3 pt-6">
              <p className="text-xs text-white/60">© 2026 UNIFY · Built for Ghana&apos;s freshers · Free forever</p>
              <p className="text-xs text-white/60">Connecting students at 180+ schools across Ghana</p>
            </div>
            <div className="mt-6 h-[3px] rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
          </div>
        </footer>

      </div>{/* end browser wrapper */}

      <StickyBar />
      <ExitModal />
    </div>
  );
}
