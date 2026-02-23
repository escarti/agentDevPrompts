---
name: feature-pr-reviewing
description: Use when reviewing pull request changes - follow structured workflow
---

# feature-prreview: PR Review with Research-Driven Analysis

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Verify session is running in Plan mode
2. ☐ Create TodoWrite checklist (see below)
3. ☐ Mark Step 1 as `in_progress`
4. ☐ Switch to PR branch

**If you ran `gh pr view` or `gh pr diff` before switching branches, you FAILED.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Verify Plan mode and stop if unavailable", status: "in_progress", activeForm: "Checking collaboration mode"},
    {content: "Step 1: Extract PR number from user input, switch to PR branch NOW", status: "pending", activeForm: "Switching to PR branch"},
    {content: "Step 2: Read documentation FIRST (CLAUDE.md, README, ARCHITECTURE)", status: "pending", activeForm: "Reading project docs"},
    {content: "Step 3: Get PR details and changed files", status: "pending", activeForm: "Getting PR info"},
    {content: "Step 4: Read changed files to understand code", status: "pending", activeForm: "Reading changed files"},
    {content: "Step 5: Hunt for bugs (adversarial review)", status: "pending", activeForm: "Hunting for bugs"},
    {content: "Step 6: Present EACH finding and collect decision in one pass", status: "pending", activeForm: "Reviewing findings with user"},
    {content: "Step 7: Execute all queued decisions in batch", status: "pending", activeForm: "Posting queued comments"},
    {content: "Step 8: Create Z03 for anything unposted", status: "pending", activeForm: "Finalizing documentation"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

### Step 0: Plan Mode Gate (BLOCKING)

This workflow must run in Plan mode.

If current mode is not Plan mode:
1. STOP immediately
2. Do not perform review steps
3. Report: "feature-pr-reviewing requires Plan mode. Please switch to Plan mode and rerun."

---

### Step 1: Switch to PR Branch NOW

**PR number comes from USER INPUT, not from gh commands.**

User said: "review PR https://github.com/owner/repo/pull/258"
→ PR number is `258`

**Verify current branch and switch:**
```bash
git branch --show-current
gh pr checkout 258
```

**Even if you think you're on the right branch, VERIFY IT FIRST.**

**DO NOT run `gh pr view` to "find the branch name first". The user gave you the PR number. Switch NOW.**

**You MUST be on the PR branch before Step 2. No excuses about "already on it".**

---

### Step 2: Read Documentation FIRST

**You're now on the PR branch.** Establish full context BEFORE looking at changes.

**Read in order:**
1. `CLAUDE.md` (mandatory patterns, forbidden approaches, quality standards)
2. `README.md` (project overview, setup, conventions)
3. `ARCHITECTURE.md` or `docs/architecture/` (system design, component relationships)

**Goal:** Understand project patterns so you can detect when PR review comments violate established architecture.

---

### Step 3: Get PR Details

Get PR metadata and changed files however you want (`gh pr view`, `gh pr diff`, etc.)

You need:
- PR title, author
- **List of changed files** (critical for Step 4)

---

### Step 4: Read Changed Files

**NOW you know what files changed.** Read the changed files to understand what the code does.

**Read the changed files:**
- Use `Read` tool for each changed file from Step 3
- Focus on understanding what the new/modified code is doing
- Note patterns/conventions used in immediate vicinity of changes

**Goal:** Understand the code well enough to find bugs in it.

---

### Step 5: Hunt for Bugs (Adversarial Review)

**ASSUME BUGS EXIST. Your goal: FIND them.**

**Hunt for:**

| Category | Look For |
|----------|----------|
| **Security** | Injection (SQL/XSS/command), auth/authz bypasses, exposed secrets, resource exhaustion, info disclosure |
| **Logic** | Edge cases (null/empty/max), off-by-one, race conditions, state inconsistency, error handling gaps |
| **Quality** | CLAUDE.md violations, inconsistent with codebase patterns (Step 3), silent failures, poor naming |
| **Architecture** | Broken boundaries, layer bypasses, circular deps, contradicts ARCHITECTURE.md |
| **Tests** | Missing coverage, no negative tests, integration gaps, mock overuse |

**How:**
- Ask "what breaks here?" for each line
- Trace data flow: input → validation → processing → output
- Check conditionals: what if opposite?
- Check calls: what if error/null/unexpected?
- Look for what's NOT there: validation, tests, error handling
- Compare to existing patterns (Step 3)

**Document:** file + exact lines, type, severity (`Must-fix` | `Should-fix` | `Nice-to-have`), WHY bug, HOW to trigger, pattern violations

---

### Step 6: Present Findings and Decide (One by One)

Display findings in structured format, one finding at a time.
Do not print Finding 2+ before Finding 1 decision is collected.

```
## PR Review Findings: {PR Title}

Finding 1: {Issue Type} - {Description}
- File: {file}:{line-start}-{line-end}
- Severity: {Must-fix | Should-fix | Nice-to-have}
- Why this is a bug: {impact + broken assumption}
- How to trigger: {minimal repro}
- Suggested PR comment text (ready to post, not vague):
  - Summary: {specific issue in one sentence}
  - Evidence: {file}:{line-start}-{line-end} and what those lines do wrong
  - Impact: {concrete failure/risk}
  - Severity: {Must-fix | Should-fix | Nice-to-have}
```

For EACH finding, run this strict loop:
1. Print only the current finding details.
2. Immediately ask decision for that finding.
3. End the assistant message after that question block.
4. Wait for explicit user decision.
5. Queue action for that finding.
6. Only then move to next finding.

For the decision step, ask user decision and queue it:

```typescript
request_user_input({
  questions: [{
    question: "How should I handle Finding {n}?",
    header: "Finding {n}",
    options: [
      {label: "Post comment", description: "Post this finding as one PR comment in Step 7"},
      {label: "Skip comment", description: "Do not post this finding; continue to next finding"},
      {label: "Stop review cycle", description: "Stop cycling findings now and move to execution/documentation"}
    ]
  }]
})
```

**Decision protocol (required):**
1. Use `request_user_input` for each finding.
2. If `request_user_input` is unavailable, STOP and report: "feature-pr-reviewing requires Plan mode for interactive selection."

Collect decisions in-loop and proceed to Step 7 after loop ends.

**DO NOT ask one global action for all findings.**
**DO NOT execute posting during Step 6. Step 6 is decision collection only.**
**DO NOT print all findings first and ask all questions at the end.**
**DO NOT ask the next finding before receiving a decision for the current one.**
**DO NOT send multiple pending finding questions in one assistant message.**

---

### Step 7: Execute Queued Decisions (Batch)

After Step 6 decision cycle is complete, execute queued actions:
- For each `Post comment`: post exactly ONE PR comment for that ONE finding using `gh pr comment`
- For each `Skip comment`: do not post
- If Step 6 stopped early: do not auto-post remaining unreviewed findings

---

### Step 8: Document Unposted Findings (Z03)

**Mandatory comment format for each posted finding:**
```
[Severity: Must-fix|Should-fix|Nice-to-have] {specific issue summary}

Why this matters:
{concrete impact and failure mode}

Affected code:
- `{file}:{line-start}-{line-end}`: {what this code is doing and why it's wrong/risky}

Suggested change:
{clear and actionable fix direction}
```

**Never post a single combined comment containing multiple findings.**

**Z03 conditional creation:**
- Only create if findings exist that were NOT posted as comments
- If all findings posted → no Z03 needed
- If Step 6 stopped early, include all unreviewed findings in Z03
- If a finding was queued as skip, include it in Z03

**Z03 location:** Scan for existing `Z0[12]_*.md` files to find ongoing directory. Default to `docs/ai/ongoing/`.

**Z03 filename:** `Z03_{kebab-case-pr-title}_review.md`

---


## Red Flags - You're Failing If:

- **Ran `gh pr view` or `gh pr diff` before creating TodoWrite**
- **Ran commands before switching to PR branch**
- **Still on `main` branch when analyzing**
- **Thinking "I'll gather metadata first"**
- **Skipped TodoWrite creation**
- **Reading entire codebase before getting PR details** (Step 3 MUST come before Step 4)
- **Reading files before getting changed file list** (get PR details first)
- **Suggesting next steps instead of running the per-finding decision protocol**
- **Using this skill outside Plan mode**
- **Using free-form prose asks instead of request_user_input**
- **Asking one global action for all findings instead of per-finding decisions**
- **Printing all findings before asking decisions**
- **Asking multiple finding decisions without waiting between them**
- **Sending multiple pending finding questions in one message**
- **Executing comments before completing the per-finding decision cycle**
- **Posting multiple findings in one combined PR comment**
- **Posting vague comments without concrete file-line evidence**
- **Drafting comments but not posting them**
- **Passive review instead of adversarial bug hunting**
- **Not finding ANY bugs** (means you didn't look hard enough)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Get PR details first to know branch"** | **NO.** PR number in USER INPUT. Extract, switch NOW. |
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. Run `git branch --show-current`. |
| **"Run gh pr view to find branch name"** | **NO.** `gh pr checkout {number}` does that. Switch NOW. |
| **"Skip docs/reading files, I can see changes"** | **NO.** Need to read code to find bugs. |
| **"Read whole codebase before checking PR"** | **NO.** Get PR details FIRST (Step 3), then read changed files ONLY (Step 4). |
| **"Time pressure = skip workflow"** | **NO.** Workflow is FASTER than ad-hoc. Follow it. |
| "TodoWrite wastes time" | **NO.** TodoWrite prevents mistakes that waste MORE time. |
| "I'll offer helpful next steps in text" | **NO.** Use request_user_input per finding in Plan mode. |
| "Findings presented, I can proceed" | **NO.** During Step 6, ask decision per finding and queue it. |
| "I'll ask one question for all findings" | **NO.** Must ask decision per finding. No bundling. |
| "I'll list all findings first, then ask at end" | **NO.** Show one finding, ask immediately, wait, then continue. |
| "I can ask all finding decisions in one message" | **NO.** One finding question at a time, wait for explicit answer. |
| "I'll ask, then continue writing context for later findings" | **NO.** End message right after the current finding question block. |
| "I can post while I ask" | **NO.** Finish Step 6 decision cycle first, then execute in Step 7. |
| "I can post one summary comment for everything" | **NO.** One accepted finding = one PR comment. No combined comment. |
| "Short generic comments are fine" | **NO.** Include concrete impact + exact file and line range evidence. |
| "I drafted comments, that's enough" | **NO.** Draft ≠ posted. Execute `gh pr comment`. |
| "Code looks correct, just confirm it" | **NO.** Don't confirm. ATTACK it. Find how to break it. |
| "ASSUME BUGS EXIST. Hunt adversarially" | **NO.** ASSUME BUGS EXIST. Hunt for them adversarially. |
| "Changes are simple, quick review" | **NO.** Simple code hides subtle bugs. Hunt line-by-line. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read documentation (CLAUDE.md, README, ARCHITECTURE) from PR branch
- ✓ Got PR details and changed files list BEFORE exploring
- ✓ Read ONLY changed files (not entire codebase)
- ✓ Hunted for bugs adversarially (not passive validation)
- ✓ Assumed bugs exist, found them
- ✓ Analyzed changes with full repo context awareness
- ✓ Ran in Plan mode and used request_user_input for per-finding interaction
- ✓ Asked for a decision for EACH finding during Step 6 (no global-action shortcut)
- ✓ Presented and decided findings in strict sequence: one finding -> one decision -> next finding
- ✓ Never had more than one pending finding decision at a time
- ✓ Completed decision collection cycle before executing posts
- ✓ Posted one PR comment per accepted finding (no combined comment)
- ✓ Each posted comment includes severity (`Must-fix`, `Should-fix`, or `Nice-to-have`)
- ✓ Each posted comment includes affected file and exact line range evidence
- ✓ Posted comments with actual commands (not drafts)
- ✓ Created Z03 documentation (if needed)
- ✓ Resisted all rationalizations
