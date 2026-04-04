from __future__ import annotations

from pathlib import Path

from tools.blueprint_paper import (
    archive_stem,
    available_pygments_aliases,
    build_selected_metadata,
    build_glossary_entries,
    build_source_entries,
    latest_section_stem,
    LeanGlossaryEntry,
    MintedConfig,
    LeanSourceEntry,
    PaperMetadata,
    parse_section_metadata,
    render_lean_appendix,
    render_lean_glossary,
    render_lean_refs,
    remove_legacy_archive_pdfs,
    resolve_minted_config,
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

    stem = archive_stem(Path("."), sections)

    assert stem.startswith("collection_2_demos_")
    assert len(stem) == len("collection_2_demos_") + 10


def test_archive_stem_uses_matching_lean_filename_for_single_section(tmp_path: Path) -> None:
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

    assert archive_stem(repo_root, [section]) == "Demo_20260402_000000_example"


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
    glossary_path = render_lean_glossary(build_dir, glossary_entries, lexer_name="lean4")

    refs_text = refs_path.read_text(encoding="utf-8")
    glossary_text = glossary_path.read_text(encoding="utf-8")
    snippet_text = (
        build_dir / "lean_glossary" / "example-one.lean"
    ).read_text(encoding="utf-8")

    assert "leanref@Biblioteca.Demonstrations.example_one" in refs_text
    assert r"\texttt{example\_one}" in refs_text
    assert r"\section*{Lean Glossary}" in glossary_text
    assert r"\texttt{example\_one}" in glossary_text
    assert (
        r"\leaninputfile{lean4}{\detokenize{lean_glossary/example-one.lean}}"
        in glossary_text
    )
    assert snippet_text == "theorem example_one : True\n"


def test_render_lean_glossary_uses_unique_snippet_names_for_duplicate_short_names(tmp_path: Path) -> None:
    build_dir = tmp_path / "build"
    build_dir.mkdir()
    glossary_entries = [
        LeanGlossaryEntry(
            declaration="Biblioteca.Demonstrations.Foo.of_dvd",
            short_name="of_dvd",
            label="lean-glossary:biblioteca-demonstrations-foo-of-dvd",
            signature="theorem Foo.of_dvd : True",
        ),
        LeanGlossaryEntry(
            declaration="Biblioteca.Demonstrations.Bar.of_dvd",
            short_name="of_dvd",
            label="lean-glossary:biblioteca-demonstrations-bar-of-dvd",
            signature="theorem Bar.of_dvd : True",
        ),
    ]

    glossary_path = render_lean_glossary(build_dir, glossary_entries, lexer_name="lean4")
    glossary_text = glossary_path.read_text(encoding="utf-8")

    foo_snippet = build_dir / "lean_glossary" / "biblioteca-demonstrations-foo-of-dvd.lean"
    bar_snippet = build_dir / "lean_glossary" / "biblioteca-demonstrations-bar-of-dvd.lean"

    assert foo_snippet.read_text(encoding="utf-8") == "theorem Foo.of_dvd : True\n"
    assert bar_snippet.read_text(encoding="utf-8") == "theorem Bar.of_dvd : True\n"
    assert r"\detokenize{lean_glossary/biblioteca-demonstrations-foo-of-dvd.lean}" in glossary_text
    assert r"\detokenize{lean_glossary/biblioteca-demonstrations-bar-of-dvd.lean}" in glossary_text


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


def test_build_source_entries_supports_non_demo_prefixes(tmp_path: Path) -> None:
    repo_root = tmp_path
    section_path = repo_root / "blueprint" / "src" / "sections" / "IMO_20260402_182818_example.tex"
    write_section(section_path, title="Example")
    lean_path = repo_root / "Biblioteca" / "Demonstrations" / "IMO_20260402_182818_example.lean"
    lean_path.parent.mkdir(parents=True, exist_ok=True)
    lean_path.write_text("namespace Biblioteca.Demonstrations\nend Biblioteca.Demonstrations\n", encoding="utf-8")
    section = SectionRecord(
        stem="IMO_20260402_182818_example",
        path=section_path,
        metadata=PaperMetadata("Example", "Example", "Abstract", "03B35", "Lean 4"),
    )

    entries = build_source_entries(repo_root, [section])

    assert entries == [
        LeanSourceEntry(
            path=lean_path,
            title="Biblioteca/Demonstrations/IMO_20260402_182818_example.lean",
        )
    ]


def test_remove_legacy_archive_pdfs_deletes_old_single_demo_aliases(tmp_path: Path) -> None:
    library_dir = tmp_path / "pdf"
    library_dir.mkdir()
    archive_pdf = library_dir / "Demo_20260402_000000_example.pdf"
    legacy_pdf = library_dir / "demo_20260402_000000_example.pdf"
    timestamped_legacy_pdf = library_dir / "20260403_080000_demo_20260402_000000_example.pdf"
    archive_pdf.write_bytes(b"new")
    legacy_pdf.write_bytes(b"old")
    timestamped_legacy_pdf.write_bytes(b"old-timestamped")
    section = SectionRecord(
        stem="demo_20260402_000000_example",
        path=Path("demo_20260402_000000_example.tex"),
        metadata=PaperMetadata("Example", "Example", "Abstract", "03B35", "Lean 4"),
    )

    remove_legacy_archive_pdfs(library_dir, archive_pdf, [section])

    assert archive_pdf.is_file()
    assert not legacy_pdf.exists()
    assert not timestamped_legacy_pdf.exists()


def test_available_pygments_aliases_parses_alias_names(monkeypatch) -> None:
    def fake_run(*args, **kwargs):
        return __import__("subprocess").CompletedProcess(
            args=args,
            returncode=0,
            stdout="\n".join(
                [
                    "Lexers:",
                    "* lean, lean3:",
                    "* lean4:",
                    "",
                ]
            ),
            stderr="",
        )

    monkeypatch.setattr("tools.blueprint_paper.subprocess.run", fake_run)

    aliases = available_pygments_aliases(Path("/tmp/pygmentize"))

    assert aliases >= {"lean", "lean3", "lean4"}


def test_resolve_minted_config_prefers_repo_venv_and_lean4(tmp_path: Path, monkeypatch) -> None:
    repo_root = tmp_path
    pygmentize_path = repo_root / ".venv" / "bin" / "pygmentize"
    pygmentize_path.parent.mkdir(parents=True, exist_ok=True)
    pygmentize_path.write_text("", encoding="utf-8")

    monkeypatch.setattr(
        "tools.blueprint_paper.available_pygments_aliases",
        lambda path: {"lean", "lean3", "lean4"},
    )

    config = resolve_minted_config(repo_root)

    assert config == MintedConfig(
        lexer_name="lean4",
        pygmentize_path=pygmentize_path,
    )


def test_render_lean_appendix_uses_inputminted_with_relative_path(tmp_path: Path) -> None:
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
        lexer_name="lean4",
    )

    appendix_text = appendix_path.read_text(encoding="utf-8")

    assert r"\section*{Anexo}" in appendix_text
    assert (
        r"\subsection*{\texorpdfstring{\nolinkurl{Biblioteca/Demonstrations/Demo_example.lean}}"
        r"{Demo example.lean}}"
    ) in appendix_text
    assert r"\addcontentsline{toc}{subsection}{Demo example.lean}" in appendix_text
    assert r"\leaninputfile{lean4}{\detokenize{../Demo_example.lean}}" in appendix_text
