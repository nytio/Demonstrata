from __future__ import annotations

from pathlib import Path

from tools.demo_library import build_names, insert_before_marker, slugify


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


def test_insert_before_marker_adds_line_once(tmp_path: Path) -> None:
    target = tmp_path / "index.txt"
    target.write_text("a\nMARKER\nb\n", encoding="utf-8")

    insert_before_marker(target, "MARKER", "new-line")
    insert_before_marker(target, "MARKER", "new-line")

    assert target.read_text(encoding="utf-8") == "a\nnew-line\nMARKER\nb\n"
