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

- **Max 6 new cards per session** (`_system/config.md`).
- **Max 300 active cards per course.** Check with `/usr/bin/python3 _system/scripts/kortstatus.py`.
- **Activation:** every concept that reached level 2 or more in this session gets its note's tag switched from `#flashcards-vent/<domene>` to `#flashcards/<domene>`. Max 25 activated cards per session. Remaining concepts keep next action `aktiver kort` in `elevmodell.md` and are activated first in the next session.
- Before switching a note's tag, check every card in it against the log: each fact must have been tested or explained. If one was not, keep the note waiting and set next action `gå gjennom <fact>, så aktiver kort`.
- New cards for a concept that is still below level 2 go into the note but stay waiting (the note keeps `#flashcards-vent/`).
- **Personal topics** (codes in "Personlige temaer" in config): max 3 new cards per session and max 150 active cards per topic, because they share the daily review budget with school. While a school course has an exam within 7 days, write no new cards and activate none for personal topics. Set next action `aktiver kort` instead.

## 3. Card standard

1. The question always states its context: course topic, algorithm or technology (`I MPI: ...`, `I ARM-assembly: ...`).
2. **Unambiguous:** if more than one answer could be right, the question names the variant (signed or unsigned, tree or graph search, ARM or RISC-V). Check this by asking yourself whether a correct but different answer exists.
3. One fact per card. The answer is preferably under 25 words and never more than two short sentences.
   The answer contains exactly what the question asks for, nothing more. A correct answer to the question must never be judged incomplete by extra facts in the answer. Put extra facts on their own card.
4. **Self-contained:** a reader who was not in the session must understand both the question and why the answer is right, months later.
   Every symbol in the question or answer is defined in the card itself (`S(p) = p, der p er antall prosessorer`), and a formula answer also says in words what it means.
5. **Error cards name the trap.** A card made from an error or a `sikker-og-feil` answer states the wrong alternative the user chose, in one short clause (`fra 8 til 16 kjerner gir p = 16, ikke 2`).
   If the error came from mixing up two concepts, the card asks for both sides of the contrast (`hvilken kjøretid er f en andel av i Amdahl, og hvilken i Gustafson?`), never only one side.
   This clause is part of the fact, not an extra fact under rule 3.
6. Card types, in priority order: abbreviation → meaning (plus one line on what it is), definition, formula, notation, fact or rule. A "why" card only when the reason is a short fact the exam asks for.
7. Never: yes/no questions, lists of more than 3 items, trivia, analogies, questions about what the lecture covered, references to other notes or concepts ("se roofline-modellen"), or understanding that is better tested with a problem.
8. Norwegian, with the English term in parentheses the first time it is used in the card.
9. Correct. Check each card against the note and your subject knowledge.
   Then read it cold, as a stranger: if the answer would make a reader ask "what is p?" or "compared to what?", rewrite it.
10. Order in the note follows dependencies: definitions and abbreviations first, then what builds on them.

## 4. Format

In the concept note, under `## Flashcards`, after the tag line, one card per paragraph:

```
Spørsmål med kontekst? :: Kort svar.
```

- Single-line cards with `::` only. Math in `$...$`. Never `==` (the plugin turns highlights into clozes).
- Do not write scheduling data. The plugin adds the `> [!sr|card-metadata]` callout at first review.
- Never touch existing callouts. They belong to the card above them.

## 5. Report

One or two lines to the user, no list to approve:
`Kort: 5 nye (A*, konsistent heuristikk, UCS), 9 aktivert (søketre, uinformerte søkestrategier).`
Append the same line to the session's block in `_system/logg.md`.
