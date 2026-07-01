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
- optionally prepare and publish tracker items only after the `Z02` plan is approved

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature planning workflow",
  "plan": [
    {"step": "Step 1: Load project context (AGENTS.md first, CLAUDE.md if it exists)", "status": "in_progress"},
    {"step": "Step 2: Find and validate Z01 inputs", "status": "pending"},
    {"step": "Step 3: Invoke superpowers:writing-plans with the Z02 contract", "status": "pending"},
    {"step": "Step 4: Verify Z02 outputs and required phase metadata", "status": "pending"},
    {"step": "Step 5: Ask whether to publish the approved Z02 plan to a tracker", "status": "pending"},
    {"step": "Step 6: Build and preview the tracker publication model", "status": "pending"},
    {"step": "Step 7: Publish tracker items only after explicit approval", "status": "pending"},
    {"step": "Step 8: Enforce Z02_CLARIFY completion gate", "status": "pending"}
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
- tracker publication, when requested, is previewed before mutation and uses one child item per `Z02` task

If any required phase metadata is missing:
- treat the plan as invalid
- do not mark planning complete
- revise the plan before handing off to `feature-implementing`

---

### Step 5: Ask Whether to Publish the Approved Z02 Plan

Once `Z02_{feature}_plan.md` satisfies the `Z02` contract, treat that artifact as the primary planning deliverable.

After validating the plan:
- ask whether the approved `Z02` plan should also be published to a tracker
- offer exactly these choices: `GitHub issues`, `Jira epic plus tasks`, or `No publication`
- describe tracker publication as an optional follow-on step, not a replacement for `Z02_{feature}_plan.md`
- do not publish anything by default
- do not start tracker-target resolution until the user selects a publication mode

If the user does not want tracker publication:
- skip Steps 6 and 7
- continue directly to Step 8

If the user wants tracker publication:
- continue to Step 6 while keeping `Z02_{feature}_plan.md` as the source of truth

---

### Step 6: Build and Preview the Tracker Publication Model

If tracker publication is requested:
- derive the tracker item structure from the approved `Z02_{feature}_plan.md`
- preview the proposed tracker items before publishing them
- preserve phase boundaries, ordering, and verification intent from `Z02`
- surface any assumptions or mapping gaps that require confirmation
- use a preview model only; do not create or update remote tracker items in this step
- require the previewed tracker items themselves to be self-contained, without depending on local workflow artifacts for core implementation context

Target resolution rules:
- for `GitHub issues`, default the publication target to the current repository unless the user explicitly chooses another repository
- for `Jira epic plus tasks`, use an explicit repository-defined Jira project reference when one exists
- if no repository-defined Jira project reference exists, ask the user which Jira project to use before requesting preview approval

Approval rules:
- no mutation before explicit approval of the preview
- do not ask for publication approval until the target repository or Jira project is resolved
- if the preview contains unresolved target, mapping, or dependency questions, keep the items in preview only

Publish-time body and link requirements to include in the preview:
- all tracker items must be self-contained for implementation purposes
- do not link to `Z01_*`, `Z02_*`, `Z03_*`, `Z04_*`, `Z05_*`, local file paths, or any other transient local workflow artifacts
- do not rely on external documents for required implementation context
- if information from `Z02` is needed, copy or restate it into the tracker items themselves
- tracker items may reference only other tracker items when those references clarify execution order or parent/child structure
- `GitHub issues`: propose one epic-like parent issue plus one child issue per `Z02` task
- `GitHub issues`: the parent issue must restate the complete roadmap context needed to understand the work, including the feature goal, the ordered phase structure, and how the child issues fit together
- `GitHub issues`: the parent issue preview must include the full intended child issue list in execution order, using concrete child titles and explicit predecessor/dependency notes for each child
- `GitHub issues`: the parent issue preview must not stop at a policy statement like "one child per task"; it must enumerate the actual planned children and their order
- `GitHub issues`: each child issue must reference the parent issue and any blocker or predecessor tasks from `Z02`
- `GitHub issues`: each child issue must include all task intent, scope boundaries, dependencies, and verification expectations needed to implement that task without opening the local `Z02` plan
- `GitHub issues`: the parent issue must be updated after child creation with real child issue references, not placeholders
- `GitHub issues`: the published parent issue must contain the actual created child issue references in execution order and must state the dependency/completion order between those child issues
- `Jira epic plus tasks`: propose one epic plus one task per `Z02` task
- `Jira epic plus tasks`: the epic must restate the complete roadmap context needed to understand the work, including the feature goal, the ordered phase structure, and how the child tasks fit together
- `Jira epic plus tasks`: the epic preview must include the full intended child task list in execution order, using concrete child titles and explicit predecessor/dependency notes for each task
- `Jira epic plus tasks`: the epic preview must not stop at a policy statement like "one task per Z02 task"; it must enumerate the actual planned children and their order
- `Jira epic plus tasks`: each task must reference the epic and any predecessor tasks from `Z02`
- `Jira epic plus tasks`: each task must include all task intent, scope boundaries, dependencies, and verification expectations needed to implement that task without opening the local `Z02` plan
- `Jira epic plus tasks`: dependency language must appear both in issue links and in the task bodies when predecessor relationships exist
- `Jira epic plus tasks`: the published epic must contain the actual created child task references in execution order and must state the dependency/completion order between those child tasks

Do not mutate or replace `Z02_{feature}_plan.md` during tracker preparation.

---

### Step 7: Publish Tracker Items Only After Explicit Approval

Tracker publication requires an explicit user approval after preview.

Rules:
- do not publish on implied consent
- do not publish from the existence of `Z02_{feature}_plan.md` alone
- do not publish if the preview still contains unresolved mapping questions
- do not publish if the target repository or Jira project is unresolved
- keep `Z02_{feature}_plan.md` as the canonical local planning artifact after publication

If publishing `GitHub issues`:
- create the epic-like parent issue in the resolved repository
- create one child issue per `Z02` task
- include parent references and blocker references in each child issue body
- keep all required implementation context in the GitHub issues themselves rather than linking back to local planning artifacts
- update the parent issue after child creation so it contains real links or issue references to every created child
- ensure the updated parent issue lists the child issues in the intended execution order and explicitly describes which child issues block or precede later ones

If publishing `Jira epic plus tasks`:
- create the epic in the resolved Jira project
- create one task per `Z02` task
- include epic references and predecessor-task dependency language in each task body
- keep all required implementation context in the Jira issues themselves rather than linking back to local planning artifacts
- create issue links that express the predecessor relationships between tasks when those dependencies exist
- ensure the updated epic lists the child tasks in the intended execution order and explicitly describes which child tasks block or precede later ones

If approval is not given:
- leave tracker items unpublished
- keep `Z02_{feature}_plan.md` as the completed planning artifact

---

### Step 8: Enforce the `Z02_CLARIFY` Completion Gate

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
- if complete without publication: `Plan created: Z02_{feature}_plan.md. Tracker publication skipped. Ready for feature-workflow:feature-implementing.`
- if complete with publication: `Plan created: Z02_{feature}_plan.md and published to the approved tracker destination. Ready for feature-workflow:feature-implementing.`
- if blocked: `Planning not complete. Resolve Z02_CLARIFY before implementation.`

## Red Flags

- Proceeded without `Z01_{feature}_research.md`
- Planned with unanswered `Z01_CLARIFY`
- Failed to pass repo constraints into `writing-plans`
- Saved `Z02` to the wrong directory or with the wrong feature slug
- Accepted a plan with missing phase metadata
- Treated tracker publication as a replacement for `Z02_{feature}_plan.md`
- Mutated GitHub or Jira before preview approval
- Asked for tracker publication without offering `GitHub issues`, `Jira epic plus tasks`, or `No publication`
- Used a non-preview flow for tracker preparation
- Failed to resolve the target repository or Jira project before approval
- Published tracker items without explicit approval
- Published a tracker graph that dropped task dependencies or verification expectations
- Published tracker items that relied on `Z0X` files, local paths, or external documents for required implementation context
- Linked tracker items back to transient local workflow artifacts instead of restating the required information in the issues themselves
- Published a parent issue or epic that described child-item policy abstractly but did not enumerate the actual child items, their execution order, and their dependency/completion order
- Published GitHub issues without a parent issue, child issues, or final parent back-links
- Published Jira tasks without epic references, predecessor links, or dependency language in task bodies
- Guessed a Jira project when no repo-defined project reference existed
- Created `Z02_CLARIFY` without a new blocking question
- Marked planning complete while unresolved `Z02_CLARIFY` remained

## Success Criteria

- Read `AGENTS.md` and `CLAUDE.md` if present
- Required `Z01` research before planning
- Blocked on unresolved `Z01_CLARIFY`
- Invoked `superpowers:writing-plans`
- Enforced the `Z02_{feature}_plan.md` path and feature slug
- Verified `## Phase N`, `**Phase Goal:**`, `**Phase Verification:**`, `**Phase Boundary Rule:**`, and `**Phase:** Phase N`
- Treated tracker publication as an optional post-`Z02` tail
- Offered explicit tracker choices and kept `No publication` as the default path
- Built a preview-only publication model with resolved GitHub or Jira targets before approval
- Previewed destination, tasks, and dependencies before mutation
- Kept tracker items self-contained and free of required links to local workflow artifacts or external documents
- Published one parent item and one child item per `Z02` task when approved
- Published tracker items only after explicit approval
- Ensured the parent issue or epic enumerated the actual child items in execution order with explicit dependency/completion ordering
- Kept publication aligned to the parent/child or epic/task contract with dependency references
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
