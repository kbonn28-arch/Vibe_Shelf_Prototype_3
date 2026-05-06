# VibeShelf

> A mood-driven book discovery and personal library web app.
> Pick a vibe, get a story.

**Live demo:** _[Paste your AWS Amplify URL here after deploying]_

---

## What this is

VibeShelf is a single-page web app that helps readers decide what to read next based on how they're feeling **right now**. Every session begins with a mood pop-up; that mood drives the recommendation engine for the rest of the session. Users build a personal shelf, track reading progress inline on each book card, favorite books, write community reviews tied to their public profile, and keep private personal ratings.

This is the Level 3 / Prototype 2 deliverable, built directly from the Analyst's Final Specification (Interview 3 feedback incorporated).

## Repo layout

```
vibeshelf/
├── client/        # Frontend SPA — open client/index.html
├── api/           # Express API server (Node) + OpenAPI spec
├── db/            # SQL schema + seed for Supabase
├── docs/          # PRD, task list, workspace rules, site map
├── tests/         # Smoke tests (bash + windows)
├── amplify.yml    # AWS Amplify static-deploy config
└── README.md      # This file
```

## Tech stack

| Layer | Tool |
|---|---|
| Frontend | Vanilla HTML/CSS/JS, single-file SPA (no build step) |
| Hosting (FE) | AWS Amplify (static) |
| Backend API | Node.js + Express, runs locally on `:3000` |
| Database | Supabase (Postgres) |
| Fonts | Fraunces (display) + Manrope (body) via Google Fonts |

The browser client does **not** talk to Supabase directly — all DB access goes through the Express API using the service-role key.

## Quick start

### 1. Database
```bash
# In Supabase: create a new project, then run in SQL Editor:
#   db/01_schema.sql
#   db/02_seed.sql
# Verify the 'book' table has 5 rows and 'mood' has 6.
```

### 2. API
```bash
cd api
npm install
cp .env.example .env
# edit .env — paste in SUPABASE_URL and SUPABASE_SERVICE_KEY
npm start
# → API listening on http://localhost:3000
```

### 3. Client
```bash
cd client
python3 -m http.server 8080
# open http://localhost:8080 in a browser
```

To wire the client to the live API, add this line to `client/index.html` **above** the main `<script>` block:
```html
<script>window.VIBESHELF_API_URL = 'http://localhost:3000';</script>
```
Without this line the client uses `localStorage` (offline / mock mode).

### 4. Smoke test
```bash
# with the API running:
BASE_URL=http://localhost:3000 bash tests/smoke.sh
# Windows:
set BASE_URL=http://localhost:3000 && tests\smoke.bat
```

## Documentation

- [`docs/PRD.md`](docs/PRD.md) — Product Requirements Document
- [`docs/TASKS.md`](docs/TASKS.md) — Task list with acceptance criteria
- [`docs/WORKSPACE_RULES.md`](docs/WORKSPACE_RULES.md) — Branching, commits, PRs
- [`docs/SITE_MAP.md`](docs/SITE_MAP.md) — Site map description (hand-drawn submission in `docs/site-map.png`)
- [`api/openapi.yaml`](api/openapi.yaml) — Full OpenAPI 3.0 spec
- [`api/README.md`](api/README.md) — API setup + endpoint summary
- [`client/README.md`](client/README.md) — Client run modes

## Deploying

### Frontend (AWS Amplify)
1. Open the AWS Amplify console.
2. **New app → Deploy without Git provider**.
3. Drag the `client/` folder into the upload zone. (Or connect the GitHub repo and set the build root to `client/`.)
4. Amplify gives you a public URL within ~30 seconds.

### Backend
For local grading: see step 2 above.
For production: deploy `api/` as AWS Lambda via Serverless Framework, or as a small EC2/Render service.

## Demo credentials

Seed data creates 4 users; passwords are pseudo-hashed for the prototype only. Use the API `/auth/signup` endpoint (or the Sign-Up form in the UI) to create your own account and test the full flow.

Suggested demo flow:
1. Sign up with any email + username.
2. Mood popup appears — pick "Cosy" or click 🎲 Random.
3. From Home, click **Get Recommendations** → save / skip / not-interested.
4. Click **Library** in nav → ★, 3-dot menu, 📈 progress on each card.
5. Set a book to "Finished" — Personal Rating popup auto-opens.
6. Floating **+** button (bottom-right) → Add Book → redirects to Library.
7. Click any cover → Book Detail → Write Review.
8. **Profile** → Edit profile.
9. Sign out, sign back in — data persists.

## Known issues / incomplete areas

- **Auth is prototype-grade** (SHA-256 + salt). Replace with Supabase Auth or AWS Cognito before any real use.
- **Cover images** stored as base64 data URLs in offline mode. For live mode, migrate to Supabase Storage.
- **No password reset flow** — out of scope for the prototype.
- **Genre is single-select** in Add form (schema supports many-to-many; future upgrade).
- **RLS policies** in `db/03_policies.sql` are not exercised because the API uses the service-role key. They become relevant once the client moves to direct anon-key access.
