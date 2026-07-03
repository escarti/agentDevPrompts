---
name: feature-implementing
description: Use to execute either a local Z02 implementation plan or a published GitHub/Jira tracker graph with the workflow's batching and execution-mode controls
---

# Feature Workflow: Implement Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan
2. Mark Step 1 as `in_progress`
3. Verify a supported implementation source exists
4. Split early into local-plan mode or tracker mode

This skill is the workflow-owned implementation controller. It handles source discovery, clarification gates, context loading, execution-mode selection, dependency-aware batching, proof validation, and approval between batches.

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature implementation workflow",
  "plan": [
    {"step": "Step 1: Find the implementation source, entrypoint, and feature name", "status": "in_progress"},
    {"step": "Step 2: Check for unresolved clarifications", "status": "pending"},
    {"step": "Step 3: Load context (AGENTS.md, CLAUDE.md, Z01, source artifacts)", "status": "pending"},
    {"step": "Step 4: Split into local-plan mode or tracker mode and build the live execution model", "status": "pending"},
    {"step": "Step 5: Ask the user to choose execution mode", "status": "pending"},
    {"step": "Step 6: Select the next dependency-ready batch from the live execution model", "status": "pending"},
    {"step": "Step 7: Delegate only the current batch to the chosen execution controller", "status": "pending"},
    {"step": "Step 8: Verify the batch outcome and update the live execution tracker", "status": "pending"},
    {"step": "Step 9: Ask approval before the next batch if work remains", "status": "pending"},
    {"step": "Step 10: Enforce the mode-specific completion gate", "status": "pending"}
  ]
})
```

After each step, mark it completed and move `in_progress` to the next step.

## Workflow Steps

### Step 1: Find Planning Source and Feature Name

Supported implementation sources:
- `Z02_{feature}_plan.md` in an ongoing directory
- a GitHub parent roadmap issue plus child issues created from `feature-planning`
- a Jira epic plus child tasks created from `feature-planning`

Local file discovery:
- scan for `Z02_*_plan.md` in common ongoing locations
- if multiple Z02 plans exist and the user specified a feature name, use that plan
- if multiple Z02 plans exist and the user did not specify a feature name, ask which plan to execute

Tracker entrypoint discovery:
- GitHub entrypoint: parent roadmap issue URL or issue number in the current repository
- Jira entrypoint: epic key or epic URL

Source selection rules:
- if both a local Z02 file and a tracker entrypoint are provided, prefer the source explicitly named by the user
- otherwise prefer the local Z02 file
- if the user does not name a source and multiple tracker entrypoints are present without a local Z02, ask which tracker source to execute
- if a tracker entrypoint does not resolve to its parent item plus child work items, STOP and ask for a valid entrypoint

If no supported source is provided:
- report: "No implementation source found. Run feature-workflow:feature-planning first."
- do not proceed without a source

Feature name extraction:
- local-plan mode: from `Z02_{feature}_plan.md`
- tracker mode: prefer the explicit feature slug preserved by `feature-planning`
- otherwise normalize the parent issue or epic title into the workflow feature slug format
- if tracker mode does not preserve a stable feature name and the title cannot be safely normalized, STOP and ask the user to confirm the feature name

Ongoing directory rules:
- local-plan mode: the plan's ongoing directory is authoritative
- tracker mode: if a matching ongoing directory already exists, keep using it for Z01 and clarify lookup
- otherwise default to `docs/ai/ongoing/`

### Step 2: Check for Unresolved Clarifications

Check `ONGOING_DIR` for:
- `Z01_CLARIFY_{feature}_research.md`
- `Z02_CLARIFY_{feature}_plan.md`

If `Z01_CLARIFY` exists:
- read it
- if any `User response:` field is blank, STOP and report: "Cannot implement with unanswered research questions. Please answer all questions in Z01_CLARIFY_{feature}_research.md first."

If `Z02_CLARIFY` exists:
- read it
- if any `User response:` field is blank, STOP and report: "Cannot implement with unanswered plan questions. Please answer all questions in Z02_CLARIFY_{feature}_plan.md first."

Proceed only when all clarifications are resolved.

### Step 3: Load Context Files

Read all available context in this order:

1. `AGENTS.md`, then `CLAUDE.md` if it exists
2. `Z01_{feature}_research.md`, then `Z01_CLARIFY_{feature}_research.md` if answered
3. Planning source:
   - local-plan mode: `Z02_{feature}_plan.md`, then `Z02_CLARIFY_{feature}_plan.md` if answered
   - tracker mode: parent issue or epic body, all child issues or tasks, and only the tracker metadata needed to preserve phase order, task order, dependencies, and verification expectations

Tracker mode requirements:
- child items must be self-contained
- parent plus children must preserve ordered phases or an equivalent ordered execution sequence
- dependency or predecessor order must be explicit
- verification expectations must be present in the child items
- prefer explicit planning metadata emitted by `feature-planning` over inferred structure

Reject tracker mode if the parent/child graph does not preserve near-parity with the local Z02 structure. Report:
"Tracker source does not preserve enough `feature-planning` structure to execute safely. Use the local Z02 plan or regenerate the tracker artifacts."

Extract and preserve:
- required project constraints
- research decisions that must survive implementation
- normalized task identities
- phase boundaries
- dependency edges
- verification expectations

Prepare a compact execution brief, not full artifact dumps.

### Step 4: Split Into Local-Plan Mode or Tracker Mode

After source detection and context loading, branch immediately into one of these execution models.

#### Local-Plan Mode

Use local-plan mode when the source is `Z02_{feature}_plan.md`.

Live execution tracker:
- `Z99_implementation_status.md`

Proof ledger:
- at least one validated, attributable commit per completed task on the feature branch

Rules:
- create or reconcile `{ONGOING_DIR}/Z99_implementation_status.md` before execution-mode selection
- normalize the plan into ordered phases, ordered tasks, stable task identifiers, dependencies, and verification checkpoints
- add per-task status fields: `pending`, `in_progress`, `done`, `blocked`
- add per-task proof-of-work fields
- require each completed task to map to one isolated, attributable commit on the feature branch
- require the commit message or returned metadata to make task attribution unambiguous
- add `Current batch` and `Blockers` sections
- treat Z99 as the live execution checklist and the file as persisted resume state
- do not edit the original Z02 plan

If Z99 already exists:
- reconcile it with the latest normalized task set
- append missing tasks without deleting existing status or proof
- resume from the earliest unfinished task in the earliest unfinished phase

#### Tracker Mode

Use tracker mode when the source is a GitHub parent roadmap issue or Jira epic with child items.

Live execution tracker:
- the tracker itself

Proof ledger:
- at least one validated, attributable commit per completed child item on the epic branch

Rules:
- do not create, read, reconcile, or rely on `Z99_implementation_status.md`
- treat open child items as the remaining work list
- preserve parent-declared phase order and explicit predecessor dependencies
- use one branch per parent issue or epic
- require each completed child item to map to one attributable commit on that branch
- require the commit message or returned metadata to make child-item attribution unambiguous
- mark the child item done in the tracker as soon as the commit SHA is validated on the epic branch and verification was reported

Tracker mode is invalid if:
- the tracker is missing self-contained implementation context
- dependencies are ambiguous
- verification expectations are absent
- the parent/child graph cannot support direct execution without a local Z02

### Step 5: Ask the User to Choose Execution Mode

Always ask. Present exactly these two execution modes:

1. Subagent-Driven (recommended) - Use `superpowers:subagent-driven-development` for the current batch.
2. Inline Execution - Use `superpowers:executing-plans` for the current batch.

Do not invent additional execution modes.

If the user chooses Subagent-Driven:
- load and follow `superpowers:subagent-driven-development`
- if unavailable, stop and report that the required skill is missing

If the user chooses Inline Execution:
- load and follow `superpowers:executing-plans`
- if unavailable, stop and report that the required skill is missing

### Step 6: Select the Next Dependency-Ready Batch

Always select the next dependency-ready batch from the live execution model for the active mode.

Shared batch rules:
- choose the earliest unfinished phase first
- choose only tasks from that one phase
- preserve explicit dependency order
- stop at explicit phase-verification or phase-boundary checkpoints
- never pull work from a later phase just to make the batch larger
- if the plan, tracker, or current checkpoint implies a specific smaller batch, keep that smaller batch
- if no explicit batch size or tighter boundary is specified, select the next 3-5 independent tasks that can be executed without violating dependencies

Local-plan mode batching:
- select from Z99 tasks not marked `done`
- record the chosen batch in the Z99 `Current batch` section before delegation

Tracker mode batching:
- select from child items not already done in the tracker
- derive remaining work from tracker state plus dependency order
- default to exactly the next single dependency-ready child item
- only include multiple child items in one batch when the chosen executor is explicitly going to keep one isolated completion commit and one structured outcome entry per child item
- if that per-child-item isolation cannot be guaranteed up front, reduce the batch back to one child item
- do not mirror the batch into Z99 or another local tracker file

### Step 7: Delegate Only the Current Batch

The chosen execution mode receives only the current batch scope.

`feature-implementing` owns:
- cross-batch sequencing
- live execution tracker ownership
- proof validation
- human approval between batches

The downstream executor owns:
- implementation of the current batch only
- verification of the current batch only
- persisting any `done` work as committed git history before returning control
- reporting completion, blockers, and proof back to `feature-implementing`

Provide a compact execution brief containing only:
- active phase
- exact batch task list
- dependency and order constraints
- relevant repo constraints
- relevant research and planning excerpts
- batch success criteria
- tracker-specific red flags when tracker mode is used
- when tracker mode is used: the explicit hard rule that each child item must complete in its own isolated, followable commit on the feature branch and must not be combined with another child item in the same commit
- the instruction that control returns to `feature-implementing` after this batch completes or blocks

Require a structured batch outcome for every task:
- task identifier or exact task text
- status: `done` | `blocked` | `incomplete`
- returned commit SHA for any `done` task
- proof of work for any `done` task
- blocker summary for any `blocked` task
- verification run for the batch
- whether the batch completed cleanly or stopped early

Additional branch-proof requirement for any `done` task:
- confirmation that the commit was made on the active feature branch
- the commit must be attributable to exactly one completed task or child item
- the commit must already exist before the task is returned as `done`

#### Subagent-Driven Batch Contract

When using `superpowers:subagent-driven-development`:
- treat the current batch as the full plan scope for that invocation
- let it keep its native per-task orchestration and review loops within the batch
- require each task it returns as `done` to already be committed before control returns to `feature-implementing`
- require it to return control after the batch completes or blocks
- do not let it continue into later batches on its own

Tracker-mode subagent expectation:
- every child item must end up with at least one attributable commit on the feature branch before it is considered done
- one tracker child item should be the default unit of subagent execution
- the subagent should report child identifier, commit SHA, verification run, and final status

Local-plan subagent expectation:
- every completed Z02 task must end up with at least one attributable commit on the feature branch before it is considered done
- the subagent should report task identifier, commit SHA, verification run, and final status

#### Inline Execution Batch Contract

When using `superpowers:executing-plans`:
- treat the current batch as the full plan scope for that invocation
- require it to execute and verify only that batch
- require each task it returns as `done` to already be committed before control returns to `feature-implementing`
- require it to return control after the batch completes or blocks
- do not claim it provides reviewer-subagent loops
- do not claim it owns batching or live-tracker orchestration
- when tracker mode is active, require it to keep one isolated completion commit per child item and forbid collapsing multiple child items into one shared commit

### Step 8: Verify the Batch Outcome and Update the Live Execution Tracker

After the chosen executor returns:
- verify that it returned a structured batch outcome covering every task in the batch
- verify proof of work for every reported `done` task
- verify verification was reported for the batch
- treat any reported `done` task without an already-existing commit as `incomplete`

Local-plan mode:
- for each task reported `done`, validate that the returned commit SHA exists on the current feature branch
- do not mark a task done without a returned commit SHA
- do not mark a task done until commit-on-branch validation succeeds
- do not allow multiple completed tasks to share one completion commit
- update Z99 task statuses
- add or verify proof-of-work entries
- retain the commit SHA in the task proof entry
- update the Z99 `Blockers` section if needed
- clear or replace the Z99 `Current batch` section
- persist the updated Z99 snapshot

Tracker mode:
- for each task reported `done`, validate that the returned commit SHA exists on the current epic branch
- do not mark a child item done without a returned commit SHA
- do not mark a child item done until commit-on-branch validation succeeds
- do not allow multiple completed child items to share one completion commit
- do not defer committing child-item work until after user approval for the next batch
- once validated, mark the child item done in the tracker immediately
- retain or add the commit SHA reference in the child item if the tracker supports it
- update tracker-side blockers or comments only as needed to preserve execution clarity

If the executor did not return a structured batch outcome:
- treat the batch as incomplete
- do not update the live tracker as though the batch finished
- ask for the missing task-by-task outcome before proceeding

If a task is reported complete but lacks required proof:
- treat it as incomplete
- do not advance as if the batch finished cleanly

### Step 9: Ask Approval Before the Next Batch

If remaining non-done work still exists after Step 8:
- report the batch outcome
- only ask for approval after all reported `done` tasks from the batch are already committed and validated
- ask whether to continue with the next batch
- do not delegate another batch until the user approves

If the user pauses:
- local-plan mode: leave the latest Z99 snapshot as the resume state
- tracker mode: leave tracker state and epic-branch history as the resume state

### Step 10: Enforce the Mode-Specific Completion Gate

Local-plan mode is complete only when:
- every task extracted from Z02 is present in Z99
- every Z99 task is marked `done`
- every done task includes proof of work
- every done task has a validated commit SHA on the feature branch
- final verification has been run

Tracker mode is complete only when:
- every child item in scope is marked done in the tracker
- every done child item has a validated commit SHA on the epic branch
- verification has been reported for every completed child item
- no remaining open child item violates the declared dependency order
- final verification for the implemented work has been run

If the active mode fails its completion gate:
- STOP
- keep the workflow in progress
- do not claim implementation is complete

## Red Flags

You are failing if you:
- proceeded with unanswered `Z01_CLARIFY` or `Z02_CLARIFY` questions
- skipped `AGENTS.md`
- skipped `CLAUDE.md` when it exists after `AGENTS.md`
- accepted an invalid tracker entrypoint
- failed to extract or confirm a stable feature name in tracker mode
- inferred tracker structure that was not actually preserved
- skipped the early split between local-plan mode and tracker mode
- asked for or relied on execution modes other than the two allowed options
- delegated the full remaining plan instead of only the current batch
- passed full artifact dumps instead of a compact execution brief

Local-plan mode red flags:
- failed to create or reconcile `Z99_implementation_status.md` before execution-mode selection
- treated Z99 as a passive report instead of the live execution checklist
- overwrote an existing Z99 instead of resuming
- modified `Z02_{feature}_plan.md` to track progress
- marked a local-plan task done without a returned commit SHA
- allowed multiple local-plan tasks to share one completion commit
- claimed implementation complete while any Z99 task is not `done` or lacks proof

Tracker mode red flags:
- created, updated, or depended on `Z99_implementation_status.md`
- closed a child item without a returned commit SHA
- closed a child item before validating the commit on the epic branch
- allowed multiple child items to share one completion commit
- delegated multiple tracker child items as one combined work unit without explicit per-child-item commit isolation
- returned tracker child-item work for human approval before creating the required completion commit
- lost dependency order while selecting the next child item
- treated partial non-committed work as done
- relied on links to local Z0X files for required execution context

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "All sources should normalize into Z99." | No. Only local Z02 execution uses Z99. Tracker mode is tracker-native. |
| "The parent issue title is enough to implement from." | No. Tracker mode requires self-contained child items plus explicit order and verification. |
| "A local Z02 task can stay uncommitted until the end of the feature." | No. Local-plan completion also requires one validated commit per completed task on the feature branch. |
| "A child item can be marked done once code exists locally." | No. Tracker mode completion requires a validated commit on the epic branch. |
| "The subagent can implement first and commit after the user says continue." | No. Any task returned as `done` must already be committed before the approval-for-next-batch step. |
| "A tracker batch can combine several child items as long as the code is small." | No. Tracker mode defaults to one child item per batch unless per-child-item commit isolation is explicitly preserved. |
| "Several local-plan tasks can share one commit if they were done in one batch." | No. Batching does not relax per-task commit isolation. |
| "Two child items can share one commit if the work is related." | No. Each child item needs its own attributable commit history; a shared single commit is not enough. |
| "Close the tracker item now and clean up the git proof later." | No. Validate the commit first, then close the item. |
| "Pass the whole plan for convenience." | No. The wrapper owns batching and approval. |
| "Approval between batches slows things down." | No. Batch approval is a core workflow guarantee. |
| "A done task without proof is good enough." | No. Both modes require proof before completion. |

## Success Criteria

You followed the workflow if:
- verified a supported implementation source exists
- applied the correct source preference when both local and tracker sources existed
- blocked on unresolved clarification files
- read `AGENTS.md`
- read `CLAUDE.md` when present
- read the relevant Z01 and planning-source context
- extracted or confirmed a stable feature name for tracker mode
- rejected tracker mode when the published tracker graph was not self-contained enough to execute safely
- split early into local-plan mode or tracker mode
- asked the user to choose exactly one of the two execution modes
- selected only the next dependency-ready batch from the earliest unfinished phase
- delegated only that batch to the chosen executor
- sent a compact execution brief
- required a structured batch outcome before updating live progress
- preserved dependency order and verification expectations

Local-plan mode success requires:
- created or reconciled `Z99_implementation_status.md`
- used Z99 as the live execution checklist
- updated Z99 with statuses and proof after each batch
- required at least one attributable commit per Z02 task
- validated commit-on-branch before marking a task done
- verified every Z99 task is `done` with proof before claiming completion

Tracker mode success requires:
- did not create or rely on `Z99_implementation_status.md`
- used the tracker itself as the live execution state
- used one branch per parent issue or epic
- required at least one attributable commit per child item
- defaulted tracker execution to one child item per batch unless stricter per-child-item isolation was explicitly preserved
- required those commits to exist before asking the user whether to continue with the next batch
- validated commit-on-branch before marking a child item done
- derived remaining work from still-open child items in dependency order

## When to Use

Use when:
- `Z02_{feature}_plan.md` exists in the ongoing directory, or
- a GitHub parent roadmap issue plus child issues created from `feature-planning` exists, or
- a Jira epic plus child tasks created from `feature-planning` exists
- all clarifications are resolved
- the chosen source preserves enough structure to execute safely
- you want workflow-owned batching, explicit execution-mode selection, and proof-based completion

Do not use when:
- no supported source exists
- tracker artifacts do not preserve planning parity
- clarifications are unresolved
- the work is a simple one-step change

## Integration With Feature Workflow

```text
1. feature-researching  -> Z01_research + Z01_CLARIFY
2. feature-planning     -> Z02_plan and/or tracker artifacts + Z02_CLARIFY
3. feature-implementing -> local Z02 + Z99 OR tracker-native execution from published tracker items
```

After this skill:
- local-plan mode leaves all Z99 tasks done with proof and validated per-task commit SHAs
- tracker mode leaves all child items done with validated commit proof
- final verification has passed
- implementation is ready for optional finishing and documenting steps
