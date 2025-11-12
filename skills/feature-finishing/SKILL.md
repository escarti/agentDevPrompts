---
name: feature-finishing
description: Use after feature-implementing completes - performs final quality check from fresh context
---

# feature-finish: Final Quality Check Before Merge

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Confirm you're on a feature branch (not main)

**This skill runs from FRESH context. If you have feature-implement conversation history, you're doing it wrong.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Get current branch and changed files", status: "in_progress", activeForm: "Getting git status"},
    {content: "Step 2: Read CLAUDE.md", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Load Z01/Z02 plan files", status: "pending", activeForm: "Reading plan docs"},
    {content: "Step 4: Assess implementation with feature-research", status: "pending", activeForm: "Running quality check"},
    {content: "Step 5: Compare against plan", status: "pending", activeForm: "Checking deviations"},
    {content: "Step 6: Present findings", status: "pending", activeForm: "Formatting summary"},
    {content: "Step 7: Ask user what to do (AskUserQuestion)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 8: Execute user choice", status: "pending", activeForm: "Applying fixes"},
    {content: "Step 9: Create Z05 finish documentation", status: "pending", activeForm: "Writing Z05"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

### Step 1: Get Current Branch and Changed Files

```bash
git branch --show-current
git diff main --name-only
```

**Extract:**
- Current branch name
- List of changed files

**If on main:** Error - "Cannot run from main. Switch to feature branch first."

---

### Step 2: Read CLAUDE.md

Read `CLAUDE.md` if it exists.

Look for:
- Mandatory patterns
- Forbidden approaches
- Code quality standards

You'll use these when assessing implementation.

---

### Step 3: Load Z01/Z02 Plan Files

**Find and read plan documentation:**

Scan for Z01/Z02 files in common locations (docs/ai/ongoing, .ai/ongoing, etc.)

**Extract:**
- Feature name from filenames (Z02_{feature}_plan.md)
- Original requirements from Z01
- Implementation plan from Z02

**If not found:** Note "No plan found" and continue (ad-hoc implementation).

**Save ONGOING_DIR location** - you'll create Z05 there.

---

### Step 4: Hunt for Bugs (Adversarial Assessment)

**CRITICAL MINDSET: ASSUME BUGS EXIST. Your job is to FIND them.**

You are a security auditor, QA engineer, and attacker combined. Don't ask "is this correct?" Ask "how can I break this?"

**Read each changed file with adversarial intent:**

For EACH file, actively hunt for:

**1. Security Vulnerabilities:**
- Input validation missing → Can I inject code? (SQL, XSS, command injection)
- Authentication bypasses → Can I access without credentials?
- Authorization flaws → Can I access data I shouldn't?
- Secrets exposed → Are credentials/keys in code?
- Resource exhaustion → Can I cause DoS with large inputs?

**2. Logic Bugs:**
- Edge cases → What happens with null/empty/max values?
- Off-by-one errors → Array bounds, loop conditions
- Race conditions → Async operations, state changes
- Error handling → What breaks when dependencies fail?
- Incorrect assumptions → Does code assume happy path only?

**3. Code Quality Issues:**
- CLAUDE.md violations → Does this break mandatory patterns?
- Inconsistent with codebase → Different from existing approaches?
- Missing error handling → Silent failures?
- Poor naming/structure → Confusing or misleading?

**4. Test Gaps:**
- Untested paths → What code has NO test coverage?
- Missing negative tests → Error cases tested?
- Integration gaps → Are component boundaries tested?

**5. Plan Deviations:**
- Compare against Z02 → Did implementation diverge?
- Unintentional changes → Scope creep or mistakes?

**HOW to hunt:**
- Read code line-by-line, ask "what breaks here?"
- Trace data flow: user input → processing → output
- Check every conditional: what if the opposite happens?
- Check every function call: what if it returns error/null?
- Look for what's NOT there: missing validation, missing tests

**Document findings:**
- File path and line number
- Issue type (security/bug/quality/test/deviation)
- Severity (critical/high/medium/low)
- Explanation: WHY this is a bug, HOW to exploit/trigger it

---

### Step 5: Compare Against Plan

For each finding, assess:
- Is this a deviation from Z02 plan?
- Is this a legitimate improvement?
- Is this a mistake?

Track:
- Intentional changes (with reason)
- Unintentional mistakes

---

### Step 6: Present Findings

Display summary:

```
## Feature Finish Assessment: {Feature Name}

**Branch**: {branch}
**Files Changed**: {count}
**Plan Status**: Found Z01/Z02 / No plan found

### Findings Summary
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}

### Issues by Type
- Security: {count}
- Bugs: {count}
- Code Quality: {count}
- Tests: {count}
- Plan Deviations: {count}

### Critical Issues (if any)
1. {description} ({file}:{line})
```

**DO NOT suggest next steps. Proceed immediately to Step 7.**

---

### Step 7: Ask User What To Do

**STOP. Use AskUserQuestion tool NOW.**

**If you haven't asked the user yet, you are at Step 7. Ask NOW.**

```typescript
AskUserQuestion({
  questions: [{
    question: "How would you like to handle these findings?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Fix all", description: "Automatically fix all issues using Edit tool"},
      {label: "Loop issues", description: "Go through each issue, decide fix/skip/explain individually"},
      {label: "Document only", description: "Save findings to Z05 file without making changes"}
    ]
  }]
})
```

**Wait for user response before Step 8.**

---

### Step 8: Execute User Choice

**If "Fix all":**

Use Skill tool to invoke `superpowers:systematic-debugging` with ALL findings:

```
You are fixing issues found in feature-finish quality check.

CONTEXT:
- Feature: {feature_name}
- Branch: {branch}
- Files changed: {list}
- CLAUDE.md constraints: {if exists}

FINDINGS TO FIX:
{List all issues with file:line, severity, description}

For EACH issue:
1. Root Cause Investigation: Read code, understand why issue exists
2. Pattern Analysis: Check if similar issues exist elsewhere
3. Hypothesis: State what fix will do
4. Implementation: Apply fix, verify it works

CRITICAL: If 3+ fixes fail for SAME issue → STOP and report "architectural problem, not implementation bug"

Report back: What was fixed, what failed, any architectural concerns discovered.
```

Track systematic-debugging's report for Z05 documentation.

---

**If "Loop issues":**

For each issue, ask user:
```typescript
AskUserQuestion({
  questions: [{
    question: "Issue {n}/{total}: {description} ({file}:{line}). Severity: {severity}. What action?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Fix", description: "Fix using superpowers:systematic-debugging"},
      {label: "Skip", description: "Skip this issue, continue to next"},
      {label: "Explain", description: "Provide context to reassess this issue"},
      {label: "Stop", description: "Stop processing remaining issues"}
    ]
  }]
})
```

**If user chooses "Fix":**

Use Skill tool to invoke `superpowers:systematic-debugging` for this specific issue:

```
Fix this issue using systematic debugging:

CONTEXT:
- Feature: {feature_name}
- File: {file}:{line}
- Severity: {severity}
- Description: {issue_description}
- CLAUDE.md constraints: {if exists}

Follow the four phases:
1. Root Cause Investigation
2. Pattern Analysis
3. Hypothesis and Testing
4. Implementation

Report back: Root cause found, fix applied, verification result.
```

**If user chooses "Explain":**

User provides context → re-invoke feature-research with new context → update assessment → ask again.

---

**If "Document only":**

Skip to Step 9.

---

### Step 9: Create Z05 Documentation

**ALWAYS create Z05 file** (regardless of choice).

**Location:** `{ONGOING_DIR}/Z05_{feature}_finish.md`

**Use feature name from Z02 filename** (already in snake_case).

**Format:**
```markdown
# Feature Finish: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Files Changed**: {count}
**Plan Status**: Found / Not Found

## Findings

### Issue 1: {Type} - {Description}
- **File**: {file}:{line}
- **Severity**: {severity}
- **Description**: {explanation}
- **Plan Deviation**: Yes/No
- **User Context**: {if provided}
- **Action**: Fixed / Skipped / Explained
- **Status**: ✓ Applied / ⊘ Skipped / ℹ Context

### Issue 2: ...

## Summary
- Total: {count}
- Fixed: {count}
- By severity: Critical {count}, High {count}, etc.
- By type: Security {count}, Bugs {count}, etc.

## Plan Deviations
{List intentional vs unintentional}

## Recommendations
{Follow-up actions}
```

**If implementation deviated from plan:** Ask if user wants to update Z01/Z02 to reflect actual work.

---

## Red Flags - You're Failing If:

- **Presenting findings without using AskUserQuestion** ← MOST COMMON FAILURE
- **Running from same context as feature-implement** (need fresh context)
- **Skipping CLAUDE.md** (exists but not read)
- **Not reading Z01/Z02 files**
- **Passive validation instead of adversarial bug hunting**
- **Not finding ANY bugs** (means you didn't look hard enough)
- **Using Edit tool directly instead of invoking superpowers:systematic-debugging**
- **Documenting in Z05 instead of fixing when user chose 'Fix'**
- **Asking "would you like me to..." in prose instead of AskUserQuestion**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Assessment done, I can proceed"** | **NO.** Step 7 requires AskUserQuestion. You have NOT done Step 7 yet. |
| **"User obviously wants fixes, no need to ask"** | **NO.** ALWAYS ask. User might want document-only. Use AskUserQuestion. |
| **"I'll just start fixing, user can stop me"** | **NO.** Ask BEFORE any action. Use AskUserQuestion NOW. |
| **"I can see what user wants, skip AskUserQuestion"** | **NO.** Use AskUserQuestion. Not optional. STOP and ask. |
| **"I'll fix directly with Edit tool"** | **NO.** Invoke superpowers:systematic-debugging. Don't skip root cause analysis. |
| **"Issue is simple, don't need systematic-debugging"** | **NO.** Simple issues have root causes too. Use the skill. |
| **"I'll document in Z05, no need to fix"** | **NO.** User chose 'Fix' = invoke systematic-debugging. |
| "Implementation looks good, skip assessment" | **NO.** ASSUME BUGS EXIST. Hunt for them adversarially. |
| "Code seems correct, just validate it" | **NO.** Don't validate. ATTACK it. Find how to break it. |
| "I remember from feature-implement context" | **NO.** This runs from FRESH context. Hunt for bugs with fresh eyes. |
| "Z01/Z02 not found, skip reading" | **NO.** Try to find them. If truly missing, note it and continue. |
| "Quality check is exploratory, no tracking" | **NO.** 9 mandatory steps with decisions. MUST use TodoWrite. |

## Using "Explain" Option

When user chooses "Explain" during issue loop:

**Purpose:** User provides context about:
- Why code was written this way
- Business requirements not visible in code
- Future plans justifying implementation

**Workflow:**
1. User provides context
2. Re-read code with new context
3. Re-assess issue
4. Present updated assessment
5. Ask again with new understanding

**Document in Z05** with user's context verbatim.

---

## Success Criteria

You followed the workflow if:
- ✓ Ran from fresh context (no feature-implement history)
- ✓ Used git diff to get changed files
- ✓ Read Z01/Z02 files (or noted missing)
- ✓ Hunted for bugs adversarially (not passive validation)
- ✓ Assumed bugs exist, found them
- ✓ Compared against plan (if exists)
- ✓ Used AskUserQuestion (not prose suggestions)
- ✓ Invoked superpowers:systematic-debugging for fixes (not Edit tool directly)
- ✓ Created Z05 documentation with systematic-debugging results
- ✓ Resisted rationalization pressures

## When to Use

- After feature-implement completes (before PR)
- Before merging to main (final quality gate)
- When revisiting old feature branch
- After manual coding without feature-implement
