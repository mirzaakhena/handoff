# handoff

A pair of Claude Code slash commands that make session-to-session handoff smooth.

- **`/handoff [optional notes]`** — at the end of a session, generates a markdown file in `<repo>/.handoff/` capturing what was done, choices made, references, anti-patterns to remember, and what to do next. If next-step direction is ambiguous, the AI brainstorms with you before writing.
- **`/handoff-resume`** — at the start of a new session, picks up the latest handoff file from `<repo>/.handoff/`, summarises it, and asks you to confirm before continuing.

## Install

```bash
cd ~/Workspace/handoff
./install.sh
```

The installer creates symlinks from `~/.claude/commands/` and `~/.claude/skills/` into this project. Editing files in this repo takes effect on the next Claude Code session — no re-install needed.

## Uninstall

```bash
./uninstall.sh
```

## Filename format

```
<repo-root>/.handoff/<yyyymmddhhmm>-prompt-<title>.md
```

`<title>` is kebab-case, ≤6 words, AI-inferred from the session.

## Should `.handoff/` be git-tracked?

It depends.

- **Track it** if you want a project-level audit trail of cross-session decisions.
- **Ignore it** (`echo .handoff/ >> .gitignore`) if these are personal notes between you and Claude.

The `/handoff` command does NOT touch your `.gitignore`. That choice is yours.

## See also

- Design spec: [docs/superpowers/specs/2026-04-27-handoff-design.md](docs/superpowers/specs/2026-04-27-handoff-design.md)
- Implementation plan: [docs/superpowers/plans/2026-04-27-handoff-implementation.md](docs/superpowers/plans/2026-04-27-handoff-implementation.md)
