---
name: feature-pr-fixing
description: Use when addressing PR review comments - follow structured workflow
---

# feature-prfix: Address PR Review Comments with Research-Driven Assessment

## ⚠️ STOP - READ THIS FIRST ⚠️

**YOU ARE LOADING THIS SKILL RIGHT NOW.**

Before taking ANY action:

1. ☐ Create TodoWrite (exact template below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Execute Step 1

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
    {content: "Step 1: Switch to PR branch", status: "in_progress", activeForm: "Switching to PR branch"},
    {content: "Step 2: Read documentation FIRST (CLAUDE.md, README, ARCHITECTURE)", status: "pending", activeForm: "Reading project docs"},
    {content: "Step 3: Explore codebase (glob, grep, read files)", status: "pending", activeForm: "Analyzing codebase"},
    {content: "Step 4: Get PR details and review comments", status: "pending", activeForm: "Getting PR info"},
    {content: "Step 5: Assess ALL comments using repo context and pattern awareness", status: "pending", activeForm: "Assessing validity"},
    {content: "Step 6: Present assessments", status: "pending", activeForm: "Presenting findings"},
    {content: "Step 7: Ask user what to do (AskUserQuestion)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 8: Execute user choice", status: "pending", activeForm: "Executing action"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

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
1. `CLAUDE.md` (mandatory patterns, forbidden approaches, quality standards)
2. `README.md` (project overview, setup, conventions)
3. `ARCHITECTURE.md` or `docs/architecture/` (system design, component relationships)

**Goal:** Understand project patterns so you can detect when review comments conflict with established architecture.

---

### Step 3: Explore Codebase

**Follow Steps 2-3 from feature-pr-reviewing** to build mental model:
- Use Task tool with subagent_type=Explore
- Focus on changed areas related to PR files
- Alternative: Manual exploration with glob/grep/Read

**Goal:** Know how things are SUPPOSED to be done, so you can identify when review comments suggest anti-patterns or violate project architecture.

---

### Step 4: Get PR Details and Comments

Get PR metadata and **UNRESOLVED, CURRENT** review comments with:
- Comment ID (needed for replies), file:line, comment text, reviewer

**CRITICAL FILTERING:**
- **ONLY UNRESOLVED** (not marked resolved by reviewer)
- **ONLY CURRENT** (not outdated after force-push)
- **SKIP resolved or outdated**

**If no unresolved comments**: "No unresolved review comments. Nothing to address."

---

### Step 5: Assess ALL Comments Using Repo Context

**For each comment, determine:**

**Valid?**
- Real bug/security/violates CLAUDE.md/architecture → **VALID (fix)**
- Style preference/conflicts with project conventions → **INVALID (refute)**

**Category:** Bug | Security | Architecture | Style | Convention

**Reasoning:** Reference docs (CLAUDE.md, ARCHITECTURE) and code patterns from Step 3. Explain WHY.

**Action:** Fix | Refute | Discuss

**Use your judgment.** You have the context. Apply it rigorously.

---

### Step 6: Present Assessments

Display all comments with AI assessment:

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

**DO NOT suggest next steps. Proceed immediately to Step 7.**

---

### Step 7: Ask User What To Do

**STOP. Use AskUserQuestion tool NOW.**

```typescript
AskUserQuestion({
  questions: [{
    question: "How would you like to handle these review comments?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Auto: fix valid, refute invalid", description: "Automatically apply fixes and post refutations based on AI assessment"},
      {label: "Review per-comment", description: "Go through each comment, decide fix/refute/skip individually"},
      {label: "Document only", description: "Save assessments to Z04 file without applying changes"}
    ]
  }]
})
```

**Wait for user response before Step 8.**

---

### Step 8: Execute User Choice

**If "Auto: fix valid, refute invalid":**

For VALID comments: Invoke `superpowers:systematic-debugging` with context (PR, file, comment, assessment).

For INVALID comments: Post refutation using `gh api` (see "Replying to Review Comments" section).

---

**If "Review per-comment":**

Loop through comments with AskUserQuestion offering: Fix / Refute / Explain / Skip / Stop.

- **Fix**: Invoke `superpowers:systematic-debugging`
- **Refute**: Post via `gh api`
- **Explain**: User provides context → update assessment → ask again

---

**Z04 File Creation (Conditional):**

**If "Auto: fix valid, refute invalid":**
- All comments fixed or refuted → **NO Z04 file**

**If "Review per-comment":**
- If user stops before completing: **CREATE Z04** with remaining unhandled comments
- If all comments fixed/refuted/skipped: **NO Z04 file**

**If "Document only":**
- **CREATE Z04 file** with all assessments (nothing fixed/refuted)

**Z04 conditional creation:**
- Only create if comments exist that were NOT fixed or refuted
- If all comments handled → no Z04 needed

**Z04 location:** Scan for existing `Z0[12]_*.md` files to find ongoing directory. Default to `docs/ai/ongoing/`.

**Z04 filename:** `Z04_{kebab-case-pr-title}_fix.md`

---

## Replying to Review Comments

**CRITICAL:** Use `gh api` for replies, NOT `gh pr comment`:

```bash
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments/{COMMENT_ID}/replies \
  -X POST \
  -f body="Your reply text here"
```

**Get values:**
- OWNER/REPO: `gh repo view --json nameWithOwner --jq .nameWithOwner`
- PR_NUM: From Step 1
- COMMENT_ID: From Step 4

**Refutation template:**
```
Thank you for the feedback. I've assessed this and believe [current approach] is better because:
1. [Technical reason with evidence]
2. [Reference to CLAUDE.md or existing pattern]
3. [Cost/benefit analysis]

Happy to discuss further if there's context I'm missing.
```

---

## Red Flags - You're Failing If:

- **Ran `gh pr view` before creating TodoWrite**
- **Ran commands before switching to PR branch**
- **Still on different branch when fixing code**
- **Skipped TodoWrite creation**
- **Skipped reading documentation (CLAUDE.md, README, ARCHITECTURE)**
- **Skipped codebase exploration**
- **Processing resolved or outdated comments**
- **Not filtering comments by resolution status**
- **Re-fixing already addressed issues from previous rounds**
- **Suggesting next steps instead of using AskUserQuestion**
- **Using `gh pr comment` instead of `gh api .../replies`**
- **Using Edit tool directly instead of invoking superpowers:systematic-debugging**
- **Drafting refutations but not posting them**
- **Accepting all comments without verifying against project patterns**
- **Assessing comments without understanding codebase context**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"I'll check PR first to understand scope"** | **NO.** TodoWrite FIRST. No commands before TodoWrite. Zero exceptions. |
| **"Need context before creating TodoWrite"** | **NO.** TodoWrite doesn't need context. Create from skill steps, THEN gather context. |
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. Run `git branch --show-current`. |
| **"Process all comments, including resolved"** | **NO.** ONLY unresolved. Filter resolved/outdated FIRST. |
| **"Senior engineer knows best, just fix all"** | **NO.** Senior engineers miss project patterns. Verify against docs. |
| **"Skip docs/exploration, I know patterns"** | **NO.** Memory fades. Verify actual patterns before assessment. |
| **"Not worth arguing about style"** | **NO.** Style changes have cost. Require justification. |
| **"Faster to fix than debate"** | **NO.** Blind fixes accumulate debt. Assess with full context first. |
| **"Don't want to seem difficult"** | **NO.** Technical discussion is normal. Respectful refutation is professional. |
| **"Use gh pr comment to post reply"** | **NO.** Use `gh api .../replies` to reply in thread. |
| **"I'll fix directly with Edit tool"** | **NO.** Invoke superpowers:systematic-debugging. Don't skip root cause. |
| "Assessments done, I can proceed" | **NO.** Step 7 requires AskUserQuestion. Use it NOW. |
| "I drafted refutation, that's enough" | **NO.** Draft ≠ posted. Execute `gh api` command. |
| **"I'll simulate user choice"** | **NO.** Use AskUserQuestion tool. Don't assume what user wants. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read documentation (CLAUDE.md, README, ARCHITECTURE) from PR branch
- ✓ Explored codebase to understand patterns
- ✓ Assessed ALL comments using full repo context
- ✓ Verified reviewer claims against project patterns
- ✓ Used AskUserQuestion (not prose suggestions)
- ✓ Invoked superpowers:systematic-debugging for valid fixes (not Edit tool directly)
- ✓ Posted refutations with `gh api .../replies` (not `gh pr comment`)
- ✓ Verified replies posted in correct threads
- ✓ Created Z04 documentation (if needed)
- ✓ Resisted authority/agreeableness pressures
