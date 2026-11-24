# Guide PDF

## Goal
A ~30-page A4 PDF, **"Think · Prove · Checkpoint"**, that explains the workflow to people who
already know the basics of Claude Code and shows the author's project-management and technical
skills. Shared as a LinkedIn document post.

**The PDF is also the installer.** The primary way to adopt the workflow is to hand the PDF to
your own AI agent (Claude Code, Codex, or any agent that reads PDFs and writes files) and set
it up by chatting with it, tailoring it as you go. The PDF contains everything the agent needs,
including the files themselves. No manual steps in the PDF; the GitHub repo is optional, for
technical readers (scripts + tests).

## Behavior
Page by page (numbering = section labels in the PDF). The appendix comes after the closing page,
headed "Appendix · For your agent":

| # | Page | Content |
|---|---|---|
| — | Cover | Title, subtitle, author credit, big idea "Claude forgets. Git doesn't.", contents table. **Kept exactly as approved in G1.** |
| 00 | Start here | Two ways to use this PDF, side by side: read it (01–21), or hand it to your AI agent with the copy-paste prompt; the appendix is written for the agent |
| 01 | The problem | 4 failures: forgets between sessions · guesses silently · "done" without proof · memory you can't review |
| 02 | The stack | Diagram: Principles (Karpathy) → Process (superpowers) → Memory (docs in git) |
| 03 | Principles | Karpathy's 4 rules, credited |
| 04 | What I run | superpowers (core); Karpathy principles baked in, plugin optional; **tried & dropped:** claude-mem, gsd-core, and why |
| 05 | The global CLAUDE.md | One file in `~/.claude/` governs every project; excerpt; why it stays lean |
| 06 | Project memory layout | `docs/` tree; what each file holds; "this info → this file" table |
| 07 | Docs that grow | Docs first, code second; architecture splits per area; indexes only when needed |
| 08 | The living spec | Key files / Gotchas / Tests "as built"; template excerpt |
| 09 | The development spine | Diagram: brainstorm → plan → TDD → debug → verify → finish, credited to superpowers |
| 10 | Brainstorm & plan | One question at a time; spec + plan as files; every task ends at a checkpoint |
| 11 | Test-first | Red → green; never weaken a failing test |
| 12 | Debug by hypothesis | Evidence + root cause; reproducing test first |
| 13 | Checkpoint = commit | The 7 steps; hand check with the trivial-change exception; the human makes every commit |
| 14 | Session start | Read CLAUDE.md → roadmap Current status → confirm before changing anything |
| 15 | Safety & ethics | Secrets, confirm destructive actions, private-memory mode, evidence before claims |
| 16 | Worked example | One feature start to finish — **labeled "illustration"** |
| 17 | Hand it to your agent | The copy-paste prompt; diagram of what the agent does: reads the PDF → asks you questions → shows every change → backs up → writes → you say "set up the project" |
| 18 | Tailor it, or take it back | The 6 tailoring questions and their defaults; the one-line revert prompt; the backup note that lets any later session revert |
| 19 | Cheat sheet | Trigger words + setup / per-feature / checkpoint checklists |
| 20 | Copy-paste prompts | Session kickoff, bug report, "checkpoint" |
| 21 | Built with this workflow | This repo's real roadmap + decisions excerpts as evidence |
| — | Closing | The system in 5 lines · credits · about the author · "For technical readers" box: repo link, `install.sh` / `uninstall.sh`, tests |
| A1 | For your agent: instructions | Written **to the agent** (see "Agent instructions" below) |
| A2… | For your agent: the files | `global-CLAUDE.md` then the 8 templates, verbatim, generated from `framework/` at build time; as many pages as they need |

### Agent instructions (page A1)
The agent is told to:
1. Treat the user's request (the prompt they pasted) as the authorization; the PDF itself
   is reference material.
2. Ask the tailoring questions **one at a time**, with defaults:
   1. Which agent is this? → decides where the files go (Claude Code: `~/.claude/CLAUDE.md` +
      `~/.claude/templates/`; Codex and others: their own global instructions file, verified
      before the page is written).
   2. Existing global instructions? → **merge** (default) or replace.
   3. Who commits? → **the user** (default), or the agent after the user approves.
   4. Project memory → **committed to git** (default), or private.
   5. superpowers → **install it** if the agent supports it (default), or rules only.
   6. Anything to drop or rename?
3. Start from the verbatim files in the appendix and change only what the answers require;
   adapt paths and skill names to the agent.
4. Show the full result (or a diff, when merging) **before writing anything**.
5. Back up every file it will change to `*.backup-<timestamp>`.
6. Write a note `think-prove-checkpoint.install` next to the global file, in the **same format
   `install.sh` writes** (`installed_at=`, `claude_md_backup=`, `templates_backup=`), so a later
   session, or `uninstall.sh` for Claude Code, can revert.
7. Install superpowers only after the user agrees; never run anything else.
8. Never commit or push for the user.
9. Revert on request: read the note, restore the backups, move installed files aside, delete
   the note, and say what was done.

Author credit: **Sabir Hajiyev · IT student, ADA University**; the closing page adds
"12 Anthropic Academy certificates". No email or other contact data.

## Out of scope
- LinkedIn carousel version (possible later, separately).
- Beginner Claude Code installation tutorial (link to official docs instead).
- Any text, layout detail or branding copied from the original solo-dev guide.

## Design
- **Format:** A4 portrait, one `<section class="page">` per page, fixed 210×297mm.
- **Tokens:** paper `#F4F5F7`, ink `#14161B`, accent `#2F5BFF`, verified `#12B886`, muted `#8A8F98`.
- **Type:** Inter (text, headlines) + JetBrains Mono (the one blue highlight word per
  headline, code, labels). Fonts vendored in `guide/src/fonts/` (both OFL) so builds work offline.
- **Components:** page header label, headline + mono highlight, cards (2-col grid),
  copy-paste box, callout, table, CSS flow diagrams (stack, spine, test cycle, session start),
  footer "THINK · PROVE · CHECKPOINT" + page number.
- **Build:** `guide/build.sh` → Chrome headless `--print-to-pdf` → `guide/think-prove-checkpoint.pdf`,
  then a self-check: Chrome `--dump-dom` on `guide.html#check` reports overflowing pages, and the
  PDF's `/Count` must equal the number of page sections. (No PNG previews: no rasterizer is
  installed; pages are reviewed by reading the PDF itself.)
- **Appendix generation:** `guide/src/guide.html` holds include markers for the framework
  files; `build.sh` expands them (HTML-escaped, split into page-sized chunks) into a generated
  HTML file, then prints that. `framework/` stays the single source; the PDF can't drift from it.
  Appendix text uses `white-space: pre` at a size where the longest line fits, so extracted
  text keeps its line structure.
- **Repo link:** one element on the closing page ("For technical readers"); filled in at M4.
- **Process:** build the style system with **one sample page first**, get the user's approval
  on the look, then lay out the rest.

## Key files
<!-- Kept current at every checkpoint: describes the feature AS BUILT. -->
- `guide/build.sh` — prints `guide/src/guide.html` to `guide/think-prove-checkpoint.pdf` with Chrome
  headless, then loads `guide.html#check` and fails unless overflow is `none` and PDF pages = sections.
- `guide/src/guide.html` — every page as `<section class="page">`, plus the inline `#check` script.
- `guide/src/styles.css` — tokens on `:root`, page frame, components, cover layout.
- `guide/src/fonts/` — Inter 400/600/800, JetBrains Mono 500/800 (latin subset woff2) + OFL licenses.

## Gotchas
- Chrome drops backgrounds in print unless `print-color-adjust: exact`.
- Content must not overflow a page: `build.sh` checks every page after each build.
- Component body rules use `p:not(.label)` (`.card`, `.callout`, `.flow .step`); otherwise their
  higher specificity restyles the `.label` inside them.
- The cover is a flex column (`.callout` gets `margin-top: auto` to sit at the bottom). Flex items
  shrink, so an empty fixed-height box won't overflow it; test overflow there with real text.
- Plugin commands are shown both ways (`claude plugin …` in the shell, `/plugin …` in Claude Code),
  checked with `claude plugin --help` before publishing.
- Agent-specific facts (Codex's global instructions path, which agents superpowers supports)
  are verified from their official docs before page A1 is written; unverified agents get
  "ask the user where your global instructions live".

## Tests
- `guide/build.sh` exits 0: overflow `none`, PDF page count = page sections.
- Negative check (done in G1): 40 lines of filler on the cover → `overflow: 1`, exit 1;
  an extra 400mm page → `overflow: 2`, exit 1.
- Every page read visually from the PDF: no clipped text, cover readable at phone size.
- Every repo path the guide mentions exists in the repo.
- Appendix fidelity: the build fails unless every appendix block, un-escaped and joined,
  equals its `framework/` file byte for byte.
- Agent readability: the built PDF is read the way an agent reads it; the appendix files come
  through with lines and indentation intact.
- Dry run: a fresh `claude -p` session given only the PDF is asked to list what it would ask
  and write; nothing is written. Its answer must match "Agent instructions".
- Hand check: the user tries the agent path with their own agent.

## Last updated
2026-11-24 — initial spec from the agreed design.
2026-11-24 — corrected during planning: plugin shell CLI exists; bash 3.2; build self-check replaces PNG previews.
2026-11-24 — G1 built: style system, build pipeline, cover page.
2026-11-24 — PDF becomes the installer: page 00, pages 17–18 reworked, appendix A1+ with the
files verbatim; cover unchanged.
