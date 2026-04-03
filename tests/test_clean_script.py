from __future__ import annotations

import subprocess
from pathlib import Path


def test_clean_script_removes_only_disposable_artifacts(tmp_path: Path) -> None:
    source_script = Path(__file__).resolve().parents[1] / "clean.sh"
    clean_script = tmp_path / "clean.sh"
    clean_script.write_text(source_script.read_text(encoding="utf-8"), encoding="utf-8")
    clean_script.chmod(0o755)

    build_dir = tmp_path / "blueprint" / "build"
    nested_build_dir = build_dir / "nested"
    nested_build_dir.mkdir(parents=True)
    (nested_build_dir / "paper.pdf").write_text("temporary build pdf", encoding="utf-8")
    (nested_build_dir / "paper.log").write_text("temporary log", encoding="utf-8")
    (build_dir / "print.out").write_text("temporary top-level build file", encoding="utf-8")

    pytest_cache = tmp_path / ".pytest_cache" / "v" / "cache"
    pytest_cache.mkdir(parents=True)
    (pytest_cache / "nodeids").write_text("cached data", encoding="utf-8")

    script_pycache = tmp_path / "scripts" / "__pycache__"
    script_pycache.mkdir(parents=True)
    (script_pycache / "tool.cpython-312.pyc").write_bytes(b"pyc")
    (tmp_path / "scripts" / "keep.sh").write_text("#!/usr/bin/env bash\n", encoding="utf-8")

    tests_pyc = tmp_path / "tests" / "stale.pyc"
    tests_pyc.parent.mkdir(parents=True)
    tests_pyc.write_bytes(b"pyc")

    tools_pycache = tmp_path / "tools" / "__pycache__"
    tools_pycache.mkdir(parents=True)
    (tools_pycache / "helper.cpython-312.pyc").write_bytes(b"pyc")
    (tmp_path / "tools" / "keep.py").write_text("VALUE = 1\n", encoding="utf-8")

    lean_file = tmp_path / "Biblioteca" / "Demonstrations" / "Demo_keep.lean"
    lean_file.parent.mkdir(parents=True)
    lean_file.write_text("theorem keep : True := by trivial\n", encoding="utf-8")

    tex_file = tmp_path / "blueprint" / "src" / "sections" / "demo_keep.tex"
    tex_file.parent.mkdir(parents=True)
    tex_file.write_text("% keep\n", encoding="utf-8")

    archived_pdf = tmp_path / "blueprint" / "library" / "pdf" / "keep.pdf"
    archived_pdf.parent.mkdir(parents=True)
    archived_pdf.write_text("archived pdf", encoding="utf-8")

    current_demo = tmp_path / "blueprint" / ".current_demo"
    current_demo.write_text("demo_keep\n", encoding="utf-8")

    subprocess.run(["bash", str(clean_script)], cwd=tmp_path, check=True)

    assert build_dir.is_dir()
    assert list(build_dir.iterdir()) == []
    assert not nested_build_dir.exists()
    assert not pytest_cache.exists()
    assert not script_pycache.exists()
    assert not tests_pyc.exists()
    assert not tools_pycache.exists()

    assert lean_file.is_file()
    assert tex_file.is_file()
    assert archived_pdf.is_file()
    assert current_demo.is_file()
    assert (tmp_path / "scripts" / "keep.sh").is_file()
    assert (tmp_path / "tools" / "keep.py").is_file()
