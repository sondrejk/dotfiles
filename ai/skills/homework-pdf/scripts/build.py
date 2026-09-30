#!/usr/bin/env python3
"""Render a homework submission Markdown file to PDF via pandoc and Typst.

Usage: build.py SUBMISSION.md --source NOTE.md --out OUT.pdf

SUBMISSION.md is the cleaned-up copy (YAML header with title/author/date/lang).
NOTE.md is the original note; its folder and vault are used to resolve images.
"""

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import unquote

SKILL_DIR = Path(__file__).resolve().parent.parent
IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp", ".bmp"}
FENCE = re.compile(r"^\s*(```|~~~)")
WIKI_EMBED = re.compile(r"!\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|([^\]]*))?\]\]")
WIKI_LINK = re.compile(r"(?<!!)\[\[([^\]|]+?)(?:\|([^\]]*))?\]\]")
MD_IMAGE = re.compile(r"!\[([^\]]*)\]\((<[^>]+>|[^)\s]+)(\s+\"[^\"]*\")?\)(\{[^}]*\})?")
COMMENT = re.compile(r"%%.*?%%", re.S)
CALLOUT = re.compile(r"^(\s*>\s*)\[!(\w+)\][+-]?\s*(.*)$")


def find_vault(start: Path) -> Path | None:
    for d in [start, *start.parents]:
        if (d / ".obsidian").is_dir():
            return d
    return None


class Resolver:
    def __init__(self, note: Path):
        self.note_dir = note.parent.resolve()
        self.vault = find_vault(self.note_dir)
        self._index: dict[str, list[Path]] | None = None

    def _all_files(self) -> dict[str, list[Path]]:
        if self._index is None:
            self._index = {}
            root = self.vault or self.note_dir
            for p in root.rglob("*"):
                if p.is_file() and ".obsidian" not in p.parts and ".trash" not in p.parts:
                    self._index.setdefault(p.name.lower(), []).append(p)
        return self._index

    def resolve(self, target: str) -> Path | None:
        target = unquote(target.strip())
        candidates = [self.note_dir / target]
        if self.vault:
            candidates.append(self.vault / target)
        for c in candidates:
            if c.is_file():
                return c.resolve()
        # Obsidian's "shortest path" links: match by file name anywhere in the vault.
        matches = self._all_files().get(Path(target).name.lower(), [])
        if matches:
            return min(matches, key=lambda p: (len(p.parts), str(p))).resolve()
        return None

    def resolve_image(self, target: str) -> Path | None:
        found = self.resolve(target)
        if found and found.suffix.lower() in IMAGE_EXTS:
            return found
        # Excalidraw drawings only render if the plugin auto-exported a PNG/SVG next to them.
        stem = re.sub(r"(\.excalidraw)?(\.md)?$", "", target)
        for ext in (".excalidraw.png", ".excalidraw.svg", ".png", ".svg"):
            found = self.resolve(stem + ext)
            if found:
                return found
        return None


def width_attr(opts: str | None) -> str:
    if not opts:
        return ""
    m = re.match(r"^\s*(\d+)(?:x\d+)?\s*$", opts)
    return f"{{width={m.group(1)}px}}" if m else ""


def md_path(p: Path) -> str:
    return f"<{p}>"


def prepare(text: str, resolver: Resolver, missing: list[str], used: list[Path]) -> str:
    out, in_fence = [], False
    text = COMMENT.sub("", text)
    for line in text.split("\n"):
        if FENCE.match(line):
            in_fence = not in_fence
            out.append(line)
            continue
        if in_fence:
            out.append(line)
            continue

        def embed(m: re.Match) -> str:
            target, opts = m.group(1).strip(), m.group(2)
            path = resolver.resolve_image(target)
            if path is None:
                missing.append(target)
                return m.group(0)
            used.append(path)
            return f"![]({md_path(path)}){width_attr(opts)}"

        def md_image(m: re.Match) -> str:
            src = m.group(2).strip("<>")
            if re.match(r"^[a-z]+://", src):
                missing.append(f"{src} (remote images are not downloaded)")
                return m.group(0)
            path = resolver.resolve_image(src)
            if path is None:
                missing.append(src)
                return m.group(0)
            used.append(path)
            return f"![]({md_path(path)}){m.group(4) or ''}"

        line = MD_IMAGE.sub(md_image, line)
        line = WIKI_EMBED.sub(embed, line)
        line = WIKI_LINK.sub(lambda m: m.group(2) or Path(m.group(1).split("#")[0]).stem, line)
        callout = CALLOUT.match(line)
        if callout:
            prefix, kind, title = callout.groups()
            line = f"{prefix}**{title or kind.capitalize()}**"
        out.append(line)
    return "\n".join(out)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("submission", type=Path)
    ap.add_argument("--source", type=Path, required=True, help="original note, used to resolve images")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--keep-typst", action="store_true", help="also write the intermediate .typ next to the PDF")
    args = ap.parse_args()

    for tool in ("pandoc", "typst"):
        if not shutil.which(tool):
            print(f"error: {tool} is not installed or not on PATH", file=sys.stderr)
            return 1

    missing: list[str] = []
    used: list[Path] = []
    prepared = prepare(args.submission.read_text(encoding="utf-8"), Resolver(args.source), missing, used)
    if missing:
        print("error: these images could not be found, so the PDF would be missing them:", file=sys.stderr)
        for m in missing:
            print(f"  - {m}", file=sys.stderr)
        return 2

    with tempfile.TemporaryDirectory() as tmp:
        md = Path(tmp) / "prepared.md"
        typ = Path(tmp) / "submission.typ"
        md.write_text(prepared, encoding="utf-8")
        subprocess.run(
            [
                "pandoc", str(md),
                "-f", "markdown+mark+tex_math_dollars-implicit_figures",
                "-t", "typst", "-s",
                "--template", str(SKILL_DIR / "assets" / "template.typ"),
                "--lua-filter", str(SKILL_DIR / "assets" / "filter.lua"),
                "-o", str(typ),
            ],
            check=True,
        )
        args.out.parent.mkdir(parents=True, exist_ok=True)
        result = subprocess.run(["typst", "compile", "--root", "/", str(typ), str(args.out)])
        if args.keep_typst:
            shutil.copy(typ, args.out.with_suffix(".typ"))
        if result.returncode != 0:
            return result.returncode

    print(f"wrote {args.out}")
    print(f"images embedded: {len(used)}")
    for p in used:
        print(f"  - {p.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
