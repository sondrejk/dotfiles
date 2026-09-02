---
name: destill-fangst
description: >
  Distill capture notes ("fangstnotater") in the obsidian-laeringshvelv vault
  (~/Documents/obsidian-laeringshvelv) into atomic Norwegian concept notes. Use
  when the user asks to distill, process or clean up capture notes, or do the
  weekly review ("ukesgjennomgang"). Triggers on "destiller fangstnotater",
  "lag konseptnotater", "gjør ukesgjennomgang", "distill my capture notes",
  "process fangst". Quizzes the user on the material first, then writes or
  extends concept notes based on demonstrated understanding, and always asks
  before introducing a new fagområde.
---

# Destill fangstnotater

Turns raw capture notes into the vault's permanent, atomic, spaced-repetition-ready
concept notes. The point is not to transcribe the capture note, it is to record what
the user actually understood, corrected for whatever the quiz step below reveals.

## Vault structure (short version)

Full rules live in `README.md` and `OPPSETT.md` at the vault root, read those if
anything below is ambiguous. The essentials:

- `00 innboks` — anything without an obvious home, cleared weekly.
- `10 fag/<fag>/fangst` — raw capture notes for an active course, never deleted or
  rewritten, only appended to (the "Konsepter å trekke ut" checklist).
- `20 notater` — atomic concept notes. Frontmatter `type: konsept`,
  `fagområde: [slug, ...]` (an array, a note can belong to several), optional
  `aliases:` for the English term. Body: prose from memory, `[[links]]` to related
  concepts, math as LaTeX (`$...$` / `$$...$$`, LaTeX Suite plugin), ending in a
  `## Flashcards` section tagged `#flashcards/<fagområde>` with 2-4 `::`
  question/answer pairs (or multi-line with `?`).
- `30 kart/<fagområde>.md` — one MOC per fagområde, a Dataview query plus a short
  hand-picked list of key concepts. `fagområde:` values in `20 notater` are what
  tie a note to a kart.

## Procedure

### 1. Read the material

Read every fangst note being processed in full, including embedded images. A
formula or diagram screenshot is source material for LaTeX in the concept note, not
something to leave as an embed.

### 2. Quiz before writing anything

Before creating or touching a single concept note, quiz the user on the captured
material. Purpose: catch gaps and misunderstandings while the source is still fresh,
not after they're baked into a note.

- Ask 3-6 questions covering the candidate concepts in the capture, in one chat
  message, numbered.
- Ask the quiz questions in Norwegian, regardless of the capture note's source
  language. Feedback on the user's answers is also in Norwegian.
- Answerable directly in chat: recall, explain-in-your-own-words, or short
  calculation. Never require drawing, handwriting, or a diagram, unless the concept
  is genuinely impossible to test any other way.
- Stop and wait for the user's answers. Do not proceed to step 3 in the same turn.
- Give brief feedback per answer (correct / off in this specific way), don't just
  move on silently.

### 3. Let the quiz shape the notes

Write concept notes to reflect what the user actually demonstrated, not the raw
capture text. A correct-but-shaky answer may need the note to spell out the
distinction that tripped them up. A wrong answer means the note should state the
correct version plainly, mention the misconception is worth double-checking against
the source (slides, book) if you can't resolve it from the capture alone.

### 4. Reuse before creating

Before writing a new note, search `20 notater` for existing notes covering the same
or adjacent ground (grep title and content, not just filenames). Prefer extending an
existing note over creating a near-duplicate. Only make a new note for a concept that
genuinely isn't covered yet.

### 5. New fagområde: ask, don't assume

If the material doesn't fit any existing fagområde well, ask the user with a
concrete proposal (name it, name a couple of existing notes/fagområder it would
pull together) before creating a new `30 kart/<slug>.md` or tagging notes with it.
Use AskUserQuestion. If the user declines, place the concept notes under the
best-fitting existing fagområde(s) instead, don't leave them untagged.

### 6. Move the fangst note

Move the capture note into `10 fag/<fag>/fangst/` if it isn't already there. Fill in
its `## Konsepter å trekke ut` checklist: one line per candidate concept, checked off
with a link to where it landed (new note, extended existing note, or "not covered
yet, needs more source material" if the quiz or capture left a real gap).

### 7. Summarize

End with a short list: concept notes created, concept notes extended (and why,
briefly), fagområder touched, and any new fagområde created or declined.

## Rules

- Concept notes are always Norwegian, regardless of the source language. English
  terms become an `aliases:` entry.
- Never fabricate content the capture and quiz didn't establish. A term the user
  only listed without explaining stays unwritten, note it as still open in the
  fangst checklist instead.
- One concept per note. A capture note usually yields several concept notes, not one
  big one.
