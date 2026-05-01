from __future__ import annotations

import argparse
import hashlib
import json
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
DEFAULT_KEYWORDS = "Lean 4, formalized mathematics, reproducibility, theorem proving"

META_PATTERN = re.compile(r"^%\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$")
INPUT_PATTERN = re.compile(r"\\input\{sections/([^}]+)\}")
LEAN_MACRO_PATTERN = re.compile(r"\\lean\{([^}]*)\}")
DECLARATION_HEAD_PATTERN = re.compile(
    r"^\s*(theorem|lemma|def|abbrev|instance|class|structure|inductive)\s+([A-Za-z0-9_']+)\b"
)
PYGMENTS_LEXER_PATTERN = re.compile(r"^\*\s+([^:]+):\s*$")
TEXT_MODE_MATH_COMMAND_PATTERN = re.compile(
    r"(?<!\\)\\(ge|le|neq|ne|mid|nmid|to|mapsto|iff|implies|Rightarrow|leftarrow|rightarrow|infty)\b"
)


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
class MathlibManifestInfo:
    revision: str
    input_revision: str | None


@dataclass(frozen=True)
class LeanReproducibilityInfo:
    lean_version: str
    mathlib: MathlibManifestInfo
    config_files: tuple[str, ...]
    verification_output_path: Path
    axiom_probe_path: Path | None
    axiom_output_path: Path | None
    axiom_declarations: tuple[str, ...]


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
        title=title or "Demonstrata Note",
        short_title=title or "Demonstrata Note",
        abstract=(
            "This note records a Lean 4 formalization produced with the "
            "Demonstrata workflow."
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
            title="Collected Demonstrata Notes",
            short_title="Demonstrata Notes",
            abstract=(
                f"This paper collects {len(sections)} Lean-verified mathematical "
                "notes produced with Demonstrata."
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


def glossary_snippet_name(entry: LeanGlossaryEntry) -> str:
    return entry.label.split(":", maxsplit=1)[-1] + ".lean"


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


def sanitize_latex_text(text: str) -> str:
    """Wrap standalone math control sequences so metadata remains valid in text mode."""

    def replace(match: re.Match[str]) -> str:
        command = match.group(1)
        return rf"\ensuremath{{\{command}}}"

    return TEXT_MODE_MATH_COMMAND_PATTERN.sub(replace, text)


def latex_breakable_mono(text: str) -> str:
    rendered: list[str] = []
    previous: str | None = None
    alnum_run = 0
    for char in text:
        if previous is not None and char.isupper() and (previous.islower() or previous.isdigit()):
            rendered.append(r"\hspace{0pt}")

        rendered.append(latex_escape(char))
        if char in {"_", ".", "/"}:
            rendered.append(r"\hspace{0pt}")
            alnum_run = 0
        elif char.isalnum():
            alnum_run += 1
            if alnum_run >= 8:
                rendered.append(r"\hspace{0pt}")
                alnum_run = 0
        else:
            alnum_run = 0
        previous = char

    return "".join(rendered)


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
            + r"\leaninline{" + latex_breakable_mono(entry.short_name) + r"}"
            + r"}"
        )
    path = build_dir / "lean_refs.tex"
    path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    return path


def render_lean_glossary(
    build_dir: Path,
    entries: list[LeanGlossaryEntry],
    *,
    lexer_name: str,
) -> Path:
    glossary_dir = build_dir / "lean_glossary"
    lines: list[str] = []
    if entries:
        glossary_dir.mkdir(parents=True, exist_ok=True)
        lines.extend(
            [
                r"\subsection{Glossary}",
                r"\mbox{}\par\nobreak\smallskip",
                r"\begingroup",
                r"\small",
            ]
        )
        for entry in entries:
            snippet_path = glossary_dir / glossary_snippet_name(entry)
            snippet_path.write_text(entry.signature + "\n", encoding="utf-8")
            lines.extend(
                [
                    r"\noindent\hypertarget{"
                    + entry.label
                    + r"}{\leanname{"
                    + latex_breakable_mono(entry.short_name)
                    + r"}}\par\nobreak\smallskip",
                    r"\leaninputfile{" + lexer_name + r"}{"
                    + latex_detokenize(relative_tex_path(build_dir, snippet_path))
                    + r"}",
                    r"\medskip",
                ]
            )
        lines.append(r"\endgroup")
    path = build_dir / "lean_glossary.tex"
    path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    return path


def latex_detokenize(text: str) -> str:
    return r"\detokenize{" + text + r"}"


def read_lean_toolchain(repo_root: Path) -> str:
    path = repo_root / "lean-toolchain"
    return path.read_text(encoding="utf-8").strip()


def read_mathlib_manifest_info(repo_root: Path) -> MathlibManifestInfo:
    manifest_path = repo_root / "lake-manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    for package in manifest.get("packages", []):
        if package.get("name") == "mathlib":
            revision = package.get("rev")
            if not isinstance(revision, str) or not revision:
                break
            input_revision = package.get("inputRev")
            return MathlibManifestInfo(
                revision=revision,
                input_revision=input_revision if isinstance(input_revision, str) else None,
            )
    raise RuntimeError("Could not find the mathlib revision in lake-manifest.json.")


def lake_executable() -> str:
    elan_lake = Path.home() / ".elan" / "bin" / "lake"
    if elan_lake.is_file():
        return str(elan_lake)
    return shutil.which("lake") or "lake"


def write_command_output(
    path: Path,
    *,
    display_command: str,
    completed: subprocess.CompletedProcess[str],
) -> None:
    output_parts = [
        f"$ {display_command}",
        f"exit code: {completed.returncode}",
    ]
    stdout = completed.stdout.strip()
    stderr = completed.stderr.strip()
    if stdout:
        output_parts.extend(["", "stdout:", stdout])
    if stderr:
        output_parts.extend(["", "stderr:", stderr])
    if not stdout and not stderr:
        output_parts.extend(["", "(no output)"])
    path.write_text("\n".join(output_parts) + "\n", encoding="utf-8")


def capture_checked_command(
    repo_root: Path,
    output_path: Path,
    *,
    command: list[str],
    display_command: str,
) -> None:
    completed = subprocess.run(
        command,
        cwd=repo_root,
        capture_output=True,
        text=True,
    )
    write_command_output(
        output_path,
        display_command=display_command,
        completed=completed,
    )
    if completed.returncode != 0:
        raise RuntimeError(
            f"Command failed while collecting Lean reproducibility evidence: "
            f"{display_command}"
        )


def lean_module_name(repo_root: Path, lean_path: Path) -> str:
    relative = lean_path.relative_to(repo_root).with_suffix("")
    return ".".join(relative.parts)


def build_axiom_probe(
    repo_root: Path,
    repro_dir: Path,
    source_entries: list[LeanSourceEntry],
    glossary_entries: list[LeanGlossaryEntry],
) -> tuple[Path | None, tuple[str, ...]]:
    declarations: list[str] = []
    seen_declarations: set[str] = set()
    for entry in glossary_entries:
        if entry.declaration in seen_declarations:
            continue
        seen_declarations.add(entry.declaration)
        declarations.append(entry.declaration)

    if not declarations:
        return None, ()

    modules = sorted(
        {
            lean_module_name(repo_root, source_entry.path)
            for source_entry in source_entries
            if source_entry.path.is_relative_to(repo_root)
        }
    )
    if not modules:
        modules = ["Biblioteca"]
    lines = [f"import {module}" for module in modules]
    lines.append("")
    lines.extend(f"#print axioms {declaration}" for declaration in declarations)
    probe_path = repro_dir / "print_axioms.lean"
    probe_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return probe_path, tuple(declarations)


def build_lean_reproducibility_info(
    repo_root: Path,
    build_dir: Path,
    source_entries: list[LeanSourceEntry],
    glossary_entries: list[LeanGlossaryEntry],
) -> LeanReproducibilityInfo:
    repro_dir = build_dir / "lean_reproducibility"
    repro_dir.mkdir(parents=True, exist_ok=True)
    lake = lake_executable()

    verification_output_path = repro_dir / "lake_build.out"
    capture_checked_command(
        repo_root,
        verification_output_path,
        command=[lake, "build"],
        display_command="lake build",
    )

    axiom_probe_path, axiom_declarations = build_axiom_probe(
        repo_root,
        repro_dir,
        source_entries,
        glossary_entries,
    )
    axiom_output_path: Path | None = None
    if axiom_probe_path is not None:
        axiom_output_path = repro_dir / "print_axioms.out"
        probe_arg = relative_tex_path(repo_root, axiom_probe_path)
        capture_checked_command(
            repo_root,
            axiom_output_path,
            command=[lake, "env", "lean", probe_arg],
            display_command=f"lake env lean {probe_arg}",
        )

    return LeanReproducibilityInfo(
        lean_version=read_lean_toolchain(repo_root),
        mathlib=read_mathlib_manifest_info(repo_root),
        config_files=("lakefile.toml", "lake-manifest.json"),
        verification_output_path=verification_output_path,
        axiom_probe_path=axiom_probe_path,
        axiom_output_path=axiom_output_path,
        axiom_declarations=axiom_declarations,
    )


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


def render_lean_reproducibility(
    build_dir: Path,
    info: LeanReproducibilityInfo,
    *,
    lexer_name: str,
) -> Path:
    repro_dir = build_dir / "lean_reproducibility"
    repro_dir.mkdir(parents=True, exist_ok=True)

    lines = [
        r"\subsection{Reproducibility}",
        r"\mbox{}\par\nobreak\smallskip",
        r"\begingroup",
        r"\small",
        r"\noindent\begin{tabular}{@{}ll@{}}",
        r"\textbf{Lean version:} & \leaninline{"
        + latex_breakable_mono(info.lean_version)
        + r"} \\",
        r"\textbf{Project files:} & "
        + ", ".join(r"\nolinkurl{" + path + r"}" for path in info.config_files)
        + r" \\",
        r"\textbf{Verification command:} & \leaninline{lake\hspace{0pt} build} \\",
        r"\textbf{Axiom audit command:} & \leaninline{\#print\hspace{0pt} axioms}",
        r"\end{tabular}\par\smallskip",
        r"\noindent\textbf{Mathlib commit:}\par",
        r"\noindent\texttt{"
        + latex_escape(info.mathlib.revision)
        + r"}\par",
    ]
    if info.mathlib.input_revision is not None:
        lines.append(
            r"\noindent\textbf{Manifest input revision:} \texttt{"
            + latex_escape(info.mathlib.input_revision)
            + r"}\par"
        )
    lines.extend(
        [
            r"\medskip",
            r"\noindent\textbf{Captured output of \leaninline{lake\hspace{0pt} build}.}\par",
            r"\leaninputfile{text}{"
            + latex_detokenize(relative_tex_path(build_dir, info.verification_output_path))
            + r"}",
        ]
    )

    if info.axiom_probe_path is not None and info.axiom_output_path is not None:
        declarations = ", ".join(
            r"\leaninline{" + latex_breakable_mono(declaration_short_name(declaration)) + r"}"
            for declaration in info.axiom_declarations
        )
        lines.extend(
            [
                r"\noindent\textbf{Axiom queries.} "
                + declarations
                + r"\par",
                r"\leaninputfile{"
                + lexer_name
                + r"}{"
                + latex_detokenize(relative_tex_path(build_dir, info.axiom_probe_path))
                + r"}",
                r"\noindent\textbf{Captured output of the axiom queries.}\par",
                r"\leaninputfile{text}{"
                + latex_detokenize(relative_tex_path(build_dir, info.axiom_output_path))
                + r"}",
            ]
        )
    else:
        lines.append(
            r"\noindent No \leaninline{\#print\hspace{0pt} axioms} query was generated, "
            r"because no Lean declaration was referenced by the selected section.\par"
        )

    lines.append(r"\endgroup")
    path = build_dir / "lean_reproducibility.tex"
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return path


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
    safe_title = sanitize_latex_text(metadata.title)
    safe_short_title = sanitize_latex_text(metadata.short_title)
    safe_keywords = sanitize_latex_text(metadata.keywords)
    safe_abstract = sanitize_latex_text(metadata.abstract)
    content = "\n".join(
        [
            r"\documentclass[11pt]{amsart}",
            rf"\input{{{latex_path(Path('../../src/macros/common.tex'))}}}",
            rf"\input{{{latex_path(Path('../../src/macros/print.tex'))}}}",
            r"\input{lean_refs.tex}",
            rf"\title[{safe_short_title}]{{{safe_title}}}",
            rf"\author{{{metadata.author}}}",
            rf"\subjclass[2020]{{{metadata.subjclass}}}",
            rf"\keywords{{{safe_keywords}}}",
            r"\date{\today}",
            r"\begin{document}",
            rf"\begin{{abstract}}{safe_abstract}\end{{abstract}}",
            r"\maketitle",
            r"\tableofcontents" if include_toc else "",
            r"\input{selected_content.tex}",
            r"\section{Lean formalization}",
            r"\input{lean_reproducibility.tex}",
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
    reproducibility_info = build_lean_reproducibility_info(
        repo_root,
        build_dir,
        source_entries,
        glossary_entries,
    )
    render_selected_content(build_dir, sections)
    render_lean_refs(build_dir, glossary_entries)
    render_lean_glossary(build_dir, glossary_entries, lexer_name=minted_config.lexer_name)
    render_lean_reproducibility(
        build_dir,
        reproducibility_info,
        lexer_name=minted_config.lexer_name,
    )
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
