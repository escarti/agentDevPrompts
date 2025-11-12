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

**Build mental model of codebase structure** using exploration tools:

**Use Task tool with subagent_type=Explore:**
```
Explore the codebase to understand:
- Project structure and organization
- Key architectural patterns
- Common coding conventions
- Testing patterns
- Security practices

Focus on changed areas related to PR files.
```

**Alternative (if Explore agent not available):** Manual exploration:
- `glob` to find related files by pattern
- `grep` to search for similar implementations
- `Read` files to understand existing approaches

**Goal:** Know how things are SUPPOSED to be done, so you can identify when review comments suggest anti-patterns or violate project architecture.

---

### Step 4: Get PR Details and Comments

Get PR metadata and review comments however you want (`gh pr view`, `gh pr view --comments`, etc.)

You need:
- PR title, author, branch
- **All UNRESOLVED review comments** with:
  - Comment ID (CRITICAL - needed for replies)
  - File path and line number
  - Comment body text
  - Reviewer username
  - **Resolution status** (resolved/unresolved)
  - **Outdated status** (outdated/current)

**CRITICAL FILTERING:**
- **ONLY include UNRESOLVED comments** (not marked as resolved by reviewer)
- **ONLY include CURRENT comments** (not marked as outdated by GitHub after force-push)
- **SKIP any comment with state "RESOLVED" or marked outdated**

**If no unresolved comments**: "No unresolved review comments. Nothing to address."

**Save comment IDs** - you need them to reply in the correct thread.

**Example gh command to check resolution status:**
```bash
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments \
  --jq '.[] | select(.in_reply_to_id == null) | {id, body, path, line, user: .user.login, resolved: (.pull_request_review_id != null)}'
```

---

### Step 5: Assess ALL Comments Using Repo Context

**You now have full context:** Documentation + codebase patterns + review comments.

**For each review comment, assess:**

1. **Is the claim valid?**
   - Real bug/security issue → **VALID (must fix)**
   - Violates CLAUDE.md patterns → **VALID (must fix)**
   - Violates established architecture (from Step 3) → **VALID (must fix)**
   - Style preference without technical justification → **INVALID (can refute)**
   - Conflicts with project conventions (from Steps 2-3) → **INVALID (can refute)**

2. **Category:**
   - Bug: Logic error, incorrect behavior
   - Security: Vulnerability, exposure, attack vector
   - Architecture: Violates design patterns, breaks boundaries
   - Style: Subjective preference without technical merit
   - Convention: Conflicts with or aligns with project standards

3. **Technical reasoning:**
   - Reference docs from Step 2 (CLAUDE.md, ARCHITECTURE.md)
   - Reference code patterns from Step 3 (existing implementations)
   - Explain WHY valid or invalid
   - For invalid comments: explain why reviewer suggestion conflicts with project patterns

4. **Suggested action:**
   - Fix: Valid issue, should be addressed
   - Refute: Invalid, conflicts with project patterns
   - Discuss: Ambiguous, needs clarification

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
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. You might be wrong. Run `git branch --show-current`. |
| **"Get PR details first to know which branch"** | **NO.** PR number in USER INPUT. Extract, switch NOW. |
| **"Process all comments, including resolved ones"** | **NO.** ONLY unresolved. Filter resolved/outdated FIRST. |
| **"Reviewer might unresolve later, fix now"** | **NO.** Resolved = done. Don't waste time on closed discussions. |
| **"Outdated comments might still be valid"** | **NO.** Outdated = code changed. Re-review if needed, don't refix old code. |
| **"Senior engineer knows best, just fix all"** | **NO.** Senior engineers make mistakes too. Verify claims. |
| **"Skip README/ARCHITECTURE, just check CLAUDE.md"** | **NO.** Full context prevents accepting anti-patterns from reviewers. |
| **"Skip codebase exploration, I know the patterns"** | **NO.** Memory fades. Verify actual patterns before assessment. |
| **"Not worth arguing about style"** | **NO.** Style changes have maintenance cost. Require justification. |
| **"Faster to fix than debate"** | **NO.** Blind fixes accumulate debt. Assess with full context first. |
| **"Don't want to seem difficult"** | **NO.** Technical discussion is normal. Respectful refutation is professional. |
| **"Reviewer is senior, must be right"** | **NO.** Senior engineers miss project-specific patterns. Verify against docs. |
| **"Use gh pr comment to post reply"** | **NO.** Use `gh api .../replies` to reply in thread. |
| **"I'll fix directly with Edit tool"** | **NO.** Invoke superpowers:systematic-debugging. Don't skip root cause analysis. |
| **"Simple typo fix, don't need systematic-debugging"** | **NO.** Even typos have root causes (why was typo introduced?). Use the skill. |
| "Assessments done, I can proceed" | **NO.** Step 7 requires AskUserQuestion. Use it NOW. |
| "I drafted refutation, that's enough" | **NO.** Draft ≠ posted. Execute `gh api` command. |
| "I can assess without exploration" | **NO.** Quick assessments miss patterns. Need full context. |
| "Reviewer waiting, respond fast" | **NO.** Fast wrong responses waste MORE time. Verify first. |
| **"I already read docs in another session"** | **NO.** Context expires. Read docs EVERY time from PR branch. |
| **"I'll simulate user choice"** | **NO.** Use AskUserQuestion tool. Don't assume what user wants. |
| **"I'll check PR first to understand scope"** | **NO.** TodoWrite FIRST. No commands before TodoWrite. Zero exceptions. |
| **"Need context before creating TodoWrite"** | **NO.** TodoWrite doesn't need context. Create it from skill steps, THEN gather context. |

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
