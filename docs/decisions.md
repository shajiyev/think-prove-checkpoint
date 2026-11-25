# Decisions

Append-only. Newest at the bottom. Never edit past entries — add a new one that supersedes.

## 2026-11-23 — Guide format: A4 portrait document, not a carousel
**Why:** it needs room for templates, setup and revert steps; it doubles as a download people keep.
**Alternatives considered:** 4:5 LinkedIn carousel (too little room; maybe later as a teaser); both at once (twice the work).

## 2026-11-23 — Palette: Ink & electric blue
**Why:** technical and trustworthy, clearly distinct from the original guide's orange, fits the safe/ethical theme.
**Alternatives considered:** dark terminal (hard to read over many pages), sand & forest green, Azerbaijan-flag accents.

## 2026-11-23 — Name: "Think · Prove · Checkpoint"; big idea: "Claude forgets. Git doesn't."
**Why:** names the three moves made on every task; the tagline states the memory idea in four words.
**Alternatives considered:** "Memory in Git", "The Checkpoint Method".

## 2026-11-23 — Distribution: PDF + public GitHub repo
**Why:** copying 119 lines out of a PDF breaks formatting; a repo can be fixed after sharing and gives a link for LinkedIn.
**Alternatives considered:** files in a PDF appendix; a paste-in setup prompt.

## 2026-11-24 — Project docs are public (dogfooding), not private-memory mode
**Why:** the repo is a portfolio piece for project management; its own roadmap, decisions, specs and plans are the evidence.
**Alternatives considered:** private memory (hides the very thing we want to show).

## 2026-11-24 — Installable files live in `framework/`, separate from this project's `CLAUDE.md`
**Why:** the reader's global file and this project's memory are different things and must never get mixed up.

## 2026-11-24 — Build with HTML/CSS + Chrome headless; MIT license
**Why:** no extra dependencies (Chrome is already installed), full layout control, page previews for verification. MIT matches superpowers.
**Alternatives considered:** Python PDF libraries (harder layout), slide tools (wrong format).

## 2026-11-24 — Only real experience in the text
**Why:** credibility. The "why" comes from real decisions (rejecting claude-mem and gsd-core, user makes every commit); the worked example is labeled as an illustration.

## 2026-11-24 — The PDF is the installer: hand it to your AI agent
**Decision:** the primary install path is giving the PDF to your own agent and setting it up in
conversation (tailoring questions, changes shown first, backups, a revert note). The files are
in an appendix, generated from `framework/` at build time. The repo is optional (scripts + tests).
**Why:** agents read PDFs, so the "copying from a PDF breaks formatting" problem behind the
2026-11-23 distribution decision no longer applies; one shareable file is enough to adopt the
workflow, and tailoring by conversation fits readers using other agents (Codex, …).
**Alternatives considered:** describe the rules only and let the agent write its own files
(every reader gets a different workflow); keep manual setup steps (more friction).
**Supersedes:** the "why" of 2026-11-23 — Distribution: PDF + public GitHub repo (both still ship).

## 2026-11-24 — Cover stays as approved; "Hand it to your agent" lives on page 00
**Why:** the user approved the cover as is; page 00 is the first page a LinkedIn reader swipes to.

## 2026-11-24 — The agent analyses your current setup before changing anything
**Decision:** pages 00 and 17 warn that the workflow can clash with an agent's existing setup;
the agent's first step is a read-only analysis that reports overlaps and conflicts with a
recommendation for each, and nothing changes until the user decides.
**Why:** the author's own experience: other memory tools, workflow frameworks and global rules
can work against this workflow. The agent can see the reader's setup; the PDF can't.
**Alternatives considered:** a fixed list of incompatible tools in the PDF (goes stale, and can't
see setups the author never used).

## 2026-11-24 — Encourage readers to explore and add skills
**Decision:** the guide stresses that it is built on other people's skills (superpowers by Jesse
Vincent, Karpathy's principles via andrej-karpathy-skills) and urges readers to research the many
other skills out there and tailor the workflow to how they work; the agent offers that research
after setup. Skills are read before they're installed.
**Why:** the workflow is a base, not a fence; the author's own setup came from combining skills.
Reading a skill first keeps the safety rule: a skill runs with your agent's permissions.

## 2026-11-24 — PDF text layer: ligatures off, verified by a test
**Decision:** turn off font ligatures and contextual alternates for the whole guide; test the
PDF's extracted text (PDFKit, macOS) for Markdown symbols.
**Why:** found while reading the appendix like an agent: JetBrains Mono ligatures turned `|---|`
into `|--` and `##`/`<!--` into other glyphs in the text layer, while the DOM-level fidelity check
still passed. Agents read the text layer, so that's what must be tested.

## 2026-11-24 — Agent facts in A1 verified from official sources
**Decision:** A1 names Claude Code's paths (`~/.claude/CLAUDE.md`, `~/.claude/templates/`) and
Codex's global file (`~/.codex/AGENTS.md`, or `$CODEX_HOME`); any other agent asks the user.
superpowers is installed per agent from its own README (Claude Code, Codex, OpenCode supported).
Page 04 names where to find skills: `/plugin` → Discover (claude.com/plugins),
github.com/anthropics/skills, agentskills.io.
**Why:** the PDF is executed by agents; a wrong path would install the workflow where it never loads.
**Sources:** developers.openai.com/codex/guides/agents-md · github.com/obra/superpowers ·
code.claude.com/docs/en/discover-plugins · github.com/anthropics/skills · github.com/agentskills/agentskills

## 2026-11-24 — A1 note rule tightened after the dry run
**Decision:** leave the note only if something was written; backup values are full paths; empty
means nothing existed before.
**Why:** the dry-run agent reasoned that a note with empty backups would make undo move the user's
real files aside with nothing to restore, and it had to guess the path format. Now it doesn't guess.

## 2026-11-24 — Reader copy marks the agent's pronouns "(the agent)"
**Decision:** in `framework/global-CLAUDE.md` (shipped in the PDF appendix and by `install.sh`),
every "I"/"me" that means the agent is followed by "(the agent)" (lines 3, 71, 91, 96), with no
product name. The author's live `~/.claude/CLAUDE.md` is left as it is, so the two now differ in
exactly these four places.
**Why:** readers, and the agents they hand the PDF to, must be able to tell the agent's "I" from
the author's "I" in the guide; naming no product keeps it right for Codex and other agents.
**Alternatives considered:** changing the live file too (the author declined); rewriting the
text at build time only (the PDF and `install.sh` would ship different files).

## 2026-11-24 — A closing call to keep researching
**Decision:** an unnumbered "Before you go" page before the closing page tells readers it is their
responsibility to keep researching skills, plugins, tools and ways of working with their agent,
and to keep adding and removing things from this workflow (research → try → keep or cut).
**Why:** the workflow is a snapshot of one person's loop, not a finished product; the author wants
readers to own and evolve theirs. Unnumbered so the approved cover's contents table stays accurate.

## 2026-11-24 — Audience named: solo developers
**Decision:** the README tagline, page 00's lead and the LinkedIn post say the workflow is for solo
developers. The cover is unchanged.
**Why:** the workflow assumes one person who reviews every change and makes every commit; naming the
audience sets the right expectations. Teams can adapt it, but it isn't designed for them.

## 2026-11-25 — British spelling throughout the guide
**Decision:** the guide, its prompts and the reader copy of the framework files use British
spelling ("analyse", "summarise", "behaviour", "judgement", "towards", "authorisation"). The
author's live files are unchanged; like the "(the agent)" marks, this is a documented difference
in `framework/` only. The README keeps "License" (the MIT License's name and GitHub's file name).
**Why:** consistent spelling; the author writes British English.
