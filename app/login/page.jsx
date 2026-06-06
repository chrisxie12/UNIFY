'use client';

import { useState, useEffect } from 'react';
import { Mail, Lock, Eye, EyeOff, ArrowRight } from 'lucide-react';

function OrangeScribble({ width = 80 }) {
  return (
    <svg width={width} height="10" viewBox={`0 0 ${width} 10`} fill="none" aria-hidden="true"
      className="block mx-auto mt-1">
      <path
        d={`M2,6 C${width*0.12},2 ${width*0.25},9 ${width*0.38},5 C${width*0.5},1 ${width*0.63},9 ${width*0.75},5 C${width*0.87},1 ${width*0.94},7 ${width-2},5`}
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

function BlueSpark() {
  return (
    <svg width="28" height="28" viewBox="0 0 32 32" fill="none" aria-hidden="true"
      style={{ animation: 'sparkPop 400ms cubic-bezier(0.34,1.56,0.64,1) 600ms both' }}>
      <line x1="16" y1="2"  x2="16" y2="10" stroke="#0066FF" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="24" y1="8"  x2="20" y2="12" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
      <line x1="28" y1="16" x2="22" y2="16" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
    </svg>
  );
}

function BlueSwirl() {
  return (
    <svg width="110" height="140" viewBox="0 0 120 160" fill="none" aria-hidden="true"
      className="absolute bottom-0 right-0 opacity-40 pointer-events-none">
      <path d="M100,10 C140,40 60,70 90,100 C120,130 40,145 70,155"
        stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round" fill="none"
        style={{ strokeDasharray: 300, strokeDashoffset: 0, animation: 'swirlDraw 800ms ease-out 1000ms both' }} />
      <path d="M80,20 C110,50 50,75 80,100 C105,120 55,140 75,155"
        stroke="#0066FF" strokeWidth="1" strokeLinecap="round" fill="none" opacity="0.5"
        style={{ strokeDasharray: 260, strokeDashoffset: 0, animation: 'swirlDraw 800ms ease-out 1200ms both' }} />
    </svg>
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

  useEffect(() => { setMounted(true); }, []);

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
    setEmailError(eErr);
    setPasswordError(pErr);
    if (eErr || pErr) return;
    setLoading(true);
    await new Promise(r => setTimeout(r, 1200));
    setLoading(false);
    setDone(true);
  }

  function switchMode(m) {
    setMode(m);
    setEmailError('');
    setPasswordError('');
    setDone(false);
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
          to   { stroke-dashoffset: 0;   opacity: 0.5; }
        }
        @keyframes sparkPop {
          from { opacity: 0; transform: scale(0) rotate(-15deg); }
          to   { opacity: 1; transform: scale(1) rotate(0deg); }
        }
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(16px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .login-input {
          width: 100%; height: 52px;
          border-radius: 9999px;
          border: 1.5px solid #E5E7EB;
          background: rgba(255,255,255,0.8);
          font-size: 0.9375rem;
          color: #111827;
          outline: none;
          transition: border-color 200ms, box-shadow 200ms;
          padding: 0 20px 0 46px;
          box-sizing: border-box;
          font-family: inherit;
        }
        .login-input::placeholder { color: #9CA3AF; }
        .login-input:focus {
          border-color: #0066FF;
          box-shadow: 0 0 0 4px rgba(0,102,255,0.10);
          background: #fff;
        }
        .login-input.error { border-color: #EF4444; box-shadow: 0 0 0 4px rgba(239,68,68,0.08); }
        .social-btn {
          width: 52px; height: 52px; border-radius: 50%;
          border: 1.5px solid #E5E7EB; background: rgba(255,255,255,0.8);
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; transition: transform 200ms, box-shadow 200ms;
        }
        .social-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.10); background: #fff; }
        .social-btn:active { transform: scale(0.95); }
        .spinner {
          width: 20px; height: 20px; border-radius: 50%;
          border: 2.5px solid rgba(255,255,255,0.35);
          border-top-color: white;
          animation: spin 700ms linear infinite;
        }
      `}</style>

      {/* Same gradient background as landing/schools/faq */}
      <div className="min-h-screen antialiased font-sans"
        style={{ background: 'linear-gradient(135deg, #EEF1F8 0%, #D1D5DB 50%, #E8EEFF 100%)' }}>

        {/* Nav — identical to other pages */}
        <nav className="px-6 py-4 flex items-center justify-between max-w-7xl mx-auto">
          <a href="/" className="flex items-center gap-2">
            <span className="text-xl font-black text-[#111827] tracking-tight">UNIFY</span>
            <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/20 text-[#0066FF]">GH</span>
          </a>
          <div className="hidden md:flex items-center gap-6">
            <a href="/schools" className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">Schools</a>
            <a href="/hubs" className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">Hubs</a>
            <a href="/match" className="text-sm font-semibold text-[#6B7280] hover:text-[#111827] transition-colors">Match</a>
          </div>
        </nav>

        {/* Centered form area */}
        <div className="flex flex-col items-center justify-center px-5 pt-6 pb-20">

          {/* Glass card — same style as FAQ card */}
          <div className="w-full relative overflow-hidden"
            style={{
              maxWidth: 420,
              borderRadius: 28,
              border: '1px solid rgba(255,255,255,0.75)',
              background: 'rgba(255,255,255,0.65)',
              backdropFilter: 'blur(20px)',
              WebkitBackdropFilter: 'blur(20px)',
              boxShadow: '0 8px 32px rgba(0,0,0,0.08), inset 0 1px 0 rgba(255,255,255,0.8)',
              padding: '40px 32px 36px',
            }}>

            <BlueSwirl />

            {/* Logo */}
            <div className="text-center mb-8 relative"
              style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) both' : 'none' }}>
              <div className="absolute -top-2 right-2">
                <BlueSpark />
              </div>
              <a href="/" className="inline-block">
                <span className="text-[2.25rem] font-black text-[#111827] tracking-tight leading-none">UNIFY</span>
              </a>
              <OrangeScribble width={86} />
              <p className="mt-3 text-[#6B7280] text-sm">
                {isSignup ? "Join Ghana's campus network" : 'Welcome back'}
              </p>
            </div>

            {done ? (
              <div className="text-center py-6"
                style={{ animation: 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) both' }}>
                <div className="text-5xl mb-3">🔥</div>
                <h3 className="text-xl font-black text-[#111827] mb-2">You're in!</h3>
                <p className="text-[#6B7280] text-sm">
                  {isSignup ? 'Welcome to UNIFY. Check your email to verify your account.' : 'Welcome back. Redirecting you now…'}
                </p>
              </div>
            ) : (
              <>
                {/* Toggle */}
                <div className="flex w-full h-12 rounded-full border border-[#E5E7EB] bg-white p-1 mb-7"
                  style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) 100ms both' : 'none' }}>
                  {['signup', 'login'].map(m => (
                    <button key={m} onClick={() => switchMode(m)}
                      className="flex-1 rounded-full text-sm font-bold transition-all duration-300"
                      style={{
                        background: mode === m ? '#0066FF' : 'transparent',
                        color: mode === m ? '#fff' : '#6B7280',
                        border: 'none', cursor: 'pointer',
                        boxShadow: mode === m ? '0 4px 14px rgba(0,102,255,0.30)' : 'none',
                        transition: 'background 300ms cubic-bezier(0.34,1.56,0.64,1), color 300ms, box-shadow 300ms',
                      }}>
                      {m === 'signup' ? 'Sign Up' : 'Log In'}
                    </button>
                  ))}
                </div>

                {/* Email */}
                <div className="relative"
                  style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) 180ms both' : 'none' }}>
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-[18px] h-[18px] text-[#9CA3AF] z-10"
                    style={{ top: emailError ? 26 : undefined }} />
                  <input type="email" placeholder="Your email address" value={email}
                    onChange={e => { setEmail(e.target.value); if (emailError) setEmailError(''); }}
                    className={`login-input${emailError ? ' error' : ''}`} />
                  {emailError && <p className="text-[#EF4444] text-xs mt-1.5 ml-4">{emailError}</p>}
                </div>

                {/* Password */}
                <div className="relative mt-3"
                  style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) 240ms both' : 'none' }}>
                  <Lock className="absolute left-4 top-[17px] w-[18px] h-[18px] text-[#9CA3AF] z-10" />
                  <input type={showPassword ? 'text' : 'password'}
                    placeholder={isSignup ? 'Create a password' : 'Your password'}
                    value={password}
                    onChange={e => { setPassword(e.target.value); if (passwordError) setPasswordError(''); }}
                    onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                    className={`login-input${passwordError ? ' error' : ''}`}
                    style={{ paddingRight: 48 }} />
                  <button type="button" onClick={() => setShowPassword(v => !v)}
                    className="absolute right-4 top-[17px] p-0 bg-transparent border-none cursor-pointer text-[#9CA3AF]"
                    aria-label={showPassword ? 'Hide password' : 'Show password'}>
                    {showPassword ? <EyeOff className="w-[18px] h-[18px]" /> : <Eye className="w-[18px] h-[18px]" />}
                  </button>
                  {passwordError && <p className="text-[#EF4444] text-xs mt-1.5 ml-4">{passwordError}</p>}
                </div>

                {!isSignup && (
                  <div className="text-right mt-2">
                    <a href="#" className="text-xs text-[#0066FF] font-semibold hover:text-[#0052CC]">Forgot password?</a>
                  </div>
                )}

                {/* CTA — same blue pill as landing page */}
                <div className="mt-6"
                  style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) 300ms both' : 'none' }}>
                  <button onClick={handleSubmit} disabled={loading}
                    className="w-full h-[52px] rounded-full font-black text-sm text-white border-none cursor-pointer flex flex-col items-center justify-center transition-all duration-200 disabled:opacity-70 disabled:cursor-not-allowed hover:-translate-y-0.5"
                    style={{
                      background: '#0066FF',
                      boxShadow: '0 4px 14px rgba(0,102,255,0.35)',
                    }}>
                    {loading
                      ? <div className="spinner" />
                      : <>
                          <span>{isSignup ? 'Create Account' : 'Log In'}</span>
                          <ButtonScribble />
                        </>
                    }
                  </button>
                </div>

                {/* Divider */}
                <div className="flex items-center gap-3 my-6"
                  style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) 360ms both' : 'none' }}>
                  <div className="flex-1 h-px bg-[#E5E7EB]" />
                  <span className="text-[11px] text-[#6B7280] uppercase tracking-widest whitespace-nowrap">
                    {isSignup ? 'or sign up with' : 'or log in with'}
                  </span>
                  <div className="flex-1 h-px bg-[#E5E7EB]" />
                </div>

                {/* Social buttons */}
                <div className="flex justify-center gap-4"
                  style={{ animation: mounted ? 'fadeUp 500ms cubic-bezier(0.16,1,0.3,1) 420ms both' : 'none' }}>
                  <button className="social-btn" aria-label="Sign in with Apple">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="#111827">
                      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                    </svg>
                  </button>
                  <button className="social-btn" aria-label="Sign in with Facebook">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none">
                      <circle cx="12" cy="12" r="10" stroke="#1877F2" strokeWidth="1.5"/>
                      <path d="M13.5 8.5h1.5V6.5h-1.5C11.6 6.5 10.5 7.6 10.5 9v1.5H9V12.5h1.5V18h2v-5.5h1.5l.5-2H12.5V9c0-.28.22-.5.5-.5h.5z" fill="#1877F2"/>
                    </svg>
                  </button>
                  <button className="social-btn" aria-label="Sign in with Google">
                    <svg viewBox="0 0 24 24" width="20" height="20">
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
          <div className="mt-6 text-center text-xs text-[#9CA3AF]">
            <a href="#" className="text-[#9CA3AF] no-underline hover:text-[#6B7280]">Terms of use</a>
            <span className="px-2">·</span>
            <a href="#" className="text-[#9CA3AF] no-underline hover:text-[#6B7280]">Privacy policy</a>
            <span className="px-2">·</span>
            <a href="#" className="text-[#9CA3AF] no-underline hover:text-[#6B7280]">Copyrights</a>
          </div>
        </div>
      </div>
    </>
  );
}
