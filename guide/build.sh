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
