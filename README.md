# Think · Prove · Checkpoint

**Claude forgets. Git doesn't.** A small, structured way of building with AI agents: principles that
stop the guessing, skills that demand proof, and project memory that lives in git, where you can
read it, review it and roll it back.

### **[Download the practical guide (PDF)](guide/think-prove-checkpoint.pdf)**

## Two ways to use it
- **Read it.** The guide explains what goes wrong without structure, the three layers that fix
  it, and how a feature moves from idea to commit.
- **Hand it to your agent.** Give the PDF to Claude Code, Codex or any agent that reads PDFs and
  edits files, and paste the prompt below. No steps to follow.

> I'm giving you a PDF called "Think · Prove · Checkpoint". Set its workflow up for me by
> following its appendix, "For your agent". First analyse my current setup and tell me what
> would overlap or conflict with it, and what you recommend. Then ask me the questions one at
> a time, show me every change before you make it, and back up anything you replace.

**Before you install:** it may not fit your current setup. From my own experience, other memory
tools, workflow frameworks or global rules can clash with it. That's why the prompt asks your
agent to check your setup first and tell you what conflicts, before it changes anything.

## What your agent does
1. Reads the PDF.
2. Checks your setup for conflicts, and recommends what to do about each one.
3. Asks you six questions, one at a time.
4. Shows every change before making it.
5. Backs up what it replaces, then writes, and leaves a note so any later session can undo it.
6. Hands over to you: open a project and say **"set up the project"**.

It never commits for you.

## Make it yours
The agent starts from the guide's files and changes only what your answers require:

| It asks | Default |
|---|---|
| Which agent are you using? | Decides where the files go |
| Existing global instructions? | Merge them (or replace) |
| Who makes the commits? | You (or the agent, after you approve) |
| Project memory? | Committed to git (or private) |
| superpowers? | Install it, if your agent supports it (or rules only) |
| Anything to drop or rename? | Nothing |

**Extend it:** this is a base, not a fence. Ask your agent to find skills that fit how you work
and explain what each would add. It reads them first and installs nothing without you.

**Undo it:**
> Undo the Think · Prove · Checkpoint setup: find the think-prove-checkpoint.install note,
> restore my backups, and tell me exactly what you changed.

## Never stop researching
This workflow is a starting point, not a finished product. Keeping it current is your
responsibility: keep researching skills, plugins, tools and new ways of working with your agent;
add what helps, remove what doesn't. Research → try → keep or cut, then start again.
Places to start: `/plugin` → Discover in Claude Code,
[anthropics/skills](https://github.com/anthropics/skills), [agentskills.io](https://agentskills.io).

## For technical readers
This repo has the same files as the guide's appendix (`framework/`), plus
`scripts/install.sh` and `scripts/uninstall.sh` for Claude Code (they back up first, and are
tested against a throwaway home folder), and the build that generated the PDF (`guide/`).
It is also built with the workflow it describes: see [`CLAUDE.md`](CLAUDE.md) and
[`docs/`](docs/) for its roadmap, decisions, specs and plans.

- `guide/build.sh` builds the PDF and fails on any page overflow, page-count mismatch, or
  appendix file that doesn't match its source byte for byte.
- `tests/test_guide.sh` and `tests/test_scripts.sh` run the build and installer tests.

### Prefer to install it by hand? (Claude Code, macOS / Linux)
> **Recommended: use the agent approach instead.** Hand the PDF to your agent (see
> [Two ways to use it](#two-ways-to-use-it)). It checks your setup for conflicts first and
> tailors the files to how you work. The manual steps below install the files exactly as they
> are, for Claude Code only, with no conflict check and no tailoring (they do back up your
> existing files first).

If you'd still rather do it yourself:

1. **Clone:** `git clone https://github.com/shajiyev/think-prove-checkpoint.git && cd think-prove-checkpoint`
2. **Install the files:** `bash scripts/install.sh`
   Your existing `~/.claude/CLAUDE.md` and `~/.claude/templates/` are moved to `*.backup-<timestamp>` first.
3. **Install the plugin** (in your shell, or the same commands with `/plugin` inside Claude Code):
   `claude plugin marketplace add obra/superpowers-marketplace`
   `claude plugin install superpowers@superpowers-marketplace`
4. **Start a project:** open Claude Code in a repo and say **"set up the project"**.

**Revert:**
1. `bash scripts/uninstall.sh` (installed files are moved to `*.removed-<timestamp>`, your backups restored)
2. `claude plugin uninstall superpowers@superpowers-marketplace`
   `claude plugin marketplace remove superpowers-marketplace`
3. Projects' `CLAUDE.md` and `docs/` are plain files: keep or delete them.

| From | To |
|---|---|
| `framework/global-CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `framework/templates/` (8 files) | `~/.claude/templates/` |

## Credits
- The four core principles: Andrej Karpathy's observations on LLM coding pitfalls, as packaged
  in [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills).
- The development skills: [superpowers](https://github.com/obra/superpowers) by Jesse Vincent.
- Author: Sabir Hajiyev. More about me on [LinkedIn](https://www.linkedin.com/in/sabir-hajiyev-9948a9364/).

## License
[MIT](LICENSE)
