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
# Big PDFs split the page tree into nodes, each with its own /Count; the root's is the largest.
pdf_pages="$(LC_ALL=C grep -ao '/Count [0-9]*' "$OUT" | cut -d' ' -f2 | sort -n | tail -1)"

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
