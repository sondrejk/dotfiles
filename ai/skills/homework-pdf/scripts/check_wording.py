#!/usr/bin/env python3
"""Check that a submission keeps the wording of the original note.

Usage: check_wording.py NOTE.md SUBMISSION.md

Compares the two files word by word with all Markdown syntax, list markers and
numbering stripped, so only real wording differences show up. Words are
compared as runs of letters and digits, so typesetting plain-text math as LaTeX
("0.9 * 1" as "$0.9 \\cdot 1$") passes as long as every number, variable and
word is kept. Content inside a `::: {.transcribed src="img.png"}` block is a
transcription of that image: it is skipped, and the image counts as kept. Prints:
  ADDED    words in the submission that are not in the note (should be none,
           apart from the header and question labels you added on purpose)
  REMOVED  text from the note that is not in the submission (should only be
           frontmatter-like leftovers, personal notes and similar)
  IMAGES   image embeds from the note that are missing in the submission
Exit code is 1 if anything was added or an image was dropped, else 0.
"""

import difflib
import re
import sys
from pathlib import Path
from urllib.parse import unquote

FRONTMATTER = re.compile(r"\A---\n.*?\n---\n", re.S)
IMAGE = re.compile(r"!\[\[([^\]|#]+)[^\]]*\]\]|!\[[^\]]*\]\((<[^>]+>|[^)\s]+)[^)]*\)(\{[^}]*\})?")
WIKI_LINK = re.compile(r"\[\[([^\]|]+?)(?:\|([^\]]*))?\]\]")
MARKUP = re.compile(r"^\s*(:::+.*|#{1,6}\s|>\s?|[-*+]\s|\d+[.)]\s|[a-z][.)]\s|\[[ x]\]\s)+", re.I)
TRANSCRIBED = re.compile(r"^:::+\s*\{[^}]*\.transcribed[^}]*src=\"([^\"]+)\"[^}]*\}.*?^:::+[ \t]*$", re.S | re.M)
TOKEN = re.compile(r"[^\W\d_]+|\d+(?:[.,]\d+)*")
# LaTeX commands that only typeset what plain text wrote with symbols or spacing.
LATEX_NOISE = {
    "cdot", "times", "div", "frac", "dfrac", "tfrac", "left", "right", "bigl", "bigr", "big", "Big",
    "text", "textrm", "mathrm", "mathit", "mathbf", "operatorname", "displaystyle",
    "quad", "qquad", "to", "rightarrow", "Rightarrow", "leftarrow", "implies",
    "le", "leq", "ge", "geq", "neq", "ne", "approx", "pm", "mid",
}


def images(text: str) -> list[str]:
    names = []
    for m in IMAGE.finditer(text):
        name = m.group(1) or m.group(2).strip("<>")
        names.append(Path(unquote(name.strip())).name)
    return names


def transcribed(text: str) -> list[str]:
    return [Path(unquote(m.group(1))).name for m in TRANSCRIBED.finditer(text)]


def words(text: str) -> list[str]:
    text = FRONTMATTER.sub("", text)
    text = TRANSCRIBED.sub(" ", text)
    text = re.sub(r"\\([a-zA-Z]+)", lambda m: " " if m.group(1) in LATEX_NOISE else f" {m.group(1)} ", text)
    text = re.sub(r"%%.*?%%", " ", text, flags=re.S)
    text = IMAGE.sub(" ", text)
    text = WIKI_LINK.sub(lambda m: m.group(2) or m.group(1), text)
    out = []
    for line in text.split("\n"):
        prev = None
        while prev != line:
            prev, line = line, MARKUP.sub("", line)
        out.extend(t.lower() for t in TOKEN.findall(line))
    return out


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    note, sub = (Path(a).read_text(encoding="utf-8") for a in sys.argv[1:])
    a, b = words(note), words(sub)
    added, removed = [], []
    for op, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if op in ("replace", "delete"):
            removed.append(" ".join(a[i1:i2]))
        if op in ("replace", "insert"):
            added.append(" ".join(b[j1:j2]))

    kept = images(sub) + transcribed(sub)
    missing_imgs = [i for i in images(note) if i not in kept]

    print(f"ADDED ({len(added)})")
    for x in added:
        print(f"  + {x}")
    print(f"REMOVED ({len(removed)})")
    for x in removed:
        print(f"  - {x}")
    print(f"IMAGES MISSING ({len(missing_imgs)})")
    for x in missing_imgs:
        print(f"  ! {x}")
    return 1 if added or missing_imgs else 0


if __name__ == "__main__":
    sys.exit(main())
