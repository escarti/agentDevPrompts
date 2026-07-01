# Tracker-Native `feature-implementing` Design

## Summary

`feature-implementing` currently treats every execution source as something that must be normalized into a local `Z99_implementation_status.md` tracker. That is appropriate when the source is a local `Z02_{feature}_plan.md`, because the file itself has no live execution state. It is the wrong model when the source is a published GitHub or Jira tracker graph, because the tracker already is the live execution state.

This design splits `feature-implementing` into two execution modes after source detection:

- **Local-plan mode** keeps the current behavior: `Z02` is the source of truth and `Z99` is the live execution tracker.
- **Tracker mode** becomes tracker-native: the parent issue/epic and child issues/tasks are the live execution tracker, one branch is used per parent item, and one commit represents completion of one child item.

In tracker mode, `feature-implementing` must stop mirroring progress into `Z99`. Instead, completion is recorded directly in the tracker as soon as a child item has a validated commit on the epic branch.

## Goals

- Preserve the current `Z02` + `Z99` workflow for local-plan execution.
- Make tracker mode use the tracker itself as the live execution state.
- Treat one commit on the epic branch as the completion signal for one child issue/task.
- Keep tracker-mode subagent execution compatible with the existing subagent-driven execution style.
- Preserve dependency order and phase order from the parent tracker item and child references.

## Non-Goals

- This change does not redesign how `feature-planning` publishes tracker items beyond what is already specified.
- This change does not require a local recovery file for tracker mode unless a later failure mode proves it is necessary.
- This change does not redefine how final documenting/finishing workflows operate after implementation completes.

## Current Problem

The current design assumes that even tracker-based execution should be normalized into `Z99`. That creates unnecessary duplication:

- the tracker already contains task state
- the tracker already contains task ordering and dependencies
- the branch history already contains proof of work

Duplicating that state into `Z99` introduces drift:

- a tracker item can be open while `Z99` says done
- a tracker item can be closed while `Z99` still says pending
- commit history can prove work exists even when the local tracker file was not updated

This is especially unnecessary when subagent mode is already expected to do the work item-by-item and report verification with each completion.

## Proposed Model

### 1. Early Mode Split

After source detection, `feature-implementing` should branch immediately into:

- **Local-plan mode**
  - source: `Z02_{feature}_plan.md`
  - execution tracker: `Z99_implementation_status.md`
  - completion proof: `Z99` proof-of-work entries

- **Tracker mode**
  - source: GitHub parent roadmap issue or Jira epic plus child items
  - execution tracker: the tracker itself
  - completion proof: one validated commit SHA per child item on the epic branch

The skill text should stop describing `Z99` as universal. It should describe `Z99` as local-plan-mode state only.

### 2. Tracker Mode Source Contract

Tracker mode is valid only if the parent item and child items provide enough structure to execute directly:

- parent issue/epic defines ordered phases or ordered child execution sequence
- child items are self-contained
- dependency or predecessor order is explicit
- verification expectations are present in the child items

If that structure is missing, `feature-implementing` should reject tracker mode and instruct the user to use the local `Z02` plan or regenerate tracker artifacts.

### 3. Epic Branch Model

Tracker mode uses one branch per parent tracker item.

Rules:

- the parent issue/epic owns one branch
- all child-item commits land on that branch
- each child issue/task is represented by one completion commit
- the commit message should be attributable to the child item, so the link between tracker item and proof of work is unambiguous

This branch becomes the execution lane for the entire epic. It also gives the controller a stable place to look for commit proof when deciding whether a child item is done.

### 4. Completion Semantics

In tracker mode, a child item is done when:

- the executor returns a commit SHA on the epic branch for that child item
- the controller validates that the commit exists on the current epic branch
- the executor reported verification for the work

Once those conditions are satisfied:

- the child item is marked done in the tracker immediately
- the controller does not wait for a later batch-level or phase-level local state update
- no `Z99` row is created or updated for that child

The tracker is the status ledger. Git history is the proof ledger.

### 5. Batch Selection in Tracker Mode

Tracker mode should still retain batching, but the source of remaining work changes.

The controller selects the next batch from open child items by:

- respecting parent-declared order
- respecting explicit predecessor dependencies
- skipping any child item already marked done in the tracker
- stopping at phase or dependency boundaries

This preserves the current execution discipline without duplicating state locally.

### 6. Subagent Execution Model

Subagent-driven execution remains the recommended tracker-mode executor.

In tracker mode, the subagent contract should be:

- work one child item at a time
- implement, verify, and commit on the epic branch
- return:
  - child item identifier
  - commit SHA
  - verification run
  - `done` / `blocked` / `incomplete`

The controller then:

- validates the commit SHA
- updates the tracker item to done if valid
- selects the next dependency-ready child item

This fits naturally with the existing “fresh focused execution per work item” model.

### 7. Local-Plan Mode Remains Unchanged

Local `Z02` execution still needs `Z99`, because there is no external live task ledger.

Local-plan mode should keep:

- `Z99_implementation_status.md`
- proof-of-work fields
- batch selection from `Z99`
- final completion gate based on `Z99`

This design is not trying to replace `Z99` globally. It is only removing it from tracker mode where it is redundant.

## Skill Contract Changes

`skills/feature-implementing/SKILL.md` should be updated so that:

- source detection chooses between local-plan mode and tracker mode
- `Z99` creation is described as local-plan-mode behavior only
- tracker mode describes tracker-native state management
- tracker mode completion is defined as “validated commit on epic branch”
- tracker mode batch selection is defined in terms of open tracker items
- tracker mode proof of work is commit SHA attached to the child item

The red flags and success criteria should also split by mode:

- local-plan mode failures still include incorrect `Z99` handling
- tracker mode failures should include:
  - creating or relying on `Z99`
  - failing to validate commit-on-branch before closing a child item
  - closing a child item without a returned commit SHA
  - losing dependency order while selecting the next child item

## Acceptance Criteria

The design is correct when all of the following are true:

- Executing from local `Z02` still behaves exactly like the current `Z99` workflow.
- Executing from a tracker source does not create or depend on `Z99`.
- Tracker mode uses the parent issue/epic plus child issues/tasks as the only live progress tracker.
- Tracker mode uses one branch per parent issue/epic.
- One child issue/task corresponds to one completion commit on the epic branch.
- A child issue/task is marked done as soon as that commit is validated and the subagent reported successful verification.
- Remaining work is derived from still-open child items in declared dependency order.

## Risks

- If tracker APIs do not support the needed done-state updates reliably, the controller may need a fallback strategy.
- If commit-to-child-item attribution is ambiguous, the workflow will need stricter commit message or metadata rules.
- If some users expect partial progress without a commit, tracker mode will feel stricter than local-plan mode by design.

## Recommendation

Adopt this split model.

It keeps the original `Z99` design where it is needed and removes it where it is redundant. It also aligns the workflow with your intended operating model:

- tracker mode uses the tracker as the tracker
- branch history is the durable proof of execution
- subagents map naturally onto child items
- one epic branch can accumulate one commit per child item in dependency order
