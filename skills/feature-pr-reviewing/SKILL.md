---
name: feature-pr-reviewing
description: Use when reviewing pull request changes - follow structured workflow
---

# feature-prreview: PR Review with Research-Driven Analysis

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Switch to PR branch

**If you ran `gh pr view` or `gh pr diff` before switching branches, you FAILED.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Extract PR number from user input, switch to PR branch NOW", status: "in_progress", activeForm: "Switching to PR branch"},
    {content: "Step 2: Read documentation FIRST (CLAUDE.md, README, ARCHITECTURE)", status: "pending", activeForm: "Reading project docs"},
    {content: "Step 3: Explore codebase (glob, grep, read files)", status: "pending", activeForm: "Analyzing codebase"},
    {content: "Step 4: Get PR details and changed files", status: "pending", activeForm: "Getting PR info"},
    {content: "Step 5: Analyze changes using repo context and pattern awareness", status: "pending", activeForm: "Analyzing changes"},
    {content: "Step 6: Present findings", status: "pending", activeForm: "Presenting findings"},
    {content: "Step 7: Ask user what to do (AskUserQuestion)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 8: Execute user choice", status: "pending", activeForm: "Executing action"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Workflow Steps

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

**Goal:** Know how things are SUPPOSED to be done in this codebase, so you can identify when review comments suggest anti-patterns.

---

### Step 4: Get PR Details

Get PR metadata and changed files however you want (`gh pr view`, `gh pr diff`, etc.)

You need:
- PR title, author
- List of changed files

---

### Step 5: Analyze Changes Using Repo Context

**You now have full context:** Documentation + codebase patterns + changed files.

**Analyze the PR changes for:**

1. **Security Issues:**
   - Input validation missing
   - Authentication/authorization bypasses
   - Injection vulnerabilities (SQL, XSS, command)
   - Secrets in code

2. **Code Quality Problems:**
   - Violates patterns from CLAUDE.md
   - Inconsistent with existing conventions (from Step 3)
   - Missing error handling
   - Poor naming/structure

3. **Architecture Violations:**
   - Breaks component boundaries
   - Bypasses established abstractions
   - Introduces unwanted dependencies
   - Contradicts ARCHITECTURE.md design

4. **Test Gaps:**
   - Missing test coverage for new features
   - No error case testing
   - Integration points untested

**For each finding, capture:**
- File path and line number
- Issue type and severity (critical/high/medium/low)
- Description with technical reasoning
- How it violates project patterns (reference docs/code from Steps 2-3)

**Use your judgment.** You have the context. Apply it.

---

### Step 6: Present Findings

Display findings in structured format:

```
## PR Review Findings: {PR Title}

Finding 1: {Issue Type} - {Description}
- File: {file}:{line}
- Severity: {level}

Finding 2: ...

Total findings: {count}
```

**DO NOT suggest next steps. DO NOT ask "would you like me to...". Proceed immediately to Step 7.**

---

### Step 7: Ask User What To Do

**STOP. Use AskUserQuestion tool NOW. Do NOT proceed until user responds.**

```typescript
AskUserQuestion({
  questions: [{
    question: "How would you like to handle these findings?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Comment all", description: "Post all findings as PR comments immediately"},
      {label: "Review per-finding", description: "Go through each finding, decide comment/skip/stop"},
      {label: "Document only", description: "Save findings to Z03 file without posting"}
    ]
  }]
})
```

**Wait for user response before Step 8.**

---

### Step 8: Execute User Choice

**If "Comment all":**
- Ask format (separate comments vs single review)
- Post using `gh pr comment` or `gh pr review`
- **NO Z03 file** (all findings posted)

**If "Review per-finding":**
- Loop through each finding, ask user (Comment/Skip/Stop)
- If user stops before completing: **CREATE Z03** with remaining unposted findings
- If all findings posted/skipped: **NO Z03 file**

**If "Document only":**
- **CREATE Z03 file** with all findings (nothing posted)

**Z03 conditional creation:**
- Only create if findings exist that were NOT posted as comments
- If all findings posted → no Z03 needed

**Z03 location:** Scan for existing `Z0[12]_*.md` files to find ongoing directory. Default to `docs/ai/ongoing/`.

**Z03 filename:** `Z03_{kebab-case-pr-title}_review.md`

---

## Posting Review Comments (Reference)

**For NEW review comments** (findings from this review):
- Use `gh pr comment {PR_NUM}` for individual comments
- Use `gh pr review {PR_NUM}` for batch review submission
- Both are correct - choose based on user preference

**For REPLYING to existing comments** (not applicable in this skill):
- **CRITICAL:** Must include PR_NUM in path
- ❌ WRONG: `gh api repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID}/replies` (404)
- ✅ CORRECT: `gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments/{COMMENT_ID}/replies` (201)
- See feature-pr-fixing skill for full reply workflow

**If commands fail, reference official docs:**
- Review comments: https://docs.github.com/en/rest/pulls/comments?apiVersion=2022-11-28
- Review replies: https://docs.github.com/en/rest/pulls/comments?apiVersion=2022-11-28#create-a-reply-for-a-review-comment

---

## Red Flags - You're Failing If:

- **Ran `gh pr view` or `gh pr diff` before creating TodoWrite**
- **Ran commands before switching to PR branch**
- **Still on `main` branch when analyzing**
- **Thinking "I'll gather metadata first"**
- **Skipped TodoWrite creation**
- **Suggesting next steps instead of using AskUserQuestion**
- **Asking "would you like me to..." in prose**
- **Drafting comments but not posting them**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. You might be wrong. Run `git branch --show-current`. |
| **"Get PR details first to know which branch"** | **NO.** PR number is in USER INPUT. Extract it, switch NOW. No gh commands first. |
| **"Run gh pr view to find branch name"** | **NO.** `gh pr checkout {number}` does that automatically. Switch NOW. |
| **"Gather metadata first, then switch"** | **NO.** Switch FIRST. Metadata from wrong branch = wrong context. |
| **"Quick overview before diving in"** | **NO.** Overview from wrong branch is useless. Switch FIRST. |
| **"Time pressure = skip workflow"** | **NO.** Workflow is FASTER than ad-hoc. Follow it. |
| **"Not spend time switching branches"** | **NO.** Switching takes 5 seconds. Wrong branch wastes 15 minutes. |
| **"Trust PR description, skip CLAUDE.md"** | **NO.** PR description doesn't replace project guidelines. |
| **"Skip README/ARCHITECTURE, just check CLAUDE.md"** | **NO.** Full context prevents missing architecture violations. |
| **"Skip codebase exploration, I can see the changes"** | **NO.** Need to know existing patterns to detect violations. |
| **"15 minutes too tight for workflow"** | **NO.** TodoWrite + context + analysis is faster than rework. |
| "I can see what needs doing, skip TodoWrite" | **NO.** TodoWrite is MANDATORY. Creates visibility, prevents skips. |
| "Creating TodoWrite wastes time" | **NO.** TodoWrite prevents mistakes that waste MORE time. |
| "I'll offer helpful next steps in text" | **NO.** Use AskUserQuestion tool. NOT prose. |
| "Findings presented, I can proceed" | **NO.** Step 7 requires AskUserQuestion. Use it NOW. |
| "User obviously wants comments" | **NO.** ALWAYS ask. User might want document-only. |
| "I drafted comments, that's enough" | **NO.** Draft ≠ posted. Execute `gh pr comment`. |
| "PR is simple, review directly" | **NO.** Context reveals issues you'll miss. Architecture awareness matters. |
| "Time pressure, skip systematic approach" | **NO.** Systematic is FASTER. Shortcuts cause rework. |
| "I know this codebase, skip exploration" | **NO.** Memory fades. Refresh context every time. Patterns evolve. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read documentation (CLAUDE.md, README, ARCHITECTURE) from PR branch
- ✓ Explored codebase to understand patterns
- ✓ Analyzed changes with full repo context awareness
- ✓ Used AskUserQuestion (not prose suggestions)
- ✓ Posted comments with actual commands (not drafts)
- ✓ Created Z03 documentation (if needed)
- ✓ Resisted all rationalizations
