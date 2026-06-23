'use client';

import { useEffect } from 'react';
import { createBrowserClient } from '@supabase/ssr';

export default function NotificationsReader({ notificationIds }) {
  useEffect(() => {
    if (!notificationIds?.length) return;
    const supabase = createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    );
    supabase
      .from('notifications')
      .update({ is_read: true })
      .in('id', notificationIds)
      .then(() => {});
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return null;
}
