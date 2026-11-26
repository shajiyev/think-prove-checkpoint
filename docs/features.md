# Features

Status: `planned` · `in progress` · `done` · `dropped`

| Feature | Status | Spec | Notes |
|---|---|---|---|
| Guide PDF (33 pages) | done | `specs/guide.md` | Doubles as the installer; dry run passed; author reviewed |
| Build pipeline (HTML → PDF) | done | `specs/guide.md` | Chrome headless; self-checks overflow, page count, appendix fidelity |
| "What you need" box (17) | done | `specs/guide.md` | Plan, install command, Git, for newcomers; 00 points to it |
| Appendix for agents | done | `specs/guide.md` | `framework/` files verbatim, generated + verified at build |
| Framework payload (`framework/`) | done | `specs/installer.md` | From live `~/.claude/`; agent pronouns marked for readers |
| Install script | done | `specs/installer.md` | Backup first, never silent overwrite |
| Uninstall script | done | `specs/installer.md` | Restores backup |
| README | done | `specs/installer.md` | Mirrors the guide (agent path first); optional manual install for technical readers |
| Project facts (`project.json`) | done | `specs/landing-page.md` | Version, date, links filled into PDF and site; README checked by tests |
| Shared design tokens | done | `specs/landing-page.md` | `guide/src/tokens.css`, used by print and web |
| Website (landing page) | done | `specs/landing-page.md` | Live at think-prove-checkpoint.vercel.app; redeploys on push |
| LinkedIn carousel teaser | dropped (for now) | — | Possible later, separately |
