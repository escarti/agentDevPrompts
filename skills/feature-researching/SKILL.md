---
name: feature-researching
description: Use as the single feature-workflow entry point to classify idea definition, refine intent when needed, and produce a grounded feature specification
---

# Feature Research

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Verify Superpowers dependencies are available for this session
2. ☐ Create a progress plan (see below)
3. ☐ Mark Step 0 as `in_progress`
4. ☐ Read AGENTS.md first, then CLAUDE.md/docs before any code exploration

**This skill is the single feature-workflow entry point.**

Its responsibilities are:
- Classify the incoming request as low-, medium-, or high-definition
- Run an explicit conversational refinement phase before any `Z01_*` writing when the idea is too underdefined for repo-grounded research
- Use `superpowers:brainstorming` as an internal refinement step when deeper product/design refinement is needed
- Produce repo-grounded research artifacts: `Z01_{feature}_research.md` and, when required, `Z01_CLARIFY_{feature}_research.md`

**This skill produces a grounded feature specification, not an implementation plan.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature research workflow",
  "plan": [
    {"step": "Step 0: Verify session mode and Superpowers dependencies", "status": "in_progress"},
    {"step": "Step 1: Read documentation FIRST (AGENTS.md, CLAUDE.md, README, ARCHITECTURE)", "status": "pending"},
    {"step": "Step 2: Classify request definition level", "status": "pending"},
    {"step": "Step 3: Route low/medium/high definition requests appropriately", "status": "pending"},
    {"step": "Step 4: Explore code and repo touchpoints", "status": "pending"},
    {"step": "Step 5: Create Z01 research file (grounded feature specification)", "status": "pending"},
    {"step": "Step 6: Create or update Z01_CLARIFY for blocking ambiguities", "status": "pending"},
    {"step": "Step 7: Verify research/planning boundary and completion gate", "status": "pending"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to the next step.

## The Iron Law

```
NO RESEARCH WITHOUT READING AGENTS.MD FIRST
NO LOW-DEFINITION INPUT WITHOUT A USER-FACING REFINEMENT CHECKPOINT BEFORE Z01
NO Z01 THAT REQUIRES READING ANOTHER DOCUMENT TO UNDERSTAND THE FEATURE
NO HANDOFF TO PLANNING WHILE BLOCKING AMBIGUITIES REMAIN
```

**If Superpowers dependencies are unavailable:** Stop and report that the required marketplace-installed Superpowers skills are missing.

**If Z01 depends on external docs for core requirements:** Copy or summarize the required source context into Z01 and rewrite it to be self-contained.

**If the request remains product-ambiguous after conversational refinement or medium-definition clarification:** Escalate to `superpowers:brainstorming`.

## Research Output Contract

**Z01 is a grounded feature specification.**

It must:
- Stand on its own for planning
- Be grounded in current repo behavior and constraints
- Surface edge cases, risks, dependencies, and test criteria
- Record likely touchpoints and possible downstream adaptations
- Make explicit which assumptions are safe for planning versus which ambiguities still block planning

It must **not**:
- Lock exact edit line ranges
- Contain a pseudo-implementation plan
- Promise that implementation can begin without planning
- Turn planning into a formatting-only step

## Workflow Steps

### Step 0: Verify Session Mode and Dependencies

This workflow runs in Default mode or Plan mode.
Proceed in the current mode; do not block on Plan mode availability.

This skill depends on Superpowers. Verify that the following skills are available before continuing:
- `superpowers:using-superpowers`
- `superpowers:brainstorming`

If they are unavailable, stop and report that the required Superpowers dependency is missing.

---

### Step 1: Read Documentation FIRST

**MANDATORY FIRST - read these if they exist:**
- AGENTS.md (default repo instructions, patterns, conventions)
- CLAUDE.md (Claude-specific patterns, conventions, forbidden approaches)
- README.md (workflow expectations and public behavior)
- ARCHITECTURE.md (system design)
- All documentation (glob `**/docs/**/*.md`)

Why:
- AGENTS.md sets default repo rules
- CLAUDE.md may add mandatory patterns or forbidden approaches
- README and docs establish the public workflow contract this skill must preserve

---

### Step 2: Classify Request Definition Level

Before code exploration or artifact creation, classify the incoming request:

**Low definition**
- Only a couple of lines or an intention statement
- No clear behavior, scope boundaries, or success criteria
- Not enough specificity to research against the repo responsibly

**Medium definition**
- Some desired behavior is described
- Important scope, UX, contract, compatibility, or test expectations are still missing
- Enough detail exists to ask a small number of targeted questions before deciding whether research can proceed

**High definition**
- Desired behavior, scope, and success criteria are mostly clear
- Research can proceed directly after repo inspection
- Still verify the request does not hide unresolved product intent behind detailed wording

Record the chosen classification and a short reason in Z01 under `Definition Level and Triage Result` after refinement is complete and `Z01_*` is created.

---

### Step 3: Route Based on Definition Level

For any route that is still idea-level or product-ambiguous, there must be an explicit user-facing refinement checkpoint before `Z01_*` is written.

That checkpoint must happen inside `feature-researching`, and must include:
- A short restatement of the problem in your own words
- 2-3 viable approaches with a recommendation
- The likely building blocks, repo touchpoints, and integration areas you expect to inspect
- The main tradeoffs, risks, or open decisions
- A direct confirmation question such as `Does this direction look right before I write the research doc?`

Do not write `Z01_*` until that checkpoint has happened and the direction is clear enough to ground in the repo.

#### Low-definition requests

Start with an explicit conversational refinement phase inside `feature-researching`.

If the request still needs deeper product/design shaping after that first exchange, use `superpowers:brainstorming` as an **internal refinement step**.

Critical constraints for that invocation:
- `feature-researching` remains the primary workflow owner
- The goal is to refine product intent enough for repo-grounded research
- Do NOT treat brainstorming output as the final workflow artifact
- Do NOT hand off directly to planning from the brainstorming flow
- Do NOT skip the visible refinement checkpoint and jump straight to document writing

Tell the dependency:
- It is being used to refine intent only
- After refinement, control returns to `feature-researching`
- Refined requirements must be merged back into `Z01_{feature}_research.md`
- If brainstorming writes a spec because its own workflow requires it, treat that file as temporary input and fold the needed context into Z01

After refinement completes, continue with Step 4.

#### Medium-definition requests

Ask **1-3 targeted clarification questions** inside `feature-researching` before repo exploration when that will materially sharpen research.

Use those questions to resolve:
- Scope boundaries
- User-visible behavior
- Acceptance/test intent
- Contract assumptions
- Compatibility expectations

If the request is still idea-level rather than spec-level after those answers, provide the same explicit refinement checkpoint used for low-definition requests before writing `Z01_*`.

After the answers:
- If the request is now clear enough for research, continue with Step 4
- If ambiguity remains primarily product/design-level, escalate to `superpowers:brainstorming` using the same internal-refinement constraints as low-definition requests

#### High-definition requests

Proceed directly to Step 4 only when the request is actually decision-ready.
If the wording looks detailed but the product direction is still not locked, run a short refinement checkpoint first instead of drafting `Z01_*` immediately.

---

### Step 4: Explore Code and Repo Touchpoints

Find related files, search for patterns, read key files, and ground the request in what the repo can already do.

Document:
- Current behavior and current limitations
- Existing patterns and constraints that must be preserved
- Likely touchpoints and integration points
- Data shapes and contracts already in play
- Security considerations
- Edge cases and failure modes
- Dependency risks and compatibility concerns
- Testing expectations and acceptance criteria implied by the current code
- Possible downstream or upstream adaptations that may be required

Prefer likely touchpoints and integration boundaries over false precision. Exact edit ranges belong in planning unless they are genuinely obvious and important for risk analysis.

---

### Step 5: Create Research File

Only begin this step after any required refinement checkpoint is complete and the requested direction is clear enough to research responsibly.

**Scan for ongoing directory:**
- Check for existing Z01 files
- Common locations: `docs/ai/ongoing`, `.ai/ongoing`, `docs/ongoing`
- Create default `docs/ai/ongoing` if none is found

**Save ONGOING_DIR location** for Step 6.

**File**: `{ONGOING_DIR}/Z01_{feature}_research.md`

**Sanitize feature name:**
- Use snake_case: lowercase with underscores
- Replace spaces and special chars with underscores
- Remove quotes, slashes, colons
- Truncate to 50 characters
- Example: `OAuth 2.0 Authentication!` → `oauth_2_0_authentication`

**Structure**:

```markdown
# {Feature} Research

## Summary
One paragraph: what is being proposed and why it matters.

## Source Idea / Requested Change
- Original user proposal or refined request context
- Functional requirements from the source prompt or refinement step
- Non-functional requirements, constraints, and explicit out-of-scope notes

## Definition Level and Triage Result
- Classification: low | medium | high
- Why it was classified this way
- Whether brainstorming or targeted clarification was used

## Current State in the Repo
- What exists today
- Relevant files, modules, endpoints, or workflows already involved
- Current limitations or inconsistencies discovered during exploration

## Observed Constraints and Existing Patterns
### From AGENTS.md and CLAUDE.md
- Conventions that MUST be followed
- Architectural patterns to preserve
- Forbidden patterns/approaches

### From the Codebase
- Relevant repository structure or implementation patterns already in use

## Proposed Feature Behavior
- What the feature should do
- What it should not do
- User-visible behavior and system-visible behavior

## Edge Cases and Failure Modes
- Important edge cases that must be handled
- Expected failure behavior and fallback behavior

## Dependencies, Compatibility Risks, and Potential Adaptations
- Likely touchpoints or integration points
- Upstream/downstream contracts that may need adaptation
- Endpoint, schema, consumer, or workflow risks
- External dependencies or internal services affected

## Testing and Acceptance Criteria
- What must be verified for the feature to be considered correct
- Critical regression coverage expectations
- User-visible acceptance criteria

## Known Limitations / Explicit Non-Goals
- Constraints accepted for now
- Things this research intentionally does not solve

## Open Assumptions Chosen for Planning
- Non-blocking assumptions that planning may rely on
- Assumptions that must be revisited if new evidence appears
```

**Self-contained requirement (MANDATORY):**
- Z01 must stand on its own for planning.
- Do not require readers to open idea/spec/PRD/ticket documents for core requirements.
- If external docs are mentioned, summarize or copy the relevant requirements into Z01.
- Phrases like `see spec`, `refer to ticket`, or `details in doc X` are only allowed for optional background, never for required planning inputs.

---

### Step 6: Create or Update CLARIFY File

**File**: `{ONGOING_DIR}/Z01_CLARIFY_{feature}_research.md`

Use this file only for **blocking ambiguities** that remain after routing and repo exploration.

Blocking categories include:
- User-visible behavior or scope ambiguity
- Data contract ambiguity
- Permission or security ambiguity
- External dependency or upstream/downstream contract uncertainty
- Compatibility or migration ambiguity
- Test oracle ambiguity

**Do not** create CLARIFY entries for non-blocking unknowns. Keep those in Z01 under `Open Assumptions Chosen for Planning`.

**Structure for each blocking item:**

```markdown
Question: {concise blocking question}
Why this matters: {short explanation of the planning risk}
Options considered:
- Option A
- Option B
Recommended default: {recommended direction if the user does not care strongly}
User response:
```

**Critical:** Leave `User response:` blank until answered.

**When incorporating answered questions:** Delete fully answered CLARIFY files or remove incorporated entries if only some were answered.

---

### Step 7: Verify Research/Planning Boundary and Completion Gate

Check `Z01_{feature}_research.md` for boundary violations.

Move or remove anything that looks like:
- exact implementation task breakdown
- phased PR execution plan
- code-level execution instructions
- hard requirements for exact edit line ranges
- claims that planning has no meaningful decisions left

Research is **NOT complete** while `Z01_CLARIFY_{feature}_research.md` exists with unresolved items.

**Unresolved means ANY of the following:**
- The file still contains at least one `Question:` entry
- Any `User response:` is blank
- Answers were provided but not yet incorporated into `Z01_{feature}_research.md`

**If unresolved CLARIFY exists:**
1. Keep research todo as `in_progress`
2. Report only: `Waiting for Z01_CLARIFY_{feature}_research.md answers/incorporation before planning.`
3. Do NOT invoke or suggest `feature-planning` yet

**Only mark research complete when:**
1. Clarification answers are incorporated into `Z01_{feature}_research.md`
2. `Z01_CLARIFY_{feature}_research.md` is deleted (or has no remaining entries)
3. Z01 is self-contained and grounded
4. Z01 contains behavior, risks, dependencies, edge cases, and acceptance criteria
5. Z01 stays on the research side of the research/planning boundary

## Red Flags - You're Failing If:

- **Did NOT read AGENTS.md/CLAUDE.md/README/docs FIRST**
- **Stopped this skill due to missing Plan mode**
- **Skipped the explicit user-facing refinement checkpoint for a rough or product-ambiguous request**
- **Treated brainstorming as a separate workflow owner or canonical artifact instead of an internal refinement step**
- **Allowed brainstorming artifacts to replace Z01 as the primary research artifact**
- **Skipped classification of the request as low/medium/high definition**
- **Wrote `Z01_*` before presenting approaches/building blocks/tradeoffs for an idea-level request**
- **Used more than 3 initial clarification questions for a medium-definition request before deciding whether to escalate**
- **Stored non-blocking unknowns in Z01_CLARIFY instead of Z01 assumptions**
- **Marked research done while Z01_CLARIFY still has unresolved items**
- **No triage result recorded in Z01**
- **No edge cases or failure modes captured**
- **No dependency/adaptation warnings captured**
- **Z01 depends on external docs for core requirements**
- **Z01 reads like an implementation plan instead of grounded research**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"This is only a rough idea, research can't start"** | **NO.** Research is now the single entry point. Classify it and route internally. |
| **"I already know enough to write Z01 from this rough prompt"** | **NO.** Rough or idea-level requests require a visible refinement checkpoint before artifact creation. |
| **"Brainstorming should own the whole flow for vague requests"** | **NO.** Brainstorming is an internal refinement tool here. Workflow and artifact ownership remain with research. |
| **"Medium ambiguity means ask every question now"** | **NO.** Ask 1-3 high-leverage questions, then decide whether to continue or escalate. |
| **"If I keep the brainstorm short, it doesn't need options or tradeoffs"** | **NO.** The refinement checkpoint must still surface approaches, building blocks, and tradeoffs clearly enough for user confirmation. |
| **"The repo touchpoints are obvious, I'll skip documenting risks"** | **NO.** Surfacing compatibility and adaptation risks is a core deliverable of research. |
| **"Exact file edits belong in research so planning stays easy"** | **NO.** That collapses the stage boundary. Research should identify likely touchpoints, not replace planning. |
| **"Questions need no context in CLARIFY"** | **NO.** Blocking questions should include why they matter and the recommended default. |
| **"If a guess is reasonable, no need to mention it"** | **NO.** Non-blocking guesses belong in `Open Assumptions Chosen for Planning`. |
| **"Research is done because Z01 exists"** | **NO.** Done state depends on resolved blocking ambiguities and a clean research/planning boundary. |

## Success Criteria

You followed the workflow if:
- ✓ Read AGENTS.md/CLAUDE.md/README/docs FIRST
- ✓ Verified Superpowers dependencies before proceeding
- ✓ Classified the request as low, medium, or high definition
- ✓ Used an explicit conversational refinement checkpoint before `Z01_*` for low-definition and product-ambiguous requests
- ✓ Presented approaches, likely building blocks/touchpoints, and tradeoffs before writing `Z01_*` when the idea was rough
- ✓ Used brainstorming internally for deeper refinement without surrendering workflow or artifact ownership
- ✓ Recorded the triage result in Z01
- ✓ Produced a self-contained Z01 grounded in repo behavior and constraints
- ✓ Captured current state, proposed behavior, edge cases, risks, dependencies, and acceptance criteria
- ✓ Used likely touchpoints/integration points instead of forcing planning-level edit detail
- ✓ Put non-blocking unknowns into Z01 assumptions
- ✓ Used contextualized Z01_CLARIFY entries only for blocking ambiguities
- ✓ Kept research in progress until Z01_CLARIFY was fully resolved and removed
- ✓ Handed planning a grounded feature spec rather than a pseudo-plan

## When to Use

Use when:
- You have a rough idea, partial spec, or well-defined feature request
- You need one entry point that can refine intent and then ground the work in the repo
- You need to surface integration risks, edge cases, constraints, and test criteria before planning
- You want a short collaborative framing step before a persistent research artifact is written for rough requests

**Don't use when:**
- The change is trivial enough that no research artifact is needed
- The work is already fully planned and ready for execution

## Handoff to Planning

If CLARIFY has unresolved items:
1. Announce: `Research not complete yet. Waiting for Z01_CLARIFY answers/incorporation.`
2. Keep research workflow open (do not hand off)

When CLARIFY is fully resolved and removed:
1. Announce: `Research complete. Z01_research.md ready for planning.`
2. Then proceed to planning workflow

**What planning receives:**
- Patterns that MUST be preserved
- Grounded feature behavior and explicit non-goals
- Current repo state and likely touchpoints
- Edge cases, failure modes, and compatibility risks
- Test and acceptance criteria
- Blocking decisions already resolved
- Explicit assumptions safe to carry into planning
