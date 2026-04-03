from __future__ import annotations

from dataclasses import dataclass
import re


PREFIX_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9]*$")
STEM_PATTERN = re.compile(
    r"^(?P<prefix>[A-Za-z][A-Za-z0-9]*)_(?P<stamp>\d{8}_\d{6})_(?P<slug>[A-Za-z0-9_]+)$"
)


@dataclass(frozen=True)
class DemonstrationStem:
    prefix: str
    stamp: str
    slug: str


def normalize_prefix(raw: str) -> str:
    prefix = raw.strip()
    if not prefix:
        raise ValueError("prefix must not be empty")
    if prefix.lower() == "demo":
        return "Demo"
    if PREFIX_PATTERN.fullmatch(prefix) is None:
        raise ValueError(
            "prefix must start with a letter and contain only letters or digits"
        )
    return prefix


def section_prefix_for_lean_prefix(lean_prefix: str) -> str:
    return "demo" if lean_prefix == "Demo" else lean_prefix


def parse_demonstration_stem(stem: str) -> DemonstrationStem | None:
    match = STEM_PATTERN.fullmatch(stem)
    if match is None:
        return None
    return DemonstrationStem(
        prefix=match.group("prefix"),
        stamp=match.group("stamp"),
        slug=match.group("slug"),
    )


def build_lean_stem(prefix: str, stamp: str, slug: str) -> str:
    lean_prefix = normalize_prefix(prefix)
    return f"{lean_prefix}_{stamp}_{slug}"


def build_section_stem(prefix: str, stamp: str, slug: str) -> str:
    lean_prefix = normalize_prefix(prefix)
    section_prefix = section_prefix_for_lean_prefix(lean_prefix)
    return f"{section_prefix}_{stamp}_{slug}"


def infer_lean_stem_from_section_stem(section_stem: str) -> str:
    parsed = parse_demonstration_stem(section_stem)
    if parsed is not None:
        return build_lean_stem(parsed.prefix, parsed.stamp, parsed.slug)
    if section_stem.startswith("demo_"):
        return section_stem.replace("demo_", "Demo_", 1)
    return section_stem


def title_slug_from_stem(stem: str) -> str:
    parsed = parse_demonstration_stem(stem)
    if parsed is not None:
        return parsed.slug
    if stem.startswith("demo_"):
        return stem.removeprefix("demo_")
    return stem
