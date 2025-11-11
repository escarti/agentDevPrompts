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
    {content: "Step 2: Read CLAUDE.md from PR branch", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Get PR details and review comments", status: "pending", activeForm: "Getting PR info"},
    {content: "Step 4: Assess ALL comments with feature-research (once)", status: "pending", activeForm: "Assessing validity"},
    {content: "Step 5: Present assessments", status: "pending", activeForm: "Presenting findings"},
    {content: "Step 6: Ask user what to do (AskUserQuestion)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 7: Execute user choice", status: "pending", activeForm: "Executing action"}
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

### Step 2: Read CLAUDE.md

**You're now on the PR branch.** Read `CLAUDE.md` if it exists.

Look for:
- Mandatory patterns that MUST be preserved
- Forbidden approaches
- Project conventions

You'll use this to validate whether reviewer comments align with project standards.

---

### Step 3: Get PR Details and Comments

Get PR metadata and review comments however you want (`gh pr view`, `gh pr view --comments`, etc.)

You need:
- PR title, author, branch
- **All review comments** with:
  - Comment ID (CRITICAL - needed for replies)
  - File path and line number
  - Comment body text
  - Reviewer username

**If no comments**: "No review comments. Nothing to address."

**Save comment IDs** - you need them to reply in the correct thread.

---

### Step 4: Assess ALL Comments with feature-research

**Use Skill tool to invoke `feature-workflow:feature-researching` ONCE with ALL comments.**

Give it:
- List of ALL review comments with file paths/lines
- Full comment text from each reviewer
- CLAUDE.md constraints (if exists)
- Request: "Assess each PR review comment. Determine if it identifies a real bug/security issue or is subjective style preference. Consider CLAUDE.md patterns. Provide technical reasoning for each."

Parse research output to generate for each comment:
- Is claim valid? (real bug vs subjective)
- Category (bug/security/style/subjective)
- Technical reasoning

---

### Step 5: Present Assessments

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

**DO NOT suggest next steps. Proceed immediately to Step 6.**

---

### Step 6: Ask User What To Do

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

**Wait for user response before Step 7.**

---

### Step 7: Execute User Choice

**If "Auto: fix valid, refute invalid":**

For each VALID comment, use Skill tool to invoke `superpowers:systematic-debugging`:

```
Fix this PR review comment using systematic debugging:

CONTEXT:
- PR: {pr_number}
- File: {file}:{line}
- Reviewer: @{username}
- Comment: {comment_text}
- Assessment: Valid (real bug/security issue)
- CLAUDE.md constraints: {if exists}

Follow the four phases:
1. Root Cause Investigation: Why does this issue exist?
2. Pattern Analysis: Similar issues elsewhere?
3. Hypothesis: What will fix do?
4. Implementation: Apply fix, verify

Report back: Root cause, fix applied, verification result.
```

For each INVALID comment:
- Draft refutation with technical reasoning from feature-research assessment
- Post as reply to comment thread (CRITICAL: must include PR_NUM in path):
  ```bash
  gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments/{COMMENT_ID}/replies \
    -X POST \
    -f body="{refutation text}"
  ```
- **DO NOT use `gh pr comment`** (creates top-level, not reply)
- **DO NOT omit PR_NUM from path** (will get 404)
- **See "Replying to Review Comments" section below for detailed format**
- Verify reply posted successfully (should return 201 Created)

---

**If "Review per-comment":**

Loop through each comment, ask user:
```typescript
AskUserQuestion({
  questions: [{
    question: "Comment {n}/{total}: {description}. Assessment: {valid/invalid}. What action?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Fix", description: "Fix using superpowers:systematic-debugging"},
      {label: "Refute", description: "Post technical explanation as reply"},
      {label: "Explain", description: "User will provide additional context"},
      {label: "Skip", description: "Skip this comment"},
      {label: "Stop", description: "Stop processing"}
    ]
  }]
})
```

**If user chooses "Fix":**

Use Skill tool to invoke `superpowers:systematic-debugging` for this comment (same prompt as "Auto" mode above).

**If user chooses "Refute":**

Post refutation as reply (same gh api command as "Auto" mode above).

**If user chooses "Explain":**

User provides context → re-invoke feature-research with new context → update assessment → ask again.

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

## Replying to Review Comments (CRITICAL)

**DO NOT use `gh pr comment` for replies.** That creates top-level comments.

**❌ WRONG format (missing PR_NUM):**
```bash
# This will return 404 Not Found
gh api repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID}/replies
```

**✅ CORRECT format:**
```bash
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments/{COMMENT_ID}/replies \
  -X POST \
  -f body="Your reply text here"
```

**Key difference:** Must include `pulls/{PR_NUM}/` before `comments/{COMMENT_ID}`

**Example (real working format):**
```bash
gh api repos/new-work/insights-etl/pulls/279/comments/2514655196/replies \
  -X POST \
  -f body="Your reply text here"
```

Result: 201 Created ✅

**Get required values:**
- OWNER/REPO: `gh repo view --json nameWithOwner --jq .nameWithOwner`
- PR_NUM: From Step 1 (the PR number you're working on)
- COMMENT_ID: From Step 3 (saved when parsing comments)

**Why this matters:**
- `gh pr comment` → Top-level comment (loses context)
- `gh api .../replies` → Reply in thread (maintains context)

**If command fails, verify endpoint format against official docs:**
https://docs.github.com/en/rest/pulls/comments?apiVersion=2022-11-28#create-a-reply-for-a-review-comment

---

## Refutation Best Practices

**DO:**
- Thank reviewer for feedback
- Explain technical reasoning clearly
- Reference code context from feature-research
- Offer to discuss further
- Maintain respectful tone
- Provide evidence

**DON'T:**
- Be dismissive or defensive
- Say "you're wrong"
- Refute without reasoning
- Use absolute language

**Example:**
```
Thank you for the suggestion to extract this logic.

I've assessed this and believe keeping it inline is better because:

1. The logic is only 4 lines and used once
2. Extracting now would be premature (YAGNI)
3. Context is clear in current scope

If we find a second use case, I'd be happy to extract then.
Does that sound reasonable, or is there planned reuse I'm not aware of?
```

---

## Red Flags - You're Failing If:

- **Ran `gh pr view` before creating TodoWrite**
- **Ran commands before switching to PR branch**
- **Still on different branch when fixing code**
- **Skipped TodoWrite creation**
- **Suggesting next steps instead of using AskUserQuestion**
- **Using `gh pr comment` instead of `gh api .../replies`**
- **Using Edit tool directly instead of invoking superpowers:systematic-debugging**
- **Drafting refutations but not posting them**
- **Accepting all comments without verification**
- **Not using feature-research to assess validity**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. You might be wrong. Run `git branch --show-current`. |
| **"Get PR details first to know which branch"** | **NO.** PR number in USER INPUT. Extract, switch NOW. |
| **"Senior engineer knows best, just fix all"** | **NO.** Senior engineers make mistakes too. Verify claims. |
| **"Not worth arguing about style"** | **NO.** Style changes have maintenance cost. Require justification. |
| **"Faster to fix than debate"** | **NO.** Blind fixes accumulate debt. Assess first. |
| **"Don't want to seem difficult"** | **NO.** Technical discussion is normal. Respectful refutation is professional. |
| **"Use gh pr comment to post reply"** | **NO.** Use `gh api .../replies` to reply in thread. |
| **"I'll fix directly with Edit tool"** | **NO.** Invoke superpowers:systematic-debugging. Don't skip root cause analysis. |
| **"Simple typo fix, don't need systematic-debugging"** | **NO.** Even typos have root causes (why was typo introduced?). Use the skill. |
| "Assessments done, I can proceed" | **NO.** Step 6 requires AskUserQuestion. Use it NOW. |
| "I drafted refutation, that's enough" | **NO.** Draft ≠ posted. Execute `gh api` command. |
| "I can assess without feature-research" | **NO.** Quick assessments miss context. Use research. |
| "Reviewer waiting, respond fast" | **NO.** Fast wrong responses waste MORE time. Verify first. |
| **"Feature-research skill not installed"** | **NO.** Don't rationalize around missing dependencies. Use manual research with same rigor. |
| **"I'll simulate user choice"** | **NO.** Use AskUserQuestion tool. Don't assume what user wants. |
| **"I'll check PR first to understand scope"** | **NO.** TodoWrite FIRST. No commands before TodoWrite. Zero exceptions. |
| **"Need context before creating TodoWrite"** | **NO.** TodoWrite doesn't need context. Create it from skill steps, THEN gather context. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read CLAUDE.md from PR branch
- ✓ Used feature-research to assess ALL comments
- ✓ Verified reviewer claims by reading code
- ✓ Used AskUserQuestion (not prose suggestions)
- ✓ Invoked superpowers:systematic-debugging for valid fixes (not Edit tool directly)
- ✓ Posted refutations with `gh api .../replies` (not `gh pr comment`)
- ✓ Verified replies posted in correct threads
- ✓ Created Z04 documentation with systematic-debugging results
- ✓ Resisted authority/agreeableness pressures
