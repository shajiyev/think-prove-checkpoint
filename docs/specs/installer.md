# Installer (framework payload + install / uninstall scripts + README)

## Goal
Let a reader install the workflow in a few minutes and fully revert it, without ever
losing a file they had before.

## Behavior
**`framework/`** contains `global-CLAUDE.md` and `templates/` (8 files), copied from the
author's live `~/.claude/CLAUDE.md` and `~/.claude/templates/`, except that the reader copy of
`global-CLAUDE.md` marks the agent's pronouns "(the agent)".

**`scripts/install.sh`**
1. Refuses to run if the workflow is already installed (marker file present).
2. Backs up an existing `~/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md.backup-<timestamp>`
   and an existing `~/.claude/templates/` → `~/.claude/templates.backup-<timestamp>`.
3. Copies `framework/global-CLAUDE.md` → `~/.claude/CLAUDE.md` and `framework/templates/`
   → `~/.claude/templates/` (creates `~/.claude/` if missing).
4. Writes the marker `~/.claude/think-prove-checkpoint.install` (timestamp + backup paths).
5. Prints the plugin install commands (shell `claude plugin …` and in-app `/plugin …`);
   it does not run them, so plugin changes stay the reader's explicit choice.

**`scripts/uninstall.sh`**
1. Refuses to run if the marker is missing; changes nothing.
2. **Never deletes:** moves the installed `CLAUDE.md` and `templates/` aside to
   `*.removed-<timestamp>`, so edits made after installing are kept.
3. Restores the backups recorded in the marker, if any.
4. Removes the marker; prints the commands to remove the plugin and marketplace (shell + in-app).
5. Never touches project folders (their `CLAUDE.md` / `docs/` are plain files).

**`README.md`** mirrors the guide: what it is + PDF link; two ways to use it (read it, or hand it
to your agent with the PDF's own prompt) + the compatibility warning; what the agent does; make it
yours (the 6 questions, extend, undo prompt); never stop researching; for technical readers (one
paragraph: `framework/`, the scripts, the build, tests, then an optional "Prefer to install it by
hand?" subsection with the script steps, revert and what gets installed); credits; license
linked to `LICENSE`. The agent path stays the recommended one.

## Out of scope
- Installing or removing plugins from the script (`/plugin` commands are run by the user inside Claude Code).
- Windows support (macOS + Linux bash only; noted in the README).
- Flags/options (no `--dry-run`, `--force`); add only if a real need appears.

## Design
- Bash with `set -euo pipefail`; paths come from `$HOME`, so tests can point it at a temp folder.
- Scripts find `framework/` relative to their own location, so they work from any directory.
- One timestamp format everywhere: `YYYYMMDD-HHMMSS`.

## Key files
<!-- Kept current at every checkpoint: describes the feature AS BUILT. -->
- `framework/global-CLAUDE.md`, `framework/templates/` (8 files) — copied from the author's live `~/.claude/`
- `scripts/install.sh` — refuse if marker exists → move existing files to `*.backup-<ts>` → copy `framework/` → write marker → print plugin commands
- `scripts/uninstall.sh` — refuse without marker → move installed files to `*.removed-<ts>` → restore backups from the marker → remove marker → print plugin commands
- `README.md` — mirrors the guide (agent path only, same prompts and questions as the PDF); manual
  script install kept as an optional subsection for technical readers; credits with the author's LinkedIn; license link
- `LICENSE` — MIT
- `tests/test_scripts.sh` — harness (`fresh_home`, `check`, `refuses`, `snapshot`, `has_glob`) + payload, install and uninstall checks (24 total, all 5 spec cases)

## Gotchas
- A second install would back up *our* file over the reader's original; hence the refusal (step 1).
- `cp -R` behaves differently on macOS vs Linux with trailing slashes; copy via explicit paths.
- macOS ships bash 3.2: no associative arrays, `mapfile`, or `${var,,}`.

## Tests
`tests/test_scripts.sh`, each case in a fresh `HOME=$(mktemp -d)`:
1. Fresh home (no `~/.claude/`): install creates the files; uninstall leaves no active
   `CLAUDE.md`/`templates/` (only `*.removed-*`).
2. Existing `CLAUDE.md` + `templates/`: install backs up; uninstall restores them byte-for-byte.
3. Second install while installed: refused, nothing changed.
4. Uninstall without install: refused, nothing changed.
5. File edited after install: uninstall keeps the edit in the `*.removed-*` copy.

## Last updated
2026-11-24 — initial spec from the agreed design.
2026-11-24 — corrected during planning: plugin shell CLI exists; bash 3.2; build self-check replaces PNG previews.
2026-11-24 — README rewritten to lead with the agent path (G8); scripts kept for technical readers.
