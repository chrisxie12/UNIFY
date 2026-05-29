# Unify — University Class Communication Platform

Unify is a Progressive Web App (PWA) that serves as a dedicated communication hub for university classes, helping students avoid missed announcements, deadlines, and schedule changes.

## The Problem
University communication is often fragmented across WhatsApp groups, emails, and word-of-mouth. Important information gets lost in chat noise, and class reps have no reliable way to confirm who has seen what.

## The Solution
Unify centralizes class communication in one place. Each class has a dedicated page managed by its class rep, and students receive instant notifications whenever posts are created or edited.

## How It Works
1. **Super Admin** registers a Class Rep and creates their class page.
2. **Class Rep** pays **50 GHS per semester** to activate the class page.
3. Class Rep generates a one-time invite link and shares it via WhatsApp/SMS.
4. Students open the link, enter their name/email, and join instantly.
5. Class Rep posts announcements, assignments, and events with priority levels.
6. Students receive real-time notifications for created or edited posts.
7. Students set personal reminders for assignments and events.
8. Class Rep edits posts anytime, with edit history tracked and notifications sent.

## Core Features
- 🔐 **Role-Based Access**: Super Admin → Class Rep → Student, each with clear permissions.
- 🔗 **One-Tap Join**: Secure, regenerable invite links shared through WhatsApp/SMS.
- 🔔 **Real-Time Notifications**: Instant alerts when posts are created or edited.
- ⏰ **Personal Reminders**: Students create personal deadline and event reminders.
- 📱 **PWA Native Feel**: Installable on iOS/Android/Desktop with offline support.
- 📝 **Edit History**: Full audit trail for all post updates.
- 💳 **Simple Pricing**: 50 GHS per class per semester.

## Tech Stack
- **Frontend**: React 18 + Vite
- **Styling**: Tailwind CSS (dark theme)
- **Routing**: React Router
- **State (demo)**: Context API + LocalStorage
- **PWA**: `vite-plugin-pwa` (service worker, manifest, offline support)
- **Backend (planned)**: Supabase (auth, database, real-time)
- **Payments (planned)**: Paystack / Flutterwave

## Target Market
- **Primary launch market**: Ghana Communication Technology University (GCTU)
- **Expansion**: Universities across Ghana, then Africa
- **Users**: Paying class representatives and free class members

## Current Status
- ✅ Frontend pages built and interactive
- ✅ Demo role data for Super Admin, Class Rep, and Student
- ✅ PWA installable across major devices
- ✅ Rebranded as **Unify** for broader scaling
- ✅ Vercel deployment ready
- 🔄 Next: Supabase backend, payment integration, and live deployment

## One-Line Pitch
> **Unify is the dedicated information hub for university classes — one link, zero missed announcements, total class clarity.**
