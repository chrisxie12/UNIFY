'use client';

import { useState, useEffect } from 'react';
import { Mail, Lock, Eye, EyeOff } from 'lucide-react';

// ── Decorative SVGs ─────────────────────────────────────────────────────────

function OrangeScribble({ width = 76 }) {
  return (
    <svg width={width} height="10" viewBox={`0 0 ${width} 10`} fill="none" aria-hidden="true" className="block mx-auto mt-1">
      <path
        d={`M2,6 C${width*.12},2 ${width*.25},9 ${width*.38},5 C${width*.5},1 ${width*.63},9 ${width*.75},5 C${width*.87},1 ${width*.94},7 ${width-2},5`}
        stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" fill="none"
        style={{ strokeDasharray: width * 1.4, strokeDashoffset: 0, animation: 'scribbleDraw 500ms cubic-bezier(0.16,1,0.3,1) 400ms both' }}
      />
    </svg>
  );
}

function ButtonScribble() {
  return (
    <svg width="48" height="7" viewBox="0 0 48 7" fill="none" aria-hidden="true" className="block mx-auto mt-0.5">
      <path d="M2,4.5 C6.5,1 12,7 18,4 C24,1 30,7 36,4 C41,1 45,5.5 46,4"
        stroke="#FF6B35" strokeWidth="1.8" strokeLinecap="round" fill="none" />
    </svg>
  );
}

function BlueSwirl() {
  return (
    <svg width="100" height="130" viewBox="0 0 120 160" fill="none" aria-hidden="true"
      className="absolute bottom-0 right-0 opacity-30 pointer-events-none">
      <path d="M100,10 C140,40 60,70 90,100 C120,130 40,145 70,155"
        stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round" fill="none"
        style={{ strokeDasharray: 300, strokeDashoffset: 0, animation: 'swirlDraw 900ms ease-out 800ms both' }} />
      <path d="M80,20 C110,50 50,75 80,100 C105,120 55,140 75,155"
        stroke="#0066FF" strokeWidth="1" strokeLinecap="round" fill="none" opacity="0.5"
        style={{ strokeDasharray: 260, strokeDashoffset: 0, animation: 'swirlDraw 900ms ease-out 1000ms both' }} />
    </svg>
  );
}

// ── Campus card artwork — rich gradient tiles mimicking photographs ───────────

const CAMPUS_CARDS = [
  {
    school: 'KNUST',
    location: 'Kumasi',
    initials: 'KN',
    tagline: 'Great Hall · Est. 1952',
    // deep forest green with warm amber highlight — evokes KNUST's lush campus
    bg: 'linear-gradient(155deg, #0a2e0a 0%, #1a4a10 35%, #2d6e1e 65%, #1a3d0a 100%)',
    accent: 'rgba(255,200,50,0.18)',
    accentPos: '75% 20%',
    stripe: '#FFD700',
    rotation: '-18deg',
    delay: '0ms',
    zIndex: 1,
    float: '5.2s',
  },
  {
    school: 'UG Legon',
    location: 'Accra',
    initials: 'UG',
    tagline: 'Balme Library · Est. 1948',
    // deep navy with warm gold wash — classic Legon colours
    bg: 'linear-gradient(155deg, #020b1f 0%, #05194a 40%, #0a2f72 70%, #031230 100%)',
    accent: 'rgba(192,160,0,0.20)',
    accentPos: '25% 30%',
    stripe: '#C0A000',
    rotation: '-6deg',
    delay: '150ms',
    zIndex: 3,
    float: '6.8s',
  },
  {
    school: 'UCC',
    location: 'Cape Coast',
    initials: 'UC',
    tagline: 'Main Campus · Est. 1962',
    // rich burgundy with golden haze
    bg: 'linear-gradient(155deg, #1a0000 0%, #4a0606 35%, #7a0a0a 65%, #3a0303 100%)',
    accent: 'rgba(255,200,60,0.16)',
    accentPos: '60% 70%',
    stripe: '#FFD700',
    rotation: '6deg',
    delay: '300ms',
    zIndex: 2,
    float: '4.7s',
  },
  {
    school: 'UPSA',
    location: 'Accra',
    initials: 'UP',
    tagline: 'Modern Campus · Est. 1965',
    // deep indigo with crimson warmth
    bg: 'linear-gradient(155deg, #03031a 0%, #0d0d4a 40%, #1a1a72 65%, #06062a 100%)',
    accent: 'rgba(204,40,40,0.20)',
    accentPos: '80% 60%',
    stripe: '#CC2222',
    rotation: '18deg',
    delay: '450ms',
    zIndex: 1,
    float: '7.4s',
  },
];

function CampusCard({ card, index, scrollY }) {
  const parallax = [0.04, 0.07, 0.055, 0.09][index];
  const py = -(scrollY * parallax);

  return (
    <div
      style={{
        position: 'absolute',
        bottom: '8%',
        left: '50%',
        transformOrigin: '50% 100%',
        transform: `translateX(-50%) translateY(${py}px) rotate(${card.rotation})`,
        zIndex: card.zIndex,
        width: 280,
        borderRadius: 20,
        background: '#fff',
        padding: '10px 10px 38px',
        boxShadow: '0 32px 64px -8px rgba(0,0,0,0.30), 0 8px 24px rgba(0,0,0,0.15)',
        animation: `cardEntrance${index} 700ms cubic-bezier(0.16,1,0.3,1) ${card.delay} both`,
        willChange: 'transform',
      }}
    >
      {/* Photo area */}
      <div style={{
        width: '100%',
        height: 210,
        borderRadius: 12,
        background: card.bg,
        position: 'relative',
        overflow: 'hidden',
      }}>
        {/* Light orb */}
        <div style={{
          position: 'absolute',
          width: 200, height: 200,
          borderRadius: '50%',
          background: `radial-gradient(circle, ${card.accent} 0%, transparent 70%)`,
          top: card.accentPos.split(' ')[1],
          left: card.accentPos.split(' ')[0],
          transform: 'translate(-50%, -50%)',
          pointerEvents: 'none',
        }} />
        {/* Architectural grid overlay — columns/windows */}
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.08 }} preserveAspectRatio="none">
          {[0.15, 0.33, 0.51, 0.69, 0.87].map(x => (
            <line key={x} x1={`${x*100}%`} y1="0" x2={`${x*100}%`} y2="100%" stroke="white" strokeWidth="1" />
          ))}
          {[0.25, 0.5, 0.75].map(y => (
            <line key={y} x1="0" y1={`${y*100}%`} x2="100%" y2={`${y*100}%`} stroke="white" strokeWidth="0.8" />
          ))}
        </svg>
        {/* Film grain */}
        <div style={{
          position: 'absolute', inset: 0,
          backgroundImage: 'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'200\' height=\'200\'%3E%3Cfilter id=\'n\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'0.75\' numOctaves=\'4\' stitchTiles=\'stitch\'/%3E%3C/filter%3E%3Crect width=\'200\' height=\'200\' filter=\'url(%23n)\' opacity=\'0.04\'/%3E%3C/svg%3E")',
          opacity: 0.4,
          pointerEvents: 'none',
        }} />
        {/* Top badge */}
        <div style={{
          position: 'absolute', top: 12, left: 12,
          background: 'rgba(255,255,255,0.12)',
          border: '1px solid rgba(255,255,255,0.22)',
          borderRadius: 9999,
          padding: '3px 10px',
        }}>
          <span style={{ color: 'rgba(255,255,255,0.9)', fontSize: 10, fontWeight: 700, letterSpacing: 1 }}>
            {card.school.toUpperCase()}
          </span>
        </div>
        {/* Large initials watermark */}
        <span style={{
          position: 'absolute', bottom: -12, right: 8,
          fontSize: 100, fontWeight: 900,
          color: 'rgba(255,255,255,0.06)',
          lineHeight: 1, letterSpacing: -6,
          userSelect: 'none',
          fontFamily: 'system-ui, sans-serif',
        }}>{card.initials}</span>
        {/* Bottom gradient overlay + location */}
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0,
          height: 70,
          background: 'linear-gradient(to top, rgba(0,0,0,0.55) 0%, transparent 100%)',
          display: 'flex', alignItems: 'flex-end',
          padding: '0 12px 10px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <div style={{ width: 6, height: 6, borderRadius: '50%', background: card.stripe, flexShrink: 0 }} />
            <span style={{ color: 'rgba(255,255,255,0.85)', fontSize: 11, fontWeight: 600 }}>{card.location}</span>
          </div>
        </div>
      </div>
      {/* Polaroid caption */}
      <div style={{ paddingTop: 10, textAlign: 'center' }}>
        <p style={{ margin: 0, fontSize: 12, fontWeight: 700, color: '#111827', fontFamily: 'system-ui, sans-serif' }}>
          {card.school}
        </p>
        <p style={{ margin: '2px 0 0', fontSize: 10, color: '#9CA3AF', fontFamily: 'system-ui, sans-serif' }}>
          {card.tagline}
        </p>
      </div>
      {/* Accent stripe at bottom */}
      <div style={{
        position: 'absolute', bottom: 0, left: '15%', right: '15%', height: 3,
        background: card.stripe, borderRadius: '0 0 4px 4px', opacity: 0.6,
      }} />
    </div>
  );
}

function CollageSection({ scrollY, mounted }) {
  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {/* Behind-frame swirl */}
      <svg width="500" height="500" viewBox="0 0 500 500" fill="none" aria-hidden="true"
        style={{ position: 'absolute', top: '5%', left: '5%', opacity: 0.12, pointerEvents: 'none' }}>
        <path d="M400,30 C480,130 280,230 360,330 C440,430 220,460 300,490"
          stroke="#0066FF" strokeWidth="2.5" strokeLinecap="round" fill="none"
          style={{ strokeDasharray: 900, strokeDashoffset: 0, animation: 'swirlDraw 1400ms ease-out 100ms both' }} />
        <path d="M350,50 C430,140 250,230 330,320 C410,410 210,450 290,480"
          stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round" fill="none" opacity="0.6"
          style={{ strokeDasharray: 800, strokeDashoffset: 0, animation: 'swirlDraw 1400ms ease-out 300ms both' }} />
      </svg>

      {/* Orange accent blob top-right */}
      <div style={{
        position: 'absolute', top: '10%', right: '12%',
        width: 80, height: 80, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(255,107,53,0.15) 0%, transparent 70%)',
        animation: 'fadeIn 800ms ease 600ms both',
      }} />

      {/* Blue accent blob bottom-left */}
      <div style={{
        position: 'absolute', bottom: '15%', left: '8%',
        width: 100, height: 100, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(0,102,255,0.12) 0%, transparent 70%)',
      }} />

      {/* Spark cluster — top left */}
      <div style={{ position: 'absolute', top: '12%', left: '10%', animation: 'sparkPop 400ms cubic-bezier(0.34,1.56,0.64,1) 500ms both' }}>
        <svg width="36" height="36" viewBox="0 0 32 32" fill="none">
          <line x1="16" y1="2"  x2="16" y2="10" stroke="#0066FF" strokeWidth="2.5" strokeLinecap="round"/>
          <line x1="24" y1="8"  x2="20" y2="12" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
          <line x1="28" y1="16" x2="22" y2="16" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
          <line x1="8"  y1="8"  x2="12" y2="12" stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="4"  y1="16" x2="10" y2="16" stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{ position: 'absolute', top: '22%', left: '18%', animation: 'sparkPop 400ms cubic-bezier(0.34,1.56,0.64,1) 700ms both' }}>
        <svg width="22" height="22" viewBox="0 0 32 32" fill="none">
          <line x1="16" y1="4"  x2="16" y2="11" stroke="#0066FF" strokeWidth="2" strokeLinecap="round"/>
          <line x1="23" y1="9"  x2="20" y2="13" stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="26" y1="16" x2="21" y2="16" stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round"/>
        </svg>
      </div>

      {/* Orange radiates — bottom right */}
      <div style={{ position: 'absolute', bottom: '18%', right: '14%', animation: 'sparkPop 400ms cubic-bezier(0.34,1.56,0.64,1) 900ms both' }}>
        <svg width="34" height="34" viewBox="0 0 28 28" fill="none">
          <line x1="14" y1="1"  x2="14" y2="9"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
          <line x1="25" y1="5"  x2="20" y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
          <line x1="4"  y1="5"  x2="9"  y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
          <line x1="27" y1="14" x2="19" y2="14" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="1"  y1="14" x2="9"  y2="14" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="25" y1="23" x2="20" y2="18" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="4"  y1="23" x2="9"  y2="18" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{ position: 'absolute', bottom: '28%', right: '22%', animation: 'sparkPop 400ms cubic-bezier(0.34,1.56,0.64,1) 1100ms both' }}>
        <svg width="20" height="20" viewBox="0 0 28 28" fill="none">
          <line x1="14" y1="2"  x2="14" y2="8"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
          <line x1="23" y1="6"  x2="19" y2="10" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="5"  y1="6"  x2="9"  y2="10" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
        </svg>
      </div>

      {/* Cards rendered BELOW the decorative dots in z-order but above the blobs */}
      {mounted && CAMPUS_CARDS.map((card, i) => (
        <CampusCard key={card.school} card={card} index={i} scrollY={scrollY} />
      ))}

      {/* Tagline */}
      <div style={{
        position: 'absolute', top: 36, left: 0, right: 0,
        textAlign: 'center', animation: 'fadeIn 700ms ease 600ms both',
      }}>
        <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 8,
          background: 'rgba(255,255,255,0.55)', backdropFilter: 'blur(12px)',
          border: '1px solid rgba(255,255,255,0.7)',
          borderRadius: 9999, padding: '6px 16px',
          fontSize: 12, fontWeight: 700, color: '#374151',
          fontFamily: 'system-ui, sans-serif',
        }}>
          🇬🇭 Ghana University Network
        </span>
      </div>
    </div>
  );
}

// ── Main ─────────────────────────────────────────────────────────────────────

export default function LoginPage() {
  const [mode, setMode] = useState('signup');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [scrollY, setScrollY] = useState(0);

  useEffect(() => {
    setMounted(true);
    const onScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const isSignup = mode === 'signup';

  function validateEmail(v) {
    if (!v || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) return 'Please enter a valid email address.';
    return '';
  }
  function validatePassword(v) {
    if (!v) return isSignup ? 'Password must be at least 8 characters.' : 'Please enter your password.';
    if (isSignup && v.length < 8) return 'Password must be at least 8 characters.';
    return '';
  }
  async function handleSubmit(e) {
    e?.preventDefault();
    const eErr = validateEmail(email);
    const pErr = validatePassword(password);
    setEmailError(eErr); setPasswordError(pErr);
    if (eErr || pErr) return;
    setLoading(true);
    await new Promise(r => setTimeout(r, 1200));
    setLoading(false); setDone(true);
  }
  function switchMode(m) {
    setMode(m); setEmailError(''); setPasswordError(''); setDone(false);
  }

  return (
    <>
      <style>{`
        @keyframes scribbleDraw {
          from { stroke-dashoffset: 200; opacity: 0; }
          to   { stroke-dashoffset: 0; opacity: 1; }
        }
        @keyframes swirlDraw {
          from { stroke-dashoffset: 900; opacity: 0; }
          to   { stroke-dashoffset: 0; opacity: 1; }
        }
        @keyframes sparkPop {
          from { opacity: 0; transform: scale(0) rotate(-20deg); }
          to   { opacity: 1; transform: scale(1) rotate(0deg); }
        }
        @keyframes fadeIn {
          from { opacity: 0; }
          to   { opacity: 1; }
        }
        @keyframes slideInRight {
          from { opacity: 0; transform: translateX(36px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes cardEntrance0 {
          from { opacity: 0; transform: translateX(-50%) rotate(-26deg) scale(0.85); }
          to   { opacity: 1; transform: translateX(-50%) rotate(-18deg) scale(1); }
        }
        @keyframes cardEntrance1 {
          from { opacity: 0; transform: translateX(-50%) translateY(30px) rotate(-10deg) scale(0.88); }
          to   { opacity: 1; transform: translateX(-50%) rotate(-6deg) scale(1); }
        }
        @keyframes cardEntrance2 {
          from { opacity: 0; transform: translateX(-50%) translateY(30px) rotate(10deg) scale(0.88); }
          to   { opacity: 1; transform: translateX(-50%) rotate(6deg) scale(1); }
        }
        @keyframes cardEntrance3 {
          from { opacity: 0; transform: translateX(-50%) rotate(26deg) scale(0.85); }
          to   { opacity: 1; transform: translateX(-50%) rotate(18deg) scale(1); }
        }
        @keyframes float0 {
          0%,100% { transform: translateX(-50%) translateY(0px) rotate(-18deg); }
          50%     { transform: translateX(-50%) translateY(-10px) rotate(-17deg); }
        }
        @keyframes float1 {
          0%,100% { transform: translateX(-50%) translateY(0px) rotate(-6deg); }
          50%     { transform: translateX(-50%) translateY(-12px) rotate(-5deg); }
        }
        @keyframes float2 {
          0%,100% { transform: translateX(-50%) translateY(0px) rotate(6deg); }
          50%     { transform: translateX(-50%) translateY(-9px) rotate(7deg); }
        }
        @keyframes float3 {
          0%,100% { transform: translateX(-50%) translateY(0px) rotate(18deg); }
          50%     { transform: translateX(-50%) translateY(-11px) rotate(19deg); }
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        .login-input {
          width: 100%; height: 48px;
          border-radius: 9999px;
          border: 1.5px solid #E5E7EB;
          background: rgba(255,255,255,0.85);
          font-size: 0.9rem; color: #111827;
          outline: none;
          transition: border-color 200ms, box-shadow 200ms, background 200ms;
          padding: 0 18px 0 42px;
          box-sizing: border-box;
          font-family: inherit;
        }
        .login-input::placeholder { color: #9CA3AF; }
        .login-input:focus {
          border-color: #0066FF;
          box-shadow: 0 0 0 3px rgba(0,102,255,0.10);
          background: #fff;
        }
        .login-input.error { border-color: #EF4444; box-shadow: 0 0 0 3px rgba(239,68,68,0.08); }

        .social-btn {
          width: 48px; height: 48px; border-radius: 50%;
          border: 1.5px solid #E5E7EB; background: rgba(255,255,255,0.85);
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; transition: transform 200ms, box-shadow 200ms, background 200ms;
        }
        .social-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.10); background: #fff; }
        .social-btn:active { transform: scale(0.95); }

        .spinner {
          width: 18px; height: 18px; border-radius: 50%;
          border: 2px solid rgba(255,255,255,0.35);
          border-top-color: white;
          animation: spin 700ms linear infinite;
        }

        /* card float animations — applied after entrance */
        .card-float-0 { animation: cardEntrance0 700ms cubic-bezier(0.16,1,0.3,1) 0ms both, float0 5.2s ease-in-out 900ms infinite; }
        .card-float-1 { animation: cardEntrance1 700ms cubic-bezier(0.16,1,0.3,1) 150ms both, float1 6.8s ease-in-out 1200ms infinite; }
        .card-float-2 { animation: cardEntrance2 700ms cubic-bezier(0.16,1,0.3,1) 300ms both, float2 4.7s ease-in-out 1050ms infinite; }
        .card-float-3 { animation: cardEntrance3 700ms cubic-bezier(0.16,1,0.3,1) 450ms both, float3 7.4s ease-in-out 1350ms infinite; }

        /* ── Layout ── */
        .login-shell {
          min-height: 100vh;
          background: linear-gradient(135deg, #EEF1F8 0%, #D1D5DB 50%, #E8EEFF 100%);
        }

        /* Mobile: single column */
        .login-body {
          display: flex;
          flex-direction: column;
          align-items: center;
          padding: 20px 20px 48px;
        }
        .collage-side { display: none; }
        .form-side {
          width: 100%;
          max-width: 420px;
        }
        .form-card {
          width: 100%;
          border-radius: 28px;
          border: 1px solid rgba(255,255,255,0.75);
          background: rgba(255,255,255,0.65);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          box-shadow: 0 8px 32px rgba(0,0,0,0.08), inset 0 1px 0 rgba(255,255,255,0.8);
          padding: 36px 28px 32px;
          position: relative;
          overflow: hidden;
        }

        /* Desktop: two-column */
        @media (min-width: 1024px) {
          .login-body {
            flex-direction: row;
            align-items: stretch;
            padding: 0;
            min-height: calc(100vh - 54px);
          }
          .collage-side {
            display: block;
            flex: 0 0 58%;
            position: relative;
            background: linear-gradient(135deg, #E8EDF6 0%, #D0D8EA 50%, #DCE4F5 100%);
            overflow: hidden;
          }
          .form-side {
            flex: 0 0 42%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 48px 40px;
            background: rgba(255,255,255,0.42);
            backdrop-filter: blur(8px);
            max-width: none;
          }
          .form-card {
            max-width: 360px;
            padding: 32px 28px 28px;
          }
        }
      `}</style>

      <div className="login-shell antialiased font-sans">
        {/* Nav */}
        <nav style={{
          background: 'rgba(255,255,255,0.55)', backdropFilter: 'blur(14px)',
          borderBottom: '1px solid rgba(255,255,255,0.5)',
        }} className="px-6 py-3.5 flex items-center justify-between">
          <a href="/" className="flex items-center gap-2">
            <span className="text-xl font-black text-[#111827] tracking-tight">UNIFY</span>
            <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/20 text-[#0066FF]">GH</span>
          </a>
          <div className="hidden md:flex items-center gap-6">
            <a href="/schools" className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">Schools</a>
            <a href="/hubs"    className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">Hubs</a>
            <a href="/match"   className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">Match</a>
          </div>
        </nav>

        <div className="login-body">

          {/* ── Left: collage (desktop only) ── */}
          <div className="collage-side">
            <CollageSection scrollY={scrollY} mounted={mounted} />
          </div>

          {/* ── Right: form ── */}
          <div className="form-side">
            <div className="w-full" style={{
              maxWidth: 360,
              animation: mounted ? 'slideInRight 700ms cubic-bezier(0.16,1,0.3,1) 200ms both' : 'none',
            }}>
              {/* Mobile-only back link */}
              <div className="mb-4 lg:hidden">
                <a href="/" className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">← Back to home</a>
              </div>

              <div className="form-card">
                <BlueSwirl />

                {/* Logo */}
                <div className="text-center mb-6 relative">
                  <a href="/" className="inline-block">
                    <span className="font-black text-[#111827] tracking-tight leading-none" style={{ fontSize: '2rem' }}>UNIFY</span>
                  </a>
                  <OrangeScribble width={76} />
                  <p className="mt-2.5 text-[#6B7280] text-sm">
                    {isSignup ? "Join Ghana's campus network" : 'Welcome back'}
                  </p>
                </div>

                {done ? (
                  <div className="text-center py-4">
                    <div className="text-4xl mb-2">🔥</div>
                    <h3 className="text-lg font-black text-[#111827] mb-1">You're in!</h3>
                    <p className="text-[#6B7280] text-sm">
                      {isSignup ? 'Check your email to verify your account.' : 'Welcome back. Redirecting…'}
                    </p>
                  </div>
                ) : (
                  <>
                    {/* Toggle */}
                    <div className="flex w-full h-11 rounded-full border border-[#E5E7EB] bg-white p-1 mb-5">
                      {['signup', 'login'].map(m => (
                        <button key={m} onClick={() => switchMode(m)}
                          className="flex-1 rounded-full text-sm font-bold"
                          style={{
                            background: mode === m ? '#0066FF' : 'transparent',
                            color: mode === m ? '#fff' : '#6B7280',
                            border: 'none', cursor: 'pointer',
                            boxShadow: mode === m ? '0 4px 12px rgba(0,102,255,0.28)' : 'none',
                            transition: 'background 300ms cubic-bezier(0.34,1.56,0.64,1), color 300ms, box-shadow 300ms',
                          }}>
                          {m === 'signup' ? 'Sign Up' : 'Log In'}
                        </button>
                      ))}
                    </div>

                    {/* Email */}
                    <div className="relative">
                      <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#9CA3AF] z-10"
                        style={{ top: emailError ? 24 : undefined }} />
                      <input type="email" placeholder="Your email address" value={email}
                        onChange={e => { setEmail(e.target.value); if (emailError) setEmailError(''); }}
                        className={`login-input${emailError ? ' error' : ''}`} />
                      {emailError && <p className="text-[#EF4444] text-xs mt-1 ml-4">{emailError}</p>}
                    </div>

                    {/* Password */}
                    <div className="relative mt-3">
                      <Lock className="absolute left-3.5 top-[15px] w-4 h-4 text-[#9CA3AF] z-10" />
                      <input type={showPassword ? 'text' : 'password'}
                        placeholder={isSignup ? 'Create a password' : 'Your password'}
                        value={password}
                        onChange={e => { setPassword(e.target.value); if (passwordError) setPasswordError(''); }}
                        onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                        className={`login-input${passwordError ? ' error' : ''}`}
                        style={{ paddingRight: 44 }} />
                      <button type="button" onClick={() => setShowPassword(v => !v)}
                        className="absolute right-3.5 top-[15px] p-0 bg-transparent border-none cursor-pointer text-[#9CA3AF]"
                        aria-label={showPassword ? 'Hide password' : 'Show password'}>
                        {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                      {passwordError && <p className="text-[#EF4444] text-xs mt-1 ml-4">{passwordError}</p>}
                    </div>

                    {!isSignup && (
                      <div className="text-right mt-1.5">
                        <a href="#" className="text-xs text-[#0066FF] font-semibold hover:text-[#0052CC]">Forgot password?</a>
                      </div>
                    )}

                    {/* CTA */}
                    <div className="mt-5">
                      <button onClick={handleSubmit} disabled={loading}
                        className="w-full rounded-full font-black text-sm text-white border-none cursor-pointer flex flex-col items-center justify-center transition-all duration-200 disabled:opacity-70 disabled:cursor-not-allowed hover:-translate-y-0.5 active:scale-[0.98]"
                        style={{ height: 48, background: '#0066FF', boxShadow: '0 4px 14px rgba(0,102,255,0.35)' }}>
                        {loading
                          ? <div className="spinner" />
                          : <><span>{isSignup ? 'Create Account' : 'Log In'}</span><ButtonScribble /></>
                        }
                      </button>
                    </div>

                    {/* Divider */}
                    <div className="flex items-center gap-3 my-5">
                      <div className="flex-1 h-px bg-[#E5E7EB]" />
                      <span className="text-[11px] text-[#6B7280] uppercase tracking-widest whitespace-nowrap">
                        {isSignup ? 'or sign up with' : 'or log in with'}
                      </span>
                      <div className="flex-1 h-px bg-[#E5E7EB]" />
                    </div>

                    {/* Social */}
                    <div className="flex justify-center gap-4">
                      <button className="social-btn" aria-label="Continue with Apple">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="#111827">
                          <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                        </svg>
                      </button>
                      <button className="social-btn" aria-label="Continue with Facebook">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none">
                          <circle cx="12" cy="12" r="10" stroke="#1877F2" strokeWidth="1.5"/>
                          <path d="M13.5 8.5h1.5V6.5h-1.5C11.6 6.5 10.5 7.6 10.5 9v1.5H9V12.5h1.5V18h2v-5.5h1.5l.5-2H12.5V9c0-.28.22-.5.5-.5h.5z" fill="#1877F2"/>
                        </svg>
                      </button>
                      <button className="social-btn" aria-label="Continue with Google">
                        <svg viewBox="0 0 24 24" width="18" height="18">
                          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                        </svg>
                      </button>
                    </div>
                  </>
                )}
              </div>

              {/* Footer */}
              <div className="mt-5 text-center text-xs text-[#9CA3AF]">
                <a href="#" className="text-[#9CA3AF] no-underline hover:text-[#6B7280]">Terms of use</a>
                <span className="px-2">·</span>
                <a href="#" className="text-[#9CA3AF] no-underline hover:text-[#6B7280]">Privacy policy</a>
                <span className="px-2">·</span>
                <a href="#" className="text-[#9CA3AF] no-underline hover:text-[#6B7280]">Copyrights</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
