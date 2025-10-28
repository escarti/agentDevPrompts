---
name: feature-research
description: Use when starting any feature implementation, before planning or coding, to produce a thorough directive specification - systematically researches codebase, APIs, data shapes, security, and edge cases, separating all ambiguities into structured clarification format
---

# Feature Research

## Overview

Systematically research a feature request to produce a single directive specification with zero open questions. All ambiguities are extracted into a structured CLARIFY file for user resolution.

## When to Use

- User requests new feature or significant enhancement
- Before using superpowers:writing-plans or superpowers:brainstorming
- When thorough technical research is needed
- When you need to understand integration points, APIs, data shapes, security considerations

## Core Pattern

```
Feature Request
    ↓
Research codebase systematically
    ↓
Produce 2 files:
  - docs/ai/ongoing/Z01_{feature}_research.md (directive specification, zero questions)
  - docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md (structured questions only)
    ↓
User answers CLARIFY
    ↓
Update docs/ai/ongoing/Z01_research.md with answers
    ↓
Hand to planning agent
```

## Required Deliverables

**Exactly 2 files:**

1. **`docs/ai/ongoing/Z01_{feature}_research.md`** - Directive specification
   - What to implement (no questions, no options)
   - Files to change with approximate line ranges
   - APIs, data shapes, integration points
   - Security, edge cases, failure modes
   - Environment requirements
   - Test requirements

2. **`docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`** - Structured questions
   - Use exact format below
   - No explanations, no context
   - User will answer inline

## CLARIFY File Format

```markdown
Agent question: Should we use OAuth 2.0 or SAML?
User response:

Agent question: What is the expected request volume (requests/second)?
User response:

Agent question: Should authentication be at API Gateway or application level?
User response:
```

**Critical**: Leave "User response:" blank. No explanations. Just questions.

## Research Checklist

Cover ALL of these areas in docs/ai/ongoing/Z01_research.md:

- [ ] APIs and endpoints (existing and new)
- [ ] Data shapes and schemas
- [ ] Configuration changes needed
- [ ] Integration points with existing code
- [ ] Test requirements (unit, integration, e2e)
- [ ] Environment variables and secrets
- [ ] Edge cases and error handling
- [ ] Failure modes and recovery
- [ ] Security considerations
- [ ] Performance implications

## Implementation

### Step 1: Explore Codebase

```bash
# Find relevant files
glob "**/*auth*" "**/*api*"

# Search for patterns
grep "authentication" --type py
grep "class.*API" --type py

# Read key files
read path/to/relevant/file.py
```

### Step 2: Extract Feature Name

From request "add OAuth authentication" → feature name: `oauth_authentication`

### Step 3: Create Research File

**File**: `docs/ai/ongoing/Z01_{feature}_research.md`

**Structure**:
```markdown
# {Feature} Research

## Summary
One paragraph: what is being built and why.

## Current State
What exists now. Files: path/to/file.py:123-145

## Proposed Implementation

### Architecture
How it fits into existing system.

### Files to Change
- path/to/file.py:50-75 - Add auth middleware
- path/to/config.py:20-30 - Add auth config

### Data Shapes
```python
# Example schemas
class UserAuth:
    user_id: str
    token: str
    expires_at: datetime
```

### APIs
- Endpoint: POST /auth/login
- Request: {username, password}
- Response: {token, expires_at}

### Integration Points
Where this connects to existing code.

### Security Considerations
- Token storage: httpOnly cookies
- HTTPS required
- Rate limiting: 5 req/min per IP

### Edge Cases
- Token expiration
- Concurrent logins
- Network failures

### Test Requirements
- Unit: auth validation logic
- Integration: full login flow
- E2E: browser authentication

### Environment Variables
- AUTH_SECRET_KEY
- AUTH_TOKEN_TTL
- AUTH_PROVIDER_URL
```

### Step 4: Create CLARIFY File

**File**: `docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`

Every ambiguity, technology choice, or missing requirement goes here:

```markdown
Agent question: <concise question>
User response:

Agent question: <next question>
User response:
```

### Step 5: Verify Zero Questions in Z01

Check docs/ai/ongoing/Z01_research.md for:
- "Should we...?"
- "Options include..."
- "Alternatively..."
- "We could..."

**If found**: Move to CLARIFY file.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating 3+ documents | Only 2 files: docs/ai/ongoing/Z01_research + Z01_CLARIFY |
| Questions in Z01_research.md | Move ALL questions to CLARIFY |
| Making technology decisions | List as CLARIFY questions |
| Vague file references | Include path + approximate line ranges |
| Missing coverage areas | Use checklist above |
| Explaining CLARIFY questions | Just question + blank response |

## Red Flags - STOP and Fix

- More than 2 files created
- "Option A vs Option B" in docs/ai/ongoing/Z01_research.md
- "We could use X or Y" anywhere in Z01
- No file paths mentioned
- No line ranges provided
- Missing areas from checklist
- CLARIFY has explanations or context

**All of these mean**: Review and fix before proceeding.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Multiple audiences need different docs" | Planning agent handles that. Research = 2 files only. |
| "Questions need context for user" | User has conversation context. CLARIFY = questions only. |
| "User suggested solution, so proceed" | Still list as CLARIFY question. User confirms inline. |
| "This is obvious, no need to clarify" | If it's a decision, it goes in CLARIFY. No assumptions. |
| "Research comprehensive = many documents" | Research complete = ONE directive doc + ONE clarify doc. |
| "File paths will be in planning step" | Research includes approximate files + line ranges NOW. |

## Example: OAuth Research

**Bad** (makes decisions, multiple docs, questions in main doc):
- OAuth_Executive_Summary.md
- OAuth_Technical_Spec.md
- OAuth_Methodology.md
- Contains: "We recommend FastAPI or Flask..."
- Contains: "Should we use PKCE? This depends on..."

**Good** (directive, 2 files, zero questions in main):
- docs/ai/ongoing/Z01_oauth_authentication_research.md
  - States: "Use FastAPI with Authlib library"
  - Lists: src/api/auth.py:10-50, src/config.py:5-15
  - Covers: APIs, data, security, edge cases, tests, env vars
  - Zero questions
- docs/ai/ongoing/Z01_CLARIFY_oauth_authentication_research.md
  - "Agent question: FastAPI or Flask for API framework?"
  - "Agent question: Expected user volume (concurrent users)?"
  - No explanations

## After CLARIFY Answered

1. User fills in responses in docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md
2. Update docs/ai/ongoing/Z01_{feature}_research.md with answered information
3. Verify zero ambiguities remain
4. Hand off to superpowers:writing-plans

## Success Criteria

Research is complete when:
- [ ] Exactly 2 files exist: docs/ai/ongoing/Z01_research.md + Z01_CLARIFY.md
- [ ] Z01_research.md has zero questions
- [ ] CLARIFY uses exact format (question + blank response)
- [ ] All checklist areas covered
- [ ] File paths + line ranges included
- [ ] Technology choices resolved (either specified or in CLARIFY)
- [ ] Implementer can code without making decisions
