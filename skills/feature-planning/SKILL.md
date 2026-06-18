---
name: feature-planning
description: Use after research (Z01 files exist) to create implementation plan - follow structured workflow
---

# Feature Workflow: Plan Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Read AGENTS.md first and CLAUDE.md if it exists

**This skill is a WRAPPER that loads Z01 context and invokes superpowers:writing-plans**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature planning workflow",
  "plan": [
    {"step": "Step 1: Load project context (AGENTS.md first, CLAUDE.md if it exists)", "status": "in_progress"},
    {"step": "Step 2: Verify Z01 files exist", "status": "pending"},
    {"step": "Step 3: Read ALL Z01 files", "status": "pending"},
    {"step": "Step 4: Invoke superpowers:writing-plans", "status": "pending"},
    {"step": "Step 5: Verify Z02 outputs", "status": "pending"},
    {"step": "Step 6: Resolve/track Z02_CLARIFY and block handoff until cleared", "status": "pending"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Why Use This Wrapper?

- Automates Z01 → Z02 file management
- Loads AGENTS.md defaults and CLAUDE.md constraints into planning context
- Enforces feature-workflow naming conventions (Z02_{feature}_plan.md)
- Integrates with clarification workflow (Z02_CLARIFY)
- Maintains consistent file structure

**Without this wrapper:** You'd manually load Z01 files, pass to superpowers:writing-plans, manage Z02 output paths, check for clarifications.

## Workflow Steps

### Step 1: Load Project Context (MANDATORY FIRST)

**Read `AGENTS.md` first. Then read `CLAUDE.md` if it exists.**

Extract from `AGENTS.md` and `CLAUDE.md` (if it exists):
- Mandatory patterns that MUST be preserved
- Forbidden approaches to AVOID
- Project conventions (naming, structure, etc.)
- Release workflows and constraints

**CRITICAL:** Pass `AGENTS.md` defaults and any `CLAUDE.md` constraints to superpowers:writing-plans so the plan preserves project standards.

---

### Step 2: Verify Z01 Files Exist

Scan for existing Z01 files in common locations (docs/ai/ongoing, .ai/ongoing, docs/ongoing).

**If Z01 files found:**
- Note the ONGOING_DIR location
- Extract feature name from filename (e.g., Z01_metrics_research.md → "metrics")
- Feature name should already be sanitized snake_case from feature-research

**If NO Z01 files found:**
- Ask user if they want to run feature-workflow:feature-researching first
- Or proceed without research context (suboptimal)

---

### Step 3: Read ALL Z01 Files

Read all Z01 files in ONGOING_DIR:
- Z01_{feature}_research.md (required)
- Z01_CLARIFY_{feature}_research.md (if exists)

**BLOCKING CHECK - If Z01_CLARIFY exists:**
- Read the file
- Check if "User response:" fields are empty
- **If ANY empty → STOP, report:** "Cannot plan with unanswered questions. Please answer all questions in Z01_CLARIFY_{feature}_research.md first."
- If all answered → proceed

Extract:
- Grounded feature behavior and explicit non-goals
- Current repo state, likely touchpoints, and integration points
- Answered clarifications
- Risks, dependencies, compatibility concerns, and planning-safe assumptions
- Security, test, and acceptance requirements

---

### Step 4: Invoke Superpowers Planning

**CRITICAL**: This skill's primary job is to invoke superpowers:writing-plans with Z01 context. If you skip this invocation, the skill provides no value.

**Load and follow** `superpowers:writing-plans` using Codex's current skill-loading flow.
If that dependency is unavailable, stop and report that the required Superpowers skill is missing.

Provide this instruction:

"Create an implementation plan for the {feature} feature based on the research in Z01_{feature}_research.md and clarifications in Z01_CLARIFY_{feature}_research.md.

**MANDATORY CONSTRAINTS from AGENTS.md and CLAUDE.md:**
[Include any constraints, patterns, or forbidden approaches from AGENTS.md and CLAUDE.md here if they exist]

CRITICAL: Save the plan to {ONGOING_DIR}/Z02_{feature}_plan.md (use the detected path, NOT hardcoded docs/plans/).

The plan should be a DIRECTIVE document with:
- Exact file paths and edit targets determined during planning
- Complete code examples
- Verification steps for each task
- TDD structure (test-fail-implement-pass-commit)
- A phased delivery strategy split into multiple self-contained PRs (when scope is non-trivial), where each phase is independently reviewable, testable, and mergeable
- For each planned PR phase: clear scope boundaries, explicit out-of-scope items, dependency notes, and phase-specific verification
- Explicit `## Phase N: <name>` sections that define the execution boundary for feature-implementing
- For each phase: `**Phase Goal:**`, `**Phase Verification:**`, and `**Phase Boundary Rule:**`
- For every task: a `**Phase:** Phase N` field matching its containing phase
- Assumes engineer has minimal domain knowledge

Treat Z01 as a grounded feature specification, not a pseudo-plan. Planning is responsible for locking:
- exact file edits and line ranges
- implementation decomposition
- phase boundaries
- code-level execution detail

Preserve from Z01:
- grounded behavior
- clarified requirements
- risks and dependencies
- acceptance criteria
- planning-safe assumptions

If you discover NEW blocking questions during planning (not already in Z01_CLARIFY), create {ONGOING_DIR}/Z02_CLARIFY_{feature}_plan.md. Otherwise, do NOT create a Z02_CLARIFY file.

**When incorporating answered questions:** Delete fully-answered CLARIFY files or remove incorporated Q&A pairs if only some were answered."

---

### Step 5: Verify Outputs

When superpowers:writing-plans completes:

**Check structure:**
- Z02_{feature}_plan.md must exist in ONGOING_DIR (main directive plan)
- Z02_CLARIFY_{feature}_plan.md only if NEW questions exist

---

### Step 6: Completion Gate (CLARIFY Controls Done State)

Planning is **NOT complete** while `Z02_CLARIFY_{feature}_plan.md` exists with unresolved items.

**Unresolved means ANY of the following:**
- File still contains `Agent question:` entries
- Any `User response:` is blank
- Answers were provided but not yet incorporated into `Z02_{feature}_plan.md`

**If unresolved Z02_CLARIFY exists:**
1. Keep planning todo as `in_progress` (do NOT mark workflow complete)
2. Report only: "Planning blocked by unresolved clarifications in Z02_CLARIFY_{feature}_plan.md."
3. Do NOT invoke or suggest `feature-implementing` yet

**Only mark planning complete when:**
1. Clarification answers are incorporated into `Z02_{feature}_plan.md`
2. `Z02_CLARIFY_{feature}_plan.md` is deleted (or has no remaining Q&A pairs)
3. Plan remains directive and executable

**Report to user:**
- If no unresolved clarifications: "Plan created: Z02_{feature}_plan.md. Ready for feature-workflow:feature-implementing, which will ask for execution mode and own batching/Z99 tracking."
- If clarifications exist: "Planning not complete. Resolve Z02_CLARIFY before implementation."

---

## Red Flags - You're Failing If:

- **Proceeded with unanswered questions in Z01_CLARIFY** (BLOCKING - must stop)
- **Marked planning done while Z02_CLARIFY still has unresolved items**
- **Did NOT read AGENTS.md first**
- **Did NOT read CLAUDE.md when it exists after reading AGENTS.md**
- **AGENTS.md or CLAUDE.md constraints not passed to planning**
- **Did NOT check for Z01* files**
- **Directly invoked superpowers:writing-plans without loading Z01 context**
- **Creating plan files with non-standard names** (not Z02_{feature}_plan.md)
- **Saving plans to wrong directory**
- **Treated `superpowers:writing-plans` like a slash command or generic tool call** instead of loading the skill through Codex's current skill workflow
- **Did NOT explicitly specify output path** in prompt to writing-plans
- **Skipped reading Z01_CLARIFY** (if exists)
- **Using hardcoded paths** (detect pattern instead)
- **Produced a single mega-PR plan for a non-trivial feature** instead of phased, self-contained PRs

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Skip path detection, I know it's docs/ai/ongoing"** | **NO.** Path assumptions break in non-standard repos. Detect ONGOING_DIR. |
| **"No Z01 files, skip check"** | **NO.** Research context critical for quality plans. Check first. |
| **"Superpowers will figure out output structure"** | **NO.** Generic plans lack our research integration. Provide explicit Z02* instruction. |
| **"Read only Z01_research, skip Z01_CLARIFY"** | **NO.** Missing context = incomplete plan. Read ALL Z01* files. |
| **"Create Z02_CLARIFY even if no questions"** | **NO.** Empty files clutter directory. Only create if NEW questions. |
| **"Just invoke superpowers:writing-plans directly"** | **NO.** This wrapper loads Z01 context. That's its value. |
| **"Planning is done because Z02 plan exists"** | **NO.** Done state requires no unresolved Z02_CLARIFY. |
| "Wrapper skill, no need to track steps" | **NO.** Wrapper has critical steps (context loading, invocation). Track them with the current Codex progress tool. |
| "Progress tracking adds overhead, skip it" | **NO.** Maintain workflow state with Codex-compatible progress tracking such as `update_plan`. |

## Success Criteria

You followed the workflow if:
- ✓ Read AGENTS.md
- ✓ Read CLAUDE.md if it exists after reading AGENTS.md
- ✓ Passed AGENTS.md and CLAUDE.md constraints to superpowers:writing-plans
- ✓ Checked for Z01* files
- ✓ Read ALL Z01* files if they exist
- ✓ Loaded and followed `superpowers:writing-plans` through Codex's current skill workflow
- ✓ Explicitly instructed output path in prompt
- ✓ Verified Z02_{feature}_plan.md was created
- ✓ Plan defines self-contained, sequential PR phases for non-trivial work (not one mega PR)
- ✓ Plan includes explicit phase metadata and per-task phase labels for implementation batching
- ✓ Planning stayed in_progress until Z02_CLARIFY was fully resolved and removed
- ✓ Reported next steps to user

## When to Use

**Workflow Position:** AFTER feature-research (Z01 files), BEFORE feature-implement

Use when:
- Z01 research files exist
- Need to create implementation plan
- Want automated Z01 → Z02 workflow

**Don't use when:**
- No Z01 files exist → Use feature-research first
- Already have complete plan
- Simple single-step tasks
