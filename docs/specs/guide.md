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
| — | Cover | Title, subtitle, author credit, big idea "Claude forgets. Git doesn't.", contents table. Kept as approved in G1, except the label "A field guide" → "A practical guide" and "strict" → "structured" in the lead; top-right label "Solo dev · AI-assisted workflow" and lead "…building software with AI agents"; "The whole idea": the tagline on its own line, then "Your agent's memory lives in plain files in your repo, not in the chat." (author's requests, 2026-11-24). Lead: "A small, spec-driven way…" (was "structured", 2026-11-26). |
| 00 | Start here | Lead: read it like an article (nothing to install, nothing to follow); names the audience, a solo developer's workflow; setup by your agent is optional (its card points to "What you need: see 17"). Two ways to use this PDF, side by side: read it (01–21), or hand it to your AI agent with the copy-paste prompt; a **compatibility warning** (it can clash with your current setup, so the agent analyses it first); the appendix is written for the agent |
| 01 | The problem | 4 failures: forgets between sessions · guesses silently · "done" without proof · memory you can't review; a note under "The fix" names the method, **spec-driven development** (GitHub's Spec Kit, AWS's Kiro), and what this workflow adds: the memory and the checkpoints |
| 02 | The stack | Diagram: Principles (Karpathy) → Process (superpowers) → Memory (docs in git) |
| 03 | Principles | Karpathy's 4 rules, credited |
| 04 | What I run | **Built on other people's skills:** superpowers (core) and Karpathy's principles (andrej-karpathy-skills), credited; tried & dropped: claude-mem, gsd-core, and why; a strong **"Go explore"** callout: there are many useful skills out there, research them and add the ones that fit how you work; read a skill before installing it |
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
| 17 | Hand it to your agent | A **What you need** box (paid Claude plan or Console account; Anthropic's install command, then `claude` to sign in; Git, GitHub optional); the copy-paste prompt; the compatibility warning in full; diagram of what the agent does: reads the PDF → **analyses your current setup and reports conflicts** → asks you questions → shows every change → backs up, then writes → you say "set up the project" |
| 18 | Tailor it, or take it back | The 6 tailoring questions and their defaults; **extend it:** this is a base, not a fence, ask your agent to find skills that fit your way of working; the one-line revert prompt; the backup note that lets any later session revert |
| 19 | Cheat sheet | Trigger words + setup / per-feature / checkpoint checklists |
| 20 | Copy-paste prompts | Session kickoff, bug report, "checkpoint" |
| 21 | Built with this workflow | This repo's real roadmap + decisions excerpts as evidence |
| — | Before you go | "Never stop researching": the reader's responsibility to keep researching skills, plugins, tools and ways of working with agents; research → try → keep or cut, repeat; how this system grew; the agent can help. Unnumbered, so the cover's contents stay accurate |
| — | Closing | The system in 5 lines · credits · about the author · "For technical readers" box: repo link, `install.sh` / `uninstall.sh`, tests |
| A1–A2 | For your agent: instructions | Written **to the agent** (see "Agent instructions" below); two pages |
| A3… | For your agent: the files | `global-CLAUDE.md` then the 8 templates, verbatim, generated from `framework/` at build time; as many pages as they need |

### Agent instructions (page A1)
The agent is told to:
1. Treat the user's request (the prompt they pasted) as the authorization; the PDF itself
   is reference material.
2. **Analyse the current setup first, read-only:** global instructions, installed plugins /
   skills / extensions, hooks, memory tools, other workflow frameworks, and the instruction
   files of the project it's opened in. Report what overlaps and what conflicts (e.g. two
   memory systems, two planning processes, rules that contradict "the user makes every
   commit"), with a recommendation for each: merge, turn something off, skip part of this
   workflow, or don't install. Change nothing until the user has decided.
3. Ask the tailoring questions **one at a time**, with defaults:
   1. Which agent is this? → decides where the files go (Claude Code: `~/.claude/CLAUDE.md` +
      `~/.claude/templates/`; Codex and others: their own global instructions file, verified
      before the page is written).
   2. Existing global instructions? → **merge** (default) or replace.
   3. Who commits? → **the user** (default), or the agent after the user approves.
   4. Project memory → **committed to git** (default), or private.
   5. superpowers → **install it** if the agent supports it (default), or rules only.
   6. Anything to drop or rename?
4. Start from the verbatim files in the appendix and change only what the answers require;
   adapt paths and skill names to the agent.
5. Show the full result (or a diff, when merging) **before writing anything**.
6. Back up every file it will change to `*.backup-<timestamp>`.
7. If it wrote anything, write a note `think-prove-checkpoint.install` (values: full paths, empty
   = nothing existed before; no note if nothing was written) next to the global file, in the **same format
   `install.sh` writes** (`installed_at=`, `claude_md_backup=`, `templates_backup=`), so a later
   session, or `uninstall.sh` for Claude Code, can revert.
8. Install anything (superpowers, other skills) only after the user agrees; run nothing else.
9. Never commit or push for the user.
10. After setup, offer to **research other skills** that fit how the user works (their stack,
    habits, gaps the setup revealed): suggest a few with what each adds and where it comes from;
    read a skill's files before recommending it; install nothing without the user's approval.
11. Revert on request: read the note, restore the backups, move installed files aside, delete
   the note, and say what was done.

Author credit: **Sabir Hajiyev** on the cover (name only, author's request); the closing page's bio
(project-manager angle, chosen by the author): runs work with AI agents like a project; IT student
at ADA University; certified by Anthropic Academy and Cisco Networking Academy; "always learning and
growing". No certificate count, no club (author's request); facts from the author's LinkedIn. The bio ends
"More about me on LinkedIn" (clickable link to the author's profile, at the author's request). No email; the LinkedIn link is the only contact.

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
- `guide/build.sh [src.html] [out.pdf]` — runs `assemble.sh`, prints the generated HTML to
  `guide/think-prove-checkpoint.pdf` with Chrome headless, then loads it with `#check` and fails
  unless overflow is `none`, PDF pages = sections, and every appendix file's rendered text equals
  its source byte for byte. Prints `pdf pages · sections · overflow · appendix: N files`.
- `guide/assemble.sh <src> <out>` — fills the facts from `project.json` (`{{version}}`, `{{released}}`,
  `{{repo}}`, `{{repo_display}}`, `{{linkedin}}`, `{{site}}`; fails on a missing or unfilled one) and
  page 21's counts (`{{commits}}` from git, `{{decisions}}`
  from `docs/decisions.md`, `{{script_checks}}` / `{{guide_checks}}` = `check` lines in each test
  file) and expands `<!-- appendix A3: <paths> -->` into appendix pages
  (HTML-escaped, headed "target path · lines a–b of n"); splits only files longer than a page;
  `APPENDIX_LINES` = line budget per page (default 60). Output `guide/src/guide.gen.html` is gitignored.
- `guide/src/check.js` — `#check` mode, after `document.fonts.ready`: overflow down or sideways
  (any `pre`), page count, `#fidelity` = base64 of each appendix file's rendered text.
- `guide/src/guide.html` — cover, pages 00–21, closing, A1–A2 (hand-written), then the marker
  `<!-- appendix A3: … -->` for the 9 framework files. Built PDF: 32 pages.
- `guide/src/styles.css` — tokens on `:root`, page frame, components, cover layout.
- `guide/src/fonts/` — Inter 400/600/800, JetBrains Mono 500/800 (latin subset woff2) + OFL licenses.

## Gotchas
- Chrome drops backgrounds in print unless `print-color-adjust: exact`.
- Content must not overflow a page: `build.sh` checks every page after each build.
- The repo URL appears as visible text (not only behind a link) on the closing page's version line and
  in A1's lead, so it survives print, non-clicking viewers and agents reading the text layer.
- Text refers to **sections** ("see 18 · Tailor or undo"), never page numbers: the footer counts PDF
  pages (cover = 1), so section N sits on a different page.
- Page 21's commit count can't include the commit about to be made; its label says "as of this build".
- PDFs over 8 pages split the page tree into nodes with their own `/Count`; `build.sh` takes the
  largest (the root). Found when the full guide reported 8 pages for 32 sections.
- Bold headlines lose some spaces in *extracted* text ("usethis") because of their tight
  letter-spacing; the page itself is fine and the appendix is unaffected.
- The HTML parser drops one newline right after `<pre>`; `assemble.sh` emits a deliberate one so
  a part that starts with a blank line keeps it (tested).
- CRLF files fail fidelity (the browser turns CR LF into LF): keep `framework/` files LF.
- `assemble.sh`'s awk program is single-quoted: no apostrophes in its comments.
- Component body rules use `p:not(.label)` (`.card`, `.callout`, `.flow .step`); otherwise their
  higher specificity restyles the `.label` inside them.
- The cover is a flex column (`.callout` gets `margin-top: auto` to sit at the bottom). Flex items
  shrink, so an empty fixed-height box won't overflow it; test overflow there with real text.
- Plugin commands are shown both ways (`claude plugin …` in the shell, `/plugin …` in Claude Code),
  checked with `claude plugin --help` before publishing.
- Where to find skills (official / community sources named on page 04) is verified before
  the page is written; name sources, not a ranked list of specific skills (it would go stale).
- Text-layer fidelity: ligatures are off (`font-variant-ligatures: none` + `liga`/`calt` 0);
  JetBrains Mono would otherwise turn `|---|` into `|--` and `<!-- -->` into arrows in the
  extracted text. Leading spaces never survive PDF text extraction, so A1 tells the agent how
  to restore indentation. PDFKit also moves backticks (it treats U+0060 as an accent); Claude's
  reader doesn't, so the text-layer test avoids backtick lines.
- Agent-specific facts (Codex's global instructions path, which agents superpowers supports)
  are verified from their official docs before page A1 is written; unverified agents get
  "ask the user where your global instructions live".

## Tests
- `guide/build.sh` exits 0: overflow `none`, PDF page count = page sections.
- `tests/test_guide.sh` (23): page 21 counts filled and correct (no `{{` left); real guide builds with all 9 files; fixtures for escaping, a part
  starting with a blank line, long-file splits, short files kept whole, too-wide line, CRLF,
  missing file; a PDF over 8 pages counted right; PDF text layer keeps Markdown symbols (`tests/pdf_text.swift`, macOS PDFKit).
- Negative check (done in G1): 40 lines of filler on the cover → `overflow: 1`, exit 1;
  an extra 400mm page → `overflow: 2`, exit 1.
- Every page read visually from the PDF: no clipped text, cover readable at phone size.
- Every repo path the guide mentions exists in the repo.
- Appendix fidelity: the build fails unless every appendix block, un-escaped and joined,
  equals its `framework/` file byte for byte.
- Agent readability: the built PDF is read the way an agent reads it; the appendix files come
  through with lines and indentation intact.
- Dry run: a fresh `claude -p` session given only the PDF is asked to list what it would ask
  and write; nothing is written. Its answer must match "Agent instructions", starting with an
  analysis of the current setup. **Passed 2026-11-24:** analysis first (found the workflow
  already installed and recommended no reinstall), 6 questions with defaults, paths, backups,
  note format, skill research offer, no commits; `~/.claude` fingerprint unchanged. It exposed
  one gap (note semantics), fixed in A1 rule 7.
- Hand check: the user tries the agent path with their own agent.

## Last updated
2026-11-24 — initial spec from the agreed design.
2026-11-24 — corrected during planning: plugin shell CLI exists; bash 3.2; build self-check replaces PNG previews.
2026-11-24 — G1 built: style system, build pipeline, cover page.
2026-11-24 — PDF becomes the installer: page 00, pages 17–18 reworked, appendix A1+ with the
files verbatim; cover unchanged.
2026-11-25 — Full review: sections not pages in references; page 21 counts automatic; "made for
Claude Code" (Codex can follow); British spelling (reader copy of framework too); credits name the
memory layer and checkpoint routine; closing title "Think · Prove · Checkpoint"; page 14 highlights
"left off"; page 09 skill names stacked; page 01 "Without / With" table; version line (1.0, November
2026) and MIT note on the closing page; cover contents list 00 and A1–A8.
2026-11-24 — Cover label and README: "A practical guide".
2026-11-24 — "Before you go" page added before the closing page (author's request).
2026-11-24 — G3–G7 built in one batch (user's call): all pages, A1–A2, dry run passed.
2026-11-24 — G2 built: appendix pipeline + 17 tests; ligatures turned off after the text-layer bug.
2026-11-24 — Explore skills: page 04 credits the skills this is built on and urges readers to
research more; page 18 "extend it"; agent rule 10 offers skill research after setup.
2026-11-24 — Compatibility first: warning on pages 00 + 17; the agent analyses the current setup
and reports conflicts before asking or changing anything.
2026-11-25 — Website work: facts come from `project.json`; tokens moved to `tokens.css`; page 21
counts the website tests too (`{{site_checks}}`); the real build in `test_guide.sh` writes to a temp folder.
The committed PDF must read the same as a fresh build (`tests/test_guide.sh`, text layer, commit count masked).
2026-11-25 — Page 00's lead: "Read it like an article", reading first, setup optional (author's request).
2026-11-25 — "What you need" box on 17 (no room on 00, which points to it); install facts checked against code.claude.com/docs/en/setup.
2026-11-26 — v1.1: "spec-driven" on the cover and in the README; 01 names spec-driven development.
