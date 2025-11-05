---
name: feature-prreview
description: Use when reviewing pull request changes before providing feedback - analyzes PR with feature-research, presents structured findings, offers user choices for commenting or documentation
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
    {content: "Step 2: Read CLAUDE.md from PR branch", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Get PR details and changed files", status: "pending", activeForm: "Getting PR info"},
    {content: "Step 4: Analyze with feature-research", status: "pending", activeForm: "Analyzing changes"},
    {content: "Step 5: Present findings", status: "pending", activeForm: "Presenting findings"},
    {content: "Step 6: Ask user what to do (AskUserQuestion)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 7: Execute user choice", status: "pending", activeForm: "Executing action"}
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

### Step 2: Read CLAUDE.md

**You're now on the PR branch.** Read `CLAUDE.md` if it exists.

Look for:
- Mandatory patterns
- Forbidden approaches
- Security/quality standards

You'll use these when analyzing.

---

### Step 3: Get PR Details

Get PR metadata and changed files however you want (`gh pr view`, `gh pr diff`, etc.)

You need:
- PR title, author
- List of changed files

---

### Step 4: Analyze with feature-research

**Use Skill tool to invoke `feature-workflow:feature-research`**

Give it:
- Changed files list
- CLAUDE.md constraints (if exists)
- Request: "Find security issues, code quality problems, missing error handling, test gaps, CLAUDE.md violations"

Parse research output for findings with:
- File path and line number
- Issue type and severity
- Description

---

### Step 5: Present Findings

Display findings in structured format:

```
## PR Review Findings: {PR Title}

Finding 1: {Issue Type} - {Description}
- File: {file}:{line}
- Severity: {level}

Finding 2: ...

Total findings: {count}
```

**DO NOT suggest next steps. DO NOT ask "would you like me to...". Proceed immediately to Step 6.**

---

### Step 6: Ask User What To Do

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

**Wait for user response before Step 7.**

---

### Step 7: Execute User Choice

**If "Comment all":** Ask format (separate comments vs single review), then post using `gh pr comment` or `gh pr review`.

**If "Review per-finding":** Loop through each finding, ask user (Comment/Skip/Stop), execute accordingly.

**If "Document only":** Skip to creating Z03 file.

**ALWAYS create Z03 documentation file** with findings summary, regardless of choice.

**Z03 location:** Scan for existing `Z0[12]_*.md` files to find ongoing directory. Default to `docs/ai/ongoing/`.

**Z03 filename:** `Z03_{kebab-case-pr-title}_review.md`

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
| **"15 minutes too tight for workflow"** | **NO.** TodoWrite + switch + research is faster than manual review. |
| "I can see what needs doing, skip TodoWrite" | **NO.** TodoWrite is MANDATORY. Creates visibility, prevents skips. |
| "Creating TodoWrite wastes time" | **NO.** TodoWrite prevents mistakes that waste MORE time. |
| "I'll offer helpful next steps in text" | **NO.** Use AskUserQuestion tool. NOT prose. |
| "Findings presented, I can proceed" | **NO.** Step 6 requires AskUserQuestion. Use it NOW. |
| "User obviously wants comments" | **NO.** ALWAYS ask. User might want document-only. |
| "I drafted comments, that's enough" | **NO.** Draft ≠ posted. Execute `gh pr comment`. |
| "PR is simple, review directly" | **NO.** feature-research finds issues you'll miss. |
| "Time pressure, skip systematic approach" | **NO.** Systematic is FASTER. Shortcuts cause rework. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read CLAUDE.md from PR branch
- ✓ Used feature-research skill
- ✓ Used AskUserQuestion (not prose suggestions)
- ✓ Posted comments with actual commands (not drafts)
- ✓ Created Z03 documentation
- ✓ Resisted all rationalizations
