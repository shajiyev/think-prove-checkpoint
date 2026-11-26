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
hero_part() { sed -n '/<header class="hero"/,/<\/header>/p' "$1"; }
check "hero's buttons: Read the guide and GitHub" test "$(hero_part "$html" | grep -c 'class="btn')" -eq 2
check "hero leaves the PDF to the navigation" refuses grep -q 'think-prove-checkpoint.pdf' <(hero_part "$html")
check "hero links the repo" grep -qF "href=\"$(fact repo)\"" <(hero_part "$html")
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

echo "# one look, on any screen"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
# dom FILE W,H: what site.js's #check hook reported, read through an iframe of exactly W×H
# (headless Chrome won't make a window narrower than 500px, so a 375px window is really 500).
dom() {
  local w="${2%,*}" h="${2#*,}" frame="$TMP/frame.html"
  cat > "$frame" <<EOF
<!doctype html><html><body style="margin:0"><iframe id="f" src="file://$1#check" style="width:${w}px;height:${h}px;border:0"></iframe><script>
const f = document.getElementById("f");
const poll = setInterval(() => {
  const b = f.contentDocument && f.contentDocument.body;
  if (b && b.hasAttribute("data-overflow-x")) {
    for (const a of b.getAttributeNames()) if (a.startsWith("data-")) document.body.setAttribute(a, b.getAttribute(a));
    clearInterval(poll);
  }
}, 50);
</script></body></html>
EOF
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files \
    --window-size="$((w + 40)),$((h + 40))" --virtual-time-budget=5000 --dump-dom "file://$frame" 2>/dev/null
}
fits() {
  local v; v="$(dom "$1" "$2" | sed -n 's/.*<body[^>]*data-overflow-x="\([^"]*\)".*/\1/p')"
  [ "$v" = "none" ] || { echo "  too wide at $2: ${v:-no report}"; return 1; }
}
colour_literals() { grep -nE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?([^0-9a-zA-Z_-]|$)|rgba?\(|hsla?\(' "$@"; }
check "no colour values outside tokens.css" refuses colour_literals "$ROOT/site/src/web.css" "$ROOT/site/src/site.js" "$ROOT/site/src/index.html"
check "nothing scrolls sideways on a phone (375px)" fits "$html" 375,812
check "...or on a desktop (1280px)" fits "$html" 1280,800
fixture wide "01 · Wide" '<div style="width: 900px">wide</div>'
build wide "$TMP/wide.html"
check "the phone check catches a too-wide element" refuses fits "$TMP/wide/index.html" 375,812

echo "# behaviour"
copy_buttons() { dom "$html" 1280,800 | sed -n 's/.*<body[^>]*data-copy-buttons="\([0-9]*\)".*/\1/p'; }
check "one Copy button per copy-paste block" test "$(copy_buttons)" -eq "$(grep -c 'class="copy"' "$html")"
check "...and there are some" test "$(grep -c 'class="copy"' "$html")" -gt 0

echo "# getting the PDF, from anywhere"
# report FILE W,H KEY: the value site.js's #check hook reported as data-KEY
report() { dom "$1" "$2" | sed -n "s/.*<body[^>]*data-$3=\"\([^\"]*\)\".*/\1/p"; }
check "the hero's buttons sit on one line on a phone (375px)" test "$(report "$html" 375,812 hero-rows)" = 1
check "...and on a small phone (360px)" test "$(report "$html" 360,740 hero-rows)" = 1
check "external links and the PDF open in a new tab" test "$(report "$html" 1280,800 same-tab-links)" = 0
check "the phone bar has a PDF button" grep -q '<a class="bar-pdf" href="think-prove-checkpoint.pdf"' "$html"
rail_pdf_first() { awk '/<nav class="rail"/ { n = 1 } n && /think-prove-checkpoint\.pdf/ { print "pdf"; exit } n && /<ol>/ { print "list"; exit }' "$1" | grep -q pdf; }
check "the rail's PDF button comes before the section list" rail_pdf_first "$html"

echo "# link preview"
size_is() { [ "$(sips -g pixelWidth -g pixelHeight "$1" 2>/dev/null | awk '/pixel/ { printf "%s ", $2 }')" = "$2 $3 " ]; }
check "og.png is 1200×630" size_is "$TMP/dist/og.png" 1200 630
check "preview tags are present" grep -q '<meta property="og:image" content="' "$html"
check "...with a large card" grep -q 'name="twitter:card" content="summary_large_image"' "$html"

echo "# the committed site is up to date"
norm() { sed 's/data-fact="commits">[0-9]*</data-fact="commits">N</' "$1"; }
same_site() {
  diff -r -x index.html -x think-prove-checkpoint.pdf "$ROOT/site/dist" "$TMP/dist" &&
    diff <(norm "$ROOT/site/dist/index.html") <(norm "$TMP/dist/index.html")
}
check "site/dist matches a fresh build (if not: guide/build.sh && site/build.sh)" same_site
check "site/dist ships the committed PDF" cmp -s "$ROOT/site/dist/think-prove-checkpoint.pdf" "$ROOT/guide/think-prove-checkpoint.pdf"
check "site/dist has its preview image" size_is "$ROOT/site/dist/og.png" 1200 630

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
