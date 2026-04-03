---
name: olympiad-formalize
description: Start-to-finish workflow for olympiad-style math problems in this repository. Use when a user presents an informal olympiad problem and wants a non-exhaustive mathematical solution, Lean formalization, verification, and the final PDF artifact.
---

# Olympiad Formalize

## When to Use

- Use this skill at the beginning of a new olympiad-style problem.
- Use it when the user starts from an informal statement and wants the full repo workflow: strategy, Lean, verification, and PDF.
- Use it when the proof should look like olympiad mathematics rather than a brute-force certificate.

## When Not to Use

- Do not use it for pure Lean verification of an existing file; use `lean-verify`.
- Do not use it for small edits to an already-accepted theorem when the proof strategy is settled; use `lean-prove`.
- Do not use it for non-mathematical or non-Lean tasks.

## Coordination Rule

- This skill is a coordinator. It should explicitly invoke these existing skills instead of re-explaining their internal instructions:
  - `mimate-proof-strategy`
  - `lean-prove`
  - `lean-verify`
- Use the lower-level skills for their own domains; keep this skill focused on sequencing, olympiad proof quality, and recovery logic.

## Workflow

1. Normalize the problem.
   - Restate the claim precisely.
   - Identify the mathematical domain: number theory, combinatorics, algebra, inequalities, geometry, or mixed.
   - Decide whether the final Lean development likely needs one theorem or several helper lemmas.

2. Start with `mimate-proof-strategy`.
   - Use `mimate-proof-strategy` first to search for 2-3 viable proof strategies.
   - Recommend one strategy before formalization.
   - Prefer olympiad-style structural proofs over exhaustive search.

3. Prefer non-exhaustive olympiad methods.
   - Try first: extremal arguments, contradiction, invariants, monovariants, divisibility, congruences, parity, factorization, bounding, descent, double counting, bijections, induction with a structural step, or symmetry breaking.
   - For minimum/maximum problems, separate existence from optimality and formalize both parts explicitly.
   - For impossibility claims, prefer structural obstructions before any finite search.

4. Hand off proof authoring to `lean-prove`.
   - Once the mathematical route is selected, use `lean-prove`.
   - If the theorem is new to the repo, create a fresh timestamped demonstration entry.
   - Split the informal solution into helper lemmas when the olympiad argument naturally has separate claims.
   - If a hidden support theorem is required, promote it to an explicit Lean theorem instead of burying it in prose.

5. Hand off validation to `lean-verify`.
   - Verify file-level first, then full project build.
   - If diagnostics show the strategy itself is wrong or incomplete, return to `mimate-proof-strategy`.
   - If diagnostics are local implementation issues, iterate with `lean-prove`.
   - Repeat until Lean accepts the development cleanly.

6. Generate the final PDF.
   - After Lean verification succeeds, update the blueprint section for the selected demonstration.
   - Keep `\lean{...}` references aligned with the theorems actually discussed in the paper.
   - Run the repo PDF flow only after the Lean file is accepted.
   - The final PDF should rely on repo tooling for:
     - short declaration names in the body,
     - the Lean glossary,
     - the annex with the full Lean source.

## Olympiad Heuristics

- For number theory, look first for gcd/coprime structure, divisor decomposition, and modular restrictions.
- For combinatorics, look first for double counting, counting the same object two ways, or a clean recurrence.
- For inequalities, look first for normalization, convexity candidates, rearrangement, or a hidden square/nonnegative quantity.
- For extremal/minimality problems, look for the largest/smallest witness that forces the main number or object to appear explicitly.
- For case splits, keep only mathematically meaningful cases; avoid wide enumerations unless the structure forces a tiny finite remainder.
- If search is unavoidable, isolate it in a named helper theorem and explain why the structural part already reduced the problem to that finite remainder.

## Failure Recovery

- If the current proof path drifts toward brute force too early, stop and return to `mimate-proof-strategy` for an alternative structural route.
- If a proof becomes too brittle in Lean, keep the same mathematics but split the argument into smaller lemmas through `lean-prove`.
- If `Mathlib` discovery becomes the blocker, follow the existing escalation path from `lean-prove` and `lean-verify`; do not turn this skill into a declaration-search script.

## Expected Outputs

- An informal olympiad-quality proof strategy selected before coding.
- A Lean development that makes the supporting lemmas explicit.
- Successful verification through `lean-verify`.
- A generated project PDF after the Lean development is accepted.
