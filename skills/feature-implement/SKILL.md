---
name: feature-implement
description: Execute plan in batches with review checkpoints - automatically loads context from Z01 research, Z02 plan, and CLAUDE.md files
category: Implementation
---

# Feature Workflow: Implement Feature

**Skill Name:** feature-implement (formerly execute-plan)

**Use when:** Plan is complete (Z02 files exist) and ready for implementation with built-in code review checkpoints.

## Overview

This skill wraps `superpowers:executing-plans` with automatic context loading from your feature-workflow research and planning files. It enriches the execution with:
- Research context (Z01 files)
- Implementation plan (Z02 files)
- Project patterns (CLAUDE.md)
- Batch execution with review checkpoints

**Workflow Position:** AFTER feature-workflow:feature-plan, BEFORE feature-workflow:feature-document

## When to Use

Use when:
- Z02_{feature}_plan.md exists in docs/ai/ongoing/
- All clarifications resolved (no unanswered questions in Z02_CLARIFY)
- Ready to implement with automatic code review between batches

**Don't use when:**
- No plan exists → Use feature-workflow:feature-plan first
- Clarifications unresolved → Answer Z02_CLARIFY questions first
- Simple single-step tasks → Just implement directly

## Core Pattern

```
Z02_{feature}_plan.md exists
    ↓
Auto-load context: Z01*, Z02*, CLAUDE.md
    ↓
Invoke superpowers:executing-plans skill with enriched context
    ↓
Execute in batches with review checkpoints
    ↓
Tests pass → feature-workflow:feature-document
```

## Step 0: Detect Repository Pattern

**Detect paths before proceeding:**

Use Bash tool:
```bash
# Scan for existing Z02 files to find ongoing directory
ONGOING_DIR=$(find . -name "Z02_*.md" -type f 2>/dev/null | head -1 | xargs dirname)

# If no Z02 files found, check for Z01 files
if [ -z "$ONGOING_DIR" ]; then
  ONGOING_DIR=$(find . -name "Z01_*.md" -type f 2>/dev/null | head -1 | xargs dirname)
fi

# If still not found, check common directories
if [ -z "$ONGOING_DIR" ]; then
  if [ -d "docs/ai/ongoing" ]; then
    ONGOING_DIR="docs/ai/ongoing"
  elif [ -d ".ai/ongoing" ]; then
    ONGOING_DIR=".ai/ongoing"
  elif [ -d "docs/ongoing" ]; then
    ONGOING_DIR="docs/ongoing"
  else
    echo "ERROR: No ongoing directory found. Run feature-workflow:feature-plan first."
    exit 1
  fi
fi

echo "Using ONGOING_DIR: $ONGOING_DIR"
```

Set variable:
- `ONGOING_DIR` - Where Z01/Z02 files exist

## Prerequisites Check

MANDATORY: Verify plan and context files exist.

### Step 1: Locate Plan File

```bash
# Find Z02 plan files (use detected path)
ls $ONGOING_DIR/Z02_*plan.md 2>/dev/null
```

**If multiple Z02 plans exist:**
- If user specified feature name → use that plan
- If user said "execute plan" → ask which plan to execute
- List all available plans with clickable links

**If NO Z02 plan exists:**
- Ask: "No plan found. Should I run feature-workflow:feature-plan first?"
- Do NOT proceed without a plan

### Step 2: Check for Unresolved Clarifications

```bash
# Check for clarification file (use detected path)
ls $ONGOING_DIR/Z02_CLARIFY_*plan.md 2>/dev/null
```

**If Z02_CLARIFY exists:**
- Read the file
- Check if "User response:" fields are empty
- If ANY empty → STOP, report: "Please answer questions in [Z02_CLARIFY_{feature}_plan.md]($ONGOING_DIR/Z02_CLARIFY_{feature}_plan.md) before execution"
- If all answered → proceed

### Step 3: Extract Feature Name

From `$ONGOING_DIR/Z02_{feature}_plan.md`:
- Extract {feature} from filename
- Example: `Z02_oauth_authentication_plan.md` → feature="oauth_authentication"
- Feature name should already be sanitized snake_case from feature-research/feature-plan

## Load Context Files

Read ALL available context (order matters):

### 1. Project Patterns (if exists)
```bash
# Read project conventions and forbidden patterns
read CLAUDE.md
```

### 2. Research Context (if exists)
```bash
# Read ALL Z01 files for this feature (use detected path)
read $ONGOING_DIR/Z01_{feature}_research.md
read $ONGOING_DIR/Z01_CLARIFY_{feature}_research.md
```

### 3. Plan Context (required)
```bash
# Read the plan (required, use detected path)
read $ONGOING_DIR/Z02_{feature}_plan.md

# Read clarifications if they exist and are answered
read $ONGOING_DIR/Z02_CLARIFY_{feature}_plan.md
```

**Critical:** Pass FULL CONTENT of these files to superpowers:executing-plans.

## Invoke Superpowers Execution

Use Skill tool to load the execution skill:

```
superpowers:executing-plans
```

**When the skill loads, provide this enriched context:**

```
EXECUTION CONTEXT:

=== PROJECT PATTERNS (from CLAUDE.md) ===
[Full content of CLAUDE.md if it exists]

=== RESEARCH CONTEXT (from Z01 files) ===
[Full content of docs/ai/ongoing/Z01_{feature}_research.md if it exists]

[Full content of docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md with answers if it exists]

=== IMPLEMENTATION PLAN (from Z02 files) ===
[Full content of docs/ai/ongoing/Z02_{feature}_plan.md - REQUIRED]

[Full content of docs/ai/ongoing/Z02_CLARIFY_{feature}_plan.md with answers if it exists]

=== EXECUTION INSTRUCTIONS ===

Execute the plan in docs/ai/ongoing/Z02_{feature}_plan.md following these requirements:

1. **Batch Execution:**
   - Execute tasks in logical batches (typically 3-5 tasks per batch)
   - Report completion after each batch
   - Wait for review/approval before next batch

2. **Pattern Adherence:**
   - Follow ALL patterns from CLAUDE.md (if provided)
   - Preserve architectural decisions from research
   - Do NOT deviate without asking

3. **Code Review Between Batches:**
   - After each batch, use superpowers:requesting-code-review
   - Verify implementation matches plan
   - Fix issues before proceeding

4. **Verification:**
   - Run tests after significant changes
   - Verify all requirements from plan are met
   - Report any blockers immediately

5. **Completion Criteria:**
   - ALL tasks from Z02_plan.md completed
   - Tests passing (use superpowers:verification-before-completion)
   - Ready for feature-workflow:feature-document

Begin execution now.
```

## During Execution

The agent will:
1. Execute tasks in batches (managed by superpowers:execute-plan)
2. Report after each batch
3. Use superpowers:requesting-code-review between batches
4. Handle blockers and edge cases
5. Verify completion

**Your role:** Monitor progress, answer questions if blocked.

## After Execution

When superpowers:execute-plan reports completion:

### Step 1: Verify Tests Pass

```bash
# Run project tests
# (command varies by project - pytest, npm test, etc.)
```

**If tests fail:**
- Fix failures before proceeding
- Re-run until passing

### Step 2: Verify Plan Completeness

Confirm:
- [ ] All tasks from Z02_plan.md completed
- [ ] All requirements met
- [ ] No blocking issues
- [ ] Tests passing

### Step 3: Invoke Development Logging

**MANDATORY:** Automatically invoke feature-workflow:feature-document to:
- Consolidate research + plan + implementation into timestamped dev log
- Update relevant documentation
- Clean up ALL Z0* temporary files
- Generate PR description

Use Skill tool:
```
feature-workflow:feature-document
```

**Critical:** The feature-workflow:feature-document skill will:
1. Read ALL Z01* and Z02* files
2. Create consolidated dev log in docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md
3. Update README/docs if needed
4. Remove ALL Z0* files from docs/ai/ongoing/
5. Generate PR description

**Do NOT manually clean up Z0* files** - let feature-workflow:feature-document handle it.

## Example Usage

**User says:**
> "Execute the oauth authentication plan"

**Agent does:**
```markdown
Executing plan for oauth_authentication feature.

**Context loaded:**
- CLAUDE.md (project patterns)
- Z01_oauth_authentication_research.md (research)
- Z01_CLARIFY_oauth_authentication_research.md (answered questions)
- Z02_oauth_authentication_plan.md (implementation plan)

Invoking superpowers:executing-plans skill with enriched context...
[Execution proceeds in batches with review checkpoints]
```

## Rationalization Table

| Excuse | Reality | Counter |
|--------|---------|---------|
| "User said feature name, skip file check" | File might not exist or have typos | MUST check docs/ai/ongoing/Z02_* exists first |
| "Clarify file has content, must be answered" | Content might be template with blanks | MUST check for empty "User response:" fields |
| "CLAUDE.md optional, skip if missing" | Missing critical patterns breaks implementation | Check for CLAUDE.md, load if exists |
| "Pass file paths to superpowers, it will read" | Generic superpowers won't know our Z0* convention | MUST read files and pass FULL CONTENT |
| "Use SlashCommand /superpowers:execute-plan" | That's a command, not the skill - different system | Use Skill tool with "superpowers:executing-plans" (the skill) |
| "Just invoke superpowers without context" | Missing context = lower quality execution | MUST load and pass all Z0*, CLAUDE.md context |
| "Read Z02 plan only, skip research" | Research has critical integration details | Read ALL available context: CLAUDE.md, Z01*, Z02* |
| "Execute without code review checkpoints" | Large changes without review = risky | MUST instruct superpowers to use code review between batches |
| "Tests pass, stop and ask user about logging" | Manual step breaks workflow automation | MUST automatically invoke feature-workflow:feature-document after verification |
| "Manually delete Z0* files after logging" | Manual cleanup error-prone and inconsistent | Let feature-workflow:feature-document handle ALL cleanup |

## Common Mistakes & Red Flags

| Mistake | Fix |
|---------|-----|
| Skipping Step 0 (path detection) | ALWAYS detect ONGOING_DIR first |
| Using hardcoded paths (docs/ai/ongoing) | Use detected $ONGOING_DIR variable |
| Did NOT check for Z02_plan.md existence | MUST verify file exists before proceeding |
| Proceeded with unanswered clarifications | MUST check Z02_CLARIFY for empty responses |
| Used SlashCommand /superpowers:execute-plan | Use Skill tool with superpowers:executing-plans |
| Invoked superpowers without passing context | MUST read and pass full content of Z0* + CLAUDE.md |
| Passed file paths instead of content | Superpowers won't know Z0* convention - pass CONTENT |
| Skipped CLAUDE.md when it exists | Project patterns critical - always load if exists |
| No code review between batches | MUST instruct superpowers:requesting-code-review usage |
| Stopped after tests pass without dev logging | MUST invoke feature-workflow:feature-document automatically |
| Manually deleted Z0* files | Let feature-workflow:feature-document handle cleanup |

**Red Flags - STOP and Fix:**
- Skipped Step 0 (path detection)
- Using hardcoded paths instead of $ONGOING_DIR
- Did NOT verify Z02_plan.md exists
- Found Z02_CLARIFY with empty "User response:" fields
- Used SlashCommand /superpowers:execute-plan instead of Skill superpowers:executing-plans
- Invoked with file paths instead of FULL CONTENT
- Did NOT check for CLAUDE.md
- Forgot to pass research context (Z01 files)
- Did NOT instruct code review between batches
- Stopped after tests pass without invoking feature-workflow:feature-document
- Manually deleted Z0* files instead of using feature-workflow:feature-document

## Success Criteria

Execution is complete when:
- [ ] Step 0 completed: ONGOING_DIR detected and set
- [ ] Using $ONGOING_DIR variable (not hardcoded paths)
- [ ] Verified Z02_{feature}_plan.md exists in $ONGOING_DIR
- [ ] Checked Z02_CLARIFY has no unanswered questions (or doesn't exist)
- [ ] Extracted {feature} name from plan filename
- [ ] Read CLAUDE.md (if exists)
- [ ] Read ALL Z01_{feature}* files (if exist)
- [ ] Read Z02_{feature}_plan.md (required)
- [ ] Read Z02_CLARIFY_{feature}_plan.md (if exists and answered)
- [ ] Invoked superpowers:executing-plans skill (NOT slash command) with FULL CONTENT of all context
- [ ] Instructed batch execution with code review checkpoints
- [ ] All tasks completed and tests passing
- [ ] Automatically invoked feature-workflow:feature-document
- [ ] Development logging completed (dev log created, docs updated, Z0* files cleaned up)

## Integration with Feature Workflow

This skill completes the feature-workflow cycle:

```
1. feature-workflow:feature-research    → Z01_research + Z01_CLARIFY
2. feature-workflow:feature-plan        → Z02_plan + Z02_CLARIFY (optional)
3. feature-workflow:feature-implement   → Implementation + automatically calls feature-workflow:feature-document (this skill)
   └─→ feature-workflow:feature-document → Dev log + cleanup + PR description
```

**Before this skill:**
- Research complete (Z01 files)
- Plan complete (Z02 files)
- Clarifications answered

**After this skill:**
- Implementation complete
- Tests passing
- Dev log created in docs/ai/dev_logs/
- All Z0* temp files cleaned up
- PR description generated
- Ready to commit and create PR

## Next Steps After Implementation

**Implementation complete!**

**Recommended next steps (choose one):**

**Option 1: Quality check before PR**
1. Run `/clear` to start fresh context
2. Run `/feature-finish` to perform final quality assessment
3. Review findings with feature-research
4. Fix any issues found
5. Then proceed to PR creation

**Option 2: Document and create PR immediately**
1. Run `/clear` to start fresh context
2. Run `/feature-document` to consolidate documentation and create PR

**Why /clear first?**
- Fresh context = unbiased review
- No implementation history influencing assessment
- Catches blind spots from implementation phase
