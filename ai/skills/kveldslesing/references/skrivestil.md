# Writing style

The goal is the style of *Operating Systems: Three Easy Pieces* (OSTEP): each chapter starts from a real problem, builds the mechanism step by step, and shows real output.
The discipline comes from controlled technical writing (ASD-STE100, S1000D): one name per thing, short sentences, one kind of content per block.
It must still read like a calm book, not a manual.

Read this file before you write, and again during the review pass.

## Core points

### 1. Start every chapter with the problem

Open each `#` chapter with the problem as one question in a blockquote:

```
> **Problemet:** Maskinen har åtte CPU-kjerner, men kjører hundrevis av programmer. Hvordan kan hvert program oppføre seg som om det har maskinen for seg selv?
```

Then follow this arc:
1. The naive attempt: the obvious solution.
2. Why it fails: a concrete case where it breaks.
3. The real mechanism, one step at a time.
4. A real example that shows the mechanism at work (point 5).

Everything in the chapter answers the question.
Text that does not answer it belongs in another chapter or nowhere.

### 2. Use the word practitioners use

Use the term a Norwegian developer or the course actually uses.
When that term is English, write the English term.
Never invent a Norwegian translation to sound Norwegian.

| Write | Never |
|---|---|
| stack, heap | stabel, haug |
| fork bomb | gaffelbombe |
| throttling | struping |
| namespace | navnerom (except once, to explain the word) |
| page cache | sidehurtigbuffer |

Norwegian is right where it is the normal word: prosess, kjerne, minne, tråd, signal, exit-kode.
The course's own vocabulary wins for school courses: use the slide terms.

### 3. One name per thing

Define a term once, in bold, with the abbreviation spelled out word by word.
After that, use exactly that word every time.
A metaphor is never a synonym for the term.

- Bad: "et kort i kartoteket sitt, prosesskontrollblokken, PCB" (three names in one sentence).
- Good: "Kjernen lagrer opplysningene om hver prosess i en datastruktur som heter **PCB** (process control block)."

### 4. Mechanism before metaphor

Explain the mechanism first, in plain technical words.
An analogy is allowed only after that, at most one per chapter, in a `> **Analogi:**` block.
Keep an analogy only when you can say what each part maps to and where the mapping breaks.
If it only decorates, delete it.

- Bad: "Et program er en fil på disken, som en oppskrift i en kokebok. En prosess er det som skjer når noen faktisk lager retten."
- Good: "Et program er en fil på disken. Det gjør ingenting før kjernen laster det inn i minnet og starter det. Et program som kjører, heter en **prosess**."

### 5. Show real output

Run the commands on this machine and paste the real output, cut to the lines that matter.
Then explain what to notice in it.
This is how OSTEP teaches `fork()`: a small program, its real output, then the explanation.

- Use only commands that need no `sudo`. The request may come from a phone, where nobody can approve a password prompt.
- Cut long output with `...` and keep each line within 38 characters.
- When a command cannot run here (it needs root, a cluster or a missing tool), write the example and say so in the text: "Utdata ser omtrent slik ut:".
- Never present invented output as real.

### 6. One mechanism per sentence

A sentence carries one idea.
Keep sentences under 25 words and paragraphs under 6 sentences.

- Bad: "Kjernen laster koden inn i minnet, setter av en stabel, gir programmet åpne filer for inn- og utdata, og lar CPU-en kjøre instruksjonene." (four mechanisms, none explained).
- Good: explain the mechanisms that matter in this chapter, one per sentence, and leave out the rest.

When something really is a sequence of steps, use a numbered list.

### 7. Precise, not cute

Every sentence must say something exact.
Test: could the sentence be the answer on a flashcard?

- Bad: "det er nettopp dette tallet en container lyver om", "død, men ikke begravd".
- Good: "Inne i en container har prosessen en annen PID enn den har på verten."

Humour and a personal "vi" are welcome, as in OSTEP.
Wordplay that replaces the explanation is not.

### 8. One kind of content per block

Keep the information types apart, as in S1000D:

| Block | Form |
|---|---|
| Explanation | Prose paragraphs |
| Example | Code block with real output, then one paragraph on what to notice |
| Exact values | A small table (max 3 columns) |
| Side note, history, tip | `> **Side:**`, `> **Historie:**` or `> **Tips:**` |

Do not hide flags or default values inside a long paragraph.
Do not put explanation inside a table.

### 9. Depth before coverage

Explain fewer units well rather than many units compressed.
If the draft is too long, drop the last unit and keep it for the next PDF.
Never shorten sentences or merge chapters to make more material fit.

## Review pass

After the draft, run a reader review before you build (step 5 in `SKILL.md`).
The reviewer gets this checklist:

- [ ] Every chapter opens with `> **Problemet:**` and the chapter answers it.
- [ ] No invented Norwegian translation of a term practitioners say in English.
- [ ] Every term has exactly one name in the whole PDF.
- [ ] Every new term is defined before it is used.
- [ ] No analogy comes before the mechanism, and no chapter has more than one.
- [ ] Every output block is real, or the text says that it is an example.
- [ ] No sentence is over 25 words or holds more than one mechanism.
- [ ] No cute phrase without exact content.
- [ ] No flags or values hidden in prose that belong in a table or code block.

The reviewer returns a list of findings with the quoted sentence and a proposed rewrite.
Fix every finding, or note in one line why it is not a problem.
