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
2. Import the smallest Mathlib modules that support the proof.
3. Prefer helper lemmas if the proof script becomes unstable or opaque.
4. Verify the edited file with `scripts/check_lean_json.sh <file.lean>`.
5. If the missing ingredient is declaration discovery inside `Mathlib`, consult
   `docs/mathlib-exploration.md` before expanding imports blindly.
6. Finish with `scripts/build_strict.sh`.
7. If the user wants a PDF or a narrative counterpart, update the local
   blueprint and run `scripts/check_blueprint_decls.sh`.
8. Prefer timestamped modules under `Mimate/Demonstrations/` over dumping new
   proofs into a catch-all file.

## Rules

- Never end with `sorry`.
- Prefer stable proof terms and small tactic blocks over brittle monoliths.
- If a proof depends on a missing lemma, search Mathlib before re-proving infrastructure.
- Explain the blocking diagnostic if Lean rejects the theorem.
- Use NDJSON export or a semantic index only when normal `Mathlib` navigation
  stops being efficient.
- Prefer NDJSON export when you need bulk declaration context; prefer LeanExplore
  only when the challenge is semantic retrieval of unknown names.
- Use `\lean{...}` references in `blueprint/src` when the formalized result
  should also appear in the project PDF.
- Use `scripts/new_demo.sh` when starting a fresh demonstration entry so the
  Lean module and blueprint section stay aligned.

## Expected Outputs

- A theorem or lemma accepted by Lean.
- Minimal supporting imports and helper lemmas.
- Verification evidence from file-level or full-project checks.
