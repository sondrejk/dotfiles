---
name: okt
description: >
  Run one study session ("økt") in the obsidian-laeringshvelv vault: pick course and topic,
  spaced repetition of learned concepts, teach new material Socratically, give exam-style problems, update the
  learner model, make flashcards and log everything. Started by the `studie økt` and
  `studie <emne>` shell commands as `/okt` or `/okt <emne>`. Use whenever the user wants to study, "ta en økt",
  "studere", "fortsett økta" or resume an interrupted session.
argument-hint: "[emne]"
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
| Study plan (optional, path under Stier in `config.md`) | Periods up to the exams and course-choice rules that override the score. Read at start. |
| `_system/elevmodell.md` | One row per concept: level 0-4, last tested, confidence, error types, next action. |
| `_system/logg.md` | One block per session. Write continuously. |
| `10 fag/<fag>/læreplan.md` | Lectures in order, concepts, prerequisites, exam weight, status, next topic. |
| `10 fag/<fag>/eksamenskart.md` | Every old exam task with points, lecture, concepts and status (`reservert`, `brukt <dato>`). Built by `innta`. |
| `20 notater/<konsept>.md` | Concept notes. Infrastructure for you, not reading material for the user. |
| `_system/beslutninger.md` | All setup decisions. Read only when something here is unclear. |

While "Parkert" in `config.md` lists `systemendringer`, feedback on the system itself (skills, scripts, rules) goes as one line to the ideas file named there, and the session continues. Fix it at once only when it stops or breaks the session.

Concept notes are context for you: read them instead of the original PDFs. Never reread a source PDF that `innta` has already processed.

## State is written continuously

The session can die at any moment (terminal closed, usage limit, context compaction). Nothing may be lost:
- Write the log block at startup, before anything else happens.
- Update `elevmodell.md` **after every question and every problem**, not at the end. "After" means in the same turn, through the background writer described under "Rhythm".
- Append each notable event to the session's log block as it happens (`- feil: ...`, `- sikker-og-feil: ...`, `- nivå: ...`, `- hint: ...`).
- Before asking a question or giving a problem, append `- venter: <the question or problem, verbatim>`, so an interrupted session can ask it again. One item is open at a time (see "Rhythm"). Remove nothing: an answered item gets `- besvart: <nr>`.
- If context was compacted, reread `logg.md` (your own block) and `elevmodell.md` before continuing.

## Rhythm: one item at a time, in the task file

The user works on exactly one item at a time and gets feedback on it right away, while it is fresh.
The item lives in the task file (Oppgavefil in Stier in `config.md`), which the user keeps open in vim with `studie nå` beside the chat. The chat holds feedback, walkthroughs and the user's questions.
This section sets the rhythm for the repetition block, attempt questions, check questions and problems. The mock exam and "sjekk" follow their own rules.

**The task file:** overwrite it with each new item, in this form, with math in Unicode because vim shows plain text:
```
# <Spørsmål|Oppgave> <nr> · <fase> · <emne>: <begrep eller oppgave>

<the item, complete: everything needed to answer it without the chat>

## Svar


## Sikkerhet (1-3)

```
- A problem with sub-questions gives one item per sub-question (a, then b), so each gets feedback while it is fresh. Repeat the setup the sub-question needs in every item.
- A coding problem: the item names the code file's full path on a line of its own, and nothing else on that line. `studie nå` then shows the code file instead of the task file, and goes back to the task file with the next item that is not code. The answer is the code file itself.
- A follow-up on the same code file (a fix, questions about lines in it) goes as a comment in the code file, right under the task comment: `studie nå` stays on a file it already shows, so a new item in the task file would not be seen. Still write a short item in the task file naming the code file, so the log and the fallback agree.
- A figure: send it in the chat (see Figures) and write `Figur: se chatten.` in the item.
- After a walkthrough, the item is its check question, with one line saying that the walkthrough is in the chat.

**An answer** arrives as `svar <path>`, sent by the submit key in vim. Read that file: the text under `## Svar` and the number under `## Sikkerhet`. If confidence is missing, ask for it in the feedback and go on without it. A code file path is the attempt of a coding problem (see Coding problems).
If the user answers in the chat instead (on the phone, or without vim), accept it, and end every message with the item as well, under `**Nå:**`, until a `svar` arrives again.

**On each answer, in one round of tool calls:**
1. Write the next item to the task file. Choose it from this answer, so a miss gets its variant or walkthrough at once.
2. Dispatch the bookkeeping (below) and run `date`.
Then write the feedback as the final text, with no tool call after it: verdict, one short sentence naming what the answer got right (the task file is already overwritten, so a bare `riktig` does not tell the user what it refers to), then at most 2 sentences of correction. The deep explanation belongs in the main part (a walkthrough, or the next action in `elevmodell.md`), never here.
The next item reaches vim a few seconds before the feedback reaches the chat. That is intended: the user reads the feedback, then starts.

**At the start of a phase,** read the notes for every concept the phase will touch in one batch, before the first item, so later answers need no reads.
Until the first `svar` of the session has arrived, show the item in the chat as well, since `studie nå` may not be open yet. Say once per session: `Oppgavene står i studie nå. Svar under ## Svar og lever med mellomrom + s.`

**Bookkeeping must not block the message.**
- State writes for an answer (`elevmodell.md` rows, log lines, `- venter:` and `- besvart:` lines) go to a background agent: `Agent` with `run_in_background: true`, a prompt that names the exact rows and lines to write, and never a wait for the result. Keep the running state (levels, streaks, the open item) in your own context, and use the files only for recovery after a restart or compaction.
- If no `Agent` tool is available, do all writes of the turn in one batched command instead of one call per row.
- Text written before a tool call may not reach the user in Remote Control: write the whole message as the final text, with no tool call after it.
- Before the wrap-up and before a pause, confirm that the background writes landed: reread the session's log block and the touched `elevmodell.md` rows, and redo what is missing.

**Pomodoro end and "ferdig":** write no new item. Put `Pause til <tid>.` on the first line of the task file and leave the open item below it. It has its `- venter:` line and is the first thing in the next block.

## 1. Oppstart (max 1 minute, no questions unless needed)

1. `date '+%F %H:%M'`. This is the start time.
2. Read `_system/config.md`, the study plan if Stier in `config.md` lists one, and the last ~60 lines of `_system/logg.md`.
   Run `/usr/bin/python3 _system/scripts/kortstatus.py`. If it reports an `etterslep` above 0, add one line to the first message: `Kort: <n> forfalte venter. Ta dem i dag.`
   **Repetition queue:** for each row in "Repetisjonskø" in `config.md` whose Fra is today or earlier and whose Startet is empty, run `/usr/bin/python3 _system/scripts/repetisjonsstart.py <emne>`, write today's date in Startet, and mention it in one line.
   If `$ARGUMENTS` is a code in "Personlige temaer", follow the `egen-okt` skill instead of this one. If it is neither a course (the Emne column in Emner) nor a personal topic, list both kinds of names, say that `studie ny` plans a new topic, and stop.
3. **Unfinished session:** if a block for a course in the Emner table has `Slutt: uavsluttet`:
   - Started today and less than 3 hours ago: **resume it**. Append `- gjenopptatt <tid>`, reread the block and `elevmodell.md`, and continue from the last event. Ask every open `- venter:` item (a `- venter:` line with no later `- besvart:` for it) again first, verbatim and oldest first. Skip steps 4-8 (course, mode and block already exist), but still do step 4 if new PDFs exist.
   - Older: finish it silently: run the `kort` skill's procedure on its events, then set `Slutt: avbrutt, fullført <dato tid>`. Mention it in one line and start a new session.
   - Unfinished blocks for personal topics belong to `egen-okt`. Finish them silently the same way only if they are older than 3 hours.
4. **New sources:** `/usr/bin/python3 _system/scripts/pdfverktoy.py nye`. If it lists any, run the `innta` skill's procedure on them. If the material belongs to a lecture whose prerequisites in `læreplan.md` are all `forklart` or `lært`, it becomes today's topic, and its course becomes today's course unless the user gave one. Otherwise it is only ingested and does not change course or topic. A lecture date says nothing about what the user has seen: see "Oppfølging av undervisning" in `config.md`.
   Then run `/usr/bin/python3 _system/scripts/kildesjekk.py`. It lists held lectures (not `innlest` or `lært`) whose slides are missing from Nextcloud or not listed in Kilder. Show the result to the user as a short list in the first message, so they can download the slides into `~/Downloads`, and log it as `- kilder mangler: ...`. Do not wait for the upload: the session continues, and the next session's step 4 picks up the new PDFs.
5. **Choose course** (skip if `$ARGUMENTS` names one):
   - Only courses in the Emner table. Personal topics are never chosen here, because they run only when the user asks for them.
   - Exclude courses whose "Aktiv fra" is in the future.
   - If `logg.md` already has a finished session today, exclude that course, unless it has an exam within 7 days or the rule in `config.md` for the day's later sessions allows the same course.
   - If the study plan has a course-choice rule that applies today, it decides instead of the score. Name the rule in the one-line explanation.
   - Score each remaining course and pick the highest:
     `60 / max(dager til eksamen, 1)` + `2 ×` (held lectures with high exam weight not `lært`) + `1 ×` (other held lectures not `lært`) + `0.5 ×` (days since last session in this course, max 10).
     A lecture is held when its Dato in `læreplan.md` is today or earlier. The læreplan stores no held status, so always compute it from the date.
     For a course the user follows on their own ("Oppfølging av undervisning" in `config.md`), halve the two lecture terms: the user has seen that material, so sessions consolidate instead of teaching from scratch.
   - Tell the user in **one line** what you chose and why, then continue straight into the repetition block in the same message. Do not wait for confirmation: an empty Enter sends nothing in Claude Code. Example: `algdat, T1 søk: 17 dager til eksamen, 6 forelesninger bak. (Skriv et annet emne for å bytte.)` If the user answers the first question with a course name instead, switch course.
6. **Capture notes** (the user's own notes from lectures and videos). Skip this step while "Parkert" in `config.md` lists `fangst`:
   - **Sort the inbox first:** every note in `00 innboks/` with `type: fangst` belongs to the course its `Kilde:` line names, matched against "Fangst" in `config.md` (nicknames), the Emne, the Emnekode and the Navn. Move it to `10 fag/<fag>/fangst/` with `mv`. Delete a capture with nothing under its headings (an empty template). Leave a capture whose course is unclear in the inbox and mention it in one line. Log `- fangst: flyttet <n>, slettet <n> tomme`.
   - **Read unread captures for today's course:** every `10 fag/<fag>/fangst/*.md` without `lest:` in its frontmatter. Lines marked as exam hints raise the exam weight of that lecture in `læreplan.md`. Things the user did not understand become pretest questions today when the concept is taught in this session. Otherwise add them to that concept's Neste tiltak in `elevmodell.md` (`fangst: <hva som var uklart>`), so they are not lost. Then add `lest: <dato>` to the capture's frontmatter, so it is read once.
7. **Mode:** days to exam ≤ 7 gives exam mode only. Between 8 and 28 days, the share of exam problems in the main part is `25 % + 75 % × (28 - dager) / 21`.
   This share is a floor on the main part's work time, measured with the `- fase:` times, and it holds also when the course is behind, unless the study plan sets another split for the course (for example more new material while high-weight lectures are not yet explained). Such a rule then replaces both the floor and exam-only mode, but never a mock exam. Plan the session so the problems fit: when the new material runs long, the last block goes to exam problems.
   If `config.md` makes this session a problem session (for example the day's third session), the main part is problems only, on concepts at level 2 or more, with no new material.
8. Write the log block:
   ```
   ## <dato> <tid> <emne>
   Slutt: uavsluttet
   Tema: <lecture nr and topic>
   Hendelser:
   ```

## 2. Repetisjon (spaced repetition, the time in "Repetisjonsblokk" in config)

Learned concepts come back at growing intervals, and Claude grades the answers, so the user never has to judge whether an explanation matches a card.
This replaces flashcards for every course and topic in "Repetisjonskø" in `config.md` with a Startet date. Only abbreviations stay as cards (see `kort`).

**Queue:** the `Neste repetisjon` column in `elevmodell.md`. A concept is due when its date is today or earlier. When a course's exam has passed, set `-` for its concepts that belong to no course with an exam ahead.

**Picking,** in this order until the block is full:
1. Due concepts, most overdue first.
2. Concepts with error type `sikker-og-feil`, or next action `test i repetisjon`, `test i oppvarming` or `oppvarming neste økt`. Level 1 concepts are among these.
3. When time is left: the concepts with the nearest date. An early repetition counts as a normal one.
Interleave: mix the courses, and avoid two concepts from the same lecture in a row. Today's course gets no priority. Never a course whose "Aktiv fra" is in the future, apart from the exception under the Emner table.

**The item:** 3-4 numbered questions in one item in the task file, each on a different concept, each answerable in 1-2 sentences or a tiny calculation. `## Sikkerhet` takes one number per question (`3 2 3`).
- Phrase each question fresh from the concept note's body, its Eksamenskrav and its archived cards, which are the question bank. Never copy a card verbatim.
- Vary the angle between repetitions of the same concept: definition, cause, contrast with the nearest neighbour, consequence, a small application, or the description given and the term asked. Log the angle, so the next repetition picks another one.
- A level 1 concept (step 2) gets an explain question, as the level above.
- Only facts a session has taught. A gap in untaught material is a teaching task, never a question here.

**Feedback:** per question in order: `riktig`, `delvis` or `feil`, with one short sentence summing up what the answer got right (not the whole answer), and for delvis and feil the correct answer in one sentence. No variants or walkthroughs in the block: a miss on today's course gets next action `variant i hoveddel`.

**New date,** after each question. I is the previous interval: the old Neste repetisjon minus the old Sist testet, in days, at least 1.

| Result | Neste repetisjon |
|---|---|
| riktig, sikkerhet 3 | today + max(2, round(2.5 · I)) |
| riktig, sikkerhet 1-2 | today + max(2, round(1.5 · I)) |
| delvis | tomorrow |
| feil | tomorrow, and the level goes down 1 (min 0) |
| feil, sikkerhet 3 | tomorrow, level down 1, and error type `sikker-og-feil` |

The factors and the cap are in "Repetisjonsintervaller" in config. Never set a date on or after the day of the nearest exam among the concept's courses: use the day before instead.
A concept below level 2 has no date (`-`). When it falls below 2, set `-` and next action `test i repetisjon`. When a concept reaches level 2 anywhere in the session (a check question, or two correct here), set tomorrow.
A concept tested elsewhere in the session (a check question, a problem) also gets a new date from this table.

**Levels:** due concepts at level 2 or more do not rise here: levels 3 and 4 need problems. Step 2 concepts rise as before: two correct in a row raise the level by 1, with the first one tracked in Neste tiltak as `1 riktig på nivå N`.

**Time:** log `- fase: repetisjon <tid>` when it starts, and run `date` after every answer. Fill at least the minimum time, with step 3 if steps 1-2 run out. After the minimum, start a new item only while due concepts (steps 1-2) remain. At the maximum, start no new item. The open item can still be answered and graded. Unasked concepts keep their date, so they come first next time.

**Write to `elevmodell.md` after every item,** through the background writer (see Rhythm): level, sist testet = today, sikkerhet, feiltyper, neste tiltak and neste repetisjon per concept, and one log line per question (`- repetisjon: <begrep> (<vinkel>): riktig|delvis|feil, sikkerhet N, neste <dato>`).

## 3. Hoveddel (rest of the session's pomodoros)

Split between new material and problems: the Fordeling column in "Fordeling og oppgavetyper" in `config.md`.
**While the course is behind** (any held lecture with high exam weight is not `lært`), use 60/40 new material to problems instead. A course the user follows on their own is never treated as behind: use 30/70, since the material has been seen and the check questions are quick. The exam ramp and exam mode (step 1.7) override all of these.

**Topic:** "Neste tema" in `læreplan.md`, unless new material with all prerequisites `forklart` or `lært` was ingested today.
- Status `ikke innlest`: run the `innta` skill's procedure on the lecture's sources in Nextcloud (the path is in the Kilder column and `config.md`), then teach.
- Status `innlest` with concepts at level 1, in a course the user follows on their own: the user has probably seen them. One check question per concept. A miss gets the full walkthrough below, a hit moves on.
- In a course the user does not follow, treat held lectures as unseen: go straight to the walkthrough below, starting with its attempt question.

### New material (walkthrough on a miss)

Novices learn more from worked examples than from repeated questioning, so keep the number of questions per concept low and teach properly when needed.

For each concept, in prerequisite order:
1. **One attempt question** before any explanation. If the answer is right and confident, go to step 4, but first cover in a few lines the items of the note's Eksamenskrav that the answer did not show.
2. **Walkthrough on a miss (3-6 min of reading):** a connected explanation that builds on the answer, the note's figure (shown as described under Figures), and **one fully worked example** in the course's notation, step by step. No leading questions in between. This is teaching, not Socratic dialogue.
   - The walkthrough covers **every item** in the note's `**Eksamenskrav:**`, not only what the attempt revealed. If the note has no such list, build it first as `innta` describes. Items that belong to a later concept are named with `kommer senere`, and must be in that concept's Eksamenskrav (add them if not).
   - An item of this concept that the walkthrough did not reach goes into the concept's Neste tiltak in `elevmodell.md` as `eksamenskrav: <item>`, so the next session teaches it. Never mark open items in the note itself.
   - Every symbol, index, abbreviation and name is explained at its first use, also those taken from slide figures (`Dᵢ = domenet til variabel nummer i`, `WA = Western Australia`). A term used before it is taught is marked `kommer senere`.
   - **Term check before sending:** list every technical term in the walkthrough, including file types, build artefacts, tools and mechanisms it leans on (`.h`, objektfil, lenker, laster, `volatile`, sideeffekt). Each term must be explained in the same message, be a concept at level 2 or more in `elevmodell.md`, or be marked `kommer senere`. Having seen or used it in code does not make it known. Log the check as `- begreper: <term> (forklart|nivå N|kommer senere), ...`. The same check applies to extra context, problems and answers to follow-up questions.
   - End with one line: `Dekket: <items>. Kommer senere: <items, and when>.`
   - Then offer, in one line: `Vil du ha dette visualisert eller i kode?` Where a visual or code clearly helps (an algorithm whose state changes step by step), include it without asking. Visuals: a figure, or an interactive HTML page with step buttons. Code: short Python or pseudocode.
3. The user may ask follow-up questions. Answer them fully but briefly. Each follow-up question shows a gap in the walkthrough: log it as `- hull: <spørsmålet>`, and add the answer to the concept note (body or Eksamenskrav), so later walkthroughs, cards and problems include it.
4. **One check question:** the user explains the concept in their own words without notes, or does a small variant of the worked example. Pass means level 2. Write to `elevmodell.md`.

Max 3 questions per concept, the attempt question included. Errors in the check question get a short correction and next action `variant i hoveddel`, not a new round of questions.

When every concept of a lecture reaches level 2 or more and none has an open `eksamenskrav:` in Neste tiltak, set the lecture's status to `forklart` in `læreplan.md`. Later lectures that depend on it can now be taught.
A `forklart` lecture becomes `lært` after **one exam problem** on it: an old exam task from `eksamenskart.md` if one exists and is not `reservert`, otherwise an exam-style problem built from the Eksamenskrav. Give it in the same session if a problem slot is left, otherwise in the next problem session (see "Tredje økt samme dag" in `config.md`). If the problem needs something no note's Eksamenskrav lists, add it to the note and teach it. The lecture becomes `lært` when the problem has been solved and reviewed, also when the attempt had errors: those become next actions.

### Problems (level 3)

What a problem means per course: the "Hva en oppgave er" column in "Fordeling og oppgavetyper" in `config.md`, together with the course's exam format.

**Figures in exam or textbook problems** (graphs, trees, circuits, code screenshots, tables): always extract them, never ask the user to open the PDF and find the page.
1. `pdfverktoy.py sider <pdf> <side> <side>` and read the page image.
2. `pdfverktoy.py beskjaer <side.png> X0 Y0 X1 Y1 <emne> eksamen-<år>-<H|V>-oppg<N>` (textbook: `bok-<kap>-oppg<N>`). The figure goes to `90 vedlegg/figurer/<emne>/`, so it can be reused later.
3. `pdfverktoy.py vis <bilde.webp>` opens it in the image viewer, and you also print the path.
Copy the task text into the chat yourself. The user should never need the PDF.

Sources, in order: old exam tasks from the course's `eksamenskart.md`, chosen by concept and points, skipping tasks marked `reservert` (they are kept for full mock exams) and preferring tasks not yet `brukt`. Read only the task you need from the exam PDF in `eksamener/` (Kilder in Stier in `config.md`), check with the solution file `-l.pdf`, and mark the task `brukt <dato>` in the kart. Then variants of old exercises (`10 fag/<fag>/øvinger/` and Nextcloud), textbook exercises, and your own exam-style problems. Respect the syllabus exclusions in `læreplan.md`.
Your own problems change the form, because the exam may differ from the old ones: a new problem instance, the question asked backwards, two concepts in one task, or an edge case. These are the unfamiliar twists that give level 4.

**Hint ladder, only when the user asks** ("hint"):
1. Which concept applies.
2. The first step.
3. A similar solved example.
4. The full solution.

Hint 3 or 4 sets next action `variantoppgave uten hjelp` for the concept. Without hints and correct: level 3 (or 4 for an exam problem or an unfamiliar twist).
Assess the method, not just the answer: say what is right and why, point to errors with a question instead of correcting them outright.
**Write to `elevmodell.md` after every problem** (with Neste repetisjon, see section 2) and append to the log block.

### Coding problems

Any problem where the user writes or changes code (C, MPI, OpenMP, CUDA, ARM assembly) is done in a file, not in the chat. Short code-reading questions stay in the chat.
The item in the task file names the code file (see "Rhythm"), and the submit key in vim hands it in.
1. Create the file in the course's code folder (Kodeoppgaver in Stier in `config.md`), named after the task without a date: `vecadd.cu`, `halo-sendrecv.c`, `summer-array.s`. Never overwrite an existing file: pick another name.
2. Contents: the task text as one `/* ... */` comment at the top, so the user never switches windows. Nothing else when the task says "write a program": no skeleton, no includes, no `main`. Code the task itself gives (find the bug, complete the function, what does this print) goes in below the comment.
3. Runtime settings the program needs go on one line inside the comment: `kjør: mpirun -np 4 ./prog`, `kjør: OMP_NUM_THREADS=8 ./prog 1000`. Leave it out when `./prog` (or `mpirun -np 4` for MPI) is enough.
4. A task that asks only for a function or kernel gets a driver `<navn>.main.<c|cu>` next to it, which `#include`s the user's file (for `.s`: is linked with it) and prints the result. The driver is not a test: it never says right or wrong.
5. Write the item with the file's full path to the task file, and log `- venter:` with the task and the path. In the chat fallback, give the command on its own line instead:
   ```
   studie kode <emne> <fil>
   ```
   Mention once per session that `:make` in vim (or `studie kjør <emne> <fil>`) compiles and runs it, with compiler errors in the quickfix list (CUDA runs on the CUDA-maskin in config).
6. When `svar <the code file>` arrives (or the user says they are done), read `forsøk1/<fil>` if it exists, otherwise the file itself, and copy that to `forsøk1/<fil>`. That first version is the attempt: the level follows it, as on a paper exam without a compiler. Later fixes after compiler errors are learning, not "without hints". Also read the current file, and say what the compiler caught that the attempt missed.
7. Feedback follows the rules above. Questions about errors refer to line numbers in the file.

If the user answers a coding problem in the chat instead (no terminal at hand), accept it and assess it the same way.

### Handwritten work ("sjekk")

When the user writes "sjekk": read the newest file in the submission folder (Innleveringsmappe in Stier in `config.md`) (PDF: `/usr/bin/python3 _system/scripts/pdfverktoy.py sider <pdf>` and read the images). Give feedback on the method step by step, not just the final answer.

### Time

A session is the number of pomodoros in "Tidsbudsjett per økt" in `config.md`: 25 minutes of work, then a 5-minute break. The user decides how long a break lasts: never comment on it or push to resume.
- Log `- pomodoro <N> start <tid>` when a block starts. The repetition block is part of pomodoro 1.
- Run `date` after every answer. When 25 minutes of the block have passed, write no new item: the open one may be finished, but nothing new starts. Then log `- pomodoro <N> slutt <tid>` and the next question as `- venter: ...`, and say in one line: `Pause 5 min. Skriv hva som helst når du er tilbake.`
- When the user returns, start the next block with the open item, or write a new one to the task file. Breaks do not count in the time split.
- After the last pomodoro, go to the wrap-up. The user may end after any block with "ferdig", or ask for one more block.
- Log `- fase: <repetisjon|nytt stoff|oppgaver|avslutning> <tid>` whenever the phase changes, so the time split can be measured afterwards. The split per course applies to the session's work time across all blocks.

### Coverage check

Old exams show the format and the weights, not the limits of what can be asked.
Once per course: in the first session in a course whose `læreplan.md` has no `**Dekningssjekk:** <dato>` line, compare every section of the course's Pensum in `læreplan.md` with the concept notes and their Eksamenskrav.
List the sections with no note or no requirement in the log as `- dekningssjekk: <emne>: <hull>`, and add each gap as a concept row in the lecture's row of `læreplan.md` and as level 0 in `elevmodell.md`, so the normal topic choice teaches it. Then write the `**Dekningssjekk:** <dato>` line under Pensum.

## 4. Eksamensmodus

- Mixed tasks from old exams, with a time limit equal to the exam's (points × exam minutes / total points). Never tasks marked `reservert` in `eksamenskart.md`.
- **Mock exam** on the days the study plan lists under "Prøveeksamener": the whole exam named there, at the real duration and with the real aids, no hints and no questions until it is handed in. A composed mock is built from unused tasks in `eksamenskart.md` and own problems in the course's exam format and point split. Score it with the solution and the exam's points, log `- prøveeksamen: <eksamen> <poeng>/<maks>`, then review task by task. A mock replaces the repetition block and the session's pomodoro blocks, and the wrap-up is the review.
- No hints during the attempt. Full review afterwards, task by task.
- Weak topics from the review get next action `test i repetisjon` in `elevmodell.md`.

## 5. Avslutning (when the user writes "ferdig", max 5 minutes)

1. **Cued free recall over the whole session:** list 3-6 keywords, one per concept or problem covered in the session, taken from the log block (not just the last 15 minutes). Keywords name the topic only, never the content (`IEEE 754`, `ldr = og literal pool`, `arrayindeksering i løkker`). The user writes 1-2 sentences from memory per keyword, with no notes.
   Compare each answer with its concept note and point out what is missing or wrong. Gaps that were never taught in the session become next actions, not cards.
   While "Parkert" in `config.md` lists `med mine ord`, stop here: the corrections stay in the chat and the log. Otherwise save each answer verbatim in that concept's note under `## Med mine ord` (create the section right before `## Flashcards` if missing), as:
   ```
   **<dato>:** <brukerens tekst ordrett>
   Rettelse: <én rettelse per linje>
   ```
   New entries go below older ones.
2. **Cards:** run the `kort` skill's procedure.
3. **Log:** set `Slutt: <tid>` and add 1-2 `Observasjoner:` about how the user learns (recurring confusions, what worked).
4. **Læreplan:** recompute "Neste tema" by the rule at the top of `læreplan.md`. Then run `/usr/bin/python3 _system/scripts/forelesningsstatus.py`, which copies each lecture's status and concept progress into its lecture note for the dashboard.
5. One line about what the next session will start with.
