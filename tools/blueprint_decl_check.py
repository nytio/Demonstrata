from __future__ import annotations

import argparse
import re
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable
import json
import tomllib

from tools.blueprint_paper import resolve_selected_sections


LEAN_MACRO_PATTERN = re.compile(r"\\lean\{([^}]*)\}")


@dataclass(frozen=True)
class LeanReference:
    declaration: str
    file_path: Path
    line_number: int


@dataclass(frozen=True)
class ProjectConfig:
    repo_root: Path
    lean_libs: tuple[str, ...]


@dataclass(frozen=True)
class CheckResult:
    command: tuple[str, ...]
    stdout: str
    stderr: str
    return_code: int

    @property
    def ok(self) -> bool:
        return self.return_code == 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Check that \\lean{...} declarations in blueprint TeX files exist."
    )
    parser.add_argument(
        "--blueprint-dir",
        default="blueprint/src",
        help="Directory containing blueprint TeX files.",
    )
    parser.add_argument("--all", action="store_true", help="Check all blueprint sections.")
    parser.add_argument(
        "--demo",
        action="append",
        default=[],
        help="Section stem or .tex filename to check. Repeat for a collection.",
    )
    return parser


def load_project_config(repo_root: Path) -> ProjectConfig:
    lakefile_path = repo_root / "lakefile.toml"
    with lakefile_path.open("rb") as handle:
        raw = tomllib.load(handle)

    lean_libs: list[str] = []
    for item in raw.get("lean_lib", []):
        if not isinstance(item, dict):
            continue
        name = item.get("name")
        if isinstance(name, str) and name not in lean_libs:
            lean_libs.append(name)

    if "Mathlib" not in lean_libs:
        lean_libs.insert(0, "Mathlib")

    return ProjectConfig(repo_root=repo_root, lean_libs=tuple(lean_libs))


def iter_tex_files(blueprint_dir: Path) -> Iterable[Path]:
    return sorted(path for path in blueprint_dir.rglob("*.tex") if path.is_file())


def extract_references(file_path: Path) -> list[LeanReference]:
    references: list[LeanReference] = []
    for line_number, line in enumerate(file_path.read_text(encoding="utf-8").splitlines(), start=1):
        for raw_names in LEAN_MACRO_PATTERN.findall(line):
            for raw_name in raw_names.split(","):
                declaration = raw_name.strip()
                if not declaration:
                    continue
                references.append(
                    LeanReference(
                        declaration=declaration,
                        file_path=file_path,
                        line_number=line_number,
                    )
                )
    return references


def collect_references(blueprint_dir: Path) -> list[LeanReference]:
    references: list[LeanReference] = []
    for file_path in iter_tex_files(blueprint_dir):
        references.extend(extract_references(file_path))
    return references


def collect_selected_references(repo_root: Path, *, requested_demos: list[str], include_all: bool) -> list[LeanReference]:
    references: list[LeanReference] = []
    for section in resolve_selected_sections(
        repo_root,
        requested_demos=requested_demos,
        include_all=include_all,
    ):
        references.extend(extract_references(section.path))
    return references


def render_check_file(config: ProjectConfig, references: Iterable[LeanReference]) -> tuple[str, dict[int, LeanReference]]:
    lines: list[str] = []
    line_to_reference: dict[int, LeanReference] = {}

    for lean_lib in config.lean_libs:
        lines.append(f"import {lean_lib}")
    lines.append("")

    for reference in references:
        lines.append(f"#check {reference.declaration}")
        line_to_reference[len(lines)] = reference

    return "\n".join(lines) + "\n", line_to_reference


def run_check(config: ProjectConfig, check_file: str) -> CheckResult:
    with tempfile.NamedTemporaryFile(
        mode="w",
        suffix=".lean",
        encoding="utf-8",
        delete=False,
        dir=config.repo_root,
    ) as handle:
        handle.write(check_file)
        temp_path = Path(handle.name)

    command = (
        str(Path.home() / ".elan" / "bin" / "lake"),
        "env",
        "lean",
        "--json",
        str(temp_path),
    )
    try:
        completed = subprocess.run(
            command,
            cwd=config.repo_root,
            capture_output=True,
            text=True,
            check=False,
        )
    finally:
        temp_path.unlink(missing_ok=True)

    return CheckResult(
        command=command,
        stdout=completed.stdout,
        stderr=completed.stderr,
        return_code=completed.returncode,
    )


def parse_errors(
    repo_root: Path, stdout: str, line_to_reference: dict[int, LeanReference]
) -> list[str]:
    messages: list[str] = []
    for raw_line in stdout.splitlines():
        if not raw_line.strip():
            continue
        try:
            payload = json.loads(raw_line)
        except json.JSONDecodeError:
            continue
        if not isinstance(payload, dict):
            continue
        if payload.get("severity") != "error":
            continue
        position = payload.get("pos")
        if not isinstance(position, dict):
            messages.append(str(payload.get("message", "Lean reported an error")))
            continue
        line_number = position.get("line")
        if not isinstance(line_number, int):
            messages.append(str(payload.get("message", "Lean reported an error")))
            continue
        reference = line_to_reference.get(line_number)
        if reference is None:
            messages.append(str(payload.get("message", "Lean reported an error")))
            continue
        message = str(payload.get("message", "Lean reported an error")).strip()
        messages.append(
            f"{reference.declaration} referenced at "
            f"{reference.file_path.relative_to(repo_root)}:{reference.line_number}: "
            f"{message}"
        )
    return messages


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parents[1]
    blueprint_dir = repo_root / args.blueprint_dir
    if not blueprint_dir.is_dir():
        raise FileNotFoundError(f"Blueprint directory not found: {blueprint_dir}")

    references = collect_selected_references(
        repo_root,
        requested_demos=args.demo,
        include_all=args.all,
    )
    if not references:
        print(f"No \\lean{{...}} references found under {blueprint_dir.relative_to(repo_root)}.")
        return 0

    config = load_project_config(repo_root)
    check_file, line_to_reference = render_check_file(config, references)
    _ = check_file
    result = run_check(config, check_file)

    if result.ok:
        print(
            f"Checked {len(references)} Lean declaration reference(s) from "
            f"{blueprint_dir.relative_to(repo_root)}."
        )
        return 0

    for message in parse_errors(repo_root, result.stdout, line_to_reference):
        print(message)
    if result.stderr.strip():
        print(result.stderr.strip())
    return result.return_code


if __name__ == "__main__":
    raise SystemExit(main())
