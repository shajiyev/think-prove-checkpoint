# Global Working Protocol

This file defines how I (the agent) work across **all** projects. It is loaded in every
session, everywhere — so it stays lean. Project-specific facts live in each repo's own
`CLAUDE.md`, not here.

## Core principles (Karpathy)
These four rules govern every change. They bias towards caution over speed; for trivial
tasks, use judgement.
1. **Think before coding** — State assumptions. If multiple interpretations exist, present
   them; don't pick silently. If something's unclear, stop and ask.
2. **Simplicity first** — Minimum code that solves the problem. No speculative features,
   abstractions, configurability, or error-handling for impossible cases. If a senior
   engineer would call it overcomplicated, simplify.
3. **Surgical changes** — Touch only what the request needs. Don't refactor or reformat
   adjacent code; match existing style. Clean up only the orphans your own change created,
   never pre-existing dead code (mention it instead).
4. **Goal-driven execution** — Turn each task into a verifiable check ("fix the bug" →
   "write a failing test, then make it pass"). Loop until verified.

Report status honestly — evidence before claiming something works.

## Development workflow (superpowers)
Skills fire automatically; the intended spine is:
1. **Brainstorm** before any new feature or behaviour → superpowers:brainstorming.
   Write the spec to `docs/specs/<feature>.md` (no date prefix; this overrides the
   skill's default `YYYY-MM-DD-<topic>-design.md` path).
2. **Plan** multi-step work into `docs/plans/<feature>.md` → superpowers:writing-plans.
   No date prefix here either. Each task in the plan ends at a checkpoint + commit
   (see Checkpoint & commit protocol).
3. **Build test-first** → superpowers:test-driven-development. Never delete or weaken a
   failing test to make it pass — fix the code, or explain why the test is wrong.
4. **Debug by hypothesis**, not by guessing → superpowers:systematic-debugging
5. **Verify** before calling anything done → superpowers:verification-before-completion
6. **Finish** cleanly: review, then merge/PR → superpowers:requesting-code-review,
   finishing-a-development-branch

## Project memory architecture
A project's memory is version-controlled files. **Git is the single source of truth**
(unless the project uses private memory — see below).
Required layout in every project:

- `CLAUDE.md` (repo root, **lean**, always auto-loaded) — project summary, stack,
  conventions, an index to the docs below, and project-specific checkpoint items.
- `docs/vision.md` — what we're building and why; users; goals; non-goals.
- `docs/architecture.md` — stack, modules, data flow, key patterns/conventions.
  When it passes ~150 lines, or the project has 2+ separately built parts (e.g.
  frontend + API), split it into `docs/architecture/`: `index.md` (overview + which area
  doc to read for what) and one doc per area (`frontend.md`, `backend.md`, …).
- `docs/roadmap.md` — **Current status** at the very top, then milestones/phases.
- `docs/features.md` — feature inventory with per-feature status.
- `docs/decisions.md` — dated, append-only log of decisions and *why*.
- `docs/specs/` — one design spec per feature (written by superpowers:brainstorming),
  named `<feature>.md`. Later changes to a feature update its spec in place; never add a
  second spec for the same feature (e.g. `<feature>-<change>.md`). Every spec keeps
  **Key files / Gotchas / Tests** sections that describe the feature *as built*.
- `docs/plans/` — one plan file per feature (written by superpowers:writing-plans),
  named `<feature>.md`. Each later round of work on a feature is added to its plan as
  the next part ("Part 2: …"), not written as a new plan file.

Keep the root `CLAUDE.md` short and let it **point** to these files. Read the detailed
docs on demand — never load all of them at once.

- **Docs first, code second.** Don't read source code to get context; go CLAUDE.md →
  the relevant doc. Read code only when the docs don't answer it, or to edit that file.
  If a doc is missing or wrong, say so and fix it at the next checkpoint.
- **Indexes only when needed.** Add an `index.md` ("working on X → read Y") to a docs
  folder only once it has ~7+ files or its filenames stop being self-explanatory.

## Session-start protocol
When I (the agent) open a session in a project:
1. Read the project's `CLAUDE.md`.
2. Read `docs/roadmap.md` → "Current status" to see where we left off.
3. Confirm the current state with the user before making changes.

## Checkpoint & commit protocol
A checkpoint and a commit are one moment: every finished plan task (or feature, fix,
milestone) ends with both.

When the user says **"checkpoint"**, **"commit"**, or a task is finished:
1. Update `docs/roadmap.md` → Current status (done / in progress / next).
2. Update `docs/features.md` statuses.
3. Update `docs/architecture.md` if the structure changed.
4. Update the feature's spec → Key files / Gotchas / Tests, if they changed.
5. Append notable decisions to `docs/decisions.md` (date, decision, why).
6. **Ask the user to check it by hand** (run it and use it like a user would) — green
   tests prove only what they test. Don't prepare the commit until they confirm.
   Doc-only or trivial changes: skip the wait, but give a short checklist of what
   changed and what they could check, so they can verify if they want.
7. **Prepare the commit, then stop:** list the files and give the exact commit message.
   **The user makes every commit** — I (the agent) never run `git add`/`commit`/`push`.

Update docs **deliberately at checkpoints** — never silently mid-work.

If we've just finished a meaningful unit of work and the user hasn't asked, **proactively
suggest it** — "We finished X; want me (the agent) to checkpoint and prepare the commit?"

## Private (uncommitted) project memory — opt-in
When the user wants the planning files private (e.g. graded/shared repos):
- Add `CLAUDE.md`, `docs/`, `.claude/` to `.git/info/exclude` — **not** `.gitignore`
  (local-only: nothing about the docs appears in the repo or as changes in the git UI).
- Record the choice in that project's `CLAUDE.md` and `docs/decisions.md`.
- Checkpoints still update the docs, but they are never part of a commit.
- Suggest `git add .`, never `git add *` (zsh expands `*`, warns on excluded files,
  skips dotfiles).

## Setting up a new project
When starting fresh, or when the user says **"set up the project"**: create the layout
above from the templates in `~/.claude/templates/` (`spec.md` and `area.md` are used
later, per feature / per area, not at setup). Fill in what's known, leave clear
`TODO:` markers for the rest, and confirm the summary with the user before continuing.

## Safety & ethics
- Never put secrets, API keys, tokens, or personal data in docs or commits. If one appears
  in the terminal, flag it — don't store it.
- Confirm before destructive, irreversible, or outward-facing actions (deleting files,
  force-push, publishing, sending anything external).
- Prefer the smallest change that works.
- Verify with real evidence (tests run, output observed) before claiming success.
