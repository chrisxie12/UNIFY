# UNIFY Landing Page

Unify is a production-ready, installable landing page for a university communication platform that keeps class announcements, updates, and reminders in one trusted hub.

## ✨ What this project includes

- Complete landing page (`index.html`) with all required sections:
  - Hero
  - Problem statement + solution
  - Feature highlights
  - 8-step workflow
  - Pricing (50 GHS / semester)
  - Target market
  - Footer
- Dark, modern responsive styling (`styles.css`) with animations
- PWA-ready setup (`public/manifest.json`, `public/service-worker.js`)
- React + Vite + Tailwind-ready dependency configuration (`package.json`)
- Folder structure prepared for future development (`src/`, `public/`, `assets/`)

## 🧱 Project structure

```
UNIFY/
├── assets/
│   └── .gitkeep
├── public/
│   ├── manifest.json
│   └── service-worker.js
├── src/
│   └── .gitkeep
├── .gitignore
├── index.html
├── package.json
├── README.md
└── styles.css
```

## 🎨 Design system

- Theme: Dark professional UI
- Accent colors:
  - Blue: `#3b82f6`
  - Green: `#22c55e`
- Accessibility:
  - Semantic HTML5 sections
  - ARIA labels where appropriate
  - Keyboard-visible focus states
  - Reduced motion support (`prefers-reduced-motion`)

## 🚀 Getting started

### Prerequisites

- Node.js 18+
- npm 9+

### Install dependencies

```bash
npm install
```

### Run locally

```bash
npm run dev
```

### Build for production

```bash
npm run build
```

### Preview production build

```bash
npm run preview
```

## 📱 PWA support

- Manifest metadata is in `public/manifest.json`
- Offline caching template is in `public/service-worker.js`
- Service worker registration is included in `index.html`

> Note: Add real app icons at `assets/icon-192.png` and `assets/icon-512.png` before production release.

## 💵 Pricing model

- **50 GHS / class / semester**

## 🎯 Target market

1. Ghana Communication Technology University (GCTU)
2. Universities across Ghana
3. Expansion across Africa

## 📄 License

MIT (or your preferred project license)
