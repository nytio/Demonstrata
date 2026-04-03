name: mimate-proof-strategy
description: "Repo-specific strategy pre-pass for nontrivial changes in mimate. Use to choose a proof route, decomposition, or implementation approach before handing off to olympiad-formalize, lean-prove, or lean-verify when no narrower skill already determines the path."
---

# Mimate Proof Strategy

## When to Use

- Use this skill for nontrivial design choices in this repository.
- Use it before broad behavior changes, workflow changes, or new project-specific skills.
- Use it as a short pre-pass when there are real trade-offs and the best path is not obvious from local context.
- For Lean or olympiad work, use it only to select a proof route or decomposition before handing off to `olympiad-formalize`, `lean-prove`, or `lean-verify`.

## When Not to Use

- Do not use for trivial edits or straightforward bug fixes.
- Do not use when the user already asked to execute a clear plan.
- Do not block a narrower skill. In this repo, prefer `olympiad-formalize`, `lean-prove`, `lean-verify`, `orquestador-proyecto`, `frontend-design`, `interface-design`, `openai-docs`, or `context7-docs` when they already cover the task.
- Do not turn this skill into a mandatory questionnaire when the repo and the user request already provide enough context.

## Overview

Use this skill to reduce ambiguity before implementation, not to prolong design discussion.

Start from the current project context, extract constraints from the repo, identify 2-3 viable approaches, and choose a recommended path quickly. Surface trade-offs only when they materially affect the implementation.

## The Process

**1. Inspect local context first**
- Read the relevant files, scripts, docs, skills, and recent analogous changes.
- Extract constraints from `AGENTS.md`, repo structure, and existing workflows.
- Check whether the repo already has a standard path that should be reused.

**2. Generate options**
- Identify 2-3 viable approaches.
- Prefer structural differences with real trade-offs, not cosmetic variants.
- Eliminate options that violate repo conventions or require unnecessary new machinery.

**3. Recommend one path**
- Pick the option with the best fit for the repo and the user request.
- State the reasoning briefly and concretely.
- Call out only the assumptions that could change implementation in a meaningful way.

**4. Hand off fast**
- If a narrower skill should implement the work, switch to it immediately.
- If implementation can proceed directly, do not stop just to ask for confirmation unless the missing information is genuinely blocking.

## Mathematical Problem Flow

Use this section when the task is a mathematical problem, especially olympiad-style work that will later be formalized in Lean.

**1. Normalize the statement**
- Restate the claim precisely.
- Identify the domain: number theory, algebra, combinatorics, geometry, inequalities, or mixed.
- Separate the final claim from hidden subclaims such as existence, uniqueness, classification, extremality, or minimality.

**2. Choose a reasoning mode**
- Try both directions briefly:
  - Deductive: start from the hypotheses and push consequences forward.
  - Inductive/backward: start from the target and ask what would be enough to prove it.
- Also test whether the problem is better framed by contradiction, contrapositive, extremal choice, descent, invariant, or constructive parametrization.
- Prefer the mode that exposes the structure with the fewest ad hoc cases.

**3. Probe the problem on small instances**
- Check small values, boundary cases, and degenerate configurations to detect the likely answer shape.
- Use bounded search only as a reconnaissance tool, never as the main proof idea unless the problem is genuinely reduced to a tiny finite remainder.
- Record what the small cases suggest: a conjectured classification, parity pattern, divisibility obstruction, or monotonic trend.

**4. Build a structural route**
- Identify the basic tools that are likely relevant:
  - parity, divisibility, gcd/coprimality, modular arithmetic, factorization, bounding;
  - extremal arguments, induction, recurrence, invariants, double counting;
  - standard algebraic identities, telescoping, symmetry, or normalization.
- Decide whether the argument should split into helper lemmas.
- Prefer a few mathematically meaningful cases over exhaustive enumeration.
- Reduce to a finite remainder only after a structural argument has already done most of the work.

**5. Search for nearby formal ingredients**
- Check whether the repo already contains a similar theorem or lemma pattern.
- For Mathlib exploration, first use local search and diagnostics. If deeper exploration is needed, consult `docs/mathlib-exploration.md`.
- Treat Mathlib lookup as support, not as the substitute for a new proof.
- If a theorem appears to exist, still decide whether the repo needs a new demonstration entry or just a shorter proof using that theorem.

**6. Produce a handoff-ready proof plan**
- State the recommended proof strategy in a short paragraph.
- List the helper lemmas or case splits likely needed.
- Name any finite checks separately from the structural part.
- Then move into `olympiad-formalize`, `lean-prove`, or `lean-verify`.

## Interaction Rules

- Prefer zero questions when safe assumptions can be made from local context.
- Ask at most one blocking question only when the answer would materially change the implementation.
- Keep visible strategy notes short: a brief decision memo, a few bullets, or 1-2 concise paragraphs.
- Do not insist on 200-300 word sections.
- Do not require iterative approval after every section.
- Do not write a design document by default. Only create one if the user asks, or if a longer execution workflow clearly benefits from a durable artifact.

## Project-Specific Guidance

- For olympiad and Lean tasks, focus on proof structure, helper lemmas, likely mathematical reductions, and verification order. Then move into `olympiad-formalize`, `lean-prove`, and `lean-verify`.
- For olympiad and Lean tasks, common useful lenses are:
  - direct vs contradiction;
  - forward deduction vs backward target analysis;
  - induction vs descent;
  - structural reduction vs bounded remainder cases;
  - explicit construction vs impossibility obstruction.
- For theorem search, inspect local declarations first. Escalate to the documented Mathlib exploration path only when names or nearby results are the blocker.
- For repo workflow or skill changes, focus on trigger boundaries, progressive disclosure, whether scripts or references are justified, and interaction with existing skills.
- For UI work in an existing product surface, preserve the established visual language unless the user explicitly asks to explore alternatives.
- For OpenAI or third-party tooling choices, delegate the documentation lookup to `openai-docs` or `context7-docs` instead of embedding stale guidance here.

## Expected Outputs

- A recommended approach.
- Concrete next steps for implementation.
- Explicit assumptions and risks only when they matter.
- The next skill, file, or command to use.
- For mathematical tasks specifically:
  - the chosen proof mode;
  - the likely helper lemmas;
  - the meaningful case split, if any;
  - any small-case evidence separated clearly from the final proof route.

## Gotchas and Edge Cases

- Keep the skill lightweight. This repo already has several more specific skills; this skill should sharpen the route, not become the main workflow.
- The recent olympiad formalization flow is the model case: the user had already provided a precise problem, so the useful strategy step was a short internal comparison of proof strategies, not a long question-driven dialogue.
- Do not confuse theorem search with proof design. Similar theorems and Mathlib declarations are evidence and support, not the plan by themselves.
- Do not let small-case experimentation replace the structural proof. Use it to suggest the route, not to justify the result.
- If the informal argument starts fragmenting into many brittle subcases, step back and look for a cleaner invariant, factorization, extremal choice, or auxiliary lemma.
- If evidence is insufficient, gather local context first before asking the user.
