# Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `guide/think-prove-checkpoint.pdf`, a 23-page A4 guide, from one HTML/CSS source with a self-checking build.

**Architecture:** `guide/src/guide.html` holds every page as `<section class="page">`; `guide/src/styles.css` holds tokens and components; fonts are vendored. `guide/build.sh` prints the PDF with Chrome headless, then loads `guide.html#check`, where a small inline script reports pages whose content overflows; the build fails unless overflow is `none` and the PDF page count equals the number of sections. Page numbers come from a CSS counter, so pages can be reordered freely.

**Tech Stack:** HTML, CSS, Google Chrome headless (`--print-to-pdf`, `--dump-dom`), bash.

**Spec:** `docs/specs/guide.md` (page table = source of truth for page content).

## Global Constraints

- A4 portrait, `@page { size: A4; margin: 0 }`, each page exactly 210×297mm, `overflow: hidden`.
- Tokens: paper `#F4F5F7`, ink `#14161B`, accent `#2F5BFF`, verified `#12B886`, muted `#8A8F98`. Colors/fonts only via CSS variables.
- Fonts: Inter 400/600/800 (text), JetBrains Mono 500/800 (highlight word, code, labels), vendored in `guide/src/fonts/` with their OFL license files.
- Every headline has exactly one mono highlight word: `<span class="hl">word</span>`.
- Credit Karpathy (principles, via the andrej-karpathy-skills repo) and superpowers by Jesse Vincent (skills) wherever they're introduced.
- Never invent experiences for the author; the worked example (page 16) is labeled "Illustration".
- Author credit: "Sabir Hajiyev · IT student, ADA University"; closing page adds "12 Anthropic Academy certificates". No contact data.
- No text, layout details or branding copied from the original solo-dev guide.
- Plugin commands shown both ways (`claude plugin …` shell, `/plugin …` in-app).
- `guide/build.sh` must exit 0 before any checkpoint.
- Every commit message ends with a blank line and `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **The user makes every commit.** Each task ends with a checkpoint: update docs, give the user the exact commands, stop.

## File map

| File | Responsibility |
|---|---|
| `guide/src/fonts/*.woff2`, `guide/src/fonts/LICENSE-*.txt` | Vendored fonts + licenses |
| `guide/src/styles.css` | Tokens, page frame, all components |
| `guide/src/guide.html` | All pages + the `#check` script |
| `guide/build.sh` | Print PDF, self-check, report |
| `guide/think-prove-checkpoint.pdf` | Build output (committed, so LinkedIn readers can download it from the repo) |

## Page markup pattern (used by every content task)

```html
<section class="page">
  <div class="top"><span>Think · Prove · Checkpoint</span><span>01 · The problem</span></div>
  <p class="label">01 · The problem</p>
  <h1>What goes <span class="hl">wrong</span></h1>
  <p class="lead">One or two sentences framing the page.</p>
  <!-- components: .grid/.card, .callout, .copy, table.t, .flow, ol.steps -->
  <div class="foot"><span>Think · Prove · Checkpoint</span><span class="n"></span></div>
</section>
```

---

### Task G1: Style system, build pipeline, cover page (sample for approval)

**Files:**
- Create: `guide/src/fonts/` (5 woff2 + 2 license files), `guide/src/styles.css`, `guide/src/guide.html`, `guide/build.sh`

**Interfaces:**
- Produces: CSS classes used by all later tasks: `.page .top .label h1 .hl .lead .grid .grid.three .card .callout .copy table.t .flow .step .arrow ol.steps .ok .foot .n .cover .byline`; `guide/build.sh` (exit 0 = pass).

- [ ] **Step 1: Vendor the fonts**

```bash
mkdir -p guide/src/fonts && cd guide/src/fonts
B=https://cdn.jsdelivr.net/npm/@fontsource
for w in 400 600 800; do curl -sfO "$B/inter@5.1.0/files/inter-latin-$w-normal.woff2"; done
for w in 500 800; do curl -sfO "$B/jetbrains-mono@5.1.0/files/jetbrains-mono-latin-$w-normal.woff2"; done
curl -sf "$B/inter@5.1.0/LICENSE" -o LICENSE-Inter.txt
curl -sf "$B/jetbrains-mono@5.1.0/LICENSE" -o LICENSE-JetBrainsMono.txt
ls && cd -
```
Expected: 5 `.woff2` files and 2 `LICENSE-*.txt`.

- [ ] **Step 2: Write `guide/build.sh` (the test comes first: it fails until the HTML exists)**

```bash
#!/usr/bin/env bash
# Build the guide PDF and verify it: no overflowing pages, page count = sections.
set -euo pipefail
cd "$(dirname "$0")"

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
SRC="file://$PWD/src/guide.html"
OUT="think-prove-checkpoint.pdf"
FLAGS="--headless=new --disable-gpu --no-pdf-header-footer"

[ -f src/guide.html ] || { echo "missing src/guide.html" >&2; exit 1; }

"$CHROME" $FLAGS --print-to-pdf="$OUT" "$SRC" 2>/dev/null
dom="$("$CHROME" $FLAGS --dump-dom "$SRC#check" 2>/dev/null)"

sections="$(printf '%s' "$dom" | sed -n 's/.*data-pages="\([0-9]*\)".*/\1/p')"
overflow="$(printf '%s' "$dom" | sed -n 's/.*data-overflow="\([^"]*\)".*/\1/p')"
pdf_pages="$(LC_ALL=C grep -ao -m1 '/Count [0-9]*' "$OUT" | cut -d' ' -f2)"

echo "pdf pages: $pdf_pages · sections: $sections · overflow: $overflow"
if [ "$overflow" != "none" ] || [ "$pdf_pages" != "$sections" ]; then
  echo "BUILD CHECK FAILED" >&2; exit 1
fi
echo "ok: $OUT"
```
Then `chmod +x guide/build.sh` and run `guide/build.sh`.
Expected: `missing src/guide.html`, exit 1.

- [ ] **Step 3: Write `guide/src/styles.css`**

```css
@font-face { font-family: "Inter"; font-weight: 400; src: url(fonts/inter-latin-400-normal.woff2) format("woff2"); }
@font-face { font-family: "Inter"; font-weight: 600; src: url(fonts/inter-latin-600-normal.woff2) format("woff2"); }
@font-face { font-family: "Inter"; font-weight: 800; src: url(fonts/inter-latin-800-normal.woff2) format("woff2"); }
@font-face { font-family: "JetBrains Mono"; font-weight: 500; src: url(fonts/jetbrains-mono-latin-500-normal.woff2) format("woff2"); }
@font-face { font-family: "JetBrains Mono"; font-weight: 800; src: url(fonts/jetbrains-mono-latin-800-normal.woff2) format("woff2"); }

:root {
  --paper: #F4F5F7; --card: #FFFFFF; --ink: #14161B; --ink-2: #3D424B;
  --muted: #8A8F98; --line: #D9DCE1;
  --accent: #2F5BFF; --accent-soft: #E7ECFF;
  --ok: #12B886; --ok-soft: #E2F6EE;
  --code-bg: #14161B; --code-ink: #E8EAEE; --code-muted: #9BA3AF;
  --sans: "Inter", system-ui, sans-serif;
  --mono: "JetBrains Mono", ui-monospace, monospace;
}

@page { size: A4; margin: 0; }
* { box-sizing: border-box; }
html, body {
  margin: 0; background: var(--paper); color: var(--ink); font-family: var(--sans);
  -webkit-print-color-adjust: exact; print-color-adjust: exact;
}
body { counter-reset: pg; }

.page {
  position: relative; width: 210mm; height: 297mm; overflow: hidden;
  padding: 16mm 18mm 24mm; background: var(--paper);
  break-after: page; counter-increment: pg;
}
.page:last-child { break-after: auto; }

.top, .foot {
  display: flex; justify-content: space-between;
  font-family: var(--mono); font-weight: 500; font-size: 7.5pt;
  letter-spacing: .18em; text-transform: uppercase; color: var(--muted);
}
.top { margin-bottom: 12mm; }
.foot { position: absolute; left: 18mm; right: 18mm; bottom: 10mm; border-top: 1px solid var(--line); padding-top: 3mm; }
.foot .n::after { content: "Page " counter(pg); }

.label {
  font-family: var(--mono); font-weight: 500; font-size: 8.5pt; letter-spacing: .18em;
  text-transform: uppercase; color: var(--accent); margin: 0 0 3mm;
}
h1 { font-size: 34pt; line-height: 1.05; font-weight: 800; letter-spacing: -.025em; margin: 0 0 5mm; }
h1 .hl { font-family: var(--mono); font-weight: 800; color: var(--accent); letter-spacing: -.05em; }
h3 { font-size: 11pt; font-weight: 800; margin: 0 0 2mm; }
.lead { font-size: 12pt; line-height: 1.5; color: var(--ink-2); max-width: 150mm; margin: 0 0 9mm; }
p, li { font-size: 10pt; line-height: 1.55; color: var(--ink-2); }
code { font-family: var(--mono); font-size: .88em; color: var(--accent); background: var(--accent-soft); padding: .1em .35em; border-radius: 1mm; }

.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 5mm; margin: 0 0 7mm; }
.grid.three { grid-template-columns: repeat(3, 1fr); }
.card { background: var(--card); border: 1px solid var(--line); border-radius: 4mm; padding: 5mm; }
.card p { margin: 0; font-size: 9.5pt; }
.card .label { margin-bottom: 2mm; }

.callout { border: 1.5px solid var(--accent); background: var(--accent-soft); border-radius: 4mm; padding: 5mm 6mm; margin: 0 0 7mm; }
.callout .label { margin-bottom: 2mm; }
.callout p { margin: 0; font-size: 12.5pt; font-weight: 600; line-height: 1.4; color: var(--ink); }

.copy { background: var(--code-bg); border-radius: 4mm; padding: 5mm 6mm; margin: 0 0 7mm; }
.copy .label { color: var(--code-muted); margin-bottom: 3mm; }
.copy pre { margin: 0; font-family: var(--mono); font-weight: 500; font-size: 8.3pt; line-height: 1.6; color: var(--code-ink); white-space: pre-wrap; }

table.t { width: 100%; border-collapse: collapse; margin: 0 0 7mm; }
table.t th { font-family: var(--mono); font-weight: 500; font-size: 7.5pt; letter-spacing: .14em; text-transform: uppercase; color: var(--muted); text-align: left; padding: 0 3mm 2mm 0; border-bottom: 1px solid var(--line); }
table.t td { font-size: 9.5pt; line-height: 1.45; color: var(--ink-2); padding: 2.6mm 3mm 2.6mm 0; border-bottom: 1px solid var(--line); vertical-align: top; }
table.t td:first-child { font-weight: 600; color: var(--ink); }

.flow { display: flex; align-items: stretch; gap: 2.5mm; margin: 0 0 7mm; }
.flow .step { flex: 1; background: var(--card); border: 1px solid var(--line); border-radius: 4mm; padding: 4mm; }
.flow .step.on { border: 1.5px solid var(--accent); }
.flow .step p { margin: 0; font-size: 8.8pt; }
.flow .arrow { align-self: center; font-family: var(--mono); color: var(--muted); }

ol.steps { list-style: none; counter-reset: st; padding: 0; margin: 0 0 7mm; }
ol.steps li { counter-increment: st; position: relative; padding: 0 0 3mm 11mm; }
ol.steps li::before { content: counter(st, decimal-leading-zero); position: absolute; left: 0; font-family: var(--mono); font-weight: 800; color: var(--accent); }
.ok { color: var(--ok); font-weight: 800; }

.cover h1 { font-size: 48pt; margin-top: 10mm; }
.byline { font-family: var(--mono); font-size: 9pt; letter-spacing: .08em; color: var(--ink); margin: 0 0 12mm; }
```

- [ ] **Step 4: Write `guide/src/guide.html` with the cover page**

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Think · Prove · Checkpoint</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>

<section class="page cover">
  <div class="top"><span>Think · Prove · Checkpoint</span><span>A Claude Code workflow</span></div>
  <p class="label">A field guide</p>
  <h1>Think · Prove ·<br><span class="hl">Checkpoint</span></h1>
  <p class="lead">A small, strict way of building with Claude Code: principles that stop the guessing, skills that demand proof, and project memory that lives in git, where you can read it, review it and roll it back.</p>
  <p class="byline">Sabir Hajiyev · IT student, ADA University</p>
  <div class="callout">
    <p class="label">The whole idea</p>
    <p>Claude forgets. Git doesn't. So everything Claude needs to remember lives in plain files in your repo.</p>
  </div>
  <table class="t">
    <tr><th>Part</th><th>What it covers</th></tr>
    <tr><td>01–02</td><td>The problem, and the three-layer stack that answers it</td></tr>
    <tr><td>03–04</td><td>The principles, and the tools I actually run</td></tr>
    <tr><td>05–08</td><td>Memory: the global file, project docs, living specs</td></tr>
    <tr><td>09–13</td><td>Process: brainstorm, plan, test, debug, checkpoint</td></tr>
    <tr><td>14–16</td><td>Session start, safety and ethics, a worked example</td></tr>
    <tr><td>17–21</td><td>Setup, revert, cheat sheet, prompts, and proof it works</td></tr>
  </table>
  <div class="foot"><span>Think · Prove · Checkpoint</span><span class="n"></span></div>
</section>

<script>
  // Build self-check (guide/build.sh loads guide.html#check): report overflowing pages.
  if (location.hash === "#check") {
    const pages = [...document.querySelectorAll(".page")];
    const bad = pages.map((p, i) => (p.scrollHeight > p.clientHeight + 1 ? i + 1 : 0)).filter(Boolean);
    document.body.setAttribute("data-pages", pages.length);
    document.body.setAttribute("data-overflow", bad.join(",") || "none");
  }
</script>
</body>
</html>
```

- [ ] **Step 5: Build and verify**

Run: `guide/build.sh`
Expected: `pdf pages: 1 · sections: 1 · overflow: none`, then `ok: think-prove-checkpoint.pdf`.
Then read the PDF page visually: fonts rendered (not fallback), background color present, headline highlight in blue mono.
Negative check: temporarily add `<div style="height:400mm"></div>` inside the cover, rebuild, expect `BUILD CHECK FAILED` with `overflow: 1`; remove it.

- [ ] **Step 6: Checkpoint — user approves the look (user commits)**

Hand check (the look is the deliverable): user opens `guide/think-prove-checkpoint.pdf` and approves or requests changes; iterate on `styles.css` only. Docs: features "Build pipeline" = done; spec `guide.md` → Key files; roadmap; decision entry if the look changed from the spec.
```bash
git add guide/ docs/
git commit -m "Add guide style system, self-checking build and cover page"
```

---

### Task G2: Pages 01–04 — problem, stack, principles, tools

**Files:** Modify `guide/src/guide.html` (append sections after the cover).

- [ ] **Step 1: Write the four pages** (pattern above; content per spec table)
  - **01 · The problem** — h1 "What goes <hl>wrong</hl>". `.grid` of 4 cards: *It forgets* (every session starts from zero; you re-explain the project), *It guesses* (fills gaps silently instead of asking), *It says "done"* (without running anything that proves it), *Its memory is a black box* (stored somewhere you can't read, review or roll back). `.callout` "The fix": "Not a bigger context window. A smaller, honest memory, and a process that makes Claude prove its work."
  - **02 · The stack** — h1 "Three <hl>layers</hl>". `.flow` with 3 steps: Principles (how to think: Karpathy's 4 rules) → Process (how to work: superpowers skills) → Memory (what to remember: docs in git). `table.t` "Layer / Lives in / Loaded": Principles → `~/.claude/CLAUDE.md` → every session; Process → superpowers plugin → when a skill applies; Memory → `CLAUDE.md` + `docs/` in each repo → on demand.
  - **03 · Principles** — h1 "Four <hl>rules</hl>". 4 cards (Think before coding · Simplicity first · Surgical changes · Goal-driven execution) with one-line meaning each (from `framework/global-CLAUDE.md`). Credit line: "From Andrej Karpathy's observations on how LLMs go wrong when coding, packaged as andrej-karpathy-skills. I wrote them straight into my global file instead of running the plugin."
  - **04 · What I run** — h1 "My <hl>toolkit</hl>". `table.t` Plugin / Status / Why: superpowers (core, on: the skills that run the process); andrej-karpathy-skills (off: its rules live in my global file); claude-mem (tried, dropped: memory I couldn't read or review); gsd-core (tried, dropped: kept the simpler file-based process); custom status line (personal, not part of the workflow). `.callout` "What I learned": "The best memory system was the most boring one: Markdown files in git."

- [ ] **Step 2: Build** — `guide/build.sh` → `pdf pages: 5 · sections: 5 · overflow: none`. Read pages 2–5 visually.
- [ ] **Step 3: Checkpoint (user commits)** — content changed, so the user skims pages 2–5. Docs: roadmap.
```bash
git add guide/ docs/
git commit -m "Guide: pages 01-04 (problem, stack, principles, toolkit)"
```

---

### Task G3: Pages 05–08 — memory

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Write the four pages**
  - **05 · The global CLAUDE.md** — h1 "One file, every <hl>project</hl>". Lead: `~/.claude/CLAUDE.md` loads in every session, everywhere, so it stays lean. `.copy` labeled "Excerpt · ~/.claude/CLAUDE.md": the Core principles headings + the "Docs first, code second" bullet (copied verbatim from `framework/global-CLAUDE.md`). `.grid` 2 cards: *Global* (how I work: principles, workflow, checkpoints, safety) vs *Project* (what this repo is: stack, map, conventions, gotchas).
  - **06 · Project memory layout** — h1 "Where things <hl>live</hl>". `.copy` with the `docs/` tree (vision, architecture, roadmap, features, decisions, specs/, plans/) annotated. `table.t` "If it's… / It goes in": true for nearly every task → `CLAUDE.md`; where we left off → `roadmap.md` Current status; why we chose X → `decisions.md` (append-only); how a feature works as built → `specs/<feature>.md`; the steps to build it → `plans/<feature>.md`; a one-off instruction → your prompt, nowhere else.
  - **07 · Docs that grow** — h1 "Grow only when it <hl>hurts</hl>". 3 cards: *Docs first, code second* (rule text); *Architecture splits by area* (`architecture.md` → `docs/architecture/` with `index.md` + `frontend.md`, `backend.md`… at ~150 lines or 2+ separately built parts); *Indexes only when needed* (an `index.md` routes "working on X → read Y"; add one only at ~7+ files). `.callout`: "Specs describe features. Area docs describe the parts every feature touches."
  - **08 · The living spec** — h1 "Specs that stay <hl>true</hl>". Lead: a spec is written before building, then kept current, so it describes the feature as built. `.copy` labeled "Template · spec.md" with the section list from `framework/templates/spec.md`. 3 cards: Key files (Claude goes straight to the right file), Gotchas (the traps, written down once), Tests (where proof lives).

- [ ] **Step 2: Build** — `guide/build.sh` → `pdf pages: 9 · sections: 9 · overflow: none`. Read pages 6–9.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 6–9.
```bash
git add guide/ docs/
git commit -m "Guide: pages 05-08 (global file, memory layout, growing docs, living spec)"
```

---

### Task G4: Pages 09–13 — process and checkpoint

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Write the five pages**
  - **09 · The development spine** — h1 "One path, every <hl>feature</hl>". `.flow` (6 steps, compact): Brainstorm → Plan → Test-first → Debug → Verify → Finish, each with its skill name in `code`. Credit: "These are skills from superpowers by Jesse Vincent. They load automatically when they apply; you don't paste prompts."
  - **10 · Brainstorm & plan** — h1 "Questions before <hl>code</hl>". `ol.steps`: one question at a time (multiple choice when possible); 2–3 approaches with a recommendation; design approved section by section; spec written to `docs/specs/<feature>.md`; plan written to `docs/plans/<feature>.md`, every task ending at a checkpoint. `.callout`: "Most bad output is Claude silently filling a gap. A question costs a minute; a wrong guess costs an afternoon."
  - **11 · Test-first** — h1 "Red, then <hl>green</hl>". `.flow` 3 steps: write a failing test → watch it fail → make it pass. `.callout` with the rule: "Never delete or weaken a failing test to make it pass. Fix the code, or explain why the test is wrong." Short `.copy` example: one test from `tests/test_scripts.sh` (the "nothing changed" refusal check) — real code from this repo.
  - **12 · Debug by hypothesis** — h1 "Evidence, not <hl>guesses</hl>". `.copy` labeled "Copy-paste · bug report": Problem / Error (pasted exactly) / What I did (steps) / "Find the root cause before changing anything. Add a test that reproduces it, then fix it." 2 cards: *Give symptoms, not diagnoses*; *A new error is new information*.
  - **13 · Checkpoint = commit** — h1 "Every task ends in a <hl>checkpoint</hl>". `ol.steps` with the 7 steps from `framework/global-CLAUDE.md` (roadmap, features, architecture, spec, decisions, hand check with the trivial-change exception, prepare commit and stop). `.callout`: "Claude prepares the commit. I make it. Every time."

- [ ] **Step 2: Build** — `pdf pages: 14 · sections: 14 · overflow: none`. Read pages 10–14.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 10–14.
```bash
git add guide/ docs/
git commit -m "Guide: pages 09-13 (spine, brainstorm, test-first, debugging, checkpoint)"
```

---

### Task G5: Pages 14–16 — session start, safety, worked example

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Write the three pages**
  - **14 · Session start** — h1 "Pick up where you <hl>left</hl> off". `.flow` 3 steps: read `CLAUDE.md` → read `roadmap.md` Current status → confirm with me before changing anything. `.callout`: "The docs carry the memory, not the chat. Start fresh sessions often."
  - **15 · Safety & ethics** — h1 "Safe by <hl>default</hl>". `.grid` 4 cards: *No secrets in docs or commits* (flag them, never store); *Confirm before anything irreversible* (deletes, force-push, publishing); *Private memory when needed* (`.git/info/exclude` for graded or shared repos; docs stay local); *Evidence before claims* (tests run, output seen). `.callout`: "The human stays accountable: I review every change and make every commit."
  - **16 · Worked example** — h1 "One feature, start to <hl>finish</hl>". `.label` must read "16 · Worked example · Illustration". `table.t` # / What happens / Who: 1 open session, Claude reads CLAUDE.md + roadmap (Claude); 2 describe the feature (me); 3 brainstorm questions, answered (both); 4 spec written, reviewed (both); 5 plan written, reviewed (both); 6 task 1: failing test → code → pass (Claude); 7 checkpoint: docs updated, hand check, commit prepared (Claude) → I commit (me); 8 repeat per task; 9 finish: review, merge (both).

- [ ] **Step 2: Build** — `pdf pages: 17 · sections: 17 · overflow: none`. Read pages 15–17.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 15–17.
```bash
git add guide/ docs/
git commit -m "Guide: pages 14-16 (session start, safety, worked example)"
```

---

### Task G6: Pages 17–21 + closing

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Re-verify commands** — `claude plugin --help` and `claude plugin marketplace --help` list install/uninstall/add/remove; `bash tests/test_scripts.sh | tail -1` ends in `0 failed`.
- [ ] **Step 2: Write the six pages**
  - **17 · Setup** — h1 "Set it up in 15 <hl>minutes</hl>". `ol.steps` mirroring README Setup (clone · `bash scripts/install.sh` · plugin commands shown both ways · "set up the project"). `.copy` with the exact commands. Note: "Your existing files are moved to `*.backup-<timestamp>` first." Repo link element: `<span class="repo">github.com/…/think-prove-checkpoint</span>` (filled in G7).
  - **18 · Revert** — h1 "Undo it <hl>cleanly</hl>". `ol.steps` mirroring README Revert. `.callout`: "Nothing is deleted: installed files are moved to `*.removed-<timestamp>` and your originals come back."
  - **19 · Cheat sheet** — h1 "The whole thing on one <hl>page</hl>". `.grid.three`: *Trigger words* ("set up the project", "checkpoint" / "commit"); *Per feature* (brainstorm → spec → plan → task loop → finish); *Every checkpoint* (the 7 steps, compressed).
  - **20 · Prompts** — h1 "Prompts to <hl>copy</hl>". 3 `.copy` boxes: Session kickoff ("Read CLAUDE.md and the roadmap's Current status. Summarise where we are and what's next before touching anything."); Bug report (same as page 12, compact); Wrap-up ("Checkpoint: update the docs, then give me the files and the exact commit message.").
  - **21 · Built with this workflow** — h1 "This guide is the <hl>proof</hl>". Lead: the repo was built with the workflow it describes. `.copy` excerpt of this repo's real `docs/roadmap.md` Current status and 3 real entries from `docs/decisions.md` (copied at build time, verbatim). `table.t` with real numbers: commits so far (`git rev-list --count HEAD`), decisions logged (count of `## ` entries in decisions.md), tests (`bash tests/test_scripts.sh | tail -1`).
  - **Closing** — h1 "Leave the map <hl>better</hl>". `ol.steps` the system in 5 lines (Think before building · Keep memory in plain files · Prove it with tests · Check it yourself · Checkpoint every task). Credits (Karpathy / andrej-karpathy-skills; superpowers by Jesse Vincent). About the author: "Sabir Hajiyev, IT student at ADA University, 12 Anthropic Academy certificates. I build with Claude Code and focus on workflows that are efficient, effective, ethical and safe." Repo link element.

- [ ] **Step 3: Build** — `pdf pages: 23 · sections: 23 · overflow: none`. Read pages 18–23. Verify every repo path mentioned in the guide exists: `grep -o 'scripts/[a-z_]*\.sh\|framework/[A-Za-z/_.-]*\|tests/[a-z_]*\.sh' guide/src/guide.html | sort -u | xargs ls`.
- [ ] **Step 4: Checkpoint (user commits)** — user reads the whole PDF once.
```bash
git add guide/ docs/
git commit -m "Guide: pages 17-21 and closing (setup, revert, cheat sheet, prompts, proof)"
```

---

### Task G7: Publish prep (after the user creates the GitHub repo — milestone M4)

**Files:** Modify `guide/src/guide.html` (repo link on pages 17 + closing), `README.md` (clone URL), `docs/`.

- [ ] **Step 1:** User creates the repo and pushes; gives Claude the URL.
- [ ] **Step 2:** Replace both `.repo` elements and README's `<this repo>` with the real URL. Refresh page 21's numbers.
- [ ] **Step 3: Build** — `guide/build.sh` exit 0; read all 23 pages.
- [ ] **Step 4: Checkpoint (user commits and pushes)** — spec Key files final; features all done; roadmap M3 done, M4 in progress.
```bash
git add guide/ README.md docs/
git commit -m "Add repo link and final build of the guide"
git push
```
