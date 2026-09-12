# handoff

End a work session so the next one can pick it up cold — with none of today's
conversation. Built as a
[Claude Code plugin](https://docs.claude.com/en/docs/claude-code/plugins).

**A handoff is not a document you write. It is a claim you test.**

## The problem it solves

At the end of a session you write up where things stand. Then you read your own
notes back, recognise everything in them, and conclude they are clear.

They are clear *to you*. You have the context that makes them readable — which
ticket the half-finished sentence refers to, which of two contradictory notes is
the current one, which file the next session is supposed to open first. Tomorrow
that context is gone, and the notes are all that is left.

You cannot audit your own handoff. You know too much. The claim — *someone who
was not here can pick this up and be productive* — is only ever verified one
way: by running someone who genuinely wasn't here, and checking their answers
against reality.

```
NO HANDOFF IS DONE UNTIL A ZERO-CONTEXT AGENT HAS BEEN RUN AGAINST IT
```

## How it works

The skill prepares the handoff and then tests it with `handoff-auditor`, a
subagent dropped into the repo knowing nothing about it — not the state of the
work, not what you were doing, not even which file explains the conventions.
Finding the entry point is part of what is being measured.

It answers seven questions. The first three have answers checkable against the
repo, which is what separates an audit from an impression:

1. What is being worked on right now?
2. What would you pick up next, and why that one?
3. What is blocked, and by what?
4. How long until you felt oriented, and which file helped most?
5. What did you have to guess at?
6. What did you look for and not find?
7. **Do any two places contradict each other?**

Question 7 finds the most. Decisions reverse mid-session, and the note recording
the old decision is the one that gets left behind — where it reads like an
instruction, and the next session obeys it.

The auditor is configured with no `Write` and no `Edit` tool. "Change nothing"
is enforced rather than requested, because an auditor that fixes what it finds
has destroyed the finding: the whole value of the run is that the state it saw
is the state the next session will see.

## Before the notes: is the direction real?

The skill runs a clarity check first, and assumes the direction is unclear
until three things hold: you can state the next step in one sentence without
hedging, you can cite the file or branch or spec it lives in, and **a human
chose it**. Your own inference does not count — "they probably want X next" is
precisely the invented bridge the rest of this refuses to author.

Fail any one and it brainstorms with you before writing a line. This is the one
check the auditor cannot perform for you: an auditor tests whether what you
wrote is followable, and has no way of knowing the direction was never chosen.

## What it makes sure is written down

Git remembers what was committed. The conversation remembers everything else,
and the conversation is what disappears tonight:

- **Mid-flight state** — which file is half-edited and how far it got, what is
  uncommitted and why, the last hypothesis you were testing and what you had
  ruled out. `git status` shows changed files, not what you were doing to them.
- **Blockers with the reason they block**, split between what needs a human
  decision and what waits on other work. The next session can act on the first
  and only schedule around the second.
- **References with when to read them** — at the start, or only under a named
  condition. Never restating the reference's content, because the copy and the
  original will disagree and the reader cannot tell which is current.
- **Position in a plan, never a copy of it.** Two checklists means one of them
  is already going stale.

And before any of that: the project's entry point gets updated first. A handoff
delivered next to a README this session's own work made wrong is a defective
handoff, however good the notes beside it are.

## Installation

Inside Claude Code:

```
/plugin marketplace add mirzaakhena/handoff
/plugin install handoff
```

That is the whole installation — no settings file to edit:

```
handoff/
├── skills/handoff/     when and how to hand off, and what goes wrong
└── agents/             handoff-auditor, the zero-context auditor
```

The plugin registers no hooks and applies in every project. It does nothing at
all until a session is actually ending, so installing it globally costs nothing.

Installing the skill alone — `git clone` into `~/.claude/skills/` — still gives
you the method, but loses the audit: the auditor agent is the piece that only a
plugin install can register, and the audit is the part that makes a handoff more
than a feeling.

## Usage

Ask in plain language at the end of a session — "prepare a handoff", "will the
next session understand this", "is any of this written down wrong" — and Claude
reaches for the skill.

It will update the project's own notes, run the auditor, fix what comes back,
and re-run the audit pointed at what it changed. An unverified fix is not a fix.

## Where the handoff lives

**If the project already has a place where state lives — a ticket board, an
issues file, a running log — that place IS the handoff.** Update it.

A separate `HANDOFF.md` fails in a specific way: the next session follows the
project's own entry point, never learns the file exists, and works from the
stale thing instead. A handoff nobody can find is worse than none, because it
makes you believe you handed off.

## Design principles

- **The audit is the product.** Notes are the cheap half. Running someone who
  wasn't here is the half that tells you anything.
- **Read-only is enforced, not requested.** A rule in a prompt is advice. A
  missing tool is a guarantee.
- **One list, one source.** The seven questions live in the agent file and
  nowhere else. A second copy would drift, and the drift would be invisible.
- **Report contradictions unresolved.** Never author a bridge you did not
  verify — that adds a new falsehood on top of an old one, and it looks settled.
- **Direction is chosen, not inferred.** A next step no human picked still
  reads as an instruction to whoever comes next, and gets obeyed rather than
  questioned.
- **The control must not know it is a control.** When the stakes are high, the
  strongest signal is a plain agent given real work to plan, not an auditor
  answering questions. An agent that knows it is a test performs like one.

## Deliberately absent

- **No `HANDOFF.md` template.** The artefact belongs where the project already
  keeps state.
- **No hooks.** A handoff begins when a person decides the session is over.
  There is no file event worth watching, and `SessionEnd` is too late to run
  anything.
- **No dependency on any ticket system.** It works against whatever the project
  already uses to record state, including nothing.

## Lineage

An earlier version of this repo was a `/handoff` + `/handoff-resume` pair that
wrote timestamped files into `.handoff/`. Its clarity check survives here
almost intact. A second, much more elaborate version — bot-to-bot relay with
ACK protocol and session self-reset — lives on in a private fleet setup; the
mid-flight/blocker/reference discipline above is lifted from it.

What did not survive from either: the numbered section template. Two skills
locked together by "Section 5" drift apart silently, and a form that is filled
in completely *feels* finished whether or not it is true. The content those
templates were reaching for is kept; the form is not.

## License

MIT
