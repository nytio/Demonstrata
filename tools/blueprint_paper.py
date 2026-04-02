from __future__ import annotations

import argparse
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import re


STATE_FILE = Path("blueprint/.current_demo")
DEFAULT_AUTHOR = "Biblioteca de Demostraciones"
DEFAULT_SUBJCLASS = "03B35"
DEFAULT_KEYWORDS = "Lean 4, formalized mathematics, theorem proving"

META_PATTERN = re.compile(r"^%\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$")
INPUT_PATTERN = re.compile(r"\\input\{sections/([^}]+)\}")


@dataclass(frozen=True)
class PaperMetadata:
    title: str
    short_title: str
    abstract: str
    subjclass: str
    keywords: str
    author: str = DEFAULT_AUTHOR


@dataclass(frozen=True)
class SectionRecord:
    stem: str
    path: Path
    metadata: PaperMetadata


def latex_path(path: Path) -> str:
    return path.as_posix()


def default_metadata_for_stem(stem: str) -> PaperMetadata:
    title_words = stem.removeprefix("demo_").split("_")
    title = " ".join(word.capitalize() for word in title_words if word)
    return PaperMetadata(
        title=title or "Lean Demonstration",
        short_title=title or "Lean Demonstration",
        abstract=(
            "This note records a Lean 4 formalization from the Biblioteca "
            "demonstrations library."
        ),
        subjclass=DEFAULT_SUBJCLASS,
        keywords=DEFAULT_KEYWORDS,
    )


def parse_section_metadata(path: Path) -> PaperMetadata:
    values: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            if values:
                break
            continue
        match = META_PATTERN.match(line)
        if match is None:
            break
        key = match.group(1).strip().lower()
        values[key] = match.group(2).strip()

    defaults = default_metadata_for_stem(path.stem)
    title = values.get("title", defaults.title)
    short_title = values.get("short-title", values.get("short_title", title))
    abstract = values.get("abstract", defaults.abstract)
    subjclass = values.get("subjclass", defaults.subjclass)
    keywords = values.get("keywords", defaults.keywords)
    author = values.get("author", defaults.author)

    return PaperMetadata(
        title=title,
        short_title=short_title,
        abstract=abstract,
        subjclass=subjclass,
        keywords=keywords,
        author=author,
    )


def list_section_records(repo_root: Path) -> list[SectionRecord]:
    sections_dir = repo_root / "blueprint" / "src" / "sections"
    records: list[SectionRecord] = []
    for path in sorted(sections_dir.glob("*.tex")):
        records.append(
            SectionRecord(
                stem=path.stem,
                path=path,
                metadata=parse_section_metadata(path),
            )
        )
    return records


def normalize_demo_name(raw: str) -> str:
    candidate = Path(raw).name
    if candidate.endswith(".tex"):
        candidate = candidate[:-4]
    return candidate


def write_current_demo(repo_root: Path, stem: str) -> None:
    state_path = repo_root / STATE_FILE
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(f"{stem}\n", encoding="utf-8")


def read_current_demo(repo_root: Path) -> str | None:
    state_path = repo_root / STATE_FILE
    if not state_path.is_file():
        return None
    raw = state_path.read_text(encoding="utf-8").strip()
    return raw or None


def latest_section_stem(repo_root: Path, records: list[SectionRecord]) -> str:
    if not records:
        raise FileNotFoundError("No blueprint sections found.")
    content_index = repo_root / "blueprint" / "src" / "content.tex"
    if content_index.is_file():
        indexed_stems = INPUT_PATTERN.findall(content_index.read_text(encoding="utf-8"))
        for stem in reversed(indexed_stems):
            for record in records:
                if record.stem == stem:
                    return stem
    latest = max(records, key=lambda record: record.path.stat().st_mtime)
    return latest.stem


def resolve_selected_sections(
    repo_root: Path,
    *,
    requested_demos: list[str],
    include_all: bool,
) -> list[SectionRecord]:
    records = list_section_records(repo_root)
    by_stem = {record.stem: record for record in records}

    if include_all:
        return records

    if requested_demos:
        stems = [normalize_demo_name(item) for item in requested_demos]
    else:
        current = read_current_demo(repo_root)
        if current is None or current not in by_stem:
            current = latest_section_stem(repo_root, records)
        stems = [current]

    missing = [stem for stem in stems if stem not in by_stem]
    if missing:
        missing_list = ", ".join(sorted(missing))
        raise FileNotFoundError(f"Unknown blueprint section(s): {missing_list}")

    return [by_stem[stem] for stem in stems]


def build_selected_metadata(
    sections: list[SectionRecord],
    *,
    title: str | None,
    short_title: str | None,
    abstract: str | None,
    subjclass: str | None,
    keywords: str | None,
    author: str | None,
) -> PaperMetadata:
    if len(sections) == 1:
        base = sections[0].metadata
    else:
        base = PaperMetadata(
            title="Collected Lean Demonstrations",
            short_title="Lean Demonstrations",
            abstract=(
                f"This paper collects {len(sections)} formalized demonstrations "
                "from the Biblioteca Lean library."
            ),
            subjclass=DEFAULT_SUBJCLASS,
            keywords=DEFAULT_KEYWORDS,
            author=DEFAULT_AUTHOR,
        )

    return PaperMetadata(
        title=title or base.title,
        short_title=short_title or base.short_title,
        abstract=abstract or base.abstract,
        subjclass=subjclass or base.subjclass,
        keywords=keywords or base.keywords,
        author=author or base.author,
    )


def archive_stem(timestamp: str, sections: list[SectionRecord]) -> str:
    if len(sections) == 1:
        return f"{timestamp}_{sections[0].stem}"
    return f"{timestamp}_collection_{len(sections)}_demos"


def render_selected_content(build_dir: Path, sections: list[SectionRecord]) -> Path:
    lines = [rf"\input{{{latex_path(Path('../../src/sections') / section.path.name)}}}" for section in sections]
    path = build_dir / "selected_content.tex"
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return path


def render_paper_tex(
    build_dir: Path,
    metadata: PaperMetadata,
    *,
    include_toc: bool,
) -> Path:
    content = "\n".join(
        [
            r"\documentclass[11pt]{amsart}",
            rf"\input{{{latex_path(Path('../../src/macros/common.tex'))}}}",
            rf"\input{{{latex_path(Path('../../src/macros/print.tex'))}}}",
            rf"\title[{metadata.short_title}]{{{metadata.title}}}",
            rf"\author{{{metadata.author}}}",
            rf"\subjclass[2020]{{{metadata.subjclass}}}",
            rf"\keywords{{{metadata.keywords}}}",
            r"\date{\today}",
            r"\begin{document}",
            rf"\begin{{abstract}}{metadata.abstract}\end{{abstract}}",
            r"\maketitle",
            r"\tableofcontents" if include_toc else "",
            r"\input{selected_content.tex}",
            r"\end{document}",
            "",
        ]
    )
    path = build_dir / "paper.tex"
    path.write_text(content, encoding="utf-8")
    return path


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Build an AMS-style PDF for the current demonstration or an explicit "
            "collection of blueprint sections."
        )
    )
    parser.add_argument("--all", action="store_true", help="Build a paper with all sections.")
    parser.add_argument(
        "--demo",
        action="append",
        default=[],
        help="Section stem or .tex filename to include. Repeat for a collection.",
    )
    parser.add_argument("--title", help="Override the paper title.")
    parser.add_argument("--short-title", help="Override the running-head title.")
    parser.add_argument("--abstract", help="Override the abstract.")
    parser.add_argument("--subjclass", help="Override the 2020 MSC classification.")
    parser.add_argument("--keywords", help="Override the keywords.")
    parser.add_argument("--author", help="Override the author line.")
    return parser


def timestamp_now() -> str:
    return datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")


def run_latexmk(build_dir: Path) -> None:
    command = [
        "latexmk",
        "-xelatex",
        "-interaction=nonstopmode",
        "-halt-on-error",
        "-file-line-error",
        "paper.tex",
    ]
    subprocess.run(command, cwd=build_dir, check=True)


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parents[1]
    sections = resolve_selected_sections(
        repo_root,
        requested_demos=args.demo,
        include_all=args.all,
    )
    metadata = build_selected_metadata(
        sections,
        title=args.title,
        short_title=args.short_title,
        abstract=args.abstract,
        subjclass=args.subjclass,
        keywords=args.keywords,
        author=args.author,
    )

    timestamp = timestamp_now()
    stem = archive_stem(timestamp, sections)
    build_dir = repo_root / "blueprint" / "build" / stem
    build_dir.mkdir(parents=True, exist_ok=True)

    render_selected_content(build_dir, sections)
    render_paper_tex(build_dir, metadata, include_toc=len(sections) > 1)
    run_latexmk(build_dir)

    pdf_path = build_dir / "paper.pdf"
    library_dir = repo_root / "blueprint" / "library" / "pdf"
    library_dir.mkdir(parents=True, exist_ok=True)
    archive_pdf = library_dir / f"{stem}.pdf"
    archive_pdf.write_bytes(pdf_path.read_bytes())

    print(f"Build directory: {build_dir}")
    print(f"Archived PDF: {archive_pdf}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
