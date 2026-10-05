---
name: kveldslesing
description: >
  Write an easy bedtime-reading PDF (20-40 phone-shaped dark pages) on the next concepts of a
  school course or personal topic in the obsidian-laeringshvelv vault, and drop it in Nextcloud
  so the user can read it on the phone. Not a study session: never touches the learner model,
  log, cards or læreplan status. Use when the user says "generer pdf om <tema>", "lag
  kveldslesing om <tema>", "noe å lese på senga om <tema>", "pdf om parallelle beregninger",
  often from Remote Control on the phone.
argument-hint: "<tema> [antall sider] [repeter]"
---

# Kveldslesing

Light reading for bed: clear technical explanations of the next things in a course or personal topic, in the style of *Operating Systems: Three Easy Pieces*.
It is not study.
No questions, no problems, no cards, and nothing that changes the study state.
The request may come from a phone through Remote Control, so ask nothing unless the topic cannot be resolved.

All user-facing text and the PDF itself are Norwegian bokmål.
Never use an em dash.

## Files (vault root: `~/Documents/obsidian-laeringshvelv`)

| File | Use |
|---|---|
| `_system/config.md` | Course table and "Personlige temaer" table: code, name, folder. Read only. |
| `10 fag/<fag>/læreplan.md`, `15 egne studier/<kode>/læreplan.md` | Units in order, concepts, sources, "Neste tema". Read only. |
| `_system/elevmodell.md` | What the user has met (level 1 or more). Read only. |
| `20 notater/<konsept>.md` | Concept notes: the main source for ingested units. Read only. |
| `10 fag/<fag>/forelesninger/forelesning <nr>.md` | Lecture metadata and slide numbers for units that are not ingested. |
| `_system/kveldslesing.md` | The reading log. The only vault file this skill writes. |
| `~/.cache/kveldslesing/<navn>/` | Working folder: `lesing.md`, figures, previews. |
| Kveldslesing folder (Stier in `config.md`) | Finished PDFs, synced to the phone. |

**Never write to** `elevmodell.md`, `logg.md`, cards, læreplan status or "Neste tema", lecture notes or concept notes.
Reading in bed tests nothing, so it raises no level and counts as no session.

## 1. Resolve the request

1. `date '+%F'`. Read `_system/config.md` and `_system/kveldslesing.md`.
2. Match the topic to a code: course code or name in Emner, code or name in Personlige temaer.
   Loose matches count: a word from a course or topic name gives that code.
   If nothing matches, or two codes match equally well, reply with the list of codes and names and stop.
3. Options in the request:
   - A page count ("30 sider"). Default 25, clamp to 20-40.
   - A specific subject inside the topic ("om CUDA i parallelle"): use the unit or units that cover it instead of the next ones.
   - `repeter`: re-explain the units of the latest PDF for this code from a new angle, with new problems and examples.

## 2. Choose the units

A unit is a row in the læreplan table: a lecture for a course, a module for a personal topic.
Reading ahead is allowed: lectures that are not held yet and modules that are not ingested both count.

1. **Start:** the first unit after the last unit logged for this code in `kveldslesing.md`.
   With no log entry, start at "Neste tema" in `læreplan.md`.
2. Walk the table in row order from the start.
   Skip units with status `lært`.
   Skip units with no topic text or a slide-only intro with no content.
3. Take whole units until the estimate reaches the page target.
   One page holds about 140 words once chapter breaks, code and figures are counted, so 25 pages is about 3 500 words.
   Plan 1 500-2 500 words per unit, and never split a unit across two PDFs.
   Fewer units explained well beat more units compressed: when in doubt, take one unit less.
4. If the table runs out, use what is left and say so in the reply.

## 3. Gather the material

Per unit, in this order:
1. Concept notes listed in the Konsepter column (`20 notater/`).
2. For a unit without notes: the sources in the Kilder column.
   Course slides and books: the course's source folder (Kilder in Stier in `config.md`), read with `/usr/bin/python3 _system/scripts/pdfverktoy.py tekst <pdf> [fra til]`, only the slides the lecture note lists.
   Personal topics: the anchor sources in `læreplan.md`, with WebFetch on the official docs pages, plus your own knowledge.
3. Check every version-specific fact (flags, defaults, API fields) against the source.
   Do not invent numbers, dates or names.

Keep a short list of the sources you used for the last page.

## 4. Known and new terms

The user must never meet an unexplained term.
A term counts as **known** when one of these is true:
- it has level 1 or more in `elevmodell.md` (any course, the model is shared),
- it is in "Forklart" for an earlier entry in `kveldslesing.md`.

Every other term is **new**: every concept, abbreviation, symbol, flag, command, component and proper name.
- Explain a new term in plain words the first time it appears, before you use it for anything.
  Explain abbreviations word by word ("MPI, Message Passing Interface: et grensesnitt for å sende meldinger mellom prosesser").
- Explain prerequisite terms from earlier units that the user has not met yet the same way, or give them a short opening chapter.
- A known term may get a half-sentence reminder when it has not appeared for a while.
- Read your draft once only for this: every term is either known or explained earlier in this PDF.

## 5. Write

Write `~/.cache/kveldslesing/<dato>-<kode>/lesing.md` (Pandoc Markdown).

Read `references/skrivestil.md` first and follow it.
In short: each chapter starts with the problem, then the naive attempt, why it fails, the real mechanism and a real example.
Use the terms practitioners use, one name per thing, mechanism before metaphor, and one mechanism per sentence.

**Tone:** a calm, curious explainer for someone tired in bed, like OSTEP: personal "vi", some humour, honest about simplifications.
When the "Kveldslesing" table in `config.md` lists an example source for the code, use examples from it when they fit.
No exercises, no quiz, no "test deg selv", no summaries in bullet form after every section.

**Structure:**
- YAML header: `title` (an inviting title, not the lecture name), `subtitle` (`<KODE eller tema> · <enheter>`, for example `ABC1234 · T3-T5`), `date` (for example `6. oktober 2026`), `abstract` (one or two sentences on what the reader will understand afterwards), `lang: nb`.
- One `#` chapter per main idea (each starts on a new page), opening with `> **Problemet:** <one question>`. `##` for sections. Max one level below.
- Analogies, side notes, history and tips go in a blockquote with a bold label: `> **Analogi:**`, `> **Side:**`, `> **Historie:**`, `> **Tips:**`. At most one analogy per chapter.
- Code blocks short: max ~12 lines and max 38 characters per line including indentation, because longer lines wrap on the 90 mm page.
- Tables max 3 narrow columns. Wider content becomes a list.
- Math with `$...$` only where the formula is the point, with every symbol explained in words.
- Last chapter `# Kilder`: one line per source.
- No Obsidian syntax (`[[...]]`, callouts, embeds).

**Figures (optional, 0-4):** only where a picture shows something faster than a paragraph (a process, a layout, a comparison).
Write SVG files next to `lesing.md` and embed them with `![Bildetekst](figur.svg)`.
The page is dark: transparent background, strokes and text in `#d8d0c2`, highlights in `#d9a75f`, fills at most `#262420`, font `Noto Sans`, text at least 13 px at a 300 px width, lines at least 1.5 px.

**Review pass:** before you build, spawn one `general-purpose` agent as the reader.
Give it the path to `lesing.md`, the path to `references/skrivestil.md`, and the list of known terms from step 4.
Ask it to check the draft against the review checklist in `skrivestil.md` and return findings, each with the quoted sentence and a proposed rewrite.
Fix every finding, or decide in one line why it is not a problem.

## 6. Build and check

The PDF goes straight to the kveldslesing folder as `<dato>-<kode>-<enheter>.pdf`, for example `2026-10-06-ABC1234-T3-T5.pdf`:

```
/usr/bin/python3 <skill-mappe>/scripts/build.py <arbeidsmappe>/lesing.md --out <kveldslesing-mappe>/<filnavn>.pdf --preview <arbeidsmappe>/forhandsvisning
```

The script prints pages and words.
- Below 20 pages: add depth or examples to the units you have, or add the next whole unit, and rebuild.
- Above 40 pages: drop the last unit and rebuild. Never compress the text to make it fit.
- Look at the cover, every page with a figure, table or code block, and 3 random text pages from the preview.
  Fix anything that looks wrong and rebuild: overflowing code, a cramped table, a figure that is unreadable on the dark page, an almost empty page before a chapter.

## 7. Log and deliver

1. Append to `_system/kveldslesing.md` (create it from the header below if missing):

   ```
   ## <dato> - <kode> <enheter>

   - Fil: `<filnavn>.pdf` (<sider> sider)
   - Enheter: <nr og tema per enhet>
   - Forklart: <every term this PDF explained as new, comma-separated>
   ```

2. Load the `PushNotification` tool with ToolSearch and send: `Kveldslesing klar: <tittel> (<sider> sider)`.
   If the tool is unavailable, skip it.
3. Reply in two lines: the title and units, and where the file is (the kveldslesing folder and `<filnavn>.pdf`).

Header for a new `_system/kveldslesing.md`:

```
---
type: meta
---
# Kveldslesing

Logg over PDF-er fra skillen `kveldslesing`.
Loggen styrer bare hvor neste PDF starter og hvilke begreper som er forklart.
Den teller ikke som studie og påvirker ikke elevmodellen.
```
