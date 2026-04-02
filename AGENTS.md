# AGENTS.md

## Purpose

This repository is a local workspace for formal proofs in Lean 4 with Codex CLI
on Ubuntu. Codex proposes proofs; Lean and mathlib are the source of truth.

## Environment

- OS: Ubuntu 24.04.x
- User shell: `fish`
- Codex commands may run under `bash -lc`; avoid relying on interactive shell state.
- Python virtual environment already exists in `.venv/`.
- Lean toolchain is managed by `elan` under `$HOME/.elan/bin`.

## Documentation defaults

- For OpenAI products or Codex behavior, consult official OpenAI docs first.
- For third-party libraries or frameworks, consult Context7 first.

## Mandatory repo rules

- Never leave `sorry` in committed or final Lean code.
- After editing Lean files, prefer file-level verification first, then a full build.
- The final arbiter is successful compilation without warnings that would hide incomplete proofs.
- Prefer repo-local scripts over ad hoc command variants when they exist.
- Do not rewrite repo structure broadly unless the task explicitly requires it.

## Python rules

- Use `.venv/bin/python`, `.venv/bin/pip`, and `.venv/bin/pytest`.
- Do not `source .venv/bin/activate`.
- Prefer stdlib for support scripts unless an external dependency is justified.

## Lean rules

- Use `$HOME/.elan/bin/lake` and `$HOME/.elan/bin/lean` when PATH is uncertain.
- Prefer these commands:
  - `scripts/build_strict.sh`
  - `scripts/check_lean_json.sh <file.lean>`
  - `scripts/get_mathlib_cache.sh`
- When exploring proof failures, keep the failing theorem small and isolate imports.
- Prefer helper lemmas and explicit statements over long tactic blocks when the proof becomes unstable.

## Search conventions

- Use `rg` for content search.
- Use `fdfind` for file discovery.

## Repo-local skills

- `lean-verify`: strict verification loop for builds and file-level diagnostics.
- `lean-prove`: workflow for drafting a theorem and iterating until Lean accepts it.

## Useful commands

- Install Python dependencies: `.venv/bin/python -m pip install -r requirements.txt`
- Run tests: `.venv/bin/pytest -q`
- Refresh mathlib cache: `scripts/get_mathlib_cache.sh`
- Strict project build: `scripts/build_strict.sh`
- File-level JSON diagnostics: `scripts/check_lean_json.sh Mimate/Basic.lean`
- Summarize JSON diagnostics: `.venv/bin/python scripts/summarize_lean_json.py diagnostics.jsonl`

## Restrictions

- Do not remove or modify `.venv/` unless explicitly asked.
- Do not install global Python packages for this repo.
- Do not use destructive Git commands without explicit user approval.
