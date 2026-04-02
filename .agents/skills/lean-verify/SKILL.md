---
name: lean-verify
description: Verify Lean files and projects in this repository using the strict local workflow. Use when the task is to check a theorem, inspect Lean diagnostics, refresh mathlib cache, or confirm that no proof was left incomplete.
---

# Lean Verify

## When to Use

- Use this skill when the task is to validate Lean code in this repository.
- Use this skill when you need strict verification before or after editing a proof.

## When Not to Use

- Do not use it for non-Lean tasks.
- Do not use it to invent a new proof strategy from scratch if verification is not yet needed.

## Workflow

1. If dependencies may be missing, run `scripts/get_mathlib_cache.sh`.
2. For a focused failure, run `scripts/check_lean_json.sh <file.lean>`.
3. If diagnostics are noisy, summarize them with:
   `.venv/bin/python scripts/summarize_lean_json.py <jsonl-file>`
4. After a local fix, run `scripts/build_strict.sh`.
5. If symbol discovery is the blocker rather than verification itself, consult
   `docs/mathlib-exploration.md` for NDJSON export and semantic-index options.
6. Treat warnings that hide incomplete proofs as failures.
7. If the task also touches the PDF blueprint, run
   `scripts/check_blueprint_decls.sh` after Lean verification.
8. When reviewing the library layout, prefer timestamped demonstration files
   under `Mimate/Demonstrations/`.

## Rules

- Never accept `sorry` as a valid end state.
- Prefer file-level verification first, then full project verification.
- Report the exact failing file and the first actionable diagnostic.
- Treat NDJSON export and semantic indexes as optional accelerators, not as a
  replacement for Lean verification.
- Prefer NDJSON export before a full semantic-search stack when the need is
  structured inspection rather than concept search.
- Treat blueprint declaration checks as a consistency layer for documentation,
  not as a replacement for Lean compilation.
- Unless the task is explicitly a collection, verify and print only the current
  blueprint section by default.

## Expected Outputs

- Verification result for one file or the full project.
- A short summary of the first blocking diagnostics.
- Clear next step if the build fails.
