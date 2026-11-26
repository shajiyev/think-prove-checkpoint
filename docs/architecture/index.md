# Architecture

Three parts, two of them built: the **guide** (PDF), the **website** (built from the guide's
source), and the **installer** (framework payload + scripts). They share one source for facts
(`project.json`), one for the look (`guide/src/tokens.css`) and one for content
(`guide/src/guide.html`).

## Stack
- HTML + CSS (+ a little vanilla JS on the website); bash + BWK awk for every build step
- Google Chrome headless: `--print-to-pdf` (PDF), `--dump-dom` (self-checks, tests), `--screenshot` (link preview)
- No other dependencies: no framework, no package manager, no `jq`

## Which doc for what
| Working on… | Read |
|---|---|
| The PDF: pages, appendix, build self-check | `guide.md` |
| The website: build, layout, behaviour, deploy | `site.md` |
| `framework/`, `install.sh`, `uninstall.sh` | `installer.md` |

## Data flow
```
project.json ─┐
guide.html ───┼─ guide/assemble.sh ─┬─▶ guide/build.sh ─▶ guide/think-prove-checkpoint.pdf
framework/ ───┘   (facts, page 21   │                                    │ (copied)
                   counts, appendix)└─▶ site/build.sh ─▶ site/dist/ ◀────┘ ─▶ Vercel (serves only)
tokens.css ──▶ styles.css (print) · web.css (screen)
Author's ~/.claude/ ──copied──▶ framework/ ──▶ scripts/install.sh ──▶ reader's ~/.claude/
```
Build order: `guide/build.sh && site/build.sh`, then the three test files.

## Patterns & conventions
- Facts (version, date, links) only in `project.json`, as `{{placeholders}}` elsewhere.
- Colours and fonts only in `tokens.css`; tests fail on a colour value anywhere else.
- Built outputs (PDF, `site/dist/`) are committed; tests build into temp folders and never touch them.

## Gotchas
- See root `CLAUDE.md` → Gotchas, and each area doc.
