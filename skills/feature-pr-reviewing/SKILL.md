---
name: feature-pr-reviewing
description: Use when reviewing pull request changes - follow structured workflow
---

# Feature Workflow: Review Pull Request

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan (see below)
2. Mark Step 1 as `in_progress`
3. Extract the PR number from user input and switch to the PR branch

**Do not inspect PR metadata or diffs before the progress plan exists and the PR branch has been checked out.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking pull-request review workflow",
  "plan": [
    {"step": "Step 1: Confirm collaboration mode and decision fallback path", "status": "in_progress"},
    {"step": "Step 2: Extract the PR number from user input and switch to the PR branch", "status": "pending"},
    {"step": "Step 3: Read AGENTS.md first and CLAUDE.md if it exists, then load repo context", "status": "pending"},
    {"step": "Step 4: Get PR details and changed files", "status": "pending"},
    {"step": "Step 5: Read the changed files and immediate context", "status": "pending"},
    {"step": "Step 6: Hunt for bugs with an adversarial review pass", "status": "pending"},
    {"step": "Step 7: Present findings and collect one decision per finding", "status": "pending"},
    {"step": "Step 8: Execute queued comment or fix decisions", "status": "pending"},
    {"step": "Step 9: Create Z03 documentation for any unposted findings", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## Workflow Steps

### Step 1: Confirm Collaboration Mode

This workflow must run in Plan mode.

Rules:
1. Use `request_user_input` for the review decision loop.
2. If `request_user_input` is unavailable, stop and report: `feature-pr-reviewing requires Plan mode with request_user_input.`
3. Do not continue in prose-fallback mode.

---

### Step 2: Extract the PR Number and Switch to the PR Branch

The PR number comes from user input, not from `gh` discovery.

Examples:
- `review PR https://github.com/owner/repo/pull/258` -> PR number `258`
- `review PR 258` -> PR number `258`

If the user did not provide a PR number or URL, ask for it before continuing.

Verify the current branch and switch:

```bash
git branch --show-current
gh pr checkout 258
```

Rules:
- verify first, even if you think you are already on the correct branch
- do not run `gh pr view` to discover the branch name
- be on the PR branch before reading docs or changes

---

### Step 3: Read Project Context

Read in this order:
1. `AGENTS.md`
2. `CLAUDE.md` if it exists
3. `README.md` if it exists
4. `ARCHITECTURE.md` or `docs/architecture/` if they exist

Goal:
- understand local conventions well enough to tell the difference between a real bug and a comment that conflicts with project patterns

---

### Step 4: Get PR Details and Changed Files

Get the PR metadata and changed-file list.

You need:
- PR title
- PR author
- changed files

You may use commands such as:

```bash
gh pr view 258 --json title,author,files
```

or:

```bash
gh pr diff 258 --name-only
```

Do not start code review before you know which files changed.

---

### Step 5: Read the Changed Files and Immediate Context

Read the changed files and enough nearby context to understand what the code is doing.

Focus on:
- changed files from Step 4
- nearby helpers, tests, and interfaces needed to understand the behavior
- local project patterns in the touched areas

Do not read the entire codebase when the changed-file set is enough.

---

### Step 6: Hunt for Bugs With an Adversarial Review Pass

Assume defects exist. Attack the PR.

Hunt for:
- security bugs
- logic bugs
- missing or weak tests
- architecture violations
- naming, layering, and consistency issues likely to draw reviewer feedback

For each finding, record:
- file and exact line range
- issue type
- severity (`Must-fix`, `Should-fix`, `Nice-to-have`)
- why it is a real issue
- how to trigger or observe it

---

### Step 7: Present Findings and Collect One Decision Per Finding

First print the full findings index. The user must see the complete numbered list before any per-finding decision loop begins.

Required pre-loop format:

```markdown
## PR Review Findings: {PR Title}

Total findings: {N}

Findings Index:
1. {Issue Type} - {Description} ({Severity}) [{file}:{line-start}-{line-end}]
2. ...
```

After the index, present one finding at a time.

Detailed finding format:

```markdown
## PR Review Findings: {PR Title}

Finding 1: {Issue Type} - {Description}
- File: {file}:{line-start}-{line-end}
- Severity: {Must-fix | Should-fix | Nice-to-have}
- Why this is a bug: {impact + broken assumption}
- How to trigger: {minimal repro}
- Suggested PR comment text:
  - Summary: {specific issue in one sentence}
  - Evidence: {file}:{line-start}-{line-end} and what those lines do wrong
  - Impact: {concrete failure or risk}
  - Severity: {Must-fix | Should-fix | Nice-to-have}
```

Then ask how to handle that one finding.

Required structured input:
```typescript
request_user_input({
  questions: [{
    question: "How should I handle Finding {n}?",
    header: "Finding {n}",
    options: [
      {label: "Post comment", description: "Post this finding as one PR comment in Step 8"},
      {label: "Add to fix queue", description: "Queue this finding to be fixed directly in the PR in Step 8"},
      {label: "Skip comment", description: "Do not post this finding and continue"},
      {label: "Stop review cycle", description: "Stop reviewing findings and continue to execution or documentation"}
    ]
  }]
})
```

Rules:
- ask about one finding at a time
- end the message after the question block
- wait for the explicit decision
- do not ask about the next finding before the current one is decided
- do not post comments or make fixes during Step 7
- do not replace the structured question with prose fallback

---

### Step 8: Execute Queued Comment or Fix Decisions

After the decision loop finishes:
- for each `Post comment`, post exactly one PR comment for that one finding
- for each `Add to fix queue`, fix the finding directly on the PR branch
- for each `Skip comment`, do nothing
- if the loop stopped early, do not auto-handle remaining findings

Comment format for each posted finding:

```markdown
[Severity: Must-fix|Should-fix|Nice-to-have] {specific issue summary}

Why this matters:
{concrete impact and failure mode}

Affected code:
- `{file}:{line-start}-{line-end}`: {what this code is doing and why it is wrong or risky}

Suggested change:
{clear and actionable fix direction}
```

Rules:
- never combine multiple findings into one PR comment
- if a queued fix is selected, invoke `superpowers:systematic-debugging` before editing code
- run targeted verification for each fix before moving on
- if a queued fix cannot be completed safely, record the reason and include it in `Z03`

---

### Step 9: Create Z03 Documentation for Any Unposted Findings

Create `Z03` only when findings remain unposted or unfixed.

Create `Z03` when:
- the decision loop stopped early
- a finding was skipped
- a queued fix could not be completed safely

Do not create `Z03` when every finding was fully handled in-thread.

Location rules:
- look for existing workflow artifacts to detect the ongoing directory
- default to `docs/ai/ongoing/` for this repository when no alternate location is already in use

Filename:
- `Z03_{kebab-case-pr-title}_review.md`

## Red Flags

- Looked up PR metadata before creating the progress plan
- Looked up PR metadata before switching to the PR branch
- Ran this workflow outside Plan mode
- Started review before reading project context
- Read the whole codebase instead of the changed-file set and needed context
- Asked for one global action across all findings
- Asked about `Finding 1` before printing the full findings index
- Replaced `request_user_input` with prose fallback
- Posted combined comments covering multiple findings
- Fixed code directly without routing queued fixes through `superpowers:systematic-debugging`

## Success Criteria

- Created the progress plan before PR inspection
- Switched to the PR branch before review work
- Read repo instructions and relevant project context
- Reviewed changed files with an adversarial mindset
- Printed the full findings index before any per-finding loop
- Ran in Plan mode and used `request_user_input` for every finding decision
- Posted one PR comment per accepted finding
- Routed queued fixes through `superpowers:systematic-debugging`
- Created `Z03_{kebab-case-pr-title}_review.md` only when unresolved findings remained
