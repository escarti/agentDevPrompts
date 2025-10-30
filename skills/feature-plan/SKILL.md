# Feature Workflow: Plan Implementation

**Skill Name:** feature-plan (formerly write-plan)

**Use when:** Design/research is complete and you need detailed implementation tasks for engineers with zero codebase context. This skill automatically reads Z01 research files and produces Z02 plan files following the same directive/clarification pattern.

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
   - Ask user if they want to run feature-research first
   - Or proceed without research context (suboptimal)

## Invoke Superpowers Planning Skill

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
   - Next step: "Review clarifications, then use feature-implement or feature-document"

## Rationalization Table

| Excuse | Reality | Counter |
|--------|---------|---------|
| "No Z01 files, skip check" | Research context critical for quality plans | MUST check for Z01* files first, offer to run feature-research |
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

## Red Flags - STOP

- Did NOT check for Z01* files
- Used SlashCommand /superpowers:write-plan instead of Skill superpowers:writing-plans
- Did NOT explicitly specify Z02* output path in prompt
- Created plan in docs/plans/ instead of docs/ai/ongoing/
- Skipped reading Z01_CLARIFY if it exists
- Forgot to extract feature name from Z01 filename

**All of these mean:** Stop, re-read this skill, follow the structure exactly.
