# UNIFY Beta Testing Checklist

## Authentication
- [ ] User can sign up with email/password
- [ ] User can sign in with existing credentials
- [ ] Invalid credentials show proper error message
- [ ] Password reset sends email link
- [ ] User is redirected to onboarding after first signup
- [ ] User can sign out successfully
- [ ] All cache data is cleared on sign out
- [ ] Session persists across app restarts

## Onboarding
- [ ] All onboarding steps render correctly
- [ ] Photo upload works (camera + gallery)
- [ ] Can proceed only when required fields are filled
- [ ] Can skip optional fields
- [ ] Profile is created successfully after onboarding
- [ ] User lands on Feed after completing onboarding

## Feed
- [ ] Feed loads with announcements
- [ ] Infinite scroll / pagination works
- [ ] Pull-to-refresh works
- [ ] Like/unlike announcements works
- [ ] Comments on announcements load and post
- [ ] Empty state shows when no announcements
- [ ] Loading shimmer shows while fetching

## Communities
- [ ] Community list loads
- [ ] Community detail loads (all 5 tabs)
- [ ] Join/leave community works
- [ ] Post creation in community works
- [ ] Comments on posts work
- [ ] Poll creation in community works
- [ ] Resource list loads
- [ ] Member list loads
- [ ] Member profile navigation works
- [ ] Empty state for empty tabs

## Messaging
- [ ] Conversations list loads
- [ ] Chat screen opens and shows messages
- [ ] Sending text messages works
- [ ] Messages appear in real-time
- [ ] Message reactions work
- [ ] Creating a group works
- [ ] Student directory search works
- [ ] Message requests work
- [ ] Unread count updates
- [ ] Empty state for no conversations

## Events
- [ ] Events tab loads with upcoming/trending/featured
- [ ] Event detail screen renders fully
- [ ] RSVP to an event works
- [ ] Cancel RSVP works
- [ ] View ticket works (past events too)
- [ ] QR ticket displays correctly
- [ ] Event search works
- [ ] Create event form validates
- [ ] Event media gallery renders
- [ ] Event discussions work
- [ ] Empty states for no events

## Academic Hub
- [ ] Courses tab loads by department
- [ ] Course detail shows resources/assignments
- [ ] Resource list filters by type
- [ ] Assignment hub shows upcoming/past
- [ ] GPA calculator calculates correctly
- [ ] Study planner creates/toggles items
- [ ] Exam timetable displays
- [ ] Empty states for empty data

## Profile
- [ ] Profile screen shows user info
- [ ] Edit profile saves changes
- [ ] Privacy settings render
- [ ] Settings screen renders (theme, appearance)
- [ ] Theme mode switch works (system/light/dark)
- [ ] Colour theme picker works
- [ ] About UNIFY screen renders

## Notifications
- [ ] Notifications list loads
- [ ] Notification preferences render
- [ ] Empty state for no notifications

## Search
- [ ] Global search returns results
- [ ] Category tabs (all/communities/events/users) work
- [ ] Search debouncing works
- [ ] Empty state for no results

## Offline Mode
- [ ] Feed shows cached data when offline
- [ ] Connectivity banner appears (when implemented)
- [ ] App doesn't crash when going offline
- [ ] Data re-syncs when back online

## Dark Mode
- [ ] All screens render correctly in dark mode
- [ ] Text is readable on dark backgrounds
- [ ] Buttons and inputs are visible
- [ ] Shimmer loading adapts to dark
- [ ] Empty states adapt to dark
- [ ] SnackBars are visible in dark mode
- [ ] Bottom sheets and dialogs render correctly

## Navigation
- [ ] Bottom nav bar works across all tabs
- [ ] Back navigation works correctly
- [ ] Deep links from push notifications work
- [ ] 404 page shows for unknown routes
- [ ] No navigation errors in console

## Performance
- [ ] Feed scrolls smoothly (no jank)
- [ ] Images load with caching
- [ ] App launches in < 3 seconds
- [ ] No memory leaks on tab switching

## Beta-Specific Checks
- [ ] App version and build number visible in About
- [ ] Contact Support shows email
- [ ] Privacy Policy screen renders
- [ ] Terms of Service screen renders
- [ ] Feedback navigation works
- [ ] Analytics events fired on key actions
- [ ] Crash reporting catches unhandled errors
