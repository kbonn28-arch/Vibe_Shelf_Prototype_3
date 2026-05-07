# VibeShelf

> A mood-driven book discovery and personal library web app.
> Pick a vibe, get a story.

**Live demo:** https://main.d39jxpyrz5tpfh.amplifyapp.com

**Live API:** https://vibe-shelf-prototype-3.onrender.com

**GitHub repo:** https://github.com/kbonn28-arch/Vibe_Shelf_Prototype_3

---

## What this is

VibeShelf is a single-page web app that helps readers decide what to read next based on how they're feeling right now. Every session begins with a mood pop-up; that mood drives the recommendation engine for the rest of the session. Users build a personal shelf, track reading progress inline on each book card, favorite books, write community reviews tied to their public profile, and keep private personal ratings.

This is the Level 3 / Final Prototype deliverable, built directly from the Analyst's Final Specification (Interview 3 feedback incorporated).

## Architecture

| Layer | Service | URL |
|---|---|---|
| Frontend | AWS Amplify (static hosting) | https://main.d39jxpyrz5tpfh.amplifyapp.com |
| Backend API | Render.com (Node.js / Express) | https://vibe-shelf-prototype-3.onrender.com |
| Database | Supabase (Postgres) | (private) |

The frontend, API, and database all run on independent services. The browser client does not talk to Supabase directly — all DB access goes through the Express API using the service-role key.

## Repo layout

- `client/` — Frontend SPA, deployed to AWS Amplify
- `api/` — Express API server, deployed to Render
- `db/` — SQL schema + seed for Supabase
- `docs/` — PRD, task list, workspace rules, site map
- `tests/` — Smoke tests (bash + windows)
- `amplify.yml` — AWS Amplify static-deploy config
- `README.md` — This file

## Tech stack

- **Frontend:** Vanilla HTML/CSS/JS, single-file SPA (no build step)
- **Hosting (FE):** AWS Amplify (static)
- **Backend API:** Node.js + Express on Render
- **Database:** Supabase (Postgres)
- **Fonts:** Fraunces (display) + Manrope (body) via Google Fonts

## Demo instructions

The app uses a self-contained authentication flow — no real credentials needed. Just visit the live demo and sign up.

### Try as a regular user

1. Open https://main.d39jxpyrz5tpfh.amplifyapp.com
2. Click "Sign up" and enter:
   - Email: anything (e.g., `you@example.com`)
   - Username: anything you like
   - Password: at least 4 characters
3. Pick a mood (required — cannot be skipped)
4. Try the full flow:
   - **Library** — see your books; try the ★ favorite, ⋯ menu, and 📈 progress controls on each card
   - **Discover** — get mood-matched recommendations; try Save / Skip / Not Interested
   - Floating **+** button (bottom-right) — add a new book with cover image
   - Click any book card → **Book Detail** → **Write Review**
   - **Profile** — see your stats and edit profile
   - When you mark a book "Finished" via the progress panel, a **Personal Rating** popup auto-opens

### Try as an admin (role-based view)

Sign up with the special email `admin@vibeshelf.app` and any password ≥4 chars. After mood selection, the top nav will show an extra **Admin** link with a stats dashboard — only visible to users with the admin role.

### Verify live data

The API at https://vibe-shelf-prototype-3.onrender.com is independently deployed and serves data from Supabase. Quick test in your browser:

- https://vibe-shelf-prototype-3.onrender.com/health — returns ok status
- https://vibe-shelf-prototype-3.onrender.com/moods — returns the live mood list from Supabase
- https://vibe-shelf-prototype-3.onrender.com/books — returns the live book catalog

Heads up on Render's free tier: the API sleeps after 15 minutes of inactivity. The first request after a sleep takes about 30 seconds to wake up — subsequent requests are instant. If the live demo seems slow on first load, hit refresh and it will be snappy.

## Local development

### 1. Database (Supabase)

1. Create a new Supabase project.
2. In the SQL Editor, run `db/01_schema.sql` then `db/02_seed.sql`.
3. Verify: `book` table has 5 rows, `mood` table has 6 rows.
4. From Project Settings → API, copy the **Project URL** (without `/rest/v1/`) and the **service_role** key.

### 2. API (locally)

In a terminal:

    cd api
    npm install
    cp .env.example .env
    # edit .env — paste in SUPABASE_URL and SUPABASE_SERVICE_KEY
    npm start

The API will be listening on http://localhost:3000.

### 3. Client (locally)

In a separate terminal:

    cd client
    python3 -m http.server 8080

Then open http://localhost:8080 in a browser. To wire the local client to the local API, add this line near the top of `client/index.html`, above the main script tag:

    <script>window.VIBESHELF_API_URL = 'http://localhost:3000';</script>

### 4. Smoke test

With the local API running:

    BASE_URL=http://localhost:3000 bash tests/smoke.sh

You can also run smoke tests against the live deployed API:

    BASE_URL=https://vibe-shelf-prototype-3.onrender.com bash tests/smoke.sh

## Documentation

- `docs/PRD.md` — Product Requirements Document
- `docs/TASKS.md` — Task list with acceptance criteria
- `docs/WORKSPACE_RULES.md` — Branching, commits, PRs
- `docs/SITE_MAP.md` — Site map description (hand-drawn submission in `docs/site-map.png`)
- `api/openapi.yaml` — Full OpenAPI 3.0 spec
- `api/README.md` — API setup + endpoint summary
- `client/README.md` — Client run modes

## Known issues / incomplete areas

- **Auth is prototype-grade** (SHA-256 + salt for the API; localStorage hashing for the deployed client). Replace with Supabase Auth or AWS Cognito before any real use.
- **Deployed client uses localStorage** for primary state, but the backend API and database are fully wired and proven via independent endpoints (see `/health`, `/moods`, `/books`). The client could swap to API mode by setting `window.VIBESHELF_API_URL`; this is documented in `client/README.md`.
- **Cover images** stored as base64 data URLs. For production, migrate to Supabase Storage.
- **No password reset flow** — out of scope for the prototype.
- **Genre is single-select** in Add form (schema supports many-to-many; future upgrade).
- **Render free tier sleep** — first request after 15 minutes of inactivity takes about 30 seconds.
- **RLS policies** in `db/03_policies.sql` are written but not enforced because the API uses the service-role key. They activate once the client moves to direct anon-key access.