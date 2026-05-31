# Unify

Unify is a Progressive Web App that gives university classes one reliable communication hub.

**One link. Zero missed announcements. Total class clarity.**

## Problem It Solves

University communication is fragmented across WhatsApp groups, email threads, and word-of-mouth updates. This causes missed announcements, forgotten deadlines, and confusion around class schedule changes.

## Solution Overview

Unify centralizes class communication in one place for class representatives and students. It supports announcements, assignment posts, schedule updates, reminders, and edit visibility so everyone sees the same source of truth.

## How It Works

1. Class representative creates a class space.
2. Role permissions are applied (Super Admin, Class Rep, Student).
3. Invite link is shared with the class.
4. Students join quickly at no cost.
5. Class rep posts announcements and assignment updates.
6. Students receive notifications.
7. Students set private reminders.
8. Edit history keeps all updates transparent.

## Core Features

- Role-based access control
- Real-time notifications
- Personal reminder tools
- Edit history and transparency
- Installable PWA experience
- Simple class-based pricing

## Pricing Model

- **50 GHS per class per semester** (paid by class representative)
- **Students join free**

## Target Market and Expansion

- **Phase 1:** Ghana Communication Technology University (GCTU)
- **Phase 2:** Universities across Ghana
- **Phase 3:** Expansion across Africa

## Tech Stack

### Current Frontend Setup

- HTML5 + CSS3 landing page
- Vite project configuration
- PWA manifest and service worker template

### Planned Product Stack

- React 18
- Tailwind CSS
- Supabase backend
- Paystack payments

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```
2. Run locally:
   ```bash
   npm run dev
   ```
3. Build for production:
   ```bash
   npm run build
   ```
4. Preview production build:
   ```bash
   npm run preview
   ```

## Project Structure

```
/src
  /components
  /pages
  /styles
  /utils
/public
  /icons
  manifest.json
  service-worker.js
/assets
index.html
styles.css
package.json
.gitignore
README.md
```
