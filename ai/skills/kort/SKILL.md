---
name: kort
description: >
  Write flashcards for the Obsidian Spaced Repetition plugin (FSRS) in the obsidian-laeringshvelv
  vault from what a study session revealed: errors, confident-but-wrong answers, gaps in free
  recall, and must-memorize facts. Also switches waiting cards on when a concept is learned.
  Called by `okt` at the end of a session and when finishing an interrupted one. Use also
  when the user says "lag kort" in this vault.
---

# Kort

Never ask the user to review card lists. You own the quality: every card must be one the user wants to memorize.
Cards test memory. Understanding is tested with problems in `okt`, not with cards.

## 1. Candidates, in priority order

1. Errors from the session (the `- feil:` events in the session's block in `_system/logg.md`).
2. `sikker-og-feil` answers.
3. Gaps and errors from the free recall.
4. Must-memorize material from today's topic: abbreviations, definitions, formulas, notation.

Skip a candidate if an equivalent card already exists in the note (active or waiting).
Skip a candidate unless the session (or an earlier logged one) tested or explained that exact fact. A gap in free recall on material never covered is a teaching task, not a card: set it as next action in `elevmodell.md`.

## 2. Limits

- **Review brake:** first run `/usr/bin/python3 _system/scripts/kortstatus.py`. It prints "høyeste dag" (the busiest of the next 7 days) as a percentage of the daily review target. Look up that percentage in "Bremsetrinn" in config, and use the limits of that row instead of the full limits below. Concepts that would have been activated keep next action `aktiver kort`.
- **New cards per session:** two limits in `_system/config.md`. Candidates 1-3 share "Maks nye kort per økt". Must-memorize facts (candidate 4) get their own slots ("Ekstra plasser for huskefakta per økt"), so errors never crowd them out. Main slots left unused may also go to must-memorize facts.
- **Active cards per course:** at most "Maks aktive kort per emne" in config. Check with `kortstatus.py`.
- **Activation:** every concept that reached level 2 or more in this session gets its note's tag switched from `#flashcards-vent/<domene>` to `#flashcards/<domene>`. At most "Maks aktiverte kort per økt" in config. Remaining concepts keep next action `aktiver kort` in `elevmodell.md` and are activated first in the next session.
- Before switching a note's tag, check every card in it against the log: each fact must have been tested or explained. If one was not, keep the note waiting and set next action `gå gjennom <fact>, så aktiver kort`.
- New cards for a concept that is still below level 2 go into the note but stay waiting (the note keeps `#flashcards-vent/`).
- **Archived notes:** before a note goes from `#flashcards-arkiv/` to waiting or active, rewrite its cards to the card standard below.
- **Personal topics** (codes in "Personlige temaer" in config): the personal limits in config for new and active cards (no extra must-memorize slots), because they share the daily review budget with school. While a school course has an exam within 7 days, write no new cards and activate none for personal topics. Set next action `aktiver kort` instead.

## 3. Card standard

The user must know from the question alone what the answer contains.
Every card therefore uses one form from the phrasebook below, and the form fixes the shape of the answer.

### Phrasebook

Question: `<Form> (<kontekst>): <gjenstand>`. The context must be in "Kortkontekster" in config for the note's card domain. Anything more specific (a model, a variant) goes in the subject: `Fakta (ytelse): hva styrer CPI i jernloven?`.

| Form | Question | The answer is always |
|---|---|---|
| Forkortelse | `Forkortelse (datamaskinarkitektur): CPI` | Only the expanded words: `Cycles Per Instruction`. |
| Definisjon | `Definisjon (ytelse): CPI` | One sentence that says what the term is. For an abbreviation, the question shows only the abbreviation, so it does not give away the Forkortelse card. |
| Formel | `Formel (hurtigbuffer): AMAT` | The formula, then `der` and every symbol explained. |
| Notasjon | `Notasjon (RISC-V): rd` | One sentence that says what the notation means. |
| Funksjon | `Funksjon (MPI): MPI_Bcast` | One sentence that says what the instruction, function or unit does. |
| Kontrast | `Kontrast (hurtigbuffer): write-through vs. write-back - når skrives minnet?` | `X: ... Y: ...`, one short clause per side. |
| Liste | `Liste (samlebånd): de 3 klassene av farer` | Exactly the named number of items, separated by commas. |
| Hvorfor | `Hvorfor (C): sizeof(ptr) gir ikke størrelsen på arrayet?` | One sentence with the reason. |
| Hvilken | `Hvilken (RISC-V): hvilket instruksjonsformat bruker addi?` | The name or names asked for. |
| Hvordan | `Hvordan (MPI): unngår du deadlock i et ring-mønster?` | One sentence with the method. |
| Når | `Når (MPI): returnerer MPI_Ssend?` | One sentence with the condition or point in time. |
| Hvor | `Hvor (MPI): kan MPI_ANY_TAG brukes?` | The place. |
| Konsekvens | `Konsekvens (ARM-assembly): en immediate kan ikke kodes` | One sentence with what happens. |
| Fakta | `Fakta (C): hva slags ting er sizeof?` | One sentence that answers exactly the question. |

- Every abbreviation that a card is about gets both a Forkortelse card and a Definisjon card. If one of them already exists anywhere in `20 notater`, write only the missing one.
- Kontrast without a named property (` - <egenskap>?`) only when the two terms differ in one essential way.
- Liste: at most 3 items, or at most 6 when each item is one word or one abbreviation (`IF, ID, EX, MEM, WB`).
- Fakta asks for one thing. A question with "og" between two questions becomes two cards.
- Prefer a fixed form over Fakta. Fakta is for facts no other form fits, and stays under 10 % of the cards.
- **Core answer in bold:** every answer except Forkortelse has its core in `**bold**`, and the user only has to produce the bold part. When the whole answer is core, the whole answer is bold. A `fordi` reason, an `ikke ...` trap, an example (`som ...`, `for eksempel ...`), a `der` clause in Formel and an `altså` paraphrase stay outside the bold. In Kontrast each side has its own bold core.
- **Two-way cards:** a Definisjon card for a central concept the exam may describe without naming (definitions in KI, architecture terms) uses `:::` instead of `::`. The plugin then also shows the definition alone and asks for the term. The definition must not contain the term or give it away.
- Do not write a card whose answer another card in the same note already gives (`hvilken node ekspanderer BFS først?` next to the BFS definition).

### Rules

1. **Unambiguous:** if more than one answer could be right, the question names the variant (signed or unsigned, tree or graph search, ARM or RISC-V). Check this by asking yourself whether a correct but different answer exists.
2. **Exactly what the form promises.** One fact per card, preferably under 20 words. A correct answer to the question must never be judged incomplete by extra facts in the answer. Put extra facts on their own card.
3. **Self-contained:** a reader who was not in the session must understand both the question and why the answer is right, months later.
   Every symbol in the question or answer is defined in the card itself (`S(p) = p, der p er antall prosessorer`).
4. **Error cards name the trap.** A card made from an error or a `sikker-og-feil` answer ends with the wrong alternative the user chose, as one short clause starting with `ikke`, after the bold core (`**p = 16**, ikke 2`).
   If the error came from mixing up two concepts, use the Kontrast form, never a card on only one side.
   This clause is part of the fact, not an extra fact under rule 2.
5. Never: yes/no questions, trivia, analogies, questions about what the lecture covered, references to other notes or concepts ("se roofline-modellen"), or understanding that is better tested with a problem.
6. Norwegian, with the English term in parentheses in the question the first time it is used in the card.
7. Correct. Check each card against the note and your subject knowledge.
   Then read it cold, as a stranger: if the answer would make a reader ask "what is p?" or "compared to what?", rewrite it.
8. Order in the note follows dependencies: Forkortelse and Definisjon first, then what builds on them.
9. Run `/usr/bin/python3 _system/scripts/kortsjekk.py` after writing cards, and fix every card it reports. A hook also runs it after every edit in `20 notater`, but not after edits made through Bash.

## 4. Format

In the concept note, under `## Flashcards`, after the tag line, one card per paragraph:

```
Form (kontekst): gjenstand :: **Kjernesvar**, eventuelt tillegg.
```

- Single-line cards with `::`, or `:::` for two-way Definisjon cards. Math in `$...$`. Never `==` (the plugin turns highlights into clozes).
- Do not write scheduling data. The plugin adds the `> [!sr|card-metadata]` callout at first review.
- Never touch existing callouts. They belong to the card above them.

## 5. Report

One or two lines to the user, no list to approve:
`Kort: 5 nye (A*, konsistent heuristikk, UCS), 9 aktivert (søketre, uinformerte søkestrategier).`
Append the same line to the session's block in `_system/logg.md`.
