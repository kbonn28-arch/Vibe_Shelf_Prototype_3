# VibeShelf — Product Requirements Document (PRD)

## Project title
**VibeShelf** — a mood-driven book discovery and personal library web app.

## Brief description
VibeShelf helps readers decide what to read next based on the mood they're in *right now*. Every session begins with a required mood pop-up. That mood drives mood-matched book recommendations for the rest of the session. Users build a personal shelf, track reading progress inline on each book card, favorite books they love, write public reviews tied to their profile, and keep private personal ratings. The app's visual identity is a light green-and-white palette — vibrant, calm, welcoming.

## Primary goals
1. Cut down on reading indecision — surface a mood-matched recommendation in under 30 seconds of opening the app.
2. Maintain rich, organized book records — covers, mood tags, genres, status, dates, ratings, reviews.
3. Enable lightweight community feedback — public reviews tied to user profiles.
4. Keep all interactions fast — every common action (add, favorite, update progress) reachable in one tap from the Library.

## Non-goals (for this prototype)
- Native mobile apps (web only).
- Cross-device sync without a logged-in account.
- Full Supabase Auth integration (prototype-grade hashing only).
- Offline mode (planned for a later version).
- Following / messaging other users (community feedback is review-only).

## Target users
- **Avid readers / hobbyists** — want detailed organization, history, filters.
- **Casual readers** — want fast, low-effort suggestions.
- **Busy / time-limited readers** — short sessions; mood-first flow saves them time.
- **Community reviewers** — rate and review under a public username + bio.

## Technical architecture

| Layer | Choice | Notes |
|---|---|---|
| Frontend | Vanilla HTML/CSS/JS, single-file SPA | No build step; deploy as static. |
| Hosting (FE) | AWS Amplify (static) | One-click drag-and-drop or Git-connected. |
| Backend API | Node.js + Express | Local at `http://localhost:3000` for development. Independent of the frontend. |
| Database | Supabase (Postgres) | Migrations in `db/01_schema.sql`, seed in `db/02_seed.sql`. |
| Storage adapter (FE) | `localStorage` for prototyping; pluggable to live API | Same async shape — swap by setting `window.VIBESHELF_API_URL`. |
| Fonts | Fraunces (display) + Manrope (body) via Google Fonts | Matches the warm, editorial aesthetic. |

The browser client does **not** talk to Supabase directly. All database access goes through the Express API, which uses the service-role key.

## Constraints
- Mood pop-up cannot be skipped — required UX gate per Analyst spec.
- Maximum 2 mood tags per book — enforced both at app layer and via DB trigger.
- Star ratings constrained to 1–5 (DB check constraint).
- Public reviews must be tied to a profile (FK constraint).
- Personal rating is private — never returned in `/reviews/*` endpoints.

## Success criteria
- A user can sign up, choose a mood, and reach a recommended book in under 5 clicks.
- Adding a book takes one tap from the Library page (floating + button).
- Marking a book "Finished" automatically prompts for a private rating.
- The app is fully usable on a 380px-wide mobile viewport.
- The client + API + database all run locally with one command each.
