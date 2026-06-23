'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

const LEVELS = ['100','200','300','400','PG','Staff'];
const PROGRAMMES = [
  'BSc Computer Science','BSc Information Technology','BSc Telecommunications Engineering',
  'BSc Computer Engineering','BSc Cybersecurity','BSc Data Science',
  'BEng Electrical & Electronics','BSc Business Information Systems',
  'MBA Information Technology','MSc Computer Science','Other',
];

export default function OnboardingPage() {
  const router = useRouter();
  const [studentId, setStudentId]   = useState('');
  const [programme, setProgramme]   = useState('');
  const [level, setLevel]           = useState('');
  const [phone, setPhone]           = useState('');
  const [status, setStatus]         = useState('idle');
  const [error, setError]           = useState('');

  async function handleSave(e) {
    e.preventDefault();
    setError('');
    if (!studentId.trim() || !programme || !level) {
      setError('Student ID, programme, and level are required.');
      return;
    }
    setStatus('loading');
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { router.push('/login'); return; }

    const { error: updateError } = await supabase
      .from('profiles')
      .update({ student_id: studentId.trim(), programme, level: level.toLowerCase(), phone })
      .eq('id', user.id);

    if (updateError) { setError(updateError.message); setStatus('idle'); return; }

    // Assign beta badge, add to beta_testers, send welcome notifications
    await supabase.rpc('handle_onboarding_complete', { p_user_id: user.id });
    router.push('/feed');
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md bg-white rounded-2xl border border-gray-100 shadow-sm p-8">
        <div className="flex items-center gap-2 mb-8">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/logo-icon.png" alt="UNIFY" width={32} height={32} className="rounded-xl" />
          <span className="font-bold text-lg text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
        </div>

        <h1 className="font-bold text-2xl text-gray-900 mb-1" style={{ letterSpacing: '-0.02em' }}>Complete your profile</h1>
        <p className="text-gray-500 text-sm mb-6">We need a few details to verify your student identity.</p>

        <form onSubmit={handleSave} className="flex flex-col gap-5">
          {/* Student ID */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Student ID / Index number</label>
            <input
              type="text" value={studentId} onChange={(e) => setStudentId(e.target.value)}
              placeholder="e.g. GCTU/CS/2024/001"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>

          {/* Programme */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Programme</label>
            <select
              value={programme} onChange={(e) => setProgramme(e.target.value)}
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all bg-white"
            >
              <option value="">Select your programme</option>
              {PROGRAMMES.map((p) => <option key={p} value={p}>{p}</option>)}
            </select>
          </div>

          {/* Level */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-2">Year / Level</label>
            <div className="flex flex-wrap gap-2">
              {LEVELS.map((l) => (
                <button
                  key={l} type="button" onClick={() => setLevel(l)}
                  className={`px-4 py-2 rounded-xl text-sm font-semibold border transition-all ${
                    level === l
                      ? 'bg-[#003F8A] text-white border-[#003F8A]'
                      : 'bg-white text-gray-600 border-gray-200 hover:border-[#003F8A]'
                  }`}
                >
                  {l === 'PG' ? 'Postgrad' : l === 'Staff' ? 'Staff' : `Level ${l}`}
                </button>
              ))}
            </div>
          </div>

          {/* Phone (optional) */}
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">
              Phone <span className="text-gray-400 font-normal">(optional)</span>
            </label>
            <input
              type="tel" value={phone} onChange={(e) => setPhone(e.target.value)}
              placeholder="0XX XXX XXXX"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>

          {error && <p className="text-red-500 text-xs">{error}</p>}

          <button
            type="submit" disabled={status === 'loading'}
            className="h-11 bg-[#003F8A] text-white font-semibold rounded-xl text-sm hover:bg-[#002d6b] active:scale-95 transition-all disabled:opacity-50"
          >
            {status === 'loading' ? 'Saving…' : 'Save & Continue'}
          </button>
        </form>
      </div>
    </div>
  );
}
