'use client';

import { useState, useEffect, useRef } from 'react';
import { Mail, Lock, Eye, EyeOff } from 'lucide-react';

// ── Decorative SVGs ──────────────────────────────────────────────────────────

function OrangeScribble({ width = 80 }) {
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
    <svg width="50" height="7" viewBox="0 0 50 7" fill="none" aria-hidden="true" className="block mx-auto mt-0.5">
      <path d="M2,4.5 C7,1 13,7 19,4 C25,1 31,7 37,4 C43,1 47,5.5 48,4"
        stroke="#FF6B35" strokeWidth="1.8" strokeLinecap="round" fill="none" />
    </svg>
  );
}

function BlueSpark({ size = 28 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none" aria-hidden="true">
      <line x1="16" y1="2"  x2="16" y2="10" stroke="#0066FF" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="24" y1="8"  x2="20" y2="12" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
      <line x1="28" y1="16" x2="22" y2="16" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
    </svg>
  );
}

function OrangeRadiate({ size = 26 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 28 28" fill="none" aria-hidden="true">
      <line x1="14" y1="2"  x2="14" y2="9"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="24" y1="6"  x2="20" y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="5"  y1="6"  x2="9"  y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="26" y1="14" x2="19" y2="14" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
      <line x1="2"  y1="14" x2="9"  y2="14" stroke="#FF6B35" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

function BlueSwirl() {
  return (
    <svg width="110" height="140" viewBox="0 0 120 160" fill="none" aria-hidden="true"
      className="absolute bottom-0 right-0 opacity-30 pointer-events-none">
      <path d="M100,10 C140,40 60,70 90,100 C120,130 40,145 70,155"
        stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round" fill="none"
        style={{ strokeDasharray: 300, strokeDashoffset: 0, animation: 'swirlDraw 800ms ease-out 1000ms both' }} />
      <path d="M80,20 C110,50 50,75 80,100 C105,120 55,140 75,155"
        stroke="#0066FF" strokeWidth="1" strokeLinecap="round" fill="none" opacity="0.5"
        style={{ strokeDasharray: 260, strokeDashoffset: 0, animation: 'swirlDraw 800ms ease-out 1200ms both' }} />
    </svg>
  );
}

// ── University campus placeholder frames ─────────────────────────────────────
// Abstract gradient tiles — safe, no non-Ghanaian images

const FRAMES = [
  {
    label: 'KNUST',
    sub: 'Great Hall, Kumasi',
    initials: 'KN',
    colors: ['#006400', '#FFD700'],
    pattern: 'radial-gradient(ellipse at 30% 30%, rgba(255,215,0,0.25) 0%, transparent 60%), linear-gradient(135deg, #006400 0%, #004d00 60%, #1a3a00 100%)',
    rotation: '-6deg',
    float: '5s',
    delay: '0s',
    size: 'large',
  },
  {
    label: 'UG Legon',
    sub: 'Balme Library, Accra',
    initials: 'UG',
    colors: ['#003366', '#C0A000'],
    pattern: 'radial-gradient(ellipse at 70% 20%, rgba(192,160,0,0.3) 0%, transparent 55%), linear-gradient(135deg, #003366 0%, #001f4d 70%, #001133 100%)',
    rotation: '4deg',
    float: '6.5s',
    delay: '0.15s',
    size: 'medium',
  },
  {
    label: 'UCC',
    sub: 'Main Campus, Cape Coast',
    initials: 'UC',
    colors: ['#8B0000', '#FFD700'],
    pattern: 'radial-gradient(ellipse at 20% 70%, rgba(255,215,0,0.2) 0%, transparent 50%), linear-gradient(135deg, #8B0000 0%, #6b0000 60%, #4a0000 100%)',
    rotation: '-3deg',
    float: '4.5s',
    delay: '0.3s',
    size: 'medium',
  },
  {
    label: 'UPSA',
    sub: 'Campus, Accra',
    initials: 'UP',
    colors: ['#1a1a6e', '#CC0000'],
    pattern: 'radial-gradient(ellipse at 60% 80%, rgba(204,0,0,0.25) 0%, transparent 55%), linear-gradient(135deg, #1a1a6e 0%, #0d0d4a 70%, #050528 100%)',
    rotation: '5deg',
    float: '7s',
    delay: '0.45s',
    size: 'small',
  },
];

function CampusFrame({ frame, index, scrollY }) {
  const parallaxFactor = [0.05, 0.08, 0.06, 0.10][index];
  const translateY = -scrollY * parallaxFactor;

  const positions = [
    // center large
    { top: '50%', left: '50%', transform: `translate(-50%, -50%) translateY(${translateY}px) rotate(${frame.rotation})` },
    // top-left
    { top: '18%', left: '10%', transform: `translateY(${translateY}px) rotate(${frame.rotation})` },
    // bottom-right
    { bottom: '14%', right: '8%', transform: `translateY(${translateY}px) rotate(${frame.rotation})` },
    // mid-right offset
    { top: '12%', right: '14%', transform: `translateY(${translateY}px) rotate(${frame.rotation})` },
  ];

  const sizes = {
    large: { width: 260, height: 200 },
    medium: { width: 210, height: 165 },
    small: { width: 175, height: 138 },
  };
  const { width, height } = sizes[frame.size];
  const pos = positions[index];
  const zIndex = [4, 2, 3, 1][index];
  const floatName = `frameFloat${index}`;

  return (
    <>
      <style>{`
        @keyframes ${floatName} {
          0%, 100% { transform: ${pos.transform}; }
          50%       { transform: ${pos.transform.replace('rotate(', 'translateY(-8px) rotate(')}; }
        }
      `}</style>
      <div style={{
        position: 'absolute',
        ...pos,
        zIndex,
        width,
        borderRadius: 20,
        background: 'white',
        padding: 10,
        boxShadow: '0 20px 40px -10px rgba(0,0,0,0.18), 0 4px 12px rgba(0,0,0,0.08)',
        animation: `entranceFrame${index} 700ms cubic-bezier(0.16,1,0.3,1) ${frame.delay} both, ${floatName} ${frame.float} ease-in-out ${frame.delay} infinite`,
        willChange: 'transform',
      }}>
        {/* Campus visual */}
        <div style={{
          width: '100%',
          height,
          borderRadius: 12,
          background: frame.pattern,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          position: 'relative',
          overflow: 'hidden',
        }}>
          {/* Subtle dot overlay */}
          <div style={{
            position: 'absolute', inset: 0,
            backgroundImage: 'radial-gradient(circle, rgba(255,255,255,0.08) 1px, transparent 1px)',
            backgroundSize: '18px 18px',
          }} />
          {/* Initials watermark */}
          <span style={{
            fontSize: 72, fontWeight: 900, color: 'rgba(255,255,255,0.12)',
            lineHeight: 1, letterSpacing: '-4px', userSelect: 'none',
            position: 'absolute',
          }}>{frame.initials}</span>
          {/* Foreground label */}
          <div style={{ position: 'relative', zIndex: 1, textAlign: 'center' }}>
            <div style={{
              display: 'inline-block',
              background: 'rgba(255,255,255,0.15)',
              border: '1px solid rgba(255,255,255,0.25)',
              borderRadius: 9999,
              padding: '4px 14px',
              marginBottom: 8,
            }}>
              <span style={{ color: 'rgba(255,255,255,0.9)', fontSize: 11, fontWeight: 700, letterSpacing: 1 }}>
                {frame.label}
              </span>
            </div>
          </div>
        </div>
        {/* Caption strip */}
        <div style={{ paddingTop: 8, paddingBottom: 2, textAlign: 'center' }}>
          <p style={{ margin: 0, fontSize: 11, color: '#6B7280', fontWeight: 500 }}>{frame.sub}</p>
        </div>
      </div>
    </>
  );
}

// ── Main component ────────────────────────────────────────────────────────────

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
          to   { stroke-dashoffset: 0;   opacity: 1; }
        }
        @keyframes swirlDraw {
          from { stroke-dashoffset: 300; opacity: 0; }
          to   { stroke-dashoffset: 0; }
        }
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(14px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes slideInRight {
          from { opacity: 0; transform: translateX(30px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes entranceFrame0 {
          from { opacity: 0; transform: translate(-50%,-50%) scale(0.82) rotate(-6deg); }
          to   { opacity: 1; transform: translate(-50%,-50%) scale(1) rotate(-6deg); }
        }
        @keyframes entranceFrame1 {
          from { opacity: 0; transform: translateY(30px) rotate(-10deg); }
          to   { opacity: 1; transform: translateY(0) rotate(-6deg); }
        }
        @keyframes entranceFrame2 {
          from { opacity: 0; transform: translateY(-20px) rotate(8deg); }
          to   { opacity: 1; transform: translateY(0) rotate(4deg); }
        }
        @keyframes entranceFrame3 {
          from { opacity: 0; transform: translateX(20px) rotate(-6deg); }
          to   { opacity: 1; transform: translateX(0) rotate(5deg); }
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

        /* Desktop overrides — input same height but mobile uses full width */
        @media (min-width: 1024px) {
          .login-input { background: rgba(255,255,255,0.9); }
        }

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

        /* ── Mobile: single column, full width ── */
        .login-shell {
          min-height: 100vh;
          background: linear-gradient(135deg, #EEF1F8 0%, #D1D5DB 50%, #E8EEFF 100%);
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

        /* ── Desktop: two-column ── */
        @media (min-width: 1024px) {
          .login-body {
            flex-direction: row;
            align-items: stretch;
            padding: 0;
            min-height: calc(100vh - 56px);
          }
          .collage-side {
            display: flex;
            flex: 0 0 58%;
            position: relative;
            background: linear-gradient(135deg, #EEF1F8 0%, #D5DAEA 60%, #E0E8FF 100%);
            overflow: hidden;
            align-items: center;
            justify-content: center;
          }
          .form-side {
            flex: 0 0 42%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 48px 40px;
            background: rgba(0,102,255,0.02);
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
        <nav className="px-6 py-3.5 flex items-center justify-between max-w-none border-b border-white/40"
          style={{ background: 'rgba(255,255,255,0.5)', backdropFilter: 'blur(12px)' }}>
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

          {/* ── Left: Image collage (desktop only) ── */}
          <div className="collage-side">
            {/* Background swirl behind frames */}
            <svg width="320" height="400" viewBox="0 0 320 400" fill="none" aria-hidden="true"
              style={{ position: 'absolute', top: '10%', left: '5%', opacity: 0.18, pointerEvents: 'none' }}>
              <path d="M280,20 C360,100 160,180 240,260 C320,340 120,370 200,390"
                stroke="#0066FF" strokeWidth="2" strokeLinecap="round" fill="none"
                style={{ strokeDasharray: 700, strokeDashoffset: 0, animation: 'swirlDraw 1200ms ease-out 200ms both' }} />
            </svg>

            {/* Decorative sparks */}
            <div style={{ position: 'absolute', top: '12%', left: '8%', animation: 'fadeUp 600ms ease 300ms both' }}>
              <BlueSpark size={32} />
            </div>
            <div style={{ position: 'absolute', top: '18%', left: '16%', animation: 'fadeUp 600ms ease 500ms both' }}>
              <BlueSpark size={20} />
            </div>
            <div style={{ position: 'absolute', bottom: '16%', right: '10%', animation: 'fadeUp 600ms ease 700ms both' }}>
              <OrangeRadiate size={30} />
            </div>
            <div style={{ position: 'absolute', bottom: '24%', right: '18%', animation: 'fadeUp 600ms ease 900ms both' }}>
              <OrangeRadiate size={20} />
            </div>

            {/* Campus frames */}
            {mounted && FRAMES.map((frame, i) => (
              <CampusFrame key={frame.label} frame={frame} index={i} scrollY={scrollY} />
            ))}

            {/* Bottom tagline */}
            <div style={{
              position: 'absolute', bottom: 32, left: 0, right: 0,
              textAlign: 'center', animation: 'fadeUp 600ms ease 800ms both',
            }}>
              <p style={{ margin: 0, fontSize: 13, color: '#6B7280', fontWeight: 500 }}>
                Ghana's top universities · All in one network
              </p>
            </div>
          </div>

          {/* ── Right: Login form ── */}
          <div className="form-side">
            <div className="w-full" style={{ maxWidth: 360, animation: mounted ? 'slideInRight 700ms cubic-bezier(0.16,1,0.3,1) 200ms both' : 'none' }}>

              {/* Mobile back link */}
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
                      {isSignup ? 'Check your email to verify your account.' : 'Welcome back. Redirecting you now…'}
                    </p>
                  </div>
                ) : (
                  <>
                    {/* Toggle */}
                    <div className="flex w-full h-11 rounded-full border border-[#E5E7EB] bg-white p-1 mb-5">
                      {['signup', 'login'].map(m => (
                        <button key={m} onClick={() => switchMode(m)}
                          className="flex-1 rounded-full text-sm font-bold transition-all duration-300"
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

                    {/* Social buttons */}
                    <div className="flex justify-center gap-4">
                      <button className="social-btn" aria-label="Sign in with Apple">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="#111827">
                          <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                        </svg>
                      </button>
                      <button className="social-btn" aria-label="Sign in with Facebook">
                        <svg viewBox="0 0 24 24" width="18" height="18" fill="none">
                          <circle cx="12" cy="12" r="10" stroke="#1877F2" strokeWidth="1.5"/>
                          <path d="M13.5 8.5h1.5V6.5h-1.5C11.6 6.5 10.5 7.6 10.5 9v1.5H9V12.5h1.5V18h2v-5.5h1.5l.5-2H12.5V9c0-.28.22-.5.5-.5h.5z" fill="#1877F2"/>
                        </svg>
                      </button>
                      <button className="social-btn" aria-label="Sign in with Google">
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

              {/* Footer links */}
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
