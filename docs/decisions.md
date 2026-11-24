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
