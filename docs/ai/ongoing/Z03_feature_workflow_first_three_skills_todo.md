# Feature Workflow First Three Skills Todo

The core workflow idea is still good, but the first three skills are carrying too much Claude-era machinery and too much low-level execution prescription. If your goal is “solid, disambiguated enough spec that later produces production-ready code,” I’d keep the stage structure, self-contained research, and clarification gates, but rewrite the skills around current Codex primitives and shift them from “generate exhaustive pseudo-code” to “generate decision-complete artifacts with explicit open decisions, constraints, acceptance criteria, and verification.”

**Date**: 2026-06-18
**Reviewed files**:
- `skills/feature-researching/SKILL.md`
- `skills/feature-planning/SKILL.md`
- `skills/feature-implementing/SKILL.md`

## High Priority

- [ ] Replace all `TodoWrite` requirements with Codex-compatible progress tracking.
  - Files: `skills/feature-researching/SKILL.md`, `skills/feature-planning/SKILL.md`, `skills/feature-implementing/SKILL.md`
  - Problem: The workflows are not executable as written in current Codex because `TodoWrite` is mandatory even though this environment uses `update_plan`.
  - Fix: Rewrite mandatory first-action sections, examples, red flags, and success criteria to use current Codex tooling.

- [ ] Remove or rewrite instructions that depend on a generic `Skill tool` abstraction instead of current Codex skill-loading behavior.
  - Files: `skills/feature-researching/SKILL.md`, `skills/feature-planning/SKILL.md`, `skills/feature-implementing/SKILL.md`
  - Problem: The skills still assume an older interaction model and are not precise about how Codex should invoke dependent skills.
  - Fix: Use Codex-specific wording and explicit fallback behavior when a dependent skill or tool is unavailable.

- [ ] Rework `feature-implementing` so its guarantees match what `superpowers:executing-plans` actually provides.
  - File: `skills/feature-implementing/SKILL.md`
  - Problem: The wrapper requires batching, code review checkpoints, Z99 updates, and subagent behavior that the delegated `executing-plans` skill does not define.
  - Fix: Either add those guarantees to the execution dependency stack or remove the claims and own the orchestration logic locally.

## Medium Priority

- [ ] Make `feature-planning` fail closed when research is missing.
  - File: `skills/feature-planning/SKILL.md`
  - Problem: The current workflow allows planning to proceed without Z01 research, which undermines the goal of producing a repo-grounded, disambiguated spec.
  - Fix: Require Z01 artifacts by default and allow bypass only through an explicit user override.

- [ ] Replace the “5 or more questions” rule in research with a severity-based ambiguity gate.
  - File: `skills/feature-researching/SKILL.md`
  - Problem: Question count is a weak proxy for design ambiguity and can discard good work for the wrong reasons.
  - Fix: Gate on blocking ambiguity categories such as unresolved product decisions, architecture choices, data contracts, or security constraints.

- [ ] Relax the requirement for exact file paths and line ranges during research.
  - File: `skills/feature-researching/SKILL.md`
  - Problem: The workflow pushes for false precision too early; exact edit ranges often belong to planning, not research.
  - Fix: Let research identify likely files and integration points, then require exact edit targets in Z02 planning.

- [ ] Reduce plan bloat by changing `feature-planning` from pseudo-implementation to decision-complete planning.
  - File: `skills/feature-planning/SKILL.md`
  - Problem: Requiring complete code examples, micro-step TDD tasks, and commit-by-commit detail makes plans heavy and encourages hallucinated implementation detail.
  - Fix: Focus Z02 on decisions, interfaces, data flow, edge cases, acceptance criteria, and verification strategy; keep code snippets only where they prevent ambiguity.

## Lower Priority

- [ ] Improve CLARIFY files so questions include enough context to get high-quality answers.
  - File: `skills/feature-researching/SKILL.md`
  - Problem: Bare “Agent question / User response” pairs omit the tradeoff context needed for strong decisions.
  - Fix: Allow a short rationale, listed options, and a recommended default for each non-trivial clarification.

- [ ] Stop requiring full artifact contents to be forwarded into implementation execution.
  - File: `skills/feature-implementing/SKILL.md`
  - Problem: Passing full AGENTS, CLAUDE, Z01, Z02, and Z99 contents does not scale well and adds noisy context.
  - Fix: Pass a compact execution brief plus only the artifact excerpts needed for the current batch.

## Target Outcome

- [ ] Preserve the current stage structure: research -> planning -> implementing.
- [ ] Keep the strongest existing rules: self-contained Z01, clarification gates, and separation between planning artifacts and execution progress.
- [ ] Rewrite the three skills so they are Codex-native and optimized for producing a solid, disambiguated spec that can lead to production-ready code.
