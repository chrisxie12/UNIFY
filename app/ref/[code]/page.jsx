'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect } from 'react';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

const SCHOOLS = [
  { id: 'knust', label: 'KNUST' },
  { id: 'ug',   label: 'UG Legon' },
  { id: 'ucc',  label: 'UCC' },
  { id: 'upsa', label: 'UPSA' },
  { id: 'uds',  label: 'UDS' },
  { id: 'gctu', label: 'GCTU' },
];

export default function RefPage({ params }) {
  const code = params?.code ?? '';
  const [school, setSchool]     = useState('');
  const [phone, setPhone]       = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted]   = useState(false);
  const [myCode, setMyCode]         = useState('');
  const [copied, setCopied]         = useState(false);

  useEffect(() => { setMyCode(Math.random().toString(36).slice(2, 8)); }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!school || !phone) return;
    setSubmitting(true);
    try {
      await fetch(`${SHEET_URL}?action=join&phone=${encodeURIComponent(phone)}&school=${encodeURIComponent(school)}&ref=${encodeURIComponent(code)}`, { mode: 'no-cors' });
    } catch (_) {}
    setSubmitting(false);
    setSubmitted(true);
  }

  function handleCopy() {
    navigator.clipboard.writeText(`https://unify-lake.vercel.app/ref/${myCode}`).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  return (
    <main className="relative min-h-screen flex items-center justify-center p-6"
          style={{ background: '#0F0E17' }}>

      <style>{`
        @keyframes checkPop {
          0%   { transform: scale(0.5); opacity: 0; }
          70%  { transform: scale(1.15); opacity: 1; }
          100% { transform: scale(1); }
        }
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(28px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes slideRight {
          from { opacity: 0; transform: translateX(-20px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes scaleIn {
          from { opacity: 0; transform: scale(0.93); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes glowPulse {
          0%, 100% { box-shadow: 0 0 20px rgba(0,102,255,0.15); }
          50%       { box-shadow: 0 0 40px rgba(0,102,255,0.30); }
        }
        @keyframes floatBadge {
          0%, 100% { transform: translateY(0px); }
          50%       { transform: translateY(-6px); }
        }
        .anim-fade-up    { animation: fadeUp 0.6s ease-out both; }
        .anim-slide-right { animation: slideRight 0.6s ease-out both; }
        .anim-scale-in   { animation: scaleIn 0.5s ease-out both; }
        .anim-glow       { animation: glowPulse 3s ease-in-out infinite; }
        .anim-float      { animation: floatBadge 4s ease-in-out infinite; }
        .delay-100 { animation-delay: 0.1s; }
        .delay-200 { animation-delay: 0.2s; }
        .delay-300 { animation-delay: 0.3s; }
        .delay-400 { animation-delay: 0.4s; }
        .delay-500 { animation-delay: 0.5s; }
      `}</style>

      {/* Fixed ambient blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
        <div className="absolute -top-1/4 -right-1/4 w-[700px] h-[700px] rounded-full bg-[#7B2FBE]/[0.10] blur-[120px]" />
        <div className="absolute -bottom-1/4 -left-1/4 w-[600px] h-[600px] rounded-full bg-[#00F5D4]/[0.05] blur-[100px]" />
        <div className="absolute top-1/3 left-1/3 w-[400px] h-[400px] rounded-full bg-amber-400/[0.04] blur-[80px]" />
      </div>

      <div className="anim-scale-in w-full max-w-lg mx-auto bg-[#1A1827] border border-white/10 shadow-[0_40px_100px_rgba(123,47,190,0.20)] rounded-[32px] overflow-hidden">
        {/* Gradient top bar */}
        <div className="h-1.5 bg-gradient-to-r from-[#7B2FBE] via-amber-400 to-[#00F5D4]" />

        <div className="p-8">
          {/* Logo */}
          <div className="anim-fade-up flex items-center gap-2 mb-6">
            <span className="text-xl font-black tracking-tight text-white">UNIFY</span>
            <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-amber-400/10 border border-amber-400/25 text-amber-400">GH</span>
          </div>

          {/* Ghana flag stripe */}
          <div className="w-full h-1 rounded-full mb-8 bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />

          {!submitted ? (
            <>
              <div className="mb-8 text-center">
                <div className="anim-fade-up text-5xl mb-4">🎉</div>
                <h1 className="anim-fade-up delay-100 text-3xl font-black text-white mb-3 leading-tight">You&apos;ve been invited!</h1>
                <p className="anim-fade-up delay-200 text-white/60 text-base leading-relaxed">
                  Your friend is already on the UNIFY waitlist. Join them and connect before campus chaos starts.
                </p>
              </div>

              {/* Referral badge */}
              <div className="anim-float flex justify-center mb-6">
                <span className="text-xs px-3 py-1.5 rounded-full bg-white/5 border border-white/10 text-[#00F5D4]">
                  Invited via UNIFY referral · Code: <span className="font-mono font-bold">{code}</span>
                </span>
              </div>

              {/* Social proof */}
              <p className="anim-fade-up delay-300 text-center text-sm text-white/60 mb-8">
                <span className="text-[#00F5D4] font-bold">847</span> freshers already joined
              </p>

              {/* Form */}
              <div className="anim-fade-up delay-400 bg-white/5 border border-white/10 rounded-2xl p-6">
                <p className="text-sm font-semibold text-white mb-3">Pick your school</p>
                <div className="flex flex-wrap gap-2 mb-6">
                  {SCHOOLS.map((s) => (
                    <button
                      key={s.id}
                      type="button"
                      onClick={() => setSchool(s.id)}
                      className={`px-3 py-1.5 rounded-full text-sm font-semibold border transition-all ${
                        school === s.id
                          ? 'bg-[#7B2FBE] border-[#7B2FBE] text-white'
                          : 'bg-white/5 border-white/10 text-white/60 hover:border-[#7B2FBE]/40 hover:text-purple-300'
                      }`}
                    >
                      {s.label}
                    </button>
                  ))}
                </div>

                <p className="text-sm font-semibold text-white mb-2">Phone number</p>
                <div className="flex items-center bg-white/5 border border-white/10 rounded-xl overflow-hidden mb-5 focus-within:border-[#7B2FBE]/60 focus-within:ring-2 focus-within:ring-[#7B2FBE]/10 transition-all">
                  <span className="px-3 py-3 text-white/40 text-sm border-r border-white/10 flex items-center gap-1.5 shrink-0">🇬🇭 +233</span>
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="24 000 0000"
                    required
                    className="flex-1 bg-transparent px-3 py-3 text-white placeholder-white/30 text-sm outline-none"
                  />
                </div>

                <button
                  onClick={handleSubmit}
                  disabled={submitting || !school || !phone}
                  className="w-full py-3 rounded-full font-black text-sm bg-[#7B2FBE] text-white hover:bg-[#6A1FA8] transition-all hover:-translate-y-0.5 disabled:opacity-40 disabled:cursor-not-allowed disabled:translate-y-0 shadow-[0_4px_14px_rgba(123,47,190,0.4)] hover:shadow-[0_8px_24px_rgba(123,47,190,0.5)]"
                >
                  {submitting ? 'Joining…' : 'Join the Waitlist →'}
                </button>
              </div>
            </>
          ) : (
            <div className="text-center py-8">
              <div className="w-20 h-20 rounded-full bg-white/70 backdrop-blur-sm border border-green-200/70 flex items-center justify-center mx-auto mb-6">
                <svg className="w-10 h-10" viewBox="0 0 24 24" fill="none" stroke="#16a34a" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" style={{ animation: 'checkPop 0.4s ease-out' }}>
                  <polyline points="20 6 9 17 4 12" />
                </svg>
              </div>

              <h2 className="anim-fade-up text-2xl font-black text-white mb-2">You&apos;re on the list!</h2>
              <p className="anim-fade-up delay-100 text-white/60 text-sm mb-8 leading-relaxed">Share your own link to move up and get early access.</p>

              <div className="anim-fade-up delay-200 bg-white/5 border border-white/10 rounded-2xl p-4 mb-6">
                <p className="text-xs text-white/40 mb-2 font-medium text-left">Your referral link</p>
                <div className="flex items-center gap-2">
                  <span className="flex-1 text-xs text-[#00F5D4] font-mono truncate text-left">
                    https://unify-lake.vercel.app/ref/{myCode}
                  </span>
                  <button
                    onClick={handleCopy}
                    className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${
                      copied
                        ? 'bg-[#00F5D4]/10 border-[#00F5D4]/30 text-[#00F5D4]'
                        : 'bg-white/5 border-white/10 text-white/60 hover:border-[#7B2FBE]/40 hover:text-purple-300'
                    }`}
                  >
                    {copied ? 'Copied!' : 'Copy'}
                  </button>
                </div>
              </div>

              <a href="/" className="inline-block text-sm text-white/50 hover:text-white transition-colors">← Back to UNIFY</a>
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
