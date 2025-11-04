# PR Workflow Skills Design

**Date**: 2025-11-04
**Status**: Approved
**Skills**: feature-prreview, feature-prfix

## Overview

Two new skills for PR review and fix workflows:
- **feature-prreview**: Review PR changes using feature-research, present findings, offer commenting/documentation options
- **feature-prfix**: Address PR review comments using feature-research assessment, offer fix/refute/documentation options

## Requirements Summary

**Decisions Made**:
- PR Detection: GitHub CLI (gh) only
- Analysis Method: Use existing feature-research skill
- Comment Format: Let user choose per-review (separate comments vs single review)
- Assessment Method: Use feature-research on relevant code sections
- File Location: docs/ai/ongoing/ (consistent with Z01/Z02 pattern)
- Architecture: Two independent skills (clear separation, minimal duplication acceptable)

## Architecture

**Skill Structure**:
```
skills/
├── feature-prreview/
│   └── SKILL.md
└── feature-prfix/
    └── SKILL.md

commands/
├── feature-prreview.md (simple wrapper calling skill)
└── feature-prfix.md (simple wrapper calling skill)
```

**Design Principle**: Two independent, self-contained skills. Each handles its own:
- gh CLI calls
- feature-research invocations
- User interaction flow
- Documentation generation

Some duplication is acceptable for clarity and maintainability.

## feature-prreview Skill

### Purpose
Review PR changes, analyze with feature-research, present findings, handle documentation/commenting

### Workflow

1. **PR Detection**
   - Use `gh pr view` to get current branch PR
   - Accept optional branch name parameter: `gh pr view [branch]`
   - Error gracefully if no PR found

2. **Change Analysis**
   - Get PR diff: `gh pr diff`
   - Extract list of changed files
   - Invoke feature-research skill on changed files
   - Parse research output to extract findings (security, quality, patterns)

3. **Present Findings**
   - Display research findings in structured format
   - Show file, line, issue type, description for each finding

4. **User Decision Point**
   - Use AskUserQuestion with three options:
     - **"Comment all"**: Write all findings as PR comments
     - **"Review per-finding"**: Loop through each finding, ask user to comment/skip/stop
     - **"Document only"**: Write to Z03_{pr-title}_review.md

5. **Comment Format Sub-choice** (if commenting selected)
   - Use AskUserQuestion to choose:
     - Separate comments: `gh pr comment` for each finding
     - Single review batch: `gh pr review --comment` with all findings

6. **Execute Choice**
   - Post comments using selected format
   - OR create markdown documentation

### GitHub CLI Commands
- `gh pr view` - Get current PR info
- `gh pr view [branch]` - Get PR for specific branch
- `gh pr diff` - Get file changes
- `gh pr comment [number] --body "text"` - Add single comment
- `gh pr review [number] --comment --body "text"` - Create review
- `gh api` for inline comments with file:line positioning if needed

### Output Files
**Location**: `docs/ai/ongoing/Z03_{sanitized-pr-title}_review.md`

**Format**:
```markdown
# PR Review: {PR Title}

**PR Number**: #123
**Author**: @username
**Date**: 2025-11-04
**Branch**: feature/auth

## Findings

### Finding 1: Missing input validation
- **File**: auth.ts:45
- **Type**: Security
- **Description**: User input not sanitized before database query
- **Action**: Commented / Skipped / Documented only

[Additional findings...]

## Summary
- Total findings: 8
- Commented: 5
- Skipped: 3
```

### Error Handling
- No PR found → "No PR found for current branch. Specify branch or create PR first."
- gh CLI not installed → "GitHub CLI required. Install: brew install gh"
- feature-research unavailable → Fallback to basic code reading with Read tool
- Invalid branch → List available branches with PRs

## feature-prfix Skill

### Purpose
Address PR review comments, assess validity using feature-research, fix or refute based on user choice

### Workflow

1. **PR Detection**
   - Same as feature-prreview: `gh pr view` or accept branch parameter

2. **Fetch Comments**
   - Use `gh pr view --comments --json comments`
   - Parse structured JSON: file, line, body, author, id

3. **Assess Comments**
   - For each comment:
     - Identify relevant code section (file:line)
     - Invoke feature-research skill on that specific area
     - Generate assessment:
       - Is the comment valid? (identifies real issue)
       - Is it actionable? (can be fixed programmatically)
       - Context/reasoning

4. **Present Assessments**
   - Display all comments with AI assessment
   - Format: Comment text → Assessment → Suggested action

5. **User Decision Point**
   - Use AskUserQuestion with three options:
     - **"Fix all valid, refute invalid"**: Auto-apply fixes, respond to disagreements
     - **"Review per-finding"**: Loop through each (fix yes/no, refute yes/no, skip)
     - **"Document only"**: Write to Z04_{pr-title}_fix.md

6. **Execute Choice**
   - Apply code fixes using Edit tool
   - Respond to comments: `gh pr comment [number] --body-file response.txt` (reply to specific comment ID)
   - OR create markdown documentation

### GitHub CLI Commands
- `gh pr view --comments --json comments` - Fetch all review comments
- `gh pr comment [number] --body "response"` - Reply to comment
- `gh api` for comment replies with proper threading

### Output Files
**Location**: `docs/ai/ongoing/Z04_{sanitized-pr-title}_fix.md`

**Format**:
```markdown
# PR Fix: {PR Title}

**PR Number**: #123
**Reviewer**: @reviewer-username
**Date**: 2025-11-04
**Branch**: feature/auth

## Comments Addressed

### Comment 1: Add input validation
- **File**: auth.ts:45
- **Reviewer**: @reviewer
- **Comment**: "This needs input validation"
- **Assessment**: Valid - missing sanitization could allow SQL injection
- **Action**: Fixed - Added validation using validator.escape()
- **Status**: ✓ Applied

### Comment 2: Extract to helper function
- **File**: auth.ts:89
- **Reviewer**: @reviewer
- **Comment**: "Extract this logic to a helper"
- **Assessment**: Subjective - current implementation is clear and only used once
- **Action**: Refuted - Explained YAGNI principle, no duplication exists yet
- **Status**: ✓ Responded

[Additional comments...]

## Summary
- Total comments: 12
- Fixed: 8
- Refuted: 2
- Skipped: 2
```

### "Refute" Behavior
When AI assesses a comment as invalid/non-actionable and user chooses to refute:
- Post reply to the specific comment
- Explain reasoning clearly (e.g., "This is intentional because X" or "The suggested change would break Y")
- Reference code context from feature-research analysis
- Maintain respectful, technical tone

### Error Handling
- Same as feature-prreview
- Additional: No comments found → "No review comments on this PR"
- Edit tool failures → Report which fixes failed, continue with others

## Technical Implementation Details

### File Naming Convention
Sanitize PR title for filenames:
- Lowercase
- Replace spaces and special chars with hyphens
- Truncate to reasonable length (50 chars)
- Example: "Fix authentication bug #123" → `Z03_fix-authentication-bug_review.md`

### Feature-Research Integration

**For feature-prreview**:
- Invoke: `Skill tool with "feature-research"`
- Context: List of changed files from `gh pr diff --name-only`
- Parse research output for structured findings

**For feature-prfix**:
- Invoke: `Skill tool with "feature-research"`
- Context: Specific file:line from comment metadata
- Parse research assessment of code validity

**Fallback**: If feature-research unavailable, use Read tool for basic code context

### GitHub API Edge Cases
- **Draft PRs**: Treat same as regular PRs
- **Multiple PRs per branch**: Use first/primary PR
- **Closed PRs**: Warn user but allow review for documentation purposes
- **Merged PRs**: Allow review but prevent commenting

## User Experience Flows

### Typical feature-prreview Session
```
User: /feature-prreview

Skill: Detected PR #123 "Add user authentication"
Skill: Analyzing 5 changed files with feature-research...
Skill: [Structured findings display]
       - Finding 1: Missing input validation (auth.ts:45) - Security
       - Finding 2: Error not logged (login.ts:89) - Observability
       [... 6 more findings ...]

Skill: [AskUserQuestion: Comment all / Review per-finding / Document only]

User: Review per-finding

Skill: Finding 1/8: Missing input validation in auth.ts:45
       "User input not sanitized before database query"
Skill: [AskUserQuestion: Comment / Skip / Stop]

User: Comment

Skill: [Posts comment]
Skill: Finding 2/8: Error not logged in login.ts:89
[... continues through all findings ...]

Skill: ✓ Complete - Posted 5 comments, skipped 3 findings
```

### Typical feature-prfix Session
```
User: /feature-prfix

Skill: Detected PR #123 with 12 review comments
Skill: Assessing comments with feature-research...
Skill: [Structured assessments display]
       - Comment 1: Add validation (auth.ts:45) - Valid, actionable
       - Comment 2: Extract helper (auth.ts:89) - Subjective, premature
       [... 10 more comments ...]

Skill: [AskUserQuestion: Fix valid+refute invalid / Review per-finding / Document only]

User: Fix valid+refute invalid

Skill: Applying 8 fixes...
       ✓ Fixed validation in auth.ts:45
       ✓ Fixed error handling in login.ts:89
       ✓ Added type annotation in user.ts:34
       [... 5 more fixes ...]

Skill: Refuting 2 comments with explanation...
       ✓ Explained intentional design choice on user.ts:23
       ✓ Explained YAGNI principle on helper.ts:56

Skill: ✓ Complete - 8 fixes applied, 2 refutations posted, 2 skipped
```

## Testing Strategy

### Pre-Release Testing (RED-GREEN-REFACTOR)
Use superpowers:writing-skills methodology:

**RED Phase**:
- Create test PR with intentional issues
- Run feature-prreview WITHOUT skill, document failures
- Add review comments to test PR
- Run feature-prfix WITHOUT skill, document failures

**GREEN Phase**:
- Write minimal skill addressing failures
- Verify skill guides agent to correct behavior
- Test all three user choice paths for each skill

**REFACTOR Phase**:
- Identify rationalizations from testing
- Add explicit counters to skills
- Re-test until bulletproof

### Edge Cases to Test
- No PR on current branch
- Multiple files changed (10+)
- No review comments
- Comments on deleted lines
- Conflicting comments from multiple reviewers
- gh CLI not authenticated
- Network failures during gh commands

## Success Criteria

**feature-prreview**:
- ✓ Detects PR correctly (current branch or specified)
- ✓ Analyzes changes using feature-research
- ✓ Presents findings clearly
- ✓ All three user choice paths work (comment all / per-finding / document)
- ✓ Comments posted correctly (separate or batched)
- ✓ Z03 file created with proper format

**feature-prfix**:
- ✓ Fetches review comments correctly
- ✓ Assesses comments using feature-research
- ✓ Presents assessments clearly
- ✓ All three user choice paths work (auto / per-finding / document)
- ✓ Fixes applied correctly (Edit tool)
- ✓ Refutations posted as comment replies
- ✓ Z04 file created with proper format

## Future Enhancements (Out of Scope)

- Multi-platform support (GitLab, Bitbucket)
- AI-generated fix suggestions (not just detection)
- Integration with CI/CD status checks
- Batch processing multiple PRs
- PR review templates
- Custom review checklists per project

## Implementation Notes

- Start with feature-prreview (simpler, no code changes)
- Test thoroughly before implementing feature-prfix
- Use TodoWrite to track implementation tasks
- Follow superpowers:writing-skills for skill creation
- Add slash commands AFTER skills are tested
- Update CLAUDE.md with new skill documentation patterns if needed
