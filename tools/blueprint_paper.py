from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import re
import shutil

from tools.demonstration_names import infer_lean_stem_from_section_stem, title_slug_from_stem


STATE_FILE = Path("blueprint/.current_demo")
DEFAULT_AUTHOR = "Mario Hernández M."
DEFAULT_SUBJCLASS = "03B35"
DEFAULT_KEYWORDS = "Lean 4, formalized mathematics, theorem proving"

META_PATTERN = re.compile(r"^%\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$")
INPUT_PATTERN = re.compile(r"\\input\{sections/([^}]+)\}")
LEAN_MACRO_PATTERN = re.compile(r"\\lean\{([^}]*)\}")
DECLARATION_HEAD_PATTERN = re.compile(
    r"^\s*(theorem|lemma|def|abbrev|instance|class|structure|inductive)\s+([A-Za-z0-9_']+)\b"
)
PYGMENTS_LEXER_PATTERN = re.compile(r"^\*\s+([^:]+):\s*$")


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


@dataclass(frozen=True)
class LeanGlossaryEntry:
    declaration: str
    short_name: str
    label: str
    signature: str


@dataclass(frozen=True)
class LeanSourceEntry:
    path: Path
    title: str


@dataclass(frozen=True)
class MintedConfig:
    lexer_name: str
    pygmentize_path: Path


def latex_path(path: Path) -> str:
    return path.as_posix()


def relative_tex_path(from_dir: Path, target: Path) -> str:
    return latex_path(Path(os.path.relpath(target, from_dir)))


def default_metadata_for_stem(stem: str) -> PaperMetadata:
    title_words = title_slug_from_stem(stem).split("_")
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


def archive_stem(repo_root: Path, sections: list[SectionRecord]) -> str:
    if len(sections) == 1:
        lean_path = infer_section_lean_path(repo_root, sections[0])
        if lean_path is not None:
            return lean_path.stem
        return sections[0].stem

    archive_key = "\n".join(section.stem for section in sections)
    digest = hashlib.sha1(archive_key.encode("utf-8")).hexdigest()[:10]
    return f"collection_{len(sections)}_demos_{digest}"


def remove_legacy_archive_pdfs(
    library_dir: Path,
    archive_pdf: Path,
    sections: list[SectionRecord],
) -> None:
    if len(sections) != 1:
        return

    section_stem = sections[0].stem
    legacy_paths = {library_dir / f"{section_stem}.pdf"}
    legacy_paths.update(library_dir.glob(f"*_{section_stem}.pdf"))
    for legacy_path in sorted(legacy_paths):
        if legacy_path == archive_pdf:
            continue
        if legacy_path.is_file():
            legacy_path.unlink()


def render_selected_content(build_dir: Path, sections: list[SectionRecord]) -> Path:
    lines = [rf"\input{{{latex_path(Path('../../src/sections') / section.path.name)}}}" for section in sections]
    path = build_dir / "selected_content.tex"
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return path


def declaration_short_name(declaration: str) -> str:
    return declaration.rsplit(".", maxsplit=1)[-1]


def declaration_label(declaration: str) -> str:
    slug = re.sub(r"[^A-Za-z0-9]+", "-", declaration).strip("-").lower()
    return f"lean-glossary:{slug or 'entry'}"


def latex_escape(text: str) -> str:
    replacements = {
        "\\": r"\textbackslash{}",
        "{": r"\{",
        "}": r"\}",
        "_": r"\_",
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "^": r"\^{}",
        "~": r"\textasciitilde{}",
    }
    return "".join(replacements.get(char, char) for char in text)


def extract_declarations_from_text(content: str) -> list[str]:
    declarations: list[str] = []
    for raw_names in LEAN_MACRO_PATTERN.findall(content):
        for raw_name in raw_names.split(","):
            declaration = raw_name.strip()
            if declaration:
                declarations.append(declaration)
    return declarations


def collect_section_declarations(sections: list[SectionRecord]) -> list[str]:
    ordered: dict[str, None] = {}
    for section in sections:
        content = section.path.read_text(encoding="utf-8")
        for declaration in extract_declarations_from_text(content):
            ordered.setdefault(declaration, None)
    return list(ordered)


def infer_section_lean_path(repo_root: Path, section: SectionRecord) -> Path | None:
    lean_name = infer_lean_stem_from_section_stem(section.stem)
    path = repo_root / "Biblioteca" / "Demonstrations" / f"{lean_name}.lean"
    return path if path.is_file() else None


def cleanup_signature(signature: str) -> str:
    compact = re.sub(r"\s+", " ", signature).strip()
    compact = re.sub(r"\s*:=\s*by\s*$", "", compact)
    compact = re.sub(r"\s*:=\s*$", "", compact)
    compact = re.sub(r"\s*where\s*$", "", compact)
    return compact.strip()


def extract_declaration_signature(file_path: Path, declaration: str) -> str | None:
    short_name = declaration_short_name(declaration)
    lines = file_path.read_text(encoding="utf-8").splitlines()
    for start, line in enumerate(lines):
        match = DECLARATION_HEAD_PATTERN.match(line)
        if match is None or match.group(2) != short_name:
            continue
        collected: list[str] = []
        for raw_line in lines[start:]:
            stripped = raw_line.strip()
            if not stripped and collected:
                break
            if not stripped:
                continue
            collected.append(stripped)
            if ":=" in stripped or stripped.endswith("where"):
                break
        if not collected:
            return None
        return cleanup_signature(" ".join(collected))
    return None


def resolve_declaration_signature(
    repo_root: Path,
    declaration: str,
    section_candidates: dict[str, list[Path]],
) -> str:
    checked: set[Path] = set()
    for path in section_candidates.get(declaration, []):
        checked.add(path)
        signature = extract_declaration_signature(path, declaration)
        if signature is not None:
            return signature

    if declaration.startswith("Biblioteca."):
        for path in sorted((repo_root / "Biblioteca").rglob("*.lean")):
            if path in checked:
                continue
            signature = extract_declaration_signature(path, declaration)
            if signature is not None:
                return signature

    return declaration


def build_glossary_entries(repo_root: Path, sections: list[SectionRecord]) -> list[LeanGlossaryEntry]:
    declarations = collect_section_declarations(sections)
    section_candidates: dict[str, list[Path]] = {declaration: [] for declaration in declarations}

    for section in sections:
        lean_path = infer_section_lean_path(repo_root, section)
        if lean_path is None:
            continue
        for declaration in extract_declarations_from_text(section.path.read_text(encoding="utf-8")):
            section_candidates.setdefault(declaration, []).append(lean_path)

    return [
        LeanGlossaryEntry(
            declaration=declaration,
            short_name=declaration_short_name(declaration),
            label=declaration_label(declaration),
            signature=resolve_declaration_signature(repo_root, declaration, section_candidates),
        )
        for declaration in declarations
    ]


def build_source_entries(repo_root: Path, sections: list[SectionRecord]) -> list[LeanSourceEntry]:
    entries: list[LeanSourceEntry] = []
    seen: set[Path] = set()
    for section in sections:
        lean_path = infer_section_lean_path(repo_root, section)
        if lean_path is None or lean_path in seen:
            continue
        seen.add(lean_path)
        entries.append(
            LeanSourceEntry(
                path=lean_path,
                title=lean_path.relative_to(repo_root).as_posix(),
            )
        )
    return entries


def render_lean_refs(build_dir: Path, entries: list[LeanGlossaryEntry]) -> Path:
    lines: list[str] = []
    for entry in entries:
        lines.append(
            r"\expandafter\def\csname leanref@" + entry.declaration + r"\endcsname{"
            + r"\hyperlink{" + entry.label + r"}{\texttt{" + latex_escape(entry.short_name) + r"}}"
            + r"}"
        )
    path = build_dir / "lean_refs.tex"
    path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    return path


def render_lean_glossary(build_dir: Path, entries: list[LeanGlossaryEntry]) -> Path:
    lines: list[str] = []
    if entries:
        lines.extend(
            [
                r"\section*{Lean Glossary}",
                r"\addcontentsline{toc}{section}{Lean Glossary}",
                r"\begingroup",
                r"\small",
            ]
        )
        for entry in entries:
            lines.extend(
                [
                    r"\noindent\hypertarget{"
                    + entry.label
                    + r"}{\texttt{"
                    + latex_escape(entry.short_name)
                    + r"}}\par",
                    r"\leanstatement{" + latex_escape(entry.signature) + r"}",
                ]
            )
        lines.append(r"\endgroup")
    path = build_dir / "lean_glossary.tex"
    path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    return path


def latex_detokenize(text: str) -> str:
    return r"\detokenize{" + text + r"}"


def available_pygments_aliases(pygmentize_path: Path) -> set[str]:
    completed = subprocess.run(
        [str(pygmentize_path), "-L", "lexers"],
        check=True,
        capture_output=True,
        text=True,
    )
    aliases: set[str] = set()
    for raw_line in completed.stdout.splitlines():
        match = PYGMENTS_LEXER_PATTERN.match(raw_line.strip())
        if match is None:
            continue
        aliases.update(alias.strip() for alias in match.group(1).split(","))
    return aliases


def resolve_minted_config(repo_root: Path) -> MintedConfig:
    venv_pygmentize = repo_root / ".venv" / "bin" / "pygmentize"
    if venv_pygmentize.is_file():
        pygmentize_path = venv_pygmentize
    else:
        resolved = shutil.which("pygmentize")
        if resolved is None:
            raise RuntimeError(
                "Pygments is required to build blueprint PDFs with minted, "
                "but no 'pygmentize' executable was found."
            )
        pygmentize_path = Path(resolved)

    aliases = available_pygments_aliases(pygmentize_path)
    if "lean4" in aliases:
        return MintedConfig(lexer_name="lean4", pygmentize_path=pygmentize_path)
    if "lean" in aliases:
        return MintedConfig(lexer_name="lean", pygmentize_path=pygmentize_path)
    raise RuntimeError(
        "The available Pygments installation does not provide a Lean lexer."
    )


def render_lean_appendix(
    build_dir: Path,
    entries: list[LeanSourceEntry],
    *,
    lexer_name: str,
) -> Path:
    lines: list[str] = []
    if entries:
        lines.extend(
            [
                r"\section*{Anexo}",
                r"\addcontentsline{toc}{section}{Anexo}",
            ]
        )
        for entry in entries:
            bookmark_title = entry.path.name.replace("_", " ")
            lines.extend(
                [
                    r"\subsection*{\texorpdfstring{\nolinkurl{"
                    + entry.title
                    + r"}}{"
                    + bookmark_title
                    + r"}}",
                    r"\addcontentsline{toc}{subsection}{" + latex_escape(bookmark_title) + r"}",
                    r"\leaninputfile{"
                    + lexer_name
                    + r"}{"
                    + latex_detokenize(relative_tex_path(build_dir, entry.path))
                    + r"}",
                ]
            )
    path = build_dir / "lean_appendix.tex"
    path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
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
            r"\input{lean_refs.tex}",
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
            r"\input{lean_glossary.tex}",
            r"\input{lean_appendix.tex}",
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


def run_latexmk(build_dir: Path, *, minted_config: MintedConfig) -> None:
    command = [
        "latexmk",
        "-xelatex",
        "-shell-escape",
        "-interaction=nonstopmode",
        "-halt-on-error",
        "-file-line-error",
        "paper.tex",
    ]
    env = os.environ.copy()
    env["PATH"] = str(minted_config.pygmentize_path.parent) + os.pathsep + env.get("PATH", "")
    subprocess.run(command, cwd=build_dir, env=env, check=True)


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
    stem = archive_stem(repo_root, sections)
    build_dir = repo_root / "blueprint" / "build" / f"{timestamp}_{stem}"
    build_dir.mkdir(parents=True, exist_ok=True)

    minted_config = resolve_minted_config(repo_root)
    glossary_entries = build_glossary_entries(repo_root, sections)
    source_entries = build_source_entries(repo_root, sections)
    render_selected_content(build_dir, sections)
    render_lean_refs(build_dir, glossary_entries)
    render_lean_glossary(build_dir, glossary_entries)
    render_lean_appendix(build_dir, source_entries, lexer_name=minted_config.lexer_name)
    render_paper_tex(build_dir, metadata, include_toc=len(sections) > 1)
    run_latexmk(build_dir, minted_config=minted_config)

    pdf_path = build_dir / "paper.pdf"
    library_dir = repo_root / "blueprint" / "library" / "pdf"
    library_dir.mkdir(parents=True, exist_ok=True)
    archive_pdf = library_dir / f"{stem}.pdf"
    remove_legacy_archive_pdfs(library_dir, archive_pdf, sections)
    archive_pdf.write_bytes(pdf_path.read_bytes())

    print(f"Build directory: {build_dir}")
    print(f"Archived PDF: {archive_pdf}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
