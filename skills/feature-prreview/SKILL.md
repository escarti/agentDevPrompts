---
name: feature-prreview
description: Use when reviewing pull request changes before providing feedback - analyzes PR with feature-research, presents structured findings, offers user choices for commenting or documentation
---

# feature-prreview: PR Review with Research-Driven Analysis

## Overview

**Systematically review PR changes following a step-by-step workflow with mandatory TodoWrite tracking. Analyze code in context, present findings, and handle user choices about commenting vs documentation.**

**Workflow Position:** Flow agnostic

**Core principle**: Follow the 9-step workflow exactly. Create TodoWrite list first. Switch to PR branch before reading any files. Track progress through each step. Don't skip steps or rationalize shortcuts.

## Progress Tracking

**MANDATORY:** Use TodoWrite tool to track workflow progress.

**At skill start, create todos for all steps:**

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Extract PR number and switch to PR branch", status: "in_progress", activeForm: "Detecting and switching to PR branch"},
    {content: "Step 2: Load project context (CLAUDE.md)", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Verify PR details (gh pr view)", status: "pending", activeForm: "Fetching PR details"},
    {content: "Step 4: Get changed files (gh pr diff --name-only)", status: "pending", activeForm: "Listing changed files"},
    {content: "Step 5: Analyze changes (invoke feature-research skill)", status: "pending", activeForm: "Invoking feature-research for code analysis"},
    {content: "Step 6: Present findings (security/quality/testing)", status: "pending", activeForm: "Formatting review findings"},
    {content: "Step 7: User decision (AskUserQuestion: Comment all/Review/Document)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 8: Comment format sub-choice (Separate/Single review)", status: "pending", activeForm: "Choosing comment format"},
    {content: "Step 9: Execute user choice (post comments/review)", status: "pending", activeForm: "Posting review feedback"}
  ]
})
```

**Note:** Path detection for Z03 documentation happens in Step 9 only if user chooses to document.

**After completing each step:**
- Mark current step as `completed`
- Move `in_progress` to next step
- Update `activeForm` with current action

**Example update after Step 1:**
```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Extract PR number and switch to PR branch", status: "completed"},
    {content: "Step 2: Load project context (CLAUDE.md)", status: "in_progress", activeForm: "Reading CLAUDE.md"},
    {content: "Step 3: Verify PR details (gh pr view)", status: "pending"},
    // ... remaining steps
  ]
})
```

**CRITICAL:** Exactly ONE todo should be `in_progress` at any time. All others are `pending` or `completed`.

## Mandatory Workflow

**YOU MUST follow this exact sequence. No exceptions.**

### 1. Extract PR Number and Switch to PR Branch

**CRITICAL: You must be on the correct branch before reviewing the PR.**

**Handle three scenarios:**
1. User provides PR URL (extract PR number)
2. User provides PR number directly
3. No PR specified (use current branch's PR)

Use Bash tool:
```bash
# Scenario 1 & 2: PR URL or number provided by user
# Extract from user's input if they provided a URL like:
# https://github.com/owner/repo/pull/123

# Check if user provided PR URL
if [[ "$USER_INPUT" =~ github\.com/[^/]+/[^/]+/pull/([0-9]+) ]]; then
  PR_NUM="${BASH_REMATCH[1]}"
  echo "Detected PR #$PR_NUM from URL"
elif [[ "$USER_INPUT" =~ ^[0-9]+$ ]]; then
  # User provided just the PR number
  PR_NUM="$USER_INPUT"
  echo "Using PR #$PR_NUM"
else
  # Scenario 3: No PR specified, detect from current branch
  PR_NUM=$(gh pr view --json number --jq .number 2>/dev/null || echo "")
  if [ -z "$PR_NUM" ]; then
    echo "ERROR: No PR found for current branch and no PR URL/number provided."
    echo "Usage: Provide PR URL or ensure you're on a branch with an open PR."
    exit 1
  fi
  echo "Detected PR #$PR_NUM for current branch"
fi

# Get PR branch name
PR_BRANCH=$(gh pr view "$PR_NUM" --json headRefName --jq .headRefName)
CURRENT_BRANCH=$(git branch --show-current)

echo "PR branch: $PR_BRANCH"
echo "Current branch: $CURRENT_BRANCH"

# Switch to PR branch if needed
if [ "$CURRENT_BRANCH" != "$PR_BRANCH" ]; then
  echo "Switching to PR branch $PR_BRANCH..."

  # Check if branch exists locally
  if git show-ref --verify --quiet refs/heads/"$PR_BRANCH"; then
    git checkout "$PR_BRANCH"
  else
    # Branch doesn't exist locally, use gh to fetch and checkout
    echo "Branch not found locally, fetching from PR..."
    gh pr checkout "$PR_NUM"
  fi

  # Verify switch succeeded
  NEW_BRANCH=$(git branch --show-current)
  if [ "$NEW_BRANCH" != "$PR_BRANCH" ]; then
    echo "ERROR: Failed to switch to branch $PR_BRANCH"
    exit 1
  fi
  echo "Successfully switched to $PR_BRANCH"
else
  echo "Already on correct branch: $PR_BRANCH"
fi
```

**Extract and save**:
- `PR_NUM` - PR number for all subsequent gh commands
- `PR_BRANCH` - Branch name (for documentation)

**If branch switch fails**: Error gracefully with clear instructions on how to manually checkout the branch.

### 2. Load Project Context (MANDATORY)

**CRITICAL: You are now on the correct PR branch. Read context from THIS branch.**

**Read CLAUDE.md if it exists:**

Use Read tool:
```bash
if [ -f CLAUDE.md ]; then
  echo "Reading project guidelines from PR branch..."
  # Use Read tool to read CLAUDE.md
fi
```

**Extract from CLAUDE.md (if exists):**
- Mandatory patterns code should follow
- Forbidden approaches to check for violations
- Project conventions
- Security and code quality standards

**This context is critical for identifying violations and security issues during PR review.**

### 3. Verify PR Details

**Verify PR details:**

```bash
# Use the PR_NUM from step 2
gh pr view "$PR_NUM" --json number,title,author,headRefName
```

**Extract and display**: PR number, title, author, branch name

### 4. Get Changed Files

```bash
gh pr diff --name-only
```

**Extract**: List of all changed file paths

### 5. Analyze with feature-research

**REQUIRED**: Use Skill tool to invoke `feature-workflow:feature-research` on the changed files.

**Context to provide feature-research**:
- List of changed files
- PR title and description
- CLAUDE.md constraints (if exists) to check for pattern violations
- Request: "Identify security issues, code quality problems, missing error handling, test gaps, violations of CLAUDE.md patterns"

**Parse research output** for structured findings:
- File path and line number
- Issue type (security/quality/testing/observability)
- Description of problem
- Severity (critical/high/medium/low)

### 6. Present Findings

Display findings in structured format:

```
## PR Review Findings: {PR Title}

Finding 1: {Issue Type} - {Description}
- File: {file}:{line}
- Severity: {level}

Finding 2: ...
[Continue for all findings]

Total findings: {count}
```

**DO NOT suggest next steps. DO NOT ask "would you like me to...". DO NOT offer options in plain text.**

**YOU MUST IMMEDIATELY proceed to Step 7. Read Step 7 now. Do not skip to Step 8.**

### 7. User Decision Point (REQUIRED)

**STOP. YOU MUST use AskUserQuestion tool NOW. Do NOT proceed to step 8 until user responds.**

**If you are reading this, you have NOT asked the user yet. STOP and use AskUserQuestion RIGHT NOW.**

**DO NOT write "Next Steps" or "Would you like me to..." - use the AskUserQuestion tool IMMEDIATELY.**

```typescript
AskUserQuestion({
  questions: [{
    question: "How would you like to handle these findings?",
    header: "Action",
    multiSelect: false,
    options: [
      {
        label: "Comment all",
        description: "Post all findings as PR comments immediately"
      },
      {
        label: "Review per-finding",
        description: "Go through each finding, decide comment/skip/stop for each"
      },
      {
        label: "Document only",
        description: "Save findings to Z03 file without posting comments"
      }
    ]
  }]
})
```

**After calling AskUserQuestion, WAIT for user response. Do NOT continue reading this skill until user answers.**

### 8. Comment Format Sub-choice (IF commenting selected)

**If user chose "Comment all" or "Review per-finding", ask about format**:

```typescript
AskUserQuestion({
  questions: [{
    question: "How should comments be posted?",
    header: "Format",
    multiSelect: false,
    options: [
      {
        label: "Separate comments",
        description: "Each finding as individual comment using gh pr comment"
      },
      {
        label: "Single review",
        description: "All findings in one review using gh pr review --comment"
      }
    ]
  }]
})
```

## GitHub Comment Patterns for PR Review

**IMPORTANT: feature-prreview posts NEW review comments on someone else's PR. This is different from feature-prfix which REPLIES to existing comments.**

**For posting review findings (NEW comments):**

1. **Individual comments** (`gh pr comment`):
   - Creates separate top-level comments for each finding
   - Good for: When user wants to comment on specific findings one by one
   - Command: `gh pr comment {PR_NUM} --body "{finding}"`

2. **Single consolidated review** (`gh pr review --comment`):
   - Creates one review with all findings
   - Good for: When user wants all findings in one place
   - Command: `gh pr review {PR_NUM} --comment --body "{all findings}"`

**Both create top-level comments, which is correct for new PR reviews.**

**NOTE:** Do NOT use `gh api .../replies` in this skill. That's for feature-prfix (replying to existing comment threads). This skill reviews PRs independently of existing comments.

### 9. Execute User Choice

**Comment all** (separate):
**YOU MUST use Bash tool to post comments. Do NOT just draft them.**

```bash
# Use Bash tool to execute this command for each finding
gh pr comment {number} --body "Finding 1: {description}

File: {file}:{line}
Severity: {severity}

{details}"
```

**REQUIRED**: Use Bash tool to execute `gh pr comment` for each finding. Verify each posts successfully.

**Comment all** (single review):
**YOU MUST use Bash tool to post the review. Do NOT just draft it.**

```bash
# Use Bash tool to execute this command
gh pr review {number} --comment --body "$(cat <<'EOF'
## Review Findings

### Finding 1: {description}
- File: {file}:{line}
- Severity: {severity}

{details}

### Finding 2: ...
[All findings]
EOF
)"
```

**REQUIRED**: Use Bash tool to execute `gh pr review` command. Verify review posts successfully.

**Review per-finding**:
Loop through each finding, ask user:
```typescript
AskUserQuestion({
  questions: [{
    question: "Finding {n}/{total}: {description} ({file}:{line}). What action?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Comment", description: "Post this finding as comment"},
      {label: "Skip", description: "Skip this finding, continue to next"},
      {label: "Stop", description: "Stop review, don't process remaining findings"}
    ]
  }]
})
```

**If user chooses "Comment"**:
- **USE Bash tool to execute**: `gh pr comment {number} --body "{finding text}"`
- **VERIFY** comment posted successfully (check Bash output)
- Continue to next finding

**If user chooses "Skip"**:
- Do nothing, continue to next finding

**If user chooses "Stop"**:
- Stop processing, create Z03 documentation with what's been done so far

**Document only**:
Create Z03 file (see section 9)

### 9. Create Documentation (ALWAYS)

**REGARDLESS of commenting choice, create Z03 file.**

**First, detect repository pattern:**

Use Bash tool:
```bash
# Scan for existing Z01/Z02 files to find ongoing directory
ONGOING_DIR=$(find . -name "Z0[12]_*.md" -type f 2>/dev/null | head -1 | xargs dirname)

# If not found, check common directories
if [ -z "$ONGOING_DIR" ]; then
  if [ -d "docs/ai/ongoing" ]; then
    ONGOING_DIR="docs/ai/ongoing"
  elif [ -d ".ai/ongoing" ]; then
    ONGOING_DIR=".ai/ongoing"
  elif [ -d "docs/ongoing" ]; then
    ONGOING_DIR="docs/ongoing"
  else
    ONGOING_DIR="docs/ai/ongoing"
    mkdir -p "$ONGOING_DIR"
  fi
fi

echo "Using ONGOING_DIR: $ONGOING_DIR"
```

**Location**: `$ONGOING_DIR/Z03_{sanitized-pr-title}_review.md`

**Sanitize PR title for filename:**
- Use kebab-case: lowercase with hyphens
- Replace spaces and special chars with hyphens
- Remove quotes, slashes, colons
- Truncate to 50 characters
- Example: "Fix: User Authentication Bug" → "fix-user-authentication-bug"

**Format**:
```markdown
# PR Review: {PR Title}

**PR Number**: #{number}
**Author**: @{username}
**Date**: {date}
**Branch**: {branch}

## Findings

### Finding 1: {Issue Type} - {Description}
- **File**: {file}:{line}
- **Severity**: {severity}
- **Description**: {detailed explanation}
- **Action**: Commented / Skipped / Documented only

### Finding 2: ...
[Continue for all findings]

## Summary
- Total findings: {count}
- Commented: {count}
- Skipped: {count}
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}
```

## Red Flags - STOP and Follow Workflow

- **Skipped Step 1 (branch detection and switching)**
- **Reading CLAUDE.md BEFORE switching to PR branch (Step 2 before Step 1)**
- **Detecting ONGOING_DIR path at start instead of in Step 9 (wastes time)**
- **Reading Z01/Z02 files BEFORE switching to PR branch**
- **Not on the correct PR branch when analyzing code**
- **Using gh pr view without PR number when user provided URL**
- CLAUDE.md exists but was not read
- Not passing CLAUDE.md constraints to feature-research
- Reading PR code directly without gh CLI
- Analyzing code without feature-research skill
- Skipping user choice step (not using AskUserQuestion)
- **Suggesting "next steps" in plain text after presenting findings**
- **Asking "would you like me to..." instead of using AskUserQuestion tool**
- **Offering options in prose instead of AskUserQuestion structured format**
- Not creating Z03 documentation
- Posting comments without asking user first
- **Drafting comments but not posting them with gh commands**
- **Documenting findings in Z03 instead of posting to PR when user chose 'Comment'**
- Making assumptions about what user wants

**All of these mean**: Stop. Follow the workflow exactly.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll offer helpful next steps as plain text" | **NO. Use AskUserQuestion tool. NOT plain text suggestions.** |
| "Let me ask 'would you like me to...' in prose" | **NO. That's NOT using AskUserQuestion. Use the TOOL.** |
| "I'll give user options to choose from" | **NO. Use AskUserQuestion tool with structured options. NOT freeform text.** |
| "Findings presented, now suggest actions" | **NO. Do NOT suggest. Use AskUserQuestion tool IMMEDIATELY after presenting findings.** |
| "I can see what user wants, skip AskUserQuestion" | **NO. Use AskUserQuestion. Not optional. STOP and ask.** |
| "User obviously wants comments, no need to ask" | **NO. ALWAYS ask. User might want document-only. Use AskUserQuestion.** |
| "I'll just start commenting, user can stop me" | **NO. Ask BEFORE any action. Use AskUserQuestion NOW.** |
| "Findings are presented, I can proceed" | **NO. Step 7 requires AskUserQuestion. You have NOT done step 7 yet.** |
| "I drafted comments, that's enough" | **NO. Use Bash tool to EXECUTE gh pr comment. Draft is not posted.** |
| "I'll document in Z03, no need to post" | **NO. User chose 'Comment' = post to PR. Use gh commands.** |
| "PR is simple, I can review directly" | feature-research finds issues you'll miss. Use it. |
| "I'll just look at the code quickly" | Quick reviews miss systematic issues. Use gh + feature-research. |
| "I know what user wants from context" | Context can mislead. Use AskUserQuestion. |
| "Just post comments, no need for Z03" | Documentation creates audit trail. Always create Z03. |
| "Time pressure, skip systematic workflow" | Systematic workflow is FASTER than ad-hoc review. |
| "Senior engineer approved, light review OK" | Independent review requires systematic approach. Use workflow. |
| "Should I use gh api .../replies to thread comments?" | **NO.** This skill posts NEW review comments (top-level). Use `gh pr comment` or `gh pr review`. The `gh api .../replies` is ONLY for feature-prfix (replying to existing threads). |
| "I'll read CLAUDE.md first, then switch branches" | **NO.** Switch to PR branch FIRST (Step 1). THEN read CLAUDE.md (Step 2). Wrong order = wrong context. |
| "Context files probably same on all branches" | **NO.** PR branch may have different CLAUDE.md, Z01/Z02 files, or new files. Switch FIRST. |
| "I'm on a branch, probably the right one" | **NO.** ALWAYS verify and switch to PR branch. User may be on wrong branch. |
| "User provided URL, I can extract PR number in step 3" | **NO.** Extract in step 1 and switch branches FIRST. Code analysis requires correct branch. |
| "gh pr view will work without switching" | **NO.** gh pr view works, but code files won't match PR. Switch BEFORE analyzing. |
| "TodoWrite adds overhead, skip it" | **NO.** TodoWrite provides user visibility and prevents skipped steps. MANDATORY. |
| "I can track steps mentally" | **NO.** Mental tracking fails under pressure. Use TodoWrite tool NOW. |
| "Comment posting is quick, skip tracking" | **NO.** Posting is critical and error-prone. Track all steps. |

## Error Handling

**No PR found**:
```
No PR found for current branch '{branch}'.
Options:
- Specify branch: [skill] feature-prreview --branch other-branch
- Create PR first: gh pr create
```

**gh CLI not installed**:
```
GitHub CLI required. Install:
- macOS: brew install gh
- Linux: See https://cli.github.com
Then authenticate: gh auth login
```

**feature-research unavailable**:
Fallback to Read tool for basic code context (less systematic, but workable)

**No changed files**:
```
PR has no changed files. This may indicate:
- Draft PR not yet pushed
- PR already merged
- Git sync issue
```

## Success Criteria

You followed the workflow correctly if:
- ✓ **Extracted PR number from URL or user input**
- ✓ **Verified current branch and switched to PR branch if needed**
- ✓ Used gh pr view and gh pr diff on correct branch
- ✓ Invoked feature-research skill
- ✓ Presented structured findings
- ✓ Used AskUserQuestion for user choice
- ✓ Created Z03 documentation file
- ✓ **Posted comments with Bash tool executing gh commands (not just drafts)**
- ✓ **Verified each comment/review posted successfully (checked Bash output)**
- ✓ Posted comments only after user approval
- ✓ Resisted all rationalization pressures

## When NOT to Use This Skill

- When you need to CREATE a PR (use feature-document instead)
- When fixing PR comments (use feature-prfix instead)
- When reviewing non-PR code changes (use feature-research directly)
