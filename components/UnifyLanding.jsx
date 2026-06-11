'use client';

/**
 * UNIFY — Ghana's peer-to-peer university transition network
 * Full animation motion spec: hero stagger, scroll reveals, count-up,
 * carousel, FAQ accordion, SVG draw-on, ticker pause-on-hover.
 *
 * Dependencies:
 *   npm install lucide-react
 *   Tailwind CSS configured
 */

import { useState, useEffect, useRef } from 'react';
import { MapPin, CheckCircle, ArrowRight, ChevronDown, Users2, GraduationCap, Building2, Sparkles, Star, MessageCircle, Bell } from 'lucide-react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

const GHANA_PHONE_RE = /^(?:\+233|0)(20|24|50|54|55|59|23|25|26|27)\d{7}$/;

function normalizePhone(raw) {
  const s = raw.replace(/[\s\-().]/g, '');
  if (s.startsWith('+233')) return '0' + s.slice(4);
  if (s.startsWith('233')) return '0' + s.slice(3);
  return s;
}

function track(event, data) {
  console.log('[UNIFY Analytics]', event, { ...data, ts: new Date().toISOString() });
}

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
  {
    quote: "Coming from Tamale, I was worried about finding people in Accra. UNIFY linked me with 2 other northern students before I even left home.",
    name: 'Kwesi A.', role: 'UDS Engineering Fresher', initials: 'KA', stars: 5,
  },
  {
    quote: "The hostel reviews saved me. I almost booked a place with no water and bad WiFi. The hub gave me the real intel.",
    name: 'Efua M.', role: 'UPSA Business Fresher', initials: 'EM', stars: 4,
  },
  {
    quote: "Matched with my roommate in June. By September we already knew each other's habits. Zero orientation stress.",
    name: 'Kofi B.', role: 'KNUST Pharmacy Fresher', initials: 'KB', stars: 5,
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

function useHeroSequence() {
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const t = setTimeout(() => setVisible(true), 50);
    return () => clearTimeout(t);
  }, []);
  return visible;
}

function useScrollReveal(threshold = 0.15) {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    if (!ref.current) return;
    const observer = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) { setVisible(true); observer.disconnect(); } },
      { threshold }
    );
    observer.observe(ref.current);
    return () => observer.disconnect();
  }, [threshold]);
  return [ref, visible];
}

function useCountUp(target, duration = 1500, trigger = false) {
  const [value, setValue] = useState(0);
  useEffect(() => {
    if (!trigger) return;
    let start = null;
    const numTarget = typeof target === 'number' ? target : parseFloat(target);
    const isDecimal = numTarget !== Math.floor(numTarget);
    const step = (timestamp) => {
      if (!start) start = timestamp;
      const progress = Math.min((timestamp - start) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 4);
      setValue(isDecimal ? (eased * numTarget).toFixed(1) : Math.floor(eased * numTarget));
      if (progress < 1) requestAnimationFrame(step);
      else setValue(isDecimal ? numTarget.toFixed(1) : numTarget);
    };
    requestAnimationFrame(step);
  }, [trigger, target, duration]);
  return value;
}

// ─── DECORATIVE SVGs ──────────────────────────────────────────────────────────

function BlueDoodle({ drawn = true }) {
  const lineStyle = drawn ? {
    strokeDasharray: 200,
    animation: 'drawStroke 400ms var(--ease-out-expo) both',
  } : { strokeDasharray: 200, strokeDashoffset: 200 };
  return (
    <svg viewBox="0 0 40 40" className="w-8 h-8 text-[#FF6B35]" fill="none">
      <line x1="20" y1="2" x2="20" y2="10" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="20" y1="30" x2="20" y2="38" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="2" y1="20" x2="10" y2="20" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="30" y1="20" x2="38" y2="20" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="6" y1="6" x2="12" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
      <line x1="28" y1="28" x2="34" y2="34" stroke="currentColor" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
      <line x1="34" y1="6" x2="28" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
      <line x1="6" y1="34" x2="12" y2="28" stroke="currentColor" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
    </svg>
  );
}

function OrangeDoodle({ drawn = true }) {
  const lineStyle = drawn ? {
    strokeDasharray: 200,
    animation: 'drawStroke 400ms var(--ease-out-expo) both',
  } : { strokeDasharray: 200, strokeDashoffset: 200 };
  return (
    <svg viewBox="0 0 40 40" className="w-8 h-8" fill="none">
      <line x1="20" y1="2" x2="20" y2="10" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="20" y1="30" x2="20" y2="38" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="2" y1="20" x2="10" y2="20" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="30" y1="20" x2="38" y2="20" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" style={lineStyle}/>
      <line x1="6" y1="6" x2="12" y2="12" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
      <line x1="28" y1="28" x2="34" y2="34" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
      <line x1="34" y1="6" x2="28" y2="12" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
      <line x1="6" y1="34" x2="12" y2="28" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round" style={lineStyle}/>
    </svg>
  );
}

function SparkDoodle({ color = '#FF6B35', size = 28, visible = true, delay = 0 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 28 28" fill="none" aria-hidden="true"
      className={visible ? 'spark-visible' : 'spark-hidden'}
      style={visible ? { animationDelay: `${delay}ms` } : {}}>
      <line x1="14" y1="2"  x2="14" y2="8"  stroke={color} strokeWidth="2" strokeLinecap="round"/>
      <line x1="14" y1="20" x2="14" y2="26" stroke={color} strokeWidth="2" strokeLinecap="round"/>
      <line x1="2"  y1="14" x2="8"  y2="14" stroke={color} strokeWidth="2" strokeLinecap="round"/>
      <line x1="20" y1="14" x2="26" y2="14" stroke={color} strokeWidth="2" strokeLinecap="round"/>
      <line x1="5"  y1="5"  x2="9"  y2="9"  stroke={color} strokeWidth="1.5" strokeLinecap="round"/>
      <line x1="19" y1="19" x2="23" y2="23" stroke={color} strokeWidth="1.5" strokeLinecap="round"/>
      <line x1="23" y1="5"  x2="19" y2="9"  stroke={color} strokeWidth="1.5" strokeLinecap="round"/>
      <line x1="5"  y1="23" x2="9"  y2="19" stroke={color} strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

function SquiggleUnderline({ heroVisible }) {
  return (
    <svg
      viewBox="0 0 120 10"
      className={`block w-28 h-3 mt-1${heroVisible ? ' underline-drawn' : ''}`}
      fill="none"
      style={heroVisible ? { transformOrigin: 'left center' } : { opacity: 0 }}
    >
      <path d="M0,5 C10,1 20,9 30,5 C40,1 50,9 60,5 C70,1 80,9 90,5 C100,1 110,9 120,5"
        stroke="#FF6B35" strokeWidth="3.5" strokeLinecap="round"/>
    </svg>
  );
}

function BlueSwirl({ className = '', drawn = false }) {
  return (
    <svg viewBox="0 0 80 200" className={`w-16 h-40 text-[#FF6B35] opacity-20 ${className}`} fill="none">
      <path
        d="M60,10 C80,40 20,60 40,90 C60,120 80,140 40,170 C20,185 10,190 20,195"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        style={drawn ? {
          strokeDasharray: 400,
          animation: 'drawStroke 1200ms var(--ease-in-out-smooth) both',
          '--path-len': 400,
        } : { strokeDasharray: 400, strokeDashoffset: 400 }}
      />
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
      className={`shrink-0 text-[10px] font-bold px-2.5 py-1 rounded-full border transition-all ${copied ? 'bg-[#A8C4FF]/10 border-[#A8C4FF]/30 text-[#A8C4FF]' : 'bg-white/5 border-white/10 text-white/60 hover:border-[#FF6B35]/40 hover:text-purple-300'}`}
    >
      {copied ? 'Copied!' : 'Copy'}
    </button>
  );
}

function WaitlistForm({ id = 'waitlist-form', defaultSchool = '' }) {
  const [school, setSchool] = useState(defaultSchool || '');
  const [phone, setPhone] = useState('');
  const [phoneError, setPhoneError] = useState('');
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);

  const schoolLabel = SCHOOLS.find(s => s.id === school)?.label || school || 'your campus';

  const waShareText = encodeURIComponent(
    `Bro 👀 I just claimed my spot on UNIFY — Ghana's fresher network. Find roommates, link with coursemates, and join your campus hub before matriculation. It's free fr. https://unify-lake.vercel.app/`
  );

  function validatePhone(value) {
    const norm = normalizePhone(value);
    if (!norm) return 'Please enter a valid Ghana phone number (e.g., 0551234567)';
    if (!GHANA_PHONE_RE.test(norm)) return 'Please enter a valid Ghana phone number (e.g., 0551234567)';
    return '';
  }

  async function handleSubmit(e) {
    e?.preventDefault();
    if (!school) { alert('Please select your school first'); return; }
    const err = validatePhone(phone);
    if (err) { setPhoneError(err); return; }
    setPhoneError('');
    setLoading(true);
    const norm = normalizePhone(phone);
    track('cta_click', { school, phone: norm.slice(0, 4) + '******' });
    console.log('[UNIFY Submit]', { school, phone: norm, timestamp: new Date().toISOString() });
    try {
      const params = new URLSearchParams({ phone: norm, school, ts: new Date().toISOString() });
      await fetch(`${SHEET_URL}?${params}`, { method: 'GET', mode: 'no-cors' });
    } catch { /* silent */ }
    setLoading(false);
    setDone(true);
  }

  if (done) {
    return (
      <div
        style={{
          animation: 'revealUp 600ms cubic-bezier(0.16,1,0.3,1) both',
          background: '#162347',
          borderRadius: 24,
          padding: '40px 32px',
          boxShadow: '0 8px 40px rgba(123,47,190,0.2)',
          border: '1px solid rgba(255,255,255,0.08)',
          textAlign: 'center',
          maxWidth: 480,
          margin: '0 auto',
        }}
      >
        <div style={{ fontSize: 48, marginBottom: 12 }}>🔥</div>
        <h3 style={{ fontSize: 24, fontWeight: 900, color: '#FFFFFE', marginBottom: 8 }}>You&apos;re in!</h3>
        <p style={{ color: 'rgba(255,255,255,0.5)', fontSize: 15, marginBottom: 4 }}>
          We&apos;ll text you when your <strong style={{ color: '#FFFFFE' }}>{schoolLabel}</strong> hub opens.
        </p>
        <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: 13, marginBottom: 24 }}>Share with your friends so they don&apos;t miss out.</p>
        <a
          href={`https://wa.me/?text=${waShareText}`}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => track('whatsapp_click', { type: 'share' })}
          style={{
            display: 'inline-flex', alignItems: 'center', gap: 8,
            background: '#25D366', color: 'white', fontWeight: 900, fontSize: 15,
            borderRadius: 50, padding: '12px 28px', textDecoration: 'none',
            boxShadow: '0 4px 14px rgba(37,211,102,0.35)',
          }}
        >
          <svg viewBox="0 0 24 24" width="18" height="18" fill="white">
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
          </svg>
          Share on WhatsApp
        </a>
      </div>
    );
  }

  return (
    <form id={id} onSubmit={handleSubmit} noValidate>
      {/* School pills */}
      <div className="flex flex-wrap justify-center gap-2 mb-6">
        {SCHOOLS.map((s) => (
          <button
            key={s.id}
            type="button"
            aria-pressed={school === s.id}
            onClick={() => { setSchool(s.id); track('nav_click', { page: s.id }); }}
            className={`text-xs font-bold px-4 py-2 rounded-full border transition-all duration-200 ${
              school === s.id
                ? 'bg-[#FF6B35] border-[#FF6B35] text-white shadow-[0_4px_14px_rgba(123,47,190,0.3)]'
                : 'bg-white/5 text-white/60 border-white/10 hover:border-[#FF6B35]/40 hover:text-purple-300'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>
      {/* Phone input */}
      <div className="flex flex-col sm:flex-row items-stretch gap-3 max-w-md mx-auto mb-2">
        <div className="flex-1 flex flex-col">
          <input
            type="tel"
            aria-label="Ghana phone number"
            placeholder="0551234567"
            value={phone}
            onChange={(e) => { setPhone(e.target.value); if (phoneError) setPhoneError(''); }}
            onKeyDown={(e) => e.key === 'Enter' && handleSubmit()}
            disabled={loading}
            className="flex-1 bg-white/5 border border-white/10 rounded-full px-5 py-3.5 text-sm text-white placeholder-white/30 outline-none focus:border-[#FF6B35]/60 focus:ring-2 focus:ring-[#FF6B35]/10 transition-all"
            style={phoneError ? { borderColor: '#dc2626', boxShadow: '0 0 0 2px rgba(220,38,38,0.15)' } : {}}
          />
        </div>
        <button
          type="submit"
          disabled={loading}
          className="btn-cta-glow bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-sm px-6 py-3.5 rounded-full shadow-[0_4px_14px_rgba(123,47,190,0.4)] transition-colors whitespace-nowrap disabled:opacity-60 disabled:cursor-not-allowed"
        >
          {loading ? 'Claiming…' : 'Claim Your Handle →'}
        </button>
      </div>
      {phoneError && (
        <p className="text-[#dc2626] text-xs text-center mt-1">{phoneError}</p>
      )}
    </form>
  );
}

function Ticker() {
  const [paused, setPaused] = useState(false);
  const items = [...TICKER_ITEMS, ...TICKER_ITEMS];
  const [ref, visible] = useScrollReveal(0.1);
  return (
    <div
      ref={ref}
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
      style={{
        opacity: visible ? 1 : 0,
        transition: 'opacity 800ms var(--ease-out-expo)',
        maskImage: 'linear-gradient(to right, transparent, black 8%, black 92%, transparent)',
        WebkitMaskImage: 'linear-gradient(to right, transparent, black 8%, black 92%, transparent)',
      }}
      className="overflow-hidden border-y border-white/10 bg-[#162347] py-3 relative"
    >
      <div
        className="flex gap-10 whitespace-nowrap w-max"
        style={{ animation: 'ticker 40s linear infinite', animationPlayState: paused ? 'paused' : 'running' }}
      >
        {items.map((item, i) => (
          <span key={i} className="text-[11px] font-semibold text-white/40 tracking-wide">{item}</span>
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
        className="relative bg-[#162347] border border-white/10 rounded-3xl max-w-lg w-full shadow-xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="h-1 w-full bg-gradient-to-r from-red-600 via-[#FF6B35] to-green-600" />
        <div className="p-8">
          <button
            onClick={close}
            className="absolute top-5 right-5 w-8 h-8 flex items-center justify-center rounded-full bg-white/5 hover:bg-white/10 text-white/40 hover:text-white text-lg transition-all"
            aria-label="Close"
          >
            ×
          </button>
          <div className="flex items-start gap-4 mb-6">
            <span className="text-3xl">👀</span>
            <div>
              <h3 className="text-xl font-black text-white leading-tight mb-1">
                Hold on — your spot isn&apos;t saved yet.
              </h3>
              <p className="text-white/60 text-sm leading-relaxed">
                Freshers who sign up early get 48-hour priority access before their school hub opens to everyone.
              </p>
            </div>
          </div>
          <div className="border-t border-white/30 mb-6" />
          <WaitlistForm id="exit-form" />
          <p className="text-[11px] text-white/40 mt-4 text-center">
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
      <div className="flex items-center gap-2 bg-[#162347] border border-white/10 shadow-lg rounded-full px-4 py-3">
        <div className="flex-1 min-w-0">
          <p className="text-xs font-black text-white truncate">Secure your spot 🎓</p>
          <p className="text-[10px] text-white/50 truncate">Join Ghana&apos;s fresher network — free</p>
        </div>
        <a
          href="#waitlist"
          className="bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-xs px-4 py-2.5 rounded-full whitespace-nowrap flex-shrink-0 active:scale-95 transition-all shadow-[0_4px_14px_rgba(123,47,190,0.4)]"
        >
          Claim Handle →
        </a>
        <button
          onClick={() => setDismissed(true)}
          className="text-white/40 hover:text-white/60 text-lg leading-none flex-shrink-0 pl-1"
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
    <div style={{ animation: 'phoneBob 6s ease-in-out infinite' }} className="relative w-64 h-[520px] mx-auto">
      <div className="absolute inset-0 rounded-[40px] bg-[#162347] border border-white/10 shadow-[0_30px_60px_rgba(123,47,190,0.20)]" />
      <div className="absolute inset-[3px] rounded-[38px] overflow-hidden bg-[#162347] p-4 flex flex-col gap-3">
        <div className="flex justify-between text-[10px] text-white/40 px-1">
          <span>9:41</span><span>●●●</span>
        </div>
        <div className="text-white text-sm font-bold">Find your campus fam 👋</div>
        {[
          { name: 'Ama O.', school: 'KNUST', tag: 'Roommate' },
          { name: 'Kofi B.', school: 'UG Legon', tag: 'Coursemates' },
        ].map((p) => (
          <div key={p.name} className="bg-white/5 border border-white/10 rounded-2xl p-3 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[#FF6B35]/10 border border-[#FF6B35]/20 flex items-center justify-center text-xs font-bold text-[#FF6B35]">
              {p.name[0]}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-white text-xs font-semibold">{p.name}</p>
              <p className="text-white/40 text-[10px]">{p.school}</p>
            </div>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FF6B35]/10 border border-[#FF6B35]/20 text-[#FF6B35]">{p.tag}</span>
          </div>
        ))}
        <div className="bg-white/5 border border-white/10 rounded-2xl p-3">
          <p className="text-white/40 text-[10px] mb-2">YOUR HUB</p>
          <p className="text-white text-xs font-bold">KNUST Brunei Hub</p>
          <p className="text-white/40 text-[10px]">420 freshers · Active</p>
          <div className="mt-2 w-full bg-[#1F2937] text-white text-[10px] font-black rounded-full py-1 text-center">Join Hub →</div>
        </div>
        <div className="mt-auto bg-[#FF6B35]/8 border border-[#FF6B35]/15 rounded-2xl p-3 text-center">
          <p className="text-[#FF6B35] text-xs font-black">#247 on waitlist</p>
          <p className="text-white/40 text-[10px]">Refer friends to move up</p>
        </div>
      </div>
    </div>
  );
}

// ─── GHANA MAP VIZ ────────────────────────────────────────────────────────────

// ─── CAMPUS COLLAGE (between hub cards and school search) ────────────────────
const CAMPUS_TILES = [
  { initials: 'KN', label: 'KNUST',    sub: '420 freshers', grad: 'linear-gradient(135deg,#E55A22,#FF6B35)', photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Kwame_Nkrumah_University_of_Science_and_Technology_(KNUST)_%E2%80%93_Side_view_of_the_College_of_Architecture_and_Planning.JPG?width=500', delay: 0   },
  { initials: 'UG', label: 'UG Legon', sub: '310 freshers', grad: 'linear-gradient(135deg,#7c3aed,#6366f1)', photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Legon_Tower.JPG?width=500', delay: 80  },
  { initials: 'UC', label: 'UCC',      sub: '185 freshers', grad: 'linear-gradient(135deg,#059669,#0891b2)', photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Cape_Coast_Ghana.JPG?width=500', delay: 160 },
  { initials: 'UP', label: 'UPSA',     sub: '92 freshers',  grad: 'linear-gradient(135deg,#dc2626,#be185d)', photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Warren_Library_Ashesi.JPG?width=500', delay: 240 },
];

function CampusCollage({ animate = false }) {
  return (
    <div className="relative rounded-3xl overflow-hidden p-6 md:p-8"
         style={{ background: 'linear-gradient(135deg,#0a1628 0%,#0d1f3c 60%,#0f2952 100%)' }}>
      {/* Dot grid */}
      <div className="absolute inset-0 opacity-[0.07]"
           style={{ backgroundImage: 'radial-gradient(circle,rgba(255,255,255,0.06) 1px,transparent 1px)', backgroundSize: '22px 22px' }} />

      <div className="relative grid grid-cols-2 gap-4">
        {CAMPUS_TILES.map((t) => (
          <div
            key={t.label}
            className="rounded-2xl p-5 flex flex-col justify-between overflow-hidden"
            style={{
              background: t.grad,
              minHeight: 120,
              position: 'relative',
              animation: animate ? `revealUp 600ms var(--ease-out-expo) ${t.delay}ms both` : 'none',
              opacity: animate ? undefined : 0,
            }}
          >
            {/* Campus photo */}
            {t.photo && (
              <img src={t.photo} alt={t.label} style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', objectFit: 'cover', objectPosition: 'center' }} />
            )}
            {/* Dark overlay */}
            <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to bottom, rgba(0,0,0,0.08) 0%, rgba(0,0,0,0.38) 100%)' }} />
            {/* Large faded initials */}
            <div style={{ fontSize: 52, fontWeight: 900, color: 'rgba(255,255,255,0.13)', lineHeight: 1, position: 'absolute', right: 12, top: 8, pointerEvents: 'none', userSelect: 'none' }}>
              {t.initials}
            </div>
            <span style={{ position: 'relative', fontSize: 11, fontWeight: 900, color: 'rgba(255,255,255,0.8)', textTransform: 'uppercase', letterSpacing: '0.1em' }}>{t.label}</span>
            <div style={{ position: 'relative' }}>
              <div style={{ fontSize: 22, fontWeight: 900, color: 'white', lineHeight: 1 }}>{t.sub}</div>
              <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.65)', fontWeight: 700, marginTop: 2 }}>waiting in hub</div>
            </div>
          </div>
        ))}
      </div>

      {/* Live badge */}
      <div className="relative mt-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#4FC3F7] opacity-60" />
            <span className="relative inline-flex rounded-full h-2 w-2 bg-[#4FC3F7]" />
          </span>
          <span style={{ fontSize: 10, fontWeight: 800, color: '#4FC3F7', letterSpacing: '0.12em', textTransform: 'uppercase' }}>Live · Ghana</span>
        </div>
        <div style={{ background: 'rgba(255,255,255,0.1)', border: '1px solid rgba(255,255,255,0.15)', borderRadius: 50, padding: '4px 14px' }}>
          <span style={{ fontSize: 12, fontWeight: 900, color: 'white' }}>1,074 freshers online</span>
        </div>
      </div>
    </div>
  );
}

// ─── SCHOOL LOCATOR (left side of school search section) ─────────────────────
const LOCATOR_SCHOOLS = [
  { name: 'KNUST',    location: 'Kumasi',      freshers: 420, color: '#FF6B35', initials: 'KN', delay: 0   },
  { name: 'UG Legon', location: 'Accra',       freshers: 310, color: '#7c3aed', initials: 'UG', delay: 80  },
  { name: 'UCC',      location: 'Cape Coast',  freshers: 185, color: '#059669', initials: 'UC', delay: 160 },
  { name: 'UPSA',     location: 'Accra',       freshers: 92,  color: '#dc2626', initials: 'UP', delay: 240 },
  { name: 'UDS',      location: 'Tamale',      freshers: 67,  color: '#FF6B35', initials: 'UD', delay: 320 },
  { name: 'GCTU',     location: 'Accra',       freshers: 54,  color: '#0891b2', initials: 'GC', delay: 400 },
];

function SchoolLocatorViz({ animate = false }) {
  return (
    <div className="relative w-full h-full min-h-[300px] flex flex-col p-5"
         style={{ background: 'linear-gradient(160deg,#f8faff 0%,#eef4ff 100%)', borderRadius: 24 }}>
      <div className="flex items-center justify-between mb-3">
        <div>
          <p style={{ fontSize: 10, fontWeight: 800, color: '#FF6B35', letterSpacing: '0.15em', textTransform: 'uppercase' }}>School Directory</p>
          <p style={{ fontSize: 14, fontWeight: 900, color: '#FFFFFE' }}>Ghana Universities</p>
        </div>
        <div style={{ background: '#FF6B35', color: 'white', fontSize: 10, fontWeight: 900, borderRadius: 50, padding: '4px 10px' }}>180+ schools</div>
      </div>
      <div className="flex flex-col gap-2 flex-1">
        {LOCATOR_SCHOOLS.map((s) => (
          <div key={s.name} className="flex items-center gap-3 rounded-2xl px-3 py-2"
               style={{ background: '#162347', border: `1px solid rgba(255,255,255,0.1)`, boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
                        animation: animate ? `schoolCardIn 500ms var(--ease-out-expo) ${s.delay}ms both` : 'none',
                        opacity: animate ? undefined : 0 }}>
            <div style={{ width: 30, height: 30, borderRadius: '50%', background: `linear-gradient(135deg,${s.color},${s.color}99)`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <span style={{ color: 'white', fontWeight: 900, fontSize: 8 }}>{s.initials}</span>
            </div>
            <div className="flex-1 min-w-0">
              <p style={{ fontSize: 11, fontWeight: 900, color: '#FFFFFE' }}>{s.name}</p>
              <p style={{ fontSize: 9, color: 'rgba(255,255,255,0.4)', fontWeight: 600 }}>{s.location}</p>
            </div>
            <div style={{ background: `${s.color}12`, border: `1px solid ${s.color}30`, borderRadius: 50, padding: '2px 8px' }}>
              <span style={{ fontSize: 9, fontWeight: 800, color: s.color }}>{s.freshers}</span>
            </div>
          </div>
        ))}
      </div>
      <div className="mt-3 flex items-center justify-center gap-1.5">
        <span className="relative flex h-1.5 w-1.5">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#FF6B35] opacity-60" />
          <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-[#FF6B35]" />
        </span>
        <p style={{ fontSize: 9, color: 'rgba(255,255,255,0.5)', fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Updated live · 1,074 freshers joined</p>
      </div>
    </div>
  );
}

// ─── FAQ ACCORDION ────────────────────────────────────────────────────────────

function FAQAccordion({ items, visible }) {
  const [open, setOpen] = useState(null);
  return (
    <div className="flex flex-col divide-y divide-white/30">
      {items.map((faq, i) => (
        <div
          key={i}
          className="py-4"
          style={visible ? { animation: `revealUp 500ms var(--ease-out-expo) ${i * 80}ms both` } : { opacity: 0 }}
        >
          <button
            aria-expanded={open === i}
            className="w-full text-left flex items-center justify-between gap-4 group"
            onClick={() => { setOpen(open === i ? null : i); track('faq_expand', { question: faq.q }); }}
          >
            <span className="font-semibold text-sm text-white group-hover:text-purple-300 transition-colors duration-200">{faq.q}</span>
            <span
              className={`flex-shrink-0 w-6 h-6 rounded-full border flex items-center justify-center transition-all duration-300 ${open === i ? 'rotate-180 bg-[#FF6B35] border-[#FF6B35]' : 'border-[#FF6B35]/40 bg-white/5'}`}
            >
              <ChevronDown className={`w-3.5 h-3.5 transition-colors duration-300 ${open === i ? 'text-white' : 'text-[#FF6B35]'}`} />
            </span>
          </button>
          {/* Smooth height with grid */}
          <div
            style={{
              display: 'grid',
              gridTemplateRows: open === i ? '1fr' : '0fr',
              transition: 'grid-template-rows 400ms var(--ease-out-expo)',
            }}
          >
            <div style={{ overflow: 'hidden' }}>
              <p
                className="text-sm text-white/60 leading-relaxed mt-3 pr-8"
                style={{
                  opacity: open === i ? 1 : 0,
                  transition: 'opacity 300ms var(--ease-out-expo) 100ms',
                }}
              >
                {faq.a}
              </p>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

// ─── STAT ITEM WITH COUNT-UP ──────────────────────────────────────────────────

function formatStat(n, { is12K, isDecimal, suffix }) {
  const v = Number(n);
  if (is12K) return `${Math.round(v / 1000)}K+`;
  if (isDecimal) return v.toFixed(1);
  return `${Math.floor(v)}${suffix}`;
}

function StatItem({ num, label, suffix = '', isDecimal = false, is12K = false, trigger }) {
  const rawVal = useCountUp(num, 1400, trigger);
  // Safety: during animation rawVal counts 0→num. If it hasn't started yet (0), show final value.
  // This prevents flashing wrong numbers if rAF hasn't fired yet.
  const animVal = trigger && rawVal > 0 ? rawVal : num;
  const display = formatStat(animVal, { is12K, isDecimal, suffix });
  return (
    <div className="px-4" style={trigger ? { animation: 'statReveal 600ms var(--ease-out-expo) both' } : {}}>
      <p className="text-3xl md:text-4xl font-black text-white">{display}</p>
      <p className="text-white/70 text-sm mt-1">{label}</p>
    </div>
  );
}

// ─── MOBILE MENU ─────────────────────────────────────────────────────────────

function MobileMenu() {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [open]);

  useEffect(() => {
    const handler = (e) => { if (e.key === 'Escape') setOpen(false); };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, []);

  const links = [
    { label: 'Home', href: '/' },
    { label: 'Hubs', href: '/hubs' },
    { label: 'Match', href: '/match' },
    { label: 'Schools', href: '/schools' },
    { label: 'FAQ', href: '/faq' },
  ];

  return (
    <>
      <button
        className="md:hidden flex flex-col gap-1.5 p-2"
        aria-label="Open menu"
        onClick={() => setOpen(true)}
      >
        <span className="block w-6 h-0.5 bg-white rounded-full" />
        <span className="block w-6 h-0.5 bg-white rounded-full" />
        <span className="block w-6 h-0.5 bg-white rounded-full" />
      </button>

      {open && (
        <div
          className="fixed inset-0 bg-black/40 z-[90]"
          style={{ animation: 'fadeIn 200ms ease both' }}
          onClick={() => setOpen(false)}
        />
      )}

      <div
        className="fixed top-0 right-0 bottom-0 w-4/5 max-w-xs bg-[#162347] border-l border-white/10 z-[100] flex flex-col p-8 shadow-2xl"
        style={{
          transform: open ? 'translateX(0)' : 'translateX(100%)',
          transition: open ? 'transform 300ms cubic-bezier(0.16,1,0.3,1)' : 'transform 250ms ease-in',
        }}
        role="dialog"
        aria-modal="true"
        aria-label="Navigation menu"
      >
        <button
          className="self-end w-10 h-10 rounded-full border border-white/10 bg-white/5 flex items-center justify-center text-white/60 hover:border-[#FF6B35]/50 hover:text-purple-300 transition-all mb-8"
          aria-label="Close menu"
          onClick={() => setOpen(false)}
        >
          ✕
        </button>

        <nav className="flex flex-col gap-2 flex-1">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              onClick={() => setOpen(false)}
              className="text-2xl font-black text-white py-3 border-b border-white/10 hover:text-purple-300 transition-colors"
            >
              {link.label}
            </a>
          ))}
        </nav>

        <div className="flex flex-col gap-3 mt-8">
          <a href="/login" onClick={() => setOpen(false)} className="w-full py-3 rounded-full border border-white/10 text-sm font-semibold text-white hover:border-[#FF6B35] hover:text-purple-300 transition-colors text-center">
            Sign In
          </a>
          <a href="#waitlist" onClick={() => setOpen(false)} className="w-full py-3 rounded-full bg-[#FF6B35] text-white text-sm font-black text-center hover:bg-[#E55A22] transition-colors">
            Get Early Access →
          </a>
        </div>
      </div>
    </>
  );
}

// ─── MAIN COMPONENT ──────────────────────────────────────────────────────────

export default function UnifyLanding({ schoolId } = {}) {
  const count = useSignupCount();
  const [faqPhone, setFaqPhone] = useState('');
  const [faqDone, setFaqDone] = useState(false);
  const [faqLoading, setFaqLoading] = useState(false);

  const heroVisible = useHeroSequence();

  const [statsRef, statsVisible] = useScrollReveal(0.05);
  const [featuresRef, featuresVisible] = useScrollReveal();
  const [communityRef, communityVisible] = useScrollReveal();
  const [testimonialsRef, testimonialsVisible] = useScrollReveal();
  const [faqRef, faqVisible] = useScrollReveal();
  const [ctaRef, ctaVisible] = useScrollReveal();

  // Testimonials carousel state
  const [activeTestimonial, setActiveTestimonial] = useState(0);

  useEffect(() => {
    if (!testimonialsVisible) return;
    const interval = setInterval(() => {
      setActiveTestimonial((prev) => (prev + 1) % TESTIMONIALS.length);
    }, 5000);
    return () => clearInterval(interval);
  }, [testimonialsVisible]);

  // Smooth scroll
  useEffect(() => {
    document.documentElement.style.scrollBehavior = 'smooth';
    return () => { document.documentElement.style.scrollBehavior = ''; };
  }, []);

  const sc = SCHOOL_CONFIG[schoolId] || null;
  const heroHeadline = sc ? sc.headline : "Don't Pull Up To Campus Alone,";

  // Hero style helper
  function heroStyle(delay, keyframe = 'heroFadeUp', duration = '800ms') {
    return heroVisible
      ? { animation: `${keyframe} ${duration} var(--ease-out-expo) ${delay}ms both` }
      : { opacity: 0 };
  }

  // Section reveal helper
  function sectionRevealStyle(visible, delay = 0) {
    return {
      opacity: 1,
      transform: visible ? 'translateY(0)' : 'translateY(28px)',
      transition: `transform 900ms var(--ease-out-expo) ${delay}ms`,
    };
  }

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

  // Community avatars
  const AVATARS = [
    { initials: 'EO', bg: 'bg-[#FF6B35]/20', text: 'text-[#FF6B35]', top: '38%', left: '42%', order: 0 },
    { initials: 'AA', bg: 'bg-[#FF6B35]/20', text: 'text-purple-300', top: '10%', left: '30%', order: 1 },
    { initials: 'KB', bg: 'bg-[#A8C4FF]/20', text: 'text-[#A8C4FF]', top: '10%', left: '55%', order: 2 },
    { initials: 'SM', bg: 'bg-[#FF6B35]/30', text: 'text-purple-200', top: '38%', left: '15%', order: 3 },
    { initials: 'FA', bg: 'bg-[#FF6B35]/15', text: 'text-[#FF6B35]', top: '38%', left: '68%', order: 4 },
    { initials: 'YM', bg: 'bg-cyan-100', text: 'text-cyan-700', top: '65%', left: '30%', order: 5 },
  ];

  function prevTestimonial() {
    setActiveTestimonial((prev) => (prev - 1 + TESTIMONIALS.length) % TESTIMONIALS.length);
  }
  function nextTestimonial() {
    setActiveTestimonial((prev) => (prev + 1) % TESTIMONIALS.length);
  }

  return (
    <div className="relative min-h-screen p-4 md:p-8 antialiased"
         style={{ background: '#0D1B3E', fontFamily: "'Inter', system-ui, sans-serif" }}>
      <a href="#main-content" className="skip-link">Skip to main content</a>

      <style>{`
        :root {
          --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
          --ease-in-out-smooth: cubic-bezier(0.65, 0, 0.35, 1);
          --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
          --dur-fast: 200ms;
          --dur-base: 600ms;
          --dur-slow: 1000ms;
          --dur-ambient: 4000ms;
        }

        /* Hero entrance */
        @keyframes heroFadeUp {
          from { opacity: 0; transform: translateY(30px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes heroFadeDown {
          from { opacity: 0; transform: translateY(-12px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes heroScaleIn {
          from { opacity: 0; transform: scale(0.8); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes heroDoodle {
          from { opacity: 0; transform: scale(0) rotate(-10deg); }
          to   { opacity: 1; transform: scale(1) rotate(0deg); }
        }

        /* Underline draw-on */
        @keyframes underlineDraw {
          from { transform: scaleX(0); }
          to   { transform: scaleX(1); }
        }
        @keyframes underlineWobble {
          0%, 100% { transform: scaleX(1) skewX(-1deg); }
          50%       { transform: scaleX(1) skewX(1deg); }
        }
        .underline-drawn {
          animation: underlineDraw 500ms var(--ease-out-expo) 600ms both,
                     underlineWobble 3s ease-in-out 1100ms infinite;
          transform-origin: left center;
        }

        /* Scroll reveal */
        @keyframes revealUp {
          from { opacity: 0; transform: translateY(60px); }
          to   { opacity: 1; transform: translateY(0); }
        }

        /* SVG draw-on */
        @keyframes drawStroke {
          from { stroke-dashoffset: var(--path-len, 200); }
          to   { stroke-dashoffset: 0; }
        }

        /* Map pin */
        @keyframes pinDrop {
          0%   { opacity: 0; transform: translateY(-30px) scale(0.5); }
          70%  { transform: translateY(4px) scale(1.05); }
          100% { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes pinFloat {
          0%, 100% { transform: translateY(0); }
          50%       { transform: translateY(-6px); }
        }

        /* Avatar */
        @keyframes avatarPop {
          from { opacity: 0; transform: scale(0); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes breathe {
          0%, 100% { transform: scale(1); }
          50%       { transform: scale(1.03); }
        }
        @keyframes bubblePop {
          from { opacity: 0; transform: scale(0.8); }
          to   { opacity: 1; transform: scale(1); }
        }

        /* Stats count-up shimmer */
        @keyframes statReveal {
          from { opacity: 0; transform: scale(0.85) translateY(12px); }
          to   { opacity: 1; transform: scale(1) translateY(0); }
        }

        /* Testimonials */
        @keyframes cardSlideIn {
          from { opacity: 0; transform: translateX(60px); }
          to   { opacity: 1; transform: translateX(0); }
        }

        /* Ticker */
        @keyframes ticker {
          0%   { transform: translateX(0); }
          100% { transform: translateX(-50%); }
        }

        /* Phone bob */
        @keyframes phoneBob {
          0%, 100% { transform: translateY(0) rotate(0deg); }
          33%       { transform: translateY(-8px) rotate(0.5deg); }
          66%       { transform: translateY(-4px) rotate(-0.3deg); }
        }

        @keyframes schoolCardIn {
          from { opacity: 0; transform: translateY(14px) scale(0.95); }
          to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* Ambient drift */
        @keyframes driftY {
          from { transform: translateY(0); }
          to   { transform: translateY(-12px); }
        }

        /* Spark pop-in on scroll */
        @keyframes sparkPop {
          from { opacity: 0; transform: scale(0) rotate(-15deg); }
          to   { opacity: 1; transform: scale(1) rotate(0deg); }
        }
        .spark-visible { animation: sparkPop 400ms var(--ease-spring) both; }
        .spark-hidden  { opacity: 0; }

        /* Ambient drift dots */
        @keyframes driftY {
          from { transform: translateY(0); }
          to   { transform: translateY(-12px); }
        }

        /* Fade in for backdrop */
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }

        /* Focus rings */
        :focus-visible {
          outline: 2px solid #FF6B35;
          outline-offset: 2px;
          border-radius: 4px;
        }

        /* Skip link */
        .skip-link {
          position: absolute;
          top: -100px;
          left: 16px;
          background: #FF6B35;
          color: white;
          padding: 8px 16px;
          border-radius: 8px;
          font-weight: 700;
          font-size: 14px;
          z-index: 9999;
          text-decoration: none;
          transition: top 200ms;
        }
        .skip-link:focus {
          top: 16px;
        }

        /* Reduced motion */
        @media (prefers-reduced-motion: reduce) {
          *, *::before, *::after {
            animation-duration: 0.01ms !important;
            animation-iteration-count: 1 !important;
            transition-duration: 0.01ms !important;
            scroll-behavior: auto !important;
          }
        }

        /* Nav links */
        .nav-link { position: relative; transition: color 200ms; }
        .nav-link::after { content: ''; position: absolute; bottom: -2px; left: 0; width: 0; height: 2px; background: #FF6B35; border-radius: 999px; transition: width 200ms var(--ease-out-expo); }
        .nav-link:hover::after { width: 100%; }

        /* Feature cards */
        .feature-card { transition: transform 300ms var(--ease-out-expo), box-shadow 300ms var(--ease-out-expo), border-color 300ms; }
        .feature-card:hover { transform: translateY(-6px); border-color: rgba(123,47,190,0.4); box-shadow: 0 16px 48px rgba(123,47,190,0.15), 0 8px 32px rgba(0,0,0,0.3); }

        /* Footer links */
        .footer-link { transition: opacity 150ms, transform 150ms; }
        .footer-link:hover { opacity: 1 !important; transform: translateX(2px); }

        /* Social icons */
        .social-icon { transition: transform 200ms var(--ease-spring), background 200ms; }
        .social-icon:hover { transform: scale(1.1); }

        /* CTA button glow */
        .btn-cta-glow { transition: transform 200ms var(--ease-out-expo), box-shadow 200ms var(--ease-out-expo); }
        .btn-cta-glow:hover { transform: translateY(-2px); box-shadow: 0 12px 24px -8px rgba(31,41,55,0.45); }
        .btn-cta-glow:active { transform: translateY(0); }
      `}</style>

      {/* Fixed ambient blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
        <div className="absolute -top-1/4 -right-1/4 w-[700px] h-[700px] rounded-full bg-[#FF6B35]/[0.07] blur-[120px]" />
        <div className="absolute -bottom-1/4 -left-1/4 w-[600px] h-[600px] rounded-full bg-[#A8C4FF]/[0.05] blur-[100px]" />
        <div className="absolute top-1/3 left-1/3 w-[400px] h-[400px] rounded-full bg-amber-400/[0.04] blur-[80px]" />
      </div>

      {/* Browser wrapper */}
      <div className="max-w-7xl mx-auto bg-[#0D1B3E] border border-white/10 shadow-[0_40px_100px_rgba(123,47,190,0.15)] rounded-[32px] overflow-hidden">

        {/* ── NAVIGATION ──────────────────────────────────────────────── */}
        <nav
          className="sticky top-0 z-50 bg-[#0D1B3E]/90 backdrop-blur-2xl border-b-2 border-[#FF6B35]/50"
          style={heroStyle(0, 'heroFadeDown', '600ms')}
        >
          <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-lg font-black tracking-tight text-white">UNIFY</span>
              <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-[#FF6B35]/10 border border-[#FF6B35]/25 text-[#FF6B35]">GH</span>
            </div>
            <div className="hidden md:flex items-center gap-6 text-sm text-white/50 font-medium">
              <a href="#" className="relative text-white font-semibold" onClick={() => track('nav_click', { page: 'home' })}>
                Home
                <span className="absolute -bottom-0.5 left-0 right-0 h-0.5 rounded-full bg-[#FF6B35]" />
              </a>
              <a href="/hubs" className="nav-link hover:text-white transition-colors" onClick={() => track('nav_click', { page: 'hubs' })}>Hubs</a>
              <a href="/match" className="nav-link hover:text-white transition-colors" onClick={() => track('nav_click', { page: 'match' })}>Match</a>
              <a href="#schools" className="nav-link hover:text-white transition-colors" onClick={() => track('nav_click', { page: 'schools' })}>Schools</a>
              <a href="#faq" className="nav-link hover:text-white transition-colors" onClick={() => track('nav_click', { page: 'faq' })}>FAQ</a>
            </div>
            <div className="flex items-center gap-2">
              <a href="/login" className="hidden md:inline-flex text-sm font-semibold text-white/70 px-4 py-2 rounded-full border border-white/10 bg-white/5 backdrop-blur-sm hover:border-amber-400/50 hover:text-amber-400 transition-colors">
                Sign In
              </a>
              <a
                href="#waitlist"
                className="hidden md:inline-flex btn-cta-glow bg-[#FF6B35] hover:bg-[#E55A22] text-white text-xs font-black px-4 py-2.5 rounded-none border-2 border-[#FF6B35] shadow-[2px_2px_0px_rgba(255,255,255,0.3)]"
              >
                Get Early Access →
              </a>
              <MobileMenu />
            </div>
          </div>
        </nav>

        {/* ── HERO — 55/45 asymmetric ─────────────────────────────────── */}
        <section id="main-content" className="relative bg-[#0D1B3E] pt-16 md:pt-24 pb-12 md:pb-20 px-6">
          {/* Hero glow */}
          <div className="absolute inset-0 pointer-events-none" style={{ background: 'radial-gradient(ellipse at 70% 50%, rgba(0,102,255,0.06) 0%, transparent 70%)' }} />
          {/* Ambient drift dots */}
          {[
            { size: 10, top: '15%', left: '8%',  color: '#FF6B35', dur: '5.2s', delay: '0s'    },
            { size: 8,  top: '70%', left: '5%',  color: '#FF6B35', dur: '4.1s', delay: '1.2s'  },
            { size: 12, top: '30%', left: '92%', color: '#FF6B35', dur: '6.0s', delay: '0.5s'  },
            { size: 6,  top: '80%', left: '88%', color: '#FF6B35', dur: '4.8s', delay: '2.1s'  },
            { size: 8,  top: '55%', left: '3%',  color: '#FF6B35', dur: '5.5s', delay: '0.8s'  },
          ].map((d, i) => (
            <div key={i} className="absolute rounded-full pointer-events-none"
              style={{ width: d.size, height: d.size, top: d.top, left: d.left,
                background: d.color, opacity: 0.15,
                animation: `driftY ${d.dur} ease-in-out ${d.delay} infinite alternate` }} />
          ))}
          <div className="max-w-6xl mx-auto grid md:grid-cols-[55fr_45fr] gap-10 md:gap-16 items-center">
            {/* Left */}
            <div>
              <div
                className="inline-flex items-center gap-2 bg-[#FF6B35]/8 border border-[#FF6B35]/20 text-[#FF6B35] text-xs font-bold px-3.5 py-2 rounded-full mb-7"
                style={heroStyle(100)}
              >
                <span className="w-1.5 h-1.5 rounded-full bg-[#FF6B35] animate-pulse" />
                {sc ? sc.badge : "Built for Ghana's Freshers · Launching 2026"}
              </div>

              <div className="mb-6">
                <h1 style={{ fontFamily: "'Barlow Condensed', sans-serif", fontWeight: 900, lineHeight: 1, letterSpacing: '-0.01em' }} className="text-[3.2rem] md:text-[5rem] uppercase text-white">
                  <span style={heroStyle(150, 'heroFadeUp', '800ms')} className="block">
                    {heroHeadline}
                  </span>
                  <span className="block relative" style={heroStyle(250, 'heroFadeUp', '800ms')}>
                    <span className="text-[#FF6B35]">fr.</span>
                    <span className="inline-block ml-3 align-middle" style={{ width: 48, height: 6, background: '#FF6B35', borderRadius: 3, verticalAlign: 'middle', display: 'inline-block' }} />
                    <SquiggleUnderline heroVisible={heroVisible} />
                  </span>
                </h1>
              </div>

              <p
                className="text-base md:text-lg text-white/60 leading-relaxed mb-8 max-w-[440px] mt-5"
                style={heroStyle(400, 'heroFadeUp', '700ms')}
              >
                {sc ? sc.sub : "The ZeeMee for Ghana. Find your roommate, link with coursemates, and tap into your official campus hub before matriculation."}
              </p>

              <span className="relative inline-block mb-7" style={heroStyle(550, 'heroFadeUp', '700ms')}>
                <a
                  href="#waitlist"
                  className="btn-cta-glow inline-flex items-center gap-2 bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-base px-8 py-4 rounded-none border-2 border-white shadow-[4px_4px_0px_rgba(255,255,255,0.4)]"
                >
                  Get Early Access <ArrowRight className="w-4 h-4" />
                </a>
                <span className="absolute -top-1 -right-2 w-2 h-2 rounded-full bg-[#FF6B35] opacity-60" />
                <span className="absolute -bottom-1 -left-1 w-1.5 h-1.5 rounded-full bg-[#FF6B35] opacity-40" />
              </span>

              <div
                className="flex items-center gap-3 mb-5"
                style={heroStyle(700, 'heroScaleIn', '500ms')}
              >
                <div className="flex -space-x-2">
                  {[
                    { initials: 'KA', grad: 'linear-gradient(135deg,#FF6B35,#6366f1)' },
                    { initials: 'YM', grad: 'linear-gradient(135deg,#7c3aed,#a855f7)' },
                    { initials: 'FA', grad: 'linear-gradient(135deg,#FF6B35,#dc2626)' },
                    { initials: 'EB', grad: 'linear-gradient(135deg,#059669,#0891b2)' },
                    { initials: 'AO', grad: 'linear-gradient(135deg,#be185d,#9333ea)' },
                  ].map((a) => (
                    <div
                      key={a.initials}
                      className="w-8 h-8 rounded-full border-2 border-white/60 flex items-center justify-center text-[8px] font-black text-white"
                      style={{ background: a.grad }}
                    >
                      {a.initials}
                    </div>
                  ))}
                </div>
                <p className="text-sm text-white/60">
                  <strong className="text-white font-bold">{count ? `${count.toLocaleString()}+` : '12,400+'}</strong> freshers already holding their spot
                </p>
              </div>

              <div className="flex flex-wrap gap-2">
                {['✓ 100% Free', '✓ Works on 2G', '✓ Verified students'].map((t) => (
                  <span key={t} className="text-[11px] font-semibold text-white/60 bg-white/5 border border-white/10 px-3 py-1 rounded-full">
                    {t}
                  </span>
                ))}
              </div>
            </div>

            {/* Right: floating card stack */}
            <div className="relative h-[460px] hidden md:flex items-center justify-center" style={heroStyle(300, 'heroScaleIn', '600ms')}>
              {/* Campus photo background */}
              <div className="absolute inset-0 rounded-3xl overflow-hidden" style={{ zIndex: -1 }}>
                <img
                  src="https://commons.wikimedia.org/wiki/Special:FilePath/Legon_Tower.JPG?width=700"
                  alt="Ghana university campus aerial"
                  className="w-full h-full object-cover object-center"
                  style={{ filter: 'brightness(0.65)' }}
                />
                <div className="absolute inset-0" style={{ background: 'linear-gradient(135deg, rgba(0,102,255,0.20) 0%, rgba(0,0,0,0.08) 100%)' }} />
              </div>
              {/* Glow */}
              <div className="absolute w-72 h-72 rounded-full pointer-events-none"
                style={{ background: 'radial-gradient(circle, rgba(0,102,255,0.10) 0%, transparent 70%)', zIndex: 0 }} />

              {/* Card 1 — Hub Preview (top-left, -5°) */}
              <div style={{ position: 'absolute', top: '4%', left: '2%', transform: 'rotate(-5deg)', zIndex: 3 }}>
                <div style={{ animation: 'driftY 5s ease-in-out 0s infinite alternate',
                  background: '#162347', borderRadius: 16, width: 210,
                  boxShadow: '0 12px 40px rgba(0,102,255,0.14), 0 2px 8px rgba(0,0,0,0.06)',
                  border: '1px solid rgba(229,231,235,0.8)', padding: '16px 18px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                    <div style={{ fontSize: 10, fontWeight: 800, color: '#FF6B35', textTransform: 'uppercase', letterSpacing: '0.12em' }}>Your Hub</div>
                    <span style={{ width: 7, height: 7, borderRadius: '50%', background: '#22c55e', display: 'inline-block' }} />
                  </div>
                  <div style={{ fontSize: 14, fontWeight: 900, color: '#FFFFFE', marginBottom: 4 }}>KNUST Brunei Hub</div>
                  <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', marginBottom: 12 }}>420 freshers waiting</div>
                  <div style={{ background: '#FF6B35', color: 'white', fontWeight: 900, fontSize: 11, borderRadius: 50, padding: '6px 14px', textAlign: 'center' }}>
                    Join Hub →
                  </div>
                </div>
              </div>

              {/* Card 2 — Roommate Match (center-right, +3°) */}
              <div style={{ position: 'absolute', top: '30%', right: '0%', transform: 'rotate(3deg)', zIndex: 4 }}>
                <div style={{ animation: 'driftY 5s ease-in-out 1.7s infinite alternate',
                  background: '#162347', borderRadius: 16, width: 220,
                  boxShadow: '0 16px 48px rgba(0,0,0,0.10), 0 2px 8px rgba(0,0,0,0.05)',
                  border: '1px solid rgba(229,231,235,0.8)', padding: '16px 18px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 12 }}>
                    <div style={{ width: 20, height: 20, borderRadius: '50%', background: '#dcfce7', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <svg viewBox="0 0 12 12" width="10" height="10" fill="none"><path d="M2 6l3 3 5-5" stroke="#16a34a" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
                    </div>
                    <span style={{ fontSize: 11, fontWeight: 800, color: '#16a34a' }}>Roommate Found!</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
                    <div style={{ width: 36, height: 36, borderRadius: '50%', background: 'linear-gradient(135deg,#FF6B35,#6366f1)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 900, color: 'white', flexShrink: 0 }}>AK</div>
                    <div style={{ flex: 1, height: 2, background: 'linear-gradient(90deg,#FF6B35,#FF6B35)', borderRadius: 2 }} />
                    <div style={{ width: 36, height: 36, borderRadius: '50%', background: 'linear-gradient(135deg,#FF6B35,#dc2626)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 900, color: 'white', flexShrink: 0 }}>EB</div>
                  </div>
                  <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', textAlign: 'center' }}>Ama K. + Efua B. · Evandy Hostel</div>
                </div>
              </div>

              {/* Card 3 — Chat Bubble (bottom, -2°) */}
              <div style={{ position: 'absolute', bottom: '4%', left: '8%', transform: 'rotate(-2deg)', zIndex: 3 }}>
                <div style={{ animation: 'driftY 5s ease-in-out 0.9s infinite alternate',
                  background: '#162347', borderRadius: 16, width: 230,
                  boxShadow: '0 8px 32px rgba(0,0,0,0.08), 0 2px 6px rgba(0,0,0,0.04)',
                  border: '1px solid rgba(229,231,235,0.8)', padding: '14px 16px' }}>
                  <div style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
                    <div style={{ width: 28, height: 28, borderRadius: '50%', background: 'linear-gradient(135deg,#7c3aed,#6366f1)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 9, fontWeight: 900, color: 'white', flexShrink: 0 }}>YM</div>
                    <div style={{ background: '#F3F4F6', borderRadius: '12px 12px 12px 4px', padding: '7px 11px', fontSize: 11, color: '#374151', maxWidth: 160 }}>
                      Which hall is closer to SRC? 🏠
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end', marginBottom: 8 }}>
                    <div style={{ background: '#FF6B35', borderRadius: '12px 12px 4px 12px', padding: '7px 11px', fontSize: 11, color: 'white', maxWidth: 160 }}>
                      Evandy! And cheaper too ✓
                    </div>
                    <div style={{ width: 28, height: 28, borderRadius: '50%', background: 'linear-gradient(135deg,#059669,#0891b2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 9, fontWeight: 900, color: 'white', flexShrink: 0 }}>KA</div>
                  </div>
                  <div style={{ fontSize: 9, color: 'rgba(255,255,255,0.4)', textAlign: 'center', fontWeight: 600 }}>2 mutual classmates · KNUST Hub</div>
                </div>
              </div>

              {/* Decorative orange dot accent */}
              <div style={{ position: 'absolute', top: '22%', left: '42%', width: 10, height: 10, borderRadius: '50%', background: '#FF6B35', opacity: 0.5, zIndex: 2, animation: 'driftY 4s ease-in-out 0.4s infinite alternate' }} />
              <div style={{ position: 'absolute', bottom: '28%', right: '8%', width: 7, height: 7, borderRadius: '50%', background: '#FF6B35', opacity: 0.4, zIndex: 2, animation: 'driftY 3.5s ease-in-out 1.2s infinite alternate' }} />
            </div>
          </div>
        </section>

        {/* ── TICKER ──────────────────────────────────────────────────── */}
        <Ticker />

        {/* ── STATS BAR ───────────────────────────────────────────────── */}
        <div ref={statsRef} className="relative py-10 px-6 overflow-hidden border-t-4 border-[#FF6B35]" style={{ background: '#FF6B35' }}>
          {/* Subtle dot grid overlay */}
          <div className="absolute inset-0 pointer-events-none opacity-[0.08]"
            style={{ backgroundImage: 'radial-gradient(circle, white 1px, transparent 1px)', backgroundSize: '24px 24px' }} />
          <div className="max-w-5xl mx-auto grid grid-cols-3 md:grid-cols-6 gap-4 text-center divide-x divide-white/20">
            <StatItem num={180} suffix="+" label="Universities" trigger={statsVisible} />
            <StatItem num={12000} label="Freshers Waiting" is12K={true} trigger={statsVisible} />
            <StatItem num={847} suffix="" label="Roommates Matched" trigger={statsVisible} />
            <StatItem num={4.8} suffix="" label="Overall Rating" isDecimal={true} trigger={statsVisible} />
            <StatItem num={15000} label="WhatsApp Members" is12K={true} trigger={statsVisible} />
            <StatItem num={98} suffix="%" label="Would Recommend" trigger={statsVisible} />
          </div>
        </div>

        {/* ── FEATURES ────────────────────────────────────────────────── */}
        <section
          id="features"
          ref={featuresRef}
          className="relative py-16 md:py-28 px-6 border-t-2 border-[#FF6B35]/20"
          style={{ ...sectionRevealStyle(featuresVisible), background: 'linear-gradient(180deg, #0D1B3E 0%, #130F20 100%)' }}
        >
          {/* Ambient dots */}
          {[
            { size: 9,  top: '12%', right: '4%',  color: '#FF6B35', dur: '5s',   delay: '0.3s'  },
            { size: 6,  top: '60%', right: '2%',  color: '#FF6B35', dur: '4.2s', delay: '1.5s'  },
            { size: 11, top: '80%', left:  '3%',  color: '#FF6B35', dur: '5.8s', delay: '0.7s'  },
          ].map((d, i) => (
            <div key={i} className="absolute rounded-full pointer-events-none"
              style={{ width: d.size, height: d.size, top: d.top, left: d.left, right: d.right,
                background: d.color, opacity: 0.12,
                animation: `driftY ${d.dur} ease-in-out ${d.delay} infinite alternate` }} />
          ))}
          <div className="max-w-6xl mx-auto">
            <div className="grid md:grid-cols-2 gap-10 md:gap-16 items-start mb-14">
              <div>
                <div className="flex items-center gap-3 mb-4">
                  <BlueDoodle drawn={featuresVisible} />
                  <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#FF6B35]">Why UNIFY</span>
                </div>
                <SparkDoodle visible={featuresVisible} delay={200} />
                <h2 className="text-4xl md:text-5xl font-black text-white leading-tight mb-4">
                  That&apos;s The Way<br />To Fresher.
                </h2>
                <p className="text-white/60 text-base leading-relaxed max-w-sm">
                  Not a copy-paste Western social app. Every decision built around the real Ghanaian fresher experience.
                </p>
              </div>

              <div className="flex flex-col gap-4">
                {[
                  { icon: <Users2 className="w-5 h-5 text-[#FF6B35]" />, title: '180+ Campus Hubs', body: 'Official hubs for KNUST, UG Legon, UCC, UPSA and 180+ schools across Ghana.' },
                  { icon: <GraduationCap className="w-5 h-5 text-[#FF6B35]" />, title: 'Habit-Matched Roommates', body: 'Our matching engine pairs you with compatible freshers before orientation chaos starts.' },
                  { icon: <Building2 className="w-5 h-5 text-[#FF6B35]" />, title: 'Verified Students Only', body: 'Every profile is ID-verified. No fake accounts, no strangers — just real Ghana freshers.' },
                ].map((f, i) => (
                  <div
                    key={f.title}
                    className="feature-card bg-[#162347] border-2 border-[#FF6B35]/40 shadow-[4px_4px_0px_rgba(255,107,53,0.2)] rounded-none p-6 flex items-start gap-4"
                    style={featuresVisible ? { animation: `revealUp 600ms var(--ease-out-expo) ${i * 100}ms both` } : { opacity: 0 }}
                  >
                    <div className="w-11 h-11 rounded-2xl bg-[#FF6B35]/8 border border-[#FF6B35]/15 flex items-center justify-center flex-shrink-0">
                      {f.icon}
                    </div>
                    <div>
                      <h3 className="font-black text-white mb-1">{f.title}</h3>
                      <p className="text-sm text-white/60 leading-relaxed">{f.body}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Campus collage */}
            <CampusCollage animate={featuresVisible} />
          </div>
        </section>

        {/* ── SCHOOL SEARCH ────────────────────────────────────────────── */}
        <section id="schools" className="relative bg-[#0D1B3E] py-16 md:py-28 px-6 border-t-2 border-[#FF6B35]/20">
          <div className="absolute right-0 top-0 bottom-0 pointer-events-none overflow-hidden hidden lg:block" style={{ width: 120 }}>
            <svg viewBox="0 0 120 600" fill="none" className="h-full w-full opacity-20">
              <path d="M100,0 C20,80 120,160 40,240 C-20,300 120,380 60,460 C20,510 80,560 100,600"
                stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"
                style={{ strokeDasharray: 800, strokeDashoffset: 0 }}/>
            </svg>
          </div>
          <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-10 md:gap-16 items-center">
            <div className="hidden md:block h-80 rounded-3xl overflow-hidden">
              <SchoolLocatorViz animate={featuresVisible} />
            </div>
            <div className="relative">
              <BlueSwirl className="absolute -right-4 top-0" drawn={featuresVisible} />
              <SparkDoodle visible={featuresVisible} delay={300} />
              <h2 className="text-4xl md:text-5xl font-black text-white leading-tight mb-4">
                Find Your Campus,<br />Find Your People.
              </h2>
              <p className="text-white/60 text-base leading-relaxed mb-7">
                Browse 180+ Ghana universities. Pick your school and claim your handle before your classmates do.
              </p>
              <div className="flex items-center gap-2 bg-[#162347] border border-white/10 rounded-2xl p-2 pl-5 mb-5">
                <MapPin className="w-4 h-4 text-amber-400 shrink-0" />
                <select className="flex-1 bg-transparent text-white text-sm outline-none">
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
                  className="btn-cta-glow bg-[#FF6B35] text-white font-black text-sm px-5 py-2 rounded-full hover:bg-[#E55A22] transition-colors whitespace-nowrap shadow-[0_4px_14px_rgba(123,47,190,0.4)]"
                >
                  Find Hub →
                </a>
              </div>
              <div className="flex flex-wrap gap-3">
                <a href="/hubs" className="inline-flex items-center gap-1.5 text-sm font-semibold text-white/60 hover:text-white px-4 py-2 rounded-full border border-white/10 bg-white/5 hover:border-[#FF6B35]/40 hover:text-purple-300 transition-all footer-link">
                  Browse all hubs <ArrowRight className="w-3.5 h-3.5" />
                </a>
                <a href="/match" className="inline-flex items-center gap-1.5 text-sm font-semibold text-white/60 hover:text-white px-4 py-2 rounded-full border border-white/10 bg-white/5 hover:border-[#FF6B35]/40 hover:text-purple-300 transition-all footer-link">
                  Find a roommate <ArrowRight className="w-3.5 h-3.5" />
                </a>
              </div>
            </div>
          </div>
        </section>

        {/* ── COMMUNITY ────────────────────────────────────────────────── */}
        <section
          ref={communityRef}
          className="relative py-16 md:py-28 px-6 border-t-2 border-[#FF6B35]/20"
          style={{ ...sectionRevealStyle(communityVisible), background: '#0D1B3E' }}
        >
          {/* Ambient dots */}
          {[
            { size: 8,  top: '10%', left:  '5%',  color: '#FF6B35', dur: '4.5s', delay: '0s'   },
            { size: 10, top: '70%', right: '3%',  color: '#FF6B35', dur: '5.2s', delay: '1.1s' },
            { size: 7,  top: '40%', right: '6%',  color: '#FF6B35', dur: '3.8s', delay: '0.6s' },
          ].map((d, i) => (
            <div key={i} className="absolute rounded-full pointer-events-none"
              style={{ width: d.size, height: d.size, top: d.top, left: d.left, right: d.right,
                background: d.color, opacity: 0.12,
                animation: `driftY ${d.dur} ease-in-out ${d.delay} infinite alternate` }} />
          ))}
          <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-10 md:gap-16 items-center">
            <div>
              <div className="flex items-center gap-3 mb-4">
                <OrangeDoodle drawn={communityVisible} />
                <Sparkles className="w-5 h-5 text-[#FF6B35]" />
              </div>
              <SparkDoodle visible={communityVisible} delay={200} />
              <h2 className="text-4xl md:text-5xl font-black text-white leading-tight mb-4">
                Your Campus Fam<br />Is Calling.
                <br />
                <span className="text-white/60 text-3xl md:text-4xl font-bold">Don&apos;t Miss Orientation.</span>
              </h2>
              <p className="text-white/60 text-base leading-relaxed mb-8">
                Join the official WhatsApp community for your school. Real freshers, real intel, zero spam.
              </p>
              <a
                href="https://wa.me/233000000000?text=Hi%20UNIFY!%20I'm%20a%20fresher%20interested%20in%20joining%20my%20campus%20hub."
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => track('whatsapp_click', { type: 'join' })}
                className="btn-cta-glow inline-flex items-center gap-2 bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-sm px-7 py-3.5 rounded-full shadow-[0_4px_14px_rgba(123,47,190,0.4)]"
              >
                <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                </svg>
                Join Community →
              </a>
            </div>

            <div className="relative h-72 flex items-center justify-center rounded-3xl overflow-hidden">
              {/* Campus background photo */}
              <img
                src="https://commons.wikimedia.org/wiki/Special:FilePath/Athletics_Oval_at_University_of_Ghana,_Legon.jpg?width=600"
                alt="campus life"
                className="absolute inset-0 w-full h-full object-cover object-center opacity-20"
              />
              {AVATARS.map((a) => (
                <div
                  key={a.initials}
                  className={`absolute w-12 h-12 rounded-full ${a.bg} border-2 border-white/60 flex items-center justify-center text-xs font-black ${a.text} shadow-sm`}
                  style={{
                    top: a.top, left: a.left,
                    animation: communityVisible
                      ? `avatarPop 400ms var(--ease-spring) ${a.order * 80}ms both, breathe 4s ease-in-out ${a.order * 300}ms infinite`
                      : 'none',
                    opacity: communityVisible ? undefined : 0,
                  }}
                >
                  {a.initials}
                </div>
              ))}
              <div
                className="absolute top-2 right-0 bg-[#162347]/90 backdrop-blur-sm border border-white/10 rounded-2xl rounded-tl-sm px-3 py-1.5 text-xs font-semibold text-white shadow-sm"
                style={{
                  animation: communityVisible ? 'bubblePop 300ms var(--ease-spring) 400ms both' : 'none',
                  opacity: communityVisible ? undefined : 0,
                }}
              >
                Already linked! 🔥
              </div>
              <div className="absolute bottom-8 right-4 bg-[#A8C4FF]/8 border border-[#A8C4FF]/20 rounded-2xl rounded-br-sm px-3 py-1.5 text-xs font-semibold text-[#A8C4FF] shadow-sm"
                style={{
                  animation: communityVisible ? 'bubblePop 300ms var(--ease-spring) 560ms both' : 'none',
                  opacity: communityVisible ? undefined : 0,
                }}
              >
                Found my roomie!
              </div>
              <div className="absolute bottom-2 left-0 bg-[#162347]/90 backdrop-blur-sm border border-white/10 rounded-2xl rounded-bl-sm px-3 py-1.5 text-xs font-semibold text-white shadow-sm"
                style={{
                  animation: communityVisible ? 'bubblePop 300ms var(--ease-spring) 720ms both' : 'none',
                  opacity: communityVisible ? undefined : 0,
                }}
              >
                Best app fr 🇬🇭
              </div>
              <div className="absolute top-1/2 right-0 -translate-y-1/2 flex flex-col gap-2">
                {['W', 'IG', 'X'].map((s) => (
                  <div key={s} className="social-icon w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-[9px] font-black text-white/50">
                    {s}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* ── TESTIMONIALS ─────────────────────────────────────────────── */}
        <section
          ref={testimonialsRef}
          className="relative bg-[#0D1B3E] py-16 md:py-28 px-6 border-t-2 border-[#FF6B35]/20 overflow-hidden"
          style={sectionRevealStyle(testimonialsVisible)}
        >
          {/* Subtle campus photo strip on the right */}
          <div className="absolute top-0 right-0 bottom-0 w-[280px] hidden xl:block pointer-events-none">
            <img
              src="https://commons.wikimedia.org/wiki/Special:FilePath/College_of_Engineering,_KNUST,_Kumasi,_Ghana.JPG?width=400"
              alt="Accra skyline"
              className="w-full h-full object-cover object-center opacity-[0.12]"
            />
            <div className="absolute inset-0" style={{ background: 'linear-gradient(to right, #0D1B3E 0%, transparent 40%)' }} />
          </div>
          <div className="max-w-6xl mx-auto">
            <div className="flex items-center justify-between mb-10">
              <div>
                <div className="flex items-center gap-3 mb-2">
                  <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#A8C4FF]">Reviews</span>
                  <Star className="w-4 h-4 text-[#A8C4FF]" />
                </div>
                <SparkDoodle visible={testimonialsVisible} delay={200} />
                <h2 className="text-4xl md:text-5xl font-black text-white">
                  Satisfied Freshers Are<br />Our Best Ads.
                </h2>
              </div>
              <div className="hidden md:flex items-center gap-2">
                <button
                  aria-label="Previous testimonial"
                  onClick={() => { prevTestimonial(); track('carousel_nav', { direction: 'prev' }); }}
                  className="w-10 h-10 rounded-full border border-white/10 bg-white/5 hover:border-[#FF6B35]/50 hover:text-purple-300 flex items-center justify-center text-white/60 transition-all duration-200 hover:scale-110 active:scale-95"
                >←</button>
                <button
                  aria-label="Next testimonial"
                  onClick={() => { nextTestimonial(); track('carousel_nav', { direction: 'next' }); }}
                  className="w-10 h-10 rounded-full border border-white/10 bg-white/5 hover:border-[#FF6B35]/50 hover:text-purple-300 flex items-center justify-center text-white/60 transition-all duration-200 hover:scale-110 active:scale-95"
                >→</button>
              </div>
            </div>

            {/* Sliding carousel — all 3 cards in DOM, translateX to show active */}
            <div className="relative overflow-hidden rounded-3xl">
              <div
                className="flex"
                style={{
                  transform: `translateX(-${activeTestimonial * 100}%)`,
                  transition: 'transform 500ms cubic-bezier(0.16,1,0.3,1)',
                }}
              >
                {TESTIMONIALS.map((t) => (
                  <div key={t.name} className="w-full flex-shrink-0 px-1 md:px-3">
                    <div className="relative overflow-hidden bg-[#162347] border-2 border-[#FF6B35]/30 shadow-[4px_4px_0px_rgba(255,107,53,0.15)] rounded-none p-8 md:p-10 flex flex-col min-h-[220px]">
                      {/* Watermark quote */}
                      <div className="absolute top-4 right-6 text-[96px] font-black leading-none pointer-events-none select-none"
                           style={{ color: '#FF6B35', opacity: 0.12 }}>&rdquo;</div>
                      {/* Visible small quote */}
                      <div className="text-5xl font-black text-amber-400 leading-none mb-4">&ldquo;</div>
                      <p className="text-white/60 text-base leading-relaxed flex-1 mb-8">{t.quote}</p>
                      <div className="border-t border-white/10 pt-5 flex items-center gap-3">
                        <div className="w-11 h-11 rounded-full bg-[#FF6B35]/10 border border-[#FF6B35]/20 flex items-center justify-center text-sm font-black text-[#FF6B35] flex-shrink-0">{t.initials}</div>
                        <div className="flex-1">
                          <p className="font-bold text-white text-sm">{t.name}</p>
                          <p className="text-white/40 text-xs">{t.role}</p>
                        </div>
                        <div className="flex items-center gap-0.5">
                          {[1,2,3,4,5].map(s => (
                            <svg key={s} viewBox="0 0 12 12" className="w-3.5 h-3.5" fill={s <= t.stars ? '#FF6B35' : '#E5E7EB'}>
                              <path d="M6 0.5l1.545 3.13 3.455.502-2.5 2.437.59 3.441L6 8.385 2.91 10.01l.59-3.441L1 4.132l3.455-.502z"/>
                            </svg>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Dot indicators + mobile arrows */}
            <div className="md:hidden mt-6 flex items-center justify-center gap-3">
              <button aria-label="Previous testimonial" onClick={() => { prevTestimonial(); track('carousel_nav', { direction: 'prev' }); }} className="w-10 h-10 rounded-full border border-white/10 bg-white/5 flex items-center justify-center text-white/60 hover:border-[#FF6B35]/50 hover:text-purple-300 transition-all">←</button>
              {TESTIMONIALS.map((_, i) => (
                <button key={i} onClick={() => setActiveTestimonial(i)} className={`h-2 rounded-full transition-all duration-300 ${i === activeTestimonial ? 'bg-[#FF6B35] w-6' : 'bg-[#E5E7EB] w-2'}`} />
              ))}
              <button aria-label="Next testimonial" onClick={() => { nextTestimonial(); track('carousel_nav', { direction: 'next' }); }} className="w-10 h-10 rounded-full border border-white/10 bg-white/5 flex items-center justify-center text-white/60 hover:border-[#FF6B35]/50 hover:text-purple-300 transition-all">→</button>
            </div>
            <div className="hidden md:flex mt-6 items-center justify-center gap-2">
              {TESTIMONIALS.map((_, i) => (
                <button key={i} onClick={() => setActiveTestimonial(i)} className={`h-2 rounded-full transition-all duration-300 ${i === activeTestimonial ? 'bg-[#FF6B35] w-6' : 'bg-[#E5E7EB] w-2'}`} />
              ))}
            </div>
          </div>
        </section>

        {/* ── WAITLIST CTA ─────────────────────────────────────────────── */}
        <section
          id="waitlist"
          ref={ctaRef}
          className="py-16 md:py-28 px-6 border-t-2 border-[#FF6B35]/20"
          style={{ ...sectionRevealStyle(ctaVisible), background: '#0D1B3E' }}
        >
          <div className="max-w-2xl mx-auto text-center">
            <span className="text-5xl block mb-6">🇬🇭</span>
            <div className="inline-flex items-center gap-2 bg-[#A8C4FF]/10 border border-[#A8C4FF]/30 text-[#A8C4FF] text-xs font-bold px-4 py-2 rounded-full mb-7">
              <CheckCircle className="w-3.5 h-3.5" strokeWidth={2} />
              100% free · No subscriptions · Ever
            </div>
            <h2 className="text-4xl md:text-5xl font-black text-white tracking-tight mb-5 leading-tight">
              Stop hunting for broken<br />
              <span className="text-[#A8C4FF]">WhatsApp group links.</span>
            </h2>
            <p className="text-white/60 text-lg mb-10 max-w-md mx-auto leading-relaxed">
              Secure your spot in the official Class of &apos;30 network today. Your campus people are already inside.
            </p>
            <WaitlistForm id="cta-form" defaultSchool={schoolId || ''} />
            <p className="text-xs text-white/40 mt-5">🔒 Free forever · No spam · Built by Ghanaians in Ghana</p>
          </div>
        </section>

        {/* ── FAQ + CONTACT ─────────────────────────────────────────────── */}
        <section
          id="faq"
          ref={faqRef}
          className="relative bg-[#0D1B3E] py-16 md:py-28 px-6 border-t-2 border-[#FF6B35]/20"
          style={sectionRevealStyle(faqVisible)}
        >
          <div className="absolute left-0 top-0 bottom-0 pointer-events-none overflow-hidden hidden lg:block" style={{ width: 80 }}>
            <svg viewBox="0 0 80 600" fill="none" className="h-full w-full opacity-20">
              <path d="M20,0 C80,80 -10,180 60,280 C100,340 10,420 50,520 C70,570 30,590 20,600"
                stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
            </svg>
          </div>
          <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-10 md:gap-16 items-start">
            <div className="relative">
              <BlueSwirl className="absolute -left-4 -top-4" drawn={faqVisible} />
              <div className="flex items-center gap-3 mb-4">
                <OrangeDoodle drawn={faqVisible} />
                <MessageCircle className="w-5 h-5 text-[#A8C4FF]" />
                <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#A8C4FF]">Get in touch</span>
              </div>
              <SparkDoodle visible={faqVisible} delay={200} />
              <h2 className="text-4xl md:text-5xl font-black text-white leading-tight mb-4">
                Got A Question<br />For UNIFY?
              </h2>
              <p className="text-white/60 text-base leading-relaxed mb-7">
                We&apos;ll answer everything. Drop your number and we&apos;ll reach out.
              </p>
              {faqDone ? (
                <div className="flex items-center gap-3 bg-[#A8C4FF]/10 border border-[#A8C4FF]/30 rounded-full px-5 py-4">
                  <CheckCircle className="text-[#A8C4FF] w-5 h-5 flex-shrink-0" />
                  <p className="text-[#A8C4FF] font-bold text-sm">Got it! We&apos;ll reach out soon. 🎉</p>
                </div>
              ) : (
                <form onSubmit={handleFaqSubmit} className="flex items-center bg-[#162347] border border-white/10 rounded-full overflow-hidden pr-1.5 focus-within:border-[#FF6B35]/60">
                  <input
                    type="text"
                    value={faqPhone}
                    onChange={(e) => setFaqPhone(e.target.value)}
                    placeholder="Your phone number..."
                    required
                    className="flex-1 bg-transparent px-5 py-3.5 text-sm text-white placeholder-white/30 outline-none"
                  />
                  <button
                    type="submit"
                    disabled={faqLoading}
                    className="bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-sm px-5 py-2.5 rounded-full transition-colors disabled:opacity-60 whitespace-nowrap shadow-[0_4px_14px_rgba(123,47,190,0.4)]"
                  >
                    {faqLoading ? '...' : 'Submit'}
                  </button>
                </form>
              )}
            </div>

            <div>
              <p className="text-sm text-white/60 mb-4">Check if your question is already answered:</p>
              <FAQAccordion items={FAQS_NEW} visible={faqVisible} />
            </div>
          </div>
        </section>

        {/* ── FOOTER ──────────────────────────────────────────────────── */}
        <footer className="bg-[#FF6B35] px-6 pt-14 pb-8">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-2 md:grid-cols-5 gap-8 pb-10 border-b border-white/20">

              {/* Col 1 — Brand */}
              <div className="col-span-2 md:col-span-1">
                <div className="flex items-center gap-2 mb-4">
                  <span className="text-2xl font-black text-white tracking-tight">UNIFY</span>
                  <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-white/15 border border-white/25 text-white">GH</span>
                </div>
                <p className="text-sm text-white/70 leading-relaxed max-w-[200px]">
                  We always make our customer happy by providing as many choices as possible.
                </p>
              </div>

              {/* Col 2 — Company */}
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Company</p>
                <div className="flex flex-col gap-2.5">
                  {[
                    { label: 'About Us', href: '#' },
                    { label: 'Features', href: '#features' },
                    { label: 'Blog', href: '/blog' },
                    { label: 'FAQ', href: '#faq' },
                  ].map((l) => (
                    <a key={l.label} href={l.href} className="footer-link text-sm text-white/80 hover:text-white">{l.label}</a>
                  ))}
                </div>
              </div>

              {/* Col 3 — Resources */}
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Resources</p>
                <div className="flex flex-col gap-2.5">
                  {['Events', 'Promo', 'Req Demo'].map((l) => (
                    <a key={l} href="#" className="footer-link text-sm text-white/80 hover:text-white">{l}</a>
                  ))}
                </div>
              </div>

              {/* Col 4 — Support */}
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Support</p>
                <div className="flex flex-col gap-2.5">
                  {['Account', 'Support Center', 'Feedback', 'Contact Us', 'Accessibility'].map((l) => (
                    <a key={l} href="#" className="footer-link text-sm text-white/80 hover:text-white">{l}</a>
                  ))}
                </div>
              </div>

              {/* Col 5 — Contact */}
              <div>
                <p className="text-[11px] font-bold uppercase tracking-wider text-white mb-4">Contact Info</p>
                <a href="mailto:unify@email.com" className="footer-link text-sm text-white/80 hover:text-white block mb-5">unify@email.com</a>
                <div className="flex gap-2">
                  {/* Instagram */}
                  <a href="#" className="social-icon w-9 h-9 rounded-full bg-white/15 border border-white/25 flex items-center justify-center hover:bg-white/30" aria-label="Instagram">
                    <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white">
                      <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/>
                    </svg>
                  </a>
                  {/* Facebook */}
                  <a href="#" className="social-icon w-9 h-9 rounded-full bg-white/15 border border-white/25 flex items-center justify-center hover:bg-white/30" aria-label="Facebook">
                    <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white">
                      <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                    </svg>
                  </a>
                  {/* Twitter/X */}
                  <a href="#" className="social-icon w-9 h-9 rounded-full bg-white/15 border border-white/25 flex items-center justify-center hover:bg-white/30" aria-label="Twitter">
                    <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white">
                      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                    </svg>
                  </a>
                </div>
              </div>

            </div>

            {/* Bottom bar */}
            <div className="pt-6 text-center">
              <p className="text-xs text-white/60">Copyright © 2026 UNIFY. All right reserved.</p>
            </div>
            <div className="mt-5 h-[3px] rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
          </div>
        </footer>

      </div>{/* end browser wrapper */}

      <StickyBar />
      <ExitModal />
    </div>
  );
}
