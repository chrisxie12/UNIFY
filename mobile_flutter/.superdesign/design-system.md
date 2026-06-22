# UNIFY Design System

## Product Context
UNIFY is a campus connectivity app for Ghanaian university students and SHS graduates. The entrance flow (Splash → Welcome → Onboarding → Auth) is the first impression new users have of the product.

## Brand Identity
- **Name**: UNIFY
- **Tagline**: "Your campus, connected."
- **Logo**: Two white stick-figure people holding hands inside a blue circle → forms a "U" shape
- **Tone**: Welcoming, modern, trustworthy, youthful but not childish

## Colors
- **Primary**: #2563EB (primaryBlue) — trusted, academic
- **Primary Dark**: #1D4ED8
- **Primary Light**: #3B82F6
- **Accent Purple**: #7C3AED — creative, vibrant accent
- **Accent Teal**: #14B8A6 — fresh, calming
- **Surfaces**: White (#FFF), Grey (#F8FAFC), Elevated (#F1F5F9)
- **Text Primary**: #0F172A (dark navy)
- **Text Secondary**: #64748B (slate)
- **Text Tertiary**: #94A3B8 (light slate)
- **Error**: #EF4444
- **Success**: #10B981
- **Warning**: #F59E0B

## Typography
- **Font**: Space Grotesk (Google Fonts) — ALL text, everywhere
- **Display**: 40px / w700 / -1.5ls / 1.0h
- **H1**: 32px / w700 / -1.0ls / 1.2h
- **H2**: 24px / w700 / -0.5ls / 1.3h
- **H3**: 20px / w600 / -0.3ls / 1.4h
- **H4**: 18px / w600 / -0.2ls / 1.4h
- **Body**: 16px / w400 / 0ls / 1.5h
- **Body Sm**: 14px / w400 / 0ls / 1.4h
- **Caption**: 12px / w500 / 0.5ls / 1.4h
- **Micro**: 11px / w600 / 0.5ls / 1.3h

## Spacing Scale
4, 8, 12, 16, 20, 24, 32, 40, 48 (no 10)

## Border Radius
sm 8, md 12, lg 16, xl 24, 2xl 32, full 999

## Shadows
Subtle elevation: sm (0,1, blur4), md (0,4, blur8), lg (0,8, blur20), float (0,10, blur25)

## Component Library
See `.superdesign/init/components.md` for full widget source code.
Key components: UnifyLogo, UnifyPrimaryButton (full-width, press-scale 0.97), UnifySecondaryButton (outlined), UnifyInputField (filled grey bg), UnifySelectionCard (selectable card with checkmark), UnifySegmentedControl (pill toggle).

## Key Pages
1. **Splash** — Full-screen mesh gradient (blue→purple cycling), logo + "UNIFY" title, 3s auto-navigate
2. **Welcome** — 60/40 split: purple gradient top with floating circles + logo, white card bottom with "Get Started" + "I have an account"
3. **Onboarding** — 7-step branching flow (SHS/Uni), PageView with progress bar + continue/back buttons
4. **Auth** — Login/signup with Google (SHS) or email with domain validation (Uni)

## Motion
- Duration: fast 150ms, normal 250ms, slow 400ms, enter 500ms, splash 3000ms
- Curves: easeOutCubic, easeInOutCubic, elasticOut (spring), decelerate
- Splash: mesh gradient cycles over 8s, logo spring-scale 0.8→1.0
- Welcome: floating circles drift over 6s, staggered card entrance (5 items)
- Page transitions: normal 250ms easeInOutCubic
- Button press: scale 0.97, fast 150ms easeOut

## Layout Conventions
- SafeArea everywhere
- Edge padding: s24 horizontal, s32 from top (auth)
- Cards: white bg, lg (16) border radius, md shadow when elevated
- Progress bars: 4px height, primaryBlue fill, surfaceElevated track
- Text alignment: left-aligned for headings/body, center for micro/caption
- Input fields: filled surfaceElevated, 12px radius, contentPadding s16
