---
name: feature-prreview
description: Use when reviewing pull request changes before providing feedback - analyzes PR with feature-research, presents structured findings, offers user choices for commenting or documentation
---

# feature-prreview: PR Review with Research-Driven Analysis

## Overview

**Systematically review PR changes using feature-research skill, present findings, and handle user choices about commenting vs documentation.**

**Core principle**: Don't review code ad-hoc. Use gh CLI + feature-research + structured workflow.

## Mandatory Workflow

**YOU MUST follow this exact sequence. No exceptions.**

### 1. Detect PR

```bash
# Get PR for current branch
gh pr view

# Or for specific branch
gh pr view [branch-name]
```

**If no PR found**: Error gracefully - "No PR found for current branch. Specify branch or create PR first."

**Extract**: PR number, title, author, branch name

### 2. Get Changed Files

```bash
gh pr diff --name-only
```

**Extract**: List of all changed file paths

### 3. Analyze with feature-research

**REQUIRED**: Use Skill tool to invoke `feature-workflow:feature-research` on the changed files.

**Context to provide feature-research**:
- List of changed files
- PR title and description
- Request: "Identify security issues, code quality problems, missing error handling, test gaps"

**Parse research output** for structured findings:
- File path and line number
- Issue type (security/quality/testing/observability)
- Description of problem
- Severity (critical/high/medium/low)

### 4. Present Findings

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

### 5. User Decision Point (REQUIRED)

**YOU MUST use AskUserQuestion. Do not skip this step.**

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

### 6. Comment Format Sub-choice (IF commenting selected)

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

### 7. Execute User Choice

**Comment all** (separate):
```bash
gh pr comment {number} --body "Finding 1: {description}

File: {file}:{line}
Severity: {severity}

{details}"
# Repeat for each finding
```

**Comment all** (single review):
```bash
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

**Document only**:
Create Z03 file (see section 8)

### 8. Create Documentation (ALWAYS)

**REGARDLESS of commenting choice, create Z03 file.**

**Location**: `docs/ai/ongoing/Z03_{sanitized-pr-title}_review.md`

**Sanitization**: lowercase, replace spaces/special chars with hyphens, truncate to 50 chars

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

- Reading PR code directly without gh CLI
- Analyzing code without feature-research skill
- Skipping user choice step
- Not creating Z03 documentation
- Posting comments without asking user first
- Making assumptions about what user wants

**All of these mean**: Stop. Follow the workflow exactly.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "PR is simple, I can review directly" | feature-research finds issues you'll miss. Use it. |
| "I'll just look at the code quickly" | Quick reviews miss systematic issues. Use gh + feature-research. |
| "User obviously wants comments, skip asking" | User might want documentation only. Always ask. |
| "I know what user wants from context" | Context can mislead. Use AskUserQuestion. |
| "Just post comments, no need for Z03" | Documentation creates audit trail. Always create Z03. |
| "Time pressure, skip systematic workflow" | Systematic workflow is FASTER than ad-hoc review. |
| "Senior engineer approved, light review OK" | Independent review requires systematic approach. Use workflow. |

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
- ✓ Posted comments only after user approval
- ✓ Resisted all rationalization pressures

## When NOT to Use This Skill

- When you need to CREATE a PR (use feature-document instead)
- When fixing PR comments (use feature-prfix instead)
- When reviewing non-PR code changes (use feature-research directly)
