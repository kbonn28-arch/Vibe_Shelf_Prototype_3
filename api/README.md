# VibeShelf API

Express server. Connects to Supabase via the **service-role key**.
The browser client must NOT talk to Supabase directly — only through this API.

## Local run

```bash
cd api
npm install
cp .env.example .env
# edit .env and paste in your SUPABASE_URL and SUPABASE_SERVICE_KEY
npm start
```

The server starts on `http://localhost:3000`.

## Environment variables

| Name | Required | Description |
|---|---|---|
| `PORT` | no | Defaults to 3000 |
| `SUPABASE_URL` | **yes** | `https://<ref>.supabase.co` |
| `SUPABASE_SERVICE_KEY` | **yes** | Service-role key from Supabase dashboard → Settings → API |

## Endpoints (summary)

See `openapi.yaml` for the full machine-readable spec.

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | Health check |
| POST | `/auth/signup` | Create user + profile |
| POST | `/auth/login` | Verify credentials |
| GET | `/moods` | List moods |
| GET | `/genres` | List genres |
| GET | `/books` | List books (filter `?mood=&genre=&q=`) |
| GET | `/books/:id` | Book detail |
| POST | `/books` | Create book |
| GET | `/shelf/:userId` | List shelf entries for user |
| POST | `/shelf` | Add a book to a shelf |
| PATCH | `/shelf/:entryId` | Update progress / favorite / rating |
| DELETE | `/shelf/:entryId` | Remove from shelf |
| GET | `/reviews/:bookId` | Public reviews for a book |
| POST | `/reviews` | Write a review |
| GET | `/recommend` | Mood-matched random recommendation |
| POST | `/recommend/log` | Log skip/save/not-interested |
| GET | `/profile/:userId` | Get profile |
| PATCH | `/profile/:userId` | Update profile |

## Smoke test

After the server is running:

```bash
# Linux / macOS
BASE_URL=http://localhost:3000 bash tests/smoke.sh

# Windows
set BASE_URL=http://localhost:3000 && tests\smoke.bat
```

Exits 0 on success, non-zero on any failure (scriptable for grading).

## Notes

- The service-role key bypasses RLS. Once the client moves to using the anon key directly, enable the policies in `db/03_policies.sql`.
- Authentication here is a prototype-grade SHA-256 + salt. For production, replace with Supabase Auth or AWS Cognito.
