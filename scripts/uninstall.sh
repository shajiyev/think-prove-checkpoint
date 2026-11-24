#!/usr/bin/env bash
# Revert Think · Prove · Checkpoint: move installed files aside to *.removed-<timestamp>
# and restore the backups made by install.sh. Nothing is deleted except the marker.
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
MARKER="$CLAUDE_DIR/think-prove-checkpoint.install"
TS="$(date +%Y%m%d-%H%M%S)"

if [ ! -e "$MARKER" ]; then
  echo "Not installed (no $MARKER). Nothing changed." >&2
  exit 1
fi

read_marker() { sed -n "s/^$1=//p" "$MARKER"; }
claude_md_backup="$(read_marker claude_md_backup)"
templates_backup="$(read_marker templates_backup)"

[ -e "$CLAUDE_DIR/CLAUDE.md" ] && mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.removed-$TS"
[ -e "$CLAUDE_DIR/templates" ] && mv "$CLAUDE_DIR/templates" "$CLAUDE_DIR/templates.removed-$TS"

restore() {
  local backup="$1" target="$2"
  [ -z "$backup" ] && return 0
  if [ -e "$backup" ]; then mv "$backup" "$target"
  else echo "Warning: backup $backup not found; $target not restored." >&2; fi
}
restore "$claude_md_backup" "$CLAUDE_DIR/CLAUDE.md"
restore "$templates_backup" "$CLAUDE_DIR/templates"

rm "$MARKER"

echo "Reverted. Installed files were kept as *.removed-$TS in $CLAUDE_DIR (delete them when you like)."
echo
echo "To remove the plugin too. In your shell:"
echo "  claude plugin uninstall superpowers@superpowers-marketplace"
echo "  claude plugin marketplace remove superpowers-marketplace"
echo "Or inside Claude Code:"
echo "  /plugin uninstall superpowers@superpowers-marketplace"
echo "  /plugin marketplace remove superpowers-marketplace"
echo
echo "Your projects' CLAUDE.md and docs/ are plain files: keep them or delete them."
