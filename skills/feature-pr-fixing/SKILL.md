---
name: feature-pr-fixing
description: Use when addressing PR review comments - follow structured workflow
---

# feature-prfix: Address PR Review Comments with Research-Driven Assessment

## ⚠️ STOP - READ THIS FIRST ⚠️

**YOU ARE LOADING THIS SKILL RIGHT NOW.**

Before taking ANY action:

1. ☐ Verify session is running in Plan mode
2. ☐ Create TodoWrite (exact template below)
3. ☐ Mark Step 0 as `in_progress`
4. ☐ Execute Step 0

**If you ran `gh pr view`, `gh api`, or ANY command before TodoWrite: YOU FAILED THE IRON LAW.**

## The Iron Law (Low Freedom - Exact Compliance Required)

```
NO COMMANDS BEFORE TODOWRITE
ZERO EXCEPTIONS
```

This is not a guideline. This is not flexible. This is a fragile operation requiring exact sequence.

**Validation:** Did you create TodoWrite before running ANY bash command? Yes/No.

If No → Stop, acknowledge failure, start over.

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Verify Plan mode and stop if unavailable", status: "in_progress", activeForm: "Checking collaboration mode"},
    {content: "Step 1: Switch to PR branch", status: "pending", activeForm: "Switching to PR branch"},
    {content: "Step 2: Read documentation FIRST (AGENTS.md, CLAUDE.md, README, ARCHITECTURE)", status: "pending", activeForm: "Reading project docs"},
    {content: "Step 3: Get PR details and review comments", status: "pending", activeForm: "Getting PR info"},
    {content: "Step 4: Read changed files and comment context", status: "pending", activeForm: "Reading code files"},
    {content: "Step 5: Assess ALL UNANSWERED OR UNFIXED comments using repo context and pattern awareness", status: "pending", activeForm: "Assessing validity"},
    {content: "Step 6: Present EACH comment and collect decision in one pass", status: "pending", activeForm: "Reviewing comments with user"},
    {content: "Step 7: Execute all queued comment decisions in batch", status: "pending", activeForm: "Applying queued actions"},
    {content: "Step 8: Create Z04 for anything unhandled", status: "pending", activeForm: "Finalizing documentation"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

### Step 0: Plan Mode Gate (BLOCKING)

This workflow must run in Plan mode.

If current mode is not Plan mode:
1. STOP immediately
2. Do not run Step 1+
3. Report: "feature-pr-fixing requires Plan mode. Please switch to Plan mode and rerun."

---

### Step 1: Switch to PR Branch

**Extract PR number from URL** (e.g., `/pull/258` → `258`)

**Verify current branch and switch if needed:**
```bash
git branch --show-current
gh pr checkout 258
```

**Even if you think you're on the right branch, VERIFY IT FIRST.**

**You MUST be on the PR branch before Step 2. No excuses about "already on it".**

---

### Step 2: Read Documentation FIRST

**You're now on the PR branch.** Establish full context BEFORE reading review comments.

**Read in order:**
1. `AGENTS.md` (default repo rules, patterns, quality standards)
2. `CLAUDE.md` (Claude-specific patterns, forbidden approaches, quality standards)
3. `README.md` (project overview, setup, conventions)
4. `ARCHITECTURE.md` or `docs/architecture/` (system design, component relationships)

**Goal:** Understand project patterns so you can detect when review comments conflict with established architecture.

---

### Step 3: Get PR Details and Comments

Get PR metadata and **UNRESOLVED, CURRENT** review comments with:
- Comment ID (needed for replies), file:line, comment text, reviewer
- **List of changed files** (critical for Step 4)

**CRITICAL FILTERING:**
- **ONLY UNRESOLVED** (not marked resolved by reviewer)
- **ONLY CURRENT** (not outdated after force-push)
- **SKIP resolved or outdated**

**If no unresolved comments**: "No unresolved review comments. Nothing to address."

---

### Step 4: Read Changed Files and Comment Context

**NOW you know what files changed and which have review comments.** Read the relevant files to understand the code.

**Read the files:**
- Use `Read` tool for each changed file from Step 3
- Use `Read` tool for files mentioned in review comments
- Focus on understanding what the code is doing
- Note patterns/conventions used in immediate vicinity of changes

**Goal:** Understand the code well enough to assess whether review comments are valid.

---

### Step 5: Assess ALL UNANSWERED OR UNFIXED Comments Using Repo Context

**For each comment, determine:**

**Valid?**
- Real bug/security/violates AGENTS.md, CLAUDE.md, or architecture → **VALID (fix)**
- Style preference/conflicts with project conventions → **INVALID (refute)**

**Category:** Bug | Security | Architecture | Style | Convention

**Reasoning:** Reference docs (`AGENTS.md`, `CLAUDE.md`, `ARCHITECTURE`) and code patterns from Step 3. Explain WHY.

**Action:** Fix | Refute | Discuss

**Use your judgment.** You have the context. Apply it rigorously.

---

### Step 6: Present Assessments and Decide (One Comment at a Time)

Display comments with AI assessment, one comment at a time:

```
## PR Review Comment Assessment: {PR Title}

Comment 1: {Reviewer comment text}
- File: {file}:{line}
- Reviewer: @{username}
- Assessment: Valid / Invalid
- Category: {bug|security|style|subjective}
- Reasoning: {technical explanation}
- Suggested action: Fix / Refute / Discuss

Comment 2: ...

Summary:
- Valid (should fix): {count}
- Invalid (should refute): {count}
- Discuss: {count}
```

For EACH comment, immediately ask user decision and queue it:

```typescript
request_user_input({
  questions: [{
    question: "How should I handle Comment {n}?",
    header: "Comment {n}",
    options: [
      {label: "Queue fix", description: "Queue code fix for this comment in Step 7"},
      {label: "Queue refute", description: "Queue in-thread technical reply for this comment in Step 7"},
      {label: "Queue skip", description: "Leave this comment unhandled and continue"},
      {label: "Stop review cycle", description: "Stop cycling comments now and move to execution/documentation"}
    ]
  }]
})
```

**Decision protocol for Step 6 (Plan mode required):**
1. Use `request_user_input` for each comment.
2. If `request_user_input` is unavailable, STOP and report: "Step 6 requires Plan mode interactive selection."

Collect decisions for all reviewed comments, then proceed to Step 7.

**DO NOT bundle all comments into one decision request.**
**DO NOT execute fixes/refutations during Step 6. Step 6 is decision collection only.**

---

### Step 7: Execute Queued Decisions (Batch)

After Step 6 decision cycle is complete, execute queued actions:
- For each `Queue fix`:
1. Invoke `superpowers:systematic-debugging` with context (PR, file, comment, assessment)
2. Test the fix (run relevant tests, verify behavior)
3. Commit with descriptive message: `git commit -m "Fix: [comment summary] - [what changed]"`
- For each `Queue refute`:
1. Post refutation using `gh api` (see "Replying to Review Comments" section)
- For each `Queue skip`: do not fix/refute
- If Step 6 stopped early: do not auto-handle remaining unreviewed comments

After all queued actions executed:
1. Push all commits once: `git push`

---

### Step 8: Document Unhandled Comments (Z04)

**Z04 File Creation (Conditional):**

- If user stops before completing: **CREATE Z04** with remaining unhandled comments
- If all comments fixed/refuted and none remain unreviewed: **NO Z04 file**
- If a comment was queued as skip: include it in Z04
- If Step 6 stopped early: include all unreviewed comments in Z04

**Z04 conditional creation:**
- Only create if comments exist that were NOT fixed or refuted
- If all comments are fixed/refuted and none are skipped/unreviewed → no Z04 needed

**Z04 location:** Scan for existing `Z0[12]_*.md` files to find ongoing directory. Default to `docs/ai/ongoing/`.

**Z04 filename:** `Z04_{kebab-case-pr-title}_fix.md`

---

## Replying to Review Comments

**CRITICAL:** Use `gh api` for replies, NOT `gh pr comment`.

**Post reply to existing comment:**
```bash
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments \
  -X POST \
  -f body="Your reply text here" \
  -F in_reply_to={COMMENT_ID}
```

**Get values:**
- OWNER/REPO: `gh repo view --json nameWithOwner --jq .nameWithOwner` → returns "owner/repo"
- PR_NUM: From Step 1 (e.g., 281)
- COMMENT_ID: From Step 4 (e.g., 2519198568)

**Example:**
```bash
gh api repos/new-work/insights-etl/pulls/281/comments \
  -X POST \
  -f body="Thank you for the feedback. Current approach is better because..." \
  -F in_reply_to=2519198568
```

**Key points:**
- Endpoint: `/pulls/{PR_NUM}/comments` (PR number in path)
- Use `-F in_reply_to=` for integer comment ID (NOT in URL)
- Use `-f body=` for string reply text

**Refutation template:**
```
Thank you for the feedback. I've assessed this and believe [current approach] is better because:
1. [Technical reason with evidence]
2. [Reference to AGENTS.md, CLAUDE.md, or an existing pattern]
3. [Cost/benefit analysis]

Happy to discuss further if there's context I'm missing.
```

---

## Red Flags - You're Failing If:

- **Ran `gh pr view` before creating TodoWrite**
- **Ran commands before switching to PR branch**
- **Still on different branch when fixing code**
- **Skipped TodoWrite creation**
- **Skipped reading documentation (AGENTS.md, CLAUDE.md, README, ARCHITECTURE)**
- **Reading entire codebase before getting PR details** (Step 3 MUST come before Step 4)
- **Reading files before getting changed file list** (get PR details first)
- **Processing resolved or outdated comments**
- **Not filtering comments by resolution status**
- **Re-fixing already addressed issues from previous rounds**
- **Ran this skill outside Plan mode**
- **Suggesting next steps instead of running the per-comment decision protocol**
- **Asking one global action for all comments instead of per-comment decisions**
- **Executing fixes/refutations before completing the per-comment decision cycle**
- **Using `gh pr comment` instead of `gh api .../replies`**
- **Using Edit tool directly instead of invoking superpowers:systematic-debugging**
- **Drafting refutations but not posting them**
- **Accepting all comments without verifying against project patterns**
- **Assessing comments without understanding codebase context**
- **Applied fixes but didn't commit changes**
- **Applied fixes but didn't push to remote branch**
- **Committed all fixes in one batch instead of after each fix**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"I'll check PR first to understand scope"** | **NO.** TodoWrite FIRST. No commands before TodoWrite. Zero exceptions. |
| **"Need context before creating TodoWrite"** | **NO.** TodoWrite doesn't need context. Create from skill steps, THEN gather context. |
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. Run `git branch --show-current`. |
| **"Process all comments, including resolved"** | **NO.** ONLY unresolved. Filter resolved/outdated FIRST. |
| **"Senior engineer knows best, just fix all"** | **NO.** Senior engineers miss project patterns. Verify against docs. |
| **"Skip docs/reading files, I know patterns"** | **NO.** Memory fades. Read code before assessment. |
| **"Read whole codebase before checking PR"** | **NO.** Get PR details FIRST (Step 3), then read changed files ONLY (Step 4). |
| **"Not worth arguing about style"** | **NO.** Style changes have cost. Require justification. |
| **"Faster to fix than debate"** | **NO.** Blind fixes accumulate debt. Assess with full context first. |
| **"I can run this in Default mode from the start"** | **NO.** This skill requires Plan mode. |
| **"Don't want to seem difficult"** | **NO.** Technical discussion is normal. Respectful refutation is professional. |
| **"Use gh pr comment to post reply"** | **NO.** Use `gh api .../replies` to reply in thread. |
| **"I'll fix directly with Edit tool"** | **NO.** Invoke superpowers:systematic-debugging. Don't skip root cause. |
| "Assessments done, I can proceed" | **NO.** During Step 6, ask decision per comment and queue it. |
| "I can pick one action for all comments" | **NO.** Ask decision per comment. No bundling. |
| "I can execute while I ask" | **NO.** Finish Step 6 decision cycle first, then execute in Step 7. |
| "I drafted refutation, that's enough" | **NO.** Draft ≠ posted. Execute `gh api` command. |
| **"I'll simulate user choice"** | **NO.** Use request_user_input per comment in Step 6. Don't assume what user wants. |
| **"systematic-debugging handles commits"** | **NO.** You must explicitly commit after each fix is tested. |
| **"I'll commit all fixes at once at the end"** | **NO.** Commit after testing each individual fix for atomic history. |
| **"I'll push after each commit"** | **NO.** Batch push once at end of Step 7 for efficiency. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read documentation (AGENTS.md, CLAUDE.md, README, ARCHITECTURE) from PR branch
- ✓ Got PR details and review comments BEFORE exploring
- ✓ Read ONLY changed files and comment context (not entire codebase)
- ✓ Assessed ALL comments using full repo context
- ✓ Verified reviewer claims against project patterns
- ✓ Verified session was in Plan mode before Step 1
- ✓ Used request_user_input for per-comment decisions in Step 6
- ✓ Asked for a decision for EACH comment during Step 6 (no global-action shortcut)
- ✓ Completed decision collection cycle before executing queued actions
- ✓ Invoked superpowers:systematic-debugging for valid fixes (not Edit tool directly)
- ✓ Committed each fix individually after testing
- ✓ Pushed all commits to PR branch at end of Step 7
- ✓ Posted refutations with `gh api .../replies` (not `gh pr comment`)
- ✓ Verified replies posted in correct threads
- ✓ Created Z04 documentation (if needed)
- ✓ Resisted authority/agreeableness pressures
