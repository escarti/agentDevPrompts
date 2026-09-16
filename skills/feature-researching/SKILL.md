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
- Triage the request, supplied references, and evidence needed to establish the intended feature and verify target feasibility
- Orchestrate the research: determine needed evidence, divide independent research surfaces into bounded assignments when delegation materially improves coverage, and reconcile and verify returned findings
- Investigate the repository and distinguish established decisions from open product or technical bifurcations
- Run a conversational sparring loop for every meaningful bifurcation not settled by the prompt or repository evidence
- Use `superpowers:brainstorming` as an internal refinement step when deeper product/design refinement is needed
- Produce one complete repo-grounded research payload and persist it as either `Z01_{feature}_research.md` or a GitHub issue titled `[Idea] <display feature name>`

**This skill produces a grounded feature specification, not an implementation plan.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature research workflow",
  "plan": [
    {"step": "Step 0: Confirm session mode", "status": "in_progress"},
    {"step": "Step 1: Read documentation FIRST (AGENTS.md, CLAUDE.md, README, ARCHITECTURE)", "status": "pending"},
    {"step": "Step 2: Triage the request, supplied references, and initial evidence needs", "status": "pending"},
    {"step": "Step 3: Clarify the intended feature and establish source evidence conversationally", "status": "pending"},
    {"step": "Step 4: Verify target feasibility through focused research; return to Step 3 for material mismatches", "status": "pending"},
    {"step": "Step 5: Assemble candidate research content without persisting it", "status": "pending"},
    {"step": "Step 6: Verify provenance, completeness, and the research/planning boundary", "status": "pending"},
    {"step": "Step 7: Choose and persist the validated research destination", "status": "pending"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to the next step.

## The Iron Law

```
NO RESEARCH WITHOUT READING AGENTS.MD FIRST
NO AUTONOMOUS CHOICE BETWEEN MEANINGFULLY DIFFERENT PRODUCT OR TECHNICAL PATHS
NO MATERIAL INTERPRETATION WITHOUT STATING THE ASSUMPTION AND GETTING USER CONFIRMATION
NO USE OF A SUPPLIED REFERENCE AS EVIDENCE BEFORE ITS AUTHORITY IS CONFIRMED
NO RESEARCH PERSISTENCE WHILE A KNOWN MEANINGFUL BIFURCATION REMAINS UNRESOLVED
NO Z01_CLARIFY FILE; CLARIFICATION HAPPENS LIVE IN THE RESEARCH CONVERSATION
NO CANONICAL RESEARCH SOURCE THAT REQUIRES READING ANOTHER DOCUMENT TO UNDERSTAND THE FEATURE
NO HANDOFF TO PLANNING UNTIL A COMPLETE LOCAL Z01 OR GITHUB [IDEA] ISSUE EXISTS
```

**If the research payload depends on external docs for core requirements:** Copy or summarize the required source context into the payload and rewrite it to be self-contained.

**If the request remains broadly product-ambiguous after conversational sparring:** Escalate to `superpowers:brainstorming`.

## Decision Provenance Contract

Every material research decision must have one of these provenances:

1. **User-specified**: the initial prompt or a later user response selects the direction.
2. **Repository-determined**: repository instructions, documented contracts, or established constraints leave no credible alternative.
3. **Open bifurcation**: two or more credible paths remain after inspecting the prompt and repository evidence.

Adopt user-specified and repository-determined decisions. For every open bifurcation, investigate, recommend, and ask; do not choose.

Whenever interpreting missing or ambiguous information could affect scope, behavior, architecture, contracts, data, compatibility, security, operations, testing, or acceptance criteria, state the assumption and ask the user to confirm it, even if the interpretation appears obvious: “I’m assuming X because Y. Is that correct?” A confirmed answer becomes user-specified provenance. Do not turn routine mechanical facts into questions. Research cannot be persisted while a material implicit assumption remains unconfirmed.

Supplied references must be classified and confirmed individually before they influence research:
- **Light reference**: inspiration, examples, patterns, or ideas only. It establishes no requirement, fidelity, compatibility, or parity; anything borrowed is a proposal requiring explicit user acceptance.
- **Hard reference**: authoritative specification evidence. Its applicable behavior, contracts, data, UX, or operational characteristics are requirements unless the user explicitly excludes or changes them.

Propose the role from the user’s wording, then ask for confirmation. `1:1`, `copy exactly`, `port`, and `preserve parity` normally propose hard-reference treatment; `like`, `similar to`, `inspired by`, and `feel like` normally propose light-reference treatment. Ask separately for each supplied reference; do not silently give them equal authority.

A bifurcation is meaningful when its alternatives materially affect user-visible behavior, scope, architecture, component boundaries, APIs, schemas, persistence, security, permissions, privacy, failure behavior, compatibility, migration, operations, dependencies, delivery complexity, maintainability, testing strategy, acceptance criteria, or costly-to-reverse future flexibility.

This rule applies equally to product and technical decisions. Model confidence, a preferred recommendation, time pressure, or detailed wording does not establish provenance.

Routine facts and mechanically determined details are not bifurcations. Immaterial implementation details that are readily reversible belong in planning or implementation, not in a research assumption.

## Research Output Contract

**The persisted research payload is a grounded feature specification.**

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

### Step 2: Triage the Request, References, and Evidence Needs

Before source investigation, target-feasibility research, or persistence, identify:
- The requested outcome and missing material intent
- Each supplied reference and its proposed light or hard role
- Evidence needed to establish the intended feature
- Evidence needed later to verify feasibility in the target repository
- The next blocking clarification, reference-authority confirmation, or source investigation

Do not inspect or use a reference as evidence before its role is confirmed. Do not perform target-feasibility research until the intended feature is sufficiently disambiguated. Record the triage result in the research payload.

---

### Step 3: Clarify the Intended Feature and Establish Source Evidence

#### Reference authority and research orchestration

Before using a supplied repository, website, document, issue, image, wireframe, running application, API, dataset, or other material as evidence, infer its light or hard role from the wording and ask the user to confirm it. For example: “You said you want something like this website, so I’m treating it as light inspiration rather than a specification. Is that correct?” or “You requested a 1:1 port, so I’m treating this repository as a hard reference whose applicable behavior must be preserved. Is that correct?”

The researcher owns the final disambiguated specification, not every investigation. Determine the evidence needed and use focused research subagents when they materially improve coverage; do not require delegation for trivial research. Give each assignment one bounded question and evidence scope, then reconcile and verify its output as evidence rather than accepting it as truth. Identify contradictions, omissions, access limitations, and unresolved material decisions; interview the user about those decisions one at a time.

After a reference role is confirmed, use the smallest adequate number of focused research sub-agents: at most one for a light reference and one to three for a hard reference. Three is a ceiling, not a default. Select only relevant independent surfaces, such as observable workflows, contracts, data artifacts, UX, operations, dependencies, permissions, failure behavior, or acceptance semantics.

#### Research sub-agent model selection

The orchestrator owns all material judgment, synthesis, recommendations, user interviews, feasibility conclusions, and the final specification.

Research sub-agents are bounded evidence collectors:
- Use `gpt-5.6-terra` for focused source or repository inspection that needs reliable code or documentation comprehension.
- Use `gpt-5.6-luna` for narrow mechanical collection tasks, such as inventories, enumeration, or extracting already-identifiable facts.

Sub-agents must not select requirements, resolve contradictions, recommend architecture, determine feasibility, or interview the user. They return only inspected evidence, citations or locations, access limitations, and unanswered questions.

Use confirmed source evidence and the prompt to establish what the user wants to build, independently of the target repository's preferred architecture. A light-reference finding remains a proposal until the user explicitly accepts it. A hard-reference baseline must record what was inspected, established, contradicted, inaccessible or unverified, and still requires a user decision.

For each open bifurcation, present this compact decision brief:

1. **Evidence and patterns**: relevant prompt constraints, repository patterns, and any tension between them.
2. **Viable options**: two or more credible paths; do not invent false alternatives.
3. **Consequences**: material tradeoffs and downstream effects.
4. **Recommendation**: the preferred direction and why.
5. **Decision request**: one direct question asking the user to choose or refine the direction.

Handle exactly one decision per turn. If several concerns are inseparable, express them as constraints or consequences within one composite decision and still ask only one question. Stop after the decision request and wait for the user's answer. Record the answer, continue discovery, and repeat until no known open bifurcation remains.

The agent owns evidence gathering. Investigate source material, eliminate contradicted options, identify relevant patterns, and form an informed recommendation before asking. Do not shift raw investigation work to the user.

Do not persist research during this loop. If the conversation is interrupted, keep research in progress and resume at the unresolved decision; do not externalize questions into a clarification file.

If intent remains broadly product- or design-ambiguous after conversational sparring, use `superpowers:brainstorming` as an **internal refinement step**.

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
- Refined requirements must be merged back into the candidate research payload
- If brainstorming writes a spec because its own workflow requires it, treat that file as temporary input and fold the needed context into the research payload

Continue until the desired feature has no unresolved material scope, behavior, contract, data, compatibility, security, operations, testing, or acceptance-criteria assumptions. At that point, the intended feature is disambiguated but is not yet assumed feasible in the target repository. Continue with Step 4. Return here whenever feasibility evidence exposes a material mismatch or new intent decision.

---

### Step 4: Verify Target Feasibility Through Focused Research

Assess the disambiguated intended feature against the target repository. Find related files, search for patterns, read key files, and ground feasibility in what the repository can already do.

For a confirmed hard reference, Step 3 must first have synthesized its source baseline; never invent missing evidence. Use the smallest adequate number of focused research sub-agents when independent target surfaces materially improve coverage. Relevant surfaces may include frontend, backend/API, data sources and schemas, operations, security, dependencies, permissions, or testing. Give each sub-agent one bounded question and evidence scope, then reconcile and verify the findings.

Identify existing capabilities, constraints, reusable patterns, conflicts, missing infrastructure, and compatibility risks. Only after source evidence and target feasibility are understood may the workflow present implementation or architectural options. Do not reshape the source specification around a preferred target architecture before understanding the source.

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
- if credible alternatives remain, return to Step 3 and spar with the user before continuing toward persistence

Do not call an option repository-determined merely because it is common, familiar, simpler, or recommended. When the repository contains multiple viable patterns and no governing instruction selects one, that is an open bifurcation.

If feasibility evidence exposes a material mismatch, limitation, or newly meaningful decision, return to Step 3. Clarify the intended feature with the user, then repeat this step against the revised intent. Continue until the intended feature is disambiguated and the target repository has been assessed against that exact intent.

---

### Step 5: Assemble Candidate Research Content

Only begin this step after the intent-feasibility loop is complete: the intended feature is disambiguated, target feasibility has been verified against that intent, and no known material decision remains unresolved.

Assemble the complete candidate research content in the current response context. Do not create or update a local file or GitHub issue yet; persistence happens only after the Step 6 gate passes and the user chooses a destination in Step 7.

**Prepare the local destination metadata:**
- Check for existing Z01 files
- Common locations: `docs/ai/ongoing`, `.ai/ongoing`, `docs/ongoing`
- Use default `docs/ai/ongoing` if none is found; create it only when the user chooses local persistence

**Save ONGOING_DIR location** for Step 7 if local persistence is selected.

**Local file candidate**: `{ONGOING_DIR}/Z01_{feature}_research.md`

**GitHub issue candidate**: `[Idea] <display feature name>`

Keep a concise human-readable display feature name for the GitHub issue title.

**Sanitize the local feature slug:**
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

## Reference Authority and Evidence
- Each supplied reference, its confirmed role, and its applicable scope
- For each hard reference: what was inspected, established, contradicted, inaccessible or unverified, and still requires a user decision

## Request Triage and Research Loop
- Requested outcome and initial evidence needs
- Source evidence used to establish intended feature behavior
- Intent clarifications and their provenance
- Target-feasibility investigations, findings, constraints, and risks
- Any return from feasibility verification to intent clarification
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
- The selected canonical research source must stand on its own for planning.
- Do not require readers to open idea/spec/PRD/ticket documents for core requirements.
- If external docs are mentioned, summarize or copy the relevant requirements into the research payload.
- Phrases like `see spec`, `refer to ticket`, or `details in doc X` are only allowed for optional background, never for required planning inputs.

---

### Step 6: Verify the Complete Research Payload

Check the candidate research content for completeness and boundary violations before persisting it.

Move or remove anything that looks like:
- exact implementation task breakdown
- phased PR execution plan
- code-level execution instructions
- hard requirements for exact edit line ranges
- claims that planning has no meaningful decisions left
- unresolved options, questions, bifurcations, or assumptions
- material decisions without user-specified or repository-determined provenance
- an unconfirmed material interpretation
- a hard reference that lacks a synthesized source baseline or whose unverified areas could affect the specification

Research is **NOT complete** while a known meaningful bifurcation remains unresolved. Keep the research workflow in progress, return to the live Step 3 sparring loop, and do not create or hand off a local Z01 or GitHub `[Idea]` issue.

- If a material intent decision or assumption remains unresolved, return to Step 3.
- If target feasibility is not established against the current intended feature, return to Step 4.
- If Step 4 exposes a material mismatch or a new intent decision, return to Step 3, then repeat Step 4 after the user resolves it.

**Only mark research complete when:**
1. Every material decision is user-specified or repository-determined
2. The payload contains no unresolved options, questions, or agent-selected design assumptions
3. The payload is self-contained and grounded
4. The payload contains behavior, risks, dependencies, edge cases, and acceptance criteria
5. The payload stays on the research side of the research/planning boundary
6. Every supplied reference has confirmed authority, and hard-reference evidence is synthesized before target-feasibility conclusions or options
7. The intended feature is disambiguated and target feasibility is verified against that exact intent

Only after all seven checks pass, continue to Step 7. Persistence is not an input to this gate.

---

### Step 7: Choose and Persist the Research Destination

After Step 6 passes, honor a destination the user already explicitly selected. Otherwise, offer exactly these choices:
- `Local Z01 file`
- `GitHub [Idea] issue`

The choices are alternative canonical research sources. Do not write both unless the user makes a separate explicit request after this workflow completes.

#### Local Z01 file

If the user chooses local persistence:
1. Create `ONGOING_DIR` if needed.
2. Write the validated payload to `{ONGOING_DIR}/Z01_{feature}_research.md`.
3. Reread the file and verify that the persisted content matches the validated payload.
4. Treat the local file as the canonical planning input.

#### GitHub `[Idea]` issue

If the user chooses GitHub persistence:
1. Resolve the target repository. Default to the current repository unless the user explicitly names another repository.
2. Build a preview containing the resolved repository, the exact title `[Idea] <display feature name>`, and the complete issue body.
3. Use the validated research payload as the complete issue body. The issue must satisfy the same structure, self-containment, provenance, and completeness contract as a local Z01.
4. Show the preview and request explicit approval before creating the issue. Do not treat the earlier destination choice as publication approval.
5. After approval, create the issue, reread the published title and body, and verify them against the preview.
6. Treat the published issue URL or owner/repository plus issue number as the canonical planning input. Do not create a local Z01.

If the target is unresolved, the preview is not approved, publication fails, or published content does not match the approved preview, keep research incomplete and do not hand off to planning.

## Red Flags - You're Failing If:

- **Did NOT read AGENTS.md/CLAUDE.md/README/docs FIRST**
- **Stopped this skill due to missing Plan mode**
- **Chose a meaningful product or technical path without user or repository provenance**
- **Silently interpreted a material ambiguity instead of stating and confirming the assumption**
- **Used a supplied reference without confirming whether it is light or hard authority**
- **Treated light inspiration as a requirement without explicit user acceptance**
- **Accepted subagent output without reconciling, verifying, or recording gaps and contradictions**
- **Used more research agents than the independent evidence surfaces justify, or failed to delegate when broad independent coverage materially needs it**
- **Presented target architecture or implementation options before synthesizing a hard reference and assessing target feasibility against it**
- **Treated target constraints as permission to silently redefine the intended feature**
- **Treated intended behavior as feasible before target research verified it**
- **Continued to payload assembly after feasibility exposed a material mismatch**
- **Returned to target research without first resolving changed intent with the user**
- **Treated a recommendation, confidence, simplicity, or time pressure as permission to decide**
- **Called a choice repository-determined while multiple viable repo patterns remained**
- **Skipped the live sparring loop because the request wording appeared detailed**
- **Treated brainstorming as a separate workflow owner or canonical artifact instead of an internal refinement step**
- **Allowed brainstorming artifacts to replace the validated canonical research source**
- **Skipped triage of the request, supplied references, or evidence needs**
- **Presented options without evidence, consequences, a recommendation, and a direct decision request**
- **Asked more than one decision question in a turn instead of framing one composite decision**
- **Persisted research while a known meaningful bifurcation remained unresolved**
- **Persisted a candidate research payload before the Step 6 completeness gate passed**
- **Persisted research before the user chose `Local Z01 file` or `GitHub [Idea] issue`**
- **Created a GitHub issue without a resolved repository, complete preview, and explicit publication approval**
- **Created both a local Z01 and GitHub issue without a separate explicit request**
- **Published a GitHub research issue whose title did not use `[Idea] <display feature name>`**
- **Published an `[Idea]` issue that was less complete or self-contained than the local Z01 contract**
- **Handed off an unverified or unpublished `[Idea]` issue to planning**
- **Created a Z01 clarification file or question backlog instead of continuing the conversation**
- **Stored unresolved choices or agent-selected design assumptions in the research payload**
- **No triage result recorded in the research payload**
- **No decision provenance recorded in the research payload**
- **No edge cases or failure modes captured**
- **No dependency/adaptation warnings captured**
- **The canonical research source depends on external docs for core requirements**
- **The research payload reads like an implementation plan instead of grounded research**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"This is only a rough idea, research can't start"** | **NO.** Research is now the single entry point. Triage it and route internally. |
| **"The prompt is detailed, so I can fill in the remaining technical choices"** | **NO.** Detail does not authorize choices without user or repository provenance. |
| **"I am highly confident this is the best option"** | **NO.** Confidence supports a recommendation; it does not convert an open bifurcation into a decision. |
| **"This is the simplest or most conventional path"** | **NO.** Simplicity and convention are tradeoff evidence, not user approval or a repository constraint. |
| **"The repository uses this pattern in several places"** | **NO.** If another viable pattern also exists and no governing instruction selects one, surface the bifurcation. |
| **"Brainstorming should own the whole flow for vague requests"** | **NO.** Brainstorming is an internal refinement tool here. Workflow and artifact ownership remain with research. |
| **"I can put the unresolved choice in the research source and let planning settle it"** | **NO.** Research is persisted only after all known meaningful bifurcations are resolved. |
| **"A clarification file lets me keep moving"** | **NO.** Research clarification is live. Keep the workflow in progress and wait for the user's decision. |
| **"If I keep the conversation short, it doesn't need options or tradeoffs"** | **NO.** Every decision brief includes evidence, viable options, consequences, a recommendation, and one direct question. |
| **"The repo touchpoints are obvious, I'll skip documenting risks"** | **NO.** Surfacing compatibility and adaptation risks is a core deliverable of research. |
| **"Exact file edits belong in research so planning stays easy"** | **NO.** That collapses the stage boundary. Research should identify likely touchpoints, not replace planning. |
| **"The user said to make sensible defaults"** | **NO.** That does not authorize material product or technical decisions with credible alternatives. |
| **"The reference wording is obvious, so confirmation is unnecessary"** | **NO.** Propose light or hard authority from the wording, then confirm it before using the source as evidence. |
| **"A subagent inspected the source, so its findings are the specification"** | **NO.** Returned findings are evidence; reconcile and verify them, then resolve material gaps with the user. |
| **"Research is done because a file or issue exists"** | **NO.** A research source is valid only when its material decisions have provenance and no unresolved choices remain. |

## Success Criteria

You followed the workflow if:
- ✓ Read AGENTS.md/CLAUDE.md/README/docs FIRST
- ✓ Verified Superpowers dependencies before proceeding
- ✓ Triaged the request, supplied references, and initial evidence needs
- ✓ Applied the Decision Provenance Contract to product and technical decisions throughout the intent-feasibility loop
- ✓ Stated and confirmed every material assumption before persistence
- ✓ Classified and confirmed each supplied reference as light or hard before using it as evidence
- ✓ Delegated only when independent research surfaces materially improved coverage, using bounded assignments and verified synthesis
- ✓ Treated light-reference findings as proposals until explicitly accepted
- ✓ Synthesized each hard-reference baseline, including evidence gaps and contradictions, before assessing target feasibility or presenting options
- ✓ Established intended feature behavior before assessing target-repository feasibility
- ✓ Used focused target research only where independent frontend, backend/API, data-source, operational, security, or testing surfaces materially improved coverage
- ✓ Returned from a material feasibility mismatch to live intent clarification, then re-verified feasibility against the revised intent
- ✓ Gathered target-repository evidence autonomously before asking the user to decide
- ✓ Used a live sparring loop for every meaningful open bifurcation
- ✓ Presented evidence, viable options, consequences, a recommendation, and one direct decision request
- ✓ Asked exactly one decision question per turn
- ✓ Used brainstorming internally for deeper refinement without surrendering workflow or artifact ownership
- ✓ Recorded the triage result in the research payload
- ✓ Recorded resolved material decisions and their provenance in the research payload
- ✓ Produced a self-contained canonical research source grounded in repo behavior and constraints
- ✓ Captured current state, proposed behavior, edge cases, risks, dependencies, and acceptance criteria
- ✓ Used likely touchpoints/integration points instead of forcing planning-level edit detail
- ✓ Kept research conversational and in progress until all known meaningful bifurcations were resolved
- ✓ Created no Z01 clarification file or unresolved-question backlog
- ✓ Persisted the research payload only after the decision loop completed
- ✓ Honored an explicit destination selection, or otherwise offered `Local Z01 file` or `GitHub [Idea] issue`, only after the research payload passed the completeness gate
- ✓ Previewed and explicitly approved GitHub publication before mutation
- ✓ Persisted exactly one canonical research source and verified the stored content
- ✓ Handed planning a grounded feature spec rather than a pseudo-plan

## When to Use

Use when:
- You have a rough idea, partial spec, or well-defined feature request
- You need one entry point that can refine intent and then ground the work in the repo
- You need to surface integration risks, edge cases, constraints, and test criteria before planning
- You want an evidence-led sparring partner for unresolved product and technical choices before research is persisted locally or as a GitHub `[Idea]` issue

**Don't use when:**
- The change is trivial enough that no research artifact is needed
- The work is already fully planned and ready for execution

## Handoff to Planning

If any meaningful bifurcation is unresolved:
1. Keep the live research conversation and progress plan open.
2. Do not persist research or hand off to planning.

When all known meaningful bifurcations are resolved and Step 7 verifies the selected destination:
1. For local persistence, announce: `Research complete. Z01_{feature}_research.md ready for planning.`
2. For GitHub persistence, announce: `Research complete. [Idea] issue <issue reference> ready for planning.`
3. Then proceed to planning workflow

**What planning receives:**
- The canonical local Z01 path or GitHub `[Idea]` issue reference
- Patterns that MUST be preserved
- Grounded feature behavior and explicit non-goals
- Current repo state and likely touchpoints
- Edge cases, failure modes, and compatibility risks
- Test and acceptance criteria
- Resolved material decisions with user or repository provenance
