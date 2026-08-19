---
name: runbook
description: >
  Write or update a runbook: a recipe for one concrete incident, organised by
  symptom rather than by system, stored under docs/runbooks/. Use when the user
  asks for a runbook, an incident procedure or an on-call guide. Triggers on
  "lag en runbook", "skriv en runbook", "hva gjør vi når X er nede",
  "driftsprosedyre", "write a runbook", "incident procedure", "on-call guide".
  Also propose one after an incident has been diagnosed and fixed in the
  session, since that is when the knowledge is complete and about to be lost.
---

# Runbook

A runbook is written for one reader: someone stressed at 23:00 on a Saturday who
does not remember how the system fits together.

Everything in this skill follows from that reader.
They cannot absorb background.
They need the fastest safe action, in order, with commands they can paste.

The goal is that a person who did not build the system can fix production
without waking the two people who did.

## Organised by symptom, never by system

The filename is the symptom, in the words the on-caller would actually search for.

Good:

```
docs/runbooks/site-is-down.md
docs/runbooks/signup-hangs.md
docs/runbooks/deploy-went-wrong-how-to-roll-back.md
```

Wrong:

```
docs/runbooks/how-argocd-works.md
```

That last one is documentation, not a runbook.
A reader in an incident does not know which component failed.
They know what they see.
If you cannot name the file after an observable symptom, you are writing a
concept module, and it belongs in the regular docs tree instead.

Write the filename in the language the team speaks, since the reader will search
in that language.

## Template

````markdown
# <Symptom, in the on-caller's words>

- Last verified: YYYY-MM-DD by <role>
- Affects: <who notices this, and how badly>

## Is this the right runbook?

<Two or three concrete signals that confirm this is the situation.>
<At least one discriminator against the nearest similar symptom, with a link
to that runbook.>

## First checks

Read-only. Safe to run.

```bash
<command>
```

<What each result means, in one line.>

## Most likely cause: <cause>

> **Warning:** <consequence of the command below, if it changes state.>

```bash
<command>
```

Verification: <the concrete signal that says it worked. Not "it should work now".>

## If that did not help

1. <Next branch: what to check, what it means, what to do.>
2. <Next branch.>

## Escalate

If this is not resolved after <time box>, escalate to <role>.
Rota: <link>

Bring: <what the next person needs so they do not start over.>

## After the incident

Update this runbook with what you learned. See the rules in the runbook skill.
````

## Rules

**Fastest safe fix first.**
This inverts normal documentation order.
No prose above the first command.
Background, history and architecture go at the bottom or, better, in a linked
concept document.

**Every command is copy-pasteable.**
No command that requires the reader to think up a value at 23:00.
If a value is unavoidable, show a concrete placeholder and explain it on the
line below.

**Mark what is safe and what is not.**
State plainly that the first checks are read-only.
Every command that changes state gets a warning above it, phrased as a command,
with the consequence first.
A stressed reader scrolls fast and will run the next code block they see.

**Every fix ends in a verification.**
"Restart the service" is not a fix.
"Restart the service, then confirm the health endpoint returns 200" is.
Without a stop condition the reader keeps applying fixes to a system that is
already healthy.

**Escalate to roles, not names.**
People change teams and the runbook does not.
Name the role and link to the on-call rota.
Include a time box, because the failure mode is a new person trying things alone
for two hours out of a reluctance to wake someone.

**No architecture explanation.**
If the reader needs to understand the system to follow the runbook, the runbook
is wrong.
Link to the concept document instead.

## Keeping it alive

This is the difference from an ADR.
An ADR is written once and never edited, because it records a decision at a point
in time.
A runbook is a living document, and its value decays fast.

Update it every time it is used:

- A command that no longer works gets fixed immediately, during the incident.
- A cause not covered gets added as a new branch under "If that did not help".
- A cause that turns out to be the common one moves up to "Most likely cause".
- Set `Last verified` to today whenever someone actually runs through it.

A runbook older than its `Last verified` date by a year should be treated as
untrusted.
Say so to the reader rather than deleting it.

## When a runbook is not the answer

If the same runbook is used repeatedly for the same cause, the runbook is a
workaround for a bug.
Say so, and link to the issue.
A runbook that runs monthly is a task that should be automated.

## Index

Once `docs/runbooks/` holds more than about five files, add
`docs/runbooks/README.md` with one row per runbook: symptom, who it affects,
last verified.
Sort by how often it is used, not alphabetically.
The reader is scanning for their symptom under pressure.

## Language

Follow the language rules in the `technical-documentation` skill, with the
procedural limits: maximum 20 words per sentence, one instruction per step,
active imperative, present tense.
Cut every instance of `simply` and `just`.
A reader who is stuck at 23:00 does not need to be told the fix is easy.
