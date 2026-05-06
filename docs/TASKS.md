# VibeShelf — Task List

Each task references the user story from the Analyst's Level 3 Specification (§ 2a) and lists explicit Acceptance Criteria (AC) that define "done."

---

## T-01 · Auth: Sign-up and Log-in
**User story:** New users supply email + username + password; returning users supply email + password.
**Description:** Build the auth screen, signup endpoint, login endpoint, and session handling. Username + email uniqueness enforced.
**AC:**
- Signup with a duplicate email returns 409 `email_taken`.
- Signup with a duplicate username (case-insensitive) returns 409 `username_taken`.
- Successful login redirects to the Mood Selection pop-up before any other page loads.
- Logout clears session and returns user to the Auth screen.

---

## T-02 · Mood Selection Pop-up (NEW in L3)
**User story:** "As a busy reader I want to select my current mood when I open the app."
**AC:**
- Pop-up appears immediately after every login — required.
- Cannot be dismissed without selecting a mood. Backdrop click is a no-op.
- 9 moods available: Cosy, Thrilling, Adventurous, Romantic, Reflective, Curious, Whimsical, Dark, Hopeful.
- "Random Mood" button picks one for the user.
- Selected mood persists for the rest of the session and is shown as a banner on every page.

---

## T-03 · Home Dashboard
**User story:** Receive mood-matched book recommendations.
**AC:**
- Greets user by username.
- Displays active-mood banner with a "change" link that re-opens T-02 pop-up.
- Three nav cards (Browse Library, Add New Item, Get Recommendations) — each is a full-page transition.
- Recent Activity panel shows the 5 most recent shelf additions (or empty state).

---

## T-04 · Library Page
**User story:** "Organize books in my digital bookshelf."
**AC:**
- Grid of book cover cards with title + author + status badge.
- Search bar matches title, author, or genre.
- Mood filter chips (replaces old All Types dropdown).
- Genre filter chips.
- "Favorites only" view toggle.
- Empty state with CTA when shelf is empty.
- Floating + button bottom-right opens Add Book form.

---

## T-05 · Library — Book Card Inline Controls (NEW in L3)
**User story:** "★ favourite a book by tapping a star icon", "delete a book using a 3-dot menu", "view and update reading progress from a floating tab."
**AC:**
- Tapping ★ toggles `is_favorited` and persists immediately.
- 3-dot menu shows: View details, Delete from shelf. Delete prompts for confirmation.
- Floating progress button opens an inline panel inside the card (no navigation away).
- Closing the panel via Cancel restores the card without saving.

---

## T-06 · Inline Progress Tab + Personal Rating Popup (NEW in L3)
**User story:** "Enter a personal rating in a pop-up when I mark a book as Finished."
**AC:**
- Progress panel saves status, start_date, finish_date.
- Setting status to "finished" (when previous status was not finished) automatically opens the Personal Rating pop-up.
- Rating selector accepts 1–5 stars; optional private note.
- Skip button closes the pop-up without writing rating.
- Save button writes `personal_rating` and `personal_note` to BookshelfEntry — private, never shown to other users.

---

## T-07 · Add New Item Form
**User story:** "Add a book with title, author, genre, cover image, and ISBN."
**AC:**
- Title and author are required; everything else optional.
- Cover image: file upload (preferred) or URL fallback.
- Genre dropdown.
- Mood tags: max 2 — selecting a 3rd shows a toast and is rejected.
- Status dropdown defaults to "Want to Read."
- Removed fields per Interview 3: Media Type, Music Type, Year.
- After save, redirects to Library and the new book appears at the top.

---

## T-08 · Get Recommendations
**User story:** "Receive book recommendations based on my selected mood."
**AC:**
- Reads session mood; shows one mood-matched book at a time.
- Save adds the book to user's shelf with status `want_to_read`.
- Skip suppresses the book for the remainder of the session only.
- Not Interested suppresses the book and logs `not_interested` in the recommendations table.
- Empty state when pool is exhausted, with a "pick a new mood" CTA.

---

## T-09 · Book Detail Page
**User story:** "View community reviews connected to usernames and bios."
**AC:**
- Renders cover, title, author, ISBN, genre + mood tags, description.
- Shows community average rating computed from public reviews only.
- Lists public reviews with username, bio snippet, stars, text, date.
- Shows user's private personal rating if set (never shown to others).
- "Write Review" opens a modal: 1–5 star selector, text area, public/private toggle.

---

## T-10 · Profile Page
**User story:** "View community reviews connected to usernames."
**AC:**
- Shows avatar, username, public bio.
- Stats: On Shelf / Reading / Finished / Favorites counts.
- Lists user's public reviews.
- Edit profile modal updates username (with uniqueness check) and bio.

---

## T-11 · Database — Schema + Seed
**Description:** Provide SQL files that create the schema and seed realistic test data.
**AC:**
- `db/01_schema.sql` creates every entity from the L3 spec with correct PKs/FKs and constraints.
- `db/02_seed.sql` inserts 3–5 rows per table honoring all FK relationships.
- Running both files on a clean Supabase project reproduces the full state without manual intervention.
- The "max 2 mood tags per book" rule is enforced via a Postgres trigger.

---

## T-12 · Backend API (Express)
**Description:** Independent API server that the client uses for all data operations.
**AC:**
- Server runs locally on `http://localhost:3000`.
- Connects to Supabase via service-role key from `.env`.
- Implements at least 3 GET endpoints (`/moods`, `/genres`, `/books`, `/recommend`, `/shelf/:userId`, `/reviews/:bookId`) and at least 1 write endpoint (`/auth/signup`, `/books`, `/shelf`, `/reviews`).
- All routes return 4xx errors for bad input, with a stable `error` code in JSON.
- The client never talks to Supabase directly.
- `api/openapi.yaml` documents every route.
- `tests/smoke.sh` exercises ≥4 endpoints and exits non-zero on failure.

---

## T-13 · Deployment
**Description:** Public deployable version.
**AC:**
- Static client deploys to AWS Amplify with no build step.
- `amplify.yml` checked into the root.
- README contains the live URL.
- Independent API deployable as Lambda via Serverless Framework (`api/serverless.yml`).
