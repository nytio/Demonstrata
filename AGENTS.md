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
- Do not treat `Mathlib` or `Biblioteca` as search-only corpora. Retrieval is
  only a support step; when the user asks for a new result, Codex is expected
  to author a new demonstration entry and drive it to an accepted Lean proof.

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
- Treat `Biblioteca/` as the Lean namespace root; do not remove it just because it
  looks like an extra folder.
- When the theorem to formalize is genuinely new to this repo, create a fresh
  timestamped module with `scripts/new_demo.sh "<title>"` instead of proving it
  in scratch files or stopping after a `Mathlib` search.
- When exploring proof failures, keep the failing theorem small and isolate imports.
- Prefer helper lemmas and explicit statements over long tactic blocks when the proof becomes unstable.

## Search conventions

- Use `rg` for content search.
- Use `fdfind` for file discovery.

## Repo-local skills

- `lean-verify`: strict verification loop for builds and file-level diagnostics.
- `lean-prove`: workflow for drafting a theorem and iterating until Lean accepts it.
- `olympiad-formalize`: coordinator for olympiad-style problems that sequences
  strategy search, Lean authoring, verification, and final PDF generation.
- Both skills should be used to synthesize new demonstrations when needed, not
  merely to retrieve existing declarations from `Mathlib` or `Biblioteca`.
- For deeper `Mathlib` exploration, consult `docs/mathlib-exploration.md` before
  adding new tooling.
- Treat `lean4export` as the first optional escalation for structured offline
  exploration and LeanExplore as a later semantic-search escalation.

## Useful commands

- Install Python dependencies: `.venv/bin/python -m pip install -r requirements.txt`
- Run tests: `.venv/bin/pytest -q`
- Refresh mathlib cache: `scripts/get_mathlib_cache.sh`
- Strict project build: `scripts/build_strict.sh`
- File-level JSON diagnostics:
  `scripts/check_lean_json.sh Biblioteca/Demonstrations/Demo_20260402_155130_sum_first_odds.lean`
- Summarize JSON diagnostics: `.venv/bin/python scripts/summarize_lean_json.py diagnostics.jsonl`
- Check blueprint declaration references: `scripts/check_blueprint_decls.sh`
- Build blueprint PDF: `scripts/build_blueprint_pdf.sh`
- Scaffold a timestamped demonstration: `scripts/new_demo.sh "odd numbers sum"`
- Build a collection PDF: `scripts/build_blueprint_pdf.sh --demo <section-a> --demo <section-b>`
- Build the whole library PDF: `scripts/build_blueprint_pdf.sh --all`
- Advanced exploration notes: `docs/mathlib-exploration.md`

## Blueprint PDF rules

- Default blueprint builds should target only the current demonstration.
- Use repeated `--demo` flags or `--all` only when the task genuinely needs a collection.
- Keep section metadata comments (`% title:`, `% abstract:`, `% subjclass:`, `% keywords:`) in sync with the theorem being printed.
- The print layout should remain compatible with AMS paper conventions via `amsart`.
- Keep Lean references in blueprint sections as `\lean{...}` markers. The PDF
  builder renders them as short function names in the body and appends an
  automatic Lean glossary from the matching `.lean` declaration headers.
- Every blueprint PDF must also append an `Anexo` section with the full Lean
  source for the corresponding selected demonstration file(s).
- Prefer the glossary mechanism over hardcoded fully-qualified Lean names in
  prose when the declaration already appears via `\lean{...}`.

## Restrictions

- Do not remove or modify `.venv/` unless explicitly asked.
- Do not install global Python packages for this repo.
- Do not use destructive Git commands without explicit user approval.
