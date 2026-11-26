# Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the guide as a website (hero + 24 sections + "Set it up") built from the same
source as the PDF, with project facts (version, date, links) kept in one file.

**Architecture:** `project.json` holds the facts; `guide/assemble.sh` fills them into anything it
assembles. `guide/src/tokens.css` holds fonts and colour tokens for print and web. `site/build.sh`
assembles `guide.html`, splits it with awk into hero / navigation / sections, splices those into
the template `site/src/index.html`, copies the assets and the committed PDF into `site/dist/`, and
screenshots the hero for the link preview. `site/dist/` is committed; Vercel only serves it.

**Tech Stack:** HTML, CSS, vanilla JS, bash + BWK awk (macOS), Google Chrome headless.

**Spec:** `docs/specs/landing-page.md`

## Global Constraints

- One source each: facts in `project.json`, look in `guide/src/tokens.css`, content in `guide/src/guide.html`. Never type a fact or a colour anywhere else.
- `project.json` stays flat: one `"key": "value"` per line; keys `version`, `released`, `repo`, `linkedin`, `site`.
- No new dependencies: no framework, no package manager, no `jq`. Bash 3.2 (no associative arrays, `mapfile`, `${var,,}`).
- Paths handed to Chrome are absolute (`file://` + absolute path).
- Tests never change committed files (builds in tests write to `mktemp -d` folders).
- Animations are off under `prefers-reduced-motion`; without JS every section is visible.
- No horizontal page scroll at 375px; 16px side gutter.
- Reader-facing text uses British spelling ("licence" as the noun, "behaviour").
- Credits stay in "The end": Karpathy (principles), superpowers by Jesse Vincent (skills).
- No personal data beyond the author credit and the LinkedIn link. Never an email.
- `guide/build.sh` and `site/build.sh` exit 0 and all three test files pass before any checkpoint.
- **The user makes every commit.** Each task ends with a checkpoint: update docs, rebuild, hand check, give the exact commit, stop. Commit messages end with a blank line and `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Build order everywhere: `guide/build.sh && site/build.sh`, then tests.

## File map

| File | Responsibility |
|---|---|
| `project.json` | The facts |
| `guide/assemble.sh` | Fills facts + page 21 counts; expands the appendix; fails on unfilled `{{…}}` |
| `guide/src/tokens.css` | `@font-face` + `:root` tokens (only file with colour values) |
| `guide/src/styles.css` | Print layout; `@import`s tokens |
| `guide/src/guide.html` | Content; facts as `{{placeholders}}` |
| `site/src/index.html` | Page template: head, nav shell, hero buttons, "Set it up", footer |
| `site/src/web.css` | Screen layout + look; `@import`s tokens |
| `site/src/site.js` | Reveal, current section, progress, phone menu, copy buttons, `#check` test hook |
| `site/build.sh` | Builds `site/dist/` |
| `site/dist/` | The deployed site (committed) |
| `tests/test_guide.sh` | + facts tests, real build to a temp folder |
| `tests/test_site.sh` | Site tests |

---

### Task L1: Facts in one place

**Files:**
- Create: `project.json`
- Modify: `guide/assemble.sh` (header comment, counts block, awk `-v` list, fill rules, end)
- Modify: `guide/src/guide.html:606,608,616` and page 21's commits cell
- Modify: `README.md:7` (add a version line)
- Test: `tests/test_guide.sh`

**Interfaces:**
- Produces: placeholders `{{version}} {{released}} {{repo}} {{repo_display}} {{linkedin}} {{site}}`;
  env `FACTS` (path to a facts file, default `project.json`); `assemble.sh` exit 2 = missing fact,
  exit 3 = unfilled placeholder; page 21 marks `<td data-fact="commits">N</td>`.

- [ ] **Step 1: Write the failing tests** — in `tests/test_guide.sh`:

Replace `real_build`'s line with (tests must not rewrite the committed PDF):
```bash
real_build() { "$ROOT/guide/build.sh" "$ROOT/guide/src/guide.html" "$TMP/real.pdf" > "$TMP/real.log" 2>&1; }
```
Replace the commit-count check with:
```bash
check "commit count matches git" grep -q "<td data-fact=\"commits\">$(git -C "$ROOT" rev-list --count HEAD)</td>" "$gen"
```
After the page 21 block, add:
```bash
echo "# facts come from project.json"
fact() { sed -n "s/^[[:space:]]*\"$1\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$ROOT/project.json"; }
check "version line uses project.json" grep -qF "Version $(fact version) · $(fact released) · " "$gen"
check "repo link uses project.json" grep -qF "href=\"$(fact repo)\"" "$gen"
check "LinkedIn link uses project.json" grep -qF "href=\"$(fact linkedin)\"" "$gen"
check "no fact is typed into guide.html" refuses grep -qE "$(fact version) · $(fact released)|github\.com/shajiyev|linkedin\.com/in" "$ROOT/guide/src/guide.html"
check "README shows the version from project.json" grep -qF "Version $(fact version) · $(fact released)" "$ROOT/README.md"
check "README links the repo from project.json" grep -qF "$(fact repo)" "$ROOT/README.md"
check "README links LinkedIn from project.json" grep -qF "$(fact linkedin)" "$ROOT/README.md"
site_linked() { local s; s="$(fact site)"; [ -z "$s" ] || grep -qF "$s" "$ROOT/README.md"; }
check "README links the site, once there is one" site_linked

assemble_with() { FACTS="$1" "$ROOT/guide/assemble.sh" "$TMP/$2.html" "$TMP/$2.gen.html" > "$TMP/$2.log" 2>&1; }
sed 's/"version": "[^"]*"/"version": "9.9"/' "$ROOT/project.json" > "$TMP/custom.json"
printf '<p>Version {{version}}</p>\n' > "$TMP/ver.html"
check "facts are read from the facts file" assemble_with "$TMP/custom.json" ver
check "...and filled in" grep -q "Version 9.9" "$TMP/ver.gen.html"
printf '{\n  "version": "9.9"\n}\n' > "$TMP/partial.json"
printf '<p>ok</p>\n' > "$TMP/plain.html"
check "a fact missing from the facts file fails" refuses assemble_with "$TMP/partial.json" plain
check "...and names it" logged plain 'missing "released"'
printf '<p>{{nope}}</p>\n' > "$TMP/unknown.html"
check "an unknown placeholder fails" refuses assemble_with "$ROOT/project.json" unknown
check "...and names it" logged unknown "{{nope}}"
```

- [ ] **Step 2: Run, watch them fail**

Run: `tests/test_guide.sh`
Expected: FAIL on the commit-count check, every "facts" check, and the three fixture failures
(`project.json` doesn't exist yet → `fact` is empty; `assemble.sh` ignores `FACTS`).

- [ ] **Step 3: Create `project.json`**

```json
{
  "version": "1.0",
  "released": "November 2026",
  "repo": "https://github.com/shajiyev/think-prove-checkpoint",
  "linkedin": "https://www.linkedin.com/in/sabir-hajiyev-9948a9364/",
  "site": ""
}
```

- [ ] **Step 4: Teach `guide/assemble.sh` the facts**

Header comment, replace the "Also fills the page 21 counts" line with:
```bash
# Also fills the page 21 counts: {{commits}} {{decisions}} {{script_checks}} {{guide_checks}},
# and the facts from project.json (or $FACTS): {{version}} {{released}} {{repo}} {{repo_display}}
# {{linkedin}} {{site}}. Fails on a missing fact (exit 2) or an unfilled {{placeholder}} (exit 3).
```
After `GUIDE_CHECKS=…`, add:
```bash
FACTS="${FACTS:-$ROOT/project.json}"
[ -f "$FACTS" ] || { echo "missing $FACTS" >&2; exit 2; }
# fact KEY: the value of a flat, one-per-line  "KEY": "value"  in the facts file.
fact() {
  grep -q "^[[:space:]]*\"$1\":" "$FACTS" || { echo "project.json: missing \"$1\"" >&2; return 2; }
  sed -n "s/^[[:space:]]*\"$1\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$FACTS"
}
VERSION="$(fact version)"; RELEASED="$(fact released)"; REPO="$(fact repo)"
LINKEDIN="$(fact linkedin)"; SITE="$(fact site)"
REPO_DISPLAY="${REPO#https://}"
```
(`set -e` stops on a failed `x="$(fact …)"` assignment, with the message already on stderr.)

Add to the `awk` call's `-v` list:
```bash
    -v version="$VERSION" -v released="$RELEASED" -v repo="$REPO" \
    -v repo_display="$REPO_DISPLAY" -v linkedin="$LINKEDIN" -v site="$SITE" \
```
Replace the last rule's body with:
```awk
{
  gsub(/\{\{commits\}\}/, commits); gsub(/\{\{decisions\}\}/, decisions)
  gsub(/\{\{script_checks\}\}/, script_checks); gsub(/\{\{guide_checks\}\}/, guide_checks)
  gsub(/\{\{version\}\}/, version); gsub(/\{\{released\}\}/, released)
  gsub(/\{\{repo_display\}\}/, repo_display); gsub(/\{\{repo\}\}/, repo)
  gsub(/\{\{linkedin\}\}/, linkedin); gsub(/\{\{site\}\}/, site)
  print
}
```
After `' "$1" > "$2"`, add:
```bash
left="$(grep -o '{{[a-z_]*}}' "$2" | sort -u | tr '\n' ' ' || true)"
[ -z "$left" ] || { echo "unfilled placeholder(s): $left" >&2; exit 3; }
```

- [ ] **Step 5: Use the placeholders in `guide/src/guide.html`**

- Line 606: `href="https://www.linkedin.com/in/sabir-hajiyev-9948a9364/"` → `href="{{linkedin}}"`
- Line 608: `Version 1.0 · November 2026 · Latest version: <a class="link" href="https://github.com/shajiyev/think-prove-checkpoint">github.com/shajiyev/think-prove-checkpoint</a>`
  → `Version {{version}} · {{released}} · Latest version: <a class="link" href="{{repo}}">{{repo_display}}</a>`
- Line 616: `<span style="white-space: nowrap">github.com/shajiyev/think-prove-checkpoint</span>` → `<span style="white-space: nowrap">{{repo_display}}</span>`
- Page 21: `<td>{{commits}}</td>` → `<td data-fact="commits">{{commits}}</td>`

- [ ] **Step 6: Add the README version line** — after line 7 (`### **[Download the practical guide (PDF)]…**`), add a blank line and:
```markdown
Version 1.0 · November 2026 · MIT licence
```

- [ ] **Step 7: Run the tests, see them pass**

Run: `tests/test_guide.sh && tests/test_scripts.sh`
Expected: `… passed, 0 failed` for both.

- [ ] **Step 8: Rebuild and compare the PDF**

Run: `guide/build.sh` → expect `ok: …/think-prove-checkpoint.pdf`. Then compare text layers:
```bash
S=$(mktemp -d); git show HEAD:guide/think-prove-checkpoint.pdf > "$S/old.pdf"
swift tests/pdf_text.swift "$S/old.pdf" > "$S/old.txt"
swift tests/pdf_text.swift guide/think-prove-checkpoint.pdf > "$S/new.txt"
diff "$S/old.txt" "$S/new.txt"
```
Expected: at most the page 21 commit count differs (every fact reads as before).

- [ ] **Step 9: Checkpoint (docs, then stop for the user's commit)**

- `docs/roadmap.md`: add milestone **M5 — Website** (tasks L1–L7 as boxes; L1 ticked); Current status: in progress L1 done, next L2.
- `docs/features.md`: rows "Project facts (`project.json`)" done; "Website" in progress.
- `docs/specs/landing-page.md`: Key files / Tests as built.
- `docs/decisions.md`: `## 2026-11-25 — Project facts live in project.json` (why: one change updates PDF, site, README checks; alternatives: generated README, shared text blocks).
- Root `CLAUDE.md` Conventions: "Facts (version, date, links) only in `project.json`."
- Rebuild `guide/build.sh` (decision count changed); rerun both tests.
- Doc-only for the user's eye: the PDF's last page reads the same. Commit:
```
project.json guide/assemble.sh guide/src/guide.html guide/think-prove-checkpoint.pdf README.md tests/test_guide.sh docs/ CLAUDE.md

Keep project facts in project.json; the guide and README follow it

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

---

### Task L2: Shared tokens

**Files:**
- Create: `guide/src/tokens.css`
- Modify: `guide/src/styles.css:1-15`
- Test: `tests/test_guide.sh`

**Interfaces:**
- Produces: `guide/src/tokens.css` (fonts at `fonts/…` relative to it); `--paper --card --ink --ink-2 --muted --line --accent --accent-soft --ok --ok-soft --code-bg --code-ink --code-muted --sans --mono`.

- [ ] **Step 1: Write the failing test** — append before the final summary in `tests/test_guide.sh`:
```bash
echo "# one look: colours only in tokens.css"
colour_literals() { grep -nE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?([^0-9a-zA-Z_-]|$)|rgba?\(|hsla?\(' "$@"; }
check "tokens.css exists and holds the palette" grep -q -- '--accent:' "$ROOT/guide/src/tokens.css"
check "no colour values in styles.css or guide.html" refuses colour_literals "$ROOT/guide/src/styles.css" "$ROOT/guide/src/guide.html"
```

- [ ] **Step 2: Run, watch it fail**

Run: `tests/test_guide.sh` → FAIL on both new checks (no `tokens.css`; hex values in `styles.css`).
Then build a baseline PDF from the unchanged CSS: `S=$(mktemp -d); guide/build.sh "$PWD/guide/src/guide.html" "$S/before.pdf"`.

- [ ] **Step 3: Move lines 1–15 of `styles.css` into `guide/src/tokens.css`**

`tokens.css`:
```css
/* Fonts and design tokens, shared by the PDF (styles.css) and the website (site/src/web.css).
   The only file that holds colour values. */
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
```
`styles.css`: delete lines 1–15 and start the file with:
```css
@import url("tokens.css");
```

- [ ] **Step 4: Run the tests, see them pass**

Run: `tests/test_guide.sh` → `… passed, 0 failed` (fixtures link `styles.css` by `file://`, so the import resolves beside it).

- [ ] **Step 5: Prove the PDF looks the same**

Run (same `$S` as Step 2, same commit, so page 21 is identical): `guide/build.sh "$PWD/guide/src/guide.html" "$S/after.pdf" && cmp -l "$S/before.pdf" "$S/after.pdf" | wc -l`
Expected: a few dozen bytes at most (only the creation date differs).
If it's more, the layout changed: stop and investigate. Then `guide/build.sh` for the real PDF.

- [ ] **Step 6: Checkpoint**

- Roadmap: L2 ticked; next L3. Spec Key files: `tokens.css`. Architecture: tokens file.
- `CLAUDE.md` Conventions: "Guide colors and fonts are CSS tokens in `guide/src/tokens.css`, shared by print and web."
- Rebuild, rerun tests. Commit:
```
guide/src/tokens.css guide/src/styles.css guide/think-prove-checkpoint.pdf tests/test_guide.sh docs/ CLAUDE.md

Move fonts and colour tokens into tokens.css, shared by print and web

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

---

### Task L3: Site build — structure

**Files:**
- Create: `site/build.sh`, `site/src/index.html`, `site/src/web.css` (stub), `site/src/site.js` (stub), `tests/test_site.sh`
- Modify: `guide/assemble.sh` (`{{site_checks}}`), `guide/src/guide.html` (page 21 row)
- Docs: split `docs/architecture.md` → `docs/architecture/{index,guide,site,installer}.md`

**Interfaces:**
- Consumes: `assemble.sh <src> <out>` with facts (L1); `tokens.css` (L2).
- Produces: `site/build.sh [out_dir]`, env `GUIDE_SRC`, `GUIDE_PDF`, `CHROME`; output
  `<section class="sec" id="SLUG">`, nav `<li><a href="#SLUG" data-name="NAME"><span class="num">NN</span>TITLE</a></li>`,
  hero inside `<header class="hero" id="top">`, setup `<section class="sec setup" id="set-it-up">`,
  footer `<footer class="site-foot">`; classes `.rail .bar .bar-name .progress .actions .btn .btn.primary`.

- [ ] **Step 1: Write the failing tests** — create `tests/test_site.sh` (executable):
```bash
#!/usr/bin/env bash
# Tests for site/build.sh: the real site (structure, facts, look) plus small fixture guides.
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
logged()  { grep -q -- "$2" "$TMP/$1.log"; }
fact()    { sed -n "s/^[[:space:]]*\"$1\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$ROOT/project.json"; }

# build NAME [GUIDE_SRC]: build the site into $TMP/NAME; log in $TMP/NAME.log
build() {
  local name="$1" src="${2:-$ROOT/guide/src/guide.html}"
  GUIDE_SRC="$src" "$ROOT/site/build.sh" "$TMP/$name" > "$TMP/$name.log" 2>&1
}
# fixture NAME (LABEL BODY)...: a guide with one page per LABEL/BODY pair
fixture() {
  local name="$1"; shift
  {
    echo '<!doctype html><html><body>'
    while [ $# -gt 1 ]; do
      echo '<section class="page">'
      echo "  <div class=\"top\"><span>Think · Prove · Checkpoint</span><span>$1</span></div>"
      echo "  $2"
      echo '  <div class="foot"><span>Think · Prove · Checkpoint</span><span class="n"></span></div>'
      echo '</section>'
      shift 2
    done
    echo '</body></html>'
  } > "$TMP/$name.html"
}
# every href="#x" in FILE has an id="x"
links_resolve() {
  local id
  for id in $(grep -o 'href="#[^"]*"' "$1" | sed 's/href="#//; s/"$//' | sort -u); do
    grep -q "id=\"$id\"" "$1" || { echo "  no target: #$id"; return 1; }
  done
}

echo "# real site"
check "site builds" build dist
html="$TMP/dist/index.html"
check "no {{placeholder}} left" refuses grep -q '{{' "$html"
check "24 guide sections" test "$(grep -c '^<section class="sec" id=' "$html")" -eq 24
check "...starting at 00 · Start here" grep -q '<section class="sec" id="00-start-here">' "$html"
check "...ending at The end" grep -q '<section class="sec" id="the-end">' "$html"
check "plus Set it up" grep -q '<section class="sec setup" id="set-it-up">' "$html"
check "navigation lists all 25" test "$(grep -c '<li><a href="#' "$html")" -eq 25
check "every in-page link has a target" links_resolve "$html"
check "no appendix pages" refuses grep -q 'A1 · For your agent' "$html"
check "no page header or footer strips" refuses grep -qE 'class="(top|foot|page)' "$html"
check "hero keeps the cover title" grep -qF '<h1>Think · Prove ·<br><span class="hl">Checkpoint</span></h1>' "$html"
check "hero drops the cover's contents table" refuses grep -q 'A1–A8' "$html"
check "hero links the PDF" grep -q 'href="think-prove-checkpoint.pdf"' "$html"
check "hero links the repo" grep -qF "href=\"$(fact repo)\"" "$html"
check "version line comes from project.json" grep -qF "Version $(fact version) · $(fact released)" "$html"
check "page 21 counts the site tests" grep -q "<td>$(grep -cE '^[[:space:]]*check ' "$ROOT/tests/test_site.sh") checks</td>" "$html"
check "ships the committed PDF" cmp -s "$TMP/dist/think-prove-checkpoint.pdf" "$ROOT/guide/think-prove-checkpoint.pdf"
check "ships the fonts" test -f "$TMP/dist/fonts/inter-latin-400-normal.woff2"
check "ships tokens, styles and script" test -f "$TMP/dist/tokens.css" -a -f "$TMP/dist/web.css" -a -f "$TMP/dist/site.js"

echo "# the build refuses bad input"
fixture nameless "" "<p>x</p>"
check "a page with no section name fails" refuses build nameless "$TMP/nameless.html"
check "...and says so" logged nameless "no section name"
fixture twice "01 · Same" "<p>a</p>" "01 · Same" "<p>b</p>"
check "two sections with one anchor fail" refuses build twice "$TMP/twice.html"
check "...and name it" logged twice "duplicate section: 01-same"
nopdf() { GUIDE_PDF="$TMP/nope.pdf" "$ROOT/site/build.sh" "$TMP/nopdf" > "$TMP/nopdf.log" 2>&1; }
check "a missing PDF fails" refuses nopdf
check "...and says to build it" logged nopdf "run guide/build.sh first"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: Run, watch it fail**

Run: `chmod +x tests/test_site.sh && tests/test_site.sh`
Expected: FAIL from "site builds" on (`site/build.sh` doesn't exist). The three "refuses" checks
pass for the wrong reason (no script); they get their real proof with their "…and says so" logs,
which FAIL now.

- [ ] **Step 3: Page 21 counts the site tests**

`guide/assemble.sh`: after `GUIDE_CHECKS=…` add `SITE_CHECKS="$(checks "$ROOT/tests/test_site.sh")"`;
add `-v site_checks="$SITE_CHECKS"` to the awk call; in the fill rule add `gsub(/\{\{site_checks\}\}/, site_checks)`;
extend the header comment's count list with `{{site_checks}}`.

`guide/src/guide.html`, page 21 table, after the "Guide build tests" row:
```html
    <tr><td>Website build tests</td><td>{{site_checks}} checks</td></tr>
```

- [ ] **Step 4: Create the template `site/src/index.html`**

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Think · Prove · Checkpoint</title>
<meta name="description" content="A practical guide to building software with AI agents: principles that stop the guessing, skills that demand proof, and project memory that lives in git.">
<script>document.documentElement.classList.add(location.hash === "#og" ? "og" : "js");</script>
<link rel="stylesheet" href="web.css">
</head>
<body>
<div class="progress" aria-hidden="true"><span></span></div>
<button class="bar" type="button" aria-expanded="false" aria-controls="toc"><span class="bar-name">Contents</span><span aria-hidden="true">☰</span></button>
<nav class="rail" id="toc" aria-label="Sections">
  <a class="rail-home" href="#top">Think · Prove · Checkpoint</a>
  <ol>
<!-- nav -->
<li><a href="#set-it-up" data-name="Set it up"><span class="num">→</span>Set it up</a></li>
  </ol>
  <a class="btn small" href="think-prove-checkpoint.pdf" download>Download the PDF</a>
</nav>
<main>
<header class="hero" id="top">
<!-- hero -->
  <div class="actions">
    <a class="btn primary" href="#00-start-here">Read the guide</a>
    <a class="btn" href="think-prove-checkpoint.pdf" download>Download the PDF</a>
    <a class="btn" href="{{repo}}">GitHub</a>
  </div>
</header>

<!-- sections -->
<section class="sec setup" id="set-it-up">
  <p class="label">Set it up</p>
  <h1>Hand it to your <span class="hl">agent</span></h1>
  <p class="lead">Download the PDF, give it to your agent, and paste the prompt from <a href="#00-start-here">00 · Start here</a>. Your agent checks your setup first and changes nothing until you decide.</p>
  <div class="actions">
    <a class="btn primary" href="think-prove-checkpoint.pdf" download>Download the PDF</a>
    <a class="btn" href="{{repo}}">View on GitHub</a>
  </div>
  <p class="note">Prefer the files? <a href="{{repo}}/tree/main/framework">framework/</a> holds the global file and the templates; <a href="{{repo}}/tree/main/scripts">scripts/</a> installs and uninstalls them.</p>
</section>
</main>
<footer class="site-foot">
  <p>Version {{version}} · {{released}} · MIT licence · <a href="{{repo}}">{{repo_display}}</a></p>
</footer>
<script src="site.js"></script>
</body>
</html>
```

- [ ] **Step 5: Create the stubs** (filled in L4 and L5)

`site/src/web.css`:
```css
@import url("tokens.css");
/* The guide on screens: layout and look come in Task L4. */
```
`site/src/site.js`:
```js
// Site behaviour: comes in Tasks L4 (test hook) and L5.
```

- [ ] **Step 6: Create `site/build.sh`** (executable)

```bash
#!/usr/bin/env bash
# Build the website from the guide's own source into site/dist/ (or the folder given).
# The cover becomes the hero; every page up to "The end" becomes a section, named from its header
# strip; the appendix is dropped. Facts come from project.json via guide/assemble.sh.
# The committed PDF is copied, not rebuilt: run guide/build.sh first.
# Usage: build.sh [out_dir]    Env: GUIDE_SRC (guide html), GUIDE_PDF (PDF to ship), CHROME
set -euo pipefail
SITE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SITE_DIR")"
OUT="${1:-$SITE_DIR/dist}"
GUIDE_SRC="${GUIDE_SRC:-$ROOT/guide/src/guide.html}"
GUIDE_PDF="${GUIDE_PDF:-$ROOT/guide/think-prove-checkpoint.pdf}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

[ -f "$GUIDE_PDF" ] || { echo "missing $GUIDE_PDF: run guide/build.sh first" >&2; exit 1; }
"$ROOT/guide/assemble.sh" "$GUIDE_SRC" "$WORK/guide.gen.html"
"$ROOT/guide/assemble.sh" "$SITE_DIR/src/index.html" "$WORK/index.html"

# Split the assembled guide into hero.html, nav.html and sections.html.
: > "$WORK/hero.html"; : > "$WORK/nav.html"; : > "$WORK/sections.html"
awk -v dir="$WORK" '
function slug(s) { s = tolower(s); gsub(/&amp;/, "", s); gsub(/[^a-z0-9]+/, "-", s); gsub(/^-+|-+$/, "", s); return s }
function flush(   id, num, title) {
  if (kind == "hero") { printf "%s", buf > (dir "/hero.html"); return }
  if (kind != "sec") return
  if (name == "") { print "no section name: a page header strip has no second <span> text" > "/dev/stderr"; exit 2 }
  id = slug(name)
  if (id in seen) { print "duplicate section: " id > "/dev/stderr"; exit 2 }
  seen[id] = 1
  printf "<section class=\"sec\" id=\"%s\">\n%s</section>\n\n", id, buf > (dir "/sections.html")
  num = ""; title = name
  if (match(name, /^[0-9]+ · /)) { num = substr(name, 1, index(name, " ") - 1); title = substr(name, RLENGTH + 1) }
  printf "<li><a href=\"#%s\" data-name=\"%s\"><span class=\"num\">%s</span>%s</a></li>\n", id, name, num, title > (dir "/nav.html")
}
/^<section class="page/ { kind = ($0 ~ /cover/) ? "hero" : ($0 ~ /agent|appendix/) ? "drop" : "sec"; buf = ""; name = ""; intable = 0; next }
/^<\/section>/ { flush(); kind = ""; next }
kind == "" || kind == "drop" { next }
/<div class="top">/ { s = $0; sub(/.*<\/span><span>/, "", s); sub(/<\/span><\/div>.*/, "", s); name = s; next }
/<div class="foot">/ { next }
kind == "hero" && /<table class="t">/ { intable = 1 }
intable { if (/<\/table>/) intable = 0; next }
{ buf = buf $0 "\n" }
' "$WORK/guide.gen.html"

# Splice the parts into the template at <!-- hero -->, <!-- nav -->, <!-- sections -->.
awk -v dir="$WORK" '
/^<!-- (hero|nav|sections) -->$/ { f = $0; sub(/^<!-- /, "", f); sub(/ -->$/, "", f)
  while ((getline l < (dir "/" f ".html")) > 0) print l; next }
{ print }
' "$WORK/index.html" > "$WORK/page.html"

mkdir -p "$OUT/fonts"
OUT="$(cd "$OUT" && pwd)"
cp "$WORK/page.html" "$OUT/index.html"
cp "$ROOT/guide/src/tokens.css" "$SITE_DIR/src/web.css" "$SITE_DIR/src/site.js" "$OUT/"
cp "$ROOT/guide/src/fonts/"* "$OUT/fonts/"
cp "$GUIDE_PDF" "$OUT/think-prove-checkpoint.pdf"

echo "sections: $(grep -c '^<section class="sec" id=' "$OUT/index.html") · ok: $OUT/index.html"
```

- [ ] **Step 7: Run the tests, see them pass**

Run: `chmod +x site/build.sh && guide/build.sh && tests/test_site.sh`
Expected: `… passed, 0 failed`. Also `tests/test_guide.sh` (page 21 changed; the build's overflow
check must still pass — if page 21 overflows, stop and ask the user what to shorten).

- [ ] **Step 8: Hand look**

Run: `site/build.sh && open site/dist/index.html` — unstyled apart from fonts/tokens, but in order:
hero, 24 sections, Set it up, footer; no appendix.

- [ ] **Step 9: Checkpoint**

- Split `docs/architecture.md` (now 2+ separately built parts) into `docs/architecture/`:
  `index.md` (overview, data flow incl. `project.json` → both outputs, which doc for what),
  `guide.md`, `site.md`, `installer.md` (from `~/.claude/templates/area.md`). Update the root
  `CLAUDE.md` docs table, project map (`site/`, `project.json`) and Commands
  (`site/build.sh`, `tests/test_site.sh`, build order `guide/build.sh && site/build.sh`).
- `CLAUDE.md` checkpoint items: "If `guide/src/`, `site/src/`, `project.json`, tests or docs
  changed: `guide/build.sh && site/build.sh`, then all three test files."
- Roadmap L3 ticked; spec Key files / Tests; decisions: `## 2026-11-25 — The website is built
  from guide.html by site/build.sh; site/dist is committed` (why: one source; Vercel's shallow
  clone would miscount page 21; alternatives: render in browser, Astro/Next).
- Rebuild both, run all three tests. Hand check above. Commit:
```
site/ tests/test_site.sh guide/assemble.sh guide/src/guide.html guide/think-prove-checkpoint.pdf docs/ CLAUDE.md

Build the website's structure from the guide's source

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```
(`site/dist/` is committed from L6 on, once it's complete; until then add `site/dist/` to
`.git/info/exclude` so it doesn't show as a change. Remove that line in L6.)

---

### Task L4: Screen layout and look

**Files:**
- Modify: `site/src/web.css` (full), `site/src/site.js` (test hook)
- Test: `tests/test_site.sh`

**Interfaces:**
- Consumes: classes and ids from L3; tokens from L2.
- Produces: `#check` hook on `<body>`: `data-overflow-x="none"` or the first too-wide elements;
  `data-copy-buttons="N"`. Classes `.in` (section revealed), `.menu-open` (on body), `aria-current="true"` on the current nav link, CSS var `--i` on flow children — all set by L5.

- [ ] **Step 1: Write the failing tests** — in `tests/test_site.sh`, before the summary:
```bash
echo "# one look, on any screen"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
# dom FILE W,H: the page's DOM after site.js's #check hook ran
dom() { "$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size="$2" --virtual-time-budget=5000 --dump-dom "file://$1#check" 2>/dev/null; }
fits() { dom "$1" "$2" | grep -q 'data-overflow-x="none"'; }
colour_literals() { grep -nE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?([^0-9a-zA-Z_-]|$)|rgba?\(|hsla?\(' "$@"; }
check "no colour values outside tokens.css" refuses colour_literals "$ROOT/site/src/web.css" "$ROOT/site/src/site.js" "$ROOT/site/src/index.html"
check "nothing scrolls sideways on a phone (375px)" fits "$html" 375,812
check "...or on a desktop (1280px)" fits "$html" 1280,800
fixture wide "01 · Wide" '<div style="width: 900px">wide</div>'
build wide "$TMP/wide.html"
check "the phone check catches a too-wide element" refuses fits "$TMP/wide/index.html" 375,812
```

- [ ] **Step 2: Run, watch them fail**

Run: `tests/test_site.sh` → the two `fits` checks FAIL (no hook yet, so no `data-overflow-x`);
"catches a too-wide element" passes for the wrong reason until the hook exists.

- [ ] **Step 3: Add the test hook to `site/src/site.js`**

```js
// Site behaviour (Task L5 adds reveal, navigation, progress, menu and copy buttons above this).
// #check mode, for tests/test_site.sh: reports on <body> whether anything scrolls sideways
// (data-overflow-x: "none", or the first too-wide elements) and how many Copy buttons exist.
if (location.hash === "#check") {
  document.fonts.ready.then(() => {
    const vw = document.documentElement.clientWidth;
    const wide = [...document.body.querySelectorAll("*")]
      .filter((e) => e.getBoundingClientRect().right > vw + 1)
      .slice(0, 5)
      .map((e) => e.tagName.toLowerCase() + (typeof e.className === "string" && e.className ? "." + e.className : ""));
    const scrolls = document.documentElement.scrollWidth > vw + 1;
    document.body.setAttribute("data-overflow-x", scrolls ? wide.join(" ") || "yes" : "none");
    document.body.setAttribute("data-copy-buttons", document.querySelectorAll(".copy-btn").length);
  });
}
```

- [ ] **Step 4: Run again** — "catches a too-wide element" now passes for the right reason (the
hook names the 900px div in `data-overflow-x`). The real-site `fits` checks may pass or fail
with the stub CSS; Step 6 is where they must pass.

- [ ] **Step 5: Write `site/src/web.css`**

```css
@import url("tokens.css");

/* The guide on screens. The content markup is the PDF's (guide/src/guide.html); this file only
   lays it out for the web. Colours and fonts come from tokens.css. */

* { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; scroll-padding-top: 72px; }
body {
  margin: 0; background: var(--paper); color: var(--ink); font-family: var(--sans);
  font-variant-ligatures: none; font-feature-settings: "liga" 0, "calt" 0;
}
main { max-width: 760px; margin: 0 auto; padding: 0 16px 48px; }
:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }

/* Type */
.label {
  font-family: var(--mono); font-weight: 500; font-size: .75rem; letter-spacing: .18em;
  text-transform: uppercase; color: var(--accent); margin: 0 0 .75rem;
}
h1 { font-size: clamp(2rem, 6vw, 2.75rem); line-height: 1.08; font-weight: 800; letter-spacing: -.025em; margin: 0 0 1.25rem; }
h1 .hl { font-family: var(--mono); font-weight: 800; color: var(--accent); letter-spacing: -.05em; }
h3 { font-size: 1.05rem; font-weight: 800; margin: 0 0 .4rem; color: var(--ink); }
.lead { font-size: 1.15rem; line-height: 1.55; color: var(--ink-2); margin: 0 0 2rem; }
p, li { font-size: 1rem; line-height: 1.65; color: var(--ink-2); }
strong { color: var(--ink); }
code {
  font-family: var(--mono); font-size: .86em; color: var(--accent); background: var(--accent-soft);
  padding: .1em .35em; border-radius: 4px; overflow-wrap: anywhere;
}
.link, .sec a:not(.btn) { color: var(--accent); font-weight: 600; text-decoration: none; border-bottom: 1px solid var(--accent); }
.note { font-size: .9rem; color: var(--muted); margin: 0 0 1.5rem; }
.credit { border-left: 2px solid var(--accent); padding: 0 0 0 1rem; margin: 0 0 1.75rem; font-size: .95rem; }
.ok { color: var(--ok); font-weight: 800; }

/* Sections */
.sec { padding: 72px 0 32px; border-top: 1px solid var(--line); }

/* Components: the PDF's shapes in screen units */
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; margin: 0 0 28px; }
.grid.three { grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
.card { background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px; }
.card p:not(.label) { margin: 0; font-size: .95rem; }
.card .label { margin-bottom: .5rem; }
.callout { border: 1.5px solid var(--accent); background: var(--accent-soft); border-radius: 14px; padding: 20px 24px; margin: 0 0 28px; }
.callout .label { margin-bottom: .5rem; }
.callout p:not(.label) { margin: 0; font-size: 1.15rem; font-weight: 600; line-height: 1.45; color: var(--ink); }
.callout p.sub { margin-top: .4rem; font-size: 1rem; font-weight: 400; color: var(--ink-2); }
.copy { position: relative; background: var(--code-bg); border-radius: 14px; padding: 20px 24px; margin: 0 0 28px; }
.copy .label { color: var(--code-muted); margin-bottom: .75rem; padding-right: 88px; }
.copy pre {
  margin: 0; font-family: var(--mono); font-weight: 500; font-size: .85rem; line-height: 1.65;
  color: var(--code-ink); white-space: pre-wrap; overflow-wrap: anywhere;
}
table.t { display: block; overflow-x: auto; margin: 0 0 28px; }
table.t > tbody { display: table; width: 100%; border-collapse: collapse; }
table.t th {
  font-family: var(--mono); font-weight: 500; font-size: .7rem; letter-spacing: .14em; text-transform: uppercase;
  color: var(--muted); text-align: left; padding: 0 12px 8px 0; border-bottom: 1px solid var(--line);
}
table.t td { font-size: .95rem; line-height: 1.5; color: var(--ink-2); padding: 10px 12px 10px 0; border-bottom: 1px solid var(--line); vertical-align: top; }
table.t td:first-child { font-weight: 600; color: var(--ink); }
.flow { display: flex; align-items: stretch; gap: 10px; margin: 0 0 28px; }
.flow .step { flex: 1; background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px; }
.flow .step.on { border: 1.5px solid var(--accent); }
.flow .step p:not(.label) { margin: 0; font-size: .9rem; }
.flow .step h3 { font-size: .95rem; margin: 0 0 .25rem; }
.flow .arrow { align-self: center; font-family: var(--mono); color: var(--muted); }
/* Six-step flows don't fit one row: a grid, read left to right. */
.flow.tight { display: grid; grid-template-columns: repeat(3, 1fr); }
.flow.tight .arrow { display: none; }
.flow.tight .step { padding: 12px; }
ol.steps { list-style: none; counter-reset: st; padding: 0; margin: 0 0 28px; }
ol.steps li { counter-increment: st; position: relative; padding: 0 0 .75rem 2.6rem; }
ol.steps li::before { content: counter(st, decimal-leading-zero); position: absolute; left: 0; font-family: var(--mono); font-weight: 800; color: var(--accent); }
@media (max-width: 639px) {
  .flow { flex-direction: column; }
  .flow .arrow { transform: rotate(90deg); }
  .flow.tight { grid-template-columns: 1fr 1fr; }
}

/* Hero: the PDF's cover */
.hero { min-height: 100vh; min-height: 100svh; display: flex; flex-direction: column; justify-content: center; padding: 96px 0 56px; }
.hero h1 { font-size: clamp(2.75rem, 10vw, 4.75rem); line-height: 1.02; margin-top: .5rem; }
.hero .lead { font-size: clamp(1.1rem, 2.4vw, 1.3rem); }
.byline { font-family: var(--mono); font-size: .85rem; letter-spacing: .08em; color: var(--ink); margin: 0 0 1.75rem; }
.hero .callout { order: 1; margin: 48px 0 0; }
.actions { display: flex; flex-wrap: wrap; gap: 12px; }
.setup .actions { margin: 0 0 1.5rem; }
.btn {
  display: inline-flex; align-items: center; min-height: 44px; padding: 0 20px; border-radius: 999px;
  border: 1px solid var(--line); background: var(--card); color: var(--ink); font-weight: 600; font-size: .95rem;
  text-decoration: none; transition: transform .2s ease, border-color .2s ease;
}
.btn:hover { border-color: var(--accent); transform: translateY(-1px); }
.btn.primary { background: var(--accent); border-color: var(--accent); color: var(--card); }
.btn.small { min-height: 38px; font-size: .85rem; align-self: flex-start; }

/* Copy buttons (added by site.js) */
.copy-btn {
  position: absolute; top: 14px; right: 14px; font: 500 .7rem var(--mono); letter-spacing: .12em; text-transform: uppercase;
  color: var(--code-ink); background: transparent; border: 1px solid var(--code-muted); border-radius: 999px; padding: 6px 12px; cursor: pointer;
}
.copy-btn:hover { border-color: var(--code-ink); }

/* Navigation: a side rail on desktop; on phones a top bar that opens the same list */
.progress { position: fixed; top: 0; left: 0; right: 0; height: 3px; z-index: 30; }
.progress span { display: block; height: 100%; background: var(--accent); transform-origin: 0 50%; transform: scaleX(0); }
.rail {
  position: fixed; top: 0; bottom: 0; left: 0; width: 260px; padding: 28px 16px; overflow-y: auto;
  display: flex; flex-direction: column; gap: 20px; background: var(--paper); border-right: 1px solid var(--line);
}
.rail-home { font-family: var(--mono); font-weight: 800; font-size: .75rem; letter-spacing: .1em; text-transform: uppercase; color: var(--ink); text-decoration: none; padding: 0 10px; }
.rail ol { list-style: none; margin: 0; padding: 0; }
.rail li a {
  display: flex; gap: 10px; padding: 6px 10px; border-radius: 8px; font-size: .88rem; line-height: 1.35;
  color: var(--ink-2); text-decoration: none; transition: background .2s ease, color .2s ease;
}
.rail .num { font-family: var(--mono); font-size: .75rem; color: var(--muted); min-width: 1.7em; padding-top: .1em; }
.rail li a:hover { background: var(--card); }
.rail li a[aria-current="true"] { background: var(--accent-soft); color: var(--accent); font-weight: 600; }
.rail li a[aria-current="true"] .num { color: var(--accent); }
.bar { display: none; }
@media (min-width: 1000px) {
  body { padding-left: 260px; }
  html { scroll-padding-top: 24px; }
}
@media (max-width: 999px) {
  .bar {
    display: flex; position: fixed; top: 0; left: 0; right: 0; z-index: 20; height: 56px; padding: 0 16px;
    align-items: center; justify-content: space-between; background: var(--paper); border: 0; border-bottom: 1px solid var(--line);
    font: 600 .95rem var(--sans); color: var(--ink); cursor: pointer;
  }
  .rail { top: 56px; right: 0; width: auto; z-index: 19; border-right: 0; opacity: 0; visibility: hidden; transform: translateY(-8px); transition: opacity .2s ease, transform .2s ease, visibility .2s; }
  .menu-open { overflow: hidden; }
  .menu-open .rail { opacity: 1; visibility: visible; transform: none; }
}

/* Footer */
.site-foot { border-top: 1px solid var(--line); padding: 28px 16px 48px; text-align: center; }
.site-foot p { margin: 0; font-family: var(--mono); font-size: .75rem; letter-spacing: .08em; color: var(--muted); }
.site-foot a { color: inherit; }

/* Motion: only when the script runs (.js) and the reader hasn't asked for less */
@media (prefers-reduced-motion: no-preference) {
  html { scroll-behavior: smooth; }
  .js .hero > * { animation: rise .8s cubic-bezier(.2, .7, .2, 1) both; }
  .js .hero > :nth-child(2) { animation-delay: .08s; }
  .js .hero > :nth-child(3) { animation-delay: .16s; }
  .js .hero > :nth-child(4) { animation-delay: .24s; }
  .js .hero > :nth-child(5) { animation-delay: .4s; }
  .js .hero > :nth-child(6) { animation-delay: .32s; }
  .js .sec { opacity: 0; transform: translateY(24px); transition: opacity .7s ease, transform .7s cubic-bezier(.2, .7, .2, 1); }
  .js .sec.in { opacity: 1; transform: none; }
  .js .sec .flow > * { opacity: 0; transform: translateY(12px); transition: opacity .5s ease, transform .5s ease; transition-delay: calc(var(--i, 0) * 80ms + 200ms); }
  .js .sec.in .flow > * { opacity: 1; transform: none; }
}
@keyframes rise { from { opacity: 0; transform: translateY(16px); } }
```

- [ ] **Step 6: Run the tests, see them pass**

Run: `site/build.sh && tests/test_site.sh` → `… passed, 0 failed`.
If a `fits` check fails, its `data-overflow-x` names the element: fix that rule, don't loosen the test.

- [ ] **Step 7: Checkpoint**

- Hand check (user): `open site/dist/index.html`; desktop and Chrome DevTools phone view
  (375px): the hero, cards, tables, step diagrams, the rail; sections stay hidden until L5 adds
  the script, so test with DevTools → "Disable JavaScript" for now, or wait for L5's hand check.
- Roadmap L4 ticked; spec Tests; architecture/site.md (layout, breakpoints 640 / 1000).
- Rebuild both, all three tests. Commit:
```
site/src/ tests/test_site.sh guide/think-prove-checkpoint.pdf docs/

Lay the guide out for screens, with the PDF's look

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

---

### Task L5: Behaviour — reveal, navigation, progress, menu, copy

**Files:**
- Modify: `site/src/site.js` (full)
- Test: `tests/test_site.sh`

**Interfaces:**
- Consumes: markup from L3, classes from L4, the `#check` hook from L4 (kept at the end).

- [ ] **Step 1: Write the failing test** — in `tests/test_site.sh`, before the summary:
```bash
echo "# behaviour"
copy_buttons() { dom "$html" 1280,800 | sed -n 's/.*data-copy-buttons="\([0-9]*\)".*/\1/p'; }
check "one Copy button per copy-paste block" test "$(copy_buttons)" -eq "$(grep -c 'class="copy"' "$html")"
check "...and there are some" test "$(grep -c 'class="copy"' "$html")" -gt 0
```

- [ ] **Step 2: Run, watch it fail** — `tests/test_site.sh`: "one Copy button…" FAILs (0 vs 14 or so).

- [ ] **Step 3: Write `site/src/site.js`** (the `#check` block from L4 stays at the end)

```js
// Site behaviour: sections reveal once, the current section is highlighted, a bar shows reading
// progress, the phone menu opens and closes, and every copy-paste block gets a Copy button.
// Without this script every section is simply visible (web.css hides only under .js).
(() => {
  const root = document.documentElement;
  const sections = [...document.querySelectorAll("main .sec")];
  const links = new Map([...document.querySelectorAll(".rail li a")].map((a) => [a.hash.slice(1), a]));
  const bar = document.querySelector(".bar");
  const barName = document.querySelector(".bar-name");

  // Copy buttons on every copy-paste block.
  for (const box of document.querySelectorAll(".copy")) {
    const pre = box.querySelector("pre");
    if (!pre) continue;
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "copy-btn";
    btn.textContent = "Copy";
    btn.addEventListener("click", async () => {
      try { await navigator.clipboard.writeText(pre.textContent); btn.textContent = "Copied"; }
      catch { btn.textContent = "Select to copy"; }
      setTimeout(() => { btn.textContent = "Copy"; }, 1600);
    });
    box.appendChild(btn);
  }

  // Step diagrams: each step's place in the order drives its delay (web.css, --i).
  for (const flow of document.querySelectorAll(".sec .flow")) {
    [...flow.children].forEach((el, i) => el.style.setProperty("--i", i));
  }

  // Sections rise in once, the first time they come into view.
  const reveal = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (e.isIntersecting) { e.target.classList.add("in"); reveal.unobserve(e.target); }
    }
  }, { rootMargin: "0px 0px -10% 0px" });
  sections.forEach((s) => reveal.observe(s));

  // The section crossing the middle of the screen is the current one.
  const hero = document.querySelector(".hero");
  const current = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (!e.isIntersecting) continue;
      for (const a of links.values()) a.removeAttribute("aria-current");
      const a = links.get(e.target.id);
      if (a) a.setAttribute("aria-current", "true");
      barName.textContent = a ? a.dataset.name : "Contents";
    }
  }, { rootMargin: "-45% 0px -50% 0px" });
  [hero, ...sections].forEach((s) => current.observe(s));

  // Reading progress.
  const fill = document.querySelector(".progress span");
  let queued = false;
  const progress = () => {
    const max = root.scrollHeight - innerHeight;
    fill.style.transform = `scaleX(${max > 0 ? Math.min(1, scrollY / max) : 0})`;
    queued = false;
  };
  addEventListener("scroll", () => { if (!queued) { queued = true; requestAnimationFrame(progress); } }, { passive: true });
  progress();

  // Phone menu: the bar opens the section list; choosing a section or Escape closes it.
  const setMenu = (open) => { document.body.classList.toggle("menu-open", open); bar.setAttribute("aria-expanded", String(open)); };
  bar.addEventListener("click", () => setMenu(!document.body.classList.contains("menu-open")));
  document.querySelector(".rail").addEventListener("click", (e) => { if (e.target.closest("a")) setMenu(false); });
  addEventListener("keydown", (e) => { if (e.key === "Escape") setMenu(false); });
})();
```
Then the L4 `#check` block, unchanged, below it. Remove L4's first comment line ("Task L5 adds…").

- [ ] **Step 4: Run the tests, see them pass** — `site/build.sh && tests/test_site.sh` → `… passed, 0 failed`.

- [ ] **Step 5: Checkpoint**

- Hand check (user), `open site/dist/index.html`:
  - Desktop: hero fades in; sections rise in once as you scroll; step diagrams reveal in order;
    the rail highlights the section you're reading; the top bar fills as you go; clicking a rail
    entry scrolls smoothly; Copy copies the prompt in 00 and 17.
  - Phone view (DevTools, 375px): the top bar shows the current section's name; tapping it
    opens the list; choosing one closes it and scrolls.
  - macOS System Settings → Accessibility → Display → Reduce motion: no animations, all visible.
  - DevTools → Disable JavaScript: everything visible, no menu needed on desktop.
- Roadmap L5 ticked; spec Behaviour/Tests as built. Rebuild both, all three tests. Commit:
```
site/src/site.js tests/test_site.sh guide/think-prove-checkpoint.pdf docs/

Website behaviour: reveal, navigation, progress, phone menu, copy buttons

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

---

### Task L6: Link preview, committed site, freshness

**Files:**
- Modify: `site/src/index.html` (head), `site/src/web.css` (og mode), `site/build.sh` (screenshot, note)
- Create: `site/dist/` (committed)
- Test: `tests/test_site.sh`

**Interfaces:**
- Consumes: `{{site}}` fact (L1); `og` class on `<html>` for `#og` (L3 template).
- Produces: `site/dist/og.png` (1200×630).

- [ ] **Step 1: Write the failing tests** — in `tests/test_site.sh`, before the summary:
```bash
echo "# link preview"
size_is() { [ "$(sips -g pixelWidth -g pixelHeight "$1" 2>/dev/null | awk '/pixel/ { printf "%s ", $2 }')" = "$2 $3 " ]; }
check "og.png is 1200×630" size_is "$TMP/dist/og.png" 1200 630
check "preview tags are present" grep -q '<meta property="og:image" content="' "$html"
check "...with a large card" grep -q 'name="twitter:card" content="summary_large_image"' "$html"

echo "# the committed site is up to date"
norm() { sed 's/data-fact="commits">[0-9]*</data-fact="commits">N</' "$1"; }
same_site() {
  diff -r -x index.html -x og.png -x think-prove-checkpoint.pdf "$ROOT/site/dist" "$TMP/dist" &&
    diff <(norm "$ROOT/site/dist/index.html") <(norm "$TMP/dist/index.html")
}
check "site/dist matches a fresh build (if not: guide/build.sh && site/build.sh)" same_site
check "site/dist ships the committed PDF" cmp -s "$ROOT/site/dist/think-prove-checkpoint.pdf" "$ROOT/guide/think-prove-checkpoint.pdf"
check "site/dist has its preview image" size_is "$ROOT/site/dist/og.png" 1200 630
```

- [ ] **Step 2: Run, watch them fail** — no `og.png`, no tags; `site/dist` is a hand-built folder
(or excluded) and doesn't match.

- [ ] **Step 3: Preview tags** — in `site/src/index.html`, after the description `<meta>`:
```html
<meta property="og:type" content="website">
<meta property="og:title" content="Think · Prove · Checkpoint">
<meta property="og:description" content="A practical guide to building software with AI agents: principles that stop the guessing, skills that demand proof, and project memory that lives in git.">
<meta property="og:url" content="{{site}}">
<meta property="og:image" content="{{site}}/og.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
```

- [ ] **Step 4: og mode in `site/src/web.css`** (append):
```css
/* #og: the hero alone, 1200×630, for the link preview (site/build.sh screenshots it) */
.og body { padding: 0; }
.og .rail, .og .bar, .og .progress, .og .sec, .og .site-foot, .og .hero .actions { display: none; }
.og main { max-width: none; padding: 0 80px; }
.og .hero { min-height: 0; height: 630px; padding: 48px 0; }
.og .hero h1 { font-size: 4.5rem; }
.og .hero .callout { margin-top: 28px; }
```

- [ ] **Step 5: Screenshot and note in `site/build.sh`** — before the final `echo`:
```bash
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
rm -f "$OUT/og.png"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1200,630 \
  --virtual-time-budget=3000 --screenshot="$OUT/og.png" "file://$OUT/index.html#og" 2>/dev/null
[ -s "$OUT/og.png" ] || { echo "og.png was not created" >&2; exit 1; }
grep -q '"site": ""' "$ROOT/project.json" &&
  echo "note: project.json has no \"site\" yet; the link preview needs it (Task L7)" >&2 || true
```

- [ ] **Step 6: Is og.png reproducible?** Run `S=$(mktemp -d); site/build.sh "$S/a" && site/build.sh "$S/b" && cmp "$S/a/og.png" "$S/b/og.png" && echo SAME`.
If SAME: remove `-x og.png` from `same_site` (stricter). If not: keep it, and add a Gotcha to the spec.

- [ ] **Step 7: Build the committed site** — remove `site/dist/` from `.git/info/exclude` (added in L3), then
`guide/build.sh && site/build.sh` → `sections: 24 · ok: …/site/dist/index.html` plus the "no site yet" note.

- [ ] **Step 8: Run all tests** — `tests/test_site.sh && tests/test_guide.sh && tests/test_scripts.sh` → all `0 failed`.

- [ ] **Step 9: Checkpoint**

- Hand check (user): `open site/dist/og.png` (title readable, nothing cut off); the whole site once more.
- Roadmap L6 ticked; spec Gotchas (og reproducibility result) / Tests; decisions:
  `## 2026-11-25 — Link preview: a screenshot of the hero, made at build time` (alternatives:
  a hand-made image that would drift from the cover).
- Rebuild both (docs changed the decision count), all three tests. Commit:
```
site/ tests/test_site.sh guide/think-prove-checkpoint.pdf docs/

Add the link preview and commit the built website

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

---

### Task L7: Deploy (user) and the site link

**Files:**
- Modify: `project.json` (`site`), `README.md` (site link)

- [ ] **Step 1: User deploys on Vercel** (Claude confirms before any outward step and never pushes):
  1. Vercel → Add New… → Project → import `shajiyev/think-prove-checkpoint`.
  2. Framework Preset: **Other**. Root Directory: **`site/dist`**. Build Command: override, leave
     **empty**. Output Directory: override, **`.`**. Install Command: override, leave **empty**.
  3. Deploy. Copy the production URL (e.g. `https://think-prove-checkpoint.vercel.app`).
  Every later push to `main` redeploys the committed `site/dist` as-is.

- [ ] **Step 2: Failing test first** — set `"site": "<the URL, no trailing slash>"` in `project.json`.
Run `tests/test_guide.sh` → "README links the site, once there is one" FAILs.

- [ ] **Step 3: README** — under the version line from L1, add:
```markdown
**Read it online:** <the URL>
```
Run `tests/test_guide.sh` → passes.

- [ ] **Step 4: Rebuild** — `guide/build.sh && site/build.sh` (no "no site yet" note now); all three tests pass.
Check: `grep 'og:image' site/dist/index.html` shows `<the URL>/og.png`.

- [ ] **Step 5: Checkpoint**

- User commits and pushes; Vercel redeploys. Hand check on a phone: open the link, read, use the
  menu, copy the prompt, download the PDF. Paste the link into LinkedIn's post composer (don't
  post) or linkedin.com/post-inspector: the preview shows the hero image.
- Roadmap: M5 done; Current status → next: the LinkedIn post (now with the link). Features:
  Website done. Spec Last updated. Decisions: `## <date> — Hosted on Vercel, serving the committed site/dist` (why; alternatives GitHub Pages).
- Rebuild both after the docs, all three tests. Commit:
```
project.json README.md site/dist guide/think-prove-checkpoint.pdf docs/

Website live: add its link to project.json and the README

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

---

## Execution notes (2026-11-25, L1–L6)
Run inline in one session, at the user's request; one combined hand check and commit at the end.
Where the build differed from this plan:
- **Width tests:** headless Chrome won't make a window narrower than 500px, so `dom()` in
  `tests/test_site.sh` loads the site in an iframe of the exact width and reads the hook's result
  (`--allow-file-access-from-files`). The hook also names elements whose content spills out.
- **Phone polish after screenshots:** code in tables keeps its natural breaks (`table.t code`),
  and copy blocks aligned in columns get `.cols` from `site.js` and scroll instead of wrapping.
- **`og.png` is reproducible,** so `same_site` compares it (L6 Step 6).
- **`.git/info/exclude` step skipped:** `site/dist/` was never committed half-built.
- **Docs updated once,** at the end, instead of per task (each update changes page 21 anyway).
