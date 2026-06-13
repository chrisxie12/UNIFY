'use client';

import { useState, useEffect, useRef } from 'react';
import { ChevronDown } from 'lucide-react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

const GHANA_PHONE_RE = /^(?:\+233|0)(20|24|50|54|55|59|23|25|26|27)\d{7}$/;

function normalizePhone(raw) {
  const s = raw.replace(/[\s\-().]/g, '');
  if (s.startsWith('+233')) return '0' + s.slice(4);
  if (s.startsWith('233')) return '0' + s.slice(3);
  return s;
}

const SCHOOLS = [
  { id: 'knust', label: 'KNUST' },
  { id: 'ug',   label: 'UG Legon' },
  { id: 'ucc',  label: 'UCC' },
  { id: 'upsa', label: 'UPSA' },
  { id: 'uds',  label: 'UDS' },
  { id: 'gctu', label: 'GCTU' },
];

const FAQS = [
  {
    q: 'How is verification done?',
    a: 'We verify students using their university admission index number or student ID. Universities can also push verification directly via our institution dashboard.',
  },
  {
    q: 'Is UNIFY free for students?',
    a: 'Yes — completely free for students. Universities pay for the institution dashboard, announcement tools, and analytics.',
  },
  {
    q: 'How is this different from WhatsApp groups?',
    a: 'WhatsApp groups are unverified, unstructured, and unmanaged. UNIFY gives verified identity, official channels, and searchable student directories — things no group chat can provide.',
  },
  {
    q: 'Which schools are supported at launch?',
    a: 'KNUST, UG Legon, UCC, UPSA, UDS, and GCTU. We are actively onboarding more institutions.',
  },
  {
    q: 'Can universities post official announcements?',
    a: 'Yes. Verified institution accounts can push announcements directly to enrolled students — lecture changes, exam schedules, hostel allocations, and more.',
  },
  {
    q: 'When will the app be available?',
    a: 'We are running a closed beta in the coming months. Join the waitlist to be first in when your school goes live.',
  },
];

function useScrollReveal(threshold = 0.15) {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) { setVisible(true); obs.disconnect(); } },
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
        transition: `opacity 0.55s ease ${delay}ms, transform 0.55s ease ${delay}ms`,
        opacity: visible ? 1 : 0,
        transform: visible ? 'translateY(0)' : 'translateY(20px)',
      }}
    >
      {children}
    </div>
  );
}

function FAQItem({ q, a }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="border-b border-gray-200 last:border-0">
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between py-5 text-left gap-4"
      >
        <span className="font-semibold text-gray-900 text-sm sm:text-base">{q}</span>
        <ChevronDown
          size={18}
          className="shrink-0 text-gray-400 transition-transform duration-200"
          style={{ transform: open ? 'rotate(180deg)' : 'rotate(0deg)' }}
        />
      </button>
      <div
        className="overflow-hidden transition-all duration-300"
        style={{ maxHeight: open ? '200px' : '0px', opacity: open ? 1 : 0 }}
      >
        <p className="text-gray-600 text-sm leading-relaxed pb-5">{a}</p>
      </div>
    </div>
  );
}

function JoinForm() {
  const [school, setSchool] = useState('');
  const [phone, setPhone]   = useState('');
  const [status, setStatus] = useState('idle'); // idle | loading | success | error
  const [errMsg, setErrMsg] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setErrMsg('');
    if (!school) { setErrMsg('Please select your university.'); return; }
    const norm = normalizePhone(phone);
    if (!GHANA_PHONE_RE.test(norm)) { setErrMsg('Enter a valid Ghanaian phone number.'); return; }
    setStatus('loading');
    try {
      const body = new URLSearchParams({ school, phone: norm, ts: new Date().toISOString() });
      await fetch(SHEET_URL, { method: 'POST', body });
      setStatus('success');
    } catch {
      setStatus('error');
      setErrMsg('Something went wrong. Try again.');
    }
  }

  if (status === 'success') {
    return (
      <div className="text-center py-8">
        <div className="text-4xl mb-3">🎉</div>
        <p className="font-bold text-white text-xl mb-1">You're on the list!</p>
        <p className="text-blue-100 text-sm">We'll text you when UNIFY opens at your school.</p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 w-full max-w-md mx-auto">
      {/* School selector */}
      <div className="flex flex-wrap gap-2 justify-center">
        {SCHOOLS.map((s) => (
          <button
            key={s.id}
            type="button"
            onClick={() => setSchool(s.id)}
            className={`px-4 py-2 rounded-full text-sm font-semibold border transition-all ${
              school === s.id
                ? 'bg-white text-blue-600 border-white'
                : 'bg-transparent text-white border-white/40 hover:border-white/80'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>

      {/* Phone input */}
      <div className="flex gap-2">
        <input
          type="tel"
          placeholder="0XX XXX XXXX"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          className="flex-1 bg-white/10 border border-white/30 text-white placeholder-white/50 rounded-2xl px-5 py-3.5 text-sm focus:outline-none focus:border-white/80 transition-colors"
        />
        <button
          type="submit"
          disabled={status === 'loading'}
          className="bg-white text-blue-600 font-bold px-6 py-3.5 rounded-2xl text-sm hover:bg-blue-50 active:scale-95 transition-all disabled:opacity-60"
        >
          {status === 'loading' ? '…' : 'Join'}
        </button>
      </div>

      {errMsg && <p className="text-red-300 text-xs text-center">{errMsg}</p>}
    </form>
  );
}

export default function UnifyLanding() {
  return (
    <div className="min-h-screen bg-white text-gray-900 font-sans antialiased">

      {/* ── Nav ── */}
      <nav className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-gray-100">
        <div className="max-w-5xl mx-auto px-5 h-14 flex items-center justify-between">
          <span className="font-bold text-lg tracking-tight text-blue-600">UNIFY</span>
          <div className="flex items-center gap-6">
            <a href="#universities" className="hidden sm:block text-sm text-gray-500 hover:text-gray-900 transition-colors">
              For Universities
            </a>
            <a
              href="#waitlist"
              className="bg-blue-600 text-white text-sm font-semibold px-4 py-2 rounded-full hover:bg-blue-700 active:scale-95 transition-all"
            >
              Get Early Access
            </a>
          </div>
        </div>
      </nav>

      {/* ── Hero ── */}
      <section className="max-w-5xl mx-auto px-5 pt-20 pb-24 text-center">
        <Reveal>
          <div className="inline-flex items-center gap-2 bg-blue-50 text-blue-600 text-xs font-semibold px-4 py-1.5 rounded-full mb-6">
            🇬🇭 Built for Ghanaian universities
          </div>
        </Reveal>
        <Reveal delay={80}>
          <h1 className="text-4xl sm:text-5xl md:text-6xl font-extrabold leading-tight tracking-tight text-gray-900 mb-6">
            The Campus Identity &<br />
            <span className="text-blue-600">Announcement Platform</span>
          </h1>
        </Reveal>
        <Reveal delay={160}>
          <p className="text-gray-500 text-lg sm:text-xl max-w-2xl mx-auto mb-10 leading-relaxed">
            UNIFY gives every student a verified campus identity and every university a direct channel to reach them — no spam groups, no missed notices.
          </p>
        </Reveal>
        <Reveal delay={240}>
          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            <a
              href="#waitlist"
              className="bg-blue-600 text-white font-bold px-8 py-4 rounded-full text-base hover:bg-blue-700 active:scale-95 transition-all"
            >
              Join the Waitlist
            </a>
            <a
              href="#universities"
              className="border border-gray-200 text-gray-700 font-semibold px-8 py-4 rounded-full text-base hover:border-gray-400 active:scale-95 transition-all"
            >
              For Universities →
            </a>
          </div>
        </Reveal>
      </section>

      {/* ── Problem ── */}
      <section className="bg-gray-50 py-20">
        <div className="max-w-5xl mx-auto px-5">
          <Reveal>
            <h2 className="text-2xl sm:text-3xl font-bold text-center text-gray-900 mb-3">
              Campus communication is broken
            </h2>
            <p className="text-gray-500 text-center mb-12 max-w-xl mx-auto">
              Students miss critical updates. Universities have no reliable channel. Everyone is stuck in noisy, unverified WhatsApp groups.
            </p>
          </Reveal>
          <div className="grid sm:grid-cols-3 gap-6">
            {[
              {
                icon: '📢',
                title: 'Announcements get lost',
                body: 'Lecture halls change, exams reschedule, hostel allocations open — and students find out three days late through a screenshot in a group chat.',
              },
              {
                icon: '🔓',
                title: 'No verified identity',
                body: 'Anyone can join a "KNUST students" group. Without verification, there is no way to know who you are actually talking to.',
              },
              {
                icon: '🌊',
                title: 'Group chats are unmanageable',
                body: 'A 500-person WhatsApp group floods 400 messages a day. Important notices are buried under memes and off-topic chatter.',
              },
            ].map((item, i) => (
              <Reveal key={item.title} delay={i * 80}>
                <div className="bg-white rounded-2xl p-6 border border-gray-100">
                  <div className="text-3xl mb-4">{item.icon}</div>
                  <h3 className="font-bold text-gray-900 mb-2">{item.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed">{item.body}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── Solution ── */}
      <section className="py-20">
        <div className="max-w-5xl mx-auto px-5">
          <Reveal>
            <h2 className="text-2xl sm:text-3xl font-bold text-center text-gray-900 mb-3">
              UNIFY is the official digital layer for your university
            </h2>
            <p className="text-gray-500 text-center mb-12 max-w-xl mx-auto">
              Three things that make a campus actually work online.
            </p>
          </Reveal>
          <div className="grid sm:grid-cols-3 gap-6">
            {[
              {
                icon: '🪪',
                color: 'bg-blue-50 text-blue-600',
                title: 'Verified Campus Identity',
                body: 'Every student gets a verified profile tied to their institution. No imposters, no ghost accounts — just real students with real credentials.',
              },
              {
                icon: '📣',
                color: 'bg-orange-50 text-orange-600',
                title: 'Official Announcements',
                body: 'Universities push critical notices directly to enrolled students — exam schedules, hostel allocations, academic updates — all in one feed.',
              },
              {
                icon: '🗂️',
                color: 'bg-green-50 text-green-600',
                title: 'Structured Communication',
                body: 'Department channels, year-group boards, and course groups — organised, searchable, and moderated. Not a 500-person free-for-all.',
              },
            ].map((item, i) => (
              <Reveal key={item.title} delay={i * 80}>
                <div className="bg-gray-50 rounded-2xl p-6">
                  <div className={`w-12 h-12 rounded-2xl ${item.color} flex items-center justify-center text-2xl mb-4`}>
                    {item.icon}
                  </div>
                  <h3 className="font-bold text-gray-900 mb-2">{item.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed">{item.body}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── How It Works ── */}
      <section className="bg-gray-50 py-20">
        <div className="max-w-3xl mx-auto px-5 text-center">
          <Reveal>
            <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-3">How it works</h2>
            <p className="text-gray-500 mb-14">Three steps. No paperwork.</p>
          </Reveal>
          <div className="flex flex-col sm:flex-row gap-8 sm:gap-4 items-start justify-center">
            {[
              { step: '1', title: 'Download & join', body: 'Sign up with your phone number and select your university.' },
              { step: '2', title: 'Verify your identity', body: 'Enter your student ID or index number. We confirm enrolment instantly.' },
              { step: '3', title: 'Stay in the loop', body: 'Follow official channels, get announcements, and connect with classmates — all verified.' },
            ].map((item, i) => (
              <Reveal key={item.step} delay={i * 100} className="flex-1">
                <div className="flex flex-col items-center">
                  <div className="w-12 h-12 rounded-full bg-blue-600 text-white font-bold text-lg flex items-center justify-center mb-4">
                    {item.step}
                  </div>
                  {i < 2 && (
                    <div className="hidden sm:block absolute translate-x-32 -translate-y-6 text-gray-300 text-2xl select-none">→</div>
                  )}
                  <h3 className="font-bold text-gray-900 mb-2">{item.title}</h3>
                  <p className="text-gray-500 text-sm leading-relaxed max-w-xs">{item.body}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── Student / University Split ── */}
      <section id="universities" className="py-20">
        <div className="max-w-5xl mx-auto px-5">
          <Reveal>
            <h2 className="text-2xl sm:text-3xl font-bold text-center text-gray-900 mb-12">
              Built for both sides of the campus
            </h2>
          </Reveal>
          <div className="grid sm:grid-cols-2 gap-6">
            <Reveal>
              <div className="bg-blue-600 text-white rounded-3xl p-8">
                <div className="text-3xl mb-4">🎓</div>
                <h3 className="text-xl font-bold mb-3">For Students</h3>
                <ul className="space-y-3 text-blue-100 text-sm">
                  {[
                    'Verified digital student identity',
                    'Never miss an official announcement',
                    'Connect with coursemates in your year and department',
                    'One platform for all your campus communities',
                    'Free. Always.',
                  ].map((item) => (
                    <li key={item} className="flex items-start gap-2">
                      <span className="text-blue-300 mt-0.5">✓</span>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            </Reveal>
            <Reveal delay={100}>
              <div className="bg-gray-900 text-white rounded-3xl p-8">
                <div className="text-3xl mb-4">🏛️</div>
                <h3 className="text-xl font-bold mb-3">For Universities</h3>
                <ul className="space-y-3 text-gray-400 text-sm">
                  {[
                    'Push announcements directly to enrolled students',
                    'Verified student directory with enrolment status',
                    'Department and faculty channel management',
                    'Engagement analytics — open rates, reach, response',
                    'Replace fragmented WhatsApp groups with one platform',
                  ].map((item) => (
                    <li key={item} className="flex items-start gap-2">
                      <span className="text-gray-500 mt-0.5">✓</span>
                      {item}
                    </li>
                  ))}
                </ul>
                <a
                  href="mailto:hello@joinunify.app"
                  className="inline-block mt-6 bg-white text-gray-900 font-semibold text-sm px-6 py-3 rounded-full hover:bg-gray-100 active:scale-95 transition-all"
                >
                  Partner with us →
                </a>
              </div>
            </Reveal>
          </div>
        </div>
      </section>

      {/* ── Waitlist CTA ── */}
      <section id="waitlist" className="bg-blue-600 py-20">
        <div className="max-w-2xl mx-auto px-5 text-center">
          <Reveal>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white mb-3">
              Be first when we launch at your school
            </h2>
            <p className="text-blue-100 mb-10 text-base">
              Drop your number. We'll text you the moment UNIFY opens on your campus.
            </p>
          </Reveal>
          <Reveal delay={100}>
            <JoinForm />
          </Reveal>
        </div>
      </section>

      {/* ── FAQ ── */}
      <section className="py-20">
        <div className="max-w-2xl mx-auto px-5">
          <Reveal>
            <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-10 text-center">
              Common questions
            </h2>
          </Reveal>
          <div className="divide-y divide-gray-200 border-t border-gray-200">
            {FAQS.map((faq, i) => (
              <Reveal key={i} delay={i * 40}>
                <FAQItem q={faq.q} a={faq.a} />
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── Final CTA ── */}
      <section className="bg-gray-50 py-20 text-center">
        <div className="max-w-xl mx-auto px-5">
          <Reveal>
            <p className="text-gray-400 text-sm font-semibold tracking-wide uppercase mb-4">
              Campus communication, fixed.
            </p>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-gray-900 mb-6">
              Your campus deserves better than a WhatsApp group.
            </h2>
            <a
              href="#waitlist"
              className="inline-block bg-blue-600 text-white font-bold px-10 py-4 rounded-full text-base hover:bg-blue-700 active:scale-95 transition-all"
            >
              Join the Waitlist
            </a>
          </Reveal>
        </div>
      </section>

      {/* ── Footer ── */}
      <footer className="border-t border-gray-100 py-10">
        <div className="max-w-5xl mx-auto px-5 flex flex-col sm:flex-row items-center justify-between gap-4">
          <span className="font-bold text-blue-600">UNIFY</span>
          <p className="text-gray-400 text-xs">© {new Date().getFullYear()} UNIFY. Built in Ghana 🇬🇭</p>
          <a href="mailto:hello@joinunify.app" className="text-gray-400 text-xs hover:text-gray-700 transition-colors">
            hello@joinunify.app
          </a>
        </div>
      </footer>

    </div>
  );
}
