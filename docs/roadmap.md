# Roadmap

## Current status
_Last updated: 2026-11-24_
- **Done:** design, project setup, specs, plans (`docs/plans/installer.md`, `docs/plans/guide.md`);
  **M2 complete:** framework payload, `install.sh`, `uninstall.sh` (24/24 tests pass), README + LICENSE.
- **In progress:** M3 — all 32 pages built (G1–G7): cover, 00–21, closing, agent instructions,
  appendix verified byte for byte and in the PDF text layer (19 tests). Dry run with a fresh
  agent passed. Waiting for the author's full read.
- **Next:** G8 — README leads with the agent path, refresh page 21's numbers, final build; then the
  user makes the repo public and posts.

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
- [ ] Verified: build self-check passes, every page read, commands checked, paths exist

### M4 — Publish (user)
- [ ] User creates the GitHub repo and pushes
- [ ] Repo link added to the PDF; final build
- [ ] LinkedIn post
