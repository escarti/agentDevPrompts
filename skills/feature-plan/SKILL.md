---
name: feature-plan
description: Use after research (Z01 files exist) when you need to create implementation plan - wrapper that loads Z01 research context, invokes superpowers:writing-plans, and saves to Z02_{feature}_plan.md in docs/ai/ongoing/
---

# Feature Workflow: Plan Implementation

## Overview

**feature-plan is a WRAPPER skill** that automates the feature-workflow planning phase.

**What it does:**
1. Loads ALL Z01_* research files (research + clarifications)
2. Invokes `superpowers:writing-plans` with that context
3. Saves output to Z02_{feature}_plan.md in docs/ai/ongoing/
4. Checks if Z02_CLARIFY needed (new blocking questions)
5. Reports next steps to user

**Why use this instead of superpowers:writing-plans directly?**
- Automates Z01 → Z02 file management
- Integrates seamlessly with feature-workflow research phase
- Maintains consistent file naming and structure
- Enforces feature-workflow naming conventions (Z02_{feature}_plan.md)
- Integrates with clarification workflow (Z02_CLARIFY)

**Workflow Position:** AFTER feature-research (Z01 files), BEFORE feature-implement

## Step 0: Detect Repository Pattern

**Detect paths before proceeding:**

Use Bash tool:
```bash
# Scan for existing Z01 files to find ongoing directory
ONGOING_DIR=$(find . -name "Z01_*.md" -type f 2>/dev/null | head -1 | xargs dirname)

# If no Z01 files found, check common directories
if [ -z "$ONGOING_DIR" ]; then
  if [ -d "docs/ai/ongoing" ]; then
    ONGOING_DIR="docs/ai/ongoing"
  elif [ -d ".ai/ongoing" ]; then
    ONGOING_DIR=".ai/ongoing"
  elif [ -d "docs/ongoing" ]; then
    ONGOING_DIR="docs/ongoing"
  else
    ONGOING_DIR="docs/ai/ongoing"
    mkdir -p "$ONGOING_DIR"
  fi
fi

echo "Using ONGOING_DIR: $ONGOING_DIR"
```

Set variable:
- `ONGOING_DIR` - Where Z01 research files exist and Z02 plan files will be created

## Step 1: Load Project Context (MANDATORY FIRST)

**Read CLAUDE.md if it exists:**

Use Read tool:
```bash
if [ -f CLAUDE.md ]; then
  echo "Reading project guidelines..."
  # Use Read tool to read CLAUDE.md
fi
```

**Extract from CLAUDE.md (if exists):**
- Mandatory patterns that MUST be preserved
- Forbidden approaches to AVOID
- Project conventions (naming, structure, etc.)
- Release workflows and constraints

**CRITICAL:** If CLAUDE.md exists and contains constraints, these MUST be passed to superpowers:writing-plans so the plan preserves project standards.

**If CLAUDE.md doesn't exist:** Proceed to Prerequisites Check.

## Prerequisites Check

MANDATORY: Check if research files exist first.

1. **Look for Z01 research files:**
   ```bash
   ls $ONGOING_DIR/Z01_*
   ```

2. **If Z01 files found:**
   - Read ALL Z01* files in $ONGOING_DIR/
   - Extract: feature name, technical research, integration points, clarifications
   - Note the feature name from filename (e.g., Z01_metrics_research.md → feature="metrics")

3. **If NO Z01 files found:**
   - Ask user if they want to run feature-workflow:feature-research first
   - Or proceed without research context (suboptimal)

## Invoke Superpowers Planning Skill

**CRITICAL**: This skill is a WRAPPER. Its primary job is to invoke superpowers:writing-plans with Z01 context. If you skip this invocation, the skill provides no value.

Use Skill tool to load the planning skill:

```
superpowers:writing-plans
```

**Before invoking, prepare context:**
1. Read CLAUDE.md (if exists) for project constraints
2. Read the full Z01_{feature}_research.md content
3. Read all answered questions from Z01_CLARIFY_{feature}_research.md
4. Extract the feature name (e.g., "audit_logging" from Z01_audit_logging_research.md)

**When the skill loads, provide this instruction:**

"Create an implementation plan for the {feature} feature based on the research in Z01_{feature}_research.md and clarifications in Z01_CLARIFY_{feature}_research.md.

**MANDATORY CONSTRAINTS from CLAUDE.md:**
[Include any constraints, patterns, or forbidden approaches from CLAUDE.md here if it exists]

CRITICAL: Save the plan to $ONGOING_DIR/Z02_{feature}_plan.md (use the detected path, NOT hardcoded docs/plans/).

The plan should be a DIRECTIVE document with:
- Exact file paths from research
- Complete code examples
- Verification steps for each task
- TDD structure (test-fail-implement-pass-commit)
- Assumes engineer has minimal domain knowledge

If you discover NEW blocking questions during planning (not already in Z01_CLARIFY), create $ONGOING_DIR/Z02_CLARIFY_{feature}_plan.md. Otherwise, do NOT create a Z02_CLARIFY file."

## After Planning

When superpowers:writing-plans completes:

1. **Verify outputs created:**
   ```bash
   ls $ONGOING_DIR/Z02_*
   ```

2. **Check structure:**
   - $ONGOING_DIR/Z02_{feature}_plan.md must exist (main directive plan)
   - $ONGOING_DIR/Z02_CLARIFY_{feature}_plan.md only if questions exist

3. **Report to user:**
   - "Plan created: [Z02_{feature}_plan.md]($ONGOING_DIR/Z02_{feature}_plan.md)"
   - If clarifications: "Blocking questions in [Z02_CLARIFY_{feature}_plan.md]($ONGOING_DIR/Z02_CLARIFY_{feature}_plan.md)"
   - Next step: "Review clarifications, then use feature-workflow:feature-implement or feature-workflow:feature-document"

## Rationalization Table

| Excuse | Reality | Counter |
|--------|---------|---------|
| "Skip path detection, I know it's docs/ai/ongoing" | Path assumptions break in non-standard repos | MUST run Step 0 to detect ONGOING_DIR |
| "No Z01 files, skip check" | Research context critical for quality plans | MUST check for Z01* files first, offer to run feature-workflow:feature-research |
| "User can specify output paths manually" | Consistency breaks cross-skill workflow | MUST explicitly instruct $ONGOING_DIR/Z02* path in prompt to writing-plans skill |
| "Superpowers will figure out output structure" | Generic plans lack our research integration | MUST provide explicit Z02* structure instruction when loading skill |
| "Read only Z01_research, skip Z01_CLARIFY" | Missing context = incomplete plan | Read ALL Z01* files, include clarifications in context |
| "Create Z02_CLARIFY even if no questions" | Empty files clutter docs/ai/ongoing | Only create Z02_CLARIFY if NEW blocking questions discovered |
| "Use SlashCommand /superpowers:write-plan" | That's a slash command, not a skill | Use Skill tool with "superpowers:writing-plans" (the skill name) |
| "Just invoke superpowers:writing-plans directly" | Missing feature-workflow context (Z01 files, Z02 paths) | This skill (feature-plan) is a WRAPPER that loads Z01 context before invoking superpowers:writing-plans |

## Success Criteria

- [ ] Step 0 completed: ONGOING_DIR detected and set
- [ ] Step 1 completed: CLAUDE.md read if exists
- [ ] Using $ONGOING_DIR variable (not hardcoded paths)
- [ ] Checked for Z01* files before proceeding
- [ ] Read ALL Z01* files if they exist
- [ ] Passed CLAUDE.md constraints to superpowers:writing-plans (if exists)
- [ ] Invoked superpowers:writing-plans skill (NOT slash command)
- [ ] Explicitly instructed $ONGOING_DIR/Z02* output path in prompt
- [ ] Verified Z02_{feature}_plan.md was created in $ONGOING_DIR/
- [ ] Reported next steps to user with clickable file links

## Red Flags - STOP and Use This Skill

- Skipped Step 0 (path detection)
- Skipped Step 1 (CLAUDE.md loading)
- CLAUDE.md exists but was not read or constraints not passed to planning
- Using hardcoded paths (docs/ai/ongoing) instead of $ONGOING_DIR
- Directly invoking superpowers:writing-plans without loading Z01 context first
- Creating plan files with non-standard names (not Z02_{feature}_plan.md)
- Saving plans to wrong directory (not $ONGOING_DIR/)
- Did NOT check for Z01* files before proceeding
- Used SlashCommand /superpowers:write-plan instead of Skill superpowers:writing-plans
- Did NOT explicitly specify $ONGOING_DIR/Z02* output path in prompt
- Skipped reading Z01_CLARIFY if it exists
- Skipping Z02_CLARIFY decision
- Not reporting next steps to user

**All of these mean:** Stop, use feature-plan wrapper skill instead. It automates the entire Z01→Z02 workflow.
