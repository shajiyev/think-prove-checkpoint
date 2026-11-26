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

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
rm -f "$OUT/og.png"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1200,630 \
  --virtual-time-budget=3000 --screenshot="$OUT/og.png" "file://$OUT/index.html#og" >/dev/null 2>&1
[ -s "$OUT/og.png" ] || { echo "og.png was not created" >&2; exit 1; }
if grep -q '"site": ""' "$ROOT/project.json"; then
  echo "note: project.json has no \"site\" yet; the link preview needs it (Task L7)" >&2
fi

echo "sections: $(grep -c '^<section class="sec" id=' "$OUT/index.html") · ok: $OUT/index.html"
