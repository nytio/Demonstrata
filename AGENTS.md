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

## Codex model and agent policy

- Use `gpt-5.5` as the repo-local Codex model.
- Prefer `model_reasoning_effort = "high"` for this repository because Lean
  proof work benefits from deeper planning, debugging, and multi-step tradeoffs.
- Do not use multi-agent or subagent execution for this repo unless the user
  explicitly revises this policy. The repo-local Codex configuration disables
  multi-agent features; prefer one agent with high reasoning instead.
- With Codex CLI 0.125.0 or newer, keep using repo-local permission profiles
  and prefer `/status` or `/debug-config` to confirm that the project config was
  loaded. For non-interactive planning evidence, `codex exec --json` can expose
  reasoning-token usage, but it must not be used to spawn multiple agents here.
- If a future Codex release changes model or reasoning configuration keys,
  consult official OpenAI Codex documentation before updating `.codex/config.toml`.

## Mandatory repo rules

- Never leave `sorry` in committed or final Lean code.
- After editing Lean files, prefer file-level verification first, then a full build.
- The final arbiter is successful compilation without warnings that would hide incomplete proofs.
- After Lean verification succeeds for a demonstration, review the paired LaTeX
  section so its olympiad-style exposition matches the accepted Lean argument;
  that review step updates only the `.tex`, not the Lean file.
- Prefer repo-local scripts over ad hoc command variants when they exist.
- Do not rewrite repo structure broadly unless the task explicitly requires it.
- Do not treat `Mathlib` or `Biblioteca` as search-only corpora. Retrieval is
  only a support step; when the user asks for a new result, Codex is expected
  to author a new demonstration entry and drive it to an accepted Lean proof.

## Python rules

- Use `.venv/bin/python`, `.venv/bin/pip`, and `.venv/bin/pytest`.
- Do not `source .venv/bin/activate`.
- Prefer stdlib for support scripts unless an external dependency is justified.
- Use Python primarily for automation around builds, diagnostics, blueprint
  generation, and support tooling; keep proof logic in Lean unless the task
  explicitly requires otherwise.

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

## Repository map

- `Biblioteca/` is the Lean library root for the `Biblioteca.*` namespace.
- `Biblioteca/Demonstrations/` stores timestamped Lean demonstration modules.
- `blueprint/` contains the local LaTeX blueprint sources and generated PDF artifacts.
- `blueprint/src/sections/` stores the LaTeX section paired with each demonstration.
- `blueprint/library/pdf/` stores archived, publishable PDFs.
- `scripts/` contains reproducible entrypoints for Lean verification and PDF generation.
- `tools/` contains Python support code for demo naming, blueprint handling, and diagnostics.
- `tests/` contains tests for the local automation code.
- `.agents/skills/` contains repo-local Codex workflows for strategy, proving, and verification.
- `.codex/` contains project-scoped Codex configuration and rules.

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
- For olympiad-style requests, prefer `olympiad-formalize` as the entry point so
  the workflow starts with strategy selection before Lean authoring.

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
- Clean disposable local artifacts: `./clean.sh`
- Scaffold a timestamped demonstration: `scripts/new_demo.sh "odd numbers sum"`
- Scaffold with an origin prefix: `scripts/new_demo.sh --prefix IMO "least norwegian number"`
- Build a collection PDF: `scripts/build_blueprint_pdf.sh --demo <section-a> --demo <section-b>`
- Build the whole library PDF: `scripts/build_blueprint_pdf.sh --all`
- Advanced exploration notes: `docs/mathlib-exploration.md`

## Demonstration scaffolding rules

- Treat the repo as a growing library of demonstrations, not as a scratch space.
- New Lean source files belong under `Biblioteca/Demonstrations/` with timestamped
  names and an optional origin prefix such as `Demo` or `IMO`.
- Matching blueprint sections belong under `blueprint/src/sections/` with the
  same timestamped stem; `Demo` sections use the historical lowercase `demo_`
  prefix while other prefixes are preserved as written.
- `scripts/new_demo.sh "<title>"` creates both the `.lean` and `.tex` files and
  registers them in the aggregate imports and blueprint index without
  overwriting older entries.
- `scripts/new_demo.sh --prefix <SIGLA> "<title>"` should be used when the
  theorem origin needs to be reflected in filenames and section stems.
- The intended authoring loop is: scaffold a fresh entry, write the theorem and
  proof, verify the demo file first with `scripts/check_lean_json.sh`, close the
  formal check with `scripts/build_strict.sh`, revise the paired LaTeX section
  so it matches the accepted Lean argument, then generate the current paper PDF.

## Blueprint PDF rules

- Default blueprint builds should target only the current demonstration.
- Default blueprint declaration checks should also target only the current demonstration.
- `scripts/new_demo.sh` marks the newly scaffolded demonstration as current.
- If no current marker exists, the latest modified blueprint section is used.
- Recommended blueprint workflow: verify the demo first with
  `scripts/check_lean_json.sh <file.lean>`, then run `scripts/build_strict.sh`,
  then review the paired LaTeX section for argument consistency with the
  accepted Lean proof, then check declarations with
  `scripts/check_blueprint_decls.sh`, then build the PDF with
  `scripts/build_blueprint_pdf.sh`.
- Use repeated `--demo` flags or `--all` only when the task genuinely needs a collection.
- Build outputs are preserved under timestamped directories in `blueprint/build/`.
- Archived PDFs in `blueprint/library/pdf/` should reuse the originating Lean
  stem for single-demo builds so reruns replace the prior PDF instead of adding
  a second build timestamp.
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
