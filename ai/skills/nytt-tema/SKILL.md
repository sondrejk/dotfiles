---
name: nytt-tema
description: >
  Plan a personal study topic (outside school) in the obsidian-laeringshvelv vault: interview the
  user about goals, depth and time, run a short diagnostic test, research sources and write a
  module-based læreplan and a goals note. Started by `studie ny [beskrivelse]` as `/nytt-tema`.
  Use also when the user wants to learn something outside school ("jeg vil lære meg ...", "nytt
  tema") or wants to change the plan or goals of an existing personal topic ("endre planen for
  <tema>", "revider <kode>").
argument-hint: "[beskrivelse | revider <kode>]"
---

# Nytt tema

Turn "I want to learn X" into a læreplan that `egen-okt` can run, the same way the course læreplaner drive `okt`.
The user describes. You ask, research and decide. The user approves the plan once.

All user-facing text is Norwegian bokmål. Never use an em dash. The terminal does not render LaTeX.
Ask one question per message. Propose answers where you can, so the user picks or corrects instead of writing from scratch.

## Files (vault root: `~/Documents/obsidian-laeringshvelv`)

| File | Use |
|---|---|
| `_system/config.md` | Limits, the "Personlige temaer" table, school exam dates, paths. Read at start. |
| `_system/elevmodell.md` | Rows from the diagnostic test. |
| `_system/logg.md` | One block for the planning session. |
| `15 egne studier/<kode>/mål.md` | Why, goals, depth, time, diagnostic summary. |
| `15 egne studier/<kode>/læreplan.md` | Modules, milestones, level 3 and 4, sources. |
| `30 kart/` | Existing fagområde slugs. |

## 1. Intervju (max ~10 min)

Skip a question when the description already answers it.

1. **Hvorfor:** curiosity, work, a certification, a concrete project.
2. **Mål:** propose 2-4 goals phrased as things the user can do afterwards, derived from the why. Examples: "sette opp en webserver bak en reverse proxy med TLS", "forklare hvordan et norsk landskap ble formet når jeg går tur". Rewrite goals that cannot be observed ("kunne Kubernetes") until they can.
3. **Dybde:** oversikt, arbeidskunnskap or dyp.
4. **Tid:** sessions per week (one session is 45 min) and a horizon, if any.
5. **Kilder brukeren har:** books, courses, docs. Book PDFs go in `~/Downloads`, and `innta` files them.
6. **Praktisk arbeid,** only where it fits: labs on this machine for tools (the rules are in `egen-okt`), observation or field tasks for subjects. Never cloud accounts.

Do not ask about prior knowledge. Test it in step 3.

## 2. Research (silent, max ~5 min)

- **Anchor source:** for tools, the official documentation. Find the current stable version with WebSearch and the structure of the docs with WebFetch. For academic subjects, an open textbook (OpenStax, LibreTexts, open university courses) or the user's book. The anchor decides structure and terminology. Your own knowledge fills gaps.
- **Versions:** pin every tool version. Your training data can be outdated for fast-moving tools.
- **Labs:** check the tools with `command -v`. Missing tools go into the plan as Arch packages to install.

## 3. Diagnostic test (max 10 min)

- 6-10 short questions spread over the planned modules, from basic to advanced. Say first that "vet ikke" is a good answer, so the user does not guess.
- Answer and confidence 1-3, as in `okt`.
- Adaptive: two misses in a row in an area stop that area. Two confident hits skip ahead.
- A short question shows at most level 2. Write a row to `elevmodell.md` after every question (Emner = the topic code, sist testet = today, neste tiltak). Concept names must be the titles `innta` will use for the notes. Untested concepts get no row.
- A module where every concept reached level 2 leaves the module table and goes under `## Kan fra før`.

## 4. Draft and approval

Show a compact draft in chat:
- code, goals, anchor source and versions,
- modules (nr, tema, prioritet, about how many sessions), milestones,
- what level 3 and 4 mean for this topic,
- split between new material and problems,
- packages to install and any new fagområde.

**Sizing:** a module has 3-6 concepts and takes 1-2 sessions. Fit the total to time × horizon. If the goals do not fit, say so and propose cutting `valgfri` modules.
Ask once: `Godkjenn, eller si hva som skal endres.` Adjust until approved. The approval covers installing the listed packages and creating the listed fagområde.

**Code:** a short lowercase ASCII slug (`geologi`, `infra`). It must not be `ny` and must not collide with an existing code.

**Level 3 and 4** per kind of topic:
- Tools: level 3 is a lab solved without hints. Level 4 is finding the fault in a setup Claude has broken, or designing something new.
- Subjects: level 3 is a standard problem (identify, calculate, classify). Level 4 is explaining an unfamiliar case (a landscape, a profile, a dataset).

## 5. Write

1. `15 egne studier/<kode>/mål.md` and `læreplan.md` from the templates below.
2. A row in `_system/config.md` under "Personlige temaer", status `aktiv`.
3. New fagområde: `30 kart/<slug>.md` in the same format as the other map notes.
4. Labs: `mkdir -p ~/laber/<kode>`, and install packages with `sudo pacman -S --needed <pakker>`.
5. Books: create the topic's book folder (Bøker for personlige temaer in Stier in `config.md`).
6. Log block in `_system/logg.md`:
   ```
   ## <dato> <tid> <kode>
   Slutt: <tid>
   Tema: planlegging
   Hendelser:
   - mål: ...
   - diagnose: <concept> nivå N, ...
   ```
7. End with one line and the command on its own line:
   ```
   Klart. Første økt:
   studie <kode>
   ```

Do not start teaching. Learning happens in `egen-okt`.

### Template: `mål.md`

```markdown
---
type: meta
emne: <kode>
---
# Mål for <navn>

**Hvorfor:** <one or two sentences>
**Dybde:** <oversikt | arbeidskunnskap | dyp>
**Tid:** <N> økter per uke à 45 min. Horisont: <dato | ingen>.

## Mål
1. <something the user can do>

## Diagnose <dato>
<one line per area: what the user knew and did not know>

## Ønsker
<preferences from the interview, for example labs or no labs>
```

### Template: `læreplan.md`

```markdown
---
type: meta
emne: <kode>
---
# Læreplan <navn>

Bygd fra intervjuet <dato>, se [[mål]]. Skillen `egen-okt` oppdaterer status og neste tema.

**Status:** `ikke innlest` (ingen konseptnotater ennå), `innlest` (konseptnotater finnes), `lært` (alle konseptene på nivå 2 eller mer i [[elevmodell]]).
**Neste tema:** en modul som ikke er `lært`, der alle forutsetningene er `lært`. Prioritet `kjerne` vinner over `støtte`, som vinner over `valgfri`, deretter lavest nummer.
**Milepæl:** når alle modulene til en milepæl er `lært`, er milepælen hoveddelen i neste økt.

## Kilder

- Anker: <title>, <url>, versjon <x.y>
- <other sources, books with the Nextcloud path>

## Nivå 3 og 4

- Nivå 3: <what it means for this topic>
- Nivå 4: <what it means for this topic>

## Neste tema

M1

## Moduler

| Nr | Tema | Kilder | Konsepter | Forutsetninger | Prioritet | Milepæl | Status |
|---|---|---|---|---|---|---|---|
| M1 | <tema> | <anchor sections> | - | - | kjerne | P1 | ikke innlest |

## Milepæler

| Nr | Brukeren skal klare | Moduler | Tidsgrense | Status |
|---|---|---|---|---|
| P1 | <observable task> | M1-M3 | <min> | ikke tatt |

## Kan fra før

## Utenfor
```

## Revider `<kode>`

1. Read `mål.md`, `læreplan.md` and the topic's rows in `elevmodell.md`.
2. Ask what has changed, one question at a time (new goal, less time, drop something, go deeper).
3. Show the changed modules and milestones and get one approval.
4. Never delete rows in `elevmodell.md` or concept notes. Dropped modules move to `## Utenfor`. New modules are numbered after the existing ones.
5. A topic in `vedlikehold` that gets new modules goes back to `aktiv` in `config.md`.
6. Append a short `revidert` block to the log.
