---
name: feature-pr-fixing
description: Use when addressing PR review comments - follow structured workflow
---

# Feature Workflow: Address Pull Request Comments

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan (see below)
2. Mark Step 1 as `in_progress`
3. Extract the PR number from user input and switch to the PR branch

**Do not inspect PR comments or metadata before the progress plan exists and the PR branch has been checked out.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking pull-request comment-fixing workflow",
  "plan": [
    {"step": "Step 1: Confirm collaboration mode and decision fallback path", "status": "in_progress"},
    {"step": "Step 2: Extract the PR number from user input and switch to the PR branch", "status": "pending"},
    {"step": "Step 3: Read AGENTS.md first and CLAUDE.md if it exists, then load repo context", "status": "pending"},
    {"step": "Step 4: Get PR details, unresolved current review comments, and changed files", "status": "pending"},
    {"step": "Step 5: Read changed files and comment context", "status": "pending"},
    {"step": "Step 6: Assess each unresolved review comment", "status": "pending"},
    {"step": "Step 7: Present each comment assessment and collect one decision per comment", "status": "pending"},
    {"step": "Step 8: Execute queued fix or refutation decisions", "status": "pending"},
    {"step": "Step 9: Create Z04 documentation for anything left unhandled", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## Workflow Steps

### Step 1: Confirm Collaboration Mode

This workflow must run in Plan mode.

Rules:
1. Use `request_user_input` for the per-comment decision loop.
2. If `request_user_input` is unavailable, stop and report: `feature-pr-fixing requires Plan mode with request_user_input.`
3. Do not continue in prose-fallback mode.

---

### Step 2: Extract the PR Number and Switch to the PR Branch

The PR number comes from user input, not from `gh` discovery.

If the user did not provide a PR number or URL, ask for it before continuing.

Verify the current branch and switch:

```bash
git branch --show-current
gh pr checkout 258
```

Rules:
- verify first, even if you think you are already on the correct branch
- do not use `gh pr view` to discover the branch name
- be on the PR branch before reading docs or comments

---

### Step 3: Read Project Context

Read in this order:
1. `AGENTS.md`
2. `CLAUDE.md` if it exists
3. `README.md` if it exists
4. `ARCHITECTURE.md` or `docs/architecture/` if they exist

Goal:
- understand local patterns well enough to assess whether each review comment is valid, invalid, or needs discussion

---

### Step 4: Get PR Details, Unresolved Current Review Comments, and Changed Files

You need:
- PR title
- changed files
- unresolved current review comments
- comment IDs, authors, file locations, and bodies

Filtering rules:
- include only unresolved comments
- include only current comments, not outdated ones
- skip comments already handled in previous rounds

If no unresolved comments remain, report: `No unresolved review comments. Nothing to address.`

---

### Step 5: Read Changed Files and Comment Context

Read:
- changed files from Step 4
- nearby code around each comment location
- tests or helpers needed to understand the disputed behavior

Goal:
- understand enough of the code and project patterns to assess each comment rigorously

Do not read the entire codebase when the changed-file set and nearby context are enough.

---

### Step 6: Assess Each Unresolved Review Comment

For each unresolved comment, determine:

- **Assessment**: `Valid`, `Invalid`, or `Needs discussion`
- **Category**: `Bug`, `Security`, `Architecture`, `Style`, or `Convention`
- **Reasoning**: why the comment is correct, incorrect, or ambiguous
- **Suggested action**: `Fix`, `Refute`, or `Discuss`

Use:
- repo rules from `AGENTS.md` and `CLAUDE.md`
- local code patterns from the touched files
- architectural context when relevant

---

### Step 7: Present Each Comment Assessment and Collect One Decision Per Comment

Present assessments one comment at a time.

Required format:

```markdown
## PR Review Comment Assessment: {PR Title}

Comment {n}: {Reviewer comment text}
- File: {file}:{line}
- Reviewer: @{username}
- Assessment: Valid | Invalid | Needs discussion
- Category: {Bug | Security | Architecture | Style | Convention}
- Reasoning: {technical explanation}
- Suggested action: Fix | Refute | Discuss
```

Then ask how to handle that one comment.

Required structured input:
```typescript
request_user_input({
  questions: [{
    question: "How should I handle Comment {n}?",
    header: "Comment {n}",
    options: [
      {label: "Queue fix", description: "Queue a code fix for this comment in Step 8"},
      {label: "Queue refute", description: "Queue a technical in-thread reply for this comment in Step 8"},
      {label: "Queue skip", description: "Leave this comment unhandled and continue"},
      {label: "Stop review cycle", description: "Stop cycling comments and continue to execution or documentation"}
    ]
  }]
})
```

Rules:
- ask about one comment at a time
- end the message after the question block
- wait for the explicit decision
- do not execute fixes or replies during Step 7
- if the loop stops early, leave the remaining comments for `Z04`
- do not replace the structured question with prose fallback

---

### Step 8: Execute Queued Fix or Refutation Decisions

After the decision loop finishes:

For each `Queue fix`:
1. Invoke `superpowers:systematic-debugging` for that comment.
2. Apply the fix.
3. Run targeted verification.
4. Commit the fix with a descriptive message.

For each `Queue refute`:
1. Post a reply in the existing review thread with `gh api`.

For each `Queue skip`:
1. Leave it unhandled and carry it into `Z04`.

If the loop stopped early:
- do not auto-handle the remaining comments

Push all commits once at the end of Step 8.

Reply pattern:

```bash
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUM}/comments \
  -X POST \
  -f body="Your reply text here" \
  -F in_reply_to={COMMENT_ID}
```

Refutation content should:
- stay respectful
- reference repo rules or existing code patterns when relevant
- explain the technical reason for disagreement

If a queued fix cannot be completed safely:
- do not force it
- document the reason in `Z04`

---

### Step 9: Create Z04 Documentation for Anything Left Unhandled

Create `Z04` only when comments remain unfixed or unreplied.

Create `Z04` when:
- a comment was skipped
- the decision loop stopped early
- a queued fix could not be completed safely

Do not create `Z04` when every unresolved comment was fully handled.

Location rules:
- look for existing workflow artifacts to detect the ongoing directory
- default to `docs/ai/ongoing/` for this repository when no alternate location is already in use

Filename:
- `Z04_{kebab-case-pr-title}_fix.md`

Suggested structure:

```markdown
# PR Fix: {PR Title}

## Comments Left Unhandled

### Comment {n}
- Reviewer: @{username}
- File: {file}:{line}
- Assessment: {Valid | Invalid | Needs discussion}
- Recommended action: {Fix | Refute | Discuss}
- Reason left open: {why it was not completed}
```

## Red Flags

- Looked up PR metadata or comments before creating the progress plan
- Looked up PR comments before switching to the PR branch
- Ran this workflow outside Plan mode
- Assessed comments before reading repo context and touched code
- Processed resolved or outdated comments
- Asked for one global action across all comments
- Replaced `request_user_input` with prose fallback
- Replied with `gh pr comment` instead of replying in-thread with `gh api`
- Fixed code directly without routing queued fixes through `superpowers:systematic-debugging`
- Committed all fixes as one undifferentiated batch instead of after each verified fix

## Success Criteria

- Created the progress plan before PR inspection
- Switched to the PR branch before comment handling
- Filtered to unresolved current review comments only
- Assessed each comment against repo rules and local code patterns
- Ran in Plan mode and used `request_user_input` for every comment decision
- Routed queued fixes through `superpowers:systematic-debugging`
- Replied in-thread with `gh api` for queued refutations
- Created `Z04_{kebab-case-pr-title}_fix.md` only when unresolved work remained
