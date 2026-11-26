# Think · Prove · Checkpoint

A public guide (PDF and website) plus installable files for my Claude Code workflow, so others
can set it up, try it, and revert it. A portfolio piece showing project management with a
technical emphasis — **this repo is built with the workflow it describes.**

## Stack
- Guide: one HTML/CSS source → PDF via Google Chrome headless (no other dependencies)
- Website: the same source → static site (`site/dist/`, vanilla JS), served by Vercel
- Installer: bash scripts (macOS + Linux)
- Docs: Markdown

## Project map
- `framework/` — what readers install: `global-CLAUDE.md` + `templates/`
- `scripts/` — `install.sh` / `uninstall.sh`
- `tests/` — `test_scripts.sh`, `test_guide.sh`, `test_site.sh`
- `guide/` — `src/` (HTML + CSS + tokens), `assemble.sh`, `build.sh`, the built PDF
- `site/` — `src/` (template, CSS, JS), `build.sh`, `dist/` (the built site, committed)
- `project.json` — the facts: version, release date, repo, LinkedIn, site URL
- `docs/` — this project's own memory (committed publicly, on purpose)

## Conventions
- `framework/` is copied **from** the author's live `~/.claude/CLAUDE.md` and
  `~/.claude/templates/`; never edit only one side. **One deliberate exception:** in
  `framework/global-CLAUDE.md`, pronouns that mean the agent are marked "(the agent)" for
  readers (lines 3, 71, 91, 96), and the reader copy uses British spelling ("towards",
  "judgement", "behaviour"; `templates/spec.md`: "## Behaviour"). The author's live files keep
  their own wording; re-apply both after any re-sync (`docs/decisions.md`, 2026-11-24/25).
- No personal data in committed files beyond the author credit (name, university) and the
  LinkedIn link on the closing page (author's request). Never an email.
- Scripts never overwrite anything without a timestamped backup first.
- Facts (version, date, links) live only in `project.json`; elsewhere they are `{{placeholders}}`.
- Colors and fonts live only in `guide/src/tokens.css` (shared by print and web); tests fail
  on a color value anywhere else.
- Never invent experiences for the author. Illustrative examples are labeled as such.

## Gotchas
- Chrome print-to-PDF drops backgrounds unless `print-color-adjust: exact` is set.
- Plugins can be managed two ways: `claude plugin …` in the shell, or `/plugin …` inside
  Claude Code. Show both; verify syntax with `claude plugin --help` before publishing.
- macOS ships bash 3.2: no associative arrays, `mapfile`, or `${var,,}` in scripts.
- The public files must credit Karpathy (principles) and superpowers by Jesse Vincent (skills).

## Docs (read on demand — docs first, code second)
| Need | Read |
|---|---|
| What we're building and why | `docs/vision.md` |
| Where we left off | `docs/roadmap.md` → Current status |
| How the repo is structured | `docs/architecture/index.md` (→ guide, site, installer) |
| Feature list + status | `docs/features.md` |
| Why something was decided | `docs/decisions.md` |
| The guide's pages, look, build | `docs/specs/guide.md` |
| Install / uninstall scripts | `docs/specs/installer.md` |
| The website | `docs/specs/landing-page.md` |
| Implementation plan | `docs/plans/<feature>.md` |

## Commands
- Build everything: `guide/build.sh && site/build.sh` (in that order: the site copies the PDF)
- Build PDF: `guide/build.sh` (exit 0 = no overflow, page count matches)
- Test scripts: `tests/test_scripts.sh`
- Test guide build: `tests/test_guide.sh` (fixtures + PDF text layer via macOS PDFKit; fails if the committed PDF is stale)
- Test website: `tests/test_site.sh` (structure, facts, phone width, up-to-date `site/dist`)

## Project-specific checkpoint items
- If `guide/src/`, `site/src/`, `project.json`, tests or docs changed: `guide/build.sh && site/build.sh`
  **after** the docs (they change page 21's counts), then all three test files; read changed pages.
- If the author's global files changed: re-sync `framework/`.
- The user creates the GitHub repo and pushes; Claude never does. Vercel redeploys on push.
