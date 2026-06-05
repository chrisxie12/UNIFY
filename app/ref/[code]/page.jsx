'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect } from 'react';

const SHEET_URL =
  'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

const SCHOOLS = [
  { id: 'knust',  label: 'KNUST'  },
  { id: 'ug',    label: 'UG Legon' },
  { id: 'ucc',   label: 'UCC'    },
  { id: 'upsa',  label: 'UPSA'   },
  { id: 'uds',   label: 'UDS'    },
  { id: 'gctu',  label: 'GCTU'   },
];

export default function RefPage({ params }) {
  const code = params?.code ?? '';

  const [school, setSchool]     = useState('');
  const [phone, setPhone]       = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted]   = useState(false);
  const [myCode, setMyCode]         = useState('');
  const [copied, setCopied]         = useState(false);

  useEffect(() => {
    setMyCode(Math.random().toString(36).slice(2, 8));
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!school || !phone) return;
    setSubmitting(true);
    try {
      await fetch(
        `${SHEET_URL}?action=join&phone=${encodeURIComponent(phone)}&school=${encodeURIComponent(school)}&ref=${encodeURIComponent(code)}`,
        { mode: 'no-cors' }
      );
    } catch (_) {
      // no-cors will always "fail" silently — treat as success
    }
    setSubmitting(false);
    setSubmitted(true);
  }

  function handleCopy() {
    const link = `https://unify-lake.vercel.app/ref/${myCode}`;
    navigator.clipboard.writeText(link).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  return (
    <main
      className="relative min-h-screen flex items-center justify-center px-4 py-12 overflow-hidden"
      style={{ backgroundColor: '#050d20', color: '#fff' }}
    >
      {/* Background gradient blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
        <div style={{ position:'absolute', top:'-20%', right:'-10%', width:'600px', height:'600px', background:'radial-gradient(circle, rgba(251,191,36,0.08) 0%, transparent 70%)', borderRadius:'50%' }} />
        <div style={{ position:'absolute', bottom:'-10%', left:'-10%', width:'500px', height:'500px', background:'radial-gradient(circle, rgba(59,130,246,0.07) 0%, transparent 70%)', borderRadius:'50%' }} />
        <div style={{ position:'absolute', top:'40%', left:'40%', width:'400px', height:'400px', background:'radial-gradient(circle, rgba(16,185,129,0.05) 0%, transparent 70%)', borderRadius:'50%' }} />
      </div>

      <div className="relative z-10 w-full max-w-lg mx-auto">
        {/* Logo */}
        <div className="flex items-center gap-2 mb-6">
          <span className="text-2xl font-black tracking-tight text-amber-400">
            UNIFY
          </span>
          <span
            className="text-xs font-bold px-2 py-0.5 rounded-full border border-amber-400/40 text-amber-400"
            style={{ background: 'rgba(251,191,36,0.1)' }}
          >
            GH
          </span>
        </div>

        {/* Ghana flag stripe */}
        <div
          className="w-full h-1 rounded-full mb-8"
          style={{
            background: 'linear-gradient(to right, #CE1126, #FCD116, #006B3F)',
          }}
        />

        {!submitted ? (
          <>
            {/* Hero */}
            <div className="mb-8 text-center">
              <div className="text-5xl mb-4">🎉</div>
              <h1 className="text-3xl font-black mb-3 leading-tight">
                You've been invited!
              </h1>
              <p className="text-slate-300 text-base leading-relaxed">
                Your friend is already on the UNIFY waitlist. Join them and connect
                before campus chaos starts.
              </p>
            </div>

            {/* Referral badge */}
            <div className="flex justify-center mb-8">
              <span
                className="text-xs px-3 py-1.5 rounded-full border border-amber-400/40 text-amber-400"
                style={{ background: 'rgba(251,191,36,0.08)' }}
              >
                Invited via UNIFY referral · Code:{' '}
                <span className="font-mono font-bold">{code}</span>
              </span>
            </div>

            {/* Social proof */}
            <div className="text-center text-sm text-slate-400 mb-8">
              <span className="text-amber-400 font-semibold">847</span> freshers
              already joined
            </div>

            {/* Form */}
            <form
              onSubmit={handleSubmit}
              className="rounded-2xl border border-white/10 p-6"
              style={{ background: 'rgba(255,255,255,0.06)', backdropFilter: 'blur(4px)' }}
            >
              <p className="text-sm font-semibold text-slate-300 mb-3">
                Pick your school
              </p>
              <div className="flex flex-wrap gap-2 mb-6">
                {SCHOOLS.map((s) => (
                  <button
                    key={s.id}
                    type="button"
                    onClick={() => setSchool(s.id)}
                    className="px-3 py-1.5 rounded-full text-sm font-semibold border transition-all duration-150"
                    style={
                      school === s.id
                        ? {
                            background: '#FBBF24',
                            color: '#050d20',
                            borderColor: '#FBBF24',
                          }
                        : {
                            background: 'rgba(255,255,255,0.05)',
                            color: '#94a3b8',
                            borderColor: 'rgba(255,255,255,0.1)',
                          }
                    }
                  >
                    {s.label}
                  </button>
                ))}
              </div>

              <p className="text-sm font-semibold text-slate-300 mb-2">
                Phone number
              </p>
              <div className="flex items-center border border-white/15 rounded-xl overflow-hidden mb-6"
                   style={{ background: 'rgba(255,255,255,0.05)' }}>
                <span className="px-3 py-3 text-slate-400 text-sm border-r border-white/10 flex items-center gap-1.5 shrink-0">
                  🇬🇭 +233
                </span>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="24 000 0000"
                  required
                  className="flex-1 bg-transparent px-3 py-3 text-white placeholder-slate-500 text-sm outline-none"
                />
              </div>

              <button
                type="submit"
                disabled={submitting || !school || !phone}
                className="w-full py-3 rounded-xl font-bold text-sm transition-all duration-150 disabled:opacity-50 disabled:cursor-not-allowed"
                style={{
                  background: submitting || !school || !phone ? '#7a6010' : '#FBBF24',
                  color: '#050d20',
                }}
              >
                {submitting ? 'Joining…' : 'Join the Waitlist →'}
              </button>
            </form>
          </>
        ) : (
          /* Success state */
          <div className="text-center py-8">
            {/* Animated checkmark */}
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6"
              style={{ background: 'rgba(52,211,153,0.15)', border: '2px solid rgba(52,211,153,0.4)' }}
            >
              <svg
                className="w-10 h-10"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#34d399"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
                style={{ animation: 'checkPop 0.4s ease-out' }}
              >
                <polyline points="20 6 9 17 4 12" />
              </svg>
            </div>

            <h2 className="text-2xl font-black mb-2">You're on the list!</h2>
            <p className="text-slate-400 text-sm mb-8 leading-relaxed">
              Share your own link to move up and get early access.
            </p>

            {/* Referral link copy box */}
            <div
              className="rounded-xl border border-white/10 p-4 mb-4"
              style={{ background: 'rgba(255,255,255,0.06)', backdropFilter: 'blur(4px)' }}
            >
              <p className="text-xs text-slate-400 mb-2 font-medium">
                Your referral link
              </p>
              <div className="flex items-center gap-2">
                <span className="flex-1 text-xs text-amber-400 font-mono truncate text-left">
                  https://unify-lake.vercel.app/ref/{myCode}
                </span>
                <button
                  onClick={handleCopy}
                  className="shrink-0 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all duration-150"
                  style={{
                    background: copied ? 'rgba(52,211,153,0.2)' : 'rgba(251,191,36,0.15)',
                    color: copied ? '#34d399' : '#FBBF24',
                    border: copied ? '1px solid rgba(52,211,153,0.4)' : '1px solid rgba(251,191,36,0.3)',
                  }}
                >
                  {copied ? 'Copied!' : 'Copy'}
                </button>
              </div>
            </div>

            <a
              href="/"
              className="inline-block text-sm text-slate-400 hover:text-white transition-colors"
            >
              ← Back to UNIFY
            </a>
          </div>
        )}
      </div>

      <style>{`
        @keyframes checkPop {
          0%   { transform: scale(0.5); opacity: 0; }
          70%  { transform: scale(1.15); opacity: 1; }
          100% { transform: scale(1); }
        }
      `}</style>
    </main>
  );
}
