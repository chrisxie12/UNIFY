# UNIFY Mobile

Neo-Brutalist mobile app for Ghanaian tertiary students — Instagram-style chat
plus Reddit-style campus hub threads. Expo + expo-router + NativeWind.

## Design system

- **Canvas (90%)**: parchment `#F4F4F0` light / `#121212` dark. Reading zones
  (threads, comments, chat bubbles) stay calm — white or parchment surfaces only.
- **Accents (10%)**: neon yellow `#FFE600` actions, brand orange `#FF6B35`,
  neon green `#00FF66` verification badges, hot pink `#FF007A` unread/alerts.
- **Borders**: every surface gets `1.5–2px` solid `#000`.
- **Shadows**: hard 0-blur offsets (4px standard, 2px micro). RN blurs native
  shadows, so `components/NB.jsx` builds them with a stacked-view technique:
  a black backing view at the final position, face translated up-left by the
  offset. Pressing translates the face flush — the physical depression effect
  comes free.
- **Type**: Archivo Black / Space Grotesk for display, Inter for body.
- **Radii**: `0px` everywhere (4px max where unavoidable).

## Run it

```bash
cd mobile
npm install
npx expo start
```

Scan the QR with Expo Go, or press `a` / `i` for an emulator.

## Structure

```
app/
  _layout.jsx     tabs shell + font loading
  index.jsx       Hubs feed (Reddit-style threads)
  chats.jsx       chat list (Instagram-style)
  chat/[id].jsx   1:1 chat thread
  thread/[id].jsx hub thread + comments
  profile.jsx     profile + quiz answers
components/NB.jsx NBCard / NBButton / NBBadge / NBInput primitives
theme/tokens.js   color/shadow/border/radius tokens
```
