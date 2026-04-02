from __future__ import annotations

from pathlib import Path

from tools.blueprint_paper import (
    archive_stem,
    build_selected_metadata,
    latest_section_stem,
    PaperMetadata,
    parse_section_metadata,
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
