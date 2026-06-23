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

// Named event helpers keep call sites clean
export const Analytics = {
  onboardingStarted:          () => trackEvent('onboarding_started'),
  onboardingCompleted:        () => trackEvent('onboarding_completed'),
  communityJoined:            (id) => trackEvent('community_joined', { community_id: id }),
  eventViewed:                (id) => trackEvent('event_viewed', { event_id: id }),
  eventRsvp:                  (id) => trackEvent('event_rsvp', { event_id: id }),
  profileCompleted:           () => trackEvent('profile_completed'),
  firstMessageSent:           () => trackEvent('first_message_sent'),
  firstPostCreated:           () => trackEvent('first_post_created'),
  marketplaceViewed:          () => trackEvent('marketplace_viewed'),
  marketplaceListingCreated:  () => trackEvent('marketplace_listing_created'),
  feedViewed:                 () => trackEvent('feed_viewed'),
  feedbackSubmitted:          (type) => trackEvent('feedback_submitted', { type }),
};
