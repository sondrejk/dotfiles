---
name: adr
description: >
  Write an Architecture Decision Record: a short, immutable markdown file per
  significant technical decision, checked into the repo under docs/adr/. Use
  when the user asks to record or document a decision, or asks why something was
  chosen. Triggers on "skriv en ADR", "dokumenter denne beslutningen", "hvorfor
  valgte vi", "write an ADR", "record this decision", "document why we chose".
  Also propose an ADR when the user makes a decision that clears the bar in this
  skill, but never write one without asking first.
---

# Architecture Decision Record

Code always shows *what*. It never shows *why*.
An ADR exists so the reasoning survives after the people who made the decision
have left the project.

Each ADR is one short markdown file, roughly 10 to 25 lines, numbered and
checked into the repo at `docs/adr/NNNN-short-title.md`.

## Always ask before writing

**Never create an ADR file without explicit approval from the user.**
This applies whether you noticed the decision yourself or the user asked for one.

Present three things and wait:

1. The proposed number and filename
2. The one-line decision
3. The alternatives you understood were rejected, and why

The user may not agree that a decision was made, may want a different framing, or
may have context you do not have.
Writing first and asking later produces an ADR that is wrong and immutable, which
is worse than no ADR.

If you notice a qualifying decision mid-task, raise it once, in one sentence,
after the task is done.
Do not interrupt the work, and do not ask again in the same session if the user
declines.

## The bar

Write an ADR only when **both** are true:

1. **The decision is expensive to reverse.**
   Undoing it would take more than a few days, or it involves data migration, an
   external contract, or a public interface others depend on.
2. **Someone will ask why later.**
   The choice is not obvious, or a reasonable alternative was rejected.

A shorter version of the same test: *would you have to defend this in a design
review?*

**Qualifies:** choosing an orchestrator or a database, an authentication model,
a deployment topology, a data format other systems consume, dropping support for
a platform, splitting or merging a service.

**Does not qualify:** library choices that can be swapped in an afternoon,
formatting and lint configuration, naming conventions, directory layout, anything
reversible in a day.

The bar is high on purpose.
A repo with four good ADRs is useful.
A repo with forty is a repo nobody reads.

## Template

```markdown
# NNNN. <Decision, as a short statement>

- Status: Accepted
- Date: YYYY-MM-DD
- Deciders: <names>

## Context

<What problem forced a decision. What constraints applied at the time.
Two to four sentences. Write it so someone with no history can follow.>

## Decision

<What was chosen. One or two sentences, in the active voice.>

## Trade-offs

<What this choice optimizes for, and what it gives up to get it. Name the
sacrifice plainly: what would have been better under the rejected options,
that we now do not have. One or two sentences.>

## Alternatives

- **<Option>:** <why it was rejected>
- **<Option>:** <why it was rejected>

## Consequences

<What this locks us into, including the drawbacks. What becomes harder.
What we accept as the cost.>
```

## Rules that make ADRs work

**An accepted ADR is immutable.**
Never edit the Context, Decision, Trade-offs, Alternatives or Consequences of
an accepted ADR, even when it turns out to be wrong.
The only permitted edit is the status line.
This is the opposite of normal documentation, where staleness is a defect.
Here the record is the point.

**The Trade-offs section names the sacrifice.**
Every decision optimizes for something at the cost of something else. State
plainly what is being given up, in the moment of choosing, so the trade is
visible instead of assumed. This differs from Consequences, which covers what
the choice locks in going forward, over time.

**The Alternatives section is the whole value.**
Most ADRs fail because they record only what was chosen.
The rejected options with reasons are what future readers need, because someone
will propose the rejected option again.
Refuse to write an ADR with no real alternative considered.
If nothing was genuinely weighed, no decision was made, and no ADR is needed.

**Consequences must include the drawbacks.**
An ADR listing only benefits is marketing, not a record.
State what the choice locks the project into and what becomes harder.

**Numbers are sequential and never reused.**
Check the highest existing number in `docs/adr/` and add one.
Zero-pad to four digits.
A number is a permanent address, so it survives even when the ADR is superseded.

**Write it at decision time.**
The context evaporates within weeks.
An ADR written three months later records what people remember, not what was true.

## Superseding

When a decision changes, write a new ADR and update the old one's status line only:

```
- Status: Superseded by ADR-0007
```

The new ADR states in its Context that it replaces the old one, and links to it.
The old file keeps its original, now-wrong conclusion.
That is deliberate: the pair shows how the thinking changed, which is more useful
than a single file that was quietly rewritten.

## Index

If `docs/adr/` holds more than about five records, keep a `docs/adr/README.md`
with one table row per ADR: number, title, status, date.
Never let the index carry reasoning. It is a reference module, nothing else.

## Language

Follow the language rules in the `technical-documentation` skill: one term per
concept, short sentences, active voice, present tense.
An ADR is prose, not a procedure, so it takes the descriptive limits of 25 words
per sentence and 6 sentences per paragraph.
