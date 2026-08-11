---
name: install-skill
description: >
  Install an external skill from GitHub by adding it to the dotfiles manifest
  `ai/skills.txt` and running `ai-skills fetch`. Use this whenever the user wants
  to download, install, update or remove a skill, including when they only paste
  a GitHub URL. Triggers on "installer denne", "last ned denne skillen", "legg
  til skill", "install this skill", "add this skill", "set up the X skill".
  ALWAYS use this instead of cloning or copying straight into a provider's
  skills directory.
---

# Install a skill

Skills live in dotfiles, not in a provider's directory.
The manifest `ai/skills.txt` is the truth about which external skills exist.
`ai/vendor/` is generated from it and is gitignored.
That is what makes the setup follow the user to a new machine with `git pull`.

## Find the manifest

Derive the path from `ai-skills`, which sits on PATH as a symlink into dotfiles:

```bash
AI_DIR="$(dirname "$(dirname "$(readlink -f "$(command -v ai-skills)")")")"
# $AI_DIR/skills.txt, $AI_DIR/skills/, $AI_DIR/vendor/
```

If `ai-skills` is not on PATH, dotfiles is not installed on this machine.
Say so instead of guessing a path.

## Procedure

### 1. Verify the path before you write anything

This step is the whole reason the procedure exists.
Guessing where `SKILL.md` sits inside a repo often misses, because the directory
may be `skills/`, `document-skills/`, `.claude/skills/` or nothing at all.
Look it up:

```bash
REPO="owner/repo"
BRANCH="$(curl -sf "https://api.github.com/repos/$REPO" | jq -r .default_branch)"
curl -sf "https://api.github.com/repos/$REPO/git/trees/$BRANCH?recursive=1" | jq -r '.tree[].path' | grep -i 'SKILL\.md$'
```

The directory that contains `SKILL.md` is the path to use, not the repo root,
unless `SKILL.md` really does sit there.
Several hits mean several skills in one repo: ask which one, or add all of them
if that is what the user asked for.

### 2. Read the frontmatter and report dependencies

```bash
curl -sf "https://raw.githubusercontent.com/$REPO/$BRANCH/$PATH_IN_REPO/SKILL.md" | head -30
```

Look for `compatibility`, `requires` or similar: external binaries, language
runtimes, API keys.
**Report these before installing**, together with the install command for Arch
(`yay -S ...` for AUR, `sudo pacman -S ...` otherwise).
The user should never discover a missing dependency when the skill fails.

### 3. Add it to the manifest

One line, three columns: `<repo>  <path to skill directory>  <ref>`.

If the skill has dependencies, write a short comment on the line above it.
Use `main` as the ref unless the user wants to pin the version, in which case
use a tag or a commit SHA.

### 4. Fetch and verify

```bash
ai-skills fetch
```

```bash
ai-skills list
```

`fetch` rebuilds `vendor/` from scratch every time.
Removing a skill therefore means deleting its line from the manifest and running
`fetch` again, never deleting directories by hand.

### 5. Say that a new session is needed

Skills are read at startup.
The current session will not see the new skill.

## Skills the user writes

A skill the user writes belongs in `$AI_DIR/skills/` and goes into git.
Never put it in `vendor/`, which is wiped on every `fetch`.
Keep it portable: only `name` and `description` in the frontmatter, no vendor
names in the body, and details in `references/` so `SKILL.md` stays short.
Keep native-language trigger words in `description`, since that field is matched
against the user's prompt.
