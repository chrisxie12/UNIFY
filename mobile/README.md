# UNIFY Mobile

Neubrutalist mobile app for Ghanaian tertiary students — Instagram-style chat
plus Reddit-style campus hub threads. **Expo Router + strict TypeScript +
NativeWind (utility classes only).**

## Design system

- **Borders**: thick pitch-black — `border-4 border-black` on cards/buttons/inputs,
  `border-2` on micro elements (badges, avatars, bubbles). No grey hairlines.
- **Shadows**: hard, 0-blur, 100% opaque black. Custom utilities in
  `tailwind.config.js`: `shadow-nb` (4px), `shadow-nb-sm` (2px), `shadow-nb-lg` (6px)
  — compiled by NativeWind to the RN 0.76+ `boxShadow` style (new architecture).
- **Press depression**: class-driven, no JS state —
  `active:translate-x-[4px] active:translate-y-[4px] active:shadow-none`
  shifts the element into its shadow footprint like a physical block.
- **Palette (90/10)**: calm parchment `#F4F4F0` / white reading zones; loud accents
  only on actions & status — neon yellow `#FFE600`, brand orange `#FF6B35`,
  neon green `#00FF66` (verification), hot pink `#FF007A` (unread/alerts).
  Zero gradients, transparencies, or blurs.
- **Type**: Archivo Black display (uppercase, tight tracking), Space Grotesk
  headings, Inter body. Mapped to `font-display` / `font-heading` / `font-body*`.
- **Radii**: `rounded-none` everywhere.

## Run it

```bash
cd mobile
npm install
npx expo start
```

Scan the QR with Expo Go, or press `a` / `i` for an emulator.
Type-check with `npx tsc --noEmit`.

## Structure

```
app/
  _layout.tsx           root Stack + AppProvider + font loading
  (tabs)/
    _layout.tsx         custom Neubrutalist tab bar (Dashboard / Schedule / Network)
    index.tsx           Dashboard — GPA, modules, assignment schedule
    schedule.tsx        Timetable planner with weekday selector
    network.tsx         Campus networking (Reddit-style hub threads)
  chats.tsx             chat list (Instagram-style), pushed from Network
  chat/[id].tsx         1:1 chat thread
  thread/[id].tsx       hub thread + comments
  profile.tsx           profile + quiz answers, pushed from Dashboard
components/NB.tsx       NBCard / NBPressCard / NBButton / NBBadge / NBPopBadge / NBInput / NBAvatar
context/AppContext.tsx  AppProvider + useApp — GPA modules, assignments, timetable, profile
theme/tokens.ts         typed color tokens (incl. pop palette) + data interfaces
```

## Notes

- Hard `boxShadow` requires React Native 0.76+ with the new architecture
  (Expo SDK 52 default). On older RN, shadows blur on iOS and Android —
  the previous stacked-view fallback lives in git history if you need it.
- `nativewind-env.d.ts` provides `className` typings for RN components.
