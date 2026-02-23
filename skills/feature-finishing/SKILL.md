---
name: feature-finishing
description: Use after feature-implementing completes - performs final quality check from fresh context
---

# feature-finish: Final Quality Check Before Merge

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Verify session is running in Plan mode
2. ☐ Create TodoWrite checklist (see below)
3. ☐ Mark Step 0 as `in_progress`
4. ☐ Confirm you're on a feature branch (not main)

**This skill runs from FRESH context. If you have feature-implement conversation history, you're doing it wrong.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Verify Plan mode and stop if unavailable", status: "in_progress", activeForm: "Checking collaboration mode"},
    {content: "Step 1: Get current branch and changed files", status: "pending", activeForm: "Getting git status"},
    {content: "Step 2: Read CLAUDE.md", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Load Z01/Z02 plan files", status: "pending", activeForm: "Reading plan docs"},
    {content: "Step 4: Hunt for bugs (adversarial assessment)", status: "pending", activeForm: "Hunting for bugs"},
    {content: "Step 5: Compare against plan", status: "pending", activeForm: "Checking deviations"},
    {content: "Step 6: Run PR-style code review on branch diff", status: "pending", activeForm: "Reviewing like PR reviewer"},
    {content: "Step 7: Run security-focused review pass", status: "pending", activeForm: "Reviewing with security mindset"},
    {content: "Step 8: Present findings", status: "pending", activeForm: "Formatting summary"},
    {content: "Step 9: Ask user what to do (Codex-first decision protocol)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 10: Execute user choice", status: "pending", activeForm: "Applying fixes"},
    {content: "Step 11: Create Z05 finish documentation", status: "pending", activeForm: "Writing Z05"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

### Step 0: Plan Mode Gate (BLOCKING)

This workflow must run in Plan mode.

If current mode is not Plan mode:
1. STOP immediately
2. Do not run finishing steps
3. Report: "feature-finishing requires Plan mode. Please switch to Plan mode and rerun."

---

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

**ASSUME BUGS EXIST. Your job: FIND them.**

Don't ask "is this correct?" Ask "how can I break this?"

**Hunt for:**

| Category | Look For |
|----------|----------|
| **Security** | Injection (SQL/XSS/command), auth/authz bypasses, exposed secrets, resource exhaustion |
| **Logic** | Edge cases (null/empty/max), off-by-one, race conditions, error handling gaps, happy-path assumptions |
| **Quality** | CLAUDE.md violations, inconsistent with codebase, silent failures, poor naming |
| **Tests** | Untested paths, missing negative tests, integration gaps |
| **Plan** | Z02 deviations, scope creep, unintentional changes |

**How:**
- Ask "what breaks here?" for each line
- Trace: input → processing → output
- Check conditionals: what if opposite?
- Check calls: what if error/null?
- Look for what's NOT there: validation, tests, error handling

**Document:** file:line, type, severity, WHY bug, HOW to trigger

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

### Step 6: Run PR-Style Code Review

**Do a second pass specifically as an external PR reviewer.**

Goal: minimize follow-up PR findings before opening/updating the PR.

How:
- Review `git diff main` changed files as if this were a PR review.
- Re-check for architecture/style/testing issues reviewers usually flag (naming, layering, error handling, test quality, consistency with project patterns).
- Reuse the adversarial approach from Step 4, but focus on what maintainers would comment on in review.
- Merge and de-duplicate findings from Steps 4-5 with this review pass.

Document additional findings with: file:line, type, severity, WHY issue, HOW reviewer would detect it.

---

### Step 7: Run Security-Focused Review Pass

**Do a third pass from the perspective of a security engineer.**

Goal: surface vulnerabilities likely to be caught in AppSec/SAST/penetration review before PR feedback.

How:
- Re-read `git diff main` and trace trust boundaries (user input, external services, file system, shell/database calls, auth/session paths).
- Look for exploitability, not just code quality: injection, auth bypass, privilege escalation, insecure defaults, secret leakage, unsafe deserialization, SSRF/path traversal, DoS vectors.
- Validate security controls exist and are enforced: input validation, output encoding, least privilege, rate limiting, audit logging, secure error handling.
- Include abuse cases: "how can an attacker trigger this?" for every externally reachable path.
- Merge and de-duplicate findings from Steps 4-6 with this security pass.

Document additional findings with: file:line, type, severity, WHY vulnerable, HOW to exploit, impact.

---

### Step 8: Present Findings

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

**DO NOT suggest next steps. Proceed immediately to Step 9.**

---

### Step 9: Ask User What To Do

**STOP. Run the Codex-first decision protocol NOW.**

**If you haven't asked the user yet, you are at Step 9. Ask NOW.**

```typescript
request_user_input({
  questions: [{
    question: "How would you like to handle these findings?",
    header: "Action",
    options: [
      {label: "Fix all", description: "Automatically fix all issues using Edit tool"},
      {label: "Loop issues", description: "Go through each issue, decide fix/skip/explain individually"},
      {label: "Document only", description: "Save findings to Z05 file without making changes"}
    ]
  }]
})
```

**Codex-first decision protocol (required):**
1. Use `request_user_input` when available.
2. If `request_user_input` is unavailable and runtime supports `AskUserQuestion`, use `AskUserQuestion`.
3. If neither tool is available, ask in prose with strict choices:
   - `How would you like to handle these findings? Reply with 1, 2, or 3.`
   - `1) Fix all`
   - `2) Loop issues`
   - `3) Document only`
   - Accept only explicit `1|2|3` (or exact label). If unclear, ask once to clarify.

**Wait for user response before Step 10.**

---

### Step 10: Execute User Choice

**If "Fix all":**

Invoke `superpowers:systematic-debugging` with ALL findings. Track report for Z05.

---

**If "Loop issues":**

For each issue, run a strict one-by-one cycle:
1. Show only the current issue details (`Issue {n}` with file, severity, impact, and why).
2. Immediately ask decision for that issue.
3. End the assistant message after that question block.
4. Wait for explicit user decision.
5. Execute/record decision for that issue.
6. Only then move to the next issue.

For each issue decision, use:
```typescript
request_user_input({
  questions: [{
    question: "How should I handle Issue {n}?",
    header: "Issue {n}",
    options: [
      {label: "Fix issue", description: "Apply a fix for this issue now"},
      {label: "Skip issue", description: "Leave this issue unfixed and continue"},
      {label: "Explain issue", description: "I will provide context before deciding"},
      {label: "Stop cycle", description: "Stop issue loop now and continue to documentation"}
    ]
  }]
})
```

Fallback when structured input is unavailable:
- `How should I handle Issue {n}? Reply with 1, 2, 3, or 4.`
- `1. Fix issue`
- `2. Skip issue`
- `3. Explain issue`
- `4. Stop cycle`
- Accept only explicit `1|2|3|4` (or exact label). If unclear, ask once to clarify.
- After asking, stop output. Do not include later issues/questions in the same message.

- **Fix**: Invoke `superpowers:systematic-debugging` for this issue
- **Explain**: User provides context → update assessment → ask again

---

**If "Document only":**

Skip to Step 11.

---

### Step 11: Create Z05 Documentation

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

- **Presenting findings without running the Codex-first decision protocol** ← MOST COMMON FAILURE
- **Ran this skill outside Plan mode**
- **Running from same context as feature-implement** (need fresh context)
- **Skipping CLAUDE.md** (exists but not read)
- **Not reading Z01/Z02 files**
- **Passive validation instead of adversarial bug hunting**
- **Skipping Step 6 PR-style code review pass**
- **Skipping Step 7 security-focused review pass**
- **Not finding ANY bugs** (means you didn't look hard enough)
- **Using Edit tool directly instead of invoking superpowers:systematic-debugging**
- **Documenting in Z05 instead of fixing when user chose 'Fix'**
- **Asking "would you like me to..." in free-form prose without strict options**
- **Loop issues mode but presenting all issues first**
- **Loop issues mode with multiple pending issue questions at once**
- **Moving to next issue before current issue decision is explicit**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Assessment done, I can proceed"** | **NO.** Step 9 requires the Codex-first decision protocol. You have NOT done Step 9 yet. |
| **"Step 4 bug hunt is enough, skip PR-style review"** | **NO.** Step 6 is mandatory to reduce follow-up PR findings. |
| **"Security was covered already, skip security pass"** | **NO.** Step 7 is mandatory and uses a dedicated attacker mindset. |
| **"User obviously wants fixes, no need to ask"** | **NO.** ALWAYS ask. User might want document-only. Run the decision protocol. |
| **"I'll just start fixing, user can stop me"** | **NO.** Ask BEFORE any action. Run the decision protocol NOW. |
| **"I can see what user wants, skip asking"** | **NO.** Asking is not optional. STOP and ask. |
| **"I'll fix directly with Edit tool"** | **NO.** Invoke superpowers:systematic-debugging. Don't skip root cause analysis. |
| **"Issue is simple, don't need systematic-debugging"** | **NO.** Simple issues have root causes too. Use the skill. |
| **"I'll document in Z05, no need to fix"** | **NO.** User chose 'Fix' = invoke systematic-debugging. |
| **"I'll show all issues, then ask decisions at the end"** | **NO.** In Loop issues mode, issue-by-issue only. |
| **"I'll ask all issue decisions in one message"** | **NO.** One pending issue decision at a time. |
| "Implementation looks good, skip assessment" | **NO.** ASSUME BUGS EXIST. Hunt for them adversarially. |
| "Code seems correct, just validate it" | **NO.** Don't validate. ATTACK it. Find how to break it. |
| "I remember from feature-implement context" | **NO.** This runs from FRESH context. Hunt for bugs with fresh eyes. |
| "Z01/Z02 not found, skip reading" | **NO.** Try to find them. If truly missing, note it and continue. |
| "Quality check is exploratory, no tracking" | **NO.** 11 mandatory steps with decisions. MUST use TodoWrite. |


## Success Criteria

You followed the workflow if:
- ✓ Ran from fresh context (no feature-implement history)
- ✓ Verified session was in Plan mode before Step 1
- ✓ Used git diff to get changed files
- ✓ Read Z01/Z02 files (or noted missing)
- ✓ Hunted for bugs adversarially (not passive validation)
- ✓ Assumed bugs exist, found them
- ✓ Compared against plan (if exists)
- ✓ Ran a PR-style review pass to catch likely reviewer feedback
- ✓ Ran a security-focused review pass to catch vulnerabilities before PR feedback
- ✓ Used Codex-first decision protocol (request_user_input first, AskUserQuestion compatibility fallback, strict prose fallback)
- ✓ In Loop issues mode, used strict sequence: one issue -> one decision -> next issue
- ✓ Never had more than one pending issue decision at a time
- ✓ Invoked superpowers:systematic-debugging for fixes (not Edit tool directly)
- ✓ Created Z05 documentation with systematic-debugging results
- ✓ Resisted rationalization pressures

## When to Use

- After feature-implement completes (before PR)
- Before merging to main (final quality gate)
- When revisiting old feature branch
- After manual coding without feature-implement
