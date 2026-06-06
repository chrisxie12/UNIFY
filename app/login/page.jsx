'use client';

import { useState, useEffect } from 'react';
import { Mail, Lock, Eye, EyeOff } from 'lucide-react';

function OrangeScribble({ width = 80 }) {
  return (
    <svg width={width} height="10" viewBox={`0 0 ${width} 10`} fill="none" aria-hidden="true"
      style={{ display: 'block', margin: '4px auto 0' }}>
      <path
        d={`M2,6 C${width*0.12},2 ${width*0.25},9 ${width*0.38},5 C${width*0.5},1 ${width*0.63},9 ${width*0.75},5 C${width*0.87},1 ${width*0.94},7 ${width-2},5`}
        stroke="#FF6B35" strokeWidth="2.5" strokeLinecap="round" fill="none"
        style={{
          strokeDasharray: width * 1.4,
          strokeDashoffset: 0,
          animation: 'scribbleDraw 500ms cubic-bezier(0.16,1,0.3,1) 600ms both',
        }}
      />
    </svg>
  );
}

function ButtonScribble() {
  return (
    <svg width="60" height="8" viewBox="0 0 60 8" fill="none" aria-hidden="true"
      style={{ display: 'block', margin: '3px auto 0' }}>
      <path d="M2,5 C8,1 15,8 22,4 C29,0 36,8 43,4 C50,0 55,6 58,4"
        stroke="#FF6B35" strokeWidth="2" strokeLinecap="round" fill="none" />
    </svg>
  );
}

function BlueSpark() {
  return (
    <svg width="32" height="32" viewBox="0 0 32 32" fill="none" aria-hidden="true"
      style={{ animation: 'sparkPop 400ms cubic-bezier(0.34,1.56,0.64,1) 700ms both' }}>
      <line x1="16" y1="2"  x2="16" y2="10" stroke="#0066FF" strokeWidth="2.5" strokeLinecap="round"/>
      <line x1="24" y1="8"  x2="20" y2="12" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
      <line x1="28" y1="16" x2="22" y2="16" stroke="#0066FF" strokeWidth="2"   strokeLinecap="round"/>
    </svg>
  );
}

function OrangeRadiate() {
  return (
    <svg width="28" height="28" viewBox="0 0 28 28" fill="none" aria-hidden="true">
      <line x1="14" y1="2"  x2="14" y2="9"  stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="24" y1="6"  x2="20" y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
      <line x1="5"  y1="6"  x2="9"  y2="10" stroke="#FF6B35" strokeWidth="2" strokeLinecap="round"/>
    </svg>
  );
}

function BlueSwirl() {
  return (
    <svg width="120" height="160" viewBox="0 0 120 160" fill="none" aria-hidden="true"
      style={{ position: 'absolute', bottom: -20, right: -20, opacity: 0.5, pointerEvents: 'none' }}>
      <path
        d="M100,10 C140,40 60,70 90,100 C120,130 40,145 70,155"
        stroke="#0066FF" strokeWidth="1.5" strokeLinecap="round" fill="none"
        style={{
          strokeDasharray: 300,
          strokeDashoffset: 0,
          animation: 'swirlDraw 800ms ease-out 1200ms both',
        }}
      />
      <path
        d="M80,20 C110,50 50,75 80,100 C105,120 55,140 75,155"
        stroke="#0066FF" strokeWidth="1" strokeLinecap="round" fill="none" opacity="0.5"
        style={{
          strokeDasharray: 260,
          strokeDashoffset: 0,
          animation: 'swirlDraw 800ms ease-out 1400ms both',
        }}
      />
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
    if (!v) return 'Please enter a valid email address.';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) return 'Please enter a valid email address.';
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
    console.log('[UNIFY Auth]', { mode, email, ts: new Date().toISOString() });
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
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(20px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes scaleIn {
          from { opacity: 0; transform: scale(0.85); }
          to   { opacity: 1; transform: scale(1); }
        }
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
        .login-input {
          width: 100%;
          height: 56px;
          border-radius: 9999px;
          border: 1.5px solid #E5E7EB;
          background: #fff;
          font-size: 1rem;
          color: #111827;
          outline: none;
          transition: border-color 200ms, box-shadow 200ms;
          padding: 0 20px 0 48px;
          box-sizing: border-box;
        }
        .login-input::placeholder { color: #9CA3AF; }
        .login-input:focus {
          border-color: #0066FF;
          box-shadow: 0 0 0 4px rgba(0,102,255,0.10);
        }
        .login-input.error {
          border-color: #EF4444;
          box-shadow: 0 0 0 4px rgba(239,68,68,0.08);
        }
        .social-btn {
          width: 56px; height: 56px; border-radius: 50%;
          border: 1.5px solid #E5E7EB; background: white;
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; transition: transform 200ms, box-shadow 200ms;
          flex-shrink: 0;
        }
        .social-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .social-btn:active { transform: scale(0.95); }
        .primary-btn {
          width: 100%; height: 56px; border-radius: 9999px;
          background: #1F2937; color: white;
          font-weight: 700; font-size: 1rem;
          border: none; cursor: pointer;
          transition: transform 200ms, box-shadow 200ms;
          display: flex; flex-direction: column; align-items: center; justify-content: center;
        }
        .primary-btn:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(31,41,55,0.35); }
        .primary-btn:active:not(:disabled) { transform: scale(0.98); }
        .primary-btn:disabled { opacity: 0.7; cursor: not-allowed; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .spinner {
          width: 20px; height: 20px; border-radius: 50%;
          border: 2.5px solid rgba(255,255,255,0.3);
          border-top-color: white;
          animation: spin 700ms linear infinite;
        }
      `}</style>

      {/* Page background */}
      <div style={{
        minHeight: '100vh',
        background: '#FFFFFF',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '32px 20px',
        fontFamily: 'system-ui, -apple-system, sans-serif',
      }}>
        {/* Back link */}
        <div style={{ width: '100%', maxWidth: 420, marginBottom: 16 }}>
          <a href="/" style={{ color: '#9CA3AF', fontSize: '0.875rem', textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            ← Back
          </a>
        </div>

        {/* Form card */}
        <div style={{
          width: '100%',
          maxWidth: 420,
          background: '#ffffff',
          borderRadius: 24,
          boxShadow: '0 4px 24px rgba(0,0,0,0.07)',
          padding: '40px 32px 36px',
          position: 'relative',
          overflow: 'hidden',
        }}>
          {/* Logo */}
          <div style={{
            textAlign: 'center',
            marginBottom: 36,
            animation: mounted ? 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) both' : 'none',
            position: 'relative',
          }}>
            <div style={{ position: 'absolute', top: -8, right: 0 }}>
              <BlueSpark />
            </div>
            <a href="/" style={{ textDecoration: 'none' }}>
              <h1 style={{ fontSize: '2.25rem', fontWeight: 900, color: '#111827', letterSpacing: '-0.03em', margin: 0, lineHeight: 1 }}>
                UNIFY
              </h1>
            </a>
            <OrangeScribble width={90} />
            <p style={{ marginTop: 12, color: '#6B7280', fontSize: '0.9rem' }}>
              {isSignup ? "Join Ghana's campus network" : 'Welcome back'}
            </p>
          </div>

          {done ? (
            <div style={{
              textAlign: 'center',
              padding: '24px 0',
              animation: 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) both',
            }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>🔥</div>
              <h3 style={{ fontSize: 22, fontWeight: 800, color: '#111827', margin: '0 0 8px' }}>You&apos;re in!</h3>
              <p style={{ color: '#6B7280', fontSize: 15, margin: 0 }}>
                {isSignup ? 'Welcome to UNIFY. Check your email to verify your account.' : 'Welcome back. Redirecting you now…'}
              </p>
            </div>
          ) : (
            <>
              {/* Toggle */}
              <div style={{
                display: 'flex',
                width: '100%',
                height: 48,
                background: '#FFFFFF',
                border: '1.5px solid #E5E7EB',
                borderRadius: 9999,
                padding: 4,
                marginBottom: 28,
                animation: mounted ? 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) 150ms both' : 'none',
              }}>
                {['signup', 'login'].map((m) => (
                  <button
                    key={m}
                    onClick={() => switchMode(m)}
                    style={{
                      flex: 1, borderRadius: 9999, border: 'none', cursor: 'pointer',
                      fontWeight: mode === m ? 700 : 500,
                      fontSize: '0.875rem',
                      background: mode === m ? '#1F2937' : 'transparent',
                      color: mode === m ? '#fff' : '#6B7280',
                      transition: 'background 300ms cubic-bezier(0.34,1.56,0.64,1), color 300ms',
                    }}
                  >
                    {m === 'signup' ? 'Sign Up' : 'Log In'}
                  </button>
                ))}
              </div>

              {/* Email input */}
              <div style={{ position: 'relative', animation: mounted ? 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) 250ms both' : 'none' }}>
                <div style={{ position: 'absolute', left: -4, top: '50%', transform: 'translateY(-50%)', zIndex: 0, marginTop: emailError ? -12 : 0 }}>
                  <OrangeRadiate />
                </div>
                <div style={{ position: 'relative' }}>
                  <Mail style={{ position: 'absolute', left: 18, top: '50%', transform: 'translateY(-50%)', color: '#9CA3AF', width: 20, height: 20, zIndex: 1 }} />
                  <input
                    type="email"
                    placeholder="Your email address"
                    value={email}
                    onChange={e => { setEmail(e.target.value); if (emailError) setEmailError(''); }}
                    className={`login-input${emailError ? ' error' : ''}`}
                  />
                </div>
                {emailError && <p style={{ color: '#EF4444', fontSize: '0.8rem', marginTop: 6, marginLeft: 16 }}>{emailError}</p>}
              </div>

              {/* Password input */}
              <div style={{ marginTop: 14, position: 'relative', animation: mounted ? 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) 330ms both' : 'none' }}>
                <Lock style={{ position: 'absolute', left: 18, top: 18, color: '#9CA3AF', width: 20, height: 20, zIndex: 1 }} />
                <input
                  type={showPassword ? 'text' : 'password'}
                  placeholder={isSignup ? 'Create a password' : 'Your password'}
                  value={password}
                  onChange={e => { setPassword(e.target.value); if (passwordError) setPasswordError(''); }}
                  onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                  className={`login-input${passwordError ? ' error' : ''}`}
                  style={{ paddingRight: 48 }}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(v => !v)}
                  style={{ position: 'absolute', right: 18, top: 18, background: 'none', border: 'none', cursor: 'pointer', padding: 0, color: '#9CA3AF' }}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff style={{ width: 20, height: 20 }} /> : <Eye style={{ width: 20, height: 20 }} />}
                </button>
                {passwordError && <p style={{ color: '#EF4444', fontSize: '0.8rem', marginTop: 6, marginLeft: 16 }}>{passwordError}</p>}
              </div>

              {/* Forgot password */}
              {!isSignup && (
                <div style={{ textAlign: 'right', marginTop: 8 }}>
                  <a href="#" style={{ fontSize: '0.8rem', color: '#0066FF', textDecoration: 'none' }}>Forgot password?</a>
                </div>
              )}

              {/* CTA */}
              <div style={{ marginTop: 24, animation: mounted ? 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) 400ms both' : 'none' }}>
                <button onClick={handleSubmit} disabled={loading} className="primary-btn">
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
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '28px 0', animation: mounted ? 'fadeUp 600ms cubic-bezier(0.16,1,0.3,1) 450ms both' : 'none' }}>
                <div style={{ flex: 1, height: 1, background: '#E5E7EB' }} />
                <span style={{ fontSize: '0.72rem', color: '#6B7280', textTransform: 'uppercase', letterSpacing: '0.06em', whiteSpace: 'nowrap' }}>
                  {isSignup ? 'or sign up with' : 'or log in with'}
                </span>
                <div style={{ flex: 1, height: 1, background: '#E5E7EB' }} />
              </div>

              {/* Social buttons */}
              <div style={{ display: 'flex', justifyContent: 'center', gap: 20, animation: mounted ? 'scaleIn 500ms cubic-bezier(0.16,1,0.3,1) 500ms both' : 'none' }}>
                <button className="social-btn" aria-label="Sign in with Apple" onClick={() => console.log('Apple login')}>
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="#111827">
                    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                  </svg>
                </button>
                <button className="social-btn" aria-label="Sign in with Facebook" onClick={() => console.log('Facebook login')}>
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="none">
                    <circle cx="12" cy="12" r="10" stroke="#1877F2" strokeWidth="1.5"/>
                    <path d="M13.5 8.5h1.5V6.5h-1.5C11.6 6.5 10.5 7.6 10.5 9v1.5H9V12.5h1.5V18h2v-5.5h1.5l.5-2H12.5V9c0-.28.22-.5.5-.5h.5z" fill="#1877F2"/>
                  </svg>
                </button>
                <button className="social-btn" aria-label="Sign in with Google" onClick={() => console.log('Google login')}>
                  <svg viewBox="0 0 24 24" width="22" height="22">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                  </svg>
                </button>
              </div>
            </>
          )}

          {/* Blue swirl decoration */}
          <BlueSwirl />
        </div>

        {/* Footer links */}
        <div style={{ marginTop: 24, textAlign: 'center', fontSize: '0.75rem', color: '#9CA3AF' }}>
          <a href="#" style={{ color: '#9CA3AF', textDecoration: 'none' }}>Terms of use</a>
          <span style={{ padding: '0 8px' }}>·</span>
          <a href="#" style={{ color: '#9CA3AF', textDecoration: 'none' }}>Privacy policy</a>
          <span style={{ padding: '0 8px' }}>·</span>
          <a href="#" style={{ color: '#9CA3AF', textDecoration: 'none' }}>Copyrights</a>
        </div>
      </div>
    </>
  );
}
