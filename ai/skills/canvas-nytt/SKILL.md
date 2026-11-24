---
name: canvas-nytt
description: >
  Bring the obsidian-laeringshvelv vault up to date with the news file that canvas-henter writes
  after each fetch (new or changed announcements, assignments, pages, files and course-website
  pages): exam facts, deadlines and lecture plans, each course's source index (exams, exercises,
  aids, syllabus books), ingesting held lectures whose slides arrived, mapping old exams into the
  exam map, searching the web for old exams Canvas lacks, and questions left for the next session.
  Run without a user by `studie canvas`, which canvas-henter starts after every fetch, and by `okt`
  at startup when news is still unprocessed. Use also when the user says
  "behandle canvas-nytt", "oppdater hvelvet fra Canvas" or "ta inn det nye fra Canvas".
---

# Canvas-nytt

After this run, the vault says what Canvas and the course websites say, so the next session starts from reality and spends no time on it.
All text written to the vault is Norwegian bokmål. Never use an em dash.
Paths come from Stier in `_system/config.md`: "Nytt fra Canvas" (the news file), "Canvas-kopi" (the course's copy, `canvas/` in its Nextcloud folder) and "Kildeoversikt" (`kilder.md` per course).

## 0. Guards

1. Read the news file and run `/usr/bin/python3 _system/scripts/eksamensdekning.py`. If the file has no dated sections (`## <yyyy-mm-dd hh:mm>`) and the script prints nothing, print `Ingenting nytt fra Canvas.` and stop.
2. If `_system/logg.md` has a block for a course in the Emner table with `Slutt: uavsluttet` that started less than 3 hours ago, a session is running. Print `En økt pågår, så okt tar det nye fra Canvas ved neste oppstart.` and stop: two writers to `elevmodell.md` and the læreplan lose each other's changes.
3. Nobody may be there to answer. Never ask a question. Anything that needs the user goes under `## Venter på deg` in the news file (step 6). This includes questions that a hook asks you to put to the user.

## 1. Read

- `_system/config.md`, the study plan (Studieplan in Stier) and `_system/beslutninger.md` (only the sections that name a course with news).
- Per course with news: `10 fag/<fag>/læreplan.md`, `kilder.md` and `eksamenskart.md` if they exist.
- The items. Each item has the path of the full file in the course folder named above it. Read the full file for every announcement, page, syllabus and website page: excerpts can miss the one sentence that matters. Files (PDFs) are read only as steps 3 and 4 need.

## 2. Facts

Change a fact only where the source states it. Write it in the vault's words, with the source in parentheses when the place has a source convention.

| News about | Update |
|---|---|
| Exam date, time, room, duration, aids, format, point split, what the exam covers | The course's row in Emner and its line in "Eksamensform og hjelpemidler" in `config.md`, and the exam table in the study plan |
| Deadlines, mandatory work, approval rules, grades | The list of mandatory work in the study plan. A graded item updates its approval status |
| Cancelled, moved or added lectures, syllabus exclusions | `læreplan.md` |
| Syllabus books and other required reading | Pensum in `kilder.md` (step 3) |
| Practical messages, own submissions, discussions without these facts | Nothing |

Never apply an item that contradicts a decision in `beslutninger.md`, or that changes the study plan's periods or rules beyond a fact. Put it under `## Venter på deg` with the source.

## 3. The source index

`10 fag/<fag>/kilder.md` lists every source of a course except lecture slides, which live in the Kilder column of `læreplan.md`.
Every path is relative to the course's Nextcloud folder, so files in the Canvas copy start with `canvas/`.
Create the file from this template when it is missing:

```markdown
---
type: meta
emne: <emne>
---
# Kilder <emne>

Emnets kilder utenom forelesningsslides, som står i Kilder-kolonnen i [[læreplan]].
Stiene er relative til emnets Nextcloud-mappe, og `canvas/` er kopien fra Canvas og emnets nettsider.
`canvas-nytt` holder oversikten oppdatert etter hver henting.

## Pensum

| Kilde | Hva | Fil |
|---|---|---|

## Eksamener

| Eksamen | Oppgaver | Løsning |
|---|---|---|

## Øvinger

| Øving | Oppgave | Løsningsforslag |
|---|---|---|

## Hjelpemidler

| Hjelpemiddel | Fil |
|---|---|
```

- **Pensum:** one row per book or note set the course names as syllabus (in `emneplan.md`, a page, the course website). Fil is its path in `bøker/` or the Canvas copy, or `mangler`. The user downloads books themselves: for each new `mangler` row, add `- <emne>: last ned «<tittel>» til bøker/ (pensum ifølge <kilde>)` under `## Venter på deg`. A book that appears in `bøker/` later gets its path.
- **Eksamener:** one row per old exam, labelled `<år>-<H|V>[-kont]` as in `eksamenskart.md`, with the task file and the solution file (`-` when there is none). A new exam also gets its rows in `eksamenskart.md`, as `innta` describes.
- **Øvinger:** one row per exercise set: the task text (the assignment's `canvas/oppgaver/<navn>/oppgave.md` or a file) and the solution when one is published. The user's own work stays in `øvinger/` and is not listed.
- **Hjelpemidler:** the files the user may bring or gets at the exam (formula sheets, quick references).

## 4. Lecture material

- **New material:** find the lecture's row in `læreplan.md` by number, title or date, using `canvas/moduler.md` and `canvas/nettsider.md` for the course's own order. Add the path to the Kilder column.
- **Ingest held lectures now:** when the course is active (Aktiv fra in Emner is `nå` or today or earlier), the lecture is held (Dato is today or earlier), its status is `ikke innlest` and its slides are now in the Kilder column, run the `innta` skill's procedure on it. At most 4 lectures per run, highest exam weight first. The rest keep status `ikke innlest` with their sources in place, and `okt` ingests them when they are chosen.
  Skip this bullet when `okt` runs this procedure at startup: the session ingests what it teaches.
- **Changed source** that is already `innlest`, `forklart` or `lært`: read the new version (text first with `pdfverktoy.py tekst`, page images only for the pages that changed), and add what the concept notes lack, as `innta` step 3 says. When an added fact belongs to a concept at level 2 or more, set its Neste tiltak in `elevmodell.md` to `repeter: kilden er oppdatert (<hva>)`.
- **Moved file** (`flyttet`, with the old path in parentheses): replace the old path with the new one in every vault file that names it, except `_system/logg.md` and `_system/beslutninger.md`, which are history.
- **Removed files** need nothing: the local copy stays.

## 5. Exams

`eksamensdekning.py` (step 0) lists exams that Eksamener in `kilder.md` has and `eksamenskart.md` lacks, and courses where a search for exams outside Canvas is due.
Skip this step when `okt` runs this procedure at startup: the session needs the time.

**Map missing exams:** at most 2 per run, the course with the nearest exam first, then the newest exam.
Add the rows as `innta` describes under "Eksamenskart", with the exam's row under Faglærere, and update the sums of points per lecture under the table.
A kart without the Faglærere section gets it first, filled for every exam it maps, as one of the 2 exams of the run.
When news names a new course coordinator or lecturer, update "I år" under Faglærere and the Samme som i år column, and mention a change of lecturer in the report.
Read the task text with `pdfverktoy.py tekst`, and page images only where the text is unclear.
An exam that cannot be mapped (scanned, solutions without the tasks, another course) gets one line in the kart's header saying why, such as `2016-H er skannet og ikke kartlagt`, so the check stops listing it.
Never change the Status of existing rows.

**Search for exams outside Canvas:** for each course the script names, look for the missing years with WebSearch:
`"<Emnekode>" eksamen <år>`, `"<Emnekode>" exam <år> pdf` and `site:ntnu.no "<Emnekode>" eksamen`.
- Use only public pages that need no login, account or payment: NTNU course pages and department wikis, the course's earlier course websites, and open student archives. Never a page behind Feide or another login.
- Confirm each find with WebFetch: the PDF must be this course's exam or its solution, for the year it claims.
- Register each confirmed PDF with `canvas-henter nettside <Emnekode> <PDF-URL>`. Use the PDF's own URL, not the page that lists it, so the next fetch copies that one file and not a whole website. The file then arrives as news, and step 3 adds it to Eksamener.
- Write or replace one line right under the Eksamener table: `Søkt etter eksamener utenfor Canvas: <dato> (<what was found, or ingen nye>)`. The script waits 30 days before it asks again.

## 6. Log

Append one block to `_system/logg.md`:

```
## <dato> <tid> canvas-nytt
Slutt: <tid>
Hendelser:
- canvas: <what changed where> (<emne>, <kildefil>)
- innlest: <emne> <forelesning>
- eksamenskart: <emne> <eksamen>, <n> oppgaver
- eksamenssøk: <emne>, <what was found>
```

## 7. Clean up the news file

Delete every dated section you processed.
Keep the header, the frontmatter and `## Venter på deg`. Create that section when you have something for it, with one line per question: `- <emne>: <spørsmålet> (kilde: <fil>)`.
`okt` asks these at startup and deletes each line when it is answered.
A line that starts with `canvas-henter:` belongs to `canvas-henter`, which removes it itself.

## 8. Report

End with at most 8 lines of plain text, no Markdown tables: per course, what changed in the vault, what was ingested, which exams were mapped or found, then the number of lines under `Venter på deg`.
`studie canvas` prints it in the terminal after the fetch report.
