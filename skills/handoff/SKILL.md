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

## Steps

1. **Spend your time on what an auditor cannot do.** Do not hand-reconcile
   every number yourself — the auditor will measure them, and doing it first
   means running the same suite two or three times for one figure. Your time
   goes to what needs project knowledge: does every cross-reference still
   resolve, is anything recorded only in the conversation, which notes describe
   a decision that has since reversed.

2. **Fix what is stale or contradictory.** Especially: statements that read
   like instructions but describe a decision already reversed. Those cause the
   most expensive damage, because the next session obeys them.

3. **Audit with the zero-context `handoff-auditor` subagent.** See below.

4. **Fix the findings.**

5. **Re-run the audit, pointed at what you changed.** Same agent, same
   questions, but name the area you touched — otherwise the re-run may never look there
   and confirms nothing. An audit that stayed in the ticket folder cannot
   verify a fix you made in the docs folder. You have not verified a fix until
   an audit that would have caught it comes back clean.

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
| **Asserting technical claims from reasoning** | It sounds obviously right | Measure it, then write it. "Should work" is not a finding |
| **Handoff artefacts nobody can reach** | You know the path; the next session doesn't | Reachable from the documented entry point, or it does not exist |
| **Numbers disagreeing across your own artefacts** | Written at different moments | One number, one source. Re-derive rather than recall |
| **Work recorded in the conversation, not the repo** | You told the human, so it feels recorded | The conversation is gone tomorrow. If it is not in a file, it did not happen |

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "My notes are thorough" | Thorough to you. You have the context that makes them readable. |
| "I'll just re-read them myself" | You will recognise, not comprehend. Recognition proves nothing. |
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

- About to write `HANDOFF.md` next to a board that already tracks state
- Explaining away a contradiction instead of reporting it
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
