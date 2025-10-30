---
name: feature-plan
description: Use after research (Z01 files exist) when you need to create implementation plan - wrapper that loads Z01 research context, invokes superpowers:writing-plans, and saves to Z02_{feature}_plan.md in docs/ai/ongoing/
---

# Feature Workflow: Plan Implementation

## Overview

**feature-plan is a WRAPPER skill** that automates the feature-workflow planning phase.

**What it does:**
1. Loads ALL Z01_* research files (research + clarifications)
2. Invokes superpowers:writing-plans with that context
3. Saves output to Z02_{feature}_plan.md in docs/ai/ongoing/
4. Checks if Z02_CLARIFY needed (new blocking questions)
5. Reports next steps to user

**Why use this instead of superpowers:writing-plans directly?**
- Automates Z01 → Z02 file management
- Enforces feature-workflow naming conventions (Z02_{feature}_plan.md)
- Integrates with clarification workflow (Z02_CLARIFY)
- Provides consistent user experience across feature lifecycle

**Workflow Position:** AFTER feature-research (Z01 files), BEFORE feature-implement

## Prerequisites Check

MANDATORY: Check if research files exist first.

1. **Look for Z01 research files:**
   ```bash
   ls docs/ai/ongoing/Z01_*
   ```

2. **If Z01 files found:**
   - Read ALL Z01* files in docs/ai/ongoing/
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
1. Read the full Z01_{feature}_research.md content
2. Read all answered questions from Z01_CLARIFY_{feature}_research.md
3. Extract the feature name (e.g., "audit_logging" from Z01_audit_logging_research.md)

**When the skill loads, provide this instruction:**

"Create an implementation plan for the {feature} feature based on the research in Z01_{feature}_research.md and clarifications in Z01_CLARIFY_{feature}_research.md.

CRITICAL: Save the plan to docs/ai/ongoing/Z02_{feature}_plan.md (NOT docs/plans/).

The plan should be a DIRECTIVE document with:
- Exact file paths from research
- Complete code examples
- Verification steps for each task
- TDD structure (test-fail-implement-pass-commit)
- Assumes engineer has minimal domain knowledge

If you discover NEW blocking questions during planning (not already in Z01_CLARIFY), create docs/ai/ongoing/Z02_CLARIFY_{feature}_plan.md. Otherwise, do NOT create a Z02_CLARIFY file."

## After Planning

When superpowers:writing-plans completes:

1. **Verify outputs created:**
   ```bash
   ls docs/ai/ongoing/Z02_*
   ```

2. **Check structure:**
   - Z02_{feature}_plan.md must exist (main directive plan)
   - Z02_CLARIFY_{feature}_plan.md only if questions exist

3. **Report to user:**
   - "Plan created: [Z02_{feature}_plan.md](docs/ai/ongoing/Z02_{feature}_plan.md)"
   - If clarifications: "Blocking questions in [Z02_CLARIFY_{feature}_plan.md](docs/ai/ongoing/Z02_CLARIFY_{feature}_plan.md)"
   - Next step: "Review clarifications, then use feature-workflow:feature-implement or feature-workflow:feature-document"

## Rationalization Table

| Excuse | Reality | Counter |
|--------|---------|---------|
| "No Z01 files, skip check" | Research context critical for quality plans | MUST check for Z01* files first, offer to run feature-workflow:feature-research |
| "User can specify output paths manually" | Consistency breaks cross-skill workflow | MUST explicitly instruct Z02* path in prompt to writing-plans skill |
| "Superpowers will figure out output structure" | Generic plans lack our research integration | MUST provide explicit Z02* structure instruction when loading skill |
| "Read only Z01_research, skip Z01_CLARIFY" | Missing context = incomplete plan | Read ALL Z01* files, include clarifications in context |
| "Create Z02_CLARIFY even if no questions" | Empty files clutter docs/ai/ongoing | Only create Z02_CLARIFY if NEW blocking questions discovered |
| "Use SlashCommand /superpowers:write-plan" | That's a slash command, not a skill | Use Skill tool with "superpowers:writing-plans" (the skill name) |
| "Just invoke superpowers:writing-plans directly" | Missing feature-workflow context (Z01 files, Z02 paths) | This skill (feature-plan) is a WRAPPER that loads Z01 context before invoking superpowers:writing-plans |

## Success Criteria

- [ ] Checked for Z01* files before proceeding
- [ ] Read ALL Z01* files if they exist
- [ ] Invoked superpowers:writing-plans skill (NOT slash command)
- [ ] Explicitly instructed Z02* output path in prompt
- [ ] Verified Z02_{feature}_plan.md was created in docs/ai/ongoing/
- [ ] Reported next steps to user with clickable file links

## Red Flags - STOP and Use This Skill

- Directly invoking superpowers:writing-plans without loading Z01 context first
- Creating plan files with non-standard names (not Z02_{feature}_plan.md)
- Saving plans to docs/plans/ instead of docs/ai/ongoing/
- Did NOT check for Z01* files before proceeding
- Used SlashCommand /superpowers:write-plan instead of Skill superpowers:writing-plans
- Did NOT explicitly specify Z02* output path in prompt
- Skipped reading Z01_CLARIFY if it exists
- Skipping Z02_CLARIFY decision
- Not reporting next steps to user

**All of these mean:** Stop, use feature-plan wrapper skill instead. It automates the entire Z01→Z02 workflow.
