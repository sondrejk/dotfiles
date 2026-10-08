---
name: egen-okt
description: >
  Run one study session on a personal topic (outside school) in the
  obsidian-laeringshvelv vault: warm-up, new module material, problems or hands-on labs on this
  machine, learner model, flashcards and log. Started by `studie <kode>` as `/egen-okt <kode>`,
  where <kode> is a topic in the "Personlige temaer" table in `_system/config.md`. Use whenever
  the user wants to study a personal topic ("studer geologi", "økt i infra").
argument-hint: "<kode>"
---

# Egen økt

A session on a personal topic runs exactly like `okt`, except where this file says otherwise.
**Read `../okt/SKILL.md` (relative to this skill's base directory) first**, and follow it with the changes below. Section numbers refer to `okt`.

In short: the topic is given, the session length is "Tidsbudsjett per personlig økt" in `config.md`, modules replace lectures, milestones replace exams, and tools are learned in labs.

## Files

In addition to the files in `okt`:

| File | Use |
|---|---|
| `_system/config.md` | The "Personlige temaer" table: code, folder, card domain, sources, split, status. |
| `15 egne studier/<kode>/læreplan.md` | Modules, milestones, level 3 and 4 for this topic, sources, next topic. |
| `15 egne studier/<kode>/mål.md` | Why the user learns this and the goals. Read at start. |
| `~/laber/<kode>/` | Lab working files. Never inside the vault. |

## 1. Oppstart (replaces steps 3-7 in `okt`)

1. `date '+%F %H:%M'`. Read `_system/config.md`, the last ~60 lines of `_system/logg.md`, and the topic's `mål.md` and `læreplan.md`.
2. `$ARGUMENTS` must be a code in "Personlige temaer". If it is not, list the codes, say that `studie ny` plans a new topic, and stop.
3. **Status `vedlikehold`:** say the goals are reached and the cards continue. Ask whether to plan a part 2 (run `nytt-tema` with `revider <kode>`) or run a repetition session (warm-up plus problems on the weakest concepts).
4. **Unfinished sessions:** apply the rule in `okt` step 3 only to blocks with this code. Unfinished blocks with other codes: finish silently if older than 3 hours, otherwise leave them.
5. **School exam within 7 days** (the Emner table): one line, for example `ABC1234 har eksamen om 4 dager.`, then continue. Never stop the user.
6. No PDF scan, no course choice, no capture notes, no exam ramp.
7. Write the log block as in `okt` step 8, with `Tema: <modul nr og tema>`.

## 2. Oppvarming

4 questions, max 4 minutes: 3 from this topic and 1 from another active personal topic if one exists. Never school courses.
Skip the warm-up when fewer than 3 concepts in this topic have level 1 or more, and log `- oppvarming hoppet over (for lite stoff)`.

## 3. Hoveddel (rest of the session's pomodoros)

**Split:** the Fordeling column in config (default 50/50). The "while the course is behind" rule in `okt` does not apply.

**Topic:** "Neste tema" in `læreplan.md`. If a milestone has all its modules `lært` and is not passed, the main part is that milestone (section 4 below).
- Status `ikke innlest`: run the `innta` procedure for personal topics on the module, max 5 minutes.
- New material works as in `okt`. Worked examples use the topic's own medium: a manifest and its effect, a command and its output, a rock and how it is identified.
- Level 3 and 4 are defined in `## Nivå 3 og 4` in `læreplan.md`. Problem sources: exercises in the anchor source, adapted official tutorials, and your own problems.
- When every concept of a module has level 2 or more, set the module to `lært`. There are no lecture notes to update.

### Labs

The user builds. Claude prepares the start state, breaks working setups for level 4 and verifies the result.

**Hard rules:**
- Only on this machine: Docker, kind, OpenTofu with local providers only (`docker`, `kind`, `local`, `null`, `random`, `tls`) and Ansible against lab containers. Never cloud providers, never credentials, never files outside `~/laber/<kode>/`.
- Every resource name starts with `lab-<kode>-` (containers, networks, volumes). The kind cluster is `lab-<kode>`.
- `kind` and `kubectl` always get `--kubeconfig ~/laber/<kode>/kubeconfig`, on every command, because shell state does not persist between commands. Never read or write `~/.kube/config`.
- OpenTofu runs in the lab folder with local state.
- Clean up only by prefix: `docker ps -aq --filter name=^lab-<kode>-`, `kind delete cluster --name lab-<kode>`. Never `docker system prune` and never `rm` outside the lab folder.
- No `sudo` in labs.

**Flow:**
1. Write the task in `~/laber/<kode>/<NN>-<navn>/OPPGAVE.md` and in chat: the goal, the start state and what the result must do. Never how to do it.
2. Prepare the start state (cluster up, base files, or a broken setup for level 4).
3. The user works in their own terminal and editor in that folder, and writes `sjekk` when done.
4. Verify by running checks: `get`/`describe`, `curl` against the service, `tofu plan` with no changes, a second Ansible run with `changed=0`. Read the user's files and assess the method as in `okt`: point at errors with a question.
5. Levels and hints follow `okt`. A level 4 task is a working setup you break without saying how (wrong selector, closed port, wrong variable). The user finds and fixes the fault.

## 4. Milepæl (replaces Eksamensmodus)

- The task stands in the Milepæler table in `læreplan.md`. Time limit from the table, no hints.
- Full review afterwards. Concepts used correctly without hints reach level 4 if the task was new to the user. Weak concepts get next action `oppvarming neste økt`.
- Passed: set the milestone's status to `bestått <dato>`.
- All milestones passed: set the topic's status to `vedlikehold` in config and tell the user. Suggest `revider <kode>` for a part 2.

## 5. Avslutning

As in `okt`, with these changes:
- Pomodoros as in `okt`, but the count comes from "Tidsbudsjett per personlig økt".
- The `kort` procedure uses the limits for personal topics.
- Recompute "Neste tema" by the rule in the topic's `læreplan.md`.
- Stop running lab containers (`docker stop`, by prefix) so they do not use resources. They keep their state for the next session. Say so in one line.
