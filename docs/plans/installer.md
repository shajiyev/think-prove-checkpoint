# Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `framework/` (the installable files), `scripts/install.sh` / `scripts/uninstall.sh`, their tests, and the README, so a reader can install the workflow and fully revert it without losing any file.

**Architecture:** Two small bash scripts operate only on `$HOME/.claude/`. Install moves existing files aside to `*.backup-<ts>`, copies `framework/` in, and records the backups in a marker file. Uninstall moves installed files aside to `*.removed-<ts>` and restores the backups from the marker. Nothing is ever deleted except the marker. Tests run every case against a throwaway `HOME=$(mktemp -d)`.

**Tech Stack:** bash 3.2+ (macOS default) and Linux bash; coreutils only.

**Spec:** `docs/specs/installer.md`

## Global Constraints

- Scripts: `set -euo pipefail`; all paths derived from `$HOME`; repo paths derived from the script's own location.
- bash 3.2 compatible: no associative arrays, `mapfile`, `${var,,}`, `&>>`.
- Timestamp format everywhere: `date +%Y%m%d-%H%M%S`.
- Never overwrite without a backup; never delete user files (move aside instead).
- Scripts print plugin commands; they never run `claude plugin …` themselves.
- Marker file: `$HOME/.claude/think-prove-checkpoint.install`, `key=value` lines: `installed_at`, `claude_md_backup`, `templates_backup` (empty value = nothing was backed up).
- No personal data in committed files beyond the author credit.
- Every commit message ends with a blank line and `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **The user makes every commit.** Each task ends with a checkpoint: update docs, give the user the exact commands, stop.

## File map

| File | Responsibility |
|---|---|
| `framework/global-CLAUDE.md` | Copy of the author's live `~/.claude/CLAUDE.md` |
| `framework/templates/*.md` | Copies of the 8 live templates |
| `scripts/install.sh` | Backup → copy → marker → print plugin commands |
| `scripts/uninstall.sh` | Move installed aside → restore backups → remove marker → print plugin commands |
| `tests/test_scripts.sh` | The 5 spec cases + payload checks, each in a fresh temp HOME |
| `README.md` | What, setup (4 steps), revert (3 steps), credits, license |
| `LICENSE` | MIT |

---

### Task 1: Framework payload + test harness

**Files:**
- Create: `framework/global-CLAUDE.md`, `framework/templates/{CLAUDE,vision,architecture,roadmap,features,decisions,spec,area}.md`
- Create: `tests/test_scripts.sh`

**Interfaces:**
- Produces: `tests/test_scripts.sh` helpers used by Tasks 2–3: `fresh_home`, `check <desc> <cmd...>`, `refuses <cmd...>`, `run_install`, `run_uninstall`, `snapshot`, `has_glob <pattern>`.

- [ ] **Step 1: Write the test harness with payload checks**

`tests/test_scripts.sh`:
```bash
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
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/test_scripts.sh`
Expected: both payload checks `FAIL`, last line `0 passed, 2 failed`, exit code 1.

- [ ] **Step 3: Copy the payload from the live files**

```bash
mkdir -p framework/templates
cp ~/.claude/CLAUDE.md framework/global-CLAUDE.md
cp ~/.claude/templates/*.md framework/templates/
grep -nE '@|/Users/' framework/global-CLAUDE.md framework/templates/*.md || echo "no personal data found"
```
Expected: `no personal data found` (no emails, no absolute user paths).

- [ ] **Step 4: Run tests to verify they pass**

Run: `bash tests/test_scripts.sh`
Expected: `2 passed, 0 failed`, exit 0.

- [ ] **Step 5: Checkpoint (user commits)**

Docs: `docs/features.md` → "Framework payload" = done. `docs/roadmap.md` Current status. Doc-only/trivial → no hand check; give the checklist ("open `framework/global-CLAUDE.md`: is it your current global file?").
```bash
git add framework/ tests/test_scripts.sh docs/features.md docs/roadmap.md
git commit -m "Add framework payload and script test harness"
```

---

### Task 2: install.sh

**Files:**
- Create: `scripts/install.sh`
- Modify: `tests/test_scripts.sh` (add cases before the final summary lines)

**Interfaces:**
- Consumes: harness helpers from Task 1.
- Produces: marker file format (Global Constraints) read by `uninstall.sh` in Task 3.

- [ ] **Step 1: Write the failing install tests**

Insert into `tests/test_scripts.sh` above the `echo` / summary lines:
```bash
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bash tests/test_scripts.sh`
Expected: payload checks `ok`; install checks `FAIL` (script missing); exit 1.

- [ ] **Step 3: Write `scripts/install.sh`**

```bash
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
```
Then: `chmod +x scripts/install.sh`

- [ ] **Step 4: Run tests to verify they pass**

Run: `bash tests/test_scripts.sh`
Expected: all checks `ok`, `0 failed`, exit 0.

- [ ] **Step 5: Checkpoint (user commits)**

Docs: `docs/features.md` "Install script" = done; spec `docs/specs/installer.md` → Key files (`scripts/install.sh`, `tests/test_scripts.sh`); roadmap. Hand check (behavior changed): ask the user to run `HOME=$(mktemp -d) bash scripts/install.sh` and read the output.
```bash
git add scripts/install.sh tests/test_scripts.sh docs/
git commit -m "Add install.sh with backups and marker; tests for fresh, existing and repeat installs"
```

---

### Task 3: uninstall.sh

**Files:**
- Create: `scripts/uninstall.sh`
- Modify: `tests/test_scripts.sh` (add cases before the summary lines)

**Interfaces:**
- Consumes: marker format from Task 2; harness helpers from Task 1.

- [ ] **Step 1: Write the failing uninstall tests**

Insert above the summary lines:
```bash
echo "# uninstall: fresh home round trip"
fresh_home
run_install
check "uninstall succeeds" run_uninstall
check "no active CLAUDE.md left" test ! -e "$HOME/.claude/CLAUDE.md"
check "no active templates left" test ! -e "$HOME/.claude/templates"
check "installed CLAUDE.md kept aside" has_glob "$HOME/.claude/CLAUDE.md.removed-*"
check "marker removed" test ! -e "$HOME/.claude/think-prove-checkpoint.install"

echo "# uninstall: restores originals byte-for-byte"
fresh_home
mkdir -p "$HOME/.claude/templates"
echo "my own rules" > "$HOME/.claude/CLAUDE.md"
echo "my template"  > "$HOME/.claude/templates/mine.md"
orig="$(mktemp -d)"; TMP_HOMES="$TMP_HOMES $orig"
cp -R "$HOME/.claude/." "$orig/"
run_install
check "uninstall succeeds" run_uninstall
check "CLAUDE.md restored exactly" cmp -s "$orig/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
check "templates restored exactly" diff -r "$orig/templates" "$HOME/.claude/templates"

echo "# uninstall: refuses when not installed"
fresh_home
mkdir -p "$HOME/.claude"
echo "untouched" > "$HOME/.claude/CLAUDE.md"
before="$(snapshot)"
check "uninstall without install is refused" refuses run_uninstall
check "nothing changed" test "$before" = "$(snapshot)"

echo "# uninstall: keeps edits made after install"
fresh_home
run_install
echo "my edit" >> "$HOME/.claude/CLAUDE.md"
run_uninstall
check "edited file kept in *.removed-*" grep -qx "my edit" "$(compgen -G "$HOME/.claude/CLAUDE.md.removed-*")"
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bash tests/test_scripts.sh`
Expected: uninstall checks `FAIL` (script missing); exit 1.

- [ ] **Step 3: Write `scripts/uninstall.sh`**

```bash
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
```
Note: `[ -e … ] && mv …` returns non-zero when the file is absent, which `set -e` ignores for `&&` lists except as the last command; both lines are followed by more commands, so this is safe.

Then: `chmod +x scripts/uninstall.sh`

- [ ] **Step 4: Run tests to verify they pass**

Run: `bash tests/test_scripts.sh`
Expected: all checks `ok`, `0 failed`, exit 0.

- [ ] **Step 5: Checkpoint (user commits)**

Docs: features "Uninstall script" = done; spec Key files; roadmap. Hand check: user runs install then uninstall against `HOME=$(mktemp -d)` and reads the output.
```bash
git add scripts/uninstall.sh tests/test_scripts.sh docs/
git commit -m "Add uninstall.sh that restores backups and never deletes user files"
```

---

### Task 4: README + LICENSE

**Files:**
- Create: `README.md`, `LICENSE`

- [ ] **Step 1: Verify every command the README will show**

```bash
claude plugin marketplace --help | grep -E 'add|remove'
claude plugin --help | grep -E 'install|uninstall'
bash tests/test_scripts.sh | tail -1
```
Expected: `add`, `remove|rm`, `install|i`, `uninstall|remove` listed; `… 0 failed`.

- [ ] **Step 2: Write `README.md`**

```markdown
# Think · Prove · Checkpoint

**Claude forgets. Git doesn't.** A Claude Code workflow built on three layers:
principles (Karpathy), process ([superpowers](https://github.com/obra/superpowers) skills)
and memory (plain docs in git). Read the guide: [`guide/think-prove-checkpoint.pdf`](guide/think-prove-checkpoint.pdf).

> This repo is built with the workflow it describes: see `CLAUDE.md` and `docs/`.

## Setup (≈15 minutes, macOS / Linux)
1. **Clone:** `git clone <this repo> && cd think-prove-checkpoint`
2. **Install the files:** `bash scripts/install.sh`
   Your existing `~/.claude/CLAUDE.md` and `~/.claude/templates/` are moved to `*.backup-<timestamp>` first.
3. **Install the plugin** (shell, or the same commands with `/plugin` inside Claude Code):
   `claude plugin marketplace add obra/superpowers-marketplace`
   `claude plugin install superpowers@superpowers-marketplace`
4. **Start a project:** open Claude Code in a repo and say **"set up the project"**.

## Revert
1. `bash scripts/uninstall.sh` (installed files are moved to `*.removed-<timestamp>`, your backups restored)
2. `claude plugin uninstall superpowers@superpowers-marketplace`
   `claude plugin marketplace remove superpowers-marketplace`
3. Projects' `CLAUDE.md` and `docs/` are plain files: keep or delete them.

## What gets installed
| From | To |
|---|---|
| `framework/global-CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `framework/templates/` (8 files) | `~/.claude/templates/` |

## Tests
`bash tests/test_scripts.sh` runs every install/uninstall case against a throwaway HOME.

## Credits
- The four core principles: Andrej Karpathy's observations on LLM coding pitfalls, as packaged in [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills).
- The development skills: [superpowers](https://github.com/obra/superpowers) by Jesse Vincent.
- Author: Sabir Hajiyev, IT student, ADA University.

## License
MIT — see `LICENSE`.
```
(`<this repo>` is replaced with the real URL in the guide plan's final task, once the user has created the GitHub repo.)

- [ ] **Step 3: Write `LICENSE`**

Standard MIT text, first line `MIT License`, copyright line `Copyright (c) 2026 Sabir Hajiyev`.

- [ ] **Step 4: Verify**

Run: `grep -o '`[^`]*`' README.md | sort -u` and confirm each path it names exists (`ls framework/global-CLAUDE.md scripts/install.sh scripts/uninstall.sh tests/test_scripts.sh`).
Expected: all `ls` targets exist (the PDF path is created by the guide plan).

- [ ] **Step 5: Checkpoint (user commits)**

Docs: features "README" = done; roadmap M2 complete; decisions only if something changed. Doc-only → checklist instead of hand check.
```bash
git add README.md LICENSE docs/
git commit -m "Add README with setup and revert steps, and MIT license"
```
