---
name: homework-pdf
description: >
  Turn a Markdown homework note (Obsidian or plain .md) into a neat, submission-ready PDF,
  with questions and answers laid out cleanly, math typeset and every embedded image included.
  Reviews the answers first and flags anything badly wrong or unanswered before building the PDF,
  and never changes the user's wording.
  Use this whenever the user wants to hand in, submit or print homework, an øving, exercise,
  assignment, lab report or innlevering written in Markdown, even if they only say
  "make a pdf of exercise 6", "gjør om øvingen til pdf", "lag pdf for innlevering",
  "export my answers" or point at a file in an øvinger folder.
---

# Homework to PDF

The user writes homework answers in Markdown, usually in their Obsidian vault at `~/Documents/obsidian-laeringshvelv` (`10 fag/<course>/øvinger/<name>.md`, attachments in `90 vedlegg`).
This skill turns such a note into a clean PDF they can hand in.

The deliverable is the user's own work, so two things matter more than anything else:

- **The wording is theirs.** Change style and structure only: headings, numbering, spacing, where a question ends and an answer starts, what gets dropped as private notes. Never fix, rephrase, complete or "improve" a sentence, not even a typo, unless the user explicitly asks for that specific change. A teacher grading this must see what the student wrote.
- **Nothing silently goes missing.** Every image in the answers ends up in the PDF, and every answer ends up in the PDF.

## Workflow

### 1. Read the note

Read the whole note.
Also open the embedded images that belong to answers (use the Read tool on the image files), because a "draw a diagram" answer that is only an image can still be missing parts, and a plot can contradict the text.

Work out:

- **Are the questions in the note?** If the note contains the task text (e.g. "1. Explain how ..."), the PDF shows each question followed by its answer. If the note contains only answers (e.g. headings like "Oppgave 1a" followed by prose), the PDF contains only the answers, keeping the user's own labels.
- **What is not part of the submission.** In this vault that is typically: YAML frontmatter, the `## Plan` checklist written by the `oving` skill, the `## Ting jeg lærte (kandidater til konseptnotater)` section, a bare `## Oppgaver` wrapper heading, links to the assignment PDF like `[[exercise_1.pdf]]`, progress notes to self ("Er på oppgave 1a 5/6", "TODO", "husk å ..."), and empty list items. Dropping these is a structural change, so it is allowed, but list what you drop in the final report. If you are unsure whether something is a note to self or part of an answer, keep it and ask.

### 2. Review the answers and give a heads-up before building

Check the answers the way a strict but fair teaching assistant would, looking only for problems worth interrupting the user for:

- a question or sub-question with no answer, or an answer that only covers part of what was asked (asked for three advantages, gave one; asked to "explain" and "list mistakes", only the drawing is there)
- an answer that is clearly factually wrong, or a calculation that does not check out (redo the arithmetic)
- an answer that answers a different question, or contradicts another answer or its own figure
- leftover draft material that would look odd to a grader (notes to self, "??", half sentences), and any `<!-- UTKAST -->` marker, which means a draft the user has not gone through yet
- an embedded image that cannot be found

Do not flag style, tone, debatable judgement calls or minor wording.
Obvious typos can be mentioned together in one short line at the end, since the user may want to fix them, but never fix them yourself.

If you found problems, **stop before building the PDF** and tell the user.
For each item: where it is (section and question), what is wrong in one or two sentences, and why it matters.
Then let the user decide per item: keep it as it is, or change it (they edit the note themselves, or tell you exactly what to change).
If nothing is worth flagging, say so in one line and continue without stopping.

### 3. Settle the header

The PDF has one of two header styles:

- **plain**: just the title
- **full**: title, then name on the left and date on the right

Use what the user asked for.
If they did not say, ask (together with the heads-up from step 2 if there is one, so they only get interrupted once).
For the full header, ask for the name every time; do not guess it from the git config, email or file paths.
Use today's date, written in the language of the note (`30. september 2026` for Norwegian, `30 September 2026` for English), unless the user gives another date.
The title defaults to the note's file name ("Exercise 6", "Øving 3"); use a better one if the user or the note gives it.

### 4. Write the submission Markdown

Create a working copy in the scratchpad directory (or a temp directory) and restructure it.
Start from a copy of the note (`cp`) and edit it, rather than retyping it, so the wording cannot drift.

Structure to aim for:

````markdown
---
title: Exercise 6
author: Full Name        # omit author and date for the plain header
date: 30 September 2026
lang: en                 # nb for Norwegian, used for hyphenation
---

::: {.question number="1.1"}
Consider a system with a two-level cache hierarchy ... What is the average memory latency?
:::

$$
(0.9 \cdot 1 + (0.1 \cdot 0.6) \cdot 10 + (0.1 \cdot 0.4) \cdot 100) = 5.5 \text{ cycles}
$$

::: {.question number="1.2"}
For the above system, plot average memory latency ...
:::

![[Pasted image 20260929183745.png]]

The lower the L1 hit rat is, ...

::: {.question number="4.1"}
Explain how TLB is used to translate a virtual address to a physical address.
:::

A TLB is used to cache ... Below is the TLB control flow algorithm

::: {.transcribed src="Pasted image 20260929191235.png"}
```
VPN = (VirtualAddress & VPN_MASK) >> SHIFT
(Success, TlbEntry) = TLB_Lookup(VPN)
...every line of the screenshot, exactly...
```
:::
````

**Questions.**
Wrap each question in a `::: {.question number="..."}` block.
It renders in semibold with a hanging number, and is kept on the same page as the start of its answer.
Leave out the `number` attribute if the question has no number.

**No section headings or points.**
Show only the question number and the question text: drop section and part headings ("Section 2: Dynamic Branch Prediction (4 points)") and point values.
Carry the section into the number instead when numbering restarts per section: question 1 of section 2 becomes `2.1`, and a sub-question becomes `2.1a` if the note uses letters.
If a section has intro text that the questions depend on (a shared scenario, a table, "Program A"), keep that text as a plain paragraph before its first question; only the heading line itself goes.
In an answers-only note, the user's own labels ("Oppgave 1", "a)") are the question numbers: keep them as the labels, not as section headings with extra titles.

**Answers.**
Put the answer after the question block as normal paragraphs, lists, math, code and images.
Obsidian notes often nest the answer as a sub-item under the question (`1. question` then `\t1. answer`); un-nest it so the answer is ordinary text.
When an answer has several parts, a bullet list reads better than `1. 2. 3.`, unless the numbers map to parts of the question.

**Math as LaTeX.**
Calculations and formulas written as plain text (`(0.9 * 1 + ...) = 5.5 cycles`, `log2(256) = 8`, `32KB / 32B = 1024 blocks`, `19 bits * 1024 blocks`) look sloppy in a PDF, so typeset them as LaTeX math.
This is typesetting, not rewording: keep every number, variable, unit and word, in the same order.
Map symbols one to one: `*` becomes `\cdot`, `log2(x)` becomes `\log_2(x)`, `a / b` may become `\frac{a}{b}`, `->` between quantities becomes `\to`, `<=` becomes `\le`, and units or words inside math go in `\text{...}`.
Never add steps, simplify, or "correct" a result while doing this; a wrong number stays wrong (it should already have been flagged in step 2).
A calculation on its own line becomes display math (`$$ ... $$`); an expression inside a sentence becomes inline math (`$...$`) with the surrounding prose left as prose.
Arrows in prose that are not math ("virtual address -> physical page") stay as they are.

**Images that are only text or code.**
A screenshot of code, pseudo-code, terminal output, a formula or plain text reads and prints much better as real text, so transcribe it instead of embedding the image.
Open the image, copy its content exactly, character by character (keep the identifiers, spacing and comments; drop only editor line numbers in the gutter), and put it in a `::: {.transcribed src="<image file name>"}` block, as a fenced code block for code and pseudo-code, a `$$ ... $$` block for a formula, or plain paragraphs for prose.
The `src` tells the wording check that the image is accounted for.
Afterwards, compare your transcription against the image once more, line by line.
Keep as images: diagrams, plots, drawings, handwriting, tables with visual layout, and anything that mixes text with graphics.
When in doubt, keep the image.
List every transcribed image in the final report so the user can check it.

**Other structure.**
- Fix structural slips: numbering that restarts or repeats (1, 1, 2 becomes 1, 2, 3), stray indentation that turns a paragraph into a code block. Mention numbering fixes in the report.
- Keep Obsidian syntax for images (`![[file.png]]`, `![[file.png|400]]`) and math (`$...$`, `$$...$$`); the build script resolves them.
- Keep the order of the note. Do not move an answer to a different question, even if it looks misplaced; flag it in step 2 instead.

### 5. Verify the wording, then build

Run the wording check against the original note:

```bash
python3 <skill-dir>/scripts/check_wording.py "<note.md>" "<submission.md>"
```

It compares runs of letters and digits with all Markdown, numbering and pure-typesetting LaTeX (`\cdot`, `\frac`, `\text`, ...) stripped, and skips transcribed blocks.
`ADDED` must be empty: anything there is wording you introduced, so undo it.
`REMOVED` must contain only what you meant to drop (private notes, the learning section, section headings and points, etc.).
`IMAGES MISSING` must be empty unless the user agreed to leave an image out.

Then build:

```bash
python3 <skill-dir>/scripts/build.py "<submission.md>" --source "<note.md>" --out "<note folder>/<note name>.pdf"
```

`--source` is the original note; the script uses its location to find images the way Obsidian does (next to the note, relative to the vault, or by file name anywhere in the vault).
It refuses to build if any image is missing, and lists the images it embedded.
Excalidraw embeds only work if the Excalidraw plugin has auto-exported a PNG or SVG next to the drawing; if not, ask the user to export it.
Remote images (`https://...`) are not downloaded; ask the user for a local copy.

Save the PDF next to the note with the note's name, e.g. `exercise 6.md` becomes `exercise 6.pdf`.
If that file already exists, look at what it is first (`pdftotext -l 1`): it may be the assignment sheet, not an earlier export. Ask before overwriting.

### 6. Look at the result

Render the pages and look at every one of them before handing over:

```bash
pdftoppm -r 70 -png "<out.pdf>" /path/to/scratch/page
```

Check that each image from the note appears (or its transcription), questions and answers are clearly separated, math rendered (not raw `$...$`, and no plain-text calculations left), nothing is cut off, and no heading or question sits alone at the bottom of a page.
Fix structural problems in the submission Markdown and rebuild; do not work around them by editing text.

### 7. Report

Tell the user briefly:

- where the PDF is and how many pages it has
- what you dropped as not part of the submission
- structural fixes worth knowing about (renumbering, headings)
- which images you transcribed to text or code
- which flagged items from step 2 are still in the PDF because they chose to keep them
