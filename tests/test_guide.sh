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
real_build() { "$ROOT/guide/build.sh" "$ROOT/guide/src/guide.html" "$TMP/real.pdf" > "$TMP/real.log" 2>&1; }

echo "# real guide"
check "guide builds and passes its self-check" real_build
check "all 9 framework files are in the appendix" logged real "appendix: 9 files"

echo "# page 21 counts are filled at build time"
gen="$ROOT/guide/src/guide.gen.html"
check "no {{placeholder}} left in the built guide" refuses grep -q '{{' "$gen"
check "commit count matches git" grep -q "<td data-fact=\"commits\">$(git -C "$ROOT" rev-list --count HEAD)</td>" "$gen"
check "decision count matches docs/decisions.md" grep -q "<td>$(grep -c '^## ' "$ROOT/docs/decisions.md")</td>" "$gen"
check "test counts match the test files" grep -q "<td>$(grep -cE '^[[:space:]]*check ' "$ROOT/tests/test_scripts.sh") checks</td>" "$gen"

echo "# a newcomer finds what they need"
page() { awk -v t="<span>$1</span>" '/<section class="page"/{p=0} index($0, t){p=1} p' "$gen"; }
check "17 has a What you need box" grep -qF 'What you need' <(page "17 · Hand it to your agent")
check "...with Anthropic's install command" grep -qF 'curl -fsSL https://claude.ai/install.sh | bash' <(page "17 · Hand it to your agent")
check "00's agent option points to it" grep -qF 'What you need: see 17' <(page "00 · Start here")

echo "# readers recognise the method"
check "the cover calls it spec-driven" grep -qF 'A small, spec-driven way' <(page "Solo dev · AI-assisted workflow")
check "01 names spec-driven development" grep -qF '<strong>spec-driven development</strong>' <(page "01 · The problem")
check "the README calls it spec-driven" grep -qF 'A small, spec-driven way' "$ROOT/README.md"

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
site_latest() { local s; s="$(fact site)"; [ -z "$s" ] || grep -qF "Latest version: <a class=\"link\" href=\"$s\">${s#https://}</a>" "$gen"; }
check "the end page's latest version is the site, once there is one" site_latest

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
sed 's/"site": "[^"]*"/"site": ""/' "$ROOT/project.json" > "$TMP/nosite.json"
printf '<p>{{latest}}</p>\n' > "$TMP/latest.html"
check "with no site yet, latest version is the repo" assemble_with "$TMP/nosite.json" latest
check "...filled in" grep -qF "<p>$(fact repo)</p>" "$TMP/latest.gen.html"

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

seq 1 6 | sed 's/^/a /' > "$TMP/first.md"
seq 1 8 | sed 's/^/b /' > "$TMP/short.md"
fixture short "$TMP/first.md" "$TMP/short.md"
check "a short file that doesn't fit moves to the next page" build_with 20 short
check "...whole, not split" grep -q "lines 1–8 of 8" "$TMP/short.gen.html"

echo "# the committed PDF is up to date"
# pdf_words PDF OUT: its text layer, with page 21's commit count masked (it changes with every commit).
# Bytes can't be compared: Chrome stamps a build date into every PDF.
pdf_words() { swift "$ROOT/tests/pdf_text.swift" "$1" 2>/dev/null | sed 's/^\(Commits, each one a checkpoint\) [0-9]*$/\1 N/' > "$2"; }
same_words() {
  pdf_words "$1" "$TMP/a.words"; pdf_words "$2" "$TMP/b.words"
  [ -s "$TMP/a.words" ] || { echo "  no text read from $1"; return 1; }
  diff "$TMP/a.words" "$TMP/b.words" > "$TMP/words.diff" || { head -6 "$TMP/words.diff" | sed 's/^/  /'; return 1; }
}
if command -v swift >/dev/null 2>&1; then
  check "the committed PDF reads the same as a fresh build (if not: guide/build.sh)" same_words "$ROOT/guide/think-prove-checkpoint.pdf" "$TMP/real.pdf"
  quietly() { "$@" > /dev/null; }
  check "...and the check can tell two PDFs apart" refuses quietly same_words "$TMP/real.pdf" "$TMP/long.pdf"
else
  echo "skip - committed PDF check needs swift + PDFKit (macOS)"
fi

echo "# the PDF text layer (what an agent reads)"
# Every line of SRC appears, trimmed, as a line of TXT.
all_lines_in() { local l; while IFS= read -r l; do grep -qxF -- "$l" <(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$2") || { echo "  not in PDF text: $l"; return 1; }; done < "$1"; }
if command -v swift >/dev/null 2>&1; then
  printf '%s\n' '|---|---|' '<!-- a comment -->' '## A heading' 'a -> b => c' 'x != y >= z <= w' 'www :: ... ===' > "$TMP/liga.md"
  fixture liga "$TMP/liga.md"
  build liga
  swift "$ROOT/tests/pdf_text.swift" "$TMP/liga.pdf" > "$TMP/liga.txt" 2>/dev/null
  check "markdown symbols reach the PDF text unchanged (no ligatures)" all_lines_in "$TMP/liga.md" "$TMP/liga.txt"
else
  echo "skip - PDF text layer check needs swift + PDFKit (macOS)"
fi

seq 1 420 | sed 's/^/line /' > "$TMP/many.md"
fixture many "$TMP/many.md"
check "a PDF with more than 8 pages is counted right" build_with 40 many
check "...12 pages" logged many "pdf pages: 12 · sections: 12"

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

echo "# one look: colours only in tokens.css"
colour_literals() { grep -nE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?([^0-9a-zA-Z_-]|$)|rgba?\(|hsla?\(' "$@"; }
check "tokens.css exists and holds the palette" grep -q -- '--accent:' "$ROOT/guide/src/tokens.css"
check "no colour values in styles.css or guide.html" refuses colour_literals "$ROOT/guide/src/styles.css" "$ROOT/guide/src/guide.html"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
