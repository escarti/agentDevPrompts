---
name: feature-finish
description: Use after feature-implement completes - performs final quality check with feature-research from fresh context, identifies issues, offers fix/loop/document choices, updates Z01/Z02 if implementation deviated from plan
---

# feature-finish: Final Quality Check Before Merge

## Overview

**Performs final quality assessment after implementation, from fresh context (no prior conversation history).**

**Workflow Position:** AFTER feature-workflow:feature-implement, BEFORE feature-workflow:feature-document

**Core principle**: Don't assume implementation is correct. Use feature-research to find issues before merge.

**Run this**: After feature-implement finishes, from a new conversation/context.

## Progress Tracking

**MANDATORY:** Use TodoWrite tool to track workflow progress.

**At skill start, create todos for all steps:**

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Detect repository pattern", status: "in_progress", activeForm: "Detecting ONGOING_DIR path"},
    {content: "Step 1: Detect current branch and changes", status: "pending", activeForm: "Running git diff main"},
    {content: "Step 2: Load project context (CLAUDE.md)", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Load plan documentation (Z01/Z02)", status: "pending", activeForm: "Reading Z01 and Z02 files"},
    {content: "Step 4: Assess implementation with feature-research", status: "pending", activeForm: "Invoking feature-research"},
    {content: "Step 5: Compare implementation against plan", status: "pending", activeForm: "Analyzing deviations"},
    {content: "Step 6: Present findings summary to user", status: "pending", activeForm: "Formatting findings"},
    {content: "Step 7: User decision (Fix/Loop/Document)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 8: Execute user choice", status: "pending", activeForm: "Applying fixes or looping"},
    {content: "Step 9: Create Z05 finish documentation", status: "pending", activeForm: "Writing Z05 file"},
    {content: "Step 10: Ask about updating Z01/Z02", status: "pending", activeForm: "Checking if updates needed"}
  ]
})
```

**After completing each step:**
- Mark current step as `completed`
- Move `in_progress` to next step
- Update `activeForm` with current action

**Example update after Step 0:**
```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Detect repository pattern", status: "completed"},
    {content: "Step 1: Detect current branch and changes", status: "in_progress", activeForm: "Running git diff main"},
    {content: "Step 2: Load project context (CLAUDE.md)", status: "pending"},
    // ... remaining steps
  ]
})
```

**CRITICAL:** Exactly ONE todo should be `in_progress` at any time. All others are `pending` or `completed`.

## Mandatory Workflow

**YOU MUST follow this exact sequence. No exceptions.**

### 0. Detect Repository Pattern

**Detect paths before proceeding:**

Use Bash tool:
```bash
# Scan for existing Z01/Z02 files to find ongoing directory
ONGOING_DIR=$(find . -name "Z0[12]_*.md" -type f 2>/dev/null | head -1 | xargs dirname)

# If not found, check common directories
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
- `ONGOING_DIR` - Where Z01/Z02 files exist and Z05 finish file will be created

### 1. Detect Current Branch and Changes

```bash
# Get current branch
git branch --show-current

# Get all changed files compared to main
git diff main --name-only
```

**Extract**:
- Current branch name
- List of all changed files

**If on main branch**: Error - "Cannot run feature-finish from main branch. Switch to feature branch first."

### 2. Load Project Context (MANDATORY)

**Read CLAUDE.md if it exists:**

Use Read tool:
```bash
if [ -f CLAUDE.md ]; then
  echo "Reading project guidelines..."
  # Use Read tool to read CLAUDE.md
fi
```

**Extract from CLAUDE.md (if exists):**
- Mandatory patterns implementation should follow
- Forbidden approaches to check for violations
- Project conventions to verify compliance
- Code quality standards

**This context is critical for assessing implementation quality in step 3.**

### 3. Load Plan Documentation

**Read Z01 and Z02 files** to understand what was planned:

```bash
# Find Z01 research file (use detected path)
ls $ONGOING_DIR/Z01_*_research.md

# Find Z02 plan file (use detected path)
ls $ONGOING_DIR/Z02_*_plan.md
```

**Extract feature name:**
- From Z02 filename: `Z02_{feature}_plan.md` → feature name (already in snake_case)
- Example: `Z02_oauth_authentication_plan.md` → "oauth_authentication"
- Use this exact feature name for Z05 filename (maintain snake_case consistency)

**Use Read tool** to load both files.

**Extract**:
- Feature name from filenames
- Original requirements from Z01
- Implementation plan from Z02
- Key decisions and constraints

**If Z01/Z02 not found**: Continue anyway, but note that no plan exists (ad-hoc implementation).

### 4. Assess Implementation with feature-research

**REQUIRED**: Use Skill tool to invoke `feature-workflow:feature-research` on all changed files.

**Context to provide feature-research**:
- List of changed files
- Feature name from Z01/Z02
- CLAUDE.md constraints (if exists)
- Request: "Assess implementation quality: security issues, bugs, code quality problems, test gaps, deviations from plan, violations of CLAUDE.md patterns"

**Parse research output** for structured findings:
- File path and line number
- Issue type (security/bug/quality/test/deviation)
- Description of issue
- Severity (critical/high/medium/low)

### 5. Compare Against Plan

**For each finding, assess**:
- Is this a deviation from Z02 plan? (compare with plan steps)
- Is this a legitimate improvement/adaptation?
- Is this a mistake/oversight?

**Track deviations**:
- Intentional changes (with reason)
- Unintentional mistakes

### 6. Present Findings Summary

Display in structured format:

```
## Feature Finish Assessment: {Feature Name}

**Branch**: {branch}
**Files Changed**: {count}
**Plan Status**: Found Z01/Z02 / No plan found

### Findings Summary
- Critical issues: {count}
- High priority: {count}
- Medium priority: {count}
- Low priority: {count}
- Total: {count}

### Issues by Type
- Security: {count}
- Bugs: {count}
- Code Quality: {count}
- Tests: {count}
- Plan Deviations: {count}

### Critical Issues (if any)
1. {description} ({file}:{line})
2. ...

### Plan Deviations (if any)
1. {description} - {intentional/mistake}
2. ...
```

### 7. User Decision Point (REQUIRED)

**STOP. YOU MUST use AskUserQuestion tool NOW. Do NOT proceed to step 7 until user responds.**

**If you are reading this, you have NOT asked the user yet. STOP and use AskUserQuestion RIGHT NOW.**

```typescript
AskUserQuestion({
  questions: [{
    question: "How would you like to handle these findings?",
    header: "Action",
    multiSelect: false,
    options: [
      {
        label: "Fix all",
        description: "Automatically fix all issues using Edit tool"
      },
      {
        label: "Loop issues",
        description: "Go through each issue, decide fix/skip/explain individually"
      },
      {
        label: "Document only",
        description: "Save findings to Z05 file without making changes"
      }
    ]
  }]
})
```

**After calling AskUserQuestion, WAIT for user response. Do NOT continue reading this skill until user answers.**

### 8. Execute User Choice (ONLY AFTER USER RESPONDS)

**Fix all**:
For each issue:
- Use Edit tool to apply fix
- Verify edit succeeded
- Track fixes applied

**Loop issues**:
Loop through each issue, ask user:
```typescript
AskUserQuestion({
  questions: [{
    question: "Issue {n}/{total}: {description} ({file}:{line}). Severity: {severity}. What action?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Fix", description: "Apply the fix using Edit tool"},
      {label: "Skip", description: "Skip this issue, continue to next"},
      {label: "Explain", description: "Provide context to reassess this issue"},
      {label: "Stop", description: "Stop processing remaining issues"}
    ]
  }]
})
```

**If user chooses "Fix"**:
- Use Edit tool to apply the fix
- Verify edit succeeded
- Continue to next issue

**If user chooses "Skip"**:
- Do nothing, continue to next issue

**If user chooses "Explain"**:
- User will provide additional context in their response
- Re-read the code section with user's context
- Re-invoke feature-research with the additional context
- Present updated assessment incorporating user's context
- Ask again: Fix / Skip / Explain / Stop (with updated reasoning)
- Continue loop with new understanding

**If user chooses "Stop"**:
- Stop processing, create Z05 documentation with what's been done so far

**Document only**:
Create Z05 file (see section 8)

### 9. Create Documentation (ALWAYS)

**REGARDLESS of action choice, create Z05 file.**

**Location**: `$ONGOING_DIR/Z05_{feature}_finish.md` (use detected path)

**Use the exact feature name extracted from Z02_{feature}_plan.md** (already in snake_case from feature-research/feature-plan)

**Format**:
```markdown
# Feature Finish: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Files Changed**: {count}
**Plan Status**: Found / Not Found

## Findings

### Issue 1: {Issue Type} - {Description}
- **File**: {file}:{line}
- **Severity**: {severity}
- **Description**: {detailed explanation}
- **Plan Deviation**: Yes/No - {if yes, explain}
- **User Context**: {if user provided explanation, include it here}
- **Action**: Fixed / Skipped / Explained
- **Status**: ✓ Applied / ⊘ Skipped / ℹ User provided context

### Issue 2: ...
[Continue for all issues]

## Summary
- Total issues: {count}
- Fixed: {count}
- Skipped: {count}
- Explained (user context): {count}
- By severity:
  - Critical: {count}
  - High: {count}
  - Medium: {count}
  - Low: {count}
- By type:
  - Security: {count}
  - Bugs: {count}
  - Code Quality: {count}
  - Tests: {count}
  - Plan Deviations: {count}

## Plan Deviations
{List intentional vs unintentional deviations}

## Recommendations
{Any follow-up actions needed}
```

### 10. Update Z01/Z02 if Needed

**If there were intentional plan deviations**:

**Check if updates needed**:
- Did we add features not in Z01?
- Did we change approach from Z02?
- Did we skip planned features?

**If yes, use AskUserQuestion**:
```typescript
AskUserQuestion({
  questions: [{
    question: "Implementation deviated from plan. Update Z01/Z02 documentation?",
    header: "Update Docs",
    multiSelect: false,
    options: [
      {
        label: "Update both",
        description: "Update Z01 requirements and Z02 plan to reflect actual implementation"
      },
      {
        label: "Skip",
        description: "Leave Z01/Z02 as-is (shows original plan vs actual)"
      }
    ]
  }]
})
```

**If user chooses "Update both"**:
- Use Edit tool to update Z01 with actual features implemented
- Use Edit tool to update Z02 with actual implementation approach
- Add note: "Updated post-implementation on {date} to reflect actual work"

## Using "Explain" to Provide Context

When user chooses "Explain" during issue loop:

**Purpose**: User has additional context about:
- Why code was written this way (technical constraints)
- Business requirements not visible in code
- Future plans that justify current implementation
- Trade-offs made intentionally

**Workflow**:
1. User provides context in their response (free text)
2. Re-read the relevant code file with user's context
3. Re-assess the issue with new information
4. Present updated assessment incorporating user's context
5. Ask user again: Fix / Skip / Explain / Stop (now with full picture)

**Example**:
```
Issue: "Function has high complexity, should be refactored"
Initial Assessment: Medium severity - code quality issue

User chooses "Explain" and says:
"This complexity is intentional - we're migrating from old system and need to handle
5 different legacy formats during transition period. Will be cleaned up in Q2."

Updated Assessment: Low severity - temporary technical debt with planned resolution
→ Mark as Skip with context documented
```

**Document in Z05**:
- Include user's context verbatim
- Show how it changed the assessment
- Mark with "ℹ User provided context" status

## Red Flags - STOP and Follow Workflow

- Skipped Step 0 (path detection)
- Skipped Step 2 (CLAUDE.md loading)
- CLAUDE.md exists but was not read
- Running from same context as feature-implement (need fresh context)
- Skipping feature-research assessment
- Not reading Z01/Z02 files
- Not passing CLAUDE.md constraints to feature-research
- Skipping user choice step (not using AskUserQuestion)
- Not creating Z05 documentation
- **Drafting fixes but not applying them with Edit tool**
- **Documenting issues in Z05 instead of fixing when user chose 'Fix'**
- Making assumptions about what user wants

**All of these mean**: Stop. Follow the workflow exactly.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I can see what user wants, skip AskUserQuestion" | **NO. Use AskUserQuestion. Not optional. STOP and ask.** |
| "User obviously wants fixes, no need to ask" | **NO. ALWAYS ask. User might want document-only. Use AskUserQuestion.** |
| "I'll just start fixing, user can stop me" | **NO. Ask BEFORE any action. Use AskUserQuestion NOW.** |
| "Assessment done, I can proceed" | **NO. Step 6 requires AskUserQuestion. You have NOT done step 6 yet.** |
| "I drafted fixes, that's enough" | **NO. Use Edit tool to APPLY fixes. Draft is not applied.** |
| "I'll document in Z05, no need to fix" | **NO. User chose 'Fix' = apply changes. Use Edit tool.** |
| "Implementation looks good, skip assessment" | **NO. Always use feature-research. Fresh eyes find issues.** |
| "I remember from feature-implement context" | **NO. This runs from FRESH context. Use feature-research.** |
| "Z01/Z02 not found, skip reading" | **NO. Try to find them. If truly missing, note it and continue.** |
| "TodoWrite adds overhead, skip it" | **NO.** TodoWrite provides user visibility and prevents skipped steps. MANDATORY. |
| "I can track steps mentally" | **NO.** Mental tracking fails under pressure. Use TodoWrite tool NOW. |
| "Quality check is exploratory, no tracking needed" | **NO.** 11 mandatory steps with user decisions. MUST track with TodoWrite. |

## Error Handling

**On main branch**:
```
Cannot run feature-finish from main branch.
Switch to feature branch: git checkout <feature-branch>
```

**No changed files**:
```
No files changed compared to main.
Either:
- Already merged and on main
- No work done on this branch
- Wrong branch checked out
```

**Z01/Z02 not found**:
```
No Z01/Z02 files found for this feature.
Continuing with assessment, but cannot compare against original plan.
This may be an ad-hoc implementation without formal planning.
```

**feature-research unavailable**:
Fallback to Read tool for basic code context (less systematic, but workable)

**Edit tool failures**:
Report which fixes failed, continue with others. Add to Z05 documentation with failure note.

## Success Criteria

You followed the workflow correctly if:
- ✓ Ran from fresh context (no feature-implement history)
- ✓ Used git diff to get changed files
- ✓ Attempted to read Z01/Z02 files
- ✓ Invoked feature-research skill on all changed files
- ✓ Compared implementation against plan (if plan exists)
- ✓ Presented findings summary by severity and type
- ✓ Used AskUserQuestion for user choice
- ✓ **Applied fixes with Edit tool (not just drafts)**
- ✓ **Verified each edit succeeded**
- ✓ Created Z05 documentation file
- ✓ Asked about updating Z01/Z02 if deviations found
- ✓ Resisted all rationalization pressures

## When to Use This Skill

- **After feature-implement completes** (before creating PR)
- **Before merging to main** (final quality gate)
- **When revisiting old feature branch** (assess current state)
- **After manual coding without feature-implement** (quality check)

## When NOT to Use This Skill

- During active implementation (use feature-implement instead)
- For reviewing someone else's PR (use feature-prreview instead)
- For fixing PR review comments (use feature-prfix instead)
