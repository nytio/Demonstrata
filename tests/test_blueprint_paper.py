from __future__ import annotations

from pathlib import Path

from tools.blueprint_paper import (
    archive_stem,
    build_selected_metadata,
    build_glossary_entries,
    build_source_entries,
    latest_section_stem,
    LeanGlossaryEntry,
    LeanSourceEntry,
    PaperMetadata,
    parse_section_metadata,
    render_lean_appendix,
    render_lean_glossary,
    render_lean_refs,
    resolve_selected_sections,
    SectionRecord,
)


def write_section(path: Path, *, title: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "\n".join(
            [
                f"% title: {title}",
                "% short-title: Short",
                "% abstract: Example abstract.",
                "% subjclass: 03B35",
                "% keywords: Lean 4",
                "",
                r"\begin{theorem}",
                r"\lean{Biblioteca.Demonstrations.example}",
                r"\end{theorem}",
                "",
            ]
        ),
        encoding="utf-8",
    )


def test_parse_section_metadata_reads_header_comments(tmp_path: Path) -> None:
    section = tmp_path / "demo_test.tex"
    write_section(section, title="Sample Theorem")

    metadata = parse_section_metadata(section)

    assert metadata.title == "Sample Theorem"
    assert metadata.short_title == "Short"
    assert metadata.abstract == "Example abstract."


def test_build_selected_metadata_uses_single_section_metadata() -> None:
    section = SectionRecord(
        stem="demo_one",
        path=Path("demo_one.tex"),
        metadata=PaperMetadata(
            title="Single Demo",
            short_title="Single",
            abstract="One theorem.",
            subjclass="03B35",
            keywords="Lean 4",
        ),
    )

    metadata = build_selected_metadata(
        [section],
        title=None,
        short_title=None,
        abstract=None,
        subjclass=None,
        keywords=None,
        author=None,
    )

    assert metadata.title == "Single Demo"
    assert metadata.abstract == "One theorem."


def test_archive_stem_mentions_collection_size() -> None:
    sections = [
        SectionRecord("demo_a", Path("a.tex"), PaperMetadata("A", "A", "a", "03B35", "k")),
        SectionRecord("demo_b", Path("b.tex"), PaperMetadata("B", "B", "b", "03B35", "k")),
    ]

    assert archive_stem("20260402_160000", sections) == "20260402_160000_collection_2_demos"


def test_resolve_selected_sections_defaults_to_current_demo(tmp_path: Path) -> None:
    repo_root = tmp_path
    sections_dir = repo_root / "blueprint" / "src" / "sections"
    write_section(sections_dir / "demo_alpha.tex", title="Alpha")
    write_section(sections_dir / "demo_beta.tex", title="Beta")
    (repo_root / "blueprint" / ".current_demo").write_text("demo_beta\n", encoding="utf-8")

    selected = resolve_selected_sections(
        repo_root,
        requested_demos=[],
        include_all=False,
    )

    assert [section.stem for section in selected] == ["demo_beta"]


def test_latest_section_stem_prefers_content_index_order(tmp_path: Path) -> None:
    repo_root = tmp_path
    sections_dir = repo_root / "blueprint" / "src" / "sections"
    write_section(sections_dir / "demo_alpha.tex", title="Alpha")
    write_section(sections_dir / "demo_beta.tex", title="Beta")
    (repo_root / "blueprint" / "src").mkdir(parents=True, exist_ok=True)
    (repo_root / "blueprint" / "src" / "content.tex").write_text(
        "\n".join(
            [
                r"\input{sections/demo_alpha}",
                r"\input{sections/demo_beta}",
                "",
            ]
        ),
        encoding="utf-8",
    )

    records = resolve_selected_sections(
        repo_root,
        requested_demos=["demo_alpha", "demo_beta"],
        include_all=False,
    )

    assert latest_section_stem(repo_root, records) == "demo_beta"


def test_build_glossary_entries_extracts_signatures_from_matching_lean_file(tmp_path: Path) -> None:
    repo_root = tmp_path
    section_path = repo_root / "blueprint" / "src" / "sections" / "demo_20260402_000000_example.tex"
    write_section(section_path, title="Example")
    section_path.write_text(
        "\n".join(
            [
                "% title: Example",
                "",
                r"\lean{Biblioteca.Demonstrations.example_one, Biblioteca.Demonstrations.example_two}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    lean_path = (
        repo_root
        / "Biblioteca"
        / "Demonstrations"
        / "Demo_20260402_000000_example.lean"
    )
    lean_path.parent.mkdir(parents=True, exist_ok=True)
    lean_path.write_text(
        "\n".join(
            [
                "namespace Biblioteca.Demonstrations",
                "",
                "theorem example_one : True := by",
                "  trivial",
                "",
                "lemma example_two",
                "    (n : Nat) :",
                "    n = n := by",
                "  rfl",
                "",
                "end Biblioteca.Demonstrations",
                "",
            ]
        ),
        encoding="utf-8",
    )
    section = SectionRecord(
        stem="demo_20260402_000000_example",
        path=section_path,
        metadata=PaperMetadata("Example", "Example", "Abstract", "03B35", "Lean 4"),
    )

    entries = build_glossary_entries(repo_root, [section])

    assert [entry.short_name for entry in entries] == ["example_one", "example_two"]
    assert entries[0].signature == "theorem example_one : True"
    assert entries[1].signature == "lemma example_two (n : Nat) : n = n"


def test_render_lean_support_files_include_short_names_and_glossary(tmp_path: Path) -> None:
    build_dir = tmp_path / "build"
    build_dir.mkdir()
    glossary_entries = [
        LeanGlossaryEntry(
            declaration="Biblioteca.Demonstrations.example_one",
            short_name="example_one",
            label="lean-glossary:example-one",
            signature="theorem example_one : True",
        )
    ]

    refs_path = render_lean_refs(build_dir, glossary_entries)
    glossary_path = render_lean_glossary(build_dir, glossary_entries)

    refs_text = refs_path.read_text(encoding="utf-8")
    glossary_text = glossary_path.read_text(encoding="utf-8")

    assert "leanref@Biblioteca.Demonstrations.example_one" in refs_text
    assert r"\texttt{example\_one}" in refs_text
    assert r"\section*{Lean Glossary}" in glossary_text
    assert r"\texttt{example\_one}" in glossary_text
    assert r"\leanstatement{theorem example\_one : True}" in glossary_text


def test_build_source_entries_uses_matching_lean_file(tmp_path: Path) -> None:
    repo_root = tmp_path
    section_path = repo_root / "blueprint" / "src" / "sections" / "demo_20260402_000000_example.tex"
    write_section(section_path, title="Example")
    lean_path = repo_root / "Biblioteca" / "Demonstrations" / "Demo_20260402_000000_example.lean"
    lean_path.parent.mkdir(parents=True, exist_ok=True)
    lean_path.write_text("namespace Biblioteca.Demonstrations\nend Biblioteca.Demonstrations\n", encoding="utf-8")
    section = SectionRecord(
        stem="demo_20260402_000000_example",
        path=section_path,
        metadata=PaperMetadata("Example", "Example", "Abstract", "03B35", "Lean 4"),
    )

    entries = build_source_entries(repo_root, [section])

    assert entries == [
        LeanSourceEntry(
            path=lean_path,
            title="Biblioteca/Demonstrations/Demo_20260402_000000_example.lean",
        )
    ]


def test_render_lean_appendix_includes_full_source_lines(tmp_path: Path) -> None:
    build_dir = tmp_path / "build"
    build_dir.mkdir()
    lean_path = tmp_path / "Demo_example.lean"
    lean_path.write_text(
        "\n".join(
            [
                "theorem example : True := by",
                "  trivial",
                "",
            ]
        ),
        encoding="utf-8",
    )

    appendix_path = render_lean_appendix(
        build_dir,
        [
            LeanSourceEntry(
                path=lean_path,
                title="Biblioteca/Demonstrations/Demo_example.lean",
            )
        ],
    )

    appendix_text = appendix_path.read_text(encoding="utf-8")

    assert r"\section*{Anexo}" in appendix_text
    assert r"\texttt{Biblioteca/Demonstrations/Demo\_example.lean}" in appendix_text
    assert r"\leanline{theorem example : True := by}" in appendix_text
    assert r"\leanline{\leanindent{2}trivial}" in appendix_text
