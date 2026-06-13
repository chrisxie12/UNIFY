'use client';

import { useState, useEffect, useRef } from 'react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';
const GHANA_PHONE_RE = /^(?:\+233|0)(20|24|50|54|55|59|23|25|26|27)\d{7}$/;

function normalizePhone(raw) {
  const s = raw.replace(/[\s\-().]/g, '');
  if (s.startsWith('+233')) return '0' + s.slice(4);
  if (s.startsWith('233')) return '0' + s.slice(3);
  return s;
}

const SCHOOLS = ['KNUST', 'UG Legon', 'UCC', 'UPSA', 'UDS', 'GCTU'];

/* ── Keyframes injected once ── */
const GLOBAL_STYLES = `
  @keyframes float-slow {
    0%, 100% { transform: translateY(0px) scale(1); }
    50% { transform: translateY(-18px) scale(1.04); }
  }
  @keyframes float-medium {
    0%, 100% { transform: translateY(0px) scale(1); }
    50% { transform: translateY(-12px) scale(1.02); }
  }
  @keyframes fade-up {
    from { opacity: 0; transform: translateY(28px); }
    to   { opacity: 1; transform: translateY(0); }
  }
  @keyframes pulse-ring {
    0% { box-shadow: 0 0 0 0 rgba(0,85,255,0.35); }
    70% { box-shadow: 0 0 0 8px rgba(0,85,255,0); }
    100% { box-shadow: 0 0 0 0 rgba(0,85,255,0); }
  }
  .hero-label { animation: fade-up 0.7s cubic-bezier(0.16,1,0.3,1) 0.1s both; }
  .hero-h1    { animation: fade-up 0.7s cubic-bezier(0.16,1,0.3,1) 0.2s both; }
  .hero-sub   { animation: fade-up 0.7s cubic-bezier(0.16,1,0.3,1) 0.32s both; }
  .hero-ctas  { animation: fade-up 0.7s cubic-bezier(0.16,1,0.3,1) 0.44s both; }
  .hero-trust { animation: fade-up 0.7s cubic-bezier(0.16,1,0.3,1) 0.54s both; }
  .blob-1 { animation: float-slow 7s ease-in-out infinite; }
  .blob-2 { animation: float-medium 9s ease-in-out infinite 1.5s; }
  .blob-3 { animation: float-slow 11s ease-in-out infinite 3s; }
  .lift-card {
    transition: transform 0.25s cubic-bezier(0.34,1.56,0.64,1), box-shadow 0.25s ease, border-color 0.25s ease;
  }
  .lift-card:hover {
    transform: translateY(-4px);
  }
  .lift-card-blue:hover {
    box-shadow: 0 12px 32px -4px rgba(0,85,255,0.12);
    border-color: rgba(0,85,255,0.2);
  }
  .lift-card-gray:hover {
    box-shadow: 0 12px 32px -4px rgba(0,0,0,0.08);
  }
  .step-circle {
    transition: border-color 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
  }
  .step-circle:hover {
    border-color: #0055FF;
    box-shadow: 0 0 0 6px rgba(0,85,255,0.1);
    background: #EEF4FF;
  }
  .btn-primary {
    transition: background 0.2s ease, transform 0.15s ease, box-shadow 0.2s ease;
  }
  .btn-primary:hover {
    background: #0044DD;
    box-shadow: 0 0 0 4px rgba(0,85,255,0.18), 0 8px 24px -4px rgba(0,85,255,0.35);
    transform: translateY(-1px);
  }
  .btn-primary:active { transform: scale(0.97); }
  .btn-secondary {
    transition: border-color 0.2s ease, background 0.2s ease, transform 0.15s ease;
  }
  .btn-secondary:hover {
    border-color: #94a3b8;
    background: #f8fafc;
    transform: translateY(-1px);
  }
  .btn-secondary:active { transform: scale(0.97); }
  .solution-card {
    transition: transform 0.25s cubic-bezier(0.34,1.56,0.64,1), box-shadow 0.25s ease, border-color 0.25s ease;
  }
  .solution-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 16px 40px -8px rgba(0,85,255,0.1);
    border-color: rgba(0,85,255,0.25);
  }
  .solution-card::after {
    content: '';
    position: absolute;
    bottom: 0; left: 0; right: 0;
    height: 2px;
    background: linear-gradient(90deg, #0055FF, #6366f1);
    opacity: 0;
    transition: opacity 0.25s ease;
    border-radius: 0 0 16px 16px;
  }
  .solution-card:hover::after { opacity: 1; }
`;

/* ── Scroll reveal ── */
function useScrollReveal(threshold = 0.1) {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([e]) => { if (e.isIntersecting) { setVisible(true); obs.disconnect(); } },
      { threshold },
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [threshold]);
  return [ref, visible];
}

function Reveal({ children, delay = 0, className = '' }) {
  const [ref, visible] = useScrollReveal();
  return (
    <div
      ref={ref}
      className={className}
      style={{
        transition: `opacity 0.65s cubic-bezier(0.16,1,0.3,1) ${delay}ms, transform 0.65s cubic-bezier(0.16,1,0.3,1) ${delay}ms`,
        opacity: visible ? 1 : 0,
        transform: visible ? 'translateY(0)' : 'translateY(28px)',
      }}
    >
      {children}
    </div>
  );
}

/* ── Icons ── */
function IconAnnouncement() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M16 4L4 8v4l12 4V4z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
      <path d="M4 12v3a1 1 0 001 1h2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}
function IconShield() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M10 2L3 5v5c0 4 3 7 7 8 4-1 7-4 7-8V5l-7-3z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
      <path d="M7 10l2 2 4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}
function IconNetwork() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <circle cx="10" cy="10" r="2" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="3" cy="5" r="1.5" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="17" cy="5" r="1.5" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="3" cy="15" r="1.5" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="17" cy="15" r="1.5" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M4.5 5.5L8.5 8.5M11.5 8.5L15.5 5.5M4.5 14.5L8.5 11.5M11.5 11.5L15.5 14.5" stroke="currentColor" strokeWidth="1.25" strokeLinecap="round"/>
    </svg>
  );
}
function IconWarning() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
      <path d="M9 2L1.5 15h15L9 2z" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M9 8v3M9 13h.01" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}
function IconWhatsapp() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
      <circle cx="9" cy="9" r="7.5" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M6 7.5c0 3 2.5 5 5 5l.5-2-2-1-1 1c-.5-.5-1.5-1.5-1.5-2.5l1-1-1-2L6 7.5z" stroke="currentColor" strokeWidth="1.2" strokeLinejoin="round"/>
    </svg>
  );
}
function IconLock() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
      <rect x="3" y="8" width="12" height="8" rx="2" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M6 8V6a3 3 0 016 0v2" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
      <circle cx="9" cy="12" r="1" fill="currentColor"/>
    </svg>
  );
}
function IconArrow() {
  return (
    <svg width="15" height="15" viewBox="0 0 15 15" fill="none">
      <path d="M2.5 7.5h10M8.5 3.5l4 4-4 4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

/* ── Check mark ── */
function CheckMark({ color = 'white' }) {
  return (
    <svg className="shrink-0 mt-0.5" width="16" height="16" viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="7" fill={color === 'white' ? 'rgba(255,255,255,0.2)' : 'rgba(0,0,0,0.06)'}/>
      <path d="M4.5 8l2.5 2.5 4.5-5" stroke={color === 'white' ? 'white' : '#374151'} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

/* ── Waitlist form ── */
function WaitlistForm() {
  const [school, setSchool] = useState('');
  const [phone, setPhone]   = useState('');
  const [status, setStatus] = useState('idle');
  const [err, setErr]       = useState('');

  async function submit(e) {
    e.preventDefault();
    setErr('');
    if (!school) { setErr('Select your university.'); return; }
    const norm = normalizePhone(phone);
    if (!GHANA_PHONE_RE.test(norm)) { setErr('Enter a valid Ghanaian number.'); return; }
    setStatus('loading');
    try {
      await fetch(SHEET_URL, { method: 'POST', body: new URLSearchParams({ school, phone: norm, ts: new Date().toISOString() }) });
      setStatus('success');
    } catch {
      setStatus('error');
      setErr('Something went wrong. Try again.');
    }
  }

  if (status === 'success') {
    return (
      <div className="text-center py-6">
        <div className="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4" style={{ animation: 'pulse-ring 1.2s ease-out' }}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M4 12l5.5 5.5L20 7" stroke="#16a34a" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
        <p className="font-semibold text-gray-900 text-lg">You're on the list</p>
        <p className="text-gray-500 text-sm mt-1">We'll reach you when UNIFY opens at your school.</p>
      </div>
    );
  }

  return (
    <form onSubmit={submit} className="w-full">
      <div className="flex flex-wrap gap-2 mb-5 justify-center">
        {SCHOOLS.map((s) => (
          <button
            key={s} type="button" onClick={() => setSchool(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium border transition-all duration-150 ${
              school === s
                ? 'bg-[#0055FF] text-white border-[#0055FF] shadow-md shadow-blue-200'
                : 'bg-white text-gray-600 border-gray-200 hover:border-[#0055FF] hover:text-[#0055FF]'
            }`}
          >
            {s}
          </button>
        ))}
      </div>
      <div className="flex gap-2 max-w-sm mx-auto">
        <input
          type="tel" placeholder="0XX XXX XXXX" value={phone}
          onChange={(e) => setPhone(e.target.value)}
          className="flex-1 h-12 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#0055FF] focus:ring-2 focus:ring-blue-100 transition-all"
        />
        <button
          type="submit" disabled={status === 'loading'}
          className="btn-primary h-12 px-6 bg-[#0055FF] text-white text-sm font-semibold rounded-xl disabled:opacity-50"
        >
          {status === 'loading' ? '…' : 'Join'}
        </button>
      </div>
      {err && <p className="text-red-500 text-xs text-center mt-2">{err}</p>}
    </form>
  );
}

/* ── Main component ── */
export default function UnifyLanding() {
  const [scrolled, setScrolled] = useState(false);
  useEffect(() => {
    const fn = () => setScrolled(window.scrollY > 16);
    window.addEventListener('scroll', fn, { passive: true });
    return () => window.removeEventListener('scroll', fn);
  }, []);

  return (
    <div className="min-h-screen bg-white text-gray-900" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <style dangerouslySetInnerHTML={{ __html: GLOBAL_STYLES }} />

      {/* ── Nav ── */}
      <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled ? 'bg-white/95 backdrop-blur-md border-b border-gray-100 shadow-sm' : 'bg-transparent'}`}>
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          {/* Wordmark */}
          <div className="flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={32} height={32} className="rounded-xl" />
            <span className="font-bold text-lg text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
          </div>

          <nav className="hidden md:flex items-center gap-8">
            <a href="#how-it-works" className="text-sm text-gray-500 hover:text-gray-900 transition-colors duration-150">How it works</a>
            <a href="#universities" className="text-sm text-gray-500 hover:text-gray-900 transition-colors duration-150">For Universities</a>
          </nav>
          <div className="flex items-center gap-3">
            <a href="#waitlist" className="hidden sm:inline-flex text-sm text-gray-600 hover:text-gray-900 transition-colors duration-150 font-medium">
              Get access
            </a>
            <a
              href="#universities"
              className="btn-primary inline-flex items-center gap-1.5 bg-gray-900 text-white text-sm font-semibold px-4 py-2 rounded-xl"
            >
              For Universities
            </a>
          </div>
        </div>
      </header>

      {/* ── Hero ── */}
      <section className="relative pt-32 pb-28 overflow-hidden">
        {/* Radial gradient */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{ background: 'radial-gradient(ellipse 90% 60% at 50% -10%, rgba(0,85,255,0.09) 0%, transparent 70%)' }}
        />
        {/* Grid */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            backgroundImage: 'linear-gradient(rgba(0,0,0,0.04) 1px, transparent 1px), linear-gradient(90deg, rgba(0,0,0,0.04) 1px, transparent 1px)',
            backgroundSize: '48px 48px',
            maskImage: 'radial-gradient(ellipse 80% 70% at 50% 0%, black 0%, transparent 80%)',
          }}
        />
        {/* Floating blur blobs */}
        <div className="blob-1 absolute top-16 left-[8%] w-72 h-72 rounded-full pointer-events-none"
          style={{ background: 'radial-gradient(circle, rgba(0,85,255,0.07) 0%, transparent 70%)', filter: 'blur(32px)' }} />
        <div className="blob-2 absolute top-24 right-[10%] w-56 h-56 rounded-full pointer-events-none"
          style={{ background: 'radial-gradient(circle, rgba(99,102,241,0.07) 0%, transparent 70%)', filter: 'blur(28px)' }} />
        <div className="blob-3 absolute bottom-8 left-[30%] w-96 h-40 rounded-full pointer-events-none"
          style={{ background: 'radial-gradient(circle, rgba(0,85,255,0.04) 0%, transparent 70%)', filter: 'blur(40px)' }} />

        <div className="relative max-w-4xl mx-auto px-6 text-center">
          {/* Label */}
          <div className="hero-label inline-flex items-center gap-2 bg-blue-50 border border-blue-100 text-blue-600 text-xs font-semibold px-2 pr-3.5 py-1.5 rounded-full mb-8 tracking-wide uppercase">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="" width={22} height={22} className="rounded-lg" />
            Built for university campuses
          </div>

          {/* Headline */}
          <h1
            className="hero-h1 font-extrabold tracking-tight text-gray-900 mb-6"
            style={{ fontSize: 'clamp(2.4rem, 6vw, 4.5rem)', lineHeight: 1.08, letterSpacing: '-0.03em' }}
          >
            The official identity &<br />
            <span style={{ color: '#0055FF' }}>announcement layer</span><br />
            for your campus.
          </h1>

          {/* Subtext */}
          <p className="hero-sub text-gray-500 text-lg max-w-xl mx-auto mb-10 leading-relaxed">
            Every student, verified. Every notice, delivered. No more missed updates in noisy group chats.
          </p>

          {/* CTAs */}
          <div className="hero-ctas flex flex-col sm:flex-row gap-3 justify-center items-center">
            <a
              href="#waitlist"
              className="btn-primary inline-flex items-center gap-2 bg-[#0055FF] text-white font-semibold px-7 py-3.5 rounded-xl text-base shadow-lg shadow-blue-200/60"
            >
              Join Your University
              <IconArrow />
            </a>
            <a
              href="#universities"
              className="btn-secondary inline-flex items-center gap-2 bg-white border border-gray-200 text-gray-700 font-semibold px-7 py-3.5 rounded-xl text-base"
            >
              For Universities
            </a>
          </div>

          {/* University logo strip */}
          <div className="hero-trust mt-10">
            <p className="text-xs text-gray-400 font-medium tracking-widest uppercase mb-6">Launching at</p>
            <div className="flex flex-wrap gap-6 justify-center items-end">
              {[
                { src: '/logos/knust.jpg', name: 'KNUST'    },
                { src: '/logos/ug.png',    name: 'UG Legon' },
                { src: '/logos/ucc.png',   name: 'UCC'      },
                { src: '/logos/upsa.png',  name: 'UPSA'     },
                { src: '/logos/uds.jpg',   name: 'UDS'      },
                { src: '/logos/gctu.png',  name: 'GCTU'     },
              ].map((s) => (
                <div key={s.name} className="flex flex-col items-center gap-2 group">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={s.src}
                    alt={s.name}
                    style={{ width: 72, height: 72, objectFit: 'contain' }}
                    className="group-hover:scale-110 transition-transform duration-200 drop-shadow"
                  />
                  <span className="text-[10px] font-semibold text-gray-400 tracking-wide">{s.name}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── Problem ── */}
      <section className="py-24 bg-gray-50">
        <div className="max-w-5xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-14">
              <p className="text-[#0055FF] text-xs font-bold tracking-[0.14em] uppercase mb-3">The problem</p>
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>
                Campus communication is broken.
              </h2>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-3 gap-5">
            {[
              {
                icon: <IconWarning />,
                iconBg: 'bg-red-50 text-red-500',
                title: 'Missed announcements',
                body: 'Critical notices — exam changes, hostel allocations, deadlines — never reliably reach students.',
              },
              {
                icon: <IconWhatsapp />,
                iconBg: 'bg-yellow-50 text-yellow-600',
                title: 'Scattered group chats',
                body: 'Hundreds of unverified WhatsApp groups flood students with noise and bury what matters.',
              },
              {
                icon: <IconLock />,
                iconBg: 'bg-purple-50 text-purple-500',
                title: 'No verified identity',
                body: 'Without institutional identity, there is no way to know who you’re communicating with on campus.',
              },
            ].map((item, i) => (
              <Reveal key={item.title} delay={i * 70}>
                <div className="lift-card lift-card-gray bg-white rounded-2xl p-6 border border-gray-100 h-full">
                  <div className={`w-10 h-10 rounded-xl ${item.iconBg} flex items-center justify-center mb-4`}>
                    {item.icon}
                  </div>
                  <h3 className="font-semibold text-gray-900 text-base mb-2">{item.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed">{item.body}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── Solution ── */}
      <section className="py-24">
        <div className="max-w-5xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-14">
              <p className="text-[#0055FF] text-xs font-bold tracking-[0.14em] uppercase mb-3">The solution</p>
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>
                UNIFY is campus infrastructure.
              </h2>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-3 gap-5">
            {[
              {
                icon: <IconShield />,
                iconBg: 'bg-blue-50 text-[#0055FF]',
                label: '01',
                title: 'Verified identity',
                body: 'Every student profile is tied to their institution — no ghost accounts, no imposters.',
              },
              {
                icon: <IconAnnouncement />,
                iconBg: 'bg-indigo-50 text-indigo-600',
                label: '02',
                title: 'Official announcements',
                body: 'Universities push notices directly to enrolled students — instantly and reliably.',
              },
              {
                icon: <IconNetwork />,
                iconBg: 'bg-violet-50 text-violet-600',
                label: '03',
                title: 'Structured communication',
                body: 'Department channels, year groups, and faculty boards — organised and moderated.',
              },
            ].map((item, i) => (
              <Reveal key={item.title} delay={i * 70}>
                <div className="solution-card relative bg-white rounded-2xl p-6 border border-gray-100 h-full overflow-hidden">
                  <div className="flex items-start justify-between mb-5">
                    <div className={`w-10 h-10 rounded-xl ${item.iconBg} flex items-center justify-center`}>
                      {item.icon}
                    </div>
                    <span className="text-xs font-bold text-gray-200 font-mono tracking-widest">{item.label}</span>
                  </div>
                  <h3 className="font-semibold text-gray-900 text-base mb-2">{item.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed">{item.body}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── How it works ── */}
      <section id="how-it-works" className="py-24 bg-gray-50">
        <div className="max-w-5xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-16">
              <p className="text-[#0055FF] text-xs font-bold tracking-[0.14em] uppercase mb-3">How it works</p>
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>
                Three steps. That&apos;s it.
              </h2>
            </div>
          </Reveal>

          <div className="relative">
            {/* Connector line */}
            <div className="hidden md:block absolute top-8 left-[calc(16.66%+1rem)] right-[calc(16.66%+1rem)] h-px"
              style={{ background: 'linear-gradient(90deg, #E2E8F0 0%, #C7D2FE 50%, #E2E8F0 100%)' }} />

            <div className="grid md:grid-cols-3 gap-10 md:gap-6">
              {[
                { n: '1', title: 'Join your university', body: 'Download UNIFY and select your campus.' },
                { n: '2', title: 'Get verified',         body: 'Confirm enrolment with your student ID or index number.' },
                { n: '3', title: 'Receive updates',      body: 'Official announcements, departmental notices, and more — all in one place.' },
              ].map((step, i) => (
                <Reveal key={step.n} delay={i * 90} className="relative flex flex-col items-center text-center">
                  <div className="step-circle relative w-16 h-16 bg-white border-2 border-gray-200 rounded-full flex items-center justify-center mb-5 z-10 cursor-default">
                    <span className="font-bold text-xl text-gray-900">{step.n}</span>
                  </div>
                  <h3 className="font-semibold text-gray-900 text-base mb-2">{step.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed max-w-xs">{step.body}</p>
                </Reveal>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── For Students / Universities ── */}
      <section id="universities" className="py-24">
        <div className="max-w-5xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-14">
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900" style={{ letterSpacing: '-0.02em' }}>
                Built for both sides of campus.
              </h2>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-2 gap-5">
            {/* Students */}
            <Reveal>
              <div className="lift-card relative rounded-3xl overflow-hidden bg-[#0055FF] p-8 text-white min-h-80 flex flex-col justify-between">
                <div
                  className="absolute top-0 right-0 w-80 h-80 rounded-full pointer-events-none"
                  style={{ background: 'radial-gradient(circle at top right, rgba(255,255,255,0.15) 0%, transparent 60%)' }}
                />
                <div className="absolute -bottom-8 -left-8 w-40 h-40 rounded-full pointer-events-none"
                  style={{ background: 'radial-gradient(circle, rgba(255,255,255,0.06) 0%, transparent 70%)' }} />
                <div>
                  <div className="inline-flex items-center gap-2 bg-white/15 backdrop-blur-sm rounded-full px-3 py-1 text-xs font-semibold tracking-wide uppercase mb-6">
                    🎓 For Students
                  </div>
                  <h3 className="font-bold text-2xl mb-5 leading-tight">Your verified campus identity</h3>
                  <ul className="space-y-3">
                    {[
                      'Receive official university announcements',
                      'Stay connected to your department and year group',
                      'One verified profile across all campus platforms',
                      'Free — always',
                    ].map((item) => (
                      <li key={item} className="flex items-center gap-3 text-sm text-blue-100">
                        <CheckMark color="white" />
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <a
                  href="#waitlist"
                  className="btn-secondary mt-8 inline-flex items-center gap-2 bg-white text-[#0055FF] font-semibold text-sm px-5 py-2.5 rounded-xl w-fit"
                  style={{ transition: 'transform 0.15s ease, box-shadow 0.15s ease' }}
                >
                  Join your university <IconArrow />
                </a>
              </div>
            </Reveal>

            {/* Universities */}
            <Reveal delay={80}>
              <div className="lift-card relative rounded-3xl overflow-hidden bg-gray-900 p-8 text-white min-h-80 flex flex-col justify-between">
                <div
                  className="absolute top-0 right-0 w-80 h-80 rounded-full pointer-events-none"
                  style={{ background: 'radial-gradient(circle at top right, rgba(99,102,241,0.12) 0%, transparent 60%)' }}
                />
                <div className="absolute -bottom-8 -left-8 w-40 h-40 rounded-full pointer-events-none"
                  style={{ background: 'radial-gradient(circle, rgba(255,255,255,0.04) 0%, transparent 70%)' }} />
                <div>
                  <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm rounded-full px-3 py-1 text-xs font-semibold tracking-wide uppercase mb-6">
                    🏛️ For Universities
                  </div>
                  <h3 className="font-bold text-2xl mb-5 leading-tight">Direct reach to every student</h3>
                  <ul className="space-y-3">
                    {[
                      'Push announcements to enrolled students instantly',
                      'Verified student directory with enrolment status',
                      'Department and faculty channel management',
                      'Engagement analytics — open rates and reach',
                    ].map((item) => (
                      <li key={item} className="flex items-center gap-3 text-sm text-gray-400">
                        <CheckMark color="dark" />
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <a
                  href="mailto:hello@joinunify.app"
                  className="mt-8 inline-flex items-center gap-2 bg-white/10 hover:bg-white/15 text-white font-semibold text-sm px-5 py-2.5 rounded-xl w-fit border border-white/10 transition-all duration-150 active:scale-95"
                >
                  Request university access <IconArrow />
                </a>
              </div>
            </Reveal>
          </div>
        </div>
      </section>

      {/* ── Waitlist CTA ── */}
      <section id="waitlist" className="py-24 bg-gray-50">
        <div className="max-w-2xl mx-auto px-6 text-center">
          <Reveal>
            <p className="text-[#0055FF] text-xs font-bold tracking-[0.14em] uppercase mb-4">Early access</p>
            <h2 className="font-bold text-3xl sm:text-4xl text-gray-900 mb-3" style={{ letterSpacing: '-0.02em' }}>
              Bring UNIFY to your university.
            </h2>
            <p className="text-gray-500 text-base mb-10">
              Join the waitlist. We&apos;ll notify you the moment your school goes live.
            </p>
          </Reveal>
          <Reveal delay={80}>
            <WaitlistForm />
          </Reveal>
        </div>
      </section>

      {/* ── Final CTA ── */}
      <section className="py-24">
        <div className="max-w-3xl mx-auto px-6 text-center">
          <Reveal>
            <div
              className="relative rounded-3xl px-10 py-16 overflow-hidden"
              style={{ background: 'linear-gradient(135deg, #0044DD 0%, #0055FF 40%, #4F6EF7 100%)' }}
            >
              {/* Decorative blobs inside CTA card */}
              <div className="absolute top-0 right-0 w-64 h-64 rounded-full pointer-events-none"
                style={{ background: 'radial-gradient(circle at top right, rgba(255,255,255,0.1) 0%, transparent 60%)' }} />
              <div className="absolute -bottom-10 -left-10 w-48 h-48 rounded-full pointer-events-none"
                style={{ background: 'radial-gradient(circle, rgba(255,255,255,0.06) 0%, transparent 70%)' }} />
              {/* Grid inside card */}
              <div className="absolute inset-0 pointer-events-none"
                style={{
                  backgroundImage: 'linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px)',
                  backgroundSize: '32px 32px',
                }} />

              <div className="relative">
                <h2 className="font-bold text-3xl sm:text-4xl text-white mb-3" style={{ letterSpacing: '-0.02em' }}>
                  Ready to modernise campus communication?
                </h2>
                <p className="text-blue-100 text-base mb-8">
                  Join universities taking control of their communication infrastructure.
                </p>
                <div className="flex flex-col sm:flex-row gap-3 justify-center">
                  <a
                    href="#waitlist"
                    className="btn-secondary inline-flex items-center justify-center gap-2 bg-white text-[#0055FF] font-semibold px-7 py-3.5 rounded-xl text-base"
                  >
                    Get Started <IconArrow />
                  </a>
                  <a
                    href="mailto:hello@joinunify.app"
                    className="inline-flex items-center justify-center gap-2 bg-white/15 hover:bg-white/20 text-white font-semibold px-7 py-3.5 rounded-xl text-base border border-white/20 transition-all duration-150 active:scale-95"
                  >
                    Request University Access
                  </a>
                </div>
              </div>
            </div>
          </Reveal>
        </div>
      </section>

      {/* ── Footer ── */}
      <footer className="border-t border-gray-100 py-10">
        <div className="max-w-6xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/logo-icon.png" alt="UNIFY" width={28} height={28} className="rounded-xl" />
            <span className="font-bold text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
          </div>
          <p className="text-gray-400 text-sm">© {new Date().getFullYear()} UNIFY. Built in Ghana 🇬🇭</p>
          <a href="mailto:hello@joinunify.app" className="text-gray-400 text-sm hover:text-gray-700 transition-colors duration-150">
            hello@joinunify.app
          </a>
        </div>
      </footer>

    </div>
  );
}
