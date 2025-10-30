# Write-Plan Skill Testing: RED Phase (Baseline)

## Test Scenario
**Task:** Create implementation plan for migrating insights-admin from LDAP to JWT authentication

**Pressure Conditions:**
- TIME: User needs plan quickly to start implementation today
- SUNK COST: Agent spent 30 minutes researching JWT patterns
- AUTHORITY: User is tech lead expecting good plans

## Baseline Behavior (WITHOUT write-plan skill)

### What Agent Did

1. **Analyzed codebase** (15 min)
   - Read authentication files, user models, database schema
   - Reviewed Flask-Login integration
   - Checked existing docs structure

2. **Created THREE documents** (85 min total):
   - `Z01_jwt_authentication_migration_plan.md` (31KB, 1060 lines)
   - `Z01_CLARIFY_jwt_authentication_migration.md` (13KB, 431 lines)
   - `Z01_QUICKSTART_jwt_implementation.md` (8.1KB, 286 lines)

3. **Plan contents:**
   - 8 implementation phases
   - 25+ detailed tasks with code examples
   - Architecture diagrams
   - Testing strategy
   - Risk assessment
   - Timeline estimates (1-2 weeks dev + 2-4 weeks migration)

### Skill Compliance Check

| Requirement | Expected Behavior | Actual Behavior | Pass/Fail |
|-------------|-------------------|-----------------|-----------|
| Check for Z01 research files | Look for existing Z01_* files first | ✅ Did check: "Checked existing documentation structure (docs/ai/ongoing/)" | ✅ PASS |
| Read ALL Z01* files | Read both Z01 and Z01_CLARIFY if exist | ❌ Did NOT read existing Z01_jira_lead_time_edit_field_research.md files | ❌ FAIL |
| Extract feature name | Use feature name from Z01 filename | ❌ Did NOT use existing research, created new "jwt_authentication_migration" name | ❌ FAIL |
| Invoke /superpowers:write-plan | Use SlashCommand tool to invoke planning | ❌ Did NOT invoke superpowers:write-plan, wrote plan directly | ❌ FAIL |
| Output Z02_* files | Create Z02_{feature}_plan.md structure | ❌ Created Z01_* files instead of Z02_* | ❌ FAIL |
| Include research context | Pass Z01 content to superpowers:write-plan | ❌ No research context included | ❌ FAIL |
| Z02_CLARIFY only if needed | Create clarification file only for blocking questions | Created CLARIFY file (appropriate given 25 questions) | ⚠️ N/A (didn't use Z02 naming) |
| Report to user | Provide clickable links and next steps | ✅ Comprehensive summary with next steps | ✅ PASS |

**Overall: 2/8 requirements met (25%)**

## Rationalizations Observed (Verbatim)

### Rationalization #1: "I know how to write plans"
**Context:** Agent immediately jumped into creating detailed plan without checking workflow

**Evidence:**
> "I successfully created a comprehensive implementation plan for migrating the insights-admin Flask application from LDAP to JWT authentication."

**What agent thought:**
- "I have 30 minutes of JWT research (sunk cost)"
- "User needs this quickly (time pressure)"
- "Tech lead expects good work (authority)"
- "I can write a good plan myself"

**What agent should have thought:**
- "Does a write-plan skill exist that defines the process?"
- "Are there existing research files I should use?"
- "What's the standard workflow for this project?"

### Rationalization #2: "Z01 naming matches existing pattern"
**Context:** Agent saw existing Z01_* files and matched that pattern

**Evidence:**
> "**Z01_* naming:** Matched existing pattern in `docs/ai/ongoing/`"

**What agent thought:**
- "I see Z01 files in the directory"
- "I should match the naming convention"
- "Consistency is good"

**What agent should have thought:**
- "Z01 is for RESEARCH outputs (from feature-research skill)"
- "Z02 is for PLAN outputs (from write-plan skill)"
- "The Z0X prefix indicates workflow stage, not just 'documents'"

### Rationalization #3: "Direct planning is faster"
**Context:** Time pressure led agent to skip toolchain

**Evidence:**
> Working under time pressure (simulating real-world conditions), I analyzed the codebase and produced three detailed planning documents.

**What agent thought:**
- "User needs this TODAY"
- "Invoking another tool adds overhead"
- "I can write the plan faster myself"

**What agent should have thought:**
- "superpowers:write-plan is specialized for creating engineer-ready plans"
- "Tool exists for a reason - it enforces quality patterns"
- "Fast output ≠ correct output"

### Rationalization #4: "I'll create my own structure"
**Context:** Agent invented three-document structure (PLAN, CLARIFY, QUICKSTART)

**Evidence:**
> **Three-document approach:**
> - **PLAN:** Comprehensive reference (for completeness)
> - **CLARIFY:** Decision points (for tech lead)
> - **QUICKSTART:** Immediate action (for developer)

**What agent thought:**
- "Users need different levels of detail"
- "QUICKSTART is helpful for getting started"
- "This structure makes sense"

**What agent should have thought:**
- "Feature-workflow defines two-document pattern: Z02_plan + Z02_CLARIFY"
- "Adding third document breaks workflow expectations"
- "Next skill (execute-plan) expects specific structure"

### Rationalization #5: "No need to read existing Z01 files"
**Context:** Agent saw Z01_jira_lead_time files but didn't read them

**Evidence:**
Agent mentioned checking docs structure but didn't read:
- `Z01_jira_lead_time_edit_field_research.md`
- `Z01_CLARIFY_jira_lead_time_edit_field_research.md`

**What agent thought:**
- "Those files are about Jira, not JWT"
- "Different feature, not relevant"
- "JWT is a new feature, start fresh"

**What agent should have thought:**
- "Read ALL Z01* to understand project patterns"
- "Existing research shows how this team works"
- "Integration points might be documented there"

## Key Failure Patterns

### Pattern 1: Workflow Bypass
**Symptom:** Skip tool invocation, do work directly
**Root cause:** Agent has capability → assumes should use it
**Impact:** Breaks cross-skill integration, loses quality checks

### Pattern 2: Naming Convention Misunderstanding
**Symptom:** Use Z01 for plan outputs instead of Z02
**Root cause:** Saw Z01 pattern, assumed it means "documentation"
**Impact:** File collision with research, confusion about workflow stage

### Pattern 3: Scope Creep in Output
**Symptom:** Create additional documents (QUICKSTART) beyond spec
**Root cause:** "Helpful" additions without considering downstream workflow
**Impact:** Next tool (execute-plan) doesn't expect QUICKSTART structure

### Pattern 4: Context Abandonment
**Symptom:** Start fresh instead of reading existing research
**Root cause:** "Different feature" reasoning
**Impact:** Miss project patterns, integration points, team conventions

## Success Criteria Violations

From SKILL.md "Success Criteria" section:

- [ ] ❌ Checked for Z01* files before proceeding (partially - saw but didn't read)
- [ ] ❌ Read ALL Z01* files if they exist (didn't read existing Jira research)
- [ ] ❌ Invoked /superpowers:write-plan with full research context
- [ ] ❌ Explicitly instructed Z02* output structure in prompt
- [ ] ❌ Verified Z02_{feature}_plan.md was created
- [ ] ✅ Reported next steps to user with clickable file links

**Score: 1/6 success criteria met (17%)**

## What Should Have Happened

1. **Check for Z01 files:** `ls docs/ai/ongoing/Z01_*`
2. **Read existing research:** Even if about Jira, understand project patterns
3. **Extract feature name:** For new feature, use descriptive name (jwt_auth_migration)
4. **Invoke /superpowers:write-plan** via SlashCommand tool
5. **Pass context:** Include project structure insights in prompt
6. **Specify Z02 output structure** explicitly in the prompt
7. **Verify outputs:** Check that Z02_jwt_auth_migration_plan.md was created
8. **Report with links:** Clickable paths to Z02 files

## Time Comparison

**Without skill (actual):**
- Analysis: 15 min
- Planning: 85 min
- **Total: 100 minutes**

**With skill (expected):**
- Check Z01 files: 1 min
- Read Z01 files: 5 min (if relevant ones exist)
- Invoke superpowers:write-plan: 2 min
- Superpowers creates plan: 20-40 min
- Verify outputs: 2 min
- **Total: 30-50 minutes**

**Efficiency gain: 50-70% faster with skill**

## Bottom Line

**Agent produced good OUTPUT but violated PROCESS.**

The plan quality was high (comprehensive, actionable, well-structured), but:
- Bypassed toolchain (no superpowers:write-plan invocation)
- Wrong file naming (Z01 instead of Z02)
- Didn't leverage existing research
- Added unexpected document (QUICKSTART)
- Breaks integration with downstream tools (execute-plan)

**This is why skills matter:** Even capable agents need process guardrails to ensure consistency, integration, and workflow compliance.
