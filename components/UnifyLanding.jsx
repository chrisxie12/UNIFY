'use client';

/**
 * UNIFY — Ghana's peer-to-peer university transition network
 * Drop into Next.js (app or pages dir) or Vite + React.
 *
 * Dependencies:
 *   npm install lucide-react
 *   Tailwind CSS configured with the custom `ticker` animation below.
 *
 * Add to tailwind.config.js → theme.extend:
 *   animation: { ticker: 'ticker 35s linear infinite' },
 *   keyframes: { ticker: { '0%': { transform: 'translateX(0)' }, '100%': { transform: 'translateX(-50%)' } } },
 */

import { useState } from 'react';
import { Shield, Wifi, Building2, CheckCircle, MapPin, Users, ArrowRight } from 'lucide-react';

const SCHOOLS = [
  { id: 'knust', label: 'KNUST', full: 'Kwame Nkrumah University of Science & Technology' },
  { id: 'ug', label: 'UG Legon', full: 'University of Ghana' },
  { id: 'ucc', label: 'UCC', full: 'University of Cape Coast' },
  { id: 'upsa', label: 'UPSA', full: 'University of Professional Studies' },
  { id: 'uds', label: 'UDS', full: 'University for Development Studies' },
  { id: 'gctu', label: 'GCTU', full: 'Ghana Communication Technology University' },
];

const HOW_STEPS = [
  {
    step: '01',
    title: 'Pick your school & claim your handle',
    body: 'Select your campus — KNUST, Legon, UCC, UPSA, and more. Drop your number. Your handle is reserved before the hub goes live.',
    color: 'text-amber-400', bg: 'bg-amber-400/10 border-amber-400/20',
  },
  {
    step: '02',
    title: 'Set your profile & match with roommates',
    body: 'Tell us your hostel pref, sleep schedule, and vibe. We match you with freshers who actually fit — no brokers, no group chat chaos.',
    color: 'text-blue-400', bg: 'bg-blue-400/10 border-blue-400/20',
  },
  {
    step: '03',
    title: 'Join your campus hub before day one',
    body: 'Your school hub drops 48hrs before matriculation. Link with coursemates, get real hostel intel, and walk in knowing people.',
    color: 'text-green-400', bg: 'bg-green-400/10 border-green-400/20',
  },
];

// ─── DATA ────────────────────────────────────────────────────────────────────

const TICKER_ITEMS = [
  '🔥 45 freshers from Prempeh College just claimed their handles',
  '⚡️ 120 roomies matched for KNUST Brunei & Kotei hostels',
  '🎓 Legon Class of \'30 hubs are officially live',
  '🔥 32 girls just joined the Volta Hall fresher network',
  '⚡️ Avoid the portal rush — 210 students linked up early',
  '🏠 Evandy & TF hostel threads trending in UCC hub',
  '🎓 KNUST Engineering Circle just hit 88 verified members',
  '🔥 UPSA Business fresher hub is growing fast — claim your spot',
  '⚡️ 67 Law freshers linked up at Legon before lectures even start',
  '🏠 Katanga & Unity Hall residents dropping real hostel intel',
  '🎓 Achimota Class of \'30 placement group: 340 members and counting',
  '🔥 Wesley Girls intake crew already planning Legon orientation week',
];

const FRESHERS = [
  {
    initials: 'AA',
    name: 'Akosua A.',
    age: 18,
    from: 'Aburi Girls, Eastern Region',
    school: 'UG Legon',
    program: 'BSc Business Administration',
    cohort: "Fresher '30",
    bio: "Looking for a neat roomie for Volta or Limann. I sleep early, so no loud music at night please! Let's link up before orientation week.",
    hostelPref: 'Volta Hall or Limann Hall',
    lookingFor: 'Roommate',
    tags: ['Neat Freak', 'Early Sleeper', 'Business Vibes'],
    avatarBg: 'from-blue-900 to-blue-700',
    online: true,
    accentColor: 'text-blue-400',
    borderColor: 'border-blue-500/20',
    tagBg: 'bg-blue-500/10 text-blue-300 border-blue-500/20',
  },
  {
    initials: 'KB',
    name: 'Kwaku B.',
    age: 19,
    from: 'Prempeh College, Kumasi',
    school: 'KNUST',
    program: 'BSc Computer Science',
    cohort: "Fresher '30",
    bio: "Staying around Kotei or Brunei. Looking for fellow tech heads to code with and split Uber rides to campus. Hit me up, no cap.",
    hostelPref: 'Kotei or Brunei area',
    lookingFor: 'Roommate + Code partner',
    tags: ['Tech Head', 'Night Coder', 'Uber Splitter'],
    avatarBg: 'from-green-900 to-green-700',
    online: true,
    accentColor: 'text-green-400',
    borderColor: 'border-green-500/20',
    tagBg: 'bg-green-500/10 text-green-300 border-green-500/20',
  },
  {
    initials: 'SM',
    name: 'Selorm M.',
    age: 18,
    from: 'Ho Senior High School',
    school: 'UCC',
    program: 'BSc Nursing',
    cohort: "Fresher '30",
    bio: "Admitted to Casford area. Looking for serious study partners and course mates. Let's pass these mid-sems early and actually enjoy campus life.",
    hostelPref: 'Casford Hall area',
    lookingFor: 'Study partner + Coursemates',
    tags: ['Future Nurse', 'Study First', 'Serious Vibes'],
    avatarBg: 'from-purple-900 to-purple-700',
    online: false,
    accentColor: 'text-purple-400',
    borderColor: 'border-purple-500/20',
    tagBg: 'bg-purple-500/10 text-purple-300 border-purple-500/20',
  },
];

const PILLARS = [
  {
    Icon: Shield,
    title: 'Vibe-Checked Roommates',
    subtitle: 'No brokers. No gambling.',
    body: 'Stop gambling on random hall allocation or paying sketchy middle-men brokers. Filter by habits — neatness, study vibes, and lights-out schedules — and lock down a reliable roommate before you even pack your bags.',
    tags: ['Habit-matched', 'Broker-free', 'Verified ID'],
    iconColor: 'text-green-400',
    cardBg: 'bg-green-400/[0.04] border-green-400/20',
    tagStyle: 'bg-green-400/10 text-green-300 border-green-400/20',
  },
  {
    Icon: Building2,
    title: 'Real Campus Ground Truth',
    subtitle: 'Unedited. From current students.',
    body: 'Get the unedited breakdown on halls and hostels — from Evandy, TF, and Limann to Katanga and Unity. Continuing students drop the real info on water consistency, light issues, and how to navigate freshman year smoothly.',
    tags: ['Evandy', 'TF Hostel', 'Katanga', 'Unity Hall', 'Limann'],
    iconColor: 'text-amber-400',
    cardBg: 'bg-amber-400/[0.04] border-amber-400/20',
    tagStyle: 'bg-amber-400/10 text-amber-300 border-amber-400/20',
  },
  {
    Icon: Wifi,
    title: 'No Data Anxiety',
    subtitle: 'Under 5MB. MTN or Telecel.',
    body: 'We know how fast a video-heavy app eats your data bundle. UNIFY is built from scratch to be ultra-lightweight (under 5MB). It loads instantly even when campus network lines are completely jammed on MTN or Telecel.',
    tags: ['< 5MB', 'MTN ready', 'Telecel ready', 'Offline mode'],
    iconColor: 'text-sky-400',
    cardBg: 'bg-sky-400/[0.04] border-sky-400/20',
    tagStyle: 'bg-sky-400/10 text-sky-300 border-sky-400/20',
  },
];

const PHONE_POSTS = [
  {
    av: 'AA', avBg: 'bg-blue-800',
    name: 'Akosua A.', school: 'UG Legon · Fresher · Business',
    tag: 'Roommate needed', tagStyle: 'bg-blue-500/20 text-blue-300',
    text: "Looking for a neat roomie for Volta or Limann. I sleep early — no loud music please! 🙏",
    likes: 94, comments: 38,
  },
  {
    av: 'KB', avBg: 'bg-green-800',
    name: 'Kwaku B.', school: 'KNUST · Fresher · CS',
    tag: 'Tech roomie wanted', tagStyle: 'bg-green-500/20 text-green-300',
    text: "Kotei or Brunei area. Looking for fellow tech heads to code and split rides with. No cap 🔥",
    likes: 71, comments: 24,
  },
  {
    av: 'SM', avBg: 'bg-purple-800',
    name: 'Selorm M.', school: 'UCC · Fresher · Nursing',
    tag: 'Study partner', tagStyle: 'bg-purple-500/20 text-purple-300',
    text: "Casford area. Need serious study partners for Nursing. Let's pass these mid-sems early 📚",
    likes: 55, comments: 19,
  },
];

// ─── SUB-COMPONENTS ──────────────────────────────────────────────────────────

function WaitlistForm({ id }) {
  const [phone, setPhone] = useState('');
  const [school, setSchool] = useState('');
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
      const res = await fetch('/api/waitlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone: phone.trim(), school }),
      });
      if (res.ok) {
        setDone(true);
      } else {
        setError('Something went wrong. Try again.');
      }
    } catch {
      setError('No connection. Try again.');
    } finally {
      setLoading(false);
    }
  };

  if (done) {
    return (
      <div className="flex items-center gap-3 bg-green-500/10 border border-green-500/30 rounded-2xl px-5 py-4">
        <CheckCircle className="text-green-400 w-5 h-5 flex-shrink-0" />
        <div>
          <p className="text-green-300 font-bold text-sm">You&apos;re on the list!</p>
          <p className="text-green-400/60 text-xs mt-0.5">We&apos;ll hit you 48hrs before your school hub opens 🎉</p>
        </div>
      </div>
    );
  }

  return (
    <form id={id} onSubmit={handleSubmit} className="flex flex-col gap-2.5">
      {/* school selector */}
      <p className="text-[11px] font-bold text-white/35 uppercase tracking-widest mb-0.5">Pick your school</p>
      <div className={`flex flex-wrap gap-2 p-2 rounded-2xl border transition-colors ${noSchool ? 'border-red-400/50 bg-red-400/[0.04]' : 'border-transparent'}`}>
        {SCHOOLS.map((s) => (
          <button
            key={s.id}
            type="button"
            onClick={() => { setSchool(s.id); setNoSchool(false); }}
            className={`text-xs font-black px-3.5 py-2 rounded-xl border transition-all ${
              school === s.id
                ? 'bg-amber-400 text-[#050d20] border-amber-400'
                : 'bg-white/[0.04] text-white/50 border-white/[0.08] hover:border-white/20 hover:text-white/80'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>
      {noSchool && <p className="text-[11px] text-red-400 pl-1">Please select your school first</p>}
      {/* phone + submit */}
      <div className="flex flex-col sm:flex-row gap-2.5 mt-1">
        <input
          type="text"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          placeholder="Enter phone number (e.g., 055...)"
          required
          className="flex-1 bg-white/[0.06] border border-white/[0.1] rounded-2xl px-5 py-3.5 text-sm text-white placeholder-white/25 outline-none focus:border-amber-400/50 transition-colors"
        />
        <button
          type="submit"
          disabled={loading}
          className="bg-amber-400 hover:bg-amber-300 active:scale-95 disabled:opacity-60 text-[#050d20] font-black text-sm px-7 py-3.5 rounded-2xl transition-all hover:-translate-y-0.5 hover:shadow-xl hover:shadow-amber-400/20 whitespace-nowrap"
        >
          {loading ? 'Saving...' : 'Claim Your Handle →'}
        </button>
      </div>
      {error && <p className="text-[11px] text-red-400 pl-1">{error}</p>}
    </form>
  );
}

function Ticker() {
  const items = [...TICKER_ITEMS, ...TICKER_ITEMS];
  return (
    <div className="overflow-hidden border-y border-white/[0.06] bg-white/[0.02] py-3 relative">
      <div className="pointer-events-none absolute left-0 top-0 bottom-0 w-20 z-10 bg-gradient-to-r from-[#050d20] to-transparent" />
      <div className="pointer-events-none absolute right-0 top-0 bottom-0 w-20 z-10 bg-gradient-to-l from-[#050d20] to-transparent" />
      <div className="flex gap-10 whitespace-nowrap w-max animate-[ticker_35s_linear_infinite]">
        {items.map((item, i) => (
          <span key={i} className="text-[11px] font-semibold text-white/40 tracking-wide">
            {item}
          </span>
        ))}
      </div>
    </div>
  );
}

function PhoneMockup() {
  return (
    <div className="relative mx-auto w-[230px] select-none">
      {/* ambient glow */}
      <div className="absolute -inset-6 rounded-[48px] bg-blue-500/15 blur-3xl" />
      <div className="relative bg-[#080f22] border border-white/10 rounded-[36px] shadow-2xl overflow-hidden">
        {/* pill notch */}
        <div className="flex justify-center pt-3.5 pb-0.5">
          <div className="w-14 h-1 bg-white/15 rounded-full" />
        </div>
        {/* header */}
        <div className="flex items-center justify-between px-4 py-2.5">
          <span className="text-[11px] font-black tracking-widest text-white">UNIFY</span>
          <div className="flex items-center gap-1">
            <div className="w-4 h-4 rounded-full bg-white/5 border border-white/10 flex items-center justify-center">
              <span className="text-[7px]">🔔</span>
            </div>
          </div>
        </div>
        {/* search bar */}
        <div className="mx-3 mb-3 bg-white/[0.04] border border-white/[0.07] rounded-xl px-3 py-2 text-[9px] text-white/25">
          🔍  Search freshers, schools, hostels...
        </div>
        {/* section label */}
        <div className="px-3 mb-1.5">
          <span className="text-[8px] font-bold uppercase tracking-widest text-white/30">Fresher Connect 🎓</span>
        </div>
        {/* posts */}
        <div className="px-2.5 pb-5 flex flex-col gap-2">
          {PHONE_POSTS.map((p, i) => (
            <div key={i} className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-2.5">
              <div className="flex items-center gap-1.5 mb-1.5">
                <div className={`w-6 h-6 rounded-full ${p.avBg} flex items-center justify-center text-[7px] font-black text-white flex-shrink-0`}>
                  {p.av}
                </div>
                <div>
                  <div className="text-[8px] font-bold text-white leading-tight">{p.name}</div>
                  <div className="text-[7px] text-white/35">{p.school}</div>
                </div>
              </div>
              <span className={`inline-block text-[7px] font-semibold px-1.5 py-0.5 rounded-full ${p.tagStyle} mb-1.5`}>
                {p.tag}
              </span>
              <p className="text-[8px] text-white/55 leading-relaxed mb-2">{p.text}</p>
              <div className="flex gap-3">
                <span className="text-[7px] text-white/25">❤️ {p.likes}</span>
                <span className="text-[7px] text-white/25">💬 {p.comments}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function FresherCard({ f }) {
  return (
    <div className={`bg-white/[0.025] border ${f.borderColor} rounded-3xl overflow-hidden hover:-translate-y-1.5 transition-transform duration-300 flex flex-col`}>
      {/* avatar header */}
      <div className={`bg-gradient-to-br ${f.avatarBg} px-6 pt-6 pb-5`}>
        <div className="flex items-start justify-between mb-4">
          <div className="w-14 h-14 rounded-2xl bg-black/30 backdrop-blur flex items-center justify-center text-xl font-black text-white">
            {f.initials}
          </div>
          <div className="flex items-center gap-1.5 mt-1">
            <div className={`w-1.5 h-1.5 rounded-full ${f.online ? 'bg-green-400 animate-pulse' : 'bg-white/20'}`} />
            <span className="text-[10px] text-white/40 font-medium">{f.online ? 'Active now' : 'Recently active'}</span>
          </div>
        </div>
        <h3 className="font-black text-white text-[17px] leading-tight">{f.name}</h3>
        <p className="text-white/50 text-xs mt-0.5">{f.age} yrs · {f.from}</p>
      </div>
      {/* body */}
      <div className="p-5 flex flex-col flex-1">
        <div className="flex items-center gap-2 mb-3 flex-wrap">
          <span className="text-xs font-black text-white bg-white/[0.07] px-2.5 py-1 rounded-lg">{f.school}</span>
          <span className={`text-xs font-semibold ${f.accentColor}`}>{f.program}</span>
        </div>
        <p className="text-sm text-white/55 leading-relaxed mb-4 flex-1">{f.bio}</p>
        <div className="flex flex-wrap gap-1.5 mb-4">
          {f.tags.map((t) => (
            <span key={t} className={`text-[10px] font-semibold px-2.5 py-1 rounded-full border ${f.tagBg}`}>{t}</span>
          ))}
        </div>
        <div className="border-t border-white/[0.06] pt-4 mb-4">
          <p className="text-[9px] text-white/25 uppercase tracking-[0.15em] font-bold mb-1.5">Looking for</p>
          <p className="text-sm text-white/80 font-bold">{f.lookingFor}</p>
          <div className="flex items-center gap-1.5 mt-1.5">
            <MapPin className="w-3 h-3 text-white/25" strokeWidth={1.5} />
            <p className="text-xs text-white/35">{f.hostelPref}</p>
          </div>
        </div>
        <button className="w-full bg-white/[0.05] hover:bg-white/[0.1] border border-white/[0.08] text-white text-xs font-black py-2.5 rounded-xl transition-all active:scale-95">
          Connect →
        </button>
      </div>
    </div>
  );
}

// ─── MAIN COMPONENT ──────────────────────────────────────────────────────────

export default function UnifyLanding() {
  return (
    <div
      className="min-h-screen bg-[#050d20] text-white antialiased"
      style={{ fontFamily: "'Inter', system-ui, sans-serif" }}
    >

      {/* ── NAV ─────────────────────────────────────────────────────────── */}
      <nav className="fixed top-0 left-0 right-0 z-50 border-b border-white/[0.05] bg-[#050d20]/80 backdrop-blur-2xl">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <span className="text-lg font-black tracking-tight">UNIFY</span>
          <div className="hidden md:flex items-center gap-7 text-sm text-white/40 font-medium">
            <a href="#features" className="hover:text-white transition-colors">Features</a>
            <a href="#freshers" className="hover:text-white transition-colors">Meet Freshers</a>
            <a href="#waitlist" className="hover:text-white transition-colors">Join Waitlist</a>
          </div>
          <a
            href="#waitlist"
            className="bg-amber-400 hover:bg-amber-300 text-[#050d20] text-xs font-black px-4 py-2.5 rounded-xl transition-all hover:-translate-y-0.5"
          >
            Get Early Access →
          </a>
        </div>
      </nav>

      {/* ── HERO ────────────────────────────────────────────────────────── */}
      <section className="pt-28 md:pt-36 pb-16 md:pb-24 px-6">
        <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-12 md:gap-16 items-center">

          {/* Left */}
          <div>
            <div className="inline-flex items-center gap-2 bg-amber-400/10 border border-amber-400/25 text-amber-400 text-xs font-bold px-3.5 py-2 rounded-full mb-7">
              <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" />
              Built for Ghana's freshers · Launching 2026
            </div>

            <h1 className="text-[2.6rem] md:text-[3.6rem] font-black leading-[1.06] tracking-tight mb-5">
              Don't pull up to<br />
              campus alone,<br />
              <span className="text-amber-400">fr.</span>
            </h1>

            <p className="text-base md:text-lg text-white/50 leading-relaxed mb-8 max-w-[440px]">
              The ZeeMee for Ghana. Find your roommates, link up with course mates, and tap into your official campus hub before matriculation. Lightweight, clean, and uses under 5MB of data.
            </p>

            <WaitlistForm id="hero-form" />

            {/* social proof */}
            <div className="mt-6 flex items-center gap-3">
              <div className="flex -space-x-2">
                {['KA', 'YM', 'FA', 'EB', 'AO'].map((i) => (
                  <div
                    key={i}
                    className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-700 to-blue-950 border-2 border-[#050d20] flex items-center justify-center text-[8px] font-black text-white"
                  >
                    {i}
                  </div>
                ))}
              </div>
              <p className="text-sm text-white/35">
                <strong className="text-white font-bold">12,400+</strong> freshers already holding their spot
              </p>
            </div>

            {/* trust pills */}
            <div className="mt-6 flex flex-wrap gap-2">
              {['✓ 100% Free', '✓ No subscriptions', '✓ Works on 2G', '✓ Verified students only'].map((t) => (
                <span key={t} className="text-[11px] font-semibold text-white/35 bg-white/[0.04] border border-white/[0.07] px-3 py-1 rounded-full">
                  {t}
                </span>
              ))}
            </div>
          </div>

          {/* Right — phone mockup, hidden on mobile */}
          <div className="hidden md:flex justify-end">
            <PhoneMockup />
          </div>
        </div>
      </section>

      {/* ── TICKER ──────────────────────────────────────────────────────── */}
      <Ticker />

      {/* ── HOW IT WORKS ────────────────────────────────────────────────── */}
      <section className="py-16 md:py-28 px-6 border-t border-white/[0.04]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-10 md:mb-16">
            <span className="text-xs font-bold uppercase tracking-[0.2em] text-amber-400">
              Three steps. Zero stress.
            </span>
            <h2 className="text-4xl md:text-5xl font-black mt-3 mb-4 tracking-tight">
              How UNIFY works.
            </h2>
            <p className="text-white/45 max-w-sm mx-auto text-base leading-relaxed">
              From fresher anxiety to fully linked up — before you even step on campus.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6 relative">
            {/* connector line on desktop */}
            <div className="hidden md:block absolute top-10 left-[calc(16.67%+1rem)] right-[calc(16.67%+1rem)] h-px bg-gradient-to-r from-amber-400/20 via-blue-400/20 to-green-400/20" />

            {HOW_STEPS.map(({ step, title, body, color, bg }) => (
              <div key={step} className={`relative border ${bg} rounded-3xl p-8`}>
                <div className={`text-5xl font-black ${color} opacity-20 leading-none mb-6 select-none`}>
                  {step}
                </div>
                <h3 className="text-base font-black mb-3 leading-snug">{title}</h3>
                <p className="text-sm text-white/45 leading-relaxed">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── MEET THE FRESHERS ───────────────────────────────────────────── */}
      <section id="freshers" className="py-16 md:py-28 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-10 md:mb-16">
            <span className="text-xs font-bold uppercase tracking-[0.2em] text-amber-400">
              Your new campus fam
            </span>
            <h2 className="text-4xl md:text-5xl font-black mt-3 mb-4 tracking-tight">
              Meet the freshers.
            </h2>
            <p className="text-white/45 max-w-md mx-auto text-base leading-relaxed">
              Real incoming students looking for roommates, coursemates, and people to navigate campus with. Your people are already here.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-5">
            {FRESHERS.map((f) => <FresherCard key={f.name} f={f} />)}
          </div>

          <div className="text-center mt-10">
            <a
              href="#waitlist"
              className="inline-flex items-center gap-2 text-sm text-white/35 hover:text-amber-400 font-semibold transition-colors"
            >
              <Users className="w-4 h-4" strokeWidth={1.5} />
              See all freshers in your school hub →
            </a>
          </div>
        </div>
      </section>

      {/* ── PILLARS ─────────────────────────────────────────────────────── */}
      <section id="features" className="py-16 md:py-28 px-6 border-t border-white/[0.04]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-10 md:mb-16">
            <span className="text-xs font-bold uppercase tracking-[0.2em] text-amber-400">
              Why UNIFY
            </span>
            <h2 className="text-4xl md:text-5xl font-black mt-3 mb-4 tracking-tight">
              Built different.<br />Built for Ghana.
            </h2>
            <p className="text-white/45 max-w-md mx-auto text-base leading-relaxed">
              Not a copy-paste Western social app. Every decision built around the real Ghanaian fresher experience.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {PILLARS.map(({ Icon, title, subtitle, body, tags, iconColor, cardBg, tagStyle }) => (
              <div key={title} className={`border ${cardBg} rounded-3xl p-8`}>
                <div className={`w-12 h-12 rounded-2xl border ${cardBg} flex items-center justify-center mb-6`}>
                  <Icon className={`w-5 h-5 ${iconColor}`} strokeWidth={1.7} />
                </div>
                <h3 className="text-lg font-black mb-1 leading-tight">{title}</h3>
                <p className={`text-xs font-bold mb-4 ${iconColor}`}>{subtitle}</p>
                <p className="text-sm text-white/45 leading-relaxed mb-6">{body}</p>
                <div className="flex flex-wrap gap-1.5">
                  {tags.map((t) => (
                    <span key={t} className={`text-[10px] font-bold px-2.5 py-1 rounded-full border ${tagStyle}`}>
                      {t}
                    </span>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── FINAL CTA ───────────────────────────────────────────────────── */}
      <section id="waitlist" className="py-16 md:py-28 px-6 border-t border-white/[0.04]">
        <div className="max-w-2xl mx-auto text-center">
          <span className="text-5xl block mb-6">🇬🇭</span>

          <div className="inline-flex items-center gap-2 bg-green-500/10 border border-green-500/25 text-green-400 text-xs font-bold px-4 py-2 rounded-full mb-7">
            <CheckCircle className="w-3.5 h-3.5" strokeWidth={2} />
            100% free · No subscriptions · Ever
          </div>

          <h2 className="text-4xl md:text-5xl font-black tracking-tight mb-5 leading-tight">
            Stop hunting for broken<br />
            <span className="text-amber-400">WhatsApp group links.</span>
          </h2>

          <p className="text-white/45 text-lg mb-10 max-w-md mx-auto leading-relaxed">
            Secure your spot in the official Class of &apos;30 network today. Your campus people are already inside.
          </p>

          <WaitlistForm id="footer-form" />

          <p className="text-xs text-white/20 mt-5">
            🔒 Free forever · No spam · Built by Ghanaians in Ghana
          </p>
        </div>
      </section>

      {/* ── FOOTER ──────────────────────────────────────────────────────── */}
      <footer className="border-t border-white/[0.05] pt-12 pb-8 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-8 pb-8 border-b border-white/[0.05] mb-6">
            <div>
              <span className="text-xl font-black block mb-2">UNIFY</span>
              <p className="text-sm text-white/30 max-w-xs leading-relaxed">
                Ghana's peer-to-peer university transition network. Built for freshers, by people who were once freshers.
              </p>
            </div>
            <nav className="flex flex-wrap gap-x-8 gap-y-3 text-sm text-white/30">
              <a href="#features" className="hover:text-white transition-colors">Features</a>
              <a href="#freshers" className="hover:text-white transition-colors">Meet Freshers</a>
              <a href="#waitlist" className="hover:text-white transition-colors">Join Waitlist</a>
              <a href="#" className="hover:text-white transition-colors">Privacy</a>
              <a href="#" className="hover:text-white transition-colors">Terms</a>
            </nav>
          </div>

          <div className="flex flex-col md:flex-row items-center justify-between gap-3">
            <p className="text-xs text-white/20">© 2026 UNIFY · Built in Ghana 🇬🇭</p>
            <p className="text-xs text-white/20">Connecting students at 180+ schools across Ghana</p>
          </div>

          {/* Ghana flag stripe */}
          <div className="mt-8 h-[3px] rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
        </div>
      </footer>

    </div>
  );
}
