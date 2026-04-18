from __future__ import annotations

from pathlib import Path

from tools.demo_library import build_names, insert_before_marker, slugify, tex_template


def test_slugify_normalizes_to_lowercase_underscored_words() -> None:
    assert slugify("Odd Numbers Sum!") == "odd_numbers_sum"


def test_build_names_creates_timestamped_paths() -> None:
    names = build_names("Odd Numbers Sum", stamp="20260402_155130")

    assert names.lean_module == "Demo_20260402_155130_odd_numbers_sum"
    assert names.lean_path == Path(
        "Biblioteca/Demonstrations/Demo_20260402_155130_odd_numbers_sum.lean"
    )
    assert names.tex_path == Path(
        "blueprint/src/sections/demo_20260402_155130_odd_numbers_sum.tex"
    )


def test_build_names_accepts_custom_prefix() -> None:
    names = build_names("Least Norwegian Number", stamp="20260402_182818", prefix="IMO")

    assert names.prefix == "IMO"
    assert names.lean_module == "IMO_20260402_182818_least_norwegian_number"
    assert names.lean_path == Path(
        "Biblioteca/Demonstrations/IMO_20260402_182818_least_norwegian_number.lean"
    )
    assert names.tex_path == Path(
        "blueprint/src/sections/IMO_20260402_182818_least_norwegian_number.tex"
    )


def test_insert_before_marker_adds_line_once(tmp_path: Path) -> None:
    target = tmp_path / "index.txt"
    target.write_text("a\nMARKER\nb\n", encoding="utf-8")

    insert_before_marker(target, "MARKER", "new-line")
    insert_before_marker(target, "MARKER", "new-line")

    assert target.read_text(encoding="utf-8") == "a\nnew-line\nMARKER\nb\n"


def test_tex_template_comments_problemstatement_for_demo_prefix() -> None:
    template = tex_template("Odd Numbers Sum", prefix="Demo")

    assert "% \\begin{problemstatement}" in template
    assert "Replace this block with the original problem statement in LaTeX." not in template


def test_tex_template_activates_problemstatement_for_named_source_prefix() -> None:
    template = tex_template("Least Norwegian Number", prefix="IMO")

    assert "\\begin{problemstatement}" in template
    assert "Replace this block with the original problem statement in LaTeX." in template


def test_tex_template_mentions_alignment_with_lean_argument() -> None:
    template = tex_template("Odd Numbers Sum", prefix="Demo")

    assert "Keep this LaTeX exposition aligned with the Lean proof" in template
    assert "without changing the Lean file" in template
