# VibeShelf — Site Map (reference)

This file describes the page hierarchy. **The graded submission is a hand-drawn scan/photo** — see `site-map.png` (you draw it on paper). Use this file as your reference when drawing.

## Hierarchy (tree shape — NOT a mind map)

```
[ Auth Screen ]                            ← entry point for unauth users
       │
       │  on successful login/signup
       ▼
[ Mood Selection Pop-up ]                  ← REQUIRED, cannot dismiss
       │
       │  mood chosen
       ▼
[ Home Dashboard ]  ◄──────────────────┐   ← root for all auth users
   ├──► [ Library Page ]                │      (Home/Library/Discover/Profile
   │       ├──► [ Add New Item Form ]   │       are persistent in nav bar)
   │       │      │  on save
   │       │      └──► (back to Library)
   │       │
   │       ├──► [ Inline Progress Panel ] (overlay on book card)
   │       │      │  status → finished
   │       │      └──► [ Personal Rating Pop-up ] (modal)
   │       │
   │       └──► [ Book Detail Page ]
   │              └──► [ Community Review Form ] (modal)
   │
   ├──► [ Get Recommendations ]
   │       │  Save / Skip / Not Interested
   │       └──► (returns to itself with next book)
   │
   └──► [ Profile Page ]
           └──► [ Edit Profile Modal ]
```

## How to draw it on paper

1. Take a sheet of unlined paper, landscape orientation.
2. Top-left, draw a box labelled **Auth Screen**. Annotate "entry point — unauthenticated."
3. Below it, draw an arrow down to a box labelled **Mood Selection Pop-up**. Annotate "required — cannot dismiss."
4. Arrow down to a wide box labelled **Home Dashboard**.
5. From Home, draw three arrows fanning out to: **Library**, **Get Recommendations**, **Profile**.
6. Under **Library**, branch down to:
   - **Add New Item Form** → arrow back up to Library (annotate "after save")
   - **Inline Progress Panel** → annotate "overlay on book card"
   - From Inline Progress, draw an arrow to **Personal Rating Pop-up** (annotate "auto on Finish")
   - **Book Detail** → arrow down to **Community Review Form** (annotate "modal")
7. Under **Profile**, branch down to **Edit Profile Modal**.
8. Under **Get Recommendations**, draw a self-loop arrow with the label "Save / Skip / Not Interested → next book."
9. Verify the shape: every parent is **above** every child. There should be NO arrows pointing back upward except the explicit "after save → Library" returning arrow.

## Then

- Photograph or scan the drawing.
- Save it as `docs/site-map.png` (or .jpg).
- Commit it. Done.

## Quick check (avoid the mind-map trap)

- ✗ Mind map: a central blob with everything radiating out from it equally.
- ✓ Tree: clear root at top, children flowing strictly down, deeper nodes further down.

If you see arrows criss-crossing or going back up the tree (other than the documented "after save" return), redraw it.
