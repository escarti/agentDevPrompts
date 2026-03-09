---
name: feature-implementing
description: Use to execute implementation plan (Z02 files) in batches - follow structured workflow
---

# Feature Workflow: Implement Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Verify Z02 plan exists

**This skill loads ALL context (AGENTS.md, CLAUDE.md, Z01, Z02), creates a Z99 implementation tracker, and executes plan in batches with code review checkpoints.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Find Z02 plan file and feature name", status: "in_progress", activeForm: "Finding plan"},
    {content: "Step 2: Check for unresolved clarifications", status: "pending", activeForm: "Checking Z02_CLARIFY"},
    {content: "Step 3: Load context (AGENTS.md, CLAUDE.md, Z01, Z02)", status: "pending", activeForm: "Reading context"},
    {content: "Step 4: Create or reconcile Z99_implementation_status.md from Z02 plan phases/tasks", status: "pending", activeForm: "Building implementation tracker"},
    {content: "Step 5: Use superpowers:executing-plans to execute plan tasks", status: "pending", activeForm: "Starting execution"},
    {content: "Step 6: Verify tests pass", status: "pending", activeForm: "Running tests"},
    {content: "Step 7: Enforce Z99 completion gate (all tasks done + proof of work)", status: "pending", activeForm: "Validating completion evidence"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

### Step 1: Find Z02 Plan File

Scan for Z02 plan files in common locations (docs/ai/ongoing, .ai/ongoing, docs/ongoing, etc.)

**If multiple Z02 plans exist:**
- If user specified feature name → use that plan
- Otherwise → ask which plan to execute

**If NO Z02 plan exists:**
- Ask: "No plan found. Should I run feature-workflow:feature-planning first?"
- Do NOT proceed without a plan

**Extract feature name from filename:**
- `Z02_{feature}_plan.md` → feature name
- Example: `Z02_oauth_authentication_plan.md` → "oauth_authentication"

**Save ONGOING_DIR location** - where Z01/Z02 files are.

---

### Step 2: Check for Unresolved Clarifications (BLOCKING)

**CRITICAL:** Check for ANY unanswered clarification questions before proceeding.

Check if clarification files exist in ONGOING_DIR:
- `Z01_CLARIFY_{feature}_research.md`
- `Z02_CLARIFY_{feature}_plan.md`

**If Z01_CLARIFY exists:**
- Read the file
- Check if "User response:" fields are empty
- **If ANY empty → STOP, report:** "Cannot implement with unanswered research questions. Please answer all questions in Z01_CLARIFY_{feature}_research.md first."

**If Z02_CLARIFY exists:**
- Read the file
- Check if "User response:" fields are empty
- **If ANY empty → STOP, report:** "Cannot implement with unanswered plan questions. Please answer all questions in Z02_CLARIFY_{feature}_plan.md first."

**If all answered or no CLARIFY files exist:** Proceed to Step 3.

---

### Step 3: Load Context Files

Read ALL available context in this order:

1. **Project Patterns**: `AGENTS.md`, then `CLAUDE.md` if it exists
2. **Research Context** (if exists): `Z01_{feature}_research.md`, `Z01_CLARIFY_{feature}_research.md` (with answers)
3. **Plan Context** (required): `Z02_{feature}_plan.md`, `Z02_CLARIFY_{feature}_plan.md` (with answers if exists)

**Critical:** You'll pass FULL CONTENT of these files to superpowers:executing-plans.

---

### Step 4: Create or Reconcile Implementation Tracker (Z99)

Prepare `{ONGOING_DIR}/Z99_implementation_status.md` before execution.

**Purpose:** Track implementation progress without modifying the original plan.

Rules:
- Do NOT edit `Z02_{feature}_plan.md`
- Extract all phases and tasks from Z02 into Z99
- Add per-task status fields (`pending`, `in_progress`, `done`, `blocked`)
- Include a per-task "Proof of work" field (file paths, tests, or commits proving completion)
- Include a short "Current batch" section and "Blockers" section
- Update Z99 as execution progresses; Z99 is the source of progress state during implementation

If Z99 already exists:
- Reconcile with latest Z02 phases/tasks (append missing tasks, preserve existing statuses)
- Treat existing Z99 as continuation state for in-progress development (resume, do not restart)
- Preserve all completed-task proof of work and existing progress notes
- Start the next batch from the remaining non-`done` tasks after reconciliation
- Do NOT delete already recorded progress notes unless they are clearly obsolete

---

### Step 5: Use Superpowers Execution Skill

**Use `superpowers:executing-plans` to execute the requested plan tasks** (not only to load the skill).

Provide enriched context:

```
EXECUTION CONTEXT:

=== PROJECT PATTERNS ===
[Full content of AGENTS.md]
[Full content of CLAUDE.md if it exists, after AGENTS.md]

=== RESEARCH CONTEXT ===
[Full content of Z01_{feature}_research.md if it exists]
[Full content of Z01_CLARIFY_{feature}_research.md if it exists]

=== IMPLEMENTATION PLAN ===
[Full content of Z02_{feature}_plan.md - REQUIRED]
[Full content of Z02_CLARIFY_{feature}_plan.md if it exists]
[Full content of Z99_implementation_status.md - REQUIRED]

=== EXECUTION INSTRUCTIONS ===

Execute the plan following these requirements:

1. Batch Execution: 3-5 tasks per batch, report after each, wait for approval
2. Pattern Adherence: Follow ALL patterns from AGENTS.md and CLAUDE.md, preserve research decisions
3. Code Review: Use superpowers:requesting-code-review between batches
4. Progress Tracking: Keep Z99_implementation_status.md updated after each completed/blocked task; when a task is completed, immediately mark it `done` in Z99 and add proof of work; do NOT modify Z02 plan content
5. Subagents: If execution requires subagents, invoke use-sub-agent skill and follow it exactly
6. Verification: Run tests after significant changes
7. Completion: ALL tasks done, tests passing, and Z99 fully complete with proof

Begin execution now.
```

**During execution:** superpowers:executing-plans handles batching and code review automatically. Monitor progress, answer questions if blocked.

---

### Step 6: Verify Tests Pass

When superpowers:executing-plans reports completion:

Run project tests (pytest, npm test, etc.)

**If tests fail:**
- Fix failures before proceeding
- Re-run until passing

**Verify completeness:**
- All tasks from Z02_plan.md completed
- All requirements met
- No blocking issues
- Tests passing

---

### Step 7: Enforce Z99 Completion Gate (BLOCKING)

Before considering implementation flow complete:

- Every task extracted from Z02 must be present in `Z99_implementation_status.md`
- Every task in Z99 must be marked `done`
- Every `done` task must include proof of work in code (for example: touched file paths and validation command/test evidence)

If any task is not `done`, or lacks proof:
- STOP and continue implementation
- Do NOT mark the implementation flow complete

---

## Red Flags - You're Failing If:

- **Proceeded with unanswered questions in Z01_CLARIFY or Z02_CLARIFY** (BLOCKING - must stop)
- **Did NOT check if Z02_plan.md exists**
- **Did NOT check for CLARIFY files before starting execution**
- **Used SlashCommand `/superpowers:execute-plan`** (use Skill tool instead)
- **Passed file paths instead of FULL CONTENT to superpowers**
- **Skipped AGENTS.md**
- **Skipped CLAUDE.md when it exists after reading AGENTS.md**
- **Failed to create/update `Z99_implementation_status.md` from Z02 before execution**
- **Overwrote an existing Z99 and reset prior progress instead of resuming from it**
- **Modified `Z02_{feature}_plan.md` to track progress** (track progress in Z99 only)
- **Completed a task in code but did not immediately mark it `done` in Z99 with proof of work**
- **Did NOT instruct code review between batches**
- **Needed subagents but skipped use-sub-agent skill**
- **Claimed implementation complete while any Z99 task is not `done` or lacks proof**
- **Using hardcoded paths** (detect pattern instead)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"User said feature name, skip file check"** | **NO.** MUST verify Z02_{feature}_plan.md exists first. |
| **"Pass file paths to superpowers, it will read"** | **NO.** Generic superpowers doesn't know Z0* convention. Pass FULL CONTENT. |
| **"Read Z02 plan only, skip research"** | **NO.** Research has critical integration details. Read ALL: AGENTS.md, CLAUDE.md, Z01*, Z02*. |
| **"Update Z02 with checkboxes for progress"** | **NO.** Keep Z02 immutable. Extract and track progress in `Z99_implementation_status.md`. |
| **"Z99 is optional overhead"** | **NO.** Z99 is mandatory for execution tracking and batch status clarity. |
| **"Z99 already exists, recreate it from scratch"** | **NO.** Reconcile with Z02 and resume from existing status/proof. |
| **"I'll update Z99 at the end"** | **NO.** Each completed task must be marked `done` immediately with proof of work. |
| **"Execute without code review checkpoints"** | **NO.** MUST instruct superpowers to use code review between batches. |
| **"Subagent work is minor, skip delegation skill"** | **NO.** If subagents are needed, MUST invoke `use-sub-agent` skill. |
| **"Most tasks are done, close enough to finish"** | **NO.** Workflow is not done until every Z99 task is `done` with proof. |
| "Use SlashCommand /superpowers:execute-plan" | **NO.** That's a command system. Use Skill tool with "superpowers:executing-plans". |
| "AGENTS.md or CLAUDE.md optional, skip if missing" | **NO.** AGENTS.md is required, and CLAUDE.md must be loaded if it exists. Missing critical patterns breaks implementation. |

## Success Criteria

You followed the workflow if:
- ✓ Verified Z02_{feature}_plan.md exists
- ✓ Checked Z02_CLARIFY has no unanswered questions
- ✓ Read AGENTS.md
- ✓ Read CLAUDE.md (if exists) after reading AGENTS.md
- ✓ Read ALL Z01 files (if exist)
- ✓ Read Z02 files (required)
- ✓ Created/updated `Z99_implementation_status.md` by extracting all Z02 phases/tasks
- ✓ If Z99 already existed, reconciled it with Z02 and resumed from remaining tasks without losing prior progress/proof
- ✓ Used superpowers:executing-plans to execute requested tasks (NOT slash command)
- ✓ Passed FULL CONTENT of all context files
- ✓ Instructed execution to keep progress in Z99 and keep Z02 unmodified
- ✓ Marked each task as `done` in Z99 immediately when completed, with proof of work
- ✓ Instructed use-sub-agent when subagents are required
- ✓ Instructed batch execution with code review
- ✓ Verified all Z99 tasks are `done` with proof before completing flow
- ✓ All tasks completed and tests passing

## When to Use

Use when:
- Z02_{feature}_plan.md exists in ongoing directory
- All clarifications resolved (no unanswered questions)
- Ready to implement with automatic code review and Z99-based progress tracking

**Don't use when:**
- No plan exists → Use feature-plan first
- Clarifications unresolved → Answer Z02_CLARIFY questions
- Simple single-step tasks → Just implement directly

## Integration with Feature Workflow

```
1. feature-research    → Z01_research + Z01_CLARIFY
2. feature-plan        → Z02_plan + Z02_CLARIFY
3. feature-implement   → Implementation tracked in Z99 until all tasks are done with proof
```

**After this skill:**
- Implementation complete
- Tests passing
- Z99 shows all tasks `done` with proof-of-work
- Ready for optional follow-up workflow steps (for example, documentation or PR prep)
