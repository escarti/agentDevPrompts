---
name: feature-research
description: Use after brainstorming is complete but before planning implementation, when you need technical details about integration points, APIs, data shapes, or existing patterns - produces directive specification with all ambiguities extracted to structured clarification file
---

# Feature Research

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Read CLAUDE.md/docs FIRST before any code

**This skill produces 2 files: directive specification (Z01_research.md) + structured questions (Z01_CLARIFY.md)**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Read documentation FIRST (CLAUDE.md, README, ARCHITECTURE)", status: "in_progress", activeForm: "Reading project docs"},
    {content: "Step 2: Explore code (glob, grep, read files)", status: "pending", activeForm: "Analyzing codebase"},
    {content: "Step 3: Create Z01 research file (directive specification)", status: "pending", activeForm: "Writing research"},
    {content: "Step 4: Create Z01_CLARIFY file (structured questions)", status: "pending", activeForm: "Extracting ambiguities"},
    {content: "Step 5: Verify directive nature (no questions in research)", status: "pending", activeForm: "Validating specification"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## Research Output Format

**Single directive:** One clear approach (preserves existing patterns from CLAUDE.md/docs)

**Primary + 1 alternative:** Only if alternative is significantly better for specific use case
- Primary approach MUST preserve existing patterns from CLAUDE.md/docs
- Alternative approach has different trade-offs (e.g., microservice vs monolith)
- Both options have complete technical details (files, line ranges, pros/cons)
- User chooses, then update Z01_research.md to be fully directive

## Workflow Steps

### Step 1: Read Documentation FIRST

**MANDATORY FIRST - read these if they exist:**
- CLAUDE.md (patterns, conventions, forbidden approaches)
- README.md (architecture overview)
- ARCHITECTURE.md (system design)
- All documentation (glob "**/docs/**/*.md")

**Why:** CLAUDE.md contains mandatory patterns and forbidden approaches. Primary solution MUST preserve these patterns.

---

### Step 2: Explore Code

Find related files, search for patterns, read key files.

Document:
- Files to change with line ranges
- APIs and integration points
- Data shapes and types
- Security considerations
- Edge cases and failure modes
- Test requirements
- Environment variables

---

### Step 3: Create Research File

**Scan for ongoing directory:**
- Check for existing Z01 files
- Common locations: docs/ai/ongoing, .ai/ongoing, docs/ongoing
- Create default docs/ai/ongoing if none found

**Save ONGOING_DIR location** for Step 4.

**File**: `{ONGOING_DIR}/Z01_{feature}_research.md`

**Sanitize feature name:**
- Use snake_case: lowercase with underscores
- Replace spaces and special chars with underscores
- Remove quotes, slashes, colons
- Truncate to 50 characters
- Example: "OAuth 2.0 Authentication!" → "oauth_2_0_authentication"

**Structure** (key sections only):
```markdown
# {Feature} Research

## Summary
One paragraph: what and why.

## Current State
What exists. Files: path/to/file.py:123-145

## Existing Patterns & Documentation
### From CLAUDE.md
- Conventions that MUST be followed
- Architectural patterns to preserve
- Forbidden patterns/approaches

### Repository Structure
- Directory/file naming patterns

## Proposed Implementation

### Primary Approach (Preserves Existing Patterns)
- Architecture: How it fits existing system
- Files: path/to/file.py:50-75 - What changes
- Data shapes, APIs, integration points
- Security, edge cases, test requirements

### Alternative Approach (Optional - only if significantly better)
- Why different: [specific advantages]
- Architecture, files, data shapes
- Trade-offs vs primary

## Integration Points
How this connects to existing code.

## Environment Variables
- VAR_NAME - purpose
```

---

### Step 4: Create CLARIFY File

**File**: `{ONGOING_DIR}/Z01_CLARIFY_{feature}_research.md`

Every ambiguity, technology choice, or missing requirement:
```markdown
Agent question: {concise question}
User response:

Agent question: {next question}
User response:
```

**Critical**: Leave "User response:" blank. No explanations.

---

### Step 5: Verify Directive Nature

Check Z01_research.md for vague questions:
- "Should we...?" → Move to CLARIFY
- "Options include..." (vague) → Make directive OR move to CLARIFY
- "We could..." (incomplete) → Make directive OR move to CLARIFY

**Acceptable:** Primary + 1 alternative with complete details for both
**Not acceptable:** Vague alternatives, 3+ options, questions embedded

---

## Red Flags - You're Failing If:

- **Did NOT read CLAUDE.md/README/docs FIRST**
- **Primary approach violates CLAUDE.md patterns**
- **More than 2 files created**
- **No file paths or line ranges**
- **Questions embedded in Z01_research.md**
- **CLARIFY has explanations** (should be questions only)
- **Missing "Existing Patterns" section**
- **Using hardcoded paths** (detect pattern instead)
- **Vague file references** (need path + line ranges)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"No CLAUDE.md exists, skip docs"** | **NO.** Still read README, docs/. Document patterns from code. |
| **"Small feature, patterns don't matter"** | **NO.** Small violations create technical debt. Patterns ALWAYS matter. |
| **"I can see the pattern in code"** | **NO.** CLAUDE.md may forbid what looks standard. Docs are truth. |
| **"Questions need context for user"** | **NO.** User has conversation context. CLARIFY = questions only. |
| **"File paths in planning step"** | **NO.** Research includes files + line ranges NOW. |
| **"User suggested solution, proceed"** | **NO.** Still confirm via CLARIFY. No assumptions. |
| **"This alternative is better, skip primary"** | **NO.** Primary preserving patterns is REQUIRED. |
| "TodoWrite adds overhead, skip it" | **NO.** TodoWrite provides user visibility and prevents skipped steps. MANDATORY. |
| "Research is exploratory, no need to track" | **NO.** Research follows strict workflow. Track all steps with TodoWrite. |

## Success Criteria

You followed the workflow if:
- ✓ Read CLAUDE.md/README/docs FIRST
- ✓ "Existing Patterns" section in Z01_research.md
- ✓ Primary approach preserves patterns from CLAUDE.md
- ✓ Exactly 2 files: Z01_research.md + Z01_CLARIFY.md
- ✓ Z01_research.md is directive (single OR primary + 1 alternative)
- ✓ If alternative: both have complete technical details
- ✓ File paths + line ranges included
- ✓ CLARIFY uses exact format (questions only, blank responses)
- ✓ Implementer can code without architectural decisions

## When to Use

Use when:
- Design direction is clear from brainstorming
- Need thorough technical research before planning
- Need to understand integration points, APIs, data shapes, security

**Don't use when:**
- Design is still unclear → Use superpowers:brainstorming first
- Simple changes (typo fixes, trivial updates)
- Already have complete technical specification

## Handoff to Planning

When research complete:
1. Announce: "Research complete. Z01_research.md ready for planning."
2. If CLARIFY exists: "Waiting for Z01_CLARIFY.md answers"
3. After answered: Update Z01_research.md, then "Using superpowers:writing-plans"

**What planning receives:**
- Patterns that MUST be preserved (from CLAUDE.md)
- Forbidden approaches to AVOID
- Files that MUST be modified (with line ranges)
- APIs/libraries required
- Security/integration requirements
- When to proceed (user approval trigger)
