'use client';

import { useState } from 'react';
import { createBrowserClient } from '@supabase/ssr';

export default function FeatureFlagToggles({ initialFlags }) {
  const [flags, setFlags] = useState(initialFlags);
  const [saving, setSaving] = useState(null);

  async function toggle(flag) {
    setSaving(flag.key);
    try {
      const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
      );
      const newValue = !flag.enabled;
      await supabase.from('feature_flags').update({ enabled: newValue, updated_at: new Date().toISOString() }).eq('key', flag.key);
      setFlags((prev) => prev.map((f) => f.key === flag.key ? { ...f, enabled: newValue } : f));
    } finally {
      setSaving(null);
    }
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
      {flags.map((flag) => (
        <div
          key={flag.key}
          className="flex items-center justify-between gap-3 bg-white rounded-xl border border-gray-100 px-4 py-3"
        >
          <div className="min-w-0">
            <p className="font-medium text-gray-900 text-sm truncate">{flag.label}</p>
            <p className="text-gray-400 text-xs truncate">{flag.description}</p>
          </div>
          <button
            onClick={() => toggle(flag)}
            disabled={saving === flag.key}
            className={`shrink-0 relative w-10 h-6 rounded-full transition-colors ${
              flag.enabled ? 'bg-[#003F8A]' : 'bg-gray-200'
            } ${saving === flag.key ? 'opacity-50' : ''}`}
            aria-label={`${flag.enabled ? 'Disable' : 'Enable'} ${flag.label}`}
          >
            <span
              className={`absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform ${
                flag.enabled ? 'translate-x-4' : 'translate-x-0'
              }`}
            />
          </button>
        </div>
      ))}
    </div>
  );
}
