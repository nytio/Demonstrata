# Biblioteca

Workspace for formal proofs in Lean 4 using Codex CLI, mathlib, and Python
automation around the verifier.

## Goal

- Codex drafts proofs and proof strategies.
- Lean and mathlib validate whether the proof is actually accepted.
- Python is used only for automation around build and diagnostics.

## Layout

- `Biblioteca/`: Lean library root for the `Biblioteca.*` namespace.
- `Biblioteca/Demonstrations/`: timestamped Lean demonstration modules.
- `blueprint/`: local LaTeX blueprint sources and generated PDF artifacts.
- `.agents/skills/`: repo-local Codex skills for proof authoring and verification.
- `.codex/`: project-scoped Codex configuration and rules.
- `scripts/`: reproducible shell entrypoints for Lean workflows.
- `tools/`: Python support code.
- `tests/`: tests for local automation code.

## Setup

1. Install Python dependencies:
  `.venv/bin/python -m pip install -r requirements.txt`
2. Refresh mathlib cache if needed:
   `scripts/get_mathlib_cache.sh`
3. Run a strict build:
   `scripts/build_strict.sh`

## Common commands

- Strict build: `scripts/build_strict.sh`
- File diagnostics as JSON:
  `scripts/check_lean_json.sh Biblioteca/Demonstrations/Demo_20260402_155130_sum_first_odds.lean`
- Summarize Lean JSON diagnostics:
  `.venv/bin/python scripts/summarize_lean_json.py diagnostics.jsonl`
- Run tests: `.venv/bin/pytest -q`
- Check blueprint Lean references: `scripts/check_blueprint_decls.sh`
- Build blueprint PDF: `scripts/build_blueprint_pdf.sh`
- Scaffold a timestamped demonstration:
  `scripts/new_demo.sh "odd numbers sum"`

## Blueprint PDF

This repo now includes a local `blueprint/` tree for producing a PDF that
tracks Lean declarations with `\lean{...}` annotations.

Recommended local workflow:

1. Verify Lean first:
   `scripts/build_strict.sh`
2. Check blueprint declaration references:
   `scripts/check_blueprint_decls.sh`
3. Build the PDF:
   `scripts/build_blueprint_pdf.sh`

By default, the PDF builder and the blueprint checker target only the current
demonstration under active work.

- `scripts/new_demo.sh "<title>"` marks the newly scaffolded demonstration as
  current.
- If no current marker exists, the latest modified blueprint section is used.
- For a collection, pass repeated `--demo <section-stem>` arguments or `--all`.

Examples:

- Current demonstration only:
  `scripts/build_blueprint_pdf.sh`
- Explicit collection:
  `scripts/build_blueprint_pdf.sh --demo demo_20260402_155130_sum_first_odds --demo demo_20260402_155831_cubic_increment_sum`
- Whole library:
  `scripts/build_blueprint_pdf.sh --all`

Each build is preserved under a timestamped directory in `blueprint/build/`.
The archived PDF name also includes a timestamp and the selected theorem or
collection identity under `blueprint/library/pdf/`.

The generated paper uses the AMS `amsart` class with standard mathematical
front matter: title, author, abstract, MSC subject classification, and
keywords.

If you want the full external `leanblueprint` toolchain later, the upstream
package also supports `pdf`, `web`, and `checkdecls`, but it requires
`graphviz` development headers on the host.

## Demonstration Library

This project treats Lean proofs as a growing library, not as one-off examples.

- Lean source files live under `Biblioteca/Demonstrations/` with timestamped names.
- Blueprint sections live under `blueprint/src/sections/` with matching
  timestamped names.
- `scripts/new_demo.sh "<title>"` creates both files and registers them in the
  aggregate imports and blueprint index without overwriting older entries.
- Each blueprint section carries paper metadata comments used by the AMS-style
  PDF builder.

## Advanced exploration

For deeper navigation of `Mathlib`, this repo treats two extras as optional:

- NDJSON export with `lean4export` for structured offline inspection.
- Semantic indexes such as LeanExplore for search by meaning and MCP-backed
  retrieval.

The evaluation and references are documented in
`docs/mathlib-exploration.md`.
