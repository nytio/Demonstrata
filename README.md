# Mimate

Workspace for formal proofs in Lean 4 using Codex CLI, mathlib, and Python
automation around the verifier.

## Goal

- Codex drafts proofs and proof strategies.
- Lean and mathlib validate whether the proof is actually accepted.
- Python is used only for automation around build and diagnostics.

## Layout

- `Mimate/`: Lean library modules.
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
- File diagnostics as JSON: `scripts/check_lean_json.sh Mimate/Basic.lean`
- Summarize Lean JSON diagnostics:
  `.venv/bin/python scripts/summarize_lean_json.py diagnostics.jsonl`
- Run tests: `.venv/bin/pytest -q`

## Advanced exploration

For deeper navigation of `Mathlib`, this repo treats two extras as optional:

- NDJSON export with `lean4export` for structured offline inspection.
- Semantic indexes such as LeanExplore for search by meaning and MCP-backed
  retrieval.

The evaluation and references are documented in
`docs/mathlib-exploration.md`.
