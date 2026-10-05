#!/usr/bin/env python3
"""Render a bedtime-reading Markdown file to a dark, phone-shaped PDF via pandoc and Typst.

Usage: build.py READING.md --out OUT.pdf [--preview DIR]

Image paths in READING.md resolve relative to its folder.
--preview writes one PNG per page to DIR for a visual check.
"""

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent


CODE_WIDTH = 38


def long_code_lines(md: str) -> list[str]:
    long, in_fence = [], False
    for line in md.split("\n"):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
        elif in_fence and len(line) > CODE_WIDTH:
            long.append(line)
    return long


def body_words(md: str) -> int:
    md = re.sub(r"\A---\n.*?\n---\n", "", md, flags=re.S)
    md = re.sub(r"```.*?```", "", md, flags=re.S)
    return len(re.findall(r"\w+", md))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("reading", type=Path)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--preview", type=Path, help="write page PNGs here")
    args = ap.parse_args()

    for tool in ("pandoc", "typst"):
        if not shutil.which(tool):
            print(f"error: {tool} is not installed or not on PATH", file=sys.stderr)
            return 1

    src = args.reading.resolve()
    # The .typ must sit next to the Markdown so relative image paths still resolve.
    typ = src.parent / f".{src.stem}.typ"
    try:
        subprocess.run(
            [
                "pandoc", str(src),
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
        if result.returncode != 0:
            return result.returncode
        if args.preview:
            args.preview.mkdir(parents=True, exist_ok=True)
            for old in args.preview.glob("side-*.png"):
                old.unlink()
            subprocess.run(
                ["typst", "compile", "--root", "/", "--format", "png", "--ppi", "110",
                 str(typ), str(args.preview / "side-{0p}.png")],
                check=True,
            )
    finally:
        typ.unlink(missing_ok=True)

    pages = len(re.findall(rb"/Type\s*/Page\b", args.out.read_bytes()))
    text = src.read_text(encoding="utf-8")
    words = body_words(text)
    print(f"wrote {args.out}")
    print(f"pages: {pages}, words: {words}, reading time: ~{round(words / 200)} min")
    if args.preview:
        print(f"preview: {args.preview}")
    long = long_code_lines(text)
    if long:
        print(f"warning: {len(long)} code lines exceed {CODE_WIDTH} characters and will wrap:")
        for line in long:
            print(f"  {line}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
