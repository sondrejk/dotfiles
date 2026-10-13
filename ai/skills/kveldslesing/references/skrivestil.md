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
3. The real mechanism, shown first on a concrete case and only then stated as a general rule.
4. A real example that shows the mechanism at work (point 5).
5. A contrast with a near miss, and the misconceptions this concept attracts (point 10).
6. A closing `> **Tenk på dette:**` question that the next chapter answers.

Before the mechanism, let the reader commit to a guess when the result is not obvious: "Hva tror du skjer med telleren nå?"
Answer it in the next paragraph or behind a page break, never leave it hanging.

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

### 10. Teach for learning, not only for understanding

Clear prose feels good to read but fades fast.
These points come from research on how people learn from text, and each has a concrete form in the PDF.

| Principle | What the PDF does |
|---|---|
| Problem before concept | `Problemet:` first, the term only once the reader needs it |
| Concrete before abstract | a fully worked case, then the general rule or formula; never a rule list first |
| Prediction before answer | a guess before the mechanism, answers after a page break or the next chapter break |
| Worked example, then fading | full example with named steps, then one step left out, then the whole thing to the reader |
| Contrast and near misses | the concept next to something that looks alike, with the difference named |
| Refute misconceptions | `Vanlig feil:` states the wrong belief, why it is tempting, why it is wrong |
| Linked representations | prose, figure, code and formula for the same thing, with the links named |
| No redundancy | a figure's title, caption and the prose never say the same thing twice |
| State over time | snapshots for every walkthrough of a procedure, not only the first |
| Spaced retrieval | `# Fra sist` asks about the previous PDF before anything new |
| Retrieval, not rereading | `# Kart` lists terms to recall, definitions behind a page break |
| One running example | a single case that later chapters extend |
| Pre-training | names and parts of the system before the mechanism that uses them |
| Signal the hard part | `Vanskelig:` on the step readers get stuck on |
| Layered depth | exam weight on every chapter, core first, `Stopp her hvis du er trøtt` after it, `(fordypning)` sections |
| Orientation | abstract says what the reader can do afterwards, `# Kart` ties it to the rest |

Keep questions few and specific.
A question that asks for one value or one choice works better than an open "forklar hvorfor", which tires a reader in bed and can hurt more than it helps.

Name the steps of a procedure by their purpose, not their content: "Steg 2: oppdater α" says what the step is for, so the reader can reuse it on a new problem.

A worked example helps a novice and gets in the way of someone who already knows the procedure.
When the learner model shows level 3 or more for a concept, skip the full example and go straight to the reader's own attempt.

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
- [ ] Every chapter shows a concrete case before the general rule or formula.
- [ ] Every chapter except the last before `# Kart` ends with `Tenk på dette:`, and the next chapter answers it.
- [ ] Every procedure the exam asks for has a fading series, and every `svar` div answers exactly the question before it.
- [ ] Every chapter has at least one contrast pair, and every known misconception has a `Vanlig feil:` block.
- [ ] The hard step is marked, and no sentence says "trivielt", "åpenbart" or "lett å se".
- [ ] Code and figures that show the same thing name the link between them.
- [ ] `# Kart` lists the key terms for recall, and its `svar` div gives every definition in one exact sentence.
- [ ] `# Fra sist` asks about the previous PDF for the same code, when there is one.
- [ ] Every chapter has an `Eksamen:` line, the core comes first, and `Stopp her hvis du er trøtt` follows the core.
- [ ] No section opens with a rule list or definition table before a concrete case.
- [ ] Every procedure walkthrough has snapshots, and no caption repeats the prose or the figure title.

The reviewer returns a list of findings with the quoted sentence and a proposed rewrite.
Fix every finding, or note in one line why it is not a problem.
