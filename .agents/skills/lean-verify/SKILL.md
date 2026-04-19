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
4. After a local fix, run `scripts/build_strict.sh` only once the target
   file-level check is clean.
5. Classify the first actionable diagnostic before recommending more edits.
   - Keep the next step local when the failure is parser-level, namespace-local,
     obviously caused by the current theorem statement, or confined to local
     hypothesis/tactic plumbing.
   - Treat the failure as a declaration-discovery blocker when the remaining
     issue is still "I need a theorem/rewrite but do not know which one" after
     one or two local fixes, or when `#check`/`#find`/`apply?`/`rw?` plus direct
     `rg` inspection still do not expose the needed declaration.
   - If it is a discovery blocker, stop recommending blind edits and escalate to
     the local `loogle` path.
6. If symbol discovery is the blocker rather than verification itself, consult
   `docs/mathlib-exploration.md` for the local search order:
   - `#check`, `#find`, `exact?`, `apply?`, `rw?`, and `rg` first;
   - `scripts/check_loogle_local.sh` before depending on the local server path;
   - `scripts/loogle_local.sh '<query>'` for `Mathlib`;
   - for `Mathlib` in sandbox-sensitive flows, prefer the explicit persisted
     index path:
     `scripts/loogle_local.sh --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib '<query>'`;
   - `scripts/loogle_local.sh --module <Biblioteca.Module> '<query>'` for
     built repo modules;
   - if `loogle` gets stuck on a cold index, say that explicitly, check for a
     repo-local persisted index under `.local-tools/loogle-indexes/`; for
     `Mathlib`, rerun explicitly with
     `--read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib`;
     if there is no persisted index, fall back to `rg` and direct declaration
     inspection instead of waiting indefinitely;
   - `scripts/start_loogle_local_server.sh` only when you specifically want
     Lean-side `#loogle` queries to resolve against the local server after the
     health check passes.
7. Treat warnings that hide incomplete proofs as failures.
8. If the task also touches the PDF blueprint, review the paired LaTeX section
   so its olympiad-style exposition is argumentally consistent with the Lean
   proof accepted in the previous steps; do not modify Lean during that review.
9. After that LaTeX review, run `scripts/check_blueprint_decls.sh`.
10. When reviewing the library layout, prefer timestamped demonstration files
   under `Biblioteca/Demonstrations/`.
11. When the user is asking for a genuinely new theorem, verify the freshly
   created timestamped demonstration file instead of treating the task as
   declaration lookup only.

## Rules

- Never accept `sorry` as a valid end state.
- Prefer file-level verification first, then full project verification.
- For demonstration workflows, treat a clean `scripts/check_lean_json.sh`
  result as the gate before `scripts/build_strict.sh`.
- Report the exact failing file and the first actionable diagnostic.
- Verification is not limited to imported declarations already present in
  `Mathlib` or `Biblioteca`; it must also support newly authored proofs created
  by the LLM in this repo.
- Prefer built-in Lean lookup and direct declaration inspection before
  escalating to `loogle`, NDJSON export, or LeanExplore.
- If the same declaration-shaped diagnostic survives one or two local fixes,
  require an explicit `loogle` recommendation or an explicit explanation for why
  the blocker is still local.
- Prefer local `loogle` before NDJSON export or LeanExplore when the main issue
  is declaration lookup rather than semantic retrieval.
- Treat `Biblioteca` lookup as module-scoped unless the aggregate import is
  explicitly known to be stable.
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
- Confirmation that a newly authored demonstration compiles when that is the task.
- Confirmation of the LaTeX consistency review when the task includes a paired blueprint section.
- Clear next step if the build fails.
