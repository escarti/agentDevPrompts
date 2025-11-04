---
name: feature-prfix
description: Use when addressing PR review comments - assesses comment validity with feature-research, distinguishes bugs from style preferences, fixes valid issues or refutes invalid ones with evidence-based responses
---

# feature-prfix: Address PR Review Comments with Research-Driven Assessment

## Overview

**Systematically assess PR review comments using feature-research skill, distinguish valid bugs from subjective preferences, and handle user choices about fixing vs refuting.**

**Core principle**: Don't blindly accept all reviewer comments. Verify claims with feature-research before fixing or refuting.

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

### 2. Fetch Review Comments

```bash
gh pr view --comments --json comments
```

**Parse JSON** to extract:
- Comment ID
- File path and line number
- Comment body text
- Reviewer username
- Comment timestamp

**If no comments**: "No review comments on this PR. Nothing to address."

### 3. Assess Each Comment with feature-research

**REQUIRED**: For EACH comment, use Skill tool to invoke `feature-workflow:feature-research` on the specific code section.

**Context to provide feature-research**:
- File path and line number from comment
- Comment text from reviewer
- Request: "Assess if this comment identifies a real bug/security issue or is a subjective style preference. Provide technical reasoning."

**Parse research output** to generate assessment:
- **Is claim valid?** (identifies real bug/security issue vs subjective preference)
- **Is it actionable?** (can be fixed programmatically)
- **Category**: bug / security / observability / style / subjective
- **Technical reasoning**: Why valid or invalid

### 4. Present Assessments

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
[Continue for all comments]

Summary:
- Total comments: {count}
- Valid (should fix): {count}
- Invalid (should refute): {count}
- Discuss (unclear): {count}
```

### 5. User Decision Point (REQUIRED)

**YOU MUST use AskUserQuestion. Do not skip this step.**

```typescript
AskUserQuestion({
  questions: [{
    question: "How would you like to handle these review comments?",
    header: "Action",
    multiSelect: false,
    options: [
      {
        label: "Auto: fix valid, refute invalid",
        description: "Automatically apply fixes and post refutations based on AI assessment"
      },
      {
        label: "Review per-comment",
        description: "Go through each comment, decide fix/refute/skip individually"
      },
      {
        label: "Document only",
        description: "Save assessments to Z04 file without applying changes or posting replies"
      }
    ]
  }]
})
```

### 6. Execute User Choice

**Auto: fix valid, refute invalid**:

For each VALID comment:
```bash
# Use Edit tool to apply fix
Edit({
  file_path: "{file}",
  old_string: "{current code}",
  new_string: "{fixed code}"
})
```

For each INVALID comment:
```bash
# Post refutation with technical reasoning
gh pr comment {number} --body "Re: {comment summary}

Thank you for the review. I've assessed this suggestion and believe the current implementation is correct because:

{technical reasoning from feature-research}

{specific explanation}

Would you like to discuss this further?"
```

**Review per-comment**:

Loop through each comment, ask user:
```typescript
AskUserQuestion({
  questions: [{
    question: "Comment {n}/{total}: {description} ({file}:{line}). Assessment: {valid/invalid}. What action?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Fix", description: "Apply the fix using Edit tool"},
      {label: "Refute", description: "Post technical explanation as reply"},
      {label: "Skip", description: "Skip this comment, continue to next"},
      {label: "Stop", description: "Stop processing remaining comments"}
    ]
  }]
})
```

**Document only**:
Create Z04 file (see section 7)

### 7. Create Documentation (ALWAYS)

**REGARDLESS of action choice, create Z04 file.**

**Location**: `docs/ai/ongoing/Z04_{sanitized-pr-title}_fix.md`

**Sanitization**: lowercase, replace spaces/special chars with hyphens, truncate to 50 chars

**Format**:
```markdown
# PR Fix: {PR Title}

**PR Number**: #{number}
**Reviewer**: @{reviewer-username}
**Date**: {date}
**Branch**: {branch}

## Comments Addressed

### Comment 1: {Comment summary}
- **File**: {file}:{line}
- **Reviewer**: @{reviewer}
- **Comment**: "{full comment text}"
- **Assessment**: Valid / Invalid - {reasoning}
- **Action**: Fixed / Refuted / Skipped
- **Status**: ✓ Applied / ✓ Responded / ⊘ Skipped

### Comment 2: ...
[Continue for all comments]

## Summary
- Total comments: {count}
- Fixed: {count}
- Refuted: {count}
- Skipped: {count}
- Categories:
  - Bugs: {count}
  - Security: {count}
  - Style: {count}
  - Subjective: {count}
```

## Refutation Best Practices

When refuting invalid/subjective comments:

**DO:**
- Thank reviewer for the feedback
- Explain technical reasoning clearly
- Reference specific code context from feature-research
- Offer to discuss further
- Maintain respectful, professional tone
- Provide evidence (e.g., "This pattern is used 15 times in the codebase")

**DON'T:**
- Be dismissive or defensive
- Say "you're wrong"
- Refute without technical reasoning
- Make it personal
- Use absolute language ("never", "always", "obviously")

**Example good refutation**:
```
Thank you for the suggestion to extract this logic to a helper function.

I've assessed this and believe keeping it inline is better because:

1. The logic is only 4 lines and used once in the codebase
2. Extracting now would be premature abstraction (YAGNI principle)
3. The context is clear within the current function scope

If we find a second use case for this logic, I'd be happy to extract it then. Does that sound reasonable, or is there a planned reuse I'm not aware of?
```

## Red Flags - STOP and Follow Workflow

- Accepting all comments without verification
- Fixing code without reading it first to verify reviewer's claim
- Not using feature-research to assess validity
- Skipping user choice step
- Not creating Z04 documentation
- Refuting without technical reasoning
- Letting authority/agreeableness pressure drive decisions

**All of these mean**: Stop. Follow the workflow exactly.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Senior engineer knows best, just fix all" | Senior engineers make mistakes too. Verify claims. |
| "Not worth arguing about style" | Style changes have maintenance cost. Require justification. |
| "Faster to fix than debate" | Blind fixes accumulate technical debt. Assess first. |
| "Don't want to seem difficult" | Technical discussions are normal. Respectful refutation is professional. |
| "Pick your battles" | Each comment should be evaluated independently on technical merit. |
| "Maybe they know future requirements" | If future requirements exist, reviewer should mention them. Ask. |
| "It doesn't hurt to add" | Every line has maintenance cost. Redundant code hurts. |
| "I can assess quickly without feature-research" | Quick assessments miss context. Use systematic research. |
| "Reviewer waiting, need to respond fast" | Fast wrong responses waste more time. Take time to verify. |

## Error Handling

**No PR found**:
```
No PR found for current branch '{branch}'.
Options:
- Specify branch: [skill] feature-prfix --branch other-branch
- Check if PR exists: gh pr list
```

**No comments**:
```
No review comments found on PR #{number}.
This PR either:
- Has no reviews yet
- Has only general comments (not line-specific)
- Has already had all comments resolved
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

**Edit tool failures**:
Report which fixes failed, continue with others. Add to Z04 documentation with failure note.

## Success Criteria

You followed the workflow correctly if:
- ✓ Used gh pr view and gh pr view --comments
- ✓ Invoked feature-research skill for each comment
- ✓ Verified reviewer claims by reading actual code
- ✓ Categorized comments (bug/security/style/subjective)
- ✓ Presented assessments before user decision
- ✓ Used AskUserQuestion for user choice
- ✓ Applied fixes with Edit tool for valid comments
- ✓ Posted refutations with gh pr comment for invalid comments
- ✓ Created Z04 documentation file
- ✓ Resisted authority and agreeableness pressures

## When NOT to Use This Skill

- When you need to review a PR (use feature-prreview instead)
- When fixing issues found by yourself (use feature-implement instead)
- When no PR exists yet (use feature-document to create PR)
