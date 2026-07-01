---
name: feature-implementing
description: Use to execute normalized implementation sources in controlled batches with explicit execution-mode selection and Z99 progress tracking
---

# Feature Workflow: Implement Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Verify a supported implementation source exists

**This skill is the workflow-owned implementation controller. It handles source discovery, preflight checks, Z99 tracking, 3-5 task batches, execution-mode selection, and approval between batches. Downstream Superpowers skills execute only the current batch.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature implementation workflow",
  "plan": [
    {"step": "Step 1: Find the implementation source, entrypoint, and feature name", "status": "in_progress"},
    {"step": "Step 2: Check for unresolved clarifications", "status": "pending"},
    {"step": "Step 3: Load context (AGENTS.md, CLAUDE.md, Z01, source artifacts)", "status": "pending"},
    {"step": "Step 4: Normalize source content and create or reconcile Z99_implementation_status.md", "status": "pending"},
    {"step": "Step 5: Ask the user to choose execution mode", "status": "pending"},
    {"step": "Step 6: Select the next 3-5 task batch from remaining Z99 work", "status": "pending"},
    {"step": "Step 7: Delegate only the current batch to the chosen execution controller", "status": "pending"},
    {"step": "Step 8: Verify the batch outcome and update Z99 proof-of-work", "status": "pending"},
    {"step": "Step 9: Ask approval before the next batch if work remains", "status": "pending"},
    {"step": "Step 10: Enforce the final Z99 completion gate", "status": "pending"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to the next step.

## Workflow Steps

### Step 1: Find Planning Source and Feature Name

Supported planning sources:
- `Z02_{feature}_plan.md` in an ongoing directory
- a GitHub epic-like parent issue plus child issues created from `feature-planning`
- a Jira epic plus child tasks created from `feature-planning`

Local file discovery:
- scan for Z02 plan files in common locations (`docs/ai/ongoing`, `.ai/ongoing`, `docs/ongoing`, etc.)
- if multiple Z02 plans exist and the user specified a feature name, use that plan
- if multiple Z02 plans exist and the user did not specify a feature name, ask which plan to execute

Tracker entrypoint discovery:
- GitHub entrypoint: accept the parent roadmap issue URL or issue number in the current repository
- Jira entrypoint: accept the epic key or URL

Source selection rules:
- if both a local Z02 file and a tracker entrypoint are provided, prefer the source explicitly named by the user
- otherwise prefer the local Z02 file
- if the user does not name a source and multiple tracker entrypoints are present without a local Z02, ask which tracker source to execute
- if a tracker entrypoint does not resolve to its parent item plus child work items, STOP and ask for a valid entrypoint

If no supported source is provided:
- report: "No implementation source found. Run feature-workflow:feature-planning first."
- do NOT proceed without a source

Feature name extraction:
- from `Z02_{feature}_plan.md` when using local files
- from an explicit feature slug produced by `feature-planning` when tracker mode preserves one
- otherwise from the parent issue or epic title when using tracker mode, normalized to the workflow feature slug format
- if tracker mode does not preserve a stable feature name and the title cannot be safely normalized, STOP and ask the user to confirm the feature name

**Save ONGOING_DIR location** for Z01 and Z99 artifacts. When using a local plan, that ongoing directory remains authoritative. When using tracker mode without a local plan, continue using the discovered ongoing directory for Z99 persistence if one already exists; otherwise default to `docs/ai/ongoing/`.

---

### Step 2: Check for Unresolved Clarifications (BLOCKING)

Check whether either clarification file exists in `ONGOING_DIR`:
- `Z01_CLARIFY_{feature}_research.md`
- `Z02_CLARIFY_{feature}_plan.md`

**If Z01_CLARIFY exists:**
- Read the file.
- Check whether any `User response:` field is blank.
- If ANY are blank, STOP and report: "Cannot implement with unanswered research questions. Please answer all questions in Z01_CLARIFY_{feature}_research.md first."

**If Z02_CLARIFY exists:**
- Read the file.
- Check whether any `User response:` field is blank.
- If ANY are blank, STOP and report: "Cannot implement with unanswered plan questions. Please answer all questions in Z02_CLARIFY_{feature}_plan.md first."

Proceed only when all clarifications are resolved.

---

### Step 3: Load Context Files

Read all available context in this order:

1. **Project patterns:** `AGENTS.md`, then `CLAUDE.md` if it exists
2. **Research context:** `Z01_{feature}_research.md`, then `Z01_CLARIFY_{feature}_research.md` if answers exist
3. **Planning context:**
   - local mode: `Z02_{feature}_plan.md`, then `Z02_CLARIFY_{feature}_plan.md` if answers exist
   - tracker mode: parent issue or epic body, all child issues or tasks, and only the tracker metadata needed to rebuild the same phase/task model used by Z99

Tracker mode requirements:
- load phase identity, task ordering, dependency boundaries, and verification text preserved in each child item
- prefer explicit planning metadata produced by `feature-planning` over inferred structure
- reject tracker entrypoints that do not contain enough information to recover:
  - ordered phases
  - ordered tasks
  - dependency relationships
  - verification expectations
- reject tracker entrypoints whose parent/child content cannot reach near-parity with the local `Z02` plan structure
- report: "Tracker source does not preserve enough `feature-planning` structure to build Z99 safely. Use the local Z02 plan or regenerate the tracker artifacts."

Extract and preserve:
- required project patterns and constraints
- research decisions that MUST survive execution
- the normalized task list, dependencies, phase boundaries, and verification expectations from the chosen planning source

Prepare to hand off a **compact execution brief**, not full artifact dumps.

---

### Step 4: Normalize Source Content and Create or Reconcile Implementation Tracker (Z99)

Prepare `{ONGOING_DIR}/Z99_implementation_status.md` before asking for execution mode.

**Purpose:** Maintain a workflow-owned working plan without modifying the original planning source.

Treat `Z99` as:
- the live task state that `feature-implementing` iterates on during execution
- the checklist used to choose the next batch, evaluate results, and decide whether more work remains
- persisted to `Z99_implementation_status.md` so a fresh agent can resume if execution is interrupted or something breaks

Treat the file as a persistence and recovery mechanism, not the reasoner that owns the workflow.

Rules:
- Do NOT edit the original planning source
- before creating or reconciling Z99, normalize the chosen source into the same internal structure:
  - ordered phases
  - ordered tasks within each phase
  - stable task identifiers or exact task text
  - dependencies and phase-boundary constraints
  - verification checkpoints
- local mode: extract all phases and tasks from Z02 into the normalized source model
- tracker mode: extract all phases and tasks from the parent/child tracker graph into the normalized source model
- preserve each task's phase identity and dependency edges from the normalized source
- Add per-task status fields (`pending`, `in_progress`, `done`, `blocked`)
- Add a per-task "Proof of work" field (file paths, tests, or commits proving completion)
- Add a short "Current batch" section and "Blockers" section
- Require the "Current batch" section to record the active phase
- Treat Z99 as the workflow-owned execution checklist across batches
- treat tracker-derived tasks exactly like Z02-derived tasks after normalization
- do not special-case batching rules by source type
- keep batching, Z99 ownership, and execution-brief semantics source-agnostic after normalization

Tracker mode is valid only when the published tracker graph preserves enough detail that implementation from tracker items should reach nearly the same code outcome as implementation from the source Z02.

If that parity cannot be established:
- stop and ask the user to implement from the local Z02 file instead
- do NOT build a partial or guessed Z99

If Z99 already exists:
- Reconcile it with the latest normalized task set
- Append missing tasks without deleting existing status or proof
- Rebuild the live execution state from the file, then resume from the earliest unfinished task in the earliest unfinished phase

---

### Step 5: Ask the User to Choose Execution Mode

**Always ask.** Present exactly these two execution modes:

1. **Subagent-Driven (recommended)** - Use `superpowers:subagent-driven-development` for the current batch. Inside that batch, it keeps its native per-task implementer/spec-review/code-quality-review flow.
2. **Inline Execution** - Use `superpowers:executing-plans` for the current batch. Inside that batch, it executes and verifies work without implying reviewer-subagent loops.

Do not invent additional execution modes.

**If the user chooses Subagent-Driven:**
- Load and follow `superpowers:subagent-driven-development`
- If unavailable, stop and report that the required Superpowers skill is missing

**If the user chooses Inline Execution:**
- Load and follow `superpowers:executing-plans`
- If unavailable, stop and report that the required Superpowers skill is missing

---

### Step 6: Select the Next Batch From Z99

Select the next **3-5 remaining tasks** from Z99.

This step operates on the live Z99 task state, then persists the updated snapshot back to `Z99_implementation_status.md`.

Batch rules:
- Choose the earliest unfinished phase first
- Choose only from tasks in that one phase that are not marked `done`
- Prefer tasks that are sequentially adjacent within the active phase
- Preserve explicit task dependencies from the normalized source
- Stop at any explicit `Phase Verification` or `Phase Boundary Rule` checkpoint for that phase
- Never pull tasks from the next phase just to reach 3-5 tasks
- If a dependency boundary or phase boundary forces a smaller batch, keep the batch small rather than crossing phases

Record the chosen batch in the Z99 "Current batch" section before delegation, including the active phase.

---

### Step 7: Delegate Only the Current Batch

The chosen execution mode receives **only the current batch scope**, not the full remaining plan.

`feature-implementing` owns:
- cross-batch sequencing
- `Z99` state
- human approval between batches
- persisting the latest `Z99` snapshot after each meaningful state change

The downstream executor owns:
- execution of the current batch only
- verification of the current batch only
- reporting completion, blockers, and proof back to `feature-implementing`

Provide a **compact execution brief** containing only:
- the active phase
- the exact batch task list
- batch-specific dependency/order constraints
- only the relevant repo constraints from `AGENTS.md` / `CLAUDE.md`
- only the relevant excerpts from `Z01`, the normalized source model, and current `Z99`
- clear success criteria for the batch
- tracker-specific red flags when the chosen source is GitHub or Jira
- the instruction that control returns to `feature-implementing` after this batch completes or blocks

Require the executor to return a **structured batch outcome** for every task in the batch:
- task identifier or exact task text
- status: `done` | `blocked` | `incomplete`
- proof of work for any `done` task
- blocker summary for any `blocked` task
- verification run for the batch
- whether the batch completed cleanly or stopped early

#### Subagent-Driven Batch Contract

When using `superpowers:subagent-driven-development`:
- Treat the current batch as the full plan scope for this invocation
- Let that skill keep its native per-task orchestration and review loops within the batch
- Let it execute continuously within the batch
- Require it to return control after the batch completes or blocks
- Do NOT require it to continue into later batches
- Do NOT claim that this review behavior applies to other execution modes

#### Inline Execution Batch Contract

When using `superpowers:executing-plans`:
- Treat the current batch as the full plan scope for this invocation
- Require it to execute and verify only that batch
- Require it to return control after the batch completes or blocks
- Do NOT require it to continue into later batches
- Do NOT claim that it provides reviewer-subagent loops
- Do NOT claim that it owns batching or Z99 orchestration

---

### Step 8: Verify the Batch Outcome and Update Z99

After the chosen executor returns:
- First verify that it returned a structured batch outcome covering every task in the batch
- Check which batch tasks were completed, blocked, or left incomplete
- Update Z99 task statuses accordingly
- Add or verify proof of work for every task marked `done`
- Update the Z99 "Blockers" section if needed
- Reflect whether the active phase is now complete before selecting any later phase
- Clear or replace the Z99 "Current batch" section before selecting the next batch
- Persist the updated Z99 snapshot back to `Z99_implementation_status.md`

If the executor did not return a structured batch outcome:
- Treat the batch as incomplete
- Do NOT update Z99 as though the batch finished
- Ask for the missing task-by-task outcome before proceeding

If a task was reported complete but lacks proof of work:
- Treat it as incomplete
- Do NOT advance as if the batch finished cleanly

---

### Step 9: Ask Approval Before the Next Batch

If remaining non-`done` tasks still exist after Step 8:
- Report the batch outcome
- Ask whether to continue with the next batch
- Do NOT delegate another batch until the user approves

If the user declines or pauses:
- Leave the persisted Z99 snapshot as the continuation state for later resume
- Report what remains

---

### Step 10: Enforce the Final Z99 Completion Gate

Before considering implementation complete:
- Every task extracted from the normalized source must be present in Z99
- Every Z99 task must be marked `done`
- Every `done` task must include proof of work
- Final verification for the implemented work must be run before claiming completion

If any task is not `done`, is `blocked`, or lacks proof:
- STOP
- Keep the workflow in progress
- Do NOT claim implementation is complete

## Red Flags - You're Failing If:

- **Proceeded with unanswered questions in Z01_CLARIFY or Z02_CLARIFY**
- **Did NOT check whether a supported implementation source exists**
- **Ignored the source selection rule when both local and tracker sources existed**
- **Accepted a tracker entrypoint other than a GitHub parent roadmap issue URL/issue number or Jira epic key/URL**
- **Skipped AGENTS.md**
- **Skipped CLAUDE.md when it exists after reading AGENTS.md**
- **Failed to extract or confirm a stable feature name in tracker mode**
- **Failed to normalize the chosen source before creating/updating Z99**
- **Failed to create/update Z99 before execution mode selection**
- **Treated `Z99_implementation_status.md` as a passive report instead of the persisted snapshot of the live execution checklist**
- **Assumed tracker items could be executed without enough dependency or verification detail**
- **Assumed tracker inference was acceptable when source parity with the planning output was insufficient**
- **Did NOT ask the user to choose between exactly two execution modes**
- **Delegated the full remaining plan instead of only the current batch**
- **Mixed tracker-derived tasks and Z02-derived tasks without normalizing them first**
- **Passed full artifact dumps instead of a compact execution brief**
- **Advanced Z99 without a structured batch outcome covering every batch task**
- **Claimed both execution modes provide the same review guarantees**
- **Claimed `executing-plans` owns batching, review loops, or Z99 orchestration**
- **Overwrote an existing Z99 and reset prior progress instead of resuming**
- **Modified `Z02_{feature}_plan.md` to track progress**
- **Mutated the original tracker items to track execution progress instead of keeping progress in Z99**
- **Selected tasks from multiple phases in one batch**
- **Selected tasks out of dependency or phase order to satisfy batch size**
- **Started a new batch without explicit user approval**
- **Claimed implementation complete while any Z99 task is not `done` or lacks proof**
- **Used hardcoded paths** instead of detecting artifact locations

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"The executor can figure out the rest of the plan"** | **NO.** Delegate only the current batch. The wrapper owns sequencing. |
| **"Send all Z01/Z02/Z99 context just in case"** | **NO.** Send a compact execution brief with only batch-relevant context. |
| **"The parent issue or epic title is enough to reconstruct the plan"** | **NO.** Tracker mode must preserve the same phase/task model produced by `feature-planning`. |
| **"A summary like 'batch done' is enough to update Z99"** | **NO.** Z99 needs task-by-task outcome and proof. |
| **"Z99 is just a report file"** | **NO.** Z99 is the live execution checklist; the file is its persisted backup for resume/recovery. |
| **"Subagent-driven and executing-plans are basically the same"** | **NO.** Their review guarantees differ and must stay mode-specific. |
| **"Skip execution mode choice and default silently"** | **NO.** This workflow always asks the user to choose. |
| **"Pass the whole plan for convenience"** | **NO.** That breaks wrapper-owned batching and approval gates. |
| **"Z99 already exists, rewrite it from scratch"** | **NO.** Reconcile and resume from existing state. |
| **"Grab a task from the next phase to fill the batch"** | **NO.** Phase boundaries are hard execution boundaries. |
| **"Approval between batches slows things down"** | **NO.** Batch approval is a core wrapper guarantee in this workflow. |
| **"A done task without proof is good enough"** | **NO.** Z99 completion requires proof of work. |

## Success Criteria

You followed the workflow if:
- ✓ Verified a supported implementation source exists
- ✓ Applied the correct source preference when both local and tracker sources existed
- ✓ Resolved the tracker entrypoint only from a valid GitHub parent issue URL/issue number or Jira epic key/URL when tracker mode was used
- ✓ Blocked on unresolved Z01/Z02 clarifications
- ✓ Read AGENTS.md
- ✓ Read CLAUDE.md if it exists after AGENTS.md
- ✓ Read relevant Z01 and planning-source context
- ✓ Extracted or confirmed a stable feature name for tracker mode
- ✓ Rejected tracker mode when it could not preserve parity with the `feature-planning` task model
- ✓ Created or reconciled `Z99_implementation_status.md` before execution mode selection
- ✓ Used Z99 as the live execution checklist and the file as persisted resume state
- ✓ Asked the user to choose exactly one of the two execution modes
- ✓ Normalized the chosen source before creating Z99
- ✓ Selected only the next 3-5 task batch from the earliest unfinished phase in Z99
- ✓ Delegated only that batch to the chosen executor
- ✓ Sent a compact execution brief rather than full artifact dumps
- ✓ Required a structured batch outcome before updating Z99
- ✓ Kept review guarantees mode-specific
- ✓ Preserved dependency order and verification expectations regardless of source type
- ✓ Updated Z99 with statuses and proof of work after the batch
- ✓ Kept Z99 phase-aware and advanced to the next phase only after the current one was complete
- ✓ Asked approval before the next batch when work remained
- ✓ Verified every Z99 task is `done` with proof before claiming completion

## When to Use

Use when:
- `Z02_{feature}_plan.md` exists in the ongoing directory, or
- a GitHub parent roadmap issue plus child issues created from `feature-planning` exists, or
- a Jira epic plus child tasks created from `feature-planning` exists
- All clarifications are resolved
- The chosen source preserves enough planning structure to normalize into the same phase/task model used by Z99
- You want workflow-owned batching, phase-locked Z99 tracking, and explicit execution-mode selection

**Don't use when:**
- No supported source exists → Use feature-planning first
- Tracker artifacts do not preserve planning parity → Use the local Z02 plan or regenerate the tracker artifacts from feature-planning
- Clarifications are unresolved → Answer Z01/Z02 clarification questions first
- The work is a simple one-step change → Implement directly

## Integration with Feature Workflow

```
1. feature-research    → Z01_research + Z01_CLARIFY
2. feature-plan        → Z02_plan and/or tracker artifacts + Z02_CLARIFY + explicit phase metadata
3. feature-implement   → source normalization + Z99 + phase-locked batch controller + explicit executor choice
```

**After this skill:**
- All Z99 tasks are `done` with proof of work
- Final verification has passed
- Implementation is ready for optional follow-up workflow steps
