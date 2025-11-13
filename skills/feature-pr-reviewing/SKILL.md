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
    {content: "Step 5: Hunt for bugs (adversarial review)", status: "pending", activeForm: "Hunting for bugs"},
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

**Document:** file:line, type, severity, WHY bug, HOW to trigger, pattern violations

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


## Red Flags - You're Failing If:

- **Ran `gh pr view` or `gh pr diff` before creating TodoWrite**
- **Ran commands before switching to PR branch**
- **Still on `main` branch when analyzing**
- **Thinking "I'll gather metadata first"**
- **Skipped TodoWrite creation**
- **Suggesting next steps instead of using AskUserQuestion**
- **Asking "would you like me to..." in prose**
- **Drafting comments but not posting them**
- **Passive review instead of adversarial bug hunting**
- **Not finding ANY bugs** (means you didn't look hard enough)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Get PR details first to know branch"** | **NO.** PR number in USER INPUT. Extract, switch NOW. |
| **"I'm already on PR branch, skip verification"** | **NO.** VERIFY FIRST. Run `git branch --show-current`. |
| **"Run gh pr view to find branch name"** | **NO.** `gh pr checkout {number}` does that. Switch NOW. |
| **"Skip docs/exploration, I can see changes"** | **NO.** Need patterns to detect violations. |
| **"Time pressure = skip workflow"** | **NO.** Workflow is FASTER than ad-hoc. Follow it. |
| "TodoWrite wastes time" | **NO.** TodoWrite prevents mistakes that waste MORE time. |
| "I'll offer helpful next steps in text" | **NO.** Use AskUserQuestion tool. NOT prose. |
| "Findings presented, I can proceed" | **NO.** Step 7 requires AskUserQuestion. Use it NOW. |
| "I drafted comments, that's enough" | **NO.** Draft ≠ posted. Execute `gh pr comment`. |
| "Code looks correct, just confirm it" | **NO.** Don't confirm. ATTACK it. Find how to break it. |
| "ASSUME BUGS EXIST. Hunt adversarially" | **NO.** ASSUME BUGS EXIST. Hunt for them adversarially. |
| "Changes are simple, quick review" | **NO.** Simple code hides subtle bugs. Hunt line-by-line. |

## Success Criteria

You followed the workflow if:
- ✓ Created TodoWrite as FIRST action
- ✓ Switched to PR branch BEFORE any analysis
- ✓ Read documentation (CLAUDE.md, README, ARCHITECTURE) from PR branch
- ✓ Explored codebase to understand patterns
- ✓ Hunted for bugs adversarially (not passive validation)
- ✓ Assumed bugs exist, found them
- ✓ Analyzed changes with full repo context awareness
- ✓ Used AskUserQuestion (not prose suggestions)
- ✓ Posted comments with actual commands (not drafts)
- ✓ Created Z03 documentation (if needed)
- ✓ Resisted all rationalizations
