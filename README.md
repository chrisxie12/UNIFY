# UNIFY 🇬🇭

> System communities of pages, connecting students in one platform in a unit page.

UNIFY is a dedicated platform designed to connect students across schools in Ghana. Inspired by platforms like ZeeMee, UNIFY aims to bridge the gap for students transitioning into Senior High Schools (SHS) and Universities by fostering early connections, helping find hostel roommates, and building vibrant campus communities before the school year even begins.

## 🎯 Vision

To be the central hub for the Ghanaian student experience—from post-BECE school placements to navigating university life. UNIFY provides a mobile-first, low-bandwidth environment where students can find their tribe.

## 🚀 Core Features (MVP)

### 1. Identity & Onboarding
* **Authentication:** Seamless sign-up using Phone Number (OTP), Email, or Google.
* **Student Profiles:** Customizable profiles featuring bios, avatars, hometowns, and interests.
* **School Placement Selection:** Users can select their prospective or current SHS or University to be placed in the appropriate "Unit."

### 2. "Unit" Pages (School Hubs)
* **Central Feeds:** A primary discussion board for each school to ask questions and share updates.
* **Sub-Communities:** Filtered tags and group chats for specific needs, such as "Engineering Majors," "Class of 2030," or "Hostel Roommate Search."

### 3. Connection & Messaging
* **Discovery:** Find and connect with students sharing similar interests or attending the same institution.
* **Direct Messaging (DM):** Secure 1-on-1 chats to plan meetups, discuss courses, or arrange housing.

## 🏗️ Proposed Technical Architecture

* **Frontend (Mobile-First):** React Native / Expo (Allows for building a cross-platform app for iOS and Android, which is crucial for the Ghanaian mobile market) or Next.js for a Progressive Web App.
* **Backend:** Node.js with Express.
* **Database:** PostgreSQL (Relational data for users, schools, and connections) via Supabase.
* **Authentication:** Supabase Auth or Firebase (Excellent support for SMS OTP).

## 🗺️ Project Roadmap

- [ ] **Phase 1: Foundation** - Setup repository, define database schemas, and implement user authentication.
- [ ] **Phase 2: Profiles & Units** - Build out user profiles and the core "Unit" pages for different schools.
- [ ] **Phase 3: Social Mechanics** - Implement feeds, posting, commenting, and direct messaging.
- [ ] **Phase 4: Ghana-Specific Features** - Integrate features for BECE/WASSCE cohorts and University hostel roommate matching.

## 🛠️ Getting Started

*(Instructions for local setup will be added here as the codebase evolves.)*
