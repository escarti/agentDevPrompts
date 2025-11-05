---
name: feature-prreview
description: Use when reviewing pull request changes before providing feedback - analyzes PR with feature-research, presents structured findings, offers user choices for commenting or documentation
---

# feature-prreview: PR Review with Research-Driven Analysis

## Overview

**Systematically review PR changes using feature-research skill, present findings, and handle user choices about commenting vs documentation.**

**Workflow Position:**: Flow agnostic

**Core principle**: Don't review code ad-hoc. Use gh CLI + feature-research + structured workflow.

## Progress Tracking

**MANDATORY:** Use TodoWrite tool to track workflow progress.

**At skill start, create todos for all steps:**

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Detect repository pattern", status: "in_progress", activeForm: "Detecting ONGOING_DIR path"},
    {content: "Step 1: Load project context (CLAUDE.md)", status: "pending", activeForm: "Reading CLAUDE.md"},
    {content: "Step 2: Detect PR (gh pr view)", status: "pending", activeForm: "Fetching PR details"},
    {content: "Step 3: Get changed files (gh pr diff --name-only)", status: "pending", activeForm: "Listing changed files"},
    {content: "Step 4: Analyze with feature-research", status: "pending", activeForm: "Running deep code analysis"},
    {content: "Step 5: Present findings (security/quality/testing)", status: "pending", activeForm: "Formatting review findings"},
    {content: "Step 6: User decision (AskUserQuestion: Comment all/Review/Document)", status: "pending", activeForm: "Awaiting user choice"},
    {content: "Step 7: Comment format sub-choice (Separate/Single review)", status: "pending", activeForm: "Choosing comment format"},
    {content: "Step 8: Execute user choice (post comments/review)", status: "pending", activeForm: "Posting review feedback"},
    {content: "Step 9: Create Z03 documentation", status: "pending", activeForm: "Writing Z03 file"}
  ]
})
```

**After completing each step:**
- Mark current step as `completed`
- Move `in_progress` to next step
- Update `activeForm` with current action

**Example update after Step 0:**
```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Detect repository pattern", status: "completed"},
    {content: "Step 1: Load project context (CLAUDE.md)", status: "in_progress", activeForm: "Reading CLAUDE.md"},
    {content: "Step 2: Detect PR (gh pr view)", status: "pending"},
    // ... remaining steps
  ]
})
```

**CRITICAL:** Exactly ONE todo should be `in_progress` at any time. All others are `pending` or `completed`.

## Mandatory Workflow

**YOU MUST follow this exact sequence. No exceptions.**

### 0. Detect Repository Pattern

**Detect paths before proceeding:**

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

Set variable:
- `ONGOING_DIR` - Where Z03 review file will be created

### 1. Load Project Context (MANDATORY FIRST)

**Read CLAUDE.md if it exists:**

Use Read tool:
```bash
if [ -f CLAUDE.md ]; then
  echo "Reading project guidelines..."
  # Use Read tool to read CLAUDE.md
fi
```

**Extract from CLAUDE.md (if exists):**
- Mandatory patterns code should follow
- Forbidden approaches to check for violations
- Project conventions
- Security and code quality standards

**This context is critical for identifying violations and security issues during PR review.**

### 2. Detect PR

```bash
# Get PR for current branch
gh pr view

# Or for specific branch
gh pr view [branch-name]
```

**If no PR found**: Error gracefully - "No PR found for current branch. Specify branch or create PR first."

**Extract**: PR number, title, author, branch name

### 3. Get Changed Files

```bash
gh pr diff --name-only
```

**Extract**: List of all changed file paths

### 4. Analyze with feature-research

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

### 5. Present Findings

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

### 6. User Decision Point (REQUIRED)

**STOP. YOU MUST use AskUserQuestion tool NOW. Do NOT proceed to step 7 until user responds.**

**If you are reading this, you have NOT asked the user yet. STOP and use AskUserQuestion RIGHT NOW.**

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

### 7. Comment Format Sub-choice (IF commenting selected)

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

### 8. Execute User Choice

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

**Location**: `$ONGOING_DIR/Z03_{sanitized-pr-title}_review.md` (use detected path)

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

- Skipped Step 0 (path detection)
- Skipped Step 1 (CLAUDE.md loading)
- CLAUDE.md exists but was not read
- Not passing CLAUDE.md constraints to feature-research
- Reading PR code directly without gh CLI
- Analyzing code without feature-research skill
- Skipping user choice step (not using AskUserQuestion)
- Not creating Z03 documentation
- Posting comments without asking user first
- **Drafting comments but not posting them with gh commands**
- **Documenting findings in Z03 instead of posting to PR when user chose 'Comment'**
- Making assumptions about what user wants

**All of these mean**: Stop. Follow the workflow exactly.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I can see what user wants, skip AskUserQuestion" | **NO. Use AskUserQuestion. Not optional. STOP and ask.** |
| "User obviously wants comments, no need to ask" | **NO. ALWAYS ask. User might want document-only. Use AskUserQuestion.** |
| "I'll just start commenting, user can stop me" | **NO. Ask BEFORE any action. Use AskUserQuestion NOW.** |
| "Findings are presented, I can proceed" | **NO. Step 5 requires AskUserQuestion. You have NOT done step 5 yet.** |
| "I drafted comments, that's enough" | **NO. Use Bash tool to EXECUTE gh pr comment. Draft is not posted.** |
| "I'll document in Z03, no need to post" | **NO. User chose 'Comment' = post to PR. Use gh commands.** |
| "PR is simple, I can review directly" | feature-research finds issues you'll miss. Use it. |
| "I'll just look at the code quickly" | Quick reviews miss systematic issues. Use gh + feature-research. |
| "I know what user wants from context" | Context can mislead. Use AskUserQuestion. |
| "Just post comments, no need for Z03" | Documentation creates audit trail. Always create Z03. |
| "Time pressure, skip systematic workflow" | Systematic workflow is FASTER than ad-hoc review. |
| "Senior engineer approved, light review OK" | Independent review requires systematic approach. Use workflow. |
| "Should I use gh api .../replies to thread comments?" | **NO.** This skill posts NEW review comments (top-level). Use `gh pr comment` or `gh pr review`. The `gh api .../replies` is ONLY for feature-prfix (replying to existing threads). |
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
- ✓ Used gh pr view and gh pr diff
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
