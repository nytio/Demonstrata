from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator, TextIO


@dataclass(frozen=True)
class Position:
    line: int
    column: int


@dataclass(frozen=True)
class Diagnostic:
    severity: str
    message: str
    file_name: str | None
    position: Position | None

    def location(self) -> str:
        if self.file_name is None:
            return "<unknown>"
        if self.position is None:
            return self.file_name
        return f"{self.file_name}:{self.position.line}:{self.position.column}"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Summarize Lean JSON diagnostics from a file or stdin."
    )
    parser.add_argument(
        "input_path",
        nargs="?",
        help="Optional path to a JSONL file. If omitted, read from stdin.",
    )
    parser.add_argument(
        "--max-items",
        type=int,
        default=10,
        help="Maximum number of diagnostics to print.",
    )
    parser.add_argument(
        "--errors-only",
        action="store_true",
        help="Only report diagnostics with severity 'error'.",
    )
    return parser


def parse_position(raw: object) -> Position | None:
    if not isinstance(raw, dict):
        return None
    line = raw.get("line")
    column = raw.get("column")
    if not isinstance(line, int) or not isinstance(column, int):
        return None
    return Position(line=line, column=column)


def parse_diagnostic(raw: object) -> Diagnostic | None:
    if not isinstance(raw, dict):
        return None
    severity = raw.get("severity")
    message = raw.get("message")
    if not isinstance(severity, str) or not isinstance(message, str):
        return None
    file_name = raw.get("fileName")
    if not isinstance(file_name, str):
        file_name = None
    return Diagnostic(
        severity=severity,
        message=message.strip(),
        file_name=file_name,
        position=parse_position(raw.get("pos")),
    )


def iter_json_objects(stream: TextIO) -> Iterator[object]:
    for raw_line in stream:
        line = raw_line.strip()
        if not line:
            continue
        try:
            yield json.loads(line)
        except json.JSONDecodeError as err:
            raise ValueError(f"invalid JSON line: {err.msg}") from err


def load_diagnostics(stream: TextIO) -> list[Diagnostic]:
    diagnostics: list[Diagnostic] = []
    for raw in iter_json_objects(stream):
        diagnostic = parse_diagnostic(raw)
        if diagnostic is not None:
            diagnostics.append(diagnostic)
    return diagnostics


def filter_diagnostics(
    diagnostics: Iterable[Diagnostic], *, errors_only: bool
) -> list[Diagnostic]:
    if not errors_only:
        return list(diagnostics)
    return [diagnostic for diagnostic in diagnostics if diagnostic.severity == "error"]


def render_summary(diagnostics: list[Diagnostic], max_items: int) -> str:
    if not diagnostics:
        return "No diagnostics found."

    severities = ("error", "warning", "information")
    counts = {
        severity: sum(1 for diagnostic in diagnostics if diagnostic.severity == severity)
        for severity in severities
    }

    lines = [
        "Lean diagnostics summary",
        f"errors={counts['error']} warnings={counts['warning']} info={counts['information']}",
    ]

    for index, diagnostic in enumerate(diagnostics[:max_items], start=1):
        lines.append(
            f"{index}. [{diagnostic.severity}] {diagnostic.location()} {diagnostic.message}"
        )

    if len(diagnostics) > max_items:
        remaining = len(diagnostics) - max_items
        lines.append(f"... and {remaining} more diagnostic(s)")

    return "\n".join(lines)


def open_input(path_str: str | None) -> TextIO:
    if path_str is None:
        return sys.stdin
    return Path(path_str).open("r", encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.max_items <= 0:
        raise ValueError("--max-items must be positive")

    stream = open_input(args.input_path)
    should_close = stream is not sys.stdin
    try:
        diagnostics = load_diagnostics(stream)
    finally:
        if should_close:
            stream.close()

    filtered = filter_diagnostics(diagnostics, errors_only=args.errors_only)
    print(render_summary(filtered, args.max_items))
    return 0
