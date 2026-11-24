# Think · Prove · Checkpoint

A public guide (PDF) plus installable files for my Claude Code workflow, so others can set
it up, try it, and revert it. A portfolio piece showing project management with a
technical emphasis — **this repo is built with the workflow it describes.**

## Stack
- Guide: one HTML/CSS source → PDF via Google Chrome headless (no other dependencies)
- Installer: bash scripts (macOS + Linux)
- Docs: Markdown

## Project map
- `framework/` — what readers install: `global-CLAUDE.md` + `templates/`
- `scripts/` — `install.sh` / `uninstall.sh`
- `tests/` — `test_scripts.sh` (runs the scripts against a throwaway HOME)
- `guide/` — `src/` (HTML + CSS), `build.sh`, the built PDF
- `docs/` — this project's own memory (committed publicly, on purpose)

## Conventions
- `framework/` is copied **from** the author's live `~/.claude/CLAUDE.md` and
  `~/.claude/templates/`; never edit only one side.
- No personal data in committed files beyond the author credit (name, university).
- Scripts never overwrite anything without a timestamped backup first.
- Guide colors and fonts are CSS tokens on `:root`; don't hardcode them in pages.
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
| How the repo is structured | `docs/architecture.md` |
| Feature list + status | `docs/features.md` |
| Why something was decided | `docs/decisions.md` |
| The guide's pages, look, build | `docs/specs/guide.md` |
| Install / uninstall scripts | `docs/specs/installer.md` |
| Implementation plan | `docs/plans/<feature>.md` |

## Commands
- Build PDF: `guide/build.sh` (exit 0 = no overflow, page count matches)
- Test scripts: `tests/test_scripts.sh`

## Project-specific checkpoint items
- If `guide/src/` changed: run `guide/build.sh` (must exit 0) and read the changed pages in the PDF.
- If the author's global files changed: re-sync `framework/`.
- The user creates the GitHub repo and pushes; Claude never does.
