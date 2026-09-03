---
name: feature-researching
description: Use when beginning feature work from a rough idea, partial specification, or detailed request before implementation planning
---

# Feature Research

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 0 as `in_progress`
3. ☐ Read AGENTS.md first, then CLAUDE.md/docs before any code exploration

**This skill is the single feature-workflow entry point.**

Its responsibilities are:
- Classify the incoming request as low-, medium-, or high-definition
- Investigate the repository and distinguish established decisions from open product or technical bifurcations
- Run a conversational sparring loop for every meaningful bifurcation not settled by the prompt or repository evidence
- Use `superpowers:brainstorming` as an internal refinement step when deeper product/design refinement is needed
- Produce one complete repo-grounded research artifact: `Z01_{feature}_research.md`

**This skill produces a grounded feature specification, not an implementation plan.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature research workflow",
  "plan": [
    {"step": "Step 0: Confirm session mode", "status": "in_progress"},
    {"step": "Step 1: Read documentation FIRST (AGENTS.md, CLAUDE.md, README, ARCHITECTURE)", "status": "pending"},
    {"step": "Step 2: Classify request definition level", "status": "pending"},
    {"step": "Step 3: Discover and resolve meaningful bifurcations conversationally", "status": "pending"},
    {"step": "Step 4: Explore code and repo touchpoints; return to Step 3 for newly discovered bifurcations", "status": "pending"},
    {"step": "Step 5: Assemble candidate Z01 content without writing the artifact", "status": "pending"},
    {"step": "Step 6: Verify provenance, completeness, and boundary; write Z01 only after the gate passes", "status": "pending"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to the next step.

## The Iron Law

```
NO RESEARCH WITHOUT READING AGENTS.MD FIRST
NO AUTONOMOUS CHOICE BETWEEN MEANINGFULLY DIFFERENT PRODUCT OR TECHNICAL PATHS
NO Z01 WHILE A KNOWN MEANINGFUL BIFURCATION REMAINS UNRESOLVED
NO Z01_CLARIFY FILE; CLARIFICATION HAPPENS LIVE IN THE RESEARCH CONVERSATION
NO Z01 THAT REQUIRES READING ANOTHER DOCUMENT TO UNDERSTAND THE FEATURE
NO HANDOFF TO PLANNING UNTIL Z01 IS COMPLETE
```

**If Z01 depends on external docs for core requirements:** Copy or summarize the required source context into Z01 and rewrite it to be self-contained.

**If the request remains broadly product-ambiguous after conversational sparring:** Escalate to `superpowers:brainstorming`.

## Decision Provenance Contract

Every material research decision must have one of these provenances:

1. **User-specified**: the initial prompt or a later user response selects the direction.
2. **Repository-determined**: repository instructions, documented contracts, or established constraints leave no credible alternative.
3. **Open bifurcation**: two or more credible paths remain after inspecting the prompt and repository evidence.

Adopt user-specified and repository-determined decisions. For every open bifurcation, investigate, recommend, and ask; do not choose.

A bifurcation is meaningful when its alternatives materially affect user-visible behavior, scope, architecture, component boundaries, APIs, schemas, persistence, security, permissions, privacy, failure behavior, compatibility, migration, operations, dependencies, delivery complexity, maintainability, testing strategy, acceptance criteria, or costly-to-reverse future flexibility.

This rule applies equally to product and technical decisions. Model confidence, a preferred recommendation, time pressure, or a high-definition prompt does not establish provenance.

Routine facts and mechanically determined details are not bifurcations. Immaterial implementation details that are readily reversible belong in planning or implementation, not in a research assumption.

## Research Output Contract

**Z01 is a grounded feature specification.**

It must:
- Stand on its own for planning
- Be grounded in current repo behavior and constraints
- Contain only resolved material decisions and record their provenance
- Surface edge cases, risks, dependencies, and test criteria
- Record likely touchpoints and possible downstream adaptations

It must **not**:
- Lock exact edit line ranges
- Contain a pseudo-implementation plan
- Promise that implementation can begin without planning
- Turn planning into a formatting-only step
- Contain unresolved options, open questions, or agent-selected design assumptions

## Workflow Steps

### Step 0: Confirm Session Mode

This workflow runs in Default mode or Plan mode.
Proceed in the current mode; do not block on Plan mode availability.

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
- Requires broad intent decisions before repo-grounded research can converge

**Medium definition**
- Some desired behavior is described
- Important scope, UX, contract, compatibility, or test expectations are still missing
- Enough detail exists to ask a small number of targeted questions before deciding whether research can proceed

**High definition**
- Desired behavior, scope, and success criteria are mostly clear
- Most decisions already have prompt or repository provenance
- Still verify the request does not hide unresolved product intent behind detailed wording

Definition level controls discovery depth, not whether collaboration occurs. Record the chosen classification and a short reason in Z01 under `Definition Level and Triage Result` after the decision loop is complete.

---

### Step 3: Run the Conversational Sparring Loop

Use the definition level only to decide where discovery begins:
- **Low definition**: begin with broad intent and scope bifurcations, then narrow into repo-grounded technical choices.
- **Medium definition**: identify missing material decisions and spar on them before finalizing research.
- **High definition**: move efficiently through established decisions, but still surface any meaningful product or technical gaps hidden by detailed wording.

For each open bifurcation, present this compact decision brief:

1. **Evidence and patterns**: relevant prompt constraints, repository patterns, and any tension between them.
2. **Viable options**: two or more credible paths; do not invent false alternatives.
3. **Consequences**: material tradeoffs and downstream effects.
4. **Recommendation**: the preferred direction and why.
5. **Decision request**: one direct question asking the user to choose or refine the direction.

Handle exactly one decision per turn. If several concerns are inseparable, express them as constraints or consequences within one composite decision and still ask only one question. Stop after the decision request and wait for the user's answer. Record the answer, continue discovery, and repeat until no known open bifurcation remains.

The agent owns evidence gathering. Read the repository, eliminate contradicted options, identify relevant patterns, and form an informed recommendation before asking. Do not shift raw investigation work to the user.

Do not write Z01 during this loop. If the conversation is interrupted, keep research in progress and resume at the unresolved decision; do not externalize questions into a clarification file.

#### Low-definition requests

Start with an explicit conversational refinement phase inside `feature-researching`.

If the request still needs deeper product/design shaping after that first exchange, use `superpowers:brainstorming` as an **internal refinement step**.

Immediately before this refinement, load and follow the installed `superpowers:brainstorming` skill. If it is unavailable, stop and report that `superpowers:brainstorming` is missing; instruct the user to install or enable the Superpowers plugin and start a new session before retrying.

Critical constraints for that invocation:
- `feature-researching` remains the primary workflow owner
- The goal is to refine product intent enough for repo-grounded research
- Do NOT treat brainstorming output as the final workflow artifact
- Do NOT hand off directly to planning from the brainstorming flow
- Return to the Step 3 sparring loop after brainstorming

Tell the dependency:
- It is being used to refine intent only
- After refinement, control returns to `feature-researching`
- Refined requirements must be merged back into `Z01_{feature}_research.md`
- If brainstorming writes a spec because its own workflow requires it, treat that file as temporary input and fold the needed context into Z01

After broad intent is resolved, continue with Step 4. Return to this step for every new meaningful bifurcation found during repo exploration.

#### Medium-definition requests

Ask targeted decision questions inside `feature-researching` before repo exploration when they will materially sharpen research.

Use those questions to resolve:
- Scope boundaries
- User-visible behavior
- Acceptance/test intent
- Contract assumptions
- Compatibility expectations

After the answers:
- If the request is now clear enough for research, continue with Step 4
- If ambiguity remains primarily product/design-level, escalate to `superpowers:brainstorming` using the same internal-refinement constraints as low-definition requests

#### High-definition requests

Proceed to Step 4 after resolving known open bifurcations. Detailed wording is not permission to fill gaps: if a meaningful product or technical path lacks user or repository provenance, run the same sparring loop first.

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

For every material choice found during exploration, apply the Decision Provenance Contract:
- if the prompt specifies it, record it as user-specified
- if repository evidence leaves no credible alternative, record it as repository-determined and cite the evidence
- if credible alternatives remain, return to Step 3 and spar with the user before continuing toward Z01

Do not call an option repository-determined merely because it is common, familiar, simpler, or recommended. When the repository contains multiple viable patterns and no governing instruction selects one, that is an open bifurcation.

---

### Step 5: Assemble Candidate Research Content

Only begin this step after repo exploration is complete and all known meaningful bifurcations are resolved in conversation.

Assemble the complete candidate Z01 content in the current response context. Do not create or update the artifact yet; persistence happens only after the Step 6 gate passes.

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
- Whether brainstorming or conversational sparring was used

## Resolved Decisions and Provenance
- Decision
- Provenance: user-specified | repository-determined
- Supporting prompt statement, user response, or repository evidence

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
```

**Self-contained requirement (MANDATORY):**
- Z01 must stand on its own for planning.
- Do not require readers to open idea/spec/PRD/ticket documents for core requirements.
- If external docs are mentioned, summarize or copy the relevant requirements into Z01.
- Phrases like `see spec`, `refer to ticket`, or `details in doc X` are only allowed for optional background, never for required planning inputs.

---

### Step 6: Verify and Write the Complete Research Artifact

Check the candidate Z01 content for completeness and boundary violations before writing the file.

Move or remove anything that looks like:
- exact implementation task breakdown
- phased PR execution plan
- code-level execution instructions
- hard requirements for exact edit line ranges
- claims that planning has no meaningful decisions left
- unresolved options, questions, bifurcations, or assumptions
- material decisions without user-specified or repository-determined provenance

Research is **NOT complete** while a known meaningful bifurcation remains unresolved. Keep the research workflow in progress, return to the live Step 3 sparring loop, and do not create or hand off Z01.

**Only mark research complete when:**
1. Every material decision is user-specified or repository-determined
2. Z01 contains no unresolved options, questions, or agent-selected design assumptions
3. Z01 is self-contained and grounded
4. Z01 contains behavior, risks, dependencies, edge cases, and acceptance criteria
5. Z01 stays on the research side of the research/planning boundary

Only after all five checks pass, write the candidate content to `{ONGOING_DIR}/Z01_{feature}_research.md`. Artifact creation is the final action of this gate, not an input to it.

## Red Flags - You're Failing If:

- **Did NOT read AGENTS.md/CLAUDE.md/README/docs FIRST**
- **Stopped this skill due to missing Plan mode**
- **Chose a meaningful product or technical path without user or repository provenance**
- **Treated a recommendation, confidence, simplicity, or time pressure as permission to decide**
- **Called a choice repository-determined while multiple viable repo patterns remained**
- **Skipped the live sparring loop because the request was classified as high definition**
- **Treated brainstorming as a separate workflow owner or canonical artifact instead of an internal refinement step**
- **Allowed brainstorming artifacts to replace Z01 as the primary research artifact**
- **Skipped classification of the request as low/medium/high definition**
- **Presented options without evidence, consequences, a recommendation, and a direct decision request**
- **Asked more than one decision question in a turn instead of framing one composite decision**
- **Wrote Z01 while a known meaningful bifurcation remained unresolved**
- **Persisted a candidate Z01 before the Step 6 completeness gate passed**
- **Created a Z01 clarification file or question backlog instead of continuing the conversation**
- **Stored unresolved choices or agent-selected design assumptions in Z01**
- **No triage result recorded in Z01**
- **No decision provenance recorded in Z01**
- **No edge cases or failure modes captured**
- **No dependency/adaptation warnings captured**
- **Z01 depends on external docs for core requirements**
- **Z01 reads like an implementation plan instead of grounded research**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"This is only a rough idea, research can't start"** | **NO.** Research is now the single entry point. Classify it and route internally. |
| **"The prompt is detailed, so I can fill in the remaining technical choices"** | **NO.** Definition level does not authorize choices without user or repository provenance. |
| **"I am highly confident this is the best option"** | **NO.** Confidence supports a recommendation; it does not convert an open bifurcation into a decision. |
| **"This is the simplest or most conventional path"** | **NO.** Simplicity and convention are tradeoff evidence, not user approval or a repository constraint. |
| **"The repository uses this pattern in several places"** | **NO.** If another viable pattern also exists and no governing instruction selects one, surface the bifurcation. |
| **"Brainstorming should own the whole flow for vague requests"** | **NO.** Brainstorming is an internal refinement tool here. Workflow and artifact ownership remain with research. |
| **"I can put the unresolved choice in Z01 and let planning settle it"** | **NO.** Z01 is created only after all known meaningful bifurcations are resolved. |
| **"A clarification file lets me keep moving"** | **NO.** Research clarification is live. Keep the workflow in progress and wait for the user's decision. |
| **"If I keep the conversation short, it doesn't need options or tradeoffs"** | **NO.** Every decision brief includes evidence, viable options, consequences, a recommendation, and one direct question. |
| **"The repo touchpoints are obvious, I'll skip documenting risks"** | **NO.** Surfacing compatibility and adaptation risks is a core deliverable of research. |
| **"Exact file edits belong in research so planning stays easy"** | **NO.** That collapses the stage boundary. Research should identify likely touchpoints, not replace planning. |
| **"The user said to make sensible defaults"** | **NO.** That does not authorize material product or technical decisions with credible alternatives. |
| **"Research is done because Z01 exists"** | **NO.** Z01 is valid only when its material decisions have provenance and no unresolved choices remain. |

## Success Criteria

You followed the workflow if:
- ✓ Read AGENTS.md/CLAUDE.md/README/docs FIRST
- ✓ Verified Superpowers dependencies before proceeding
- ✓ Classified the request as low, medium, or high definition
- ✓ Applied the Decision Provenance Contract to product and technical decisions at every definition level
- ✓ Gathered repo evidence autonomously before asking the user to decide
- ✓ Used a live sparring loop for every meaningful open bifurcation
- ✓ Presented evidence, viable options, consequences, a recommendation, and one direct decision request
- ✓ Asked exactly one decision question per turn
- ✓ Used brainstorming internally for deeper refinement without surrendering workflow or artifact ownership
- ✓ Recorded the triage result in Z01
- ✓ Recorded resolved material decisions and their provenance in Z01
- ✓ Produced a self-contained Z01 grounded in repo behavior and constraints
- ✓ Captured current state, proposed behavior, edge cases, risks, dependencies, and acceptance criteria
- ✓ Used likely touchpoints/integration points instead of forcing planning-level edit detail
- ✓ Kept research conversational and in progress until all known meaningful bifurcations were resolved
- ✓ Created no Z01 clarification file or unresolved-question backlog
- ✓ Created Z01 only after the decision loop completed
- ✓ Handed planning a grounded feature spec rather than a pseudo-plan

## When to Use

Use when:
- You have a rough idea, partial spec, or well-defined feature request
- You need one entry point that can refine intent and then ground the work in the repo
- You need to surface integration risks, edge cases, constraints, and test criteria before planning
- You want an evidence-led sparring partner for unresolved product and technical choices before a persistent research artifact is written

**Don't use when:**
- The change is trivial enough that no research artifact is needed
- The work is already fully planned and ready for execution

## Handoff to Planning

If any meaningful bifurcation is unresolved:
1. Keep the live research conversation and progress plan open.
2. Do not create Z01 or hand off to planning.

When all known meaningful bifurcations are resolved and Step 6 writes the validated Z01:
1. Announce: `Research complete. Z01_research.md ready for planning.`
2. Then proceed to planning workflow

**What planning receives:**
- Patterns that MUST be preserved
- Grounded feature behavior and explicit non-goals
- Current repo state and likely touchpoints
- Edge cases, failure modes, and compatibility risks
- Test and acceptance criteria
- Resolved material decisions with user or repository provenance
