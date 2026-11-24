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

echo "# install: fresh home"
fresh_home
check "install succeeds with no ~/.claude" run_install
check "CLAUDE.md is the framework file" cmp -s "$REPO_DIR/framework/global-CLAUDE.md" "$HOME/.claude/CLAUDE.md"
check "8 templates installed" test "$(count_files "$HOME/.claude/templates")" = 8
check "marker written" test -f "$HOME/.claude/think-prove-checkpoint.install"
check "marker records no CLAUDE.md backup" grep -qx 'claude_md_backup=' "$HOME/.claude/think-prove-checkpoint.install"

echo "# install: existing files are backed up"
fresh_home
mkdir -p "$HOME/.claude/templates"
echo "my own rules" > "$HOME/.claude/CLAUDE.md"
echo "my template"  > "$HOME/.claude/templates/mine.md"
check "install succeeds over existing files" run_install
check "old CLAUDE.md backed up" grep -qx "my own rules" "$(compgen -G "$HOME/.claude/CLAUDE.md.backup-*")"
check "old templates backed up" test -f "$(compgen -G "$HOME/.claude/templates.backup-*")/mine.md"
check "marker records the CLAUDE.md backup" grep -q '^claude_md_backup=.*CLAUDE.md.backup-' "$HOME/.claude/think-prove-checkpoint.install"

echo "# install: refuses a second install"
before="$(snapshot)"
check "second install is refused" refuses run_install
check "nothing changed" test "$before" = "$(snapshot)"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
