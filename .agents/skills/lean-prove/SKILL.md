---
name: lean-prove
description: Draft or refine a Lean theorem in this repository and iterate until Lean accepts it. Use when the task is to formalize a statement, add helper lemmas, or turn an informal argument into Lean code without leaving incomplete proofs.
---

# Lean Prove

## When to Use

- Use this skill when writing or refining Lean theorems in this repository.
- Use this skill when you need a disciplined loop from statement to accepted proof.

## When Not to Use

- Do not use it for pure verification with no code changes; use `lean-verify`.
- Do not use it for Python or Codex configuration work.

## Workflow

1. State the theorem precisely before writing tactics.
2. Decide whether the task belongs in an existing module or should become a new
   timestamped demonstration entry under `Biblioteca/Demonstrations/`.
3. If the result is new to this repo, start with
   `scripts/new_demo.sh "<title>"` so the Lean file and blueprint section stay
   aligned from the beginning. If the result comes from a named source such as
   an olympiad, use `scripts/new_demo.sh --prefix IMO "<title>"` or another
   relevant sigla. If the user also supplied the original problem statement,
   copy that LaTeX into the blueprint section's `problemstatement` block.
4. Import the smallest Mathlib modules that support the proof.
5. Prefer helper lemmas if the proof script becomes unstable or opaque.
6. Verify the edited file with `scripts/check_lean_json.sh <file.lean>`.
7. If the missing ingredient is declaration discovery inside `Mathlib`, consult
   `docs/mathlib-exploration.md` before expanding imports blindly.
8. Finish with `scripts/build_strict.sh`.
9. If the user wants a PDF or a narrative counterpart, update the local
   blueprint and run `scripts/check_blueprint_decls.sh`.
10. Prefer timestamped modules under `Biblioteca/Demonstrations/` over dumping
    new proofs into a catch-all file.

## Rules

- Never end with `sorry`.
- Prefer stable proof terms and small tactic blocks over brittle monoliths.
- Search in `Mathlib` or `Biblioteca` only to find ingredients, not as a
  substitute for authoring the requested result.
- If a proof depends on a missing lemma, search Mathlib before re-proving infrastructure.
- When the exact theorem does not already exist in the repo, create a new
  demonstration and prove it under LLM guidance rather than stopping at a list
  of possibly relevant lemmas.
- Explain the blocking diagnostic if Lean rejects the theorem.
- Use NDJSON export or a semantic index only when normal `Mathlib` navigation
  stops being efficient.
- Prefer NDJSON export when you need bulk declaration context; prefer LeanExplore
  only when the challenge is semantic retrieval of unknown names.
- Use `\lean{...}` references in `blueprint/src` when the formalized result
  should also appear in the project PDF.
- Treat `\lean{...}` as the source of truth for PDF cross-reference metadata:
  it should render short names in the body, feed the final Lean glossary, and
  pair with the automatically appended Lean-source annex, so avoid duplicating
  fully-qualified declaration names in prose unless needed.
- Use `scripts/new_demo.sh` when starting a fresh demonstration entry so the
  Lean module and blueprint section stay aligned.
- Single-demo PDF builds should overwrite the prior archived PDF by reusing the
  originating Lean stem under `blueprint/library/pdf/`.
- By default, build only the current theorem paper; use `--demo` or `--all`
  only when a collection is actually intended.

## Expected Outputs

- A theorem or lemma accepted by Lean.
- A new timestamped demonstration entry when the task introduces a new result.
- Minimal supporting imports and helper lemmas.
- Verification evidence from file-level or full-project checks.
