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

echo "# page 21 counts are filled at build time"
gen="$ROOT/guide/src/guide.gen.html"
check "no {{placeholder}} left in the built guide" refuses grep -q '{{' "$gen"
check "commit count matches git" grep -q "<td>$(git -C "$ROOT" rev-list --count HEAD)</td>" "$gen"
check "decision count matches docs/decisions.md" grep -q "<td>$(grep -c '^## ' "$ROOT/docs/decisions.md")</td>" "$gen"
check "test counts match the test files" grep -q "<td>$(grep -cE '^[[:space:]]*check ' "$ROOT/tests/test_scripts.sh") checks</td>" "$gen"

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

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
