# Architecture

## Stack
- HTML + CSS (single page source, one `<section class="page">` per A4 page)
- Google Chrome headless `--print-to-pdf` for the PDF; `--screenshot` for page previews
- Bash for install/uninstall scripts

## Modules
| Module / dir | Responsibility |
|---|---|
| `framework/` | The installable payload: `global-CLAUDE.md` → `~/.claude/CLAUDE.md`, `templates/` → `~/.claude/templates/` |
| `scripts/` | `install.sh` (backup, then copy) and `uninstall.sh` (restore backup, remove templates) |
| `tests/` | `test_scripts.sh`: install/uninstall cases, each in a fresh `HOME=$(mktemp -d)` |
| `guide/src/` | `guide.html` (content) + `styles.css` (tokens, page grid, components) |
| `guide/build.sh` | Builds `guide/think-prove-checkpoint.pdf` from `guide/src/` |
| `docs/` | This project's own memory, following the workflow it documents |

## Data flow
Author's live `~/.claude/` files → copied into `framework/` → readers run
`scripts/install.sh` → files land in the reader's `~/.claude/`.
`guide/src/` → `build.sh` → PDF → shared on LinkedIn and linked from the README.

## Patterns & conventions
- Design tokens (colors, fonts, spacing) live on `:root` in `styles.css`.
- Each page is self-contained: header label, headline with one mono highlight word, body,
  footer with page number.

## Gotchas
- See root `CLAUDE.md` → Gotchas.
