# Architecture

## Stack
- HTML + CSS (single page source, one `<section class="page">` per A4 page)
- Google Chrome headless `--print-to-pdf` for the PDF; `--dump-dom` for the build self-check
- Bash for install/uninstall scripts

## Modules
| Module / dir | Responsibility |
|---|---|
| `framework/` | The installable payload: `global-CLAUDE.md` → `~/.claude/CLAUDE.md`, `templates/` → `~/.claude/templates/` |
| `scripts/` | `install.sh` (backup, then copy) and `uninstall.sh` (restore backup, remove templates) |
| `tests/` | `test_scripts.sh`: install/uninstall in a throwaway HOME; `test_guide.sh`: build + appendix fidelity + PDF text layer (`pdf_text.swift`) |
| `guide/src/` | `guide.html` (content) + `styles.css` (tokens, page grid, components) |
| `guide/assemble.sh` | Expands appendix markers into pages holding `framework/` files verbatim |
| `guide/build.sh` | Builds and self-checks `guide/think-prove-checkpoint.pdf` |
| `docs/` | This project's own memory, following the workflow it documents |

## Data flow
Author's live `~/.claude/` files → copied into `framework/` → readers run
`scripts/install.sh` → files land in the reader's `~/.claude/`.
`guide/src/guide.html` + `framework/` files → `guide/assemble.sh` (appendix pages, verbatim)
→ `guide/build.sh` → PDF → self-check (overflow, page count, appendix fidelity) → shared on
LinkedIn. Readers hand the PDF to their agent, which installs from the appendix.

## Patterns & conventions
- Design tokens (colors, fonts, spacing) live on `:root` in `styles.css`.
- Each page is self-contained: header label, headline with one mono highlight word, body,
  footer with page number.

## Gotchas
- See root `CLAUDE.md` → Gotchas.
