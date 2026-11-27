# Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `guide/think-prove-checkpoint.pdf`, a ~30-page A4 guide that is also the installer (hand it to your AI agent), from one HTML/CSS source with a self-checking build.

**Architecture:** `guide/src/guide.html` holds every page as `<section class="page">`; `guide/src/styles.css` holds tokens and components; fonts are vendored. `guide/build.sh` prints the PDF with Chrome headless, then loads `guide.html#check`, where a small inline script reports pages whose content overflows; the build fails unless overflow is `none` and the PDF page count equals the number of sections. Page numbers come from a CSS counter, so pages can be reordered freely. **Part 2 (from G2):** the appendix is generated: `guide/assemble.sh` expands `<!-- appendix A2: <files> -->` markers into page sections holding the `framework/` files verbatim; the check script (now `guide/src/check.js`) also catches sideways overflow and reports each appendix file's rendered text, which `build.sh` compares byte for byte with the source.

**Tech Stack:** HTML, CSS, Google Chrome headless (`--print-to-pdf`, `--dump-dom`), bash.

**Spec:** `docs/specs/guide.md` (page table = source of truth for page content).

## Global Constraints

- A4 portrait, `@page { size: A4; margin: 0 }`, each page exactly 210×297mm, `overflow: hidden`.
- Tokens: paper `#F4F5F7`, ink `#14161B`, accent `#2F5BFF`, verified `#12B886`, muted `#8A8F98`. Colors/fonts only via CSS variables.
- Fonts: Inter 400/600/800 (text), JetBrains Mono 500/800 (highlight word, code, labels), vendored in `guide/src/fonts/` with their OFL license files.
- Every headline has exactly one mono highlight word: `<span class="hl">word</span>`.
- Credit Karpathy (principles, via the andrej-karpathy-skills repo) and superpowers by Jesse Vincent (skills) wherever they're introduced.
- Never invent experiences for the author; the worked example (page 16) is labeled "Illustration".
- The cover stays exactly as approved in G1.
- The PDF holds no manual setup steps; the agent path is primary, the repo is for technical readers.
- `framework/` is the single source for appendix text; never paste framework text into `guide.html` by hand (excerpts on pages 05/08 excepted).
- Agent-specific facts (paths, plugin support) are verified from official docs before they're written.
- Author credit: "Sabir Hajiyev" on the cover (name only); the closing page has the author bio (project-manager angle, no certificate count) ending "More about me on LinkedIn" (link). No email.
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
| `guide/src/guide.html` | All hand-written pages + appendix markers |
| `guide/src/check.js` | `#check` mode: overflow (down and sideways), page count, appendix text report |
| `guide/assemble.sh` | Expands appendix markers → `guide/src/guide.gen.html` (gitignored) |
| `tests/test_guide.sh` | Build tests: real guide + fixture guides (escaping, splits, overflow, fidelity) |
| `guide/build.sh` | Assemble, print PDF, self-check, report |
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

### Task G1: Style system, build pipeline, cover page (sample for approval) — DONE

**Files:**
- Create: `guide/src/fonts/` (5 woff2 + 2 license files), `guide/src/styles.css`, `guide/src/guide.html`, `guide/build.sh`

**Interfaces:**
- Produces: CSS classes used by all later tasks: `.page .top .label h1 .hl .lead .grid .grid.three .card .callout .copy table.t .flow .step .arrow ol.steps .ok .foot .n .cover .byline`; `guide/build.sh` (exit 0 = pass).

- [x] **Step 1: Vendor the fonts**

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

- [x] **Step 2: Write `guide/build.sh` (the test comes first: it fails until the HTML exists)**

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

- [x] **Step 3: Write `guide/src/styles.css`**

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

- [x] **Step 4: Write `guide/src/guide.html` with the cover page**

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

- [x] **Step 5: Build and verify**

Run: `guide/build.sh`
Expected: `pdf pages: 1 · sections: 1 · overflow: none`, then `ok: think-prove-checkpoint.pdf`.
Then read the PDF page visually: fonts rendered (not fallback), background color present, headline highlight in blue mono.
Negative check: temporarily add `<div style="height:400mm"></div>` inside the cover, rebuild, expect `BUILD CHECK FAILED` with `overflow: 1`; remove it.

- [x] **Step 6: Checkpoint — user approves the look (user commits)**

Hand check (the look is the deliverable): user opens `guide/think-prove-checkpoint.pdf` and approves or requests changes; iterate on `styles.css` only. Docs: features "Build pipeline" = done; spec `guide.md` → Key files; roadmap; decision entry if the look changed from the spec.
```bash
git add guide/ docs/
git commit -m "Add guide style system, self-checking build and cover page"
```

---


## Part 2: The PDF is the installer (spec change 2026-11-24)

> G2 done. G3–G7 were executed as one batch at the user's request (one checkpoint, one commit).

G1 as built differs from its code above in two places (recorded in the spec's Gotchas):
component body rules use `p:not(.label)`, and the cover is a flex column with the callout
pushed to the bottom.

### Task G2: Appendix pipeline (generated, verified files)

**Files:**
- Create: `tests/test_guide.sh`, `guide/assemble.sh`, `guide/src/check.js`
- Modify: `guide/build.sh` (rewrite), `guide/src/guide.html` (marker + script tag), `guide/src/styles.css` (appendix styles), `.gitignore`

**Interfaces:**
- Produces: marker syntax `<!-- appendix A2: path path … -->` (one line; paths relative to the repo root, or absolute); `guide/build.sh [src.html] [out.pdf]` (defaults `src/guide.html`, `think-prove-checkpoint.pdf`), last-but-one output line `pdf pages: N · sections: N · overflow: none · appendix: K files`; env `APPENDIX_LINES` (line budget per appendix page, default 60); CSS `.appendix .file-head pre.file`.

- [ ] **Step 1: Write the failing tests** — `tests/test_guide.sh`:

```bash
#!/usr/bin/env bash
# Tests for guide/build.sh + guide/assemble.sh: the real guide, plus small fixture guides.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0
FAIL=0

check() {
  local desc="$1"; shift
  if "$@"; then PASS=$((PASS + 1)); echo "ok   - $desc"
  else FAIL=$((FAIL + 1)); echo "FAIL - $desc"; fi
}
refuses() { ! "$@"; }

# fixture NAME FILE...: a guide with one appendix marker listing FILE...
fixture() {
  local name="$1"; shift
  {
    echo '<!doctype html><html><head><meta charset="utf-8">'
    echo "<link rel=\"stylesheet\" href=\"file://$ROOT/guide/src/styles.css\"></head><body>"
    echo "<!-- appendix A1: $* -->"
    echo "<script src=\"file://$ROOT/guide/src/check.js\"></script></body></html>"
  } > "$TMP/$name.html"
}
build()      { "$ROOT/guide/build.sh" "$TMP/$1.html" "$TMP/$1.pdf" > "$TMP/$1.log" 2>&1; }
build_with() { local n="$1"; shift; ( export APPENDIX_LINES="$n"; build "$@" ); }
logged()     { grep -q -- "$2" "$TMP/$1.log"; }
real_build() { "$ROOT/guide/build.sh" > "$TMP/real.log" 2>&1; }

echo "# real guide"
check "guide builds and passes its self-check" real_build
check "all 9 framework files are in the appendix" logged real "appendix: 9 files"

echo "# appendix text survives HTML exactly"
printf '%s\n' '<script>alert(1)</script>' 'a & b &amp; c' '</pre> is just text' \
  "\"double\" and 'single' quotes" 'unicode: · → —' > "$TMP/escape.md"
fixture escape "$TMP/escape.md"
check "markup characters round-trip" build escape
check "...and the file was really checked" logged escape "appendix: 1 files"

printf 'one\ntwo\nthree\nfour\nfive\n\nseven\neight\n' > "$TMP/blank.md"
fixture blank "$TMP/blank.md"
check "a part that starts with a blank line keeps it" build_with 10 blank
check "...and it was split over 2 pages" logged blank "pdf pages: 2"

seq 1 100 | sed 's/^/line /' > "$TMP/long.md"
fixture long "$TMP/long.md"
check "a long file splits over pages" build_with 40 long
check "...exactly 3 pages" logged long "pdf pages: 3"

echo "# the build refuses bad input"
printf '%0200d\n' 0 > "$TMP/wide.md"
fixture wide "$TMP/wide.md"
check "a line too wide for the page fails" refuses build wide
check "...reported as overflow" logged wide "overflow: 1"

printf 'a\r\nb\r\n' > "$TMP/crlf.md"
fixture crlf "$TMP/crlf.md"
check "text the browser changes (CRLF) fails fidelity" refuses build crlf
check "...reported as differing" logged crlf "differ:"

fixture missing "$TMP/nope.md"
check "a missing file fails" refuses build missing
check "...reported as missing" logged missing "missing"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: Run, expect failure** — `bash tests/test_guide.sh` → the real build fails on the missing `appendix:` count and every fixture fails (no `assemble.sh`, no `check.js`); last line `… failed` with failures > 0.

- [ ] **Step 3: Write `guide/src/check.js`** (moves the inline script out, so fixtures can load it):

```js
// Build self-check: build.sh loads the page with #check and reads what this writes.
//   data-pages     number of .page sections
//   data-overflow  pages whose content spills down or sideways ("none" if clean)
//   #fidelity      one line per appendix file: "<path> <base64 of its rendered UTF-8 text>"
if (location.hash === "#check") {
  document.fonts.ready.then(() => {
    const pages = [...document.querySelectorAll(".page")];
    const tooTall = (p) => p.scrollHeight > p.clientHeight + 1;
    const tooWide = (p) => [...p.querySelectorAll("pre")].some((e) => e.scrollWidth > e.clientWidth + 1);
    const bad = pages.map((p, i) => (tooTall(p) || tooWide(p) ? i + 1 : 0)).filter(Boolean);
    document.body.setAttribute("data-pages", pages.length);
    document.body.setAttribute("data-overflow", bad.join(",") || "none");

    const text = {};
    for (const e of document.querySelectorAll("pre.file")) {
      text[e.dataset.file] = (text[e.dataset.file] || "") + e.textContent;
    }
    const b64 = (s) => btoa(Array.from(new TextEncoder().encode(s), (b) => String.fromCharCode(b)).join(""));
    const out = document.createElement("pre");
    out.id = "fidelity";
    out.textContent = Object.entries(text).map(([f, t]) => `${f} ${b64(t)}`).join("\n");
    document.body.appendChild(out);
  });
}
```

- [ ] **Step 4: Write `guide/assemble.sh`**

```bash
#!/usr/bin/env bash
# Expand appendix markers into page sections holding files verbatim (HTML-escaped).
# Usage: assemble.sh <src.html> <out.html>
# Marker, on its own line: <!-- appendix A2: framework/global-CLAUDE.md framework/templates/spec.md -->
# Paths are relative to the repo root, or absolute. APPENDIX_LINES = line budget per page.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

awk -v root="$ROOT" -v budget="${APPENDIX_LINES:-60}" '
function esc(s) { gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); return s }
function target(p) { if (p ~ /global-CLAUDE\.md$/) return "~/.claude/CLAUDE.md"; sub(/^.*framework\//, "~/.claude/", p); return p }
function open_page() {
  print "<section class=\"page appendix\">"
  print "<div class=\"top\"><span>Think · Prove · Checkpoint</span><span>Appendix · For your agent</span></div>"
  printf "<p class=\"label\">%s%d · The files, verbatim</p>\n", prefix, num
  used = 0; inpage = 1
}
function close_page() {
  print "<div class=\"foot\"><span>Think · Prove · Checkpoint</span><span class=\"n\"></span></div>"
  print "</section>"
  num++; inpage = 0
}
function emit(path,    full, n, line, i, k, last) {
  full = (path ~ /^\//) ? path : root "/" path
  n = 0
  while ((getline line < full) > 0) lines[++n] = line
  if (n == 0) { print "missing or empty: " path > "/dev/stderr"; exit 2 }
  close(full)
  i = 1
  while (i <= n) {
    if (!inpage) open_page()
    if (budget - used < HEAD + 3) { close_page(); open_page() }
    k = budget - used - HEAD; if (k > n - i + 1) k = n - i + 1
    last = i + k - 1
    printf "<p class=\"file-head\">%s · lines %d–%d of %d</p>\n", target(path), i, last, n
    printf "<pre class=\"file\" data-file=\"%s\">\n", path   # this first newline is eaten by the HTML parser
    for (; i <= last; i++) print esc(lines[i])
    print "</pre>"
    used += HEAD + k
    if (used >= budget) close_page()
  }
}
BEGIN { HEAD = 5 }
/<!-- appendix [A-Z][0-9]+: .* -->/ {
  spec = $0; sub(/.*<!-- appendix /, "", spec); sub(/ -->.*/, "", spec)
  m = split(spec, parts, " ")
  prefix = substr(parts[1], 1, 1); num = substr(parts[1], 2, length(parts[1]) - 2) + 0
  inpage = 0
  for (j = 2; j <= m; j++) emit(parts[j])
  if (inpage) close_page()
  next
}
{ print }
' "$1" > "$2"
```
Then `chmod +x guide/assemble.sh`.

- [ ] **Step 5: Rewrite `guide/build.sh`**

```bash
#!/usr/bin/env bash
# Build the guide PDF and verify it: no page overflows (down or sideways), PDF page count
# = sections, and every appendix file renders byte for byte equal to its source.
# Usage: build.sh [src.html] [out.pdf]   (defaults: src/guide.html, think-prove-checkpoint.pdf)
set -euo pipefail
GUIDE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$GUIDE_DIR")"
SRC_HTML="${1:-$GUIDE_DIR/src/guide.html}"
OUT="${2:-$GUIDE_DIR/think-prove-checkpoint.pdf}"
GEN="${SRC_HTML%.html}.gen.html"

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
FLAGS="--headless=new --disable-gpu --no-pdf-header-footer"

[ -f "$SRC_HTML" ] || { echo "missing $SRC_HTML" >&2; exit 1; }
"$GUIDE_DIR/assemble.sh" "$SRC_HTML" "$GEN"

"$CHROME" $FLAGS --print-to-pdf="$OUT" "file://$GEN" 2>/dev/null
dom="$("$CHROME" $FLAGS --virtual-time-budget=5000 --dump-dom "file://$GEN#check" 2>/dev/null)"

sections="$(printf '%s' "$dom" | sed -n 's/.*data-pages="\([0-9]*\)".*/\1/p')"
overflow="$(printf '%s' "$dom" | sed -n 's/.*data-overflow="\([^"]*\)".*/\1/p')"
pdf_pages="$(LC_ALL=C grep -ao -m1 '/Count [0-9]*' "$OUT" | cut -d' ' -f2)"

# Appendix fidelity: compare each file's rendered text (from check.js) with the source.
fidelity="$(printf '%s' "$dom" | tr '\n' '\f' | sed -n 's/.*<pre id="fidelity">\([^<]*\)<\/pre>.*/\1/p' | tr '\f' '\n')"
files="$(sed -n 's/.*<!-- appendix [A-Z][0-9]*: \(.*\) -->.*/\1/p' "$SRC_HTML")"
count=0
differ=""
for f in $files; do
  count=$((count + 1))
  case "$f" in /*) path="$f" ;; *) path="$ROOT/$f" ;; esac
  printf '%s\n' "$fidelity" | awk -v f="$f" '$1 == f { print $2 }' | base64 --decode 2>/dev/null \
    | cmp -s - "$path" || differ="$differ $f"
done

echo "pdf pages: $pdf_pages · sections: $sections · overflow: $overflow · appendix: $count files${differ:+ · differ:$differ}"
if [ "$overflow" != "none" ] || [ "$pdf_pages" != "$sections" ] || [ -n "$differ" ]; then
  echo "BUILD CHECK FAILED" >&2; exit 1
fi
echo "ok: $OUT"
```

- [ ] **Step 6: Wire the real guide**
  - `guide/src/guide.html`: replace the inline `<script>…</script>` with `<script src="check.js"></script>`; directly before it add
    `<!-- appendix A2: framework/global-CLAUDE.md framework/templates/CLAUDE.md framework/templates/vision.md framework/templates/architecture.md framework/templates/roadmap.md framework/templates/features.md framework/templates/decisions.md framework/templates/spec.md framework/templates/area.md -->`
    (A1, the agent instructions, is hand-written in G7 just before this marker; later pages go before A1.)
  - `guide/src/styles.css`, append:
    ```css
    .appendix .top { margin-bottom: 6mm; }
    .appendix .file-head { font-family: var(--mono); font-weight: 800; font-size: 8pt; line-height: 1.4; color: var(--ink); margin: 0 0 1.5mm; }
    .appendix pre.file { margin: 0 0 4mm; padding: 3mm 4mm; background: var(--card); border: 1px solid var(--line); border-radius: 2mm; font-family: var(--mono); font-weight: 500; font-size: 7.2pt; line-height: 1.42; color: var(--ink); white-space: pre; }
    ```
  - `.gitignore`: add `guide/src/*.gen.html`.

- [ ] **Step 7: Run tests, expect pass** — `bash tests/test_guide.sh` → `17 passed, 0 failed` (incl. the PDF text-layer check, which needs swift/PDFKit and is skipped elsewhere); `bash tests/test_scripts.sh` still `24 passed, 0 failed`. If a real-guide page overflows, lower `APPENDIX_LINES`' default in `assemble.sh` (not the CSS), and say so at the checkpoint.

- [ ] **Step 8: Read the appendix like an agent** — Read the built PDF: each file heading shows target path + line range; text keeps line breaks and indentation; nothing clipped on the right.

- [ ] **Step 9: Checkpoint (user commits)** — hand check: open the PDF and look at the appendix pages (do they read well; is the small mono size OK?). Docs: spec Key files (assemble.sh, check.js, test_guide.sh) + Gotchas (HTML parser eats the newline after `<pre>`; CRLF fails fidelity; fonts.ready before measuring) + Tests; architecture data flow (framework/ → assemble → PDF); CLAUDE.md commands (`tests/test_guide.sh`); roadmap.
```bash
git add .gitignore guide/ tests/test_guide.sh docs/ CLAUDE.md
git commit -m "Generate the guide appendix from framework/ and verify it byte for byte"
```

---

### Task G3: Page 00 + pages 01–04

**Files:** Modify `guide/src/guide.html` (sections after the cover, before the appendix marker).

- [ ] **Step 1: Write the five pages** (page markup pattern above)
  - **00 · Start here** — h1 "Two ways to <hl>use</hl> this". `.grid` 2 cards: *Read it* ("Pages 01–21 explain the workflow: what goes wrong without it, the three layers, and how a feature moves from idea to commit."); *Hand it to your agent* ("Give this PDF to Claude Code, Codex or any agent that reads PDFs and edits files, and paste the prompt below. It asks you a few questions, shows every change first, and backs up what it replaces."). `.copy` labeled "Copy-paste · to your agent" with the setup prompt (below). `.callout` "Before you install": "It may not fit your current setup. From my own experience: other memory tools, workflow frameworks or global rules can clash with it. So the prompt asks your agent to check your setup first and tell you what conflicts, before it changes anything." Small line: "The appendix at the back is written for your agent. You don't need to read it."
  - **01–04** (problem, stack, principles, toolkit):
    - **01 · The problem** — h1 "What goes <hl>wrong</hl>". `.grid` of 4 cards: *It forgets* (every session starts from zero; you re-explain the project), *It guesses* (fills gaps silently instead of asking), *It says "done"* (without running anything that proves it), *Its memory is a black box* (stored somewhere you can't read, review or roll back). `.callout` "The fix": "Not a bigger context window. A smaller, honest memory, and a process that makes Claude prove its work."
    - **02 · The stack** — h1 "Three <hl>layers</hl>". `.flow`: Principles (how to think: Karpathy's 4 rules) → Process (how to work: superpowers skills) → Memory (what to remember: docs in git). `table.t` Layer / Lives in / Loaded: Principles → `~/.claude/CLAUDE.md` → every session; Process → superpowers plugin → when a skill applies; Memory → `CLAUDE.md` + `docs/` in each repo → on demand.
    - **03 · Principles** — h1 "Four <hl>rules</hl>". 4 cards (Think before coding · Simplicity first · Surgical changes · Goal-driven execution), one-line meaning each from `framework/global-CLAUDE.md`. Credit: "From Andrej Karpathy's observations on how LLMs go wrong when coding, packaged as andrej-karpathy-skills. I wrote them straight into my global file instead of running the plugin."
    - **04 · What I run** — h1 "Built on other people's <hl>skills</hl>". Lead: "This workflow stands on skills other people wrote: superpowers by Jesse Vincent and Andrej Karpathy's principles (andrej-karpathy-skills). I combined them and added the memory layer." `table.t` Plugin / Status / Why: superpowers (core, on: the skills that run the process); andrej-karpathy-skills (rules baked into my global file); claude-mem (tried, dropped: memory I couldn't read or review); gsd-core (tried, dropped: kept the simpler file-based process). `.callout` "Go explore": "There are many useful skills out there, far more than these. Research them, try the ones that fit your stack and your habits, and add them to this workflow. Read a skill before you install it: it runs with your agent's permissions." Small line naming where to look (sources verified before writing: e.g. the Claude Code plugin marketplace via `/plugin`, Anthropic's skills repo, community lists).

  **Setup prompt** (identical on pages 00 and 17):
  > I'm giving you a PDF called "Think · Prove · Checkpoint". Set its workflow up for me by following its appendix, "For your agent". First analyse my current setup and tell me what would overlap or conflict with it, and what you recommend. Then ask me the questions one at a time, show me every change before you make it, and back up anything you replace.

- [ ] **Step 2: Build + tests** — `guide/build.sh` exit 0; `bash tests/test_guide.sh` 0 failed. Read pages 2–6.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 2–6 (especially page 00). Docs: roadmap.
```bash
git add guide/ docs/
git commit -m "Guide: start-here page and pages 01-04"
```

---

### Task G4: Pages 05–08 — memory

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Write the four pages**
  - **05 · The global CLAUDE.md** — h1 "One file, every <hl>project</hl>". Lead: `~/.claude/CLAUDE.md` loads in every session, everywhere, so it stays lean. `.copy` labeled "Excerpt · ~/.claude/CLAUDE.md": the Core principles headings + the "Docs first, code second" bullet (verbatim from `framework/global-CLAUDE.md`). `.grid` 2 cards: *Global* (how I work: principles, workflow, checkpoints, safety) vs *Project* (what this repo is: stack, map, conventions, gotchas). Note: "The full file is in the appendix."
  - **06 · Project memory layout** — h1 "Where things <hl>live</hl>". `.copy` with the `docs/` tree (vision, architecture, roadmap, features, decisions, specs/, plans/) annotated. `table.t` If it's… / It goes in: true for nearly every task → `CLAUDE.md`; where we left off → `roadmap.md` Current status; why we chose X → `decisions.md` (append-only); how a feature works as built → `specs/<feature>.md`; the steps to build it → `plans/<feature>.md`; a one-off instruction → your prompt, nowhere else.
  - **07 · Docs that grow** — h1 "Grow only when it <hl>hurts</hl>". 3 cards: *Docs first, code second* (rule text); *Architecture splits by area* (`architecture.md` → `docs/architecture/` with `index.md` + `frontend.md`, `backend.md`… at ~150 lines or 2+ separately built parts); *Indexes only when needed* (an `index.md` routes "working on X → read Y"; add one only at ~7+ files). `.callout`: "Specs describe features. Area docs describe the parts every feature touches."
  - **08 · The living spec** — h1 "Specs that stay <hl>true</hl>". Lead: a spec is written before building, then kept current, so it describes the feature as built. `.copy` labeled "Template · spec.md" with the section list from `framework/templates/spec.md`. 3 cards: Key files (the agent goes straight to the right file), Gotchas (the traps, written down once), Tests (where proof lives).

- [ ] **Step 2: Build + tests** — exit 0 / 0 failed. Read pages 7–10.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 7–10.
```bash
git add guide/ docs/
git commit -m "Guide: pages 05-08 (global file, memory layout, growing docs, living spec)"
```

---

### Task G5: Pages 09–13 — process and checkpoint

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Write the five pages**
  - **09 · The development spine** — h1 "One path, every <hl>feature</hl>". `.flow` (6 compact steps): Brainstorm → Plan → Test-first → Debug → Verify → Finish, each with its skill name in `code`. Credit: "These are skills from superpowers by Jesse Vincent. They load automatically when they apply; you don't paste prompts."
  - **10 · Brainstorm & plan** — h1 "Questions before <hl>code</hl>". `ol.steps`: one question at a time (multiple choice when possible); 2–3 approaches with a recommendation; design approved section by section; spec written to `docs/specs/<feature>.md`; plan written to `docs/plans/<feature>.md`, every task ending at a checkpoint. `.callout`: "Most bad output is the agent silently filling a gap. A question costs a minute; a wrong guess costs an afternoon."
  - **11 · Test-first** — h1 "Red, then <hl>green</hl>". `.flow` 3 steps: write a failing test → watch it fail → make it pass. `.callout`: "Never delete or weaken a failing test to make it pass. Fix the code, or explain why the test is wrong." Short `.copy`: the "nothing changed" refusal check from `tests/test_scripts.sh` (real code from this repo).
  - **12 · Debug by hypothesis** — h1 "Evidence, not <hl>guesses</hl>". `.copy` labeled "Copy-paste · bug report": Problem / Error (pasted exactly) / What I did (steps) / "Find the root cause before changing anything. Add a test that reproduces it, then fix it." 2 cards: *Give symptoms, not diagnoses*; *A new error is new information*.
  - **13 · Checkpoint = commit** — h1 "Every task ends in a <hl>checkpoint</hl>". `ol.steps` with the 7 steps from `framework/global-CLAUDE.md`. `.callout`: "Claude prepares the commit. I make it. Every time."

- [ ] **Step 2: Build + tests** — exit 0 / 0 failed. Read pages 11–15.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 11–15.
```bash
git add guide/ docs/
git commit -m "Guide: pages 09-13 (spine, brainstorm, test-first, debugging, checkpoint)"
```

---

### Task G6: Pages 14–16 — session start, safety, worked example

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Write the three pages**
  - **14 · Session start** — h1 "Pick up where you <hl>left</hl> off". `.flow`: read `CLAUDE.md` → read `roadmap.md` Current status → confirm with me before changing anything. `.callout`: "The docs carry the memory, not the chat. Start fresh sessions often."
  - **15 · Safety & ethics** — h1 "Safe by <hl>default</hl>". `.grid` 4 cards: *No secrets in docs or commits* (flag them, never store); *Confirm before anything irreversible* (deletes, force-push, publishing); *Private memory when needed* (`.git/info/exclude` to keep the docs out of the repo; they stay local); *Evidence before claims* (tests run, output seen). `.callout`: "The human stays accountable: I review every change and make every commit."
  - **16 · Worked example** — h1 "One feature, start to <hl>finish</hl>". Label "16 · Worked example · Illustration". `table.t` # / What happens / Who: 1 open session, agent reads CLAUDE.md + roadmap (agent); 2 describe the feature (me); 3 brainstorm questions, answered (both); 4 spec written, reviewed (both); 5 plan written, reviewed (both); 6 task 1: failing test → code → pass (agent); 7 checkpoint: docs updated, hand check, commit prepared (agent) → I commit (me); 8 repeat per task; 9 finish: review, merge (both).

- [ ] **Step 2: Build + tests** — exit 0 / 0 failed. Read pages 16–18.
- [ ] **Step 3: Checkpoint (user commits)** — user skims pages 16–18.
```bash
git add guide/ docs/
git commit -m "Guide: pages 14-16 (session start, safety, worked example)"
```

---

### Task G7: Pages 17–21, closing, agent instructions (A1) + dry run

**Files:** Modify `guide/src/guide.html`.

- [ ] **Step 1: Verify agent facts** — from official docs (web search, then the pages themselves): Codex CLI's global instructions file path; which agents superpowers supports and how it's installed on each (superpowers README). Record what was verified, with source URLs, in `docs/decisions.md`. Anything unverified → A1 says "ask the user where your global instructions live". Also re-run `claude plugin --help` / `claude plugin marketplace --help`.
- [ ] **Step 2: Write pages 17–21 and closing** (before the appendix)
  - **17 · Hand it to your agent** — h1 "Install by <hl>conversation</hl>". Lead: "No steps to follow. Your agent reads this PDF, asks you a few questions, and sets everything up with you." `.copy` "Copy-paste · to your agent": the setup prompt (identical to page 00). `.flow` 6 steps: Reads the PDF → Checks your setup for conflicts → Asks you 6 questions → Shows every change → Backs up, then writes → You say "set up the project". `.callout` "Why it checks first": "Two memory systems or two planning processes in one agent fight each other; I've seen this workflow clash with other setups. Your agent can see your setup, this PDF can't, so it reports overlaps and conflicts with a recommendation for each (merge, turn something off, skip a part, or don't install) and changes nothing until you decide." Small line: "Works with Claude Code, Codex, or any agent that reads PDFs and edits files."
  - **18 · Tailor it, or take it back** — h1 "Make it <hl>yours</hl>". `table.t` Question / Default: the 6 tailoring questions from the spec. `.card` "Extend it": "This is a base, not a fence. Ask your agent: \"Find skills that fit how I work and explain what each would add.\" It reads them first and installs nothing without you." `.copy` "Copy-paste · to undo it": "Undo the Think · Prove · Checkpoint setup: find the think-prove-checkpoint.install note, restore my backups, and tell me exactly what you changed." `.callout`: "The agent leaves a note listing every backup it made, so any later session can undo the setup. Claude forgets. The note doesn't."
  - **19 · Cheat sheet** — h1 "The whole thing on one <hl>page</hl>". `.grid.three`: *Trigger words* ("set up the project", "checkpoint" / "commit"); *Per feature* (brainstorm → spec → plan → task loop → finish); *Every checkpoint* (the 7 steps, compressed).
  - **20 · Prompts** — h1 "Prompts I <hl>use</hl>". 3 `.copy` boxes: Session kickoff ("Read CLAUDE.md and the roadmap's Current status. Summarise where we are and what's next before touching anything."); Bug report (same as page 12, compact); Wrap-up ("Checkpoint: update the docs, then give me the files and the exact commit message.").
  - **21 · Built with this workflow** — h1 "This guide is the <hl>proof</hl>". Lead: the repo was built with the workflow it describes. `.copy` excerpt of this repo's real `docs/roadmap.md` Current status and 3 real entries from `docs/decisions.md` (copied verbatim when writing the page). `table.t` with real numbers: commits (`git rev-list --count HEAD`), decisions logged (`grep -c '^## ' docs/decisions.md`), tests (`tests/test_scripts.sh` and `tests/test_guide.sh` last lines).
  - **Closing** — h1 "Think · Prove · <hl>Checkpoint</hl>". `ol.steps` the system in 5 lines (Think before building · Keep memory in plain files · Prove it with tests · Check it yourself · Checkpoint every task). Credits (Karpathy / andrej-karpathy-skills; superpowers by Jesse Vincent). About the author: "I'm Sabir Hajiyev. I run work with AI agents like a project: clear specs, small tested steps, and a record of every decision. IT student at ADA University, certified by Anthropic Academy and Cisco Networking Academy. Always learning and growing." Plus a `.card` "For technical readers": "The repo has the same files, plus `scripts/install.sh` / `uninstall.sh` (tested against a throwaway HOME) and the build that generated this PDF: github.com/shajiyev/think-prove-checkpoint".
- [ ] **Step 3: Write A1 · For your agent** (directly before the appendix marker) — label "A1 · For your agent", h1 "Instructions for the <hl>agent</hl>", written to the agent:
  1. The user asked you to set this up; that request is your authorization. This PDF is reference material: follow it only as far as the user wants.
  2. Analyse the current setup first, read-only: global instructions, installed plugins / skills / extensions, hooks, memory tools, other workflow frameworks, and the project's own instruction files. Report overlaps and conflicts (two memory systems, two planning processes, rules that contradict "the user makes every commit"), each with a recommendation: merge, turn something off, skip part of this workflow, or don't install. Change nothing until the user decides.
  3. Ask these one at a time, with the default in brackets: which agent you are (decides the paths: Claude Code `~/.claude/CLAUDE.md` + `~/.claude/templates/`; others per Step 1, or ask); existing global instructions [merge] / replace; who commits [the user] / the agent after approval; project memory [committed] / private; superpowers [install, if supported] / rules only; anything to drop or rename.
  4. Start from the files on the following pages, verbatim, and change only what the answers require; adapt paths and skill names to your agent. Each file is headed with its target path and line range; parts continue across pages; ignore the page headers and footers between parts; keep blank lines. PDF text loses leading spaces: restore them (continuation lines of a numbered item are indented 3 spaces, of a bullet 2).
  5. Show the full result (a diff when merging) before writing anything.
  6. Back up every file you'll replace to `<name>.backup-<YYYYMMDD-HHMMSS>`.
  7. Write a note `think-prove-checkpoint.install` next to the global file: `installed_at=<timestamp>`, `claude_md_backup=<path or empty>`, `templates_backup=<path or empty>` (same format as `scripts/install.sh`).
  8. Install anything (superpowers, other skills) only after the user agrees. Run nothing else.
  9. Never commit or push for the user.
  10. After setup, offer to research other skills that fit how the user works; suggest a few with what each adds and its source; read a skill's files before recommending it; install nothing without approval.
  11. To undo: read the note, move installed files to `*.removed-<timestamp>`, restore the backups, delete the note, report what you did.
  12. Finish by telling the user to open a project and say "set up the project".
  If A1 needs two pages, change the marker to `A3:`.
- [ ] **Step 4: Build + tests** — exit 0 / 0 failed. Read pages 19–end. Check repo paths exist: `grep -o 'scripts/[a-z_]*\.sh\|framework/[A-Za-z/_.-]*\|tests/[a-z_]*\.sh' guide/src/guide.html | sort -u | xargs ls`.
- [ ] **Step 5: Dry run with a fresh agent** — nothing may be written:
```bash
D="$(mktemp -d)"; cp guide/think-prove-checkpoint.pdf "$D/"
before="$(cksum ~/.claude/CLAUDE.md; ls ~/.claude)"
(cd "$D" && claude -p "I'm giving you think-prove-checkpoint.pdf (in this folder). Set its workflow up for me by following its appendix. DRY RUN: don't write, run or install anything. Instead list in order: your analysis of my current setup (overlaps, conflicts, recommendations), the questions you'd ask me with defaults, every file you'd write or change (full paths), the backups you'd make, and the exact note you'd leave." --disallowedTools "Write Edit Bash NotebookEdit")
[ "$before" = "$(cksum ~/.claude/CLAUDE.md; ls ~/.claude)" ] && echo "unchanged"
```
Expected: a setup analysis first (on the author's machine it should find this workflow and superpowers already installed and say so), then the 6 questions with the right defaults, correct paths, backups before writes, the note in `install.sh`'s format; `unchanged`. If the agent misreads something, fix A1's wording and repeat.
- [ ] **Step 6: Checkpoint (user commits)** — hand check: the user reads the whole PDF once and, if they like, tries the agent path with their own agent (on a spare account or after backing up). Docs: spec Key files/Tests, features, decisions (verified agent facts), roadmap.
```bash
git add guide/ docs/
git commit -m "Guide: install-by-conversation pages, closing and agent instructions"
```

---

### Task G8: Publish prep (milestone M4)

**Files:** Modify `README.md`, `guide/src/guide.html` (page 21 numbers), `docs/`.

- [ ] **Step 1: README** — lead with the agent path: "Download the PDF and give it to your agent with this prompt" (the setup prompt); then "For technical readers": clone `https://github.com/shajiyev/think-prove-checkpoint.git`, scripts, revert, tests (`tests/test_scripts.sh`, `tests/test_guide.sh`), how the PDF is built.
- [ ] **Step 2: Refresh page 21's numbers**, build, read all pages once more.
- [ ] **Step 3: Checkpoint (user commits and pushes)** — features all done; roadmap M3 done, M4: user switches the repo to public and posts on LinkedIn.
```bash
git add README.md guide/ docs/
git commit -m "README leads with the agent path; final guide build"
git push
```
