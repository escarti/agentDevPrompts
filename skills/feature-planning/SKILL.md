---
name: feature-planning
description: Use after research (Z01 files exist) to create implementation plan - follow structured workflow
---

# Feature Workflow: Plan Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Read `AGENTS.md` first and `CLAUDE.md` if it exists

**This skill is a wrapper around `superpowers:writing-plans`.**

Its job is to:
- load repo constraints and `Z01` inputs
- require resolved research before planning
- invoke `superpowers:writing-plans`
- enforce the `Z02` / `Z02_CLARIFY` artifact contract used by this workflow

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature planning workflow",
  "plan": [
    {"step": "Step 1: Load project context (AGENTS.md first, CLAUDE.md if it exists)", "status": "in_progress"},
    {"step": "Step 2: Find and validate Z01 inputs", "status": "pending"},
    {"step": "Step 3: Invoke superpowers:writing-plans with the Z02 contract", "status": "pending"},
    {"step": "Step 4: Verify Z02 outputs and required phase metadata", "status": "pending"},
    {"step": "Step 5: Enforce Z02_CLARIFY completion gate", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## Workflow Steps

### Step 1: Load Project Context

Read `AGENTS.md` first. Then read `CLAUDE.md` if it exists.

Extract only what planning must preserve:
- required repo conventions and file locations
- forbidden approaches
- release or workflow constraints relevant to plan structure

Pass those repo-specific constraints into `superpowers:writing-plans`.

---

### Step 2: Find and Validate Z01 Inputs

`feature-planning` requires existing research artifacts.

Rules:
- Default to `docs/ai/ongoing/` for this repository.
- If existing workflow artifacts are already under another ongoing directory, use that discovered directory instead.
- Determine the feature slug from `Z01_{feature}_research.md`.

Required inputs:
- `Z01_{feature}_research.md`
- `Z01_CLARIFY_{feature}_research.md` if it exists

If multiple `Z01_*_research.md` files exist:
- use the one the user asked for
- otherwise ask which feature to plan

If no `Z01_{feature}_research.md` exists:
- stop and direct the user to `feature-researching` first
- do not proceed without research unless the user explicitly overrides this workflow

If `Z01_CLARIFY_{feature}_research.md` exists:
- read it
- if any `User response:` field is blank, stop and report: `Cannot plan with unanswered questions. Please answer all questions in Z01_CLARIFY_{feature}_research.md first.`

Extract from Z01:
- grounded behavior and explicit non-goals
- repo touchpoints and constraints
- answered clarifications
- risks, dependencies, compatibility concerns, and acceptance criteria

---

### Step 3: Invoke `superpowers:writing-plans`

Load and follow `superpowers:writing-plans` using Codex's current skill-loading flow.
If that dependency is unavailable, stop and report that the required Superpowers skill is missing.

Provide a compact instruction that adds only this workflow's contract:

`Create the implementation plan from Z01 research and save it to {ONGOING_DIR}/Z02_{feature}_plan.md. Preserve AGENTS.md / CLAUDE.md constraints. Keep the plan phase-aware for feature-implementing.`

The wrapper-owned `Z02` contract is:
- output path must be `{ONGOING_DIR}/Z02_{feature}_plan.md`
- feature slug must match the discovered `Z01` artifact
- plan must include explicit `## Phase N: <name>` sections
- each phase must include `**Phase Goal:**`, `**Phase Verification:**`, and `**Phase Boundary Rule:**`
- each task must include a stable phase field: `**Phase:** Phase N`
- create `{ONGOING_DIR}/Z02_CLARIFY_{feature}_plan.md` only for new blocking questions discovered during planning
- when answered clarifications are incorporated, remove resolved entries or delete the file entirely

Do not restate generic `writing-plans` requirements that skill already owns.

---

### Step 4: Verify `Z02` Outputs

Planning output is valid only if all of the following are true:
- `Z02_{feature}_plan.md` exists in `ONGOING_DIR`
- the feature slug matches the source `Z01`
- `Z02_CLARIFY_{feature}_plan.md` exists only when new blocking questions were discovered
- `Z02_{feature}_plan.md` contains at least one `## Phase N: <name>` section
- every phase contains `**Phase Goal:**`, `**Phase Verification:**`, and `**Phase Boundary Rule:**`
- every task uses `**Phase:** Phase N`

If any required phase metadata is missing:
- treat the plan as invalid
- do not mark planning complete
- revise the plan before handing off to `feature-implementing`

---

### Step 5: Enforce the `Z02_CLARIFY` Completion Gate

Planning is not complete while `Z02_CLARIFY_{feature}_plan.md` exists with unresolved items.

Unresolved means any of the following:
- the file still contains at least one open question entry
- any `User response:` is blank
- answers were provided but not yet incorporated into `Z02_{feature}_plan.md`

If unresolved `Z02_CLARIFY` exists:
1. Keep the workflow `in_progress`
2. Report only: `Planning blocked by unresolved clarifications in Z02_CLARIFY_{feature}_plan.md.`
3. Do not invoke or suggest `feature-implementing` yet

Only mark planning complete when:
1. `Z02_{feature}_plan.md` satisfies the `Z02` contract
2. all clarification answers are incorporated
3. `Z02_CLARIFY_{feature}_plan.md` is deleted or has no remaining unresolved entries

Report to the user:
- if complete: `Plan created: Z02_{feature}_plan.md. Ready for feature-workflow:feature-implementing.`
- if blocked: `Planning not complete. Resolve Z02_CLARIFY before implementation.`

## Red Flags

- Proceeded without `Z01_{feature}_research.md`
- Planned with unanswered `Z01_CLARIFY`
- Failed to pass repo constraints into `writing-plans`
- Saved `Z02` to the wrong directory or with the wrong feature slug
- Accepted a plan with missing phase metadata
- Created `Z02_CLARIFY` without a new blocking question
- Marked planning complete while unresolved `Z02_CLARIFY` remained

## Success Criteria

- Read `AGENTS.md` and `CLAUDE.md` if present
- Required `Z01` research before planning
- Blocked on unresolved `Z01_CLARIFY`
- Invoked `superpowers:writing-plans`
- Enforced the `Z02_{feature}_plan.md` path and feature slug
- Verified `## Phase N`, `**Phase Goal:**`, `**Phase Verification:**`, `**Phase Boundary Rule:**`, and `**Phase:** Phase N`
- Kept planning open until `Z02_CLARIFY` was resolved or removed

## When to Use

Use when:
- `Z01_{feature}_research.md` exists
- research clarifications are resolved
- you need a `Z02` plan artifact that is ready for `feature-implementing`

Don't use when:
- no `Z01` research exists
- research or planning clarifications are unresolved
- the work is already fully planned in the required `Z02` format
