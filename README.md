# Mimate

Workspace for formal proofs in Lean 4 using Codex CLI, mathlib, and Python
automation around the verifier.

## Goal

- Codex drafts proofs and proof strategies.
- Lean and mathlib validate whether the proof is actually accepted.
- Python is used only for automation around build and diagnostics.

## Layout

- `Mimate/`: Lean library root for the `Mimate.*` namespace.
- `Mimate/Demonstrations/`: timestamped Lean demonstration modules.
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
  `scripts/check_lean_json.sh Mimate/Demonstrations/Demo_20260402_155130_sum_first_odds.lean`
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

Each build is preserved under a timestamped directory in `blueprint/build/`,
and the final PDF is archived under `blueprint/library/pdf/`.

If you want the full external `leanblueprint` toolchain later, the upstream
package also supports `pdf`, `web`, and `checkdecls`, but it requires
`graphviz` development headers on the host.

## Demonstration Library

This project treats Lean proofs as a growing library, not as one-off examples.

- Lean source files live under `Mimate/Demonstrations/` with timestamped names.
- Blueprint sections live under `blueprint/src/sections/` with matching
  timestamped names.
- `scripts/new_demo.sh "<title>"` creates both files and registers them in the
  aggregate imports and blueprint index without overwriting older entries.

## Advanced exploration

For deeper navigation of `Mathlib`, this repo treats two extras as optional:

- NDJSON export with `lean4export` for structured offline inspection.
- Semantic indexes such as LeanExplore for search by meaning and MCP-backed
  retrieval.

The evaluation and references are documented in
`docs/mathlib-exploration.md`.
