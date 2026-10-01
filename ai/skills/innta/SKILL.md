---
name: innta
description: >
  Ingest course sources (lecture slides, book chapters, notes as PDF) into the
  obsidian-laeringshvelv vault as short atomic concept notes with cropped figures, and file the
  PDF in Nextcloud. Called by `okt` at startup (new PDFs in ~/Downloads) or when the next
  lecture in læreplan.md is not ingested. Use also when the user says "les inn", "innta" or
  gives a PDF to ingest.
argument-hint: "[pdf-sti eller emnekode forelesning]"
---

# Innta

Turn a source into concept notes once, so the source never has to be read again.
Concept notes are infrastructure for flashcards, for Claude's context and as targets for the learner model. The user does not read them, so they are short, not textbook prose.

All user-facing text and notes are Norwegian bokmål, with the English term in parentheses. Never use an em dash.
Paths and course table: `_system/config.md`.

## 1. Find sources and course

- From `okt` startup: `/usr/bin/python3 _system/scripts/pdfverktoy.py nye`.
- From the læreplan: the lecture's sources (Kilder column) in `~/Nextcloud/skole/ntnu/<mappe>/`. For a book, only the chapter pages the lecture covers (find them in the table of contents with `pdfverktoy.py tekst <pdf> 1 20`).
- Derive the course from the file name and the first page. Ask only if it is ambiguous. Skip non-course PDFs (receipts, shipping labels) silently.
- TDT4136: skip sections listed as not in the syllabus in `10 fag/intro ai/læreplan.md`.

## 2. Read the pages as images

All PDF work goes through `/usr/bin/python3 _system/scripts/pdfverktoy.py` (run it without arguments for usage). It is the only tool this skill needs permission for.
```bash
/usr/bin/python3 _system/scripts/pdfverktoy.py sider "<pdf>" [FRA TIL]    # prints the folder with s-NN.png at 150 dpi
/usr/bin/python3 _system/scripts/pdfverktoy.py bilder "<pdf>" [FRA TIL]   # embedded raster images
```
Read the page images, not just extracted text: formulas, diagrams and tables live there. Use `pdfverktoy.py tekst` only as a helper for long text.

## 3. Split into concepts

One concept per note: something the user must be able to define, apply or recognize on the exam.
Before creating a note, check `20 notater/` (file names and `aliases:`) for an existing note on the same concept:
- It exists: add only what is missing (figure, formula, source line, `emner:` entry). Do not rewrite the user's text.
- It does not exist: create it.

## 4. Figures

For each figure worth keeping: decide the crop box (pixels) on the 150 dpi page image, then:
```bash
/usr/bin/python3 _system/scripts/pdfverktoy.py beskjaer <side.png> X0 Y0 X1 Y1 <EMNE> <navn>
```
This writes `90 vedlegg/figurer/<EMNE>/<navn>.webp`.
Never a whole page unless the whole page is the figure. File names: lowercase Norwegian, hyphenated, descriptive (`samlebånd-fem-steg.webp`). Look at the result image to check the crop.

## 5. Write concept notes (aim for 10-25 lines)

File: `20 notater/<norsk tittel>.md` (lowercase, Norwegian, linkable).

```markdown
---
type: konsept
fagområde: [<eksisterende fagområde-slug>]
emner: [<EMNEKODE>]
aliases:
  - <english term>
---
<Definisjon i 1-3 setninger, med emnets notasjon og engelsk fagterm i parentes.>

<Nøkkelformel eller nøkkelresultat, i $...$ eller $$...$$.>

![[<figur>.webp]]

**Fallgruver:** <typiske misforståelser, bare hvis kilden eller gamle eksamener viser dem>

**Kilde:** <filnavn i Nextcloud>, s. <side>

## Med mine ord

## Relevante lenker
[[<beslektet konsept>]]

## Flashcards
#flashcards-vent/<domene>
```

- Content is only: definition, key formula or result, figure(s), pitfalls, source. No textbook-style explanations.
- `fagområde` uses existing slugs (see `30 kart/` and `_system/config.md`). Ask before introducing a new one.
- The flashcard tag domain is the note's first fagområde with spaces as hyphens, and always `#flashcards-vent/` for new notes.
- **Do not write cards.** `kort` does that when the concept is learned.

## 6. File the source in Nextcloud

For PDFs from `~/Downloads`:
1. Name it by the user's scheme: `<EMNE>-F<NN>-<pre|inclass>-<norsk-tema>.pdf` for lectures (`TDT4258-F05-pre-hurtigbuffer-og-virtuelt-minne.pdf`), `Ø<NN>` for exercise lectures, `G<NN>` for guest lectures. Exams: `<EMNE>-<år>-<H|V>[-kont][-l].pdf`, where `-l` is the solution.
2. **Copy** it with `pdfverktoy.py kopier "<pdf>" <mappe>/<slides|bøker|øvinger|eksamener|notater> <nytt-navn>.pdf`. It refuses to overwrite.
3. At the end, show one summary line per file (`gammelt navn → ny sti`) and ask: `Slette originalene fra Downloads? (skriv ja)`. Delete (`rm`) only after the user confirms. This asks for permission, on purpose.

## 7. Update state

- `10 fag/<fag>/læreplan.md`: add the new concepts to the lecture's row, set status `innlest`, and add `innlest: <fil> s. x-y` to the Kilder column.
- `_system/elevmodell.md`: one new row per new concept: level 0, next action `forklar i økt (pretest først)`.
- If you processed PDFs from Downloads: `pdfverktoy.py marker`.
- Delete the page images: `pdfverktoy.py rydd`.

## 8. Never reread

A source recorded as `innlest` in læreplan.md is never read again in later sessions. Use the notes.
