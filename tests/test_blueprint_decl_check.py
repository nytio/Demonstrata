from __future__ import annotations

from pathlib import Path

from tools.blueprint_decl_check import (
    LeanReference,
    collect_references,
    extract_references,
    render_check_file,
    ProjectConfig,
)


def test_extract_references_reads_multiple_names_from_macro(tmp_path: Path) -> None:
    tex_file = tmp_path / "content.tex"
    tex_file.write_text(
        "\\lean{Mimate.foo, Mathlib.Bar.baz}\n"
        "\\lean{Mimate.qux}\n",
        encoding="utf-8",
    )

    references = extract_references(tex_file)

    assert references == [
        LeanReference("Mimate.foo", tex_file, 1),
        LeanReference("Mathlib.Bar.baz", tex_file, 1),
        LeanReference("Mimate.qux", tex_file, 2),
    ]


def test_collect_references_scans_nested_tex_files(tmp_path: Path) -> None:
    nested = tmp_path / "sections"
    nested.mkdir()
    (tmp_path / "content.tex").write_text("\\lean{Mimate.alpha}\n", encoding="utf-8")
    (nested / "extra.tex").write_text("\\lean{Mimate.beta}\n", encoding="utf-8")

    references = collect_references(tmp_path)

    assert [reference.declaration for reference in references] == [
        "Mimate.alpha",
        "Mimate.beta",
    ]


def test_render_check_file_includes_imports_and_checks(tmp_path: Path) -> None:
    tex_file = tmp_path / "content.tex"
    references = [LeanReference("Mimate.zmod_three_mul_five", tex_file, 7)]
    config = ProjectConfig(repo_root=tmp_path, lean_libs=("Mathlib", "Mimate"))

    rendered, line_map = render_check_file(config, references)

    assert "import Mathlib" in rendered
    assert "import Mimate" in rendered
    assert "#check Mimate.zmod_three_mul_five" in rendered
    assert line_map[max(line_map)] == references[0]
