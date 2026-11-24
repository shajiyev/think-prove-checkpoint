# Guide PDF

## Goal
A ~23-page A4 PDF, **"Think · Prove · Checkpoint"**, that explains the workflow to people who
already know the basics of Claude Code, lets them set it up and revert it, and shows the
author's project-management and technical skills. Shared as a LinkedIn document post.

## Behavior
Page by page (numbering = section labels in the PDF):

| # | Page | Content |
|---|---|---|
| — | Cover | Title, subtitle, author credit, big idea "Claude forgets. Git doesn't.", contents table |
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
| 17 | Setup, step by step | Back up → install plugin → `install.sh` (or copy by hand) → "set up the project" |
| 18 | Revert, step by step | `uninstall.sh` → remove plugin + marketplace → project docs are plain files: keep or delete |
| 19 | Cheat sheet | Trigger words + setup / per-feature / checkpoint checklists |
| 20 | Copy-paste prompts | Session kickoff, bug report, "checkpoint" |
| 21 | Built with this workflow | This repo's real roadmap + decisions excerpts as evidence |
| — | Closing | The system in 5 lines · credits · about the author · repo link |

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
- **Repo link:** one element on the closing page and page 17; filled in at M4 once the
  user has created the GitHub repo.
- **Process:** build the style system with **one sample page first**, get the user's approval
  on the look, then lay out the rest.

## Key files
<!-- Kept current at every checkpoint: describes the feature AS BUILT. -->
- Not built yet.

## Gotchas
- Chrome drops backgrounds in print unless `print-color-adjust: exact`.
- Content must not overflow a page: every page preview is checked after each build.
- Plugin commands are shown both ways (`claude plugin …` in the shell, `/plugin …` in Claude Code),
  checked with `claude plugin --help` before publishing.

## Tests
- `guide/build.sh` exits 0: overflow `none`, PDF page count = page sections.
- Every page read visually from the PDF: no clipped text, cover readable at phone size.
- Every repo path the guide mentions exists in the repo.

## Last updated
2026-11-24 — initial spec from the agreed design.
2026-11-24 — corrected during planning: plugin shell CLI exists; bash 3.2; build self-check replaces PNG previews.
