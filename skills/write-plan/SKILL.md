# Feature Workflow: Write Plan

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

## Invoke Superpowers Planning

Use SlashCommand tool to invoke:

```
/superpowers:write-plan

CONTEXT FROM RESEARCH:
[Include full content from Z01_{feature}_research.md]
[Include all questions from Z01_CLARIFY_{feature}_research.md if exists]

IMPORTANT OUTPUT REQUIREMENTS:

Create the implementation plan in this structure:

1. Main plan document: docs/ai/ongoing/Z02_{feature}_plan.md
   - This should be a DIRECTIVE document (zero questions, all answers)
   - Comprehensive implementation plan with:
     * Exact file paths from research
     * Complete code examples
     * Verification steps
     * Assumes engineer has minimal domain knowledge

2. Clarification questions: docs/ai/ongoing/Z02_CLARIFY_{feature}_plan.md
   - ONLY if there are unresolved questions or ambiguities
   - Format: One question per line or bullet
   - These are questions that BLOCK implementation
   - If no blocking questions exist, DO NOT create this file

Use the same {feature} name from the Z01 files for consistency.
```

## After Planning

When superpowers:write-plan completes:

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
   - Next step: "Review clarifications, then use /superpowers:execute-plan or feature-workflow:development-logging"

## Rationalization Table

| Excuse | Reality | Counter |
|--------|---------|---------|
| "No Z01 files, skip check" | Research context critical for quality plans | MUST check for Z01* files first, offer to run feature-research |
| "User can specify output paths manually" | Consistency breaks cross-skill workflow | MUST use Z02* naming convention in SlashCommand prompt |
| "Superpowers will figure out output structure" | Generic plans lack our research integration | MUST explicitly instruct Z02* structure in prompt |
| "Read only Z01_research, skip Z01_CLARIFY" | Missing context = incomplete plan | Read ALL Z01* files, include clarifications in context |
| "Create Z02_CLARIFY even if no questions" | Empty files clutter docs/ai/ongoing | Only create Z02_CLARIFY if blocking questions exist |

## Success Criteria

- [ ] Checked for Z01* files before proceeding
- [ ] Read ALL Z01* files if they exist
- [ ] Invoked /superpowers:write-plan with full research context
- [ ] Explicitly instructed Z02* output structure in prompt
- [ ] Verified Z02_{feature}_plan.md was created
- [ ] Reported next steps to user with clickable file links

## Red Flags - STOP

- Did NOT check for Z01* files
- Invoked /superpowers:write-plan without specifying Z02* output structure
- Created generic plan.md instead of Z02_{feature}_plan.md
- Skipped reading Z01_CLARIFY if it exists
- Forgot to extract feature name from Z01 filename

**All of these mean:** Stop, re-read this skill, follow the structure exactly.
