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
