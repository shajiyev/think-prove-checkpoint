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

## 2026-11-25 — Project facts live in project.json
**Decision:** version, release date, repo URL, LinkedIn link and site URL are kept in one flat
`project.json`; `guide/assemble.sh` fills them into the PDF and the site as `{{placeholders}}` and
fails on a missing or unfilled one. The README is written by hand; tests check it matches.
**Why:** one change updates every place a fact appears, and a forgotten place fails a test.
**Alternatives considered:** generating the README (you'd edit a template, not the README);
shared text blocks between README and guide (more machinery than the drift it prevents).

## 2026-11-25 — The website is built from guide.html; site/dist is committed
**Decision:** `site/build.sh` turns the assembled guide into a web page (cover → hero, pages →
sections, appendix dropped) with its own CSS and JS, and the built `site/dist/` is committed.
Vercel only serves it. Colours and fonts move to `tokens.css`, shared by print and web.
**Why:** the site and the PDF can never say different things; building locally keeps "Chrome is the
only dependency" true, and Vercel's shallow clone would miscount page 21's commits.
**Alternatives considered:** rendering `guide.html` in the browser (empty page until JS runs, bad for
link previews); a framework like Astro or Next.js (Node and dependencies for one page).

## 2026-11-25 — Link preview: a screenshot of the hero, made at build time
**Decision:** `site/build.sh` screenshots the hero at 1200×630 (`#og` mode) as `og.png`.
**Why:** the preview always matches the cover; it is byte-identical across builds, so it is tested
like every other file. **Alternatives considered:** a hand-made image that would drift.

## 2026-11-25 — One constant website action: "Get the PDF"
**Decision:** the website keeps one action always in view: **Get the PDF**, at the top of the
desktop rail and in the phone bar. Outside links and the PDF open in a new tab. "Set it up" stays
the last navigation entry, not a floating button.
**Why:** the PDF is what readers need (it holds the prompt and the appendix their agent installs
from); "Set it up" would be one more hop to the same button. The rail is always visible, so its top
is always on screen without covering content, which a floating top-right button would between
1000 and 1150px wide.
**Alternatives considered:** a floating top-right "Set it up" button (the author's first idea);
navigation only.

## 2026-11-25 — Page 21's counts stay build-time; downloaded PDFs are handled by versions
**Decision:** page 21's counts are filled at every build, labelled "as of this build", and tests
refuse a stale PDF or site. Copies people already downloaded are handled by the version line and a
"latest version" link to the website (once it's live), with `version` bumped in `project.json` for
each content release.
**Why:** live counts would need the GitHub API on every visit (rate-limited, numbers that jump after
load, and a site that disagrees with the PDF). A file that has left the site can't be updated; it can
only say how to get the newest one.

## 2026-11-25 — The hero has no PDF button
**Decision:** the hero's buttons are **Read the guide** and **GitHub**; **Get the PDF** stays in the
navigation (rail, phone bar) and in "Set it up".
**Why:** the navigation shows it on every screen, the hero included, so a third button repeated it
and needed phone-only shrinking to fit on one line (author's hand check).

## 2026-11-25 — Read first, set up optionally
**Decision:** page 00's lead says to read the guide like an article ("Nothing to install, nothing to
follow"), with handing it to an agent as the optional next step. The LinkedIn post says: "It's a
short read on how I work with Claude Code. If you like it, your agent can set it up for you."
**Why:** most readers come from LinkedIn and should feel free to just read it; setting it up is for
those who like what they see (author's request).

## 2026-11-25 — "What you need" lives on 17, not 00
**Decision:** a box on 17 · Hand it to your agent lists what a newcomer needs: a paid Claude plan or
Console account, Claude Code (Anthropic's install command, then `claude` to sign in), and Git
(GitHub optional). 00's agent card says "What you need: see 17."
**Why:** people new to Claude Code need to know what to get before handing the PDF to an agent
(author's request). On 00 the box made the page 73px too tall; 17 is where setup happens, and it
keeps 00's "nothing to install" lead true. Git is listed although Claude Code's docs call it
optional, because this workflow's memory lives in commits.
**Alternatives considered:** trimming 00's "Before you install" callout and appendix note; a separate
"Before you start" page.

## 2026-11-26 — Name the method: spec-driven development
**Decision:** the cover lead and the README tagline say "a small, spec-driven way of building
software with AI agents" (replacing "structured"); a note under 01's "The fix" names **spec-driven
development** (GitHub's Spec Kit, AWS's Kiro) and says what this workflow adds: the memory around
the spec and the checkpoints that keep it current. The LinkedIn post names it too. Released as v1.1.
**Why:** the author's professor recognised the workflow as spec-driven development; readers know
the term, so naming it early places the guide in a familiar family. The brainstorm → spec → plan →
build loop matches it; vision, roadmap, decisions and features are project memory, not specs, so
the guide claims the family, not the whole.
**Alternatives considered:** renaming the guide; keeping "structured" alongside "spec-driven"
(heavier); the note inside "The fix" box (louder).

## 2026-11-26 — Deployed; the PDF points readers to the website
**Decision:** the site is live at https://think-prove-checkpoint.vercel.app (Vercel project
`think-prove-checkpoint`, deployed through the Vercel connection at the author's request; Vercel
serves `site/dist` as committed). The PDF's end page says "Latest version: <site> · Files: <repo>"
via `{{latest}}`, which falls back to the repo while `site` is empty. A1 keeps the repo. Released as
**v1.1.1**.
**Why:** a downloaded PDF can't update itself, so it should send readers to the page that always
has the newest version. Agents reading A1 need the raw files, which only the repo has. A patch number
keeps every tag matching what's in it for a change that adds a link but no content.
**Alternatives considered:** keeping 1.1 (the PDF would differ from the v1.1 tag); 1.2.
