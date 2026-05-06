# VibeShelf — Workspace Rules

These rules apply to every contributor working in this repo.

## Branching

- `main` is **always deployable**. Never push directly to it.
- Feature work goes on a short-lived branch named `feat/<short-slug>` (e.g. `feat/mood-popup`).
- Bug fixes use `fix/<short-slug>`.
- Documentation-only updates use `docs/<short-slug>`.
- Branches are deleted after merge.

## Commit messages

Use **Conventional Commits**:

```
<type>(<scope>): <short imperative summary>

<optional longer body>
```

| Type | When to use |
|---|---|
| `feat` | New user-visible feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Internal code change, no behavior change |
| `chore` | Build, deps, tooling |
| `test` | Adding or fixing tests |

Examples:
```
feat(library): add 3-dot menu with delete action
fix(api): reject star_rating > 5 with 400
docs(readme): document amplify deploy steps
```

## Pull requests

- Every change goes through a PR — even one-line edits.
- PR title follows the same Conventional Commits pattern.
- PR description must include:
  - **What** changed
  - **Why** (link the related task ID from `docs/TASKS.md`, e.g. T-06)
  - **How to test** (manual steps or a smoke command)
- At least one teammate must review and approve before merge.
- Squash-merge into `main`.

## Code review

- Reviewers focus on: correctness, spec alignment (does this match the Analyst's L3 spec?), readability, test coverage.
- Reviewers leave **specific, actionable** comments. Avoid "what about X?" — say "consider X because Y."
- Authors respond to every comment, either with a code change or a brief explanation.

## File and naming conventions

- File names: `kebab-case.html`, `kebab-case.js`. Exceptions: `README.md`, `SKILL.md`-style ALLCAPS markdown docs.
- JS variables and functions: `camelCase`.
- JS constants and global config: `UPPER_SNAKE_CASE`.
- React components (if added later): `PascalCase`.
- Database identifiers: `snake_case` (matches Postgres convention and the Analyst's schema).
- API route paths: `lowercase`, hyphenated multi-word (`/recommend/log`, not `/recommend_log`).

## Folder structure

```
vibeshelf/
├── client/                # Frontend SPA (single-file or future React)
│   ├── index.html
│   └── README.md
├── api/                   # Express API server
│   ├── server.js
│   ├── openapi.yaml
│   ├── package.json
│   ├── .env.example
│   └── README.md
├── db/                    # SQL migrations + seed
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   └── 03_policies.sql
├── docs/                  # PRD, tasks, workspace rules, site map
│   ├── PRD.md
│   ├── TASKS.md
│   ├── WORKSPACE_RULES.md
│   └── site-map.png       # hand-drawn scan
├── tests/                 # Smoke and integration tests
│   ├── smoke.sh
│   └── smoke.bat
├── amplify.yml            # AWS Amplify build config
├── .gitignore
└── README.md
```

## Secrets

- Never commit `.env`. Always use `.env.example` as the template.
- Never log full Supabase service-role keys, even partially, in PR descriptions.
- If a secret is committed by accident: rotate it in the Supabase dashboard immediately, then `git rm --cached` and force-push only after rotation.

## Done means done

A task is "done" when:
1. Code is merged to `main`.
2. The acceptance criteria in `docs/TASKS.md` are demonstrably met.
3. Documentation is updated (README, OpenAPI, screenshots if applicable).
4. The smoke test still passes.
