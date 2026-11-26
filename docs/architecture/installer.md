# Installer

## Purpose
Let a reader install the workflow by hand and fully revert it. Spec: `docs/specs/installer.md`.

## Key dirs & files
- `framework/global-CLAUDE.md` → `~/.claude/CLAUDE.md`
- `framework/templates/` → `~/.claude/templates/`
- `scripts/install.sh` — backup, then copy; writes the `think-prove-checkpoint.install` note
- `scripts/uninstall.sh` — moves installed files aside, restores backups, removes the note

## Conventions
- Never overwrite without a timestamped backup; never delete (move aside instead).
- `framework/` is copied from the author's live files, with the documented reader-copy differences.

## Gotchas
- macOS ships bash 3.2: no associative arrays, `mapfile`, or `${var,,}`.

## Run & test
- Test: `tests/test_scripts.sh` (runs both scripts against a throwaway HOME)
