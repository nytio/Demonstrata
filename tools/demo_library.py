from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

from tools.blueprint_paper import write_current_demo


IMPORTS_START = "-- AUTO-IMPORTS-START"
IMPORTS_END = "-- AUTO-IMPORTS-END"
SECTIONS_START = "% AUTO-SECTIONS-START"
SECTIONS_END = "% AUTO-SECTIONS-END"


@dataclass(frozen=True)
class DemoNames:
    stamp: str
    slug: str
    lean_module: str
    lean_import: str
    lean_path: Path
    tex_stem: str
    tex_path: Path


def slugify(raw: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", raw.strip().lower())
    slug = slug.strip("_")
    if not slug:
        raise ValueError("title must contain at least one alphanumeric character")
    return slug


def timestamp_now() -> str:
    return datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")


def build_names(title: str, stamp: str | None = None) -> DemoNames:
    normalized_stamp = stamp or timestamp_now()
    slug = slugify(title)
    lean_module = f"Demo_{normalized_stamp}_{slug}"
    tex_stem = f"demo_{normalized_stamp}_{slug}"
    return DemoNames(
        stamp=normalized_stamp,
        slug=slug,
        lean_module=lean_module,
        lean_import=f"import Biblioteca.Demonstrations.{lean_module}",
        lean_path=Path("Biblioteca") / "Demonstrations" / f"{lean_module}.lean",
        tex_stem=tex_stem,
        tex_path=Path("blueprint") / "src" / "sections" / f"{tex_stem}.tex",
    )


def insert_before_marker(path: Path, marker: str, line: str) -> None:
    content = path.read_text(encoding="utf-8").splitlines()
    if line in content:
        return
    try:
        marker_index = content.index(marker)
    except ValueError as err:
        raise ValueError(f"marker '{marker}' not found in {path}") from err
    content.insert(marker_index, line)
    path.write_text("\n".join(content) + "\n", encoding="utf-8")


def lean_template(title: str) -> str:
    return (
        "namespace Biblioteca.Demonstrations\n\n"
        "/-\n"
        f"Demonstration stub for: {title}\n"
        "Replace this comment with definitions and theorems.\n"
        "-/\n\n"
        "end Biblioteca.Demonstrations\n"
    )


def tex_template(title: str) -> str:
    return (
        f"% title: {title.title()}\n"
        "% short-title: Lean Demonstration\n"
        "% abstract: Replace with an AMS-style abstract for this demonstration.\n"
        "% subjclass: 03B35\n"
        "% keywords: Lean 4, formalized mathematics, theorem proving\n"
        "% author: Biblioteca de Demostraciones\n\n"
        f"\\subsection{{{title}}}\n\n"
        "\\notready\n"
        "This demonstration entry was scaffolded automatically. Add a theorem, "
        "its `\\lean{...}` reference, and a mathematical proof sketch here.\n"
    )


def ensure_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        raise FileExistsError(f"refusing to overwrite existing file: {path}")
    path.write_text(content, encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Create timestamped Lean and blueprint files for a new demonstration."
    )
    parser.add_argument("title", help="Human-readable title for the demonstration.")
    parser.add_argument(
        "--timestamp",
        help="Optional timestamp override in YYYYMMDD_HHMMSS format.",
    )
    return parser


def scaffold_demo(repo_root: Path, title: str, stamp: str | None = None) -> DemoNames:
    names = build_names(title, stamp=stamp)
    ensure_file(repo_root / names.lean_path, lean_template(title))
    ensure_file(repo_root / names.tex_path, tex_template(title))
    insert_before_marker(
        repo_root / "Biblioteca" / "Demonstrations.lean",
        IMPORTS_END,
        names.lean_import,
    )
    insert_before_marker(
        repo_root / "blueprint" / "src" / "content.tex",
        SECTIONS_END,
        rf"\input{{sections/{names.tex_stem}}}",
    )
    write_current_demo(repo_root, names.tex_stem)
    return names


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    repo_root = Path(__file__).resolve().parents[1]
    names = scaffold_demo(repo_root, args.title, stamp=args.timestamp)
    print(f"Lean file: {names.lean_path}")
    print(f"Blueprint file: {names.tex_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
