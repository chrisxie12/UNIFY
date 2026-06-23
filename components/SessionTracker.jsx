'use client';

import { useEffect, useRef } from 'react';
import { createBrowserClient } from '@supabase/ssr';

export default function SessionTracker() {
  const sessionIdRef = useRef(null);
  const startTimeRef = useRef(null);
  const supabaseRef  = useRef(null);

  function getSupabase() {
    if (!supabaseRef.current) {
      supabaseRef.current = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
      );
    }
    return supabaseRef.current;
  }

  async function startSession() {
    try {
      const supabase = getSupabase();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data } = await supabase
        .from('user_sessions')
        .insert({ user_id: user.id, platform: 'web', app_version: '1.0.0-beta' })
        .select('id')
        .single();

      if (data?.id) {
        sessionIdRef.current = data.id;
        startTimeRef.current = Date.now();
      }

      // Fire session_start event (deduplicated server-side by dashboard logic)
      await supabase.from('analytics_events').insert({
        user_id: user.id,
        event_name: 'session_start',
        platform: 'web',
        app_version: '1.0.0-beta',
        properties: {},
      });
    } catch {
      // Silent — analytics never break the UI
    }
  }

  async function endSession() {
    const id = sessionIdRef.current;
    if (!id || !startTimeRef.current) return;

    const duration = Math.round((Date.now() - startTimeRef.current) / 1000);
    sessionIdRef.current = null;
    startTimeRef.current = null;

    try {
      await getSupabase()
        .from('user_sessions')
        .update({ ended_at: new Date().toISOString(), duration_seconds: duration })
        .eq('id', id);
    } catch {
      // Silent
    }
  }

  useEffect(() => {
    startSession();

    function handleVisibilityChange() {
      if (document.hidden) {
        endSession();
      } else {
        // Page became visible again — start a new session segment
        startSession();
      }
    }

    function handleBeforeUnload() {
      // Synchronous close — use sendBeacon if available for reliability
      const id = sessionIdRef.current;
      if (!id || !startTimeRef.current) return;

      const duration = Math.round((Date.now() - startTimeRef.current) / 1000);
      const url = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/rest/v1/user_sessions?id=eq.${id}`;
      const payload = JSON.stringify({ ended_at: new Date().toISOString(), duration_seconds: duration });
      const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

      if (navigator.sendBeacon) {
        const blob = new Blob([payload], { type: 'application/json' });
        // sendBeacon doesn't support custom headers; fall through to async
      }

      // Best-effort async update (may not complete on tab close)
      endSession();
    }

    document.addEventListener('visibilitychange', handleVisibilityChange);
    window.addEventListener('beforeunload', handleBeforeUnload);

    return () => {
      document.removeEventListener('visibilitychange', handleVisibilityChange);
      window.removeEventListener('beforeunload', handleBeforeUnload);
      endSession();
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return null; // No UI
}
