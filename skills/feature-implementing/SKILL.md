---
name: feature-implementing
description: Use to execute implementation plan (Z02 files) in controlled batches with explicit execution-mode selection and Z99 progress tracking
---

# Feature Workflow: Implement Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Verify Z02 plan exists

**This skill is the workflow-owned implementation controller. It handles preflight checks, Z99 tracking, 3-5 task batches, execution-mode selection, and approval between batches. Downstream Superpowers skills execute only the current batch.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature implementation workflow",
  "plan": [
    {"step": "Step 1: Find Z02 plan file and feature name", "status": "in_progress"},
    {"step": "Step 2: Check for unresolved clarifications", "status": "pending"},
    {"step": "Step 3: Load context (AGENTS.md, CLAUDE.md, Z01, Z02)", "status": "pending"},
    {"step": "Step 4: Create or reconcile Z99_implementation_status.md from Z02 plan phases/tasks", "status": "pending"},
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

### Step 1: Find Z02 Plan File

Scan for Z02 plan files in common locations (`docs/ai/ongoing`, `.ai/ongoing`, `docs/ongoing`, etc.).

**If multiple Z02 plans exist:**
- If the user specified a feature name, use that plan.
- Otherwise, ask which plan to execute.

**If NO Z02 plan exists:**
- Report: "No plan found. Run feature-workflow:feature-planning first."
- Do NOT proceed without a plan.

**Extract feature name from filename:**
- `Z02_{feature}_plan.md` → feature name
- Example: `Z02_oauth_authentication_plan.md` → `oauth_authentication`

**Save ONGOING_DIR location** for Z01, Z02, and Z99 artifacts.

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
3. **Plan context:** `Z02_{feature}_plan.md`, then `Z02_CLARIFY_{feature}_plan.md` if answers exist

Extract and preserve:
- Required project patterns and constraints
- Research decisions that MUST survive execution
- Full task list, dependencies, and verification expectations from Z02

---

### Step 4: Create or Reconcile Implementation Tracker (Z99)

Prepare `{ONGOING_DIR}/Z99_implementation_status.md` before asking for execution mode.

**Purpose:** Track implementation state without modifying the original plan.

Rules:
- Do NOT edit `Z02_{feature}_plan.md`
- Extract all phases and tasks from Z02 into Z99
- Preserve each task's phase identity from the Z02 `**Phase:** Phase N` field
- Add per-task status fields (`pending`, `in_progress`, `done`, `blocked`)
- Add a per-task "Proof of work" field (file paths, tests, or commits proving completion)
- Add a short "Current batch" section and "Blockers" section
- Require the "Current batch" section to record the active phase
- Treat Z99 as the workflow-owned source of execution state across batches

If Z99 already exists:
- Reconcile it with the latest Z02 tasks
- Append missing tasks without deleting existing status or proof
- Resume from the earliest unfinished task in the earliest unfinished phase

---

### Step 5: Ask the User to Choose Execution Mode

**Always ask.** Present exactly these two execution modes:

1. **Subagent-Driven (recommended)** - Use `superpowers:subagent-driven-development` for the current batch. This keeps its native per-task implementer/spec-review/code-quality-review flow inside the batch.
2. **Inline Execution** - Use `superpowers:executing-plans` for the current batch. This keeps its native execution-and-verification behavior without implying reviewer-subagent loops.

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

Batch rules:
- Choose the earliest unfinished phase first
- Choose only from tasks in that one phase that are not marked `done`
- Prefer tasks that are sequentially adjacent within the active phase
- Preserve explicit task dependencies from Z02
- Stop at any explicit `Phase Verification` or `Phase Boundary Rule` checkpoint for that phase
- Never pull tasks from the next phase just to reach 3-5 tasks
- If a dependency boundary or phase boundary forces a smaller batch, keep the batch small rather than crossing phases

Record the chosen batch in the Z99 "Current batch" section before delegation, including the active phase.

---

### Step 7: Delegate Only the Current Batch

The chosen execution mode receives **only the current batch scope**, not the full remaining plan.

Provide:
- Project patterns from `AGENTS.md` and `CLAUDE.md`
- Relevant research context from Z01
- Relevant plan context from Z02
- Current Z99 state
- Exact batch task list
- The active phase for the batch
- The instruction that `feature-implementing` owns cross-batch sequencing and approval

#### Subagent-Driven Batch Contract

When using `superpowers:subagent-driven-development`:
- Pass only the current batch tasks
- Let that skill keep its native per-task orchestration and review loops
- Do NOT require it to continue beyond the current batch
- Do NOT claim that this review behavior applies to other execution modes

#### Inline Execution Batch Contract

When using `superpowers:executing-plans`:
- Pass only the current batch tasks
- Require it to execute and verify only that batch
- Do NOT claim that it provides reviewer-subagent loops
- Do NOT claim that it owns batching or Z99 orchestration

---

### Step 8: Verify the Batch Outcome and Update Z99

After the chosen executor returns:
- Check which batch tasks were completed, blocked, or left incomplete
- Update Z99 task statuses accordingly
- Add or verify proof of work for every task marked `done`
- Update the Z99 "Blockers" section if needed
- Reflect whether the active phase is now complete before selecting any later phase
- Clear or replace the Z99 "Current batch" section before selecting the next batch

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
- Leave Z99 as the continuation state
- Report what remains

---

### Step 10: Enforce the Final Z99 Completion Gate

Before considering implementation complete:
- Every task extracted from Z02 must be present in Z99
- Every Z99 task must be marked `done`
- Every `done` task must include proof of work
- Final verification for the implemented work must be run before claiming completion

If any task is not `done`, is `blocked`, or lacks proof:
- STOP
- Keep the workflow in progress
- Do NOT claim implementation is complete

## Red Flags - You're Failing If:

- **Proceeded with unanswered questions in Z01_CLARIFY or Z02_CLARIFY**
- **Did NOT check whether Z02 plan exists**
- **Skipped AGENTS.md**
- **Skipped CLAUDE.md when it exists after reading AGENTS.md**
- **Failed to create/update Z99 before execution mode selection**
- **Did NOT ask the user to choose between exactly two execution modes**
- **Delegated the full remaining plan instead of only the current batch**
- **Claimed both execution modes provide the same review guarantees**
- **Claimed `executing-plans` owns batching, review loops, or Z99 orchestration**
- **Overwrote an existing Z99 and reset prior progress instead of resuming**
- **Modified `Z02_{feature}_plan.md` to track progress**
- **Selected tasks from multiple phases in one batch**
- **Selected tasks out of dependency or phase order to satisfy batch size**
- **Started a new batch without explicit user approval**
- **Claimed implementation complete while any Z99 task is not `done` or lacks proof**
- **Used hardcoded paths** instead of detecting artifact locations

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"The executor can figure out the rest of the plan"** | **NO.** Delegate only the current batch. The wrapper owns sequencing. |
| **"Subagent-driven and executing-plans are basically the same"** | **NO.** Their review guarantees differ and must stay mode-specific. |
| **"Skip execution mode choice and default silently"** | **NO.** This workflow always asks the user to choose. |
| **"Pass the whole plan for convenience"** | **NO.** That breaks wrapper-owned batching and approval gates. |
| **"Z99 already exists, rewrite it from scratch"** | **NO.** Reconcile and resume from existing state. |
| **"Grab a task from the next phase to fill the batch"** | **NO.** Phase boundaries are hard execution boundaries. |
| **"Approval between batches slows things down"** | **NO.** Batch approval is a core wrapper guarantee in this workflow. |
| **"A done task without proof is good enough"** | **NO.** Z99 completion requires proof of work. |

## Success Criteria

You followed the workflow if:
- ✓ Verified `Z02_{feature}_plan.md` exists
- ✓ Blocked on unresolved Z01/Z02 clarifications
- ✓ Read AGENTS.md
- ✓ Read CLAUDE.md if it exists after AGENTS.md
- ✓ Read relevant Z01 and Z02 context
- ✓ Created or reconciled `Z99_implementation_status.md` before execution mode selection
- ✓ Asked the user to choose exactly one of the two execution modes
- ✓ Selected only the next 3-5 task batch from the earliest unfinished phase in Z99
- ✓ Delegated only that batch to the chosen executor
- ✓ Kept review guarantees mode-specific
- ✓ Updated Z99 with statuses and proof of work after the batch
- ✓ Kept Z99 phase-aware and advanced to the next phase only after the current one was complete
- ✓ Asked approval before the next batch when work remained
- ✓ Verified every Z99 task is `done` with proof before claiming completion

## When to Use

Use when:
- `Z02_{feature}_plan.md` exists in the ongoing directory
- All clarifications are resolved
- You want workflow-owned batching, phase-locked Z99 tracking, and explicit execution-mode selection

**Don't use when:**
- No plan exists → Use feature-planning first
- Clarifications are unresolved → Answer Z01/Z02 clarification questions first
- The work is a simple one-step change → Implement directly

## Integration with Feature Workflow

```
1. feature-research    → Z01_research + Z01_CLARIFY
2. feature-plan        → Z02_plan + Z02_CLARIFY + explicit phase metadata
3. feature-implement   → Z99 + phase-locked batch controller + explicit executor choice
```

**After this skill:**
- All Z99 tasks are `done` with proof of work
- Final verification has passed
- Implementation is ready for optional follow-up workflow steps
