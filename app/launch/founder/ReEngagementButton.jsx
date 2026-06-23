'use client';

import { useState } from 'react';
import { createBrowserClient } from '@supabase/ssr';

export default function ReEngagementButton({ dormantCount }) {
  const [status, setStatus] = useState('idle'); // idle | loading | done | error
  const [sent, setSent] = useState(null);

  async function handleSend() {
    if (status === 'loading') return;
    setStatus('loading');
    try {
      const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
      );
      const { data, error } = await supabase.rpc('send_reengagement_notifications', {
        p_threshold_days: 3,
      });
      if (error) throw error;
      setSent(data ?? 0);
      setStatus('done');
    } catch {
      setStatus('error');
    }
  }

  if (status === 'done') {
    return (
      <span className="text-xs font-semibold text-green-600 bg-green-50 px-3 py-1.5 rounded-lg">
        ✓ Sent to {sent} user{sent !== 1 ? 's' : ''}
      </span>
    );
  }

  if (status === 'error') {
    return (
      <button
        onClick={handleSend}
        className="text-xs font-semibold text-red-600 bg-red-50 px-3 py-1.5 rounded-lg hover:bg-red-100 transition-colors"
      >
        Failed — retry
      </button>
    );
  }

  return (
    <button
      onClick={handleSend}
      disabled={status === 'loading' || dormantCount === 0}
      className="text-xs font-semibold text-white bg-[#003F8A] px-3 py-1.5 rounded-lg hover:bg-[#002d6b] transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {status === 'loading' ? 'Sending…' : `Send Re-engagement (${dormantCount})`}
    </button>
  );
}
