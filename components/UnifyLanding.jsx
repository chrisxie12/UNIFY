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

function useScrollReveal(threshold = 0.12) {
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
        transition: `opacity 0.6s ease ${delay}ms, transform 0.6s ease ${delay}ms`,
        opacity: visible ? 1 : 0,
        transform: visible ? 'translateY(0)' : 'translateY(24px)',
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
    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
      <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
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
        <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
          <svg width="22" height="22" viewBox="0 0 22 22" fill="none"><path d="M4 11l5 5 9-9" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
        <p className="font-semibold text-gray-900 text-lg">You're on the list</p>
        <p className="text-gray-500 text-sm mt-1">We'll reach you when UNIFY opens at your school.</p>
      </div>
    );
  }

  return (
    <form onSubmit={submit} className="w-full">
      <div className="flex flex-wrap gap-2 mb-4 justify-center">
        {SCHOOLS.map((s) => (
          <button
            key={s} type="button" onClick={() => setSchool(s)}
            className={`px-4 py-1.5 rounded-full text-sm border transition-all duration-150 ${
              school === s
                ? 'bg-[#0055FF] text-white border-[#0055FF]'
                : 'bg-white text-gray-600 border-gray-200 hover:border-gray-400'
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
          className="flex-1 h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#0055FF] transition-colors"
        />
        <button
          type="submit" disabled={status === 'loading'}
          className="h-11 px-5 bg-[#0055FF] text-white text-sm font-semibold rounded-xl hover:bg-[#0044DD] active:scale-95 transition-all disabled:opacity-50"
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

      {/* ── Nav ── */}
      <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled ? 'bg-white/95 backdrop-blur-sm border-b border-gray-100 shadow-sm' : 'bg-transparent'}`}>
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <span className="font-bold text-xl tracking-tight text-gray-900">UNIFY</span>
          <nav className="hidden md:flex items-center gap-8">
            <a href="#how-it-works" className="text-sm text-gray-500 hover:text-gray-900 transition-colors">How it works</a>
            <a href="#universities" className="text-sm text-gray-500 hover:text-gray-900 transition-colors">For Universities</a>
          </nav>
          <div className="flex items-center gap-3">
            <a href="#waitlist" className="hidden sm:inline-flex text-sm text-gray-600 hover:text-gray-900 transition-colors">
              Get access
            </a>
            <a
              href="#universities"
              className="inline-flex items-center gap-1.5 bg-gray-900 text-white text-sm font-semibold px-4 py-2 rounded-xl hover:bg-gray-700 active:scale-95 transition-all"
            >
              For Universities
            </a>
          </div>
        </div>
      </header>

      {/* ── Hero ── */}
      <section className="relative pt-32 pb-28 overflow-hidden">
        {/* Gradient background */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            background: 'radial-gradient(ellipse 90% 60% at 50% -10%, rgba(0,85,255,0.08) 0%, transparent 70%)',
          }}
        />
        {/* Grid pattern */}
        <div
          className="absolute inset-0 pointer-events-none opacity-[0.025]"
          style={{
            backgroundImage: 'linear-gradient(#000 1px, transparent 1px), linear-gradient(90deg, #000 1px, transparent 1px)',
            backgroundSize: '48px 48px',
          }}
        />

        <div className="relative max-w-4xl mx-auto px-6 text-center">
          {/* Label */}
          <div className="inline-flex items-center gap-2 bg-blue-50 border border-blue-100 text-blue-600 text-xs font-semibold px-3 py-1.5 rounded-full mb-8 tracking-wide uppercase">
            <span className="w-1.5 h-1.5 bg-blue-500 rounded-full animate-pulse" />
            Built for university campuses
          </div>

          {/* Headline */}
          <h1
            className="font-extrabold tracking-tight text-gray-900 mb-6"
            style={{ fontSize: 'clamp(2.4rem, 6vw, 4.5rem)', lineHeight: 1.08, letterSpacing: '-0.03em' }}
          >
            The official identity &<br />
            <span style={{ color: '#0055FF' }}>announcement layer</span><br />
            for your campus.
          </h1>

          {/* Subtext */}
          <p className="text-gray-500 text-lg max-w-xl mx-auto mb-10 leading-relaxed">
            Every student, verified. Every notice, delivered. No more missed updates in noisy group chats.
          </p>

          {/* CTAs */}
          <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
            <a
              href="#waitlist"
              className="inline-flex items-center gap-2 bg-[#0055FF] text-white font-semibold px-7 py-3.5 rounded-xl text-base hover:bg-[#0044DD] active:scale-95 transition-all shadow-lg shadow-blue-200"
            >
              Join Your University
              <IconArrow />
            </a>
            <a
              href="#universities"
              className="inline-flex items-center gap-2 bg-white border border-gray-200 text-gray-700 font-semibold px-7 py-3.5 rounded-xl text-base hover:border-gray-400 active:scale-95 transition-all"
            >
              For Universities
            </a>
          </div>

          {/* Trust line */}
          <p className="text-gray-400 text-sm mt-8">
            KNUST · UG Legon · UCC · UPSA · UDS · GCTU
          </p>
        </div>
      </section>

      {/* ── Problem ── */}
      <section className="py-24 bg-gray-50">
        <div className="max-w-5xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-14">
              <p className="text-[#0055FF] text-sm font-semibold tracking-widest uppercase mb-3">The problem</p>
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900 tracking-tight" style={{ letterSpacing: '-0.02em' }}>
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
                body: 'Without institutional identity, there is no way to know who you're communicating with on campus.',
              },
            ].map((item, i) => (
              <Reveal key={item.title} delay={i * 70}>
                <div className="bg-white rounded-2xl p-6 border border-gray-100 hover:border-gray-200 hover:shadow-md transition-all duration-200">
                  <div className={`w-9 h-9 rounded-xl ${item.iconBg} flex items-center justify-center mb-4`}>
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
              <p className="text-[#0055FF] text-sm font-semibold tracking-widest uppercase mb-3">The solution</p>
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900 tracking-tight" style={{ letterSpacing: '-0.02em' }}>
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
                <div className="group relative bg-white rounded-2xl p-6 border border-gray-100 hover:border-blue-100 hover:shadow-lg hover:shadow-blue-50 transition-all duration-200">
                  <div className="flex items-start justify-between mb-5">
                    <div className={`w-9 h-9 rounded-xl ${item.iconBg} flex items-center justify-center`}>
                      {item.icon}
                    </div>
                    <span className="text-xs font-semibold text-gray-300 font-mono">{item.label}</span>
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
              <p className="text-[#0055FF] text-sm font-semibold tracking-widest uppercase mb-3">How it works</p>
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900 tracking-tight" style={{ letterSpacing: '-0.02em' }}>
                Three steps. That's it.
              </h2>
            </div>
          </Reveal>

          <div className="relative">
            {/* Connector line */}
            <div className="hidden md:block absolute top-8 left-[calc(16.66%+1rem)] right-[calc(16.66%+1rem)] h-px bg-gray-200" />

            <div className="grid md:grid-cols-3 gap-10 md:gap-6">
              {[
                { n: '1', title: 'Join your university', body: 'Download UNIFY and select your campus.' },
                { n: '2', title: 'Get verified',         body: 'Confirm enrolment with your student ID or index number.' },
                { n: '3', title: 'Receive updates',      body: 'Official announcements, departmental notices, and more — all in one place.' },
              ].map((step, i) => (
                <Reveal key={step.n} delay={i * 90} className="relative flex flex-col items-center text-center">
                  <div className="relative w-16 h-16 bg-white border-2 border-gray-200 rounded-full flex items-center justify-center mb-5 z-10">
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
              <h2 className="font-bold text-3xl sm:text-4xl text-gray-900 tracking-tight" style={{ letterSpacing: '-0.02em' }}>
                Built for both sides of campus.
              </h2>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-2 gap-5">
            {/* Students */}
            <Reveal>
              <div className="relative rounded-3xl overflow-hidden bg-[#0055FF] p-8 text-white min-h-80 flex flex-col justify-between">
                <div
                  className="absolute top-0 right-0 w-64 h-64 rounded-full pointer-events-none"
                  style={{ background: 'radial-gradient(circle at top right, rgba(255,255,255,0.12) 0%, transparent 60%)' }}
                />
                <div>
                  <div className="inline-flex items-center gap-2 bg-white/15 rounded-full px-3 py-1 text-xs font-semibold tracking-wide uppercase mb-6">
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
                        <svg className="shrink-0" width="16" height="16" viewBox="0 0 16 16" fill="none">
                          <path d="M3 8l3.5 3.5 6.5-7" stroke="white" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <a
                  href="#waitlist"
                  className="mt-8 inline-flex items-center gap-2 bg-white text-[#0055FF] font-semibold text-sm px-5 py-2.5 rounded-xl hover:bg-blue-50 active:scale-95 transition-all w-fit"
                >
                  Join your university <IconArrow />
                </a>
              </div>
            </Reveal>

            {/* Universities */}
            <Reveal delay={80}>
              <div className="relative rounded-3xl overflow-hidden bg-gray-900 p-8 text-white min-h-80 flex flex-col justify-between">
                <div
                  className="absolute top-0 right-0 w-64 h-64 rounded-full pointer-events-none"
                  style={{ background: 'radial-gradient(circle at top right, rgba(255,255,255,0.06) 0%, transparent 60%)' }}
                />
                <div>
                  <div className="inline-flex items-center gap-2 bg-white/10 rounded-full px-3 py-1 text-xs font-semibold tracking-wide uppercase mb-6">
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
                        <svg className="shrink-0" width="16" height="16" viewBox="0 0 16 16" fill="none">
                          <path d="M3 8l3.5 3.5 6.5-7" stroke="#6b7280" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <a
                  href="mailto:hello@joinunify.app"
                  className="mt-8 inline-flex items-center gap-2 bg-white/10 hover:bg-white/15 text-white font-semibold text-sm px-5 py-2.5 rounded-xl active:scale-95 transition-all w-fit border border-white/10"
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
            <p className="text-[#0055FF] text-sm font-semibold tracking-widest uppercase mb-4">Early access</p>
            <h2 className="font-bold text-3xl sm:text-4xl text-gray-900 tracking-tight mb-3" style={{ letterSpacing: '-0.02em' }}>
              Bring UNIFY to your university.
            </h2>
            <p className="text-gray-500 text-base mb-10">
              Join the waitlist. We'll notify you the moment your school goes live.
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
              className="rounded-3xl px-10 py-16"
              style={{ background: 'linear-gradient(135deg, #0055FF 0%, #3B82F6 100%)' }}
            >
              <h2 className="font-bold text-3xl sm:text-4xl text-white tracking-tight mb-3" style={{ letterSpacing: '-0.02em' }}>
                Ready to modernise campus communication?
              </h2>
              <p className="text-blue-100 text-base mb-8">
                Join universities taking control of their communication infrastructure.
              </p>
              <div className="flex flex-col sm:flex-row gap-3 justify-center">
                <a
                  href="#waitlist"
                  className="inline-flex items-center justify-center gap-2 bg-white text-[#0055FF] font-semibold px-7 py-3.5 rounded-xl text-base hover:bg-blue-50 active:scale-95 transition-all"
                >
                  Get Started <IconArrow />
                </a>
                <a
                  href="mailto:hello@joinunify.app"
                  className="inline-flex items-center justify-center gap-2 bg-white/15 hover:bg-white/20 text-white font-semibold px-7 py-3.5 rounded-xl text-base active:scale-95 transition-all border border-white/20"
                >
                  Request University Access
                </a>
              </div>
            </div>
          </Reveal>
        </div>
      </section>

      {/* ── Footer ── */}
      <footer className="border-t border-gray-100 py-10">
        <div className="max-w-6xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <span className="font-bold text-gray-900">UNIFY</span>
          <p className="text-gray-400 text-sm">© {new Date().getFullYear()} UNIFY. Built in Ghana 🇬🇭</p>
          <a href="mailto:hello@joinunify.app" className="text-gray-400 text-sm hover:text-gray-700 transition-colors">
            hello@joinunify.app
          </a>
        </div>
      </footer>

    </div>
  );
}
