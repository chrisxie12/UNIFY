# Unify

Unify is a Progressive Web App (PWA) landing experience for clear, accountable, and centralized university class communication.

## Overview

Universities often rely on fragmented communication channels. Unify provides one class link that keeps announcements, reminders, and edits visible to everyone.

## Problem

- Important class information is split across WhatsApp, email, and verbal updates.
- Students miss deadline or schedule updates.
- Class reps have no reliable way to track message transparency.

## Solution

Unify creates one communication hub with role-based access for Super Admins, Class Reps, and Students. It combines announcements, notifications, reminders, and edit tracking in one place.

## Core Features

- Role-Based Access
- Instant Notifications
- Personal Reminders
- Edit History Tracking
- PWA installability and offline fallback
- Pricing model: **50 GHS per class rep activation per semester**

## How It Works

1. Super Admin registers institution setup.
2. Class Rep activates class at 50 GHS/semester.
3. Class Rep generates invite link.
4. Students join instantly.
5. Class Rep posts announcements.
6. Students receive notifications.
7. Students set private reminders.
8. Edit history keeps all updates transparent.

## Target Market

- Launch: Ghana Communication Technology University (GCTU)
- Expansion: Universities across Ghana
- Long-term growth: Institutions across Africa

## Tech Stack

- React 18 + Vite
- Tailwind CSS
- vite-plugin-pwa
- Planned integrations: Supabase, Paystack

## Getting Started

```bash
npm install
npm run dev
```

Build and preview production output:

```bash
npm run build
npm run preview
```

## Project Structure

- `index.html` - Main landing page
- `styles.css` - Responsive dark-theme styling
- `public/manifest.json` - PWA metadata
- `public/service-worker.js` - Offline/cache behavior
- `src/` - Source directory placeholder for app expansion
- `assets/` - Static assets directory
