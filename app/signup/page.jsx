'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';

const GCTU_SLUG = 'gctu';

export default function SignupPage() {
  const router = useRouter();
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const [name, setName]         = useState('');
  const [status, setStatus]     = useState('idle');
  const [error, setError]       = useState('');

  async function handleSignup(e) {
    e.preventDefault();
    setError('');
    if (!name.trim() || !email.trim() || password.length < 6) {
      setError('Fill in all fields. Password must be at least 6 characters.');
      return;
    }
    setStatus('loading');
    const supabase = createClient();

    // 1. Create auth account
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: name } },
    });
    if (authError) { setError(authError.message); setStatus('idle'); return; }

    // 2. Fetch GCTU university id
    const { data: uni } = await supabase
      .from('universities')
      .select('id')
      .eq('slug', GCTU_SLUG)
      .single();

    // 3. Create profile row
    await supabase.from('profiles').insert({
      id: authData.user.id,
      university_id: uni.id,
      full_name: name,
      role: 'student',
    });

    setStatus('success');
    router.push('/onboarding');
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div className="w-full max-w-sm bg-white rounded-2xl border border-gray-100 shadow-sm p-8">
        {/* Logo */}
        <div className="flex items-center gap-2 mb-8">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/logo-icon.png" alt="UNIFY" width={32} height={32} className="rounded-xl" />
          <span className="font-bold text-lg text-gray-900" style={{ letterSpacing: '-0.02em' }}>UNIFY</span>
        </div>

        <h1 className="font-bold text-2xl text-gray-900 mb-1" style={{ letterSpacing: '-0.02em' }}>Create your account</h1>
        <p className="text-gray-500 text-sm mb-6">GCTU students only · Free forever</p>

        <form onSubmit={handleSignup} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Full name</label>
            <input
              type="text" value={name} onChange={(e) => setName(e.target.value)}
              placeholder="Your full name"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Email address</label>
            <input
              type="email" value={email} onChange={(e) => setEmail(e.target.value)}
              placeholder="you@gctu.edu.gh"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Password</label>
            <input
              type="password" value={password} onChange={(e) => setPassword(e.target.value)}
              placeholder="At least 6 characters"
              className="w-full h-11 px-4 rounded-xl border border-gray-200 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-[#003F8A] focus:ring-2 focus:ring-blue-100 transition-all"
            />
          </div>

          {error && <p className="text-red-500 text-xs">{error}</p>}

          <button
            type="submit" disabled={status === 'loading'}
            className="h-11 bg-[#003F8A] text-white font-semibold rounded-xl text-sm hover:bg-[#002d6b] active:scale-95 transition-all disabled:opacity-50"
          >
            {status === 'loading' ? 'Creating account…' : 'Create Account'}
          </button>
        </form>

        <p className="text-center text-xs text-gray-400 mt-6">
          Already have an account?{' '}
          <Link href="/login" className="text-[#003F8A] font-semibold hover:underline">Sign in</Link>
        </p>
      </div>
    </div>
  );
}
