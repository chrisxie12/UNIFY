'use client';

import { useState, useEffect } from 'react';
import { Mail, Lock, Eye, EyeOff } from 'lucide-react';

function OrangeScribble({ width = 72 }) {
  return (
    <svg width={width} height="9" viewBox={`0 0 ${width} 9`} fill="none" aria-hidden="true" style={{ display: 'block', margin: '3px auto 0' }}>
      <path
        d={`M2,5.5 C${width*.12},1.5 ${width*.25},8.5 ${width*.38},4.5 C${width*.5},0.5 ${width*.63},8.5 ${width*.75},4.5 C${width*.87},0.5 ${width*.94},6.5 ${width-2},4.5`}
        stroke="#FF6B35" strokeWidth="2.2" strokeLinecap="round" fill="none"
        style={{ strokeDasharray: width * 1.4, strokeDashoffset: 0, animation: 'scribbleDraw 500ms cubic-bezier(0.16,1,0.3,1) 300ms both' }}
      />
    </svg>
  );
}

function ButtonScribble() {
  return (
    <svg width="44" height="6" viewBox="0 0 44 6" fill="none" aria-hidden="true" style={{ display: 'block', margin: '2px auto 0' }}>
      <path d="M1,4 C5.5,0.5 11,6.5 17,3.5 C23,0.5 29,6.5 35,3.5 C39.5,0.5 42.5,5 43,3.5"
        stroke="#FF6B35" strokeWidth="1.6" strokeLinecap="round" fill="none" />
    </svg>
  );
}

function BlueSwirl() {
  return (
    <svg width="90" height="115" viewBox="0 0 120 160" fill="none" aria-hidden="true"
      style={{ position: 'absolute', bottom: 0, right: 0, opacity: 0.25, pointerEvents: 'none' }}>
      <path d="M100,10 C140,40 60,70 90,100 C120,130 40,145 70,155"
        stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round" fill="none"
        style={{ strokeDasharray: 300, strokeDashoffset: 0, animation: 'swirlDraw 900ms ease-out 700ms both' }} />
      <path d="M80,20 C110,50 50,75 80,100 C105,120 55,140 75,155"
        stroke="#FF6B35" strokeWidth="1" strokeLinecap="round" fill="none" opacity="0.5"
        style={{ strokeDasharray: 260, strokeDashoffset: 0, animation: 'swirlDraw 900ms ease-out 900ms both' }} />
    </svg>
  );
}

const FRAMES = [
  {
    id: 'knust',
    school: 'KNUST',
    caption: 'Great Hall · Kumasi',
    initials: 'KN',
    stripe: '#FFD700',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Kwame_Nkrumah_University_of_Science_and_Technology_(KNUST)_%E2%80%93_Side_view_of_the_College_of_Architecture_and_Planning.JPG?width=600',
    bg: 'linear-gradient(150deg, #0a2e0a 0%, #1a4a10 40%, #2d6e1e 70%, #1a3d0a 100%)',
    orb: 'rgba(255,210,50,0.20)', orbPos: '72% 18%',
    width: 270, height: 202,
    top: '22%', left: '24%',
    rotation: -2, zIndex: 10,
    floatAnim: 'float0', floatDur: '4s', delay: '0ms',
    from: 'scale(0.88) translateY(20px) rotate(-2deg)',
    to:   'scale(1) translateY(0) rotate(-2deg)',
  },
  {
    id: 'ug',
    school: 'UG Legon',
    caption: 'Balme Library · Accra',
    initials: 'UG',
    stripe: '#C0A000',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Legon_Tower.JPG?width=600',
    bg: 'linear-gradient(150deg, #020b1f 0%, #05194a 40%, #0a2f72 70%, #031232 100%)',
    orb: 'rgba(192,160,0,0.22)', orbPos: '22% 28%',
    width: 215, height: 161,
    top: '6%', left: '6%',
    rotation: -9, zIndex: 6,
    floatAnim: 'float1', floatDur: '5.3s', delay: '140ms',
    from: 'translateX(-24px) rotate(-13deg)',
    to:   'translateX(0) rotate(-9deg)',
  },
  {
    id: 'ashesi',
    school: 'Ashesi',
    caption: 'Berekuso · Eastern Region',
    initials: 'AU',
    stripe: '#C0C0C0',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Warren_Library_Ashesi.JPG?width=600',
    bg: 'linear-gradient(150deg, #2a0000 0%, #5a0808 38%, #8B1010 65%, #3d0505 100%)',
    orb: 'rgba(192,192,192,0.18)', orbPos: '35% 25%',
    width: 210, height: 158,
    top: '5%', left: '50%',
    rotation: 8, zIndex: 8,
    floatAnim: 'float2', floatDur: '6.1s', delay: '280ms',
    from: 'translateY(-24px) rotate(12deg)',
    to:   'translateY(0) rotate(8deg)',
  },
  {
    id: 'ucc',
    school: 'UCC',
    caption: 'Main Campus · Cape Coast',
    initials: 'UC',
    stripe: '#FFD700',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Cape_Coast_Ghana.JPG?width=600',
    bg: 'linear-gradient(150deg, #1a0000 0%, #4a0606 38%, #7a0a0a 68%, #3a0303 100%)',
    orb: 'rgba(255,210,60,0.18)', orbPos: '65% 72%',
    width: 235, height: 176,
    top: '50%', left: '38%',
    rotation: 6, zIndex: 9,
    floatAnim: 'float3', floatDur: '4.6s', delay: '420ms',
    from: 'translateX(24px) rotate(10deg)',
    to:   'translateX(0) rotate(6deg)',
  },
  {
    id: 'upsa',
    school: 'UPSA',
    caption: 'Modern Campus · Accra',
    initials: 'UP',
    stripe: '#CC2222',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/College_of_Engineering,_KNUST,_Kumasi,_Ghana.JPG?width=600',
    bg: 'linear-gradient(150deg, #03031a 0%, #0d0d4a 40%, #1a1a72 68%, #06062a 100%)',
    orb: 'rgba(204,40,40,0.22)', orbPos: '78% 62%',
    width: 198, height: 149,
    top: '48%', left: '6%',
    rotation: -7, zIndex: 7,
    floatAnim: 'float4', floatDur: '5.7s', delay: '560ms',
    from: 'translateX(-20px) rotate(-11deg)',
    to:   'translateX(0) rotate(-7deg)',
  },
  {
    id: 'uds',
    school: 'UDS',
    caption: 'Tamale · Northern Region',
    initials: 'UD',
    stripe: '#FF8C00',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Front-view_of_the_UDS_Central_Administration_Block.jpg?width=600',
    bg: 'linear-gradient(150deg, #001a00 0%, #003d00 38%, #005c00 65%, #002800 100%)',
    orb: 'rgba(255,140,0,0.22)', orbPos: '60% 40%',
    width: 192, height: 144,
    top: '68%', left: '24%',
    rotation: -4, zIndex: 5,
    floatAnim: 'float5', floatDur: '4.9s', delay: '700ms',
    from: 'translateY(24px) rotate(-7deg)',
    to:   'translateY(0) rotate(-4deg)',
  },
];

function CampusFrame({ frame, scrollY }) {
  const parallaxFactors = { knust: 0.04, ug: 0.07, ucc: 0.055, upsa: 0.09, ashesi: 0.06, uds: 0.08 };
  const py = -(scrollY * (parallaxFactors[frame.id] || 0.05));
  const entranceKey = `entrance_${frame.id}`;
  const floatKey = `float_${frame.id}`;

  return (
    <>
      <style>{`
        @keyframes ${entranceKey} {
          from { opacity: 0; transform: ${frame.from}; }
          to   { opacity: 1; transform: ${frame.to}; }
        }
        @keyframes ${floatKey} {
          from { transform: ${frame.to}; }
          to   { transform: ${frame.to.replace('rotate(', 'translateY(-7px) rotate(')}; }
        }
      `}</style>
      <div className="campus-frame" style={{
        position: 'absolute',
        top: frame.top,
        left: frame.left,
        width: frame.width,
        zIndex: frame.zIndex,
        borderRadius: 0,
        background: '#162347',
        padding: 10,
        boxShadow: '0 20px 40px -10px rgba(0,0,0,0.40), 0 4px 16px rgba(0,0,0,0.20)',
        animation: `${entranceKey} 650ms cubic-bezier(0.16,1,0.3,1) ${frame.delay} both, ${floatKey} ${frame.floatDur} ease-in-out calc(${frame.delay} + 650ms) infinite alternate`,
        willChange: 'transform',
      }}>
      {/* Photo tile */}
      <div style={{
        width: '100%',
        height: frame.height - 20,
        borderRadius: 0,
        background: frame.bg,
        position: 'relative',
        overflow: 'hidden',
      }}>
        {frame.photo && (
          <img
            src={frame.photo}
            alt={`${frame.school} campus`}
            style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', objectFit: 'cover', objectPosition: 'center' }}
          />
        )}
        {frame.photo && (
          <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to bottom, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0.30) 100%)' }} />
        )}
        <div style={{
          position: 'absolute',
          width: 180, height: 180,
          borderRadius: 0,
          background: `radial-gradient(circle, ${frame.orb} 0%, transparent 70%)`,
          top: frame.orbPos.split(' ')[1],
          left: frame.orbPos.split(' ')[0],
          transform: 'translate(-50%,-50%)',
          pointerEvents: 'none',
        }} />
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.07 }} preserveAspectRatio="none">
          {[0.18, 0.36, 0.54, 0.72, 0.90].map(x => (
            <line key={x} x1={`${x*100}%`} y1="0" x2={`${x*100}%`} y2="100%" stroke="white" strokeWidth="1" />
          ))}
          {[0.3, 0.6, 0.9].map(y => (
            <line key={y} x1="0" y1={`${y*100}%`} x2="100%" y2={`${y*100}%`} stroke="white" strokeWidth="0.8" />
          ))}
        </svg>
        <div style={{
          position: 'absolute', top: 10, left: 10,
          background: 'rgba(255,255,255,0.14)',
          border: '1px solid rgba(255,255,255,0.25)',
          borderRadius: 0, padding: '3px 9px',
        }}>
          <span style={{ color: 'rgba(255,255,255,0.92)', fontSize: 9, fontWeight: 700, letterSpacing: 1 }}>
            {frame.school}
          </span>
        </div>
        <span style={{
          position: 'absolute', bottom: -14, right: 6,
          fontSize: 88, fontWeight: 900,
          color: 'rgba(255,255,255,0.06)',
          lineHeight: 1, letterSpacing: -5,
          userSelect: 'none',
          fontFamily: 'system-ui, sans-serif',
        }}>{frame.initials}</span>
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0, height: 56,
          background: 'linear-gradient(to top, rgba(0,0,0,0.50) 0%, transparent 100%)',
          display: 'flex', alignItems: 'flex-end', padding: '0 10px 8px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <div style={{ width: 5, height: 5, borderRadius: 0, background: frame.stripe }} />
            <span style={{ color: 'rgba(255,255,255,0.88)', fontSize: 10, fontWeight: 600, fontFamily: 'system-ui, sans-serif' }}>
              {frame.caption.split('·')[1]?.trim()}
            </span>
          </div>
        </div>
      </div>
      {/* Polaroid caption strip */}
      <div style={{ paddingTop: 7, paddingBottom: 2, textAlign: 'center' }}>
        <p style={{ margin: 0, fontSize: 11, fontWeight: 700, color: '#FFFFFE', fontFamily: 'system-ui, sans-serif' }}>{frame.school}</p>
        <p style={{ margin: '1px 0 0', fontSize: 9, color: 'rgba(255,255,255,0.60)', fontFamily: 'system-ui, sans-serif' }}>{frame.caption}</p>
      </div>
      <div style={{
        position: 'absolute', bottom: 0, left: '12%', right: '12%', height: 3,
        background: frame.stripe, borderRadius: 0, opacity: 0.55,
      }} />
    </div>
    </>
  );
}

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
        @keyframes spin { to { transform: rotate(360deg); } }

        @keyframes slideInRight {
          from { opacity: 0; transform: translateX(28px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(12px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes popIn {
          from { opacity: 0; transform: scale(0); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes formFadeUp {
          from { opacity: 0; transform: translateY(10px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes formFadeDown {
          from { opacity: 0; transform: translateY(-15px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes formScaleIn {
          from { opacity: 0; transform: scale(0.95); }
          to   { opacity: 1; transform: scale(1); }
        }

        .campus-frame {
          transition: box-shadow 300ms ease, transform 300ms ease;
        }
        .campus-frame:hover {
          box-shadow: 8px 8px 0px #FF6B35 !important;
          z-index: 20 !important;
        }

        .login-input {
          width: 100%; height: 48px;
          border-radius: 0;
          border: 2px solid rgba(255,255,255,0.40);
          background: rgba(26,24,39,0.85);
          font-size: 0.9rem; color: #FFFFFE;
          outline: none;
          transition: border-color 200ms, box-shadow 200ms, background 200ms;
          padding: 0 16px 0 40px;
          box-sizing: border-box;
          font-family: inherit;
        }
        .login-input::placeholder { color: rgba(255,255,255,0.40); }
        .login-input:focus {
          border-color: #FF6B35;
          box-shadow: 0 0 0 3px rgba(255,107,53,0.25);
          background: rgba(26,24,39,1);
        }
        .login-input.error { border-color: #EF4444; box-shadow: 0 0 0 3px rgba(239,68,68,0.08); }

        .social-btn {
          width: 44px; height: 44px; border-radius: 0;
          border: 2px solid rgba(255,255,255,0.30); background: rgba(26,24,39,0.85);
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; transition: transform 200ms, box-shadow 200ms, background 200ms;
        }
        .social-btn:hover { transform: translateY(-2px); box-shadow: 4px 4px 0px rgba(0,0,0,0.45); background: rgba(26,24,39,1); }
        .social-btn:active { transform: scale(0.95); }

        .spinner {
          width: 18px; height: 18px; border-radius: 50%;
          border: 2px solid rgba(255,255,255,0.35);
          border-top-color: white;
          animation: spin 700ms linear infinite;
        }

        .login-shell {
          min-height: 100vh;
          background: #0D1B3E;
          font-family: inherit;
        }

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
          border-radius: 0;
          border: 2px solid #FF6B35;
          background: #162347;
          box-shadow: 4px 4px 0px #FF6B35;
          padding: 36px 28px 32px;
          position: relative;
          overflow: hidden;
        }

        @media (min-width: 1024px) {
          .login-body {
            flex-direction: row;
            align-items: stretch;
            padding: 0;
            height: calc(100vh - 54px);
            overflow: hidden;
          }
          .collage-side {
            display: block;
            flex: 0 0 58%;
            position: relative;
            background: #162347;
            overflow: hidden;
          }
          .collage-side::after {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(ellipse at 60% 50%, rgba(255,107,53,0.06) 0%, transparent 70%);
            pointer-events: none;
          }
          .form-side {
            flex: 0 0 42%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 36px;
            background: #0D1B3E;
            max-width: none;
            overflow-y: auto;
          }
          .form-card {
            width: 100%;
            max-width: 340px;
            padding: 28px 24px 24px;
            border-radius: 0;
          }
        }
      `}</style>

      <div className="login-shell antialiased font-sans">

        {/* Nav */}
        <nav style={{
          background: 'rgba(15,14,23,0.80)',
          backdropFilter: 'blur(14px)',
          WebkitBackdropFilter: 'blur(14px)',
          borderBottom: '2px solid #FF6B35',
        }} className="px-6 py-3.5 flex items-center justify-between">
          <a href="/" className="flex items-center gap-2">
            <span className="text-xl font-black text-white tracking-tight">UNIFY</span>
            <span className="text-[10px] font-black px-2 py-0.5 rounded-none border border-[#FF6B35]/40 text-[#FF6B35]">GH</span>
          </a>
          <div className="hidden md:flex items-center gap-6">
            <a href="/schools" className="text-sm font-semibold text-white/60 hover:text-white transition-colors">Schools</a>
            <a href="/hubs"    className="text-sm font-semibold text-white/60 hover:text-white transition-colors">Hubs</a>
            <a href="/match"   className="text-sm font-semibold text-white/60 hover:text-white transition-colors">Match</a>
          </div>
        </nav>

        <div className="login-body">

          {/* Left collage (desktop only) */}
          <div className="collage-side">
            <svg width="100%" height="100%" viewBox="0 0 600 700" fill="none" aria-hidden="true"
              style={{ position: 'absolute', inset: 0, opacity: 0.10, pointerEvents: 'none' }}>
              <path d="M480,40 C560,160 320,300 440,420 C560,540 280,600 380,680"
                stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" fill="none"
                style={{ strokeDasharray: 1100, strokeDashoffset: 0, animation: 'swirlDraw 1400ms ease-out 200ms both' }} />
              <path d="M420,60 C500,170 280,300 400,410 C510,510 260,580 360,670"
                stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round" fill="none" opacity="0.5"
                style={{ strokeDasharray: 1000, strokeDashoffset: 0, animation: 'swirlDraw 1400ms ease-out 400ms both' }} />
            </svg>

            <div style={{ position: 'absolute', top: '8%', left: '7%', opacity: 0.8, animation: 'fadeUp 500ms ease 600ms both' }}>
              <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                <line x1="16" y1="2"  x2="16" y2="10" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
                <line x1="24" y1="8"  x2="20" y2="12" stroke="#FF6B35" strokeWidth="2"   strokeLinecap="round"/>
                <line x1="28" y1="16" x2="22" y2="16" stroke="#FF6B35" strokeWidth="2"   strokeLinecap="round"/>
                <line x1="8"  y1="8"  x2="12" y2="12" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
                <line x1="4"  y1="16" x2="10" y2="16" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            </div>
            <div style={{ position: 'absolute', top: '16%', left: '14%', opacity: 0.6, animation: 'fadeUp 500ms ease 800ms both' }}>
              <svg width="18" height="18" viewBox="0 0 32 32" fill="none">
                <line x1="16" y1="4"  x2="16" y2="11" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                <line x1="23" y1="9"  x2="20" y2="13" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
                <line x1="26" y1="16" x2="21" y2="16" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            </div>

            <div style={{ position: 'absolute', bottom: '12%', right: '8%', opacity: 0.8, animation: 'fadeUp 500ms ease 900ms both' }}>
              <svg width="32" height="32" viewBox="0 0 28 28" fill="none">
                <line x1="14" y1="1"  x2="14" y2="8"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                <line x1="25" y1="5"  x2="20" y2="9"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                <line x1="4"  y1="5"  x2="9"  y2="9"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                <line x1="27" y1="14" x2="20" y2="14" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
                <line x1="1"  y1="14" x2="8"  y2="14" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
                <line x1="25" y1="23" x2="20" y2="19" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
                <line x1="4"  y1="23" x2="9"  y2="19" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            </div>
            <div style={{ position: 'absolute', bottom: '22%', right: '16%', opacity: 0.55, animation: 'fadeUp 500ms ease 1100ms both' }}>
              <svg width="18" height="18" viewBox="0 0 28 28" fill="none">
                <line x1="14" y1="2"  x2="14" y2="8"  stroke="#FF6B35" strokeWidth="1.8" strokeLinecap="round"/>
                <line x1="23" y1="6"  x2="19" y2="10" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
                <line x1="5"  y1="6"  x2="9"  y2="10" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            </div>

            {mounted && FRAMES.map(frame => (
              <CampusFrame key={frame.id} frame={frame} scrollY={scrollY} />
            ))}

            <div style={{
              position: 'absolute', top: 28, left: '50%', transform: 'translateX(-50%)',
              animation: 'fadeUp 600ms ease 700ms both',
              whiteSpace: 'nowrap',
            }}>
              <span style={{
                display: 'inline-flex', alignItems: 'center', gap: 7,
                background: 'rgba(26,24,39,0.80)',
                backdropFilter: 'blur(12px)',
                border: '1px solid rgba(255,255,255,0.10)',
                borderRadius: 0, padding: '6px 16px',
                fontSize: 12, fontWeight: 700, color: 'rgba(255,255,255,0.80)',
                fontFamily: 'system-ui, sans-serif',
                boxShadow: '3px 3px 0px rgba(0,0,0,0.4)',
              }}>
                🇬🇭 Ghana University Network
              </span>
            </div>
          </div>

          {/* Right: login form */}
          <div className="form-side">
            <div style={{
              width: '100%',
              maxWidth: 340,
              animation: mounted ? 'slideInRight 700ms cubic-bezier(0.16,1,0.3,1) 200ms both' : 'none',
            }}>
              <div className="mb-4 lg:hidden">
                <a href="/" className="text-sm font-semibold text-white/60 hover:text-white transition-colors">← Back to home</a>
              </div>

              <div className="form-card">
                <BlueSwirl />

                <div style={{
                  textAlign: 'center', marginBottom: 20, position: 'relative',
                  animation: mounted ? 'formFadeDown 600ms cubic-bezier(0.16,1,0.3,1) 0ms both' : 'none',
                }}>
                  <div style={{
                    position: 'absolute', top: -6, right: 8,
                    animation: mounted ? 'popIn 400ms cubic-bezier(0.34,1.56,0.64,1) 400ms both' : 'none',
                  }}>
                    <svg width="26" height="26" viewBox="0 0 32 32" fill="none" aria-hidden="true">
                      <line x1="16" y1="2"  x2="16" y2="10" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
                      <line x1="24" y1="8"  x2="20" y2="12" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
                      <line x1="28" y1="16" x2="21" y2="16" stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round"/>
                    </svg>
                  </div>
                  <a href="/" style={{ textDecoration: 'none' }}>
                    <span style={{ fontSize: '2rem', fontWeight: 900, color: '#FFFFFE', letterSpacing: '-0.03em', lineHeight: 1 }}>
                      UNIFY
                    </span>
                  </a>
                  <OrangeScribble width={72} />
                  <p style={{ marginTop: 8, color: 'rgba(255,255,255,0.60)', fontSize: '0.85rem', fontFamily: 'inherit' }}>
                    {isSignup ? "Join Ghana's campus network" : 'Welcome back'}
                  </p>
                </div>

                {done ? (
                  <div style={{ textAlign: 'center', padding: '16px 0' }}>
                    <div style={{ fontSize: 40, marginBottom: 8 }}>🔥</div>
                    <h3 style={{ fontSize: 18, fontWeight: 900, color: '#FFFFFE', margin: '0 0 6px', fontFamily: 'inherit' }}>You're in!</h3>
                    <p style={{ color: 'rgba(255,255,255,0.60)', fontSize: '0.85rem', margin: 0, fontFamily: 'inherit' }}>
                      {isSignup ? 'Check your email to verify your account.' : 'Welcome back. Redirecting…'}
                    </p>
                  </div>
                ) : (
                  <>
                    <div style={{
                      display: 'flex', width: 240, height: 44, margin: '0 auto 20px',
                      borderRadius: 0, border: '2px solid #FF6B35',
                      background: '#0D1B3E', padding: 3,
                      animation: mounted ? 'formFadeUp 600ms cubic-bezier(0.16,1,0.3,1) 100ms both' : 'none',
                    }}>
                      {['signup', 'login'].map(m => (
                        <button key={m} onClick={() => switchMode(m)} style={{
                          flex: 1, borderRadius: 0, border: 'none', cursor: 'pointer',
                          fontWeight: mode === m ? 700 : 500,
                          fontSize: '0.8rem',
                          background: mode === m ? '#FF6B35' : 'transparent',
                          color: mode === m ? '#fff' : 'rgba(255,255,255,0.60)',
                          boxShadow: 'none',
                          transition: 'background 280ms cubic-bezier(0.34,1.56,0.64,1), color 280ms, box-shadow 280ms',
                          fontFamily: 'inherit',
                        }}>
                          {m === 'signup' ? 'Sign Up' : 'Log In'}
                        </button>
                      ))}
                    </div>

                    <div style={{ position: 'relative', marginBottom: 0, animation: mounted ? 'formFadeUp 600ms cubic-bezier(0.16,1,0.3,1) 180ms both' : 'none' }}>
                      <div style={{
                        position: 'absolute', left: -18, top: '50%', transform: 'translateY(-50%)',
                        animation: mounted ? 'popIn 400ms cubic-bezier(0.34,1.56,0.64,1) 500ms both' : 'none',
                        pointerEvents: 'none',
                        ...(emailError ? { top: 24, transform: 'none' } : {}),
                      }}>
                        <svg width="14" height="14" viewBox="0 0 28 28" fill="none" aria-hidden="true">
                          <line x1="14" y1="1"  x2="14" y2="8"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                          <line x1="25" y1="5"  x2="20" y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                          <line x1="3"  y1="5"  x2="8"  y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      </div>
                      <Mail style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'rgba(255,255,255,0.40)', width: 16, height: 16, zIndex: 1,
                        ...(emailError ? { top: 24, transform: 'none' } : {}) }} />
                      <input type="email" placeholder="Your email address" value={email}
                        onChange={e => { setEmail(e.target.value); if (emailError) setEmailError(''); }}
                        className={`login-input${emailError ? ' error' : ''}`} />
                      {emailError && <p style={{ color: '#EF4444', fontSize: '0.75rem', margin: '4px 0 0 14px', fontFamily: 'inherit' }}>{emailError}</p>}
                    </div>

                    <div style={{ position: 'relative', marginTop: 10, animation: mounted ? 'formFadeUp 600ms cubic-bezier(0.16,1,0.3,1) 260ms both' : 'none' }}>
                      <Lock style={{ position: 'absolute', left: 14, top: 16, color: 'rgba(255,255,255,0.40)', width: 16, height: 16, zIndex: 1 }} />
                      <input type={showPassword ? 'text' : 'password'}
                        placeholder={isSignup ? 'Create a password' : 'Your password'}
                        value={password}
                        onChange={e => { setPassword(e.target.value); if (passwordError) setPasswordError(''); }}
                        onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                        className={`login-input${passwordError ? ' error' : ''}`}
                        style={{ paddingRight: 42 }} />
                      <button type="button" onClick={() => setShowPassword(v => !v)}
                        style={{ position: 'absolute', right: 14, top: 15, background: 'none', border: 'none', cursor: 'pointer', padding: 0, color: 'rgba(255,255,255,0.40)' }}
                        aria-label={showPassword ? 'Hide password' : 'Show password'}>
                        {showPassword ? <EyeOff style={{ width: 16, height: 16 }} /> : <Eye style={{ width: 16, height: 16 }} />}
                      </button>
                      {passwordError && <p style={{ color: '#EF4444', fontSize: '0.75rem', margin: '4px 0 0 14px', fontFamily: 'inherit' }}>{passwordError}</p>}
                    </div>

                    {!isSignup && (
                      <div style={{ textAlign: 'right', marginTop: 6 }}>
                        <a href="#" style={{ fontSize: '0.75rem', color: '#A8C4FF', fontWeight: 600, textDecoration: 'none', fontFamily: 'inherit' }}>Forgot password?</a>
                      </div>
                    )}

                    <div style={{ marginTop: 18, animation: mounted ? 'formFadeUp 600ms cubic-bezier(0.16,1,0.3,1) 300ms both' : 'none' }}>
                      <button onClick={handleSubmit} disabled={loading}
                        style={{
                          width: '100%', height: 48, borderRadius: 0,
                          background: '#FF6B35', color: 'white',
                          fontWeight: 800, fontSize: '0.875rem',
                          border: '2px solid white', cursor: 'pointer',
                          boxShadow: '3px 3px 0px rgba(255,255,255,0.3)',
                          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                          transition: 'transform 200ms, box-shadow 200ms, opacity 200ms',
                          fontFamily: 'inherit',
                        }}
                        onMouseEnter={e => { if (!loading) { e.currentTarget.style.transform = 'translateY(-1px)'; e.currentTarget.style.background = '#E55A22'; } }}
                        onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.background = '#FF6B35'; }}>
                        {loading
                          ? <div className="spinner" />
                          : <><span>{isSignup ? 'SIGN UP' : 'LOG IN'}</span><ButtonScribble /></>
                        }
                      </button>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '18px 0' }}>
                      <div style={{ flex: 1, height: 1, background: 'rgba(255,255,255,0.10)' }} />
                      <span style={{ fontSize: '0.68rem', color: 'rgba(255,255,255,0.40)', textTransform: 'uppercase', letterSpacing: '0.06em', whiteSpace: 'nowrap', fontFamily: 'inherit' }}>
                        {isSignup ? 'or sign up with' : 'or log in with'}
                      </span>
                      <div style={{ flex: 1, height: 1, background: 'rgba(255,255,255,0.10)' }} />
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'center', gap: 16, animation: mounted ? 'formScaleIn 600ms cubic-bezier(0.16,1,0.3,1) 420ms both' : 'none' }}>
                      <button className="social-btn" aria-label="Continue with Apple">
                        <svg viewBox="0 0 24 24" width="17" height="17" fill="#FFFFFE">
                          <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                        </svg>
                      </button>
                      <button className="social-btn" aria-label="Continue with Facebook">
                        <svg viewBox="0 0 24 24" width="17" height="17" fill="none">
                          <circle cx="12" cy="12" r="10" stroke="#1877F2" strokeWidth="1.5"/>
                          <path d="M13.5 8.5h1.5V6.5h-1.5C11.6 6.5 10.5 7.6 10.5 9v1.5H9V12.5h1.5V18h2v-5.5h1.5l.5-2H12.5V9c0-.28.22-.5.5-.5h.5z" fill="#1877F2"/>
                        </svg>
                      </button>
                      <button className="social-btn" aria-label="Continue with Google">
                        <svg viewBox="0 0 24 24" width="17" height="17">
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
              <div style={{ marginTop: 18, textAlign: 'center', fontSize: '0.72rem', color: 'rgba(255,255,255,0.40)', fontFamily: 'inherit' }}>
                <a href="#" style={{ color: 'rgba(255,255,255,0.40)', textDecoration: 'none' }}>Terms of use</a>
                <span style={{ padding: '0 6px' }}>·</span>
                <a href="#" style={{ color: 'rgba(255,255,255,0.40)', textDecoration: 'none' }}>Privacy policy</a>
                <span style={{ padding: '0 6px' }}>·</span>
                <a href="#" style={{ color: 'rgba(255,255,255,0.40)', textDecoration: 'none' }}>Copyrights</a>
              </div>
            </div>
          </div>

        </div>
      </div>
    </>
  );
}
