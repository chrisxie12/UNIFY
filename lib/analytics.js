'use client';

import { createBrowserClient } from '@supabase/ssr';

function getClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  );
}

export async function trackEvent(eventName, properties = {}) {
  try {
    const supabase = getClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    await supabase.from('analytics_events').insert({
      user_id: user.id,
      event_name: eventName,
      properties,
      platform: 'web',
      app_version: '1.0.0-beta',
    });
  } catch {
    // Never throw — analytics must never break the app
  }
}

// Named event helpers keep call sites readable
export const Analytics = {
  // ── Onboarding funnel ───────────────────────────────────────────────────────
  onboardingStarted:          ()   => trackEvent('onboarding_started'),
  onboardingStepCompleted:    (n)  => trackEvent('onboarding_step_completed', { step: n }),
  onboardingCompleted:        ()   => trackEvent('onboarding_completed'),
  profileCompleted:           ()   => trackEvent('profile_completed'),

  // ── Session ─────────────────────────────────────────────────────────────────
  sessionStart:               ()   => trackEvent('session_start'),

  // ── Content discovery ───────────────────────────────────────────────────────
  feedViewed:                 ()   => trackEvent('feed_viewed'),
  communityViewed:            (id) => trackEvent('community_viewed',    { community_id: id }),
  communityJoined:            (id) => trackEvent('community_joined',    { community_id: id }),
  eventViewed:                (id) => trackEvent('event_viewed',        { event_id: id }),
  eventRsvp:                  (id) => trackEvent('event_rsvp',          { event_id: id }),
  marketplaceViewed:          ()   => trackEvent('marketplace_viewed'),
  marketplaceListingViewed:   (id) => trackEvent('marketplace_listing_viewed', { listing_id: id }),
  marketplaceListingCreated:  ()   => trackEvent('marketplace_listing_created'),

  // ── Engagement ──────────────────────────────────────────────────────────────
  firstMessageSent:           ()   => trackEvent('first_message_sent'),
  messageSent:                ()   => trackEvent('message_sent'),
  firstPostCreated:           ()   => trackEvent('first_post_created'),
  postCreated:                ()   => trackEvent('post_created'),
  postViewed:                 (id) => trackEvent('post_viewed',         { discussion_id: id }),
  commentCreated:             ()   => trackEvent('comment_created'),

  // ── Notifications ───────────────────────────────────────────────────────────
  notificationReceived:       (type) => trackEvent('notification_received', { type }),
  notificationOpened:         (id, type) => trackEvent('notification_opened', { notification_id: id, type }),
  notificationDismissed:      (id)   => trackEvent('notification_dismissed', { notification_id: id }),

  // ── Retention signals ────────────────────────────────────────────────────────
  appReturned:                ()   => trackEvent('app_returned'),

  // ── Feedback ────────────────────────────────────────────────────────────────
  feedbackSubmitted:          (type) => trackEvent('feedback_submitted', { type }),
};
