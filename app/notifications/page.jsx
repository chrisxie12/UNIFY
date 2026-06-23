import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import NotificationsReader from './NotificationsReader';

const TYPE_META = {
  welcome:                       { icon: '👋' },
  activation_nudge:              { icon: '🎯' },
  re_engagement:                 { icon: '👀' },
  new_message:                   { icon: '💬' },
  community_announcement:        { icon: '📢' },
  community_join_request:        { icon: '🙋' },
  community_approval:            { icon: '✅' },
  marketplace_inquiry:           { icon: '🛒' },
  marketplace_sale:              { icon: '💰' },
  event_registration:            { icon: '📅' },
  event_reminder:                { icon: '⏰' },
  event_checkin_confirmation:    { icon: '✔️' },
  opportunity_deadline_reminder: { icon: '⌛' },
  scholarship_alert:             { icon: '🎓' },
  academic_resource_upload:      { icon: '📚' },
  verification_approved:         { icon: '🪪' },
  role_assigned:                 { icon: '⭐' },
  admin_broadcast:               { icon: '📣' },
};

function formatAge(iso) {
  const diff = Date.now() - new Date(iso).getTime();
  const m = Math.floor(diff / 60000);
  if (m < 1) return 'Just now';
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  return new Date(iso).toLocaleDateString('en-GH', { day: 'numeric', month: 'short' });
}

export const revalidate = 0;

export default async function NotificationsPage() {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: notifications } = await supabase
    .from('notifications')
    .select('id, type, title, body, is_read, created_at')
    .eq('user_id', user.id)
    .order('created_at', { ascending: false })
    .limit(50);

  const unreadIds = (notifications ?? []).filter((n) => !n.is_read).map((n) => n.id);

  return (
    <div className="min-h-screen bg-gray-50" style={{ fontFamily: "'Inter', system-ui, sans-serif" }}>
      <header className="bg-white border-b border-gray-100 sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-5 h-14 flex items-center gap-3">
          <Link href="/feed" className="text-gray-400 hover:text-gray-900 transition-colors text-lg leading-none">←</Link>
          <h1 className="font-bold text-base text-gray-900 flex-1" style={{ letterSpacing: '-0.02em' }}>Notifications</h1>
          {unreadIds.length > 0 && (
            <span className="text-[10px] font-bold bg-[#003F8A] text-white px-2 py-0.5 rounded-full">
              {unreadIds.length} new
            </span>
          )}
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-5 py-6">
        {!(notifications ?? []).length ? (
          <div className="text-center py-20">
            <p className="text-4xl mb-3">🔔</p>
            <p className="font-semibold text-gray-600">No notifications yet</p>
            <p className="text-gray-400 text-sm mt-1">Activity and updates will appear here.</p>
          </div>
        ) : (
          <div className="flex flex-col gap-2">
            {notifications.map((n) => {
              const { icon } = TYPE_META[n.type] ?? { icon: '🔔' };
              return (
                <div
                  key={n.id}
                  className={`bg-white rounded-2xl border p-4 flex items-start gap-3 ${
                    n.is_read ? 'border-gray-100' : 'border-[#003F8A]/20'
                  }`}
                >
                  <span className="text-xl shrink-0 mt-0.5">{icon}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-0.5">
                      <p className={`font-semibold text-sm leading-snug ${n.is_read ? 'text-gray-700' : 'text-gray-900'}`}>
                        {n.title}
                      </p>
                      <span className="text-[11px] text-gray-400 shrink-0">{formatAge(n.created_at)}</span>
                    </div>
                    <p className="text-gray-500 text-sm leading-relaxed">{n.body}</p>
                  </div>
                  {!n.is_read && (
                    <div className="w-2 h-2 rounded-full bg-[#003F8A] mt-1.5 shrink-0" />
                  )}
                </div>
              );
            })}
          </div>
        )}
      </main>

      {unreadIds.length > 0 && <NotificationsReader notificationIds={unreadIds} />}
    </div>
  );
}
