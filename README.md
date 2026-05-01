<p align="center">
  <img src="assets/demonstrata-cover.png" alt="Demonstrata cover image" width="720">
</p>

# Demonstrata

<p align="center">
  <strong>Demonstrata: from theorem statements to Lean-verified mathematical notes.
  Mathematics, proved and reproduced. </strong>
</p>

Demonstrata is an open-source theorem proving workflow for Codex and Lean 4.
It takes an informal mathematical problem or theorem statement and produces:

- a human-readable LaTeX proof,
- a Lean 4 formalization,
- reproducibility artifacts,
- axiom audit output,
- and a final PDF note.

The working principle is simple: Codex can propose proof strategies and drafts,
but Lean and mathlib are the source of truth. A note is publishable only when the
formal development compiles and its reproducibility evidence can be regenerated.

<p align="center">
  <img alt="Lean 4" src="https://img.shields.io/badge/Lean-4.29.0-0f5cbd?style=for-the-badge">
  <img alt="mathlib" src="https://img.shields.io/badge/mathlib-v4.29.0-1f8a70?style=for-the-badge">
  <img alt="Python" src="https://img.shields.io/badge/Python-3.12-3776ab?style=for-the-badge">
  <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-111111?style=for-the-badge">
</p>

## Codex Setup

The repository includes local Codex configuration in `.codex/config.toml` for
`gpt-5.5` with `model_reasoning_effort = "high"`. Demonstrata deliberately uses
one high-reasoning Codex session for formal proof work, Lean diagnostics and
multi-step planning.

Multi-agent execution is disabled in the project configuration. With Codex CLI
0.125.0 or newer, use `/status` or `/debug-config` to confirm that the
repo-local configuration is loaded. For non-interactive evidence, `codex exec
--json` can expose planning or reasoning-token telemetry, but it should not be
used here to spawn multiple agents.

## Why It Is Useful

- It turns mathematical statements into artifacts that are checked by a formal
  kernel, not only by informal plausibility.
- It keeps the human-readable proof, Lean source and final PDF coordinated.
- It records reproducibility evidence, including the Lean version, mathlib
  revision, build output and axiom audit output.
- It uses `mathlib4` as the formal mathematical base without reducing the
  project to theorem search.
- It treats the repository as a growing library of verified notes rather than a
  scratch directory.

## Project Layout

| Component | Role |
| --- | --- |
| `Biblioteca/` | Lean library root and technical namespace `Biblioteca.*`. |
| `Biblioteca/Demonstrations/` | Timestamped Lean demonstration modules. |
| `blueprint/src/sections/` | LaTeX sections paired with Lean demonstrations. |
| `blueprint/library/pdf/` | Archived, publishable PDF notes. |
| `scripts/` | Reproducible entrypoints for verification and artifact generation. |
| `tools/` | Python support for demo naming, blueprint rendering and diagnostics. |
| `.agents/skills/` | Repo-local Codex workflows for strategy, proving and verification. |
| `.github/workflows/` | CI, dependency update and release automation. |

`Demonstrata` is the public project name. `Biblioteca` remains the Lean namespace
and directory name for this iteration, so existing imports and theorem
references stay stable.

## Requirements

Install the local workflow dependencies:

1. `git` for the repository and Lake dependencies.
2. `python3` and `venv` for local automation.
3. `elan` for the Lean 4 toolchain.
4. `lean` and `lake`, installed through `elan`.
5. `latexmk` and `xelatex` for blueprint PDFs.
6. `node` and `npm` if you install or update Codex CLI locally.

Then, inside the repository:

```bash
.venv/bin/python -m pip install -r requirements.txt
scripts/get_mathlib_cache.sh
scripts/build_strict.sh
```

If the Python environment does not exist yet:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
```

## Ecosystem

### Python

- `pytest`: tests for the local automation.
- `sympy`: support for mathematical exploration before formalization.

### Lean and Formal Mathematics

- `Lean 4 v4.29.0`: proof assistant, language and verification kernel.
- `mathlib v4.29.0`: the main formal mathematics dependency.
- `Lake`: Lean's package and build manager.

`lake-manifest.json` also records transitive Lean dependencies such as `aesop`,
`batteries`, `proofwidgets`, `LeanSearchClient`, `importGraph`, `Cli`, `quote4`,
`Qq` and `plausible`.

## Useful Commands

```bash
# Strict Lean build
scripts/build_strict.sh

# JSON diagnostics for one Lean file
scripts/check_lean_json.sh Biblioteca/Demonstrations/Demo_20260402_155130_sum_first_odds.lean

# Human-readable summary of JSON diagnostics
.venv/bin/python scripts/summarize_lean_json.py diagnostics.jsonl

# Create a new demonstration
scripts/new_demo.sh "odd numbers sum"
scripts/new_demo.sh --prefix IMO "least norwegian number"

# Check Lean references from the blueprint
scripts/check_blueprint_decls.sh

# Build the current PDF note
scripts/build_blueprint_pdf.sh

# Run Python tests
.venv/bin/pytest -q

# Build the local loogle index to avoid cold-start waits
scripts/build_loogle_index.sh

# Query Mathlib through the canonical persisted local index
scripts/loogle_local.sh --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib 'Fintype.card_subtype'

# Check that the local loogle service answers JSON
scripts/check_loogle_local.sh

# Start loogle, build, test and open Codex with an initial query
scripts/init.sh "Your Codex query"
```

## Example Workflow

Ask Codex CLI for a complete olympiad-style flow:

```text
/olympiad-formalize solve this problem:
> Let \(p\) be a prime number. Prove that there exist integers
> \(x,y,z,t\), not all divisible by \(p\), such that
>
> \[
> p \mid x^4 - 2y^4 + 3z^4 + 4t^4.
> \]

```

From this input, Demonstrata generates a reproducible proof dossier:

- a human-readable mathematical proof;
- a Lean 4 formalization;
- LaTeX sources;
- reproducibility logs;
- axiom-audit output;
- and a final PDF note.

Example output:
[blueprint/library/pdf/Demo_20260430_221302_diagonal_quartic_modulo_prime.pdf](blueprint/library/pdf/Demo_20260430_221302_diagonal_quartic_modulo_prime.pdf)


## How `olympiad-formalize` Works

`olympiad-formalize` coordinates the full path from an informal olympiad-style
statement to a verified note:

1. It normalizes the problem statement.
2. It invokes `mimate-proof-strategy` to compare proof approaches.
3. It chooses a structural proof route before writing Lean.
4. It uses `lean-prove` to create the formal development and helper lemmas.
5. It uses `lean-verify` to run file-level diagnostics and then the strict build.
6. After Lean accepts the proof, it revises only the paired LaTeX section so the
   exposition matches the accepted formal argument.
7. It builds the final blueprint PDF.

The goal is a readable mathematical argument backed by Lean, not brute-force
case enumeration or theorem lookup alone.

## Generated Artifacts

For a new demonstration, the workflow creates or updates:

- `Biblioteca/Demonstrations/<Prefix>_<YYYYMMDD_HHMMSS>_<slug>.lean`
  with the formal Lean proof.
- `blueprint/src/sections/<stem>.tex`
  with the matching LaTeX exposition.
- `Biblioteca/Demonstrations.lean`
  with the aggregate import.
- `blueprint/src/content.tex`
  with the blueprint section entry.
- `blueprint/.current_demo`
  with the active demonstration marker.
- `blueprint/build/<timestamp>_<stem>/`
  with temporary PDF build files.
- `blueprint/library/pdf/<stem>.pdf`
  with the archived publishable note.

The PDF builder creates temporary files such as `paper.tex`,
`lean_glossary.tex`, `lean_reproducibility.tex`, `lean_appendix.tex` and
`selected_content.tex`. Temporary build directories are not versioned; archived
PDF notes are.

## Internal Authoring Loop

1. Create a demonstration with `scripts/new_demo.sh`.
2. Write or refine the mathematical argument with the repo-local skills.
3. Run `scripts/check_lean_json.sh <demo.lean>` until the file is clean.
4. Run `scripts/build_strict.sh` after file-level diagnostics pass.
5. Review the paired LaTeX section for consistency with the accepted Lean proof.
6. Run `scripts/check_blueprint_decls.sh`.
7. Build the PDF with `scripts/build_blueprint_pdf.sh`.
8. Keep the `.lean`, `.tex` and archived PDF as the publishable output.

## PDF Notes

The blueprint uses `amsart` and `\lean{...}` references to connect prose with
Lean declarations. Each generated note includes:

- short Lean declaration names in the body;
- an automatically generated Lean glossary;
- reproducibility evidence for the selected formalization;
- an `Anexo` containing the full Lean source.

By default, `scripts/build_blueprint_pdf.sh` builds the current demonstration.
For a collection, use repeated `--demo` flags or `--all`:

```bash
scripts/build_blueprint_pdf.sh --demo demo_20260402_155831_cubic_increment_sum --demo IMO_20260403_085959_finite_sets_with_divisibility_b_plus_two_c
scripts/build_blueprint_pdf.sh --all
```

## Advanced Mathlib Exploration

For deeper `Mathlib4` navigation, see `docs/mathlib-exploration.md`. The
recommended order is:

1. Lean built-ins such as `#check`, `#find`, `exact?`, `apply?`, `rw?`, plus
   direct `rg` searches.
2. Local `loogle` through `scripts/build_loogle_local.sh`,
   `scripts/build_loogle_index.sh`, `scripts/check_loogle_local.sh`,
   `scripts/loogle_local.sh` and `scripts/start_loogle_local_server.sh`.
3. NDJSON export with `lean4export`.
4. Semantic exploration with LeanExplore.

For this workspace, the canonical persisted Mathlib index is:

```text
/home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra
```

Search over `Biblioteca` is intentionally module-scoped today; the aggregate
`Biblioteca` import is not treated as a stable global loogle index.

## License

This project is distributed under the MIT license. See [LICENSE](LICENSE).
