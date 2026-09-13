---
name: handoff
description: Use when a work session is ending and the next session must continue without today's conversation - preparing a handoff, verifying the next session will understand, checking whether notes and docs are enough, or auditing whether project state is written down accurately.
---

# Handoff

## Overview

**A handoff is not a document you write. It is a claim you test.**

The claim is: *someone who was not here can pick this up and be productive.*
That claim is only ever verified one way — by running someone who genuinely
wasn't here, and checking their answers against reality.

Everything else is you reading your own notes and recognising what you already
know. You cannot audit your own handoff. You know too much.

## The Iron Law

```
NO HANDOFF IS DONE UNTIL A ZERO-CONTEXT AGENT HAS BEEN RUN AGAINST IT
```

Not "I wrote thorough notes." Not "the docs look complete." Run the audit.

## Before you start: a handoff is not project work

A handoff closes a session; it is not a unit of work inside the project. Treat
it as one and two machines end up grading the same file by different rules.
Three rules follow from that, and all three are load-bearing.

**The board must be quiet before you start.** If the project tracks work in
columns — something like *in progress* and *awaiting review* — both must be
empty before a handoff begins. Work under review is work still changing, and
notes written over moving state describe a repo that no longer exists by the
time anyone reads them. If either column holds anything, stop: tell the human
what is still open and offer to close it out first. Do not start writing while
a review is running.

**The write-up never becomes a ticket.** Updating the board *is* the handoff —
correcting statuses, editing tickets, recording position. But the account of the
session is not itself project work, and filing it as a ticket hands it to the
wrong checker.

**The handoff's auditor and the board's reviewer never mix.** A handoff is
judged by `handoff-auditor` and by nothing else. That auditor reads the board,
because that is where state lives, but it reviews no tickets — and no ticket
reviewer passes judgement on the handoff.

This has been paid for once already. A handoff began with tickets still sitting
in review, and the `HANDOFF.md` it produced was itself filed as a ticket. The
loop: handoff edits the file → its auditor finds a flaw → the fix lands inside a
ticket under review → the board's reviewer re-checks against the file that just
changed → new findings → round again. Two checkers, one file, different rules,
each one's change making the other's verdict stale. Three review rounds for a
single documentation ticket, and hours gone.

## Is the next step real, or are you inventing one?

A handoff pointing somewhere nobody decided is worse than one admitting it does
not know. The next session reads direction as instruction, and spends its first
hour on work you never chose.

**Assume the direction is unclear.** It is clear only when all three hold:

1. **You can state the next step in one sentence without hedging.** "Implement
   option B for the importer" passes. "Continue working on the importer" and
   "address the open items" do not.
2. **You can cite the artefact it lives in** — a file, a branch, a spec, a named
   failing test. Something the next session can open.
3. **A human confirmed it**, by choosing it, approving the spec that contains
   it, or instructing it directly. Work documented in the plan this session was
   executing counts too. **Your own inference does not** — "they probably want X
   next" is exactly the bridge you are forbidden to author.

Miss any one and you brainstorm with the human before writing anything. One
question at a time, options where you can offer them, your recommendation
first.

Clarity fails more often than it feels like it does. Watch for: a session that
was exploratory with no decision recorded; several plausible next steps with no
choice made between them; stopping mid-edit or mid-debug with the breakage
uncharacterised; a long debug whose fix the human has not confirmed; work
blocked on something external; or simply your own unease about what comes next.

**The audit cannot catch this one.** An auditor reads what you wrote and tests
whether it is followable — it has no way of knowing the direction was never
chosen. This check is yours alone.

## Where the handoff lives

**If the project already has a place where state lives — a ticket board, an
issues file, a running log — that place IS the handoff.** Update it. Do not
create a parallel summary document beside it.

A separate `HANDOFF.md` fails in a specific way: the next session follows the
project's own entry point, never learns the file exists, and works from the
stale thing instead. A handoff nobody can find is worse than none, because it
makes you believe you handed off.

Test for this: *starting only from the project's documented entry point, is
every artefact I produced reachable?* If not, it does not exist.

**Update that entry point before writing anything else.** The README a newcomer
opens first, the board's own index, the sub-folder README covering the code you
touched: if this session's work changed what those describe, they are wrong
now. A handoff delivered alongside a stale entry point is a defective handoff,
however good the notes beside it are.

## Steps

1. **Check the board is quiet.** Nothing in progress, nothing awaiting review.
   If something is, that is a conversation with the human, not a handoff.

2. **Check the direction is real.** The three signals above. If any is missing,
   brainstorm with the human before writing a single line.

3. **Update the entry point,** and any sub-folder docs this session's work made
   wrong. This comes before the notes, not after.

4. **Spend your remaining time on what an auditor cannot do.** Do not
   hand-reconcile every number yourself — the auditor will measure them, and
   doing it first means running the same suite two or three times for one
   figure. Your time goes to what needs project knowledge: does every
   cross-reference still resolve, is anything recorded only in the conversation,
   which notes describe a decision that has since reversed.

5. **Fix what is stale or contradictory.** Especially: statements that read like
   instructions but describe a decision already reversed. Those cause the most
   expensive damage, because the next session obeys them.

6. **Audit with the zero-context `handoff-auditor` subagent.** See below.

7. **Fix the findings.**

8. **Re-run the audit, pointed at what you changed.** Same agent, same
   questions, but name the area you touched — otherwise the re-run may never
   look there and confirms nothing. An audit that stayed in the ticket folder
   cannot verify a fix you made in the docs folder. You have not verified a fix
   until an audit that would have caught it comes back clean.

## What is most easily lost

Git remembers what was committed. The conversation remembers everything else,
and the conversation is what disappears tonight. Wherever this project records
state, make sure these four are actually in it.

**Mid-flight state.** The most perishable thing there is: which file is
half-edited and how far it got, what is uncommitted and why, the last
hypothesis you were testing and what you had already ruled out. Nothing else
records this — `git status` shows changed files, not what you were in the
middle of doing to them. If you stopped at a clean point, say so explicitly;
silence reads the same as forgetting.

**Blockers, with the reason they block.** "Waiting on review" is a status.
"Waiting on review, and the migration cannot be written until the schema in
that PR settles" is a blocker. Separate what needs a human decision from what
waits on other work: the next session can act on the first and can only
schedule around the second.

**References, with when to read them.** Point at the spec, the plan, the
playbook — and say when each matters: at the start, or only under a specific
condition. Two rules. Never restate a reference's content where you point at
it; the copy and the original will disagree, and the reader has no way to tell
which is current. And never leave a pointer without its condition — one without
it gets read either always or never, and both are wrong.

**Position, not a copy.** Where a plan or board already holds the checklist,
that is the source of truth; record where the work stands in it. Copying the
checklist across gives you two lists, and the copy starts going stale
immediately. For the same reason, never edit an earlier record so it agrees
with today — supersede it instead. The trail of a reversed decision is what
stops the next session from quietly reversing it back.

## The audit

Dispatch the **`handoff-auditor`** subagent. Its definition —
`agents/handoff-auditor.md`, which ships beside this skill — already carries the
seven questions, the read-only rule, and the instruction to find the entry point
unaided, so the prompt you send is short:

> "Audit this repo for a handoff. Answer your seven questions."

**Send it nothing else.** Not the state, not what you were doing, not even which
file explains the conventions. Finding the entry point is part of what is being
tested.

That agent has no Write and no Edit tool, so "change nothing" is enforced rather
than requested — an auditor that fixes what it finds has destroyed the finding.
It keeps Bash, because running the project's own tests is what makes its first
three answers checkable against reality instead of an impression.

**The questions live in the agent file and nowhere else.** A second copy here
would drift from it, and the drift would be invisible — one list, one source.
Read that file when you need to know what is being asked. Question 7 — *do any
two places contradict each other* — finds the most, because decisions reverse
mid-session and the note recording the old decision is the one left behind.

On a re-run, name the area you changed in the prompt. That is the only project
context the agent accepts, and without it the re-run may never look there.

**Add a control when the stakes are high.** When the handoff lives in a
separate artefact, the control is an agent not pointed at that artefact.

When the handoff lives in the board — the usual case — there is nowhere to point
an agent that is not the artefact, so use a different control: give it a
**concrete first task** instead of the seven questions. "Plan your first step on
the open criterion of ticket X." An agent answering questions can sound oriented;
an agent planning actual work reveals whether the notes steer it away from the
expensive mistake. That is the strongest signal available.

**The control is not `handoff-auditor`.** Dispatch a plain `general-purpose`
agent for it. The control works only while the agent believes it is doing the
work rather than being tested on it; one that knows it is an auditor performs
like one.

## What actually goes wrong

Observed in baseline testing, in order of damage:

| Failure | Why it happens | Counter |
|---|---|---|
| **Inventing a reconciliation** for two things that disagree | A tidy explanation feels like resolution | Report the contradiction unresolved. Never author a bridge you did not verify — you are adding a *new* falsehood to fix an old one |
| **A next step nobody chose** | It rounds the handoff out and feels helpful | The three clarity signals. An invented direction is obeyed, not questioned |
| **Asserting technical claims from reasoning** | It sounds obviously right | Measure it, then write it. "Should work" is not a finding |
| **Handoff artefacts nobody can reach** | You know the path; the next session doesn't | Reachable from the documented entry point, or it does not exist |
| **Mid-flight state left in the conversation** | It feels too temporary to write down | It is the one thing no file records. Write it or lose it |
| **Numbers disagreeing across your own artefacts** | Written at different moments | One number, one source. Re-derive rather than recall |
| **Work recorded in the conversation, not the repo** | You told the human, so it feels recorded | The conversation is gone tomorrow. If it is not in a file, it did not happen |

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "The review is nearly done, I can start the handoff now" | Nearly done is still changing. You would be describing a repo that stops being true while you type. |
| "My notes are thorough" | Thorough to you. You have the context that makes them readable. |
| "I'll just re-read them myself" | You will recognise, not comprehend. Recognition proves nothing. |
| "The direction is obvious from what we did" | Obvious to you, and unverifiable by anyone else. If a human did not choose it, brainstorm. |
| "The audit takes too long" | It genuinely costs — a run and a re-run is minutes of waiting and six figures of subagent tokens, and you cannot work meanwhile because the auditor is reading the files you would touch. Spend it anyway when work is mid-flight: the alternative is the next session redoing what was already finished. Skip it for a short session with nothing open. |
| "I already told the human" | The conversation does not survive. Only files do. |
| "I fixed the findings, that's enough" | Unverified fixes. Re-run the audit. |
| "Nothing changed since last time" | Then the audit is cheap and confirms it. |

## When you are not allowed to fix a finding

Permission limits are not contradictions, and the rule against authoring
unverified bridges does not apply. Escalate it to the human plainly, in the
reply — not in a note inside the artefact.

A warning written into an uncommitted file is invisible to exactly the reader it
warns. So is one inside a document nobody has been told to open. If the finding
is that your own work is unreachable, saying so inside that work changes nothing.

## Red flags

- Starting a handoff while a ticket is still sitting in review
- Filing the handoff write-up itself as a ticket
- About to write `HANDOFF.md` next to a board that already tracks state
- Writing a next step no human actually chose
- Handing off with a README this session's own work made wrong
- Explaining away a contradiction instead of reporting it
- A reference pointed at with no indication of when to read it
- Copying a plan's checklist into the handoff instead of recording position
- Editing an earlier record so it agrees with today
- Writing a technical claim you have not run
- "The next session will figure it out from the code"
- Fixed the audit's findings, did not re-run it
- Reported a finding to the human and considered it recorded
- Re-ran the audit without pointing it at what you changed
- Hand-reconciled every number yourself, then had the auditor do it again

## When this is not needed

Short session, nothing in flight, board already accurate — update the notes and
stop. The audit is for when someone must continue work that is genuinely
mid-flight, or when you are about to hand a project to someone else.
