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
   - If the strategy handoff says `Loogle preflight required`, or if you say you
     will use Loogle, you must actually run `scripts/check_loogle_local.sh --start`
     before authoring or revising the proof. This starts/verifies the local
     Loogle server and reuses the persisted Mathlib index instead of rebuilding it.
   - After that, run at least one targeted Loogle query for each missing lemma
     shape before changing to a different mathematical route. Use the persisted
     index path explicitly for Mathlib when invoking the CLI:
     `scripts/loogle_local.sh --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib '<query>'`.
5. Prefer helper lemmas if the proof script becomes unstable or opaque.
6. Verify the edited file with `scripts/check_lean_json.sh <file.lean>`.
7. Classify the blocker before the next proof iteration.
   - Keep the work local when the error is plainly syntactic or statement-local:
     parser failures, malformed tactic blocks, wrong variable names, bad
     hypothesis plumbing, or a theorem statement that is itself incorrect.
   - Escalate to declaration discovery when one of these holds:
     - you need a lemma or rewrite shape but do not know its name;
     - `exact?`, `apply?`, `rw?`, `#find`, and direct `rg` inspection did not
       identify the declaration;
     - one or two local edits failed without changing the blocker category and
       the remaining issue still looks like "missing theorem shape" rather than
       a local typo.
   - When you decide to escalate, say so explicitly instead of continuing with
     ad hoc edits.
8. If the missing ingredient is declaration discovery inside `Mathlib`, consult
   `docs/mathlib-exploration.md` before expanding imports blindly. The default
   local path in this repo is:
   - try `#check`, `#find`, `exact?`, `apply?`, `rw?`, and `rg` first;
   - run `scripts/check_loogle_local.sh` before relying on the local `loogle`
     path;
   - use `scripts/loogle_local.sh '<query>'` for `Mathlib`;
   - when `Mathlib` is the target and sandbox startup is sensitive, prefer the
     explicit persisted-index path:
     `scripts/loogle_local.sh --read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib '<query>'`;
   - use `scripts/loogle_local.sh --module <Biblioteca.Module> '<query>'` for
     built modules in `Biblioteca`;
   - if `loogle` stalls while building or loading its index, say that
     explicitly; for `Mathlib`, rerun with
     `--read-index /home/mario/code/mimate/.local-tools/loogle-indexes/Mathlib.extra --module Mathlib`;
     for other modules, look for a repo-local persisted index under
     `.local-tools/loogle-indexes/`; only if no persisted index exists continue
     with `rg` plus the declarations already located instead of waiting indefinitely;
   - if repeated Lean-side `#loogle` queries are useful, start
     `scripts/start_loogle_local_server.sh` and make sure the health check
     passes so LeanSearchClient hits the local server configured in
     `.codex/config.toml`.
9. Only after file-level verification passes, finish the formal check with
   `scripts/build_strict.sh`.
10. If the user wants a PDF or a narrative counterpart, update the local
   blueprint, review the LaTeX exposition so it matches the accepted Lean proof
   without modifying Lean in that step, and then run
   `scripts/check_blueprint_decls.sh`.
11. Prefer timestamped modules under `Biblioteca/Demonstrations/` over dumping
    new proofs into a catch-all file.

## Rules

- Never end with `sorry`.
- Prefer stable proof terms and small tactic blocks over brittle monoliths.
- Search in `Mathlib` or `Biblioteca` only to find ingredients, not as a
  substitute for authoring the requested result.
- If a proof depends on a missing lemma, search Mathlib before re-proving infrastructure.
- If the proof depends on missing Mathlib declarations and Loogle is available,
  do not abandon the selected proof strategy until you have performed the
  Loogle preflight (`scripts/check_loogle_local.sh --start`) and at least one
  targeted query for the missing theorem shape.
- When the exact theorem does not already exist in the repo, create a new
  demonstration and prove it under LLM guidance rather than stopping at a list
  of possibly relevant lemmas.
- Explain the blocking diagnostic if Lean rejects the theorem.
- Prefer built-in Lean lookup (`#find`, `#check`, `exact?`, `apply?`, `rw?`)
  before escalating to external search tools.
- Do not keep guessing once the same declaration-shaped blocker survives one or
  two local proof edits. At that point, make an explicit `loogle` decision.
- An explicit `loogle` decision means either running Loogle or explaining why
  the blocker is genuinely local. If you decide to use Loogle, running it is
  mandatory; mentioning it without executing the server check and queries is not
  sufficient.
- Use NDJSON export or a semantic index only when normal `Mathlib` navigation
  stops being efficient.
- Prefer local `loogle` before NDJSON export or LeanExplore when the blocker is
  discovering the right declaration name or nearby theorem shape.
- If you intentionally skip `loogle` after the checkpoint, state why the issue
  is still local, for example a broken theorem statement or a malformed local
  proof state.
- Treat `Biblioteca` lookup as module-scoped until the repo documents a stable
  aggregate search path.
- Prefer NDJSON export when you need bulk declaration context; prefer LeanExplore
  only when the challenge is semantic retrieval of unknown names.
- Use `\lean{...}` references in `blueprint/src` when the formalized result
  should also appear in the project PDF.
- Treat `\lean{...}` as the source of truth for PDF cross-reference metadata:
  it should render short names in the body, feed the final Lean glossary, and
  pair with the automatically appended Lean-source annex, so avoid duplicating
  fully-qualified declaration names in prose unless needed.
- When a demonstration also has a blueprint section, revise the `.tex`
  argument so it narrates the same mathematics Lean accepted; do not use that
  exposition pass to reopen or mutate the Lean proof unless a separate Lean
  issue is found.
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
