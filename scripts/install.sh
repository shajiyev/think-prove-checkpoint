#!/usr/bin/env bash
# Install the Think · Prove · Checkpoint workflow into ~/.claude.
# Existing files are moved aside to *.backup-<timestamp>, never overwritten.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
MARKER="$CLAUDE_DIR/think-prove-checkpoint.install"
TS="$(date +%Y%m%d-%H%M%S)"

if [ -e "$MARKER" ]; then
  echo "Already installed (found $MARKER). Run scripts/uninstall.sh first." >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR"
claude_md_backup=""
templates_backup=""

if [ -e "$CLAUDE_DIR/CLAUDE.md" ]; then
  claude_md_backup="$CLAUDE_DIR/CLAUDE.md.backup-$TS"
  mv "$CLAUDE_DIR/CLAUDE.md" "$claude_md_backup"
fi
if [ -e "$CLAUDE_DIR/templates" ]; then
  templates_backup="$CLAUDE_DIR/templates.backup-$TS"
  mv "$CLAUDE_DIR/templates" "$templates_backup"
fi

cp "$REPO_DIR/framework/global-CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
mkdir "$CLAUDE_DIR/templates"
cp "$REPO_DIR"/framework/templates/*.md "$CLAUDE_DIR/templates/"

{
  echo "installed_at=$TS"
  echo "claude_md_backup=$claude_md_backup"
  echo "templates_backup=$templates_backup"
} > "$MARKER"

echo "Installed Think · Prove · Checkpoint into $CLAUDE_DIR"
echo "  backups: ${claude_md_backup:-none} ${templates_backup:-}"
echo
echo "Next: install the superpowers plugin. In your shell:"
echo "  claude plugin marketplace add obra/superpowers-marketplace"
echo "  claude plugin install superpowers@superpowers-marketplace"
echo "Or inside Claude Code:"
echo "  /plugin marketplace add obra/superpowers-marketplace"
echo "  /plugin install superpowers@superpowers-marketplace"
