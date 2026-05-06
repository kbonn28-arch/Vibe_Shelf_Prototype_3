# VibeShelf Client

Single-file SPA. No build step.

## Two run modes

### Mode A — Offline / mock (default)
Just open `index.html` in a browser. Data persists in `localStorage`. Good for design review and screenshots — every page works without any backend.

### Mode B — Live API + Supabase
1. Start the API: see `../api/README.md`.
2. Edit `index.html` and set `window.VIBESHELF_API_URL` to your running API root, e.g.:

```html
<script>window.VIBESHELF_API_URL = 'http://localhost:3000';</script>
```
This must be **above** the main `<script>` block. Or you can set it in the browser console before loading the page.

3. Reload — all book / review / recommendation data now comes from Supabase via the Express API. The browser does NOT talk to Supabase directly.

## Local dev

```bash
cd client
python3 -m http.server 8080
# or
npx http-server -p 8080
```

Open <http://localhost:8080>.

## Site map

The pages this client renders (matching the Analyst's Skeleton):

| Page                     | Route key              |
|--------------------------|------------------------|
| Login / Sign-Up          | `auth`                 |
| Mood Selection Pop-up    | modal — required step  |
| Home Dashboard           | `home`                 |
| Library                  | `library`              |
| Inline Progress Panel    | overlay on book card   |
| Personal Rating Pop-up   | modal — auto on Finish |
| Add New Item             | `add`                  |
| Get Recommendations      | `recommend`            |
| Book Detail              | `book:<id>`            |
| Community Review Form    | modal                  |
| Profile                  | `profile`              |
