# Roadmap

## Current status
_Last updated: 2026-11-25_
- **Done:** M1–M3 (design, installer, 33-page guide); v1.0 tagged, repo public.
- **Done (M5, L1–L6):** the website, built from the guide's own source: `project.json` holds the
  facts, `tokens.css` the look; `site/build.sh` → `site/dist/` (hero, 24 sections, navigation,
  animations, copy buttons, link preview). 43 site + 44 guide + 24 script checks pass; a stale PDF or site fails a test.
- **Next (user):** hand check the site; commit; L7: deploy on Vercel (root `site/dist`, no
  build), then the link goes into `project.json` and the README. Then M4's LinkedIn post, with the link.

## Milestones
### M1 — Foundation
- [x] Design agreed
- [x] Project set up from templates
- [x] Specs reviewed
- [x] Plan written

### M2 — Installable framework
- [x] `framework/` synced from the author's live files
- [x] `install.sh` / `uninstall.sh`, tested in a throwaway HOME
- [x] README (what, setup, revert)

### M3 — The guide
- [x] Style system + build pipeline (one sample page approved)
- [x] All pages written and laid out
- [x] Verified: build self-check passes, every page read, commands checked, paths exist

### M4 — Publish (user)
- [x] User creates the GitHub repo and pushes
- [x] Repo link added to the PDF; final build
- [x] User makes the repo public (v1.0 tagged)
- [ ] LinkedIn post (after M5, with the website link). Include: "It's a short read on how I work
  with Claude Code. If you like it, your agent can set it up for you."

### M5 — Website (`docs/plans/landing-page.md`)
- [x] L1 Facts in one place (`project.json`)
- [x] L2 Shared tokens (`tokens.css`)
- [x] L3 Site build: structure
- [x] L4 Screen layout and look
- [x] L5 Behaviour: reveal, navigation, progress, menu, copy
- [x] L6 Link preview, committed `site/dist`, freshness test
- [ ] L7 Deploy on Vercel (user) and add the link
