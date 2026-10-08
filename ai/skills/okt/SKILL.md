---
name: okt
description: >
  Run one study session ("økt") in the obsidian-laeringshvelv vault: pick course and topic,
  warm-up recall, teach new material Socratically, give exam-style problems, update the
  learner model, make flashcards and log everything. Started by the `studie` shell command
  as `/okt` or `/okt <emnekode>`. Use whenever the user wants to study, "ta en økt",
  "studere", "fortsett økta" or resume an interrupted session.
argument-hint: "[emnekode]"
---

# Økt

One command, zero decisions for the user. You choose course, topic and activity.
The user always attempts first: before a new explanation, before a hint, before a solution.
Recall beats rereading, problems beat explanation. The goal is skills the user has without Claude.

All user-facing text is Norwegian bokmål. Never use an em dash.

**Display depends on where the user reads.** When Remote Control is active (a system reminder says the user can follow the conversation from another device, and `SendUserFile` is available), the user reads in claude.ai, which renders LaTeX: write math as `$...$` inline and `$$...$$` for display. Otherwise the user reads in the terminal, which does not render LaTeX: write math with Unicode and plain text (`h(n) ≤ h*(n)`, `S(p) = 1 / (f + (1 − f)/p)`, `O(n²)`, `Σᵢ CPIᵢ · nᵢ/n`, `x₁`, `√`, `∞`), with a code block for multi-line derivations, and never `$...$`. Notes and cards always use LaTeX, because Obsidian renders it.

**Figures:** whenever you refer to a figure (a note's figure, an exam figure), show it, do not only name it. With Remote Control, send it with `SendUserFile` (`display: "render"`, `status: "normal"`): a Read result only shows a tiny thumbnail there. In the terminal, open it in the image viewer with `/usr/bin/python3 _system/scripts/pdfverktoy.py vis <bilde.webp>`, because the terminal shows neither images nor Obsidian embeds. Give the path as well, so the user can find it in Obsidian.

## Files (vault root: `~/Documents/obsidian-laeringshvelv`)

| File | Use |
|---|---|
| `_system/config.md` | Limits, courses, exam dates, paths, exam formats, split and problem types per course. Read at start. All personal and course-specific settings live here, never in this skill. |
| `_system/elevmodell.md` | One row per concept: level 0-4, last tested, confidence, error types, next action. |
| `_system/logg.md` | One block per session. Write continuously. |
| `10 fag/<fag>/læreplan.md` | Lectures in order, concepts, prerequisites, exam weight, status, next topic. |
| `20 notater/<konsept>.md` | Concept notes. Infrastructure for you, not reading material for the user. |
| `_system/beslutninger.md` | All setup decisions. Read only when something here is unclear. |

Concept notes are context for you: read them instead of the original PDFs. Never reread a source PDF that `innta` has already processed.

## State is written continuously

The session can die at any moment (terminal closed, usage limit, context compaction). Nothing may be lost:
- Write the log block at startup, before anything else happens.
- Update `elevmodell.md` **after every question and every problem**, not at the end.
- Append each notable event to the session's log block as it happens (`- feil: ...`, `- sikker-og-feil: ...`, `- nivå: ...`, `- hint: ...`).
- Before asking a question or giving a problem, append `- venter: <the question or problem, verbatim>`, so an interrupted session can ask it again.
- If context was compacted, reread `logg.md` (your own block) and `elevmodell.md` before continuing.

## 1. Oppstart (max 1 minute, no questions unless needed)

1. `date '+%F %H:%M'`. This is the start time.
2. Read `_system/config.md` and the last ~60 lines of `_system/logg.md`.
   If `$ARGUMENTS` is a code in "Personlige temaer", follow the `egen-okt` skill instead of this one. If it is neither a course code nor a personal topic, list both kinds of codes, say that `studie ny` plans a new topic, and stop.
3. **Unfinished session:** if a block for a course in the Emner table has `Slutt: uavsluttet`:
   - Started today and less than 3 hours ago: **resume it**. Append `- gjenopptatt <tid>`, reread the block and `elevmodell.md`, and continue from the last event. If the last event is `- venter: ...`, ask exactly that question again first. Skip steps 4-8 (course, mode and block already exist), but still do step 4 if new PDFs exist.
   - Older: finish it silently: run the `kort` skill's procedure on its events, then set `Slutt: avbrutt, fullført <dato tid>`. Mention it in one line and start a new session.
   - Unfinished blocks for personal topics belong to `egen-okt`. Finish them silently the same way only if they are older than 3 hours.
4. **New sources:** `/usr/bin/python3 _system/scripts/pdfverktoy.py nye`. If it lists any, run the `innta` skill's procedure on them. If the material belongs to a lecture whose prerequisites in `læreplan.md` are all `lært`, it becomes today's topic, and its course becomes today's course unless the user gave one. Otherwise it is only ingested and does not change course or topic. A lecture date says nothing about what the user has seen: see "Oppfølging av undervisning" in `config.md`.
   Then run `/usr/bin/python3 _system/scripts/kildesjekk.py`. It lists held lectures (not `innlest` or `lært`) whose slides are missing from Nextcloud or not listed in Kilder. Show the result to the user as a short list in the first message, so they can download the slides into `~/Downloads`, and log it as `- kilder mangler: ...`. Do not wait for the upload: the session continues, and the next session's step 4 picks up the new PDFs.
5. **Choose course** (skip if `$ARGUMENTS` names one):
   - Only courses in the Emner table. Personal topics are never chosen here, because they run only when the user asks for them.
   - Exclude courses whose "Aktiv fra" is in the future.
   - If `logg.md` already has a finished session today, exclude that course, unless it has an exam within 7 days.
   - Score each remaining course and pick the highest:
     `60 / max(dager til eksamen, 1)` + `2 ×` (held lectures with high exam weight not `lært`) + `1 ×` (other held lectures not `lært`) + `0.5 ×` (days since last session in this course, max 10).
     For a course the user follows on their own ("Oppfølging av undervisning" in `config.md`), halve the two lecture terms: the user has seen that material, so sessions consolidate instead of teaching from scratch.
   - Tell the user in **one line** what you chose and why, then continue straight into the warm-up in the same message. Do not wait for confirmation: an empty Enter sends nothing in Claude Code. Example: `ABC1234, T1 søk: 17 dager til eksamen, 6 forelesninger bak. (Skriv en annen emnekode for å bytte.)` If the user answers the first question with a course code instead, switch course.
6. **New capture notes:** use Glob on `10 fag/<fag>/fangst/*.md` and read the files dated after the course's last session in the log. Read them. Lines marked as exam hints raise the exam weight of that lecture in `læreplan.md`. Things the user did not understand become pretest questions today.
7. **Mode:** days to exam ≤ 7 gives exam mode only. Between 8 and 28 days, the share of exam problems in the main part is `25 % + 75 % × (28 - dager) / 21`.
8. Write the log block:
   ```
   ## <dato> <tid> <EMNE>
   Slutt: uavsluttet
   Tema: <lecture nr and topic>
   Hendelser:
   ```

## 2. Oppvarming (max 5 minutes)

- 5 questions: 3 from today's course, 2 from other active school courses (interleaving). Never personal topics. A course whose "Aktiv fra" is in the future only gets questions as the exception under the Emner table allows.
- Pick concepts with level 1-2 and the oldest "sist testet", anything with `sikker-og-feil`, and next actions like "test i oppvarming".
- Ask one level above the recorded level: level 1 gets an explain question (level 2), level 2 gets a small application (level 3).
- Warm-up questions are short recall questions answerable in under a minute. Calculations and longer problems belong in the main part.
- **Hard time cap:** log `- fase: oppvarming <tid>` when it starts, and run `date` after every answer. At 5 minutes, stop the warm-up even if questions remain. Unasked concepts keep next action `test i oppvarming`.
- One question at a time. The user answers and gives confidence 1-3 (`svar (sikkerhet)`). Ask for confidence if it is missing.
- **Correct:** two correct in a row raise the level by 1. Track the first correct answer in "Neste tiltak" as `1 riktig på nivå N`.
- **Wrong:** lower the level by 1 (min 0) and give the correct answer with at most 2 sentences of explanation. Do not ask a variant in the warm-up: set next action `variant i hoveddel` if the concept belongs to today's course, otherwise `test i oppvarming`. Deeper explanation belongs in the main part.
- **Wrong with confidence 3:** also add error type `sikker-og-feil`.
- **Write to `elevmodell.md` after every question** (level, sist testet = today, sikkerhet, feiltyper, neste tiltak) and append the event to the log block.

## 3. Hoveddel (rest of the session's pomodoros)

Split between new material and problems: the Fordeling column in "Fordeling og oppgavetyper" in `config.md`.
**While the course is behind** (any held lecture with high exam weight is not `lært`), use 60/40 new material to problems instead. A course the user follows on their own is never treated as behind: use 30/70, since the material has been seen and the check questions are quick. Exam mode (step 1.7) overrides all of these.

**Topic:** "Neste tema" in `læreplan.md`, unless new material with all prerequisites `lært` was ingested today.
- Status `ikke innlest`: run the `innta` skill's procedure on the lecture's sources in Nextcloud (the path is in the Kilder column and `config.md`), then teach.
- Status `innlest` with concepts at level 1, in a course the user follows on their own: the user has probably seen them. One check question per concept. A miss gets the full walkthrough below, a hit moves on.
- In a course the user does not follow, treat held lectures as unseen: go straight to the walkthrough below, starting with its attempt question.

### New material (walkthrough on a miss)

Novices learn more from worked examples than from repeated questioning, so keep the number of questions per concept low and teach properly when needed.

For each concept, in prerequisite order:
1. **One attempt question** before any explanation. If the answer is right and confident, go to step 4.
2. **Walkthrough on a miss (3-6 min of reading):** a connected explanation that builds on the answer, the note's figure (shown as described under Figures), and **one fully worked example** in the course's notation, step by step. No leading questions in between. This is teaching, not Socratic dialogue.
3. The user may ask follow-up questions. Answer them fully but briefly.
4. **One check question:** the user explains the concept in their own words without notes, or does a small variant of the worked example. Pass means level 2. Write to `elevmodell.md`.

Max 3 questions per concept, the attempt question included. Errors in the check question get a short correction and next action `variant i hoveddel`, not a new round of questions.

When every concept of a lecture reaches level 2 or more, set the lecture's status to `lært` in `læreplan.md` and set `status: gjennomgått` in `10 fag/<fag>/forelesninger/forelesning <nr>.md`.

### Problems (level 3)

What a problem means per course: the "Hva en oppgave er" column in "Fordeling og oppgavetyper" in `config.md`, together with the course's exam format.

**Figures in exam or textbook problems** (graphs, trees, circuits, code screenshots, tables): always extract them, never ask the user to open the PDF and find the page.
1. `pdfverktoy.py sider <pdf> <side> <side>` and read the page image.
2. `pdfverktoy.py beskjaer <side.png> X0 Y0 X1 Y1 <EMNE> eksamen-<år>-<H|V>-oppg<N>` (textbook: `bok-<kap>-oppg<N>`). The figure goes to `90 vedlegg/figurer/<EMNE>/`, so it can be reused later.
3. `pdfverktoy.py vis <bilde.webp>` opens it in the image viewer, and you also print the path.
Copy the task text into the chat yourself. The user should never need the PDF.

Sources, in order: old exams in the course's `eksamener/` folder (Kilder in Stier in `config.md`) (use the solution file `-l.pdf` to check, and read only the task you need), variants of old exercises (`10 fag/<fag>/øvinger/` and Nextcloud), textbook exercises, and your own exam-style problems. Respect the syllabus exclusions in `læreplan.md`.

**Hint ladder, only when the user asks** ("hint"):
1. Which concept applies.
2. The first step.
3. A similar solved example.
4. The full solution.

Hint 3 or 4 sets next action `variantoppgave uten hjelp` for the concept. Without hints and correct: level 3 (or 4 for an exam problem or an unfamiliar twist).
Assess the method, not just the answer: say what is right and why, point to errors with a question instead of correcting them outright.
**Write to `elevmodell.md` after every problem** and append to the log block.

### Handwritten work ("sjekk")

When the user writes "sjekk": read the newest file in the submission folder (Innleveringsmappe in Stier in `config.md`) (PDF: `/usr/bin/python3 _system/scripts/pdfverktoy.py sider <pdf>` and read the images). Give feedback on the method step by step, not just the final answer.

### Time

A session is the number of pomodoros in "Tidsbudsjett per økt" in `config.md`: 25 minutes of work, then a 5-minute break. The blocks are a hard rule, not a suggestion.
- Log `- pomodoro <N> start <tid>` when a block starts. The warm-up is part of pomodoro 1.
- Run `date` after every answer. When 25 minutes of the block have passed, finish the current question or problem, but never start a new one. Then log `- pomodoro <N> slutt <tid>` and the next question as `- venter: ...`, and say in one line: `Pause 5 min. Skriv hva som helst når du er tilbake.`
- When the user returns, start the next block by asking the waiting question. Breaks do not count in the time split.
- After the last pomodoro, go to the wrap-up. The user may end after any block with "ferdig", or ask for one more block.
- Log `- fase: <oppvarming|nytt stoff|oppgaver|avslutning> <tid>` whenever the phase changes, so the time split can be measured afterwards. The split per course applies to the session's work time across all blocks.

## 4. Eksamensmodus

- Mixed tasks from old exams, with a time limit equal to the exam's (points × exam minutes / total points).
- No hints during the attempt. Full review afterwards, task by task.
- Weak topics from the review get next action `oppvarming neste økt` in `elevmodell.md`.

## 5. Avslutning (when the user writes "ferdig", max 5 minutes)

1. **Cued free recall over the whole session:** list 3-6 keywords, one per concept or problem covered in the session, taken from the log block (not just the last 15 minutes). Keywords name the topic only, never the content (`IEEE 754`, `ldr = og literal pool`, `arrayindeksering i løkker`). The user writes 1-2 sentences from memory per keyword, with no notes.
   Compare each answer with its concept note and point out what is missing or wrong. Gaps that were never taught in the session become next actions, not cards.
   Save each answer verbatim in that concept's note under `## Med mine ord` (create the section right before `## Flashcards` if missing), as:
   ```
   **<dato>:** <brukerens tekst ordrett>
   Rettelse: <én rettelse per linje>
   ```
   New entries go below older ones.
2. **Cards:** run the `kort` skill's procedure.
3. **Log:** set `Slutt: <tid>` and add 1-2 `Observasjoner:` about how the user learns (recurring confusions, what worked).
4. **Læreplan:** recompute "Neste tema" by the rule at the top of `læreplan.md`.
5. One line about what the next session will start with.
