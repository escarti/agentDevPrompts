---
name: feature-implementing
description: Use to execute implementation plan (Z02 files) in batches - follow structured workflow
category: Implementation
---

# Feature Workflow: Implement Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Verify Z02 plan exists

**This skill loads ALL context (Z01/Z02/CLAUDE.md) and executes plan in batches with code review checkpoints.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Find Z02 plan file and feature name", status: "in_progress", activeForm: "Finding plan"},
    {content: "Step 2: Check for unresolved clarifications", status: "pending", activeForm: "Checking Z02_CLARIFY"},
    {content: "Step 3: Load context (CLAUDE.md, Z01, Z02)", status: "pending", activeForm: "Reading context"},
    {content: "Step 4: Invoke superpowers:executing-plans", status: "pending", activeForm: "Starting execution"},
    {content: "Step 5: Verify tests pass", status: "pending", activeForm: "Running tests"},
    {content: "Step 6: Invoke feature-document", status: "pending", activeForm: "Creating dev log"}
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

1. **Project Patterns** (if exists): `CLAUDE.md`
2. **Research Context** (if exists): `Z01_{feature}_research.md`, `Z01_CLARIFY_{feature}_research.md` (with answers)
3. **Plan Context** (required): `Z02_{feature}_plan.md`, `Z02_CLARIFY_{feature}_plan.md` (with answers if exists)

**Critical:** You'll pass FULL CONTENT of these files to superpowers:executing-plans.

---

### Step 4: Invoke Superpowers Execution

**Use Skill tool** to invoke `superpowers:executing-plans`

Provide enriched context:

```
EXECUTION CONTEXT:

=== PROJECT PATTERNS ===
[Full content of CLAUDE.md if it exists]

=== RESEARCH CONTEXT ===
[Full content of Z01_{feature}_research.md if it exists]
[Full content of Z01_CLARIFY_{feature}_research.md if it exists]

=== IMPLEMENTATION PLAN ===
[Full content of Z02_{feature}_plan.md - REQUIRED]
[Full content of Z02_CLARIFY_{feature}_plan.md if it exists]

=== EXECUTION INSTRUCTIONS ===

Execute the plan following these requirements:

1. Batch Execution: 3-5 tasks per batch, report after each, wait for approval
2. Pattern Adherence: Follow ALL patterns from CLAUDE.md, preserve research decisions
3. Code Review: Use superpowers:requesting-code-review between batches
4. Verification: Run tests after significant changes
5. Completion: ALL tasks done, tests passing, ready for feature-document

Begin execution now.
```

**During execution:** superpowers:executing-plans handles batching and code review automatically. Monitor progress, answer questions if blocked.

---

### Step 5: Verify Tests Pass

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

### Step 6: Invoke Development Logging

**MANDATORY:** Automatically invoke `feature-workflow:feature-documenting`

Use Skill tool:
```
feature-workflow:feature-documenting
```

feature-documenting will:
1. Create consolidated dev log with all Z01/Z02 files
2. Update README/docs if needed
3. Remove ALL Z01-Z05 files from ongoing directory
4. Generate PR description
5. Ask about PR creation

**Do NOT manually clean up Z0* files** - let feature-document handle it.

---

## Red Flags - You're Failing If:

- **Proceeded with unanswered questions in Z01_CLARIFY or Z02_CLARIFY** (BLOCKING - must stop)
- **Did NOT check if Z02_plan.md exists**
- **Did NOT check for CLARIFY files before starting execution**
- **Used SlashCommand `/superpowers:execute-plan`** (use Skill tool instead)
- **Passed file paths instead of FULL CONTENT to superpowers**
- **Skipped CLAUDE.md when it exists**
- **Did NOT instruct code review between batches**
- **Stopped after tests pass without invoking feature-document**
- **Manually deleted Z0* files**
- **Using hardcoded paths** (detect pattern instead)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"User said feature name, skip file check"** | **NO.** MUST verify Z02_{feature}_plan.md exists first. |
| **"Pass file paths to superpowers, it will read"** | **NO.** Generic superpowers doesn't know Z0* convention. Pass FULL CONTENT. |
| **"Read Z02 plan only, skip research"** | **NO.** Research has critical integration details. Read ALL: CLAUDE.md, Z01*, Z02*. |
| **"Execute without code review checkpoints"** | **NO.** MUST instruct superpowers to use code review between batches. |
| **"Tests pass, ask user about next step"** | **NO.** Automatically invoke feature-document. Don't break workflow. |
| **"Manually delete Z0* files after logging"** | **NO.** Let feature-document handle ALL cleanup. Manual = error-prone. |
| "Use SlashCommand /superpowers:execute-plan" | **NO.** That's a command system. Use Skill tool with "superpowers:executing-plans". |
| "CLAUDE.md optional, skip if missing" | **NO.** Check for it. Load if exists. Missing critical patterns breaks implementation. |

## Success Criteria

You followed the workflow if:
- ✓ Verified Z02_{feature}_plan.md exists
- ✓ Checked Z02_CLARIFY has no unanswered questions
- ✓ Read CLAUDE.md (if exists)
- ✓ Read ALL Z01 files (if exist)
- ✓ Read Z02 files (required)
- ✓ Invoked superpowers:executing-plans (NOT slash command)
- ✓ Passed FULL CONTENT of all context files
- ✓ Instructed batch execution with code review
- ✓ All tasks completed and tests passing
- ✓ Automatically invoked feature-document

## When to Use

Use when:
- Z02_{feature}_plan.md exists in ongoing directory
- All clarifications resolved (no unanswered questions)
- Ready to implement with automatic code review

**Don't use when:**
- No plan exists → Use feature-plan first
- Clarifications unresolved → Answer Z02_CLARIFY questions
- Simple single-step tasks → Just implement directly

## Integration with Feature Workflow

```
1. feature-research    → Z01_research + Z01_CLARIFY
2. feature-plan        → Z02_plan + Z02_CLARIFY
3. feature-implement   → Implementation + automatically calls feature-document
   └─→ feature-document → Dev log + cleanup + PR description
```

**After this skill:**
- Implementation complete
- Tests passing
- Dev log created
- All Z0* temp files cleaned up
- PR description generated
- Ready to commit and create PR
