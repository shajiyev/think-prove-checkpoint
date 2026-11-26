#!/usr/bin/env bash
# Expand appendix markers into page sections holding files verbatim (HTML-escaped).
# Usage: assemble.sh <src.html> <out.html>
# Marker, on its own line: <!-- appendix A2: framework/global-CLAUDE.md framework/templates/spec.md -->
# Paths are relative to the repo root, or absolute. APPENDIX_LINES = line budget per page.
# Also fills the page 21 counts: {{commits}} {{decisions}} {{script_checks}} {{guide_checks}}
# {{site_checks}},
# and the facts from project.json (or $FACTS): {{version}} {{released}} {{repo}} {{repo_display}}
# {{linkedin}} {{site}}. Fails on a missing fact (exit 2) or an unfilled {{placeholder}} (exit 3).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

checks() { grep -cE '^[[:space:]]*check ' "$1"; }
COMMITS="$(git -C "$ROOT" rev-list --count HEAD)"
DECISIONS="$(grep -c '^## ' "$ROOT/docs/decisions.md")"
SCRIPT_CHECKS="$(checks "$ROOT/tests/test_scripts.sh")"
GUIDE_CHECKS="$(checks "$ROOT/tests/test_guide.sh")"
SITE_CHECKS="$(checks "$ROOT/tests/test_site.sh")"
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

awk -v root="$ROOT" -v budget="${APPENDIX_LINES:-60}" \
    -v commits="$COMMITS" -v decisions="$DECISIONS" \
    -v script_checks="$SCRIPT_CHECKS" -v guide_checks="$GUIDE_CHECKS" -v site_checks="$SITE_CHECKS" \
    -v version="$VERSION" -v released="$RELEASED" -v repo="$REPO" \
    -v repo_display="$REPO_DISPLAY" -v linkedin="$LINKEDIN" -v site="$SITE" '
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
    # Split only files longer than a page; a shorter one that will not fit moves to the next page.
    if (i == 1 && used > 0 && n <= budget - HEAD && budget - used - HEAD < n) { close_page(); open_page() }
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
{
  gsub(/\{\{commits\}\}/, commits); gsub(/\{\{decisions\}\}/, decisions)
  gsub(/\{\{script_checks\}\}/, script_checks); gsub(/\{\{guide_checks\}\}/, guide_checks)
  gsub(/\{\{site_checks\}\}/, site_checks)
  gsub(/\{\{version\}\}/, version); gsub(/\{\{released\}\}/, released)
  gsub(/\{\{repo_display\}\}/, repo_display); gsub(/\{\{repo\}\}/, repo)
  gsub(/\{\{linkedin\}\}/, linkedin); gsub(/\{\{site\}\}/, site)
  print
}
' "$1" > "$2"
left="$(grep -o '{{[a-z_]*}}' "$2" | sort -u | tr '\n' ' ' || true)"
[ -z "$left" ] || { echo "unfilled placeholder(s): $left" >&2; exit 3; }
