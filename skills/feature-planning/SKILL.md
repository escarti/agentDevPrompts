---
name: feature-planning
description: Use after complete feature research exists locally or in a GitHub Idea issue and the feature needs an implementation plan
---

# Feature Workflow: Plan Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Read `AGENTS.md` first and `CLAUDE.md` if it exists

**This skill is a wrapper around `superpowers:writing-plans`.**

Its job is to:
- load repo constraints and a local `Z01` or GitHub `[Idea]` research input
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
    {"step": "Step 2: Resolve and validate the canonical research input", "status": "pending"},
    {"step": "Step 3: Invoke superpowers:writing-plans with the Z02 contract", "status": "pending"},
    {"step": "Step 4: Verify Z02 outputs and required phase metadata", "status": "pending"},
    {"step": "Step 5: Resolve whether to publish the approved Z02 plan to a tracker", "status": "pending"},
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

### Step 2: Resolve and Validate the Canonical Research Input

`feature-planning` requires one complete canonical research source in either form:
- local file: `Z01_{feature}_research.md`
- GitHub issue: `[Idea] <display feature name>`

#### Resolve the source

1. If the user names a local Z01 path or GitHub issue URL/reference, use that source. Do not substitute a different candidate if the named source cannot be read or validated.
2. Otherwise, discover local `Z01_*_research.md` files in the repository's ongoing directory and GitHub issues whose titles begin exactly with `[Idea] ` in the current repository.
3. If exactly one candidate exists, use it.
4. If multiple local and/or GitHub candidates exist, ask which feature to plan. Present enough source identity to distinguish them: local path or GitHub repository and issue number, plus the feature name.
5. If no candidate exists, stop and direct the user to `feature-workflow:feature-researching` first. Do not proceed without research unless the user explicitly overrides this workflow.

For local discovery:
- default to `docs/ai/ongoing/`
- if workflow artifacts already use another ongoing directory, use that discovered directory

For GitHub discovery and reads:
- use the current repository unless the user names another repository
- accept an issue in any state when it is explicitly named
- require the exact `[Idea] ` title prefix; a label named `Idea` or an incidental mention of the word is not sufficient
- read the complete current issue title and body before validating it
- if GitHub access fails, report the external blocker instead of guessing from a partial result or silently choosing another source

#### Derive planning identity

- From a local source, derive the feature slug from `Z01_{feature}_research.md`.
- From a GitHub source, remove the `[Idea] ` prefix to obtain the display feature name, then derive the feature slug using the research workflow's snake_case, special-character removal, and 50-character limit.
- Use the feature slug for `{ONGOING_DIR}/Z02_{feature}_plan.md`. A GitHub research source does not require or authorize creation of a local Z01.
- Default `ONGOING_DIR` to `docs/ai/ongoing/` when the selected GitHub source has no local ongoing directory context; prefer an already established repository ongoing directory when one exists.

#### Validate the source

Before planning, verify the selected local file or GitHub issue contains:
- summary and self-contained source requirements
- definition-level triage result
- a decision-provenance record for material product and technical choices
- current repository behavior, relevant touchpoints, constraints, and existing patterns
- resolved feature behavior and explicit non-goals
- edge cases and failure behavior
- dependencies, compatibility risks, and potential adaptations
- testing expectations and acceptance criteria
- no open questions, unresolved bifurcations, competing options without a selection, or agent-selected design assumptions

Apply this contract identically to both source forms. A GitHub issue is not valid merely because its title has the `[Idea] ` prefix.

If the source is incomplete, stop and report: `Research source is incomplete. Resume feature-workflow:feature-researching and resolve the remaining decisions conversationally before planning.`

Extract from the selected source:
- grounded behavior and explicit non-goals
- repo touchpoints and constraints
- resolved decisions and their provenance
- risks, dependencies, compatibility concerns, and acceptance criteria

---

### Step 3: Invoke `superpowers:writing-plans`

Load and follow the installed plugin skill `superpowers:writing-plans` directly.
If `superpowers:writing-plans` is unavailable, stop at this step and report its exact name; instruct the user to install or enable the Superpowers plugin and start a new session before retrying.

Provide a compact instruction that adds only this workflow's contract:

`Create the implementation plan from the validated research source and save it to {ONGOING_DIR}/Z02_{feature}_plan.md. Preserve AGENTS.md / CLAUDE.md constraints. Keep the plan phase-aware for feature-implementing.`

The wrapper-owned `Z02` contract is:
- output path must be `{ONGOING_DIR}/Z02_{feature}_plan.md`
- feature slug must match the resolved local Z01 or GitHub `[Idea]` source
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
- the feature slug matches the resolved research source
- `Z02_CLARIFY_{feature}_plan.md` exists only when new blocking questions were discovered
- `Z02_{feature}_plan.md` contains at least one `## Phase N: <name>` section
- every phase contains `**Phase Goal:**`, `**Phase Verification:**`, and `**Phase Boundary Rule:**`
- every task uses `**Phase:** Phase N`
- tracker publication, when requested, is previewed before mutation and preserves lossless, reconstructable coverage from `Z02`; GitHub and Jira both create exactly one child item per Z02 task

If any required phase metadata is missing:
- treat the plan as invalid
- do not mark planning complete
- revise the plan before handing off to `feature-implementing`

---

### Step 5: Resolve Whether to Publish the Approved Z02 Plan

Once `Z02_{feature}_plan.md` satisfies the `Z02` contract, treat that artifact as the primary planning deliverable.

After validating the plan:
- if the user already selected `GitHub issues`, `Jira epic plus tasks`, or `No publication`, honor that selection and do not ask again
- treat an explicit request for a GitHub or Jira proposal or preview as selecting that tracker preview mode, not as approval to publish remotely
- if the user did not select a publication mode, ask whether the approved `Z02` plan should also be published to a tracker and offer exactly these choices: `GitHub issues`, `Jira epic plus tasks`, or `No publication`
- describe tracker publication as an optional follow-on step, not a replacement for `Z02_{feature}_plan.md`
- do not publish anything by default
- do not start tracker-target resolution until the user selects a publication mode explicitly or through an unambiguous request for a tracker proposal or preview

If the user does not want tracker publication:
- skip Steps 6 and 7
- continue directly to Step 8

If GitHub or Jira tracker mode is selected, including through an explicit proposal or preview request:
- continue to Step 6 while keeping `Z02_{feature}_plan.md` as the source of truth

---

### Step 6: Build and Preview the Tracker Publication Model

If GitHub or Jira tracker mode is selected:
- derive the tracker item structure from the approved `Z02_{feature}_plan.md`
- preview the proposed tracker items before publishing them
- preserve phase boundaries, ordering, and verification intent from `Z02`
- surface any assumptions or mapping gaps that require confirmation
- use a preview model only; do not create or update remote tracker items in this step
- require the complete parent-and-children preview graph to be self-contained, without depending on local workflow artifacts for core implementation context
- enforce lossless tracker parity: the parent item and all child items together must contain enough information to reconstruct 100% of the implementation contract in `Z02_{feature}_plan.md`, including every phase, phase goal, phase verification, phase boundary rule, task boundary, file, interface, implementation step, dependency, constraint, verification command, expected result, and acceptance criterion
- preserve each Z02 task as exactly one tracker child with the same task number, title, phase, files, interfaces, complete checklist, prose, code blocks, commands, expected results, constraints, and dependencies; do not merge, split, summarize, reorder, reinterpret, or otherwise redesign tasks during publication
- put plan-wide context in the parent: goal, architecture, stack, source identity, global constraints, repository and data contracts, every phase's goal, verification, and boundary rule, the ordered child list, and the dependency graph
- permit only tracker-specific wrappers, replacement of preview placeholders with real tracker references, and omission of transient local-workflow bookkeeping; restate any implementation context carried by omitted bookkeeping
- reproduce the Z02 dependency graph exactly; do not infer a predecessor or blocker from task order or phase membership alone
- before requesting publication approval, reconstruct the complete Z02 implementation contract from the preview graph alone; if reconstruction loses or changes any contract element, keep the workflow in preview and revise the tracker items

Target resolution rules:
- for `GitHub issues`, default the publication target to the current repository unless the user explicitly chooses another repository
- for `Jira epic plus tasks`, use an explicit repository-defined Jira project reference when one exists
- if no repository-defined Jira project reference exists, ask the user which Jira project to use before requesting preview approval

Approval rules:
- no mutation before explicit approval of the preview
- do not ask for publication approval until the target repository or Jira project is resolved
- if the preview contains unresolved target, mapping, or dependency questions, keep the items in preview only

Publish-time body and link requirements to include in the preview:
- the complete parent-and-children tracker graph must be self-contained and must not depend on local workflow artifacts or external documents for required implementation context
- do not link to `Z01_*`, `Z02_*`, `Z03_*`, `Z04_*`, `Z05_*`, local file paths, or any other transient local workflow artifacts
- do not rely on external documents for required implementation context
- treat the parent issue or epic and each child issue or task together as a self-contained execution packet
- copy all plan-wide Z02 context once into the parent issue or epic
- copy all task-specific information from each Z02 task into its corresponding child issue or task without summarizing or omitting it
- add only child-specific execution context that is not already present in the parent
- require the implementation orchestrator to provide both the parent and child content to the implementing agent
- tracker items may reference only other tracker items when those references clarify execution order or parent/child structure
- all tracker targets: propose one parent item plus exactly one child item per Z02 task
- all tracker targets: the parent must contain the complete plan-wide context, enumerate the concrete child items in Z02 order with explicit dependencies, and contain a traceability table mapping every Z02 task to its single child
- all tracker targets: each child must contain the complete corresponding Z02 task contract without summarization, including behavior-specific tests and focused verification
- all tracker targets: preserve every verification command and expected result from Z02; do not normalize, deduplicate, broaden, narrow, or relocate verification in a way that prevents reconstruction
- all tracker targets: the published parent must contain actual child references in execution order, the final task-to-child traceability mapping, and the dependency/completion order
- `GitHub issues`: use `[Epic] <feature name>` for the parent and `[Task N][Parent #E] <task title>` for each child, where `N` and the task title are copied from Z02 and `E` is the created parent issue number; each child must reference the parent and explicit blockers/predecessors
- `Jira epic plus tasks`: use `[Task N] <task title>` for each child, where `N` and the task title are copied from Z02; each task must reference the epic, and explicit predecessor dependencies must appear in both task bodies and Jira issue links

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

For either tracker target:
- create the parent item first
- create exactly one child item per Z02 task
- copy the complete corresponding Z02 task contract into each child without summarization or reinterpretation
- update the parent after child creation with actual child references, the final traceability table, and dependency order
- reread the published parent and every child and reconstruct the complete Z02 implementation contract from the published graph alone; if any contract element is missing or changed, keep planning incomplete

If publishing `GitHub issues`:
- create the epic-like parent issue in the resolved repository using `[Epic] <feature name>`
- create children using `[Task N][Parent #E] <task title>`, where `N` and the task title are copied from Z02 and `E` is the created parent issue number
- include parent and explicit blocker/predecessor references in each child body
- keep required implementation context in the GitHub issues themselves rather than linking to local planning artifacts

If publishing `Jira epic plus tasks`:
- create the epic in the resolved Jira project
- create child tasks using `[Task N] <task title>`, where `N` and the task title are copied from Z02
- include epic references and explicit predecessor dependency language in each task body, plus Jira issue links for those dependencies
- keep required implementation context in the Jira items themselves rather than linking to local planning artifacts

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
4. if tracker publication occurred, the published parent and child items passed the lossless tracker-parity reconstruction comparison against `Z02_{feature}_plan.md`

Report to the user:
- if complete without publication: `Plan created: Z02_{feature}_plan.md. Tracker publication skipped. Ready for feature-workflow:feature-implementing.`
- if complete with publication: `Plan created: Z02_{feature}_plan.md and published to the approved tracker destination. Ready for feature-workflow:feature-implementing.`
- if blocked: `Planning not complete. Resolve Z02_CLARIFY before implementation.`

## Red Flags

- Proceeded without a complete local Z01 or GitHub `[Idea]` research source
- Planned from a research source with unresolved decisions or missing decision provenance
- Treated a GitHub issue as research without reading its complete current title and body
- Accepted a GitHub issue without the exact `[Idea] ` title prefix
- Silently chose among multiple local and/or GitHub research candidates
- Created a local Z01 while planning from a GitHub `[Idea]` source
- Failed to pass repo constraints into `writing-plans`
- Saved `Z02` to the wrong directory or with the wrong feature slug
- Accepted a plan with missing phase metadata
- Treated tracker publication as a replacement for `Z02_{feature}_plan.md`
- Mutated GitHub or Jira before preview approval
- Asked the user to choose a publication mode after the user had already selected one explicitly or through an unambiguous tracker proposal or preview request
- Asked for tracker publication without offering `GitHub issues`, `Jira epic plus tasks`, or `No publication`
- Used a non-preview flow for tracker preparation
- Failed to resolve the target repository or Jira project before approval
- Published tracker items without explicit approval
- Published a tracker graph from which the complete Z02 implementation contract cannot be reconstructed
- Published GitHub or Jira items without exactly one child for every Z02 task
- Merged, split, summarized, reordered, reinterpreted, or otherwise redesigned Z02 tasks during publication
- Dropped or normalized files, interfaces, implementation steps, code blocks, dependencies, constraints, verification commands, expected results, or acceptance criteria from a Z02 task
- Omitted plan-wide goal, architecture, stack, source identity, global constraints, repository/data contracts, phase metadata, ordered children, or dependency graph from the parent
- Published tracker items that relied on `Z0X` files, local paths, or external documents for required implementation context
- Linked tracker items back to transient local workflow artifacts instead of restating the required information in the issues themselves
- Published a parent issue or epic that described child-item policy abstractly but did not enumerate the actual child items, their execution order, and their dependency/completion order
- Published GitHub child issues whose titles did not use the `[Task N][Parent #E] <task title>` pattern or preserve the Z02 task number and title
- Published GitHub issues without a parent issue, child issues, or final parent back-links
- Published Jira child tasks whose titles did not use the `[Task N] <task title>` pattern or preserve the Z02 task number and title
- Published Jira tasks without epic references, predecessor links, or dependency language in task bodies
- Guessed a Jira project when no repo-defined project reference existed
- Created `Z02_CLARIFY` without a new blocking question
- Marked planning complete while unresolved `Z02_CLARIFY` remained

## Success Criteria

- Read `AGENTS.md` and `CLAUDE.md` if present
- Required complete research before planning from either a local Z01 or GitHub `[Idea]` issue
- Resolved an explicit source first and otherwise handled local and GitHub candidates without guessing
- Rejected incomplete research from either source form and routed unresolved decisions back to live feature research
- Invoked `superpowers:writing-plans`
- Enforced the `Z02_{feature}_plan.md` path and feature slug
- Verified `## Phase N`, `**Phase Goal:**`, `**Phase Verification:**`, `**Phase Boundary Rule:**`, and `**Phase:** Phase N`
- Treated tracker publication as an optional post-`Z02` tail
- Honored an already selected publication mode without asking again; otherwise offered explicit tracker choices and kept `No publication` as the default path
- Built a preview-only publication model with resolved GitHub or Jira targets before approval
- Previewed destination, tasks, and dependencies before mutation
- Kept tracker items self-contained and free of required links to local workflow artifacts or external documents
- Published one tracker parent plus exactly one child per Z02 task for both GitHub and Jira when approved
- Preserved every Z02 task boundary and complete task contract without summarization or reinterpretation
- Preserved plan-wide context and phase metadata in the parent so the complete Z02 implementation contract is reconstructable from tracker items alone
- Enforced `[Epic] <feature name>` for GitHub parent titles and `[Task N][Parent #E] <task title>` for GitHub child titles
- Enforced `[Task N] <task title>` for Jira child task titles
- Published tracker items only after explicit approval
- Ensured the parent issue or epic enumerated the actual child items in execution order with explicit dependency/completion ordering
- Passed the lossless tracker-parity reconstruction comparison before approval and after publication
- Kept publication aligned to the parent/child or epic/task contract with dependency references
- Kept planning open until `Z02_CLARIFY` was resolved or removed

## When to Use

Use when:
- `Z01_{feature}_research.md` or a GitHub `[Idea] <display feature name>` issue exists
- the selected source contains complete research with resolved, provenance-backed material decisions
- you need a `Z02` plan artifact that is ready for `feature-implementing`

Don't use when:
- no complete local Z01 or GitHub `[Idea]` research source exists
- the selected research source still contains unresolved decisions
- planning clarifications are unresolved
- the work is already fully planned in the required `Z02` format
