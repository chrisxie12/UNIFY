# UNIFY 🇬🇭

> System communities of pages, connecting students in one platform in a unit page.

UNIFY is a dedicated platform designed to connect students across schools in Ghana. Inspired by platforms like ZeeMee, UNIFY aims to bridge the gap for students transitioning into Senior High Schools (SHS) and Universities by fostering early connections, helping find hostel roommates, and building vibrant campus communities before the school year even begins.

## 🎯 Vision

To be the central hub for the Ghanaian student experience—from post-BECE school placements to navigating university life. UNIFY provides a mobile-first, low-bandwidth environment where students can find their tribe.

## 🚀 Core Features (MVP)

### 1. Identity & Onboarding
- **Authentication:** Seamless sign-up using Phone Number (OTP), Email, or Google.
- **Student Profiles:** Customizable profiles featuring bios, avatars, hometowns, and interests.
- **School Placement Selection:** Users can select their prospective or current SHS or University to be placed in the appropriate "Unit."

### 2. "Unit" Pages (School Hubs)
- **Central Feeds:** A primary discussion board for each school to ask questions and share updates.
- **Sub-Communities:** Filtered tags and group chats for specific needs, such as "Engineering Majors," "Class of 2030," or "Hostel Roommate Search."

### 3. Connection & Messaging
- **Discovery:** Find and connect with students sharing similar interests or attending the same institution.
- **Direct Messaging (DM):** Secure 1-on-1 chats to plan meetups, discuss courses, or arrange housing.

## 🏗️ Proposed Technical Architecture

- **Frontend (Mobile-First):** React Native / Expo or Next.js for a Progressive Web App.
- **Backend:** Node.js with Express.
- **Database:** PostgreSQL (via `database/schema.sql`).
- **Authentication:** Email/phone OTP + JWT + Google OAuth scaffold.

## 🗺️ Project Roadmap

- [x] **Phase 1: Foundation** - Backend structure, database schemas, and authentication scaffolding.
- [ ] **Phase 2: Profiles & Units** - Build out user profiles and the core "Unit" pages for different schools.
- [ ] **Phase 3: Social Mechanics** - Implement feeds, posting, commenting, and direct messaging.
- [ ] **Phase 4: Ghana-Specific Features** - Integrate features for BECE/WASSCE cohorts and University hostel roommate matching.

## 📁 Backend Project Structure

```text
src/
  app.js
  server.js
  config/
    db.js
    env.js
  controllers/
  middleware/
  models/
  routes/
  validators/
database/
  schema.sql
tests/
  health.test.js
```

## 🛠️ Local Development Setup

1. Install dependencies:
   ```bash
   npm install
   ```
2. Copy environment template and fill values:
   ```bash
   cp .env.example .env
   ```
3. Create PostgreSQL database and run schema:
   ```bash
   psql -d unify -f database/schema.sql
   ```
4. Start the API server:
   ```bash
   npm run dev
   ```

## 🔐 Environment Variables

See `.env.example`.

- `NODE_ENV`: `development` | `test` | `production`
- `PORT`: API port (default `4000`)
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Access token signing secret
- `JWT_REFRESH_SECRET`: Refresh token signing secret
- `JWT_ACCESS_EXPIRES_IN`: Access token TTL (e.g. `15m`)
- `JWT_REFRESH_EXPIRES_IN`: Refresh token TTL (e.g. `7d`)
- `GOOGLE_CLIENT_ID`: Google OAuth client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth secret
- `GOOGLE_CALLBACK_URL`: OAuth callback URL

## 📚 API Endpoints (Phase 1)

Base URL: `http://localhost:4000/api`

### Auth

- `POST /auth/signup`
- `POST /auth/verify-otp`
- `POST /auth/login`
- `POST /auth/refresh-token`
- `GET /auth/google` (OAuth scaffold placeholder)

### Users

- `GET /users/:id`
- `PUT /users/:id`

### Schools & Units

- `GET /schools`
- `GET /units/:schoolId`

### Example Requests

#### `POST /api/auth/signup`
```json
{
  "email": "student@example.com",
  "phone": "+233501234567",
  "name": "Ama Mensah",
  "password": "strongpassword"
}
```

#### `POST /api/auth/verify-otp`
```json
{
  "email": "student@example.com",
  "otp": "123456"
}
```

#### `POST /api/auth/login`
```json
{
  "email": "student@example.com",
  "password": "strongpassword"
}
```

#### `PUT /api/users/:id`
```json
{
  "bio": "Future engineer",
  "hometown": "Kumasi",
  "interests": ["technology", "robotics"]
}
```

## ✅ Validation, Error Handling, and Testing Readiness

- Request validation uses `express-validator`.
- Global 404 and error middleware are configured.
- Jest is configured with a sample API health test in `tests/health.test.js`.

## 📦 Scripts

- `npm run dev` - run server with nodemon
- `npm start` - run server with node
- `npm run lint` - lint backend source and tests
- `npm run test` - run Jest tests
- `npm run build` - no-op placeholder for backend runtime
