#!/usr/bin/env bash
# Tests for scripts/install.sh and scripts/uninstall.sh.
# Every case runs against a throwaway HOME, never the real one.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REAL_HOME="$HOME"
TMP_HOMES=""
PASS=0
FAIL=0

cleanup() { for d in $TMP_HOMES; do rm -rf "$d"; done; export HOME="$REAL_HOME"; }
trap cleanup EXIT

fresh_home() {
  HOME="$(mktemp -d)"; export HOME
  TMP_HOMES="$TMP_HOMES $HOME"
}

check() {
  local desc="$1"; shift
  if "$@"; then PASS=$((PASS + 1)); echo "ok   - $desc"
  else FAIL=$((FAIL + 1)); echo "FAIL - $desc"; fi
}

refuses()       { ! "$@"; }
run_install()   { bash "$REPO_DIR/scripts/install.sh"   >/dev/null 2>&1; }
run_uninstall() { bash "$REPO_DIR/scripts/uninstall.sh" >/dev/null 2>&1; }
has_glob()      { compgen -G "$1" >/dev/null; }
# A fingerprint of everything under $HOME: paths + checksums.
snapshot()      { (cd "$HOME" && find . -print | sort && find . -type f -exec cksum {} \; | sort); }
count_files()   { ls "$1" | wc -l | tr -d ' '; }

echo "# payload"
check "framework/global-CLAUDE.md exists" test -s "$REPO_DIR/framework/global-CLAUDE.md"
check "framework has 8 templates" test "$(count_files "$REPO_DIR/framework/templates")" = 8

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
