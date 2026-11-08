---
name: kort
description: >
  Write flashcards for the Obsidian Spaced Repetition plugin (FSRS) in the obsidian-laeringshvelv
  vault for the concepts a study session taught, as standalone memory aids built from the concept
  notes, with the session's errors and gaps deciding priority and angles. Also switches waiting
  cards on when a concept is learned. Called by `okt` at the end of a session and when finishing
  an interrupted one. Use also when the user says "lag kort" in this vault.
---

# Kort

Never ask the user to review card lists. You own the quality: every card must be one the user wants to memorize.
Cards test memory. Understanding is tested with problems in `okt`, not with cards.

A card is a task for the user's future self, months from now, with no memory of the session.
It must work on its own: a reader who knows the subject but never saw the session can answer it, and answering it helps on an exam question the user has never seen.

## 1. What to card

Cards come from the concept notes, not from the session transcript.
The session decides which concepts get cards today and from which angles.

1. **Concepts:** every concept the session taught or tested, plus concepts with next action `aktiver kort` or `kort: ...` in `elevmodell.md` from earlier sessions. Earlier concepts come first, so the cards keep pace with the sessions.
2. **Coverage:** for each concept, read the note's body and `**Eksamenskrav:**`, and the cards already in the note. Every Eksamenskrav item that is memory (a term, a definition, a formula, a rule, a cause, a contrast, a step) and that a session has taught gets 1-3 cards. Skills (run an algorithm, write code, compute) are tested with problems, not cards.
3. **Angles from the session**, in priority order for the slots in section 2:
   1. Errors (the `- feil:` events in the session's block in `_system/logg.md`).
   2. `sikker-og-feil` answers.
   3. Gaps and errors from the free recall.
   4. Coverage of today's concepts that no error touched: abbreviations, definitions, formulas, notation, key facts.
4. **Turn an error into the rule behind it.** The user erred on one example, but the card tests the general rule, with neutral names: `f(a, &x)`, not the task's `divmod(a, b, &q, &r)`. Never put the session's own function names, variable names, numbers, register values or task scenarios on a card. An example gets a card only when it is the standard example of the field (the one a textbook would use), and then as an extra angle next to the rule, never instead of it.
5. **Several angles for central concepts:** 2-4 cards that reach the same idea differently, chosen from definition, cause (Hvorfor), consequence, contrast with the nearest neighbour, and description to term (a two-way Definisjon card). One angle per card.

Skip a candidate if an equivalent card already exists in the note (active or waiting).
Skip a candidate unless a session tested or explained that exact fact. A gap on material never covered is a teaching task, not a card: set it as next action in `elevmodell.md`.

## 2. Limits

- **Review brake:** first run `/usr/bin/python3 _system/scripts/kortstatus.py`. It prints "høyeste dag" (the busiest of the next 7 days, with today's overdue and unseen cards counted in) as a percentage of the daily review target. Look up that percentage in "Bremsetrinn" in config, and use the limits of that row instead of the full limits below. If it says there are too many unseen cards, activate nothing. Concepts that would have been activated keep next action `aktiver kort`.
- **New cards per session:** two limits in `_system/config.md`. Angles 1-3 share "Maks nye kort per økt". Coverage (angle 4) gets its own slots ("Ekstra plasser for huskefakta per økt"), so errors never crowd it out. Main slots left unused may also go to coverage.
- **What does not fit** goes into the concept's Neste tiltak in `elevmodell.md` as `kort: <items>`, and is written first in the next session.
- **Active cards per course:** at most "Maks aktive kort per emne" in config. Check with `kortstatus.py`.
- **Activation:** every concept that reached level 2 or more gets its note's tag switched from `#flashcards-vent/<domene>` to `#flashcards/<domene>` in the same session. At most "Maks aktiverte kort per økt" in config. Remaining concepts keep next action `aktiver kort` in `elevmodell.md` and are activated first in the next session.
- Before switching a note's tag, check every card in it against the log: each fact must have been tested or explained. If one was not, keep the note waiting and set next action `gå gjennom <fact>, så aktiver kort`.
- New cards for a concept that is still below level 2 go into the note but stay waiting (the note keeps `#flashcards-vent/`).
- **Archived notes:** before a note goes from `#flashcards-arkiv/` to waiting or active, rewrite its cards to the card standard and format below.
- **Personal topics** (codes in "Personlige temaer" in config): the personal limits in config for new and active cards (no extra coverage slots), because they share the daily review budget with school. While a school course has an exam within 7 days, write no new cards and activate none for personal topics. Set next action `aktiver kort` instead.

## 3. Card standard

The user must know from the question alone what the answer contains, and must still have to retrieve it.
Every card therefore uses one form from the phrasebook below, and the form fixes the shape of the answer.

### Phrasebook

The header line is `<Form> (<kontekst>)`. The context must be in "Kortkontekster" in config for the note's card domain. Anything more specific (a model, a variant) goes in the question: `Hva styrer CPI i jernloven?`.
The question line is a full sentence that starts with a capital letter. Hvorfor, Hvordan, Når and Hvor repeat their word first, so the line reads on its own.

| Form | Question line | The answer is always |
|---|---|---|
| Forkortelse | `CPI` | Only the expanded words: `Cycles Per Instruction`. |
| Definisjon | `CPI` | One sentence that says what the term is. For an abbreviation, the question shows only the abbreviation, so it does not give away the Forkortelse card. |
| Formel | `AMAT` | The formula, then `der` and every symbol explained. |
| Notasjon | `rd` | One sentence that says what the notation means. |
| Funksjon | `MPI_Bcast` | One sentence that says what the instruction, function or unit does. |
| Kontrast | `Write-through vs. write-back - når skrives minnet?` | `X: ... Y: ...`, one short clause per side. |
| Liste | `De 3 klassene av farer i et samlebånd` | Exactly the named number of items, separated by commas. |
| Hvorfor | `Hvorfor gir ikke sizeof(ptr) størrelsen på arrayet?` | One sentence with the reason. |
| Hvilken | `Hvilket instruksjonsformat bruker addi?` | The name or names asked for. |
| Hvordan | `Hvordan unngår du deadlock i et ring-mønster?` | One sentence with the method. |
| Når | `Når returnerer MPI_Ssend?` | One sentence with the condition or point in time. |
| Hvor | `Hvor kan MPI_ANY_TAG brukes?` | The place. |
| Konsekvens | `En immediate kan ikke kodes i instruksjonen` | One sentence with what happens. |
| Fakta | `Hva slags ting er sizeof?` | One sentence that answers exactly the question. |

- Every abbreviation that a card is about gets both a Forkortelse card and a Definisjon card. If one of them already exists anywhere in `20 notater`, write only the missing one.
- Kontrast without a named property (` - <egenskap>?`) only when the two terms differ in one essential way. Kontrast asks for the property, never for a choice between two labels: `ARM vs. x86 - RISC eller CISC?` is a coin toss, `RISC vs. CISC - hvordan er instruksjonene kodet?` is a card.
- Liste: at most 3 items, or at most 6 when each item is one or two words (`IF, ID, EX, MEM, WB`). A longer or wordier list becomes one card per item (`Hva gjør steget etter dekoding i instruksjonssyklusen?`), because sets and enumerations are recalled incompletely.
- Hvorfor gives the cause, never a restatement of the claim or a name for the mechanism. "Rekursjon trenger stakken fordi hvert kall får en stakkramme" says the same thing twice. Test it: would the answer convince someone who doubts the claim?
- Liste names what it lists and in which model, when another well-known list could fit the question (the instruction cycle against the 5 pipeline stages). Name it in words, never by printing the items: `instruksjonssyklusen (fetch-decode-execute)` gives the answer away.
- Fakta asks for one thing. A question with "og" between two questions becomes two cards.
- Prefer a fixed form over Fakta. Fakta is for facts no other form fits, and stays under 10 % of the cards.
- **Core in bold, extras in italics:** every answer except Forkortelse has its core in `**bold**`, and the user only has to produce the bold part. When the whole answer is core, the whole answer is bold. An extra is one of: a `fordi` reason, an `ikke ...` trap, an example (`som ...`, `for eksempel ...`), a `der` clause in Formel or an `altså` paraphrase. It follows the core as its own italic sentence, `**Kjerne**. *Fordi ...*`, so the user sees at a glance what is not to be recalled. Nothing else may stand outside the bold: a second fact (`**r0**, og r1 i tillegg for 64-bits verdier`) gets its own card. In Kontrast each side has its own bold core and its own italic extra: `X: **...**. *Som ...* Y: **...**.`
- **Two-way cards:** a Definisjon card for a central concept the exam may describe without naming (definitions in KI, architecture terms) uses `??` instead of `?`. The plugin then also shows the definition alone and asks for the term. The definition must not contain the term or give it away.
- Do not write a card whose answer another card in the same note already gives (`Hvilken node ekspanderer BFS først?` next to the BFS definition).

### Rules

1. **Standalone:** the card passes the test at the top of this skill. Read the question and ask: does answering it depend on remembering a session, an exercise or a lecture example? If so, rewrite it as the general rule (section 1, step 4).
2. **No giveaway:** nothing on the front may contain the answer or let it be guessed without recall: not the answer's words, not the English term for it in parentheses, not a list of the items, not a choice between two labels. Check by covering the answer and asking whether the question alone produces it without memory.
3. **Unambiguous:** if more than one answer could be right, the question names the variant (signed or unsigned, tree or graph search, ARM or RISC-V). Check this by asking yourself whether a correct but different answer exists.
4. **Minimum information:** one fact per card, and the answer preferably under 15 words (hard limit 25). A correct answer to the question must never be judged incomplete by extra facts in the answer. Put extra facts on their own card.
5. **Self-contained:** every symbol in the question or answer is defined in the card itself (`S(p) = p, der p er antall prosessorer`). A reader must understand both the question and why the answer is right, months later.
6. **Error cards name the trap.** A card made from an error or a `sikker-og-feil` answer ends with the wrong alternative the user chose, as an italic extra starting with `Ikke` (`**p = 16**. *Ikke 2.*`). Phrase the wrong alternative generally too (`ikke & alene`, not the user's exact line).
   If the error came from mixing up two concepts, use the Kontrast form, never a card on only one side.
   This clause is part of the fact, not an extra fact under rule 4.
7. Never: yes/no questions, trivia, analogies, questions about what the lecture covered, references to other notes or concepts ("se roofline-modellen"), or understanding that is better tested with a problem.
8. Norwegian, with the English term in parentheses in the question the first time it is used in the card, unless that term gives the answer away (rule 2).
9. Correct. Check each card against the note and your subject knowledge.
   Then read it cold, as a stranger: if the answer would make a reader ask "what is p?" or "compared to what?", rewrite it.
10. Order in the note follows dependencies: Forkortelse and Definisjon first, then what builds on them.
11. Run `/usr/bin/python3 _system/scripts/kortsjekk.py` after writing cards, and fix every card it reports. A hook also runs it after every edit in `20 notater`, but not after edits made through Bash. The script catches form errors and some giveaways, never whether a card is standalone: that check is yours.

### Reviewed cards

A card with a `> [!sr|card-metadata]` callout below it has review history. Rewriting it costs the user that progress, so leave it as it is, also when it breaks a rule added later.
Two exceptions, both keeping the question, the bold core and the callout directly below the card: fix the wrong part of a card that is wrong or misleading, and move an extra fact outside the bold core to a card of its own.
`kortsjekk.py` applies the newest rules (giveaway, list length, choice between two labels) only to cards without a callout.

## 4. Format

In the concept note, under `## Flashcards`, after the tag line and an empty line, one card per paragraph, with an empty line between cards:

```
Kontrast (hurtigbuffer)
&nbsp;
Write-through vs. write-back - når skrives minnet?
?
Write-through: **ved hver skriving**. Write-back: **når linja kastes ut**. *Med et dirty bit.*
```

- Line 1: `<Form> (<kontekst>)`. Line 2: `&nbsp;`, which shows as an empty line without ending the paragraph (an empty line would split the card in the plugin). Line 3: the question. Line 4: `?`, or `??` for a two-way Definisjon card. Line 5: the answer, on one line.
- Math in `$...$`. Never `==` (the plugin turns highlights into clozes). Never `::` outside backticks, because the plugin then reads the line as a one-line card.
- Do not write scheduling data. The plugin adds the `> [!sr|card-metadata]` callout below the answer at first review.
- Never touch existing callouts. They belong to the card above them.

## 5. Report

One or two lines to the user, no list to approve:
`Kort: 5 nye (A*, konsistent heuristikk, UCS), 9 aktivert (søketre, uinformerte søkestrategier).`
Append the same line to the session's block in `_system/logg.md`.
