# Release Notes - Feature-Workflow Plugin

## Version 2.0.0 (Upcoming)

**Release Date**: TBD

### Breaking Changes

**Wrapper Pattern Architecture**
- Skills that invoke superpowers now properly delegate process enforcement instead of duplicating it
- This is a breaking change in behavior: skills now invoke superpowers for fixing instead of using Edit tool directly

### Major Enhancements

#### 1. Iron Law Added to feature-research
**Impact**: Prevents premature research and ensures design clarity

Added three absolute rules:
```
NO RESEARCH WITHOUT READING CLAUDE.MD FIRST
NO Z01_CLARIFY WITH 5+ QUESTIONS WITHOUT INVOKING BRAINSTORMING
NO PLANNING WITHOUT FILE PATHS + LINE RANGES
```

**Consequences enforced**:
- Skip CLAUDE.md → violate patterns → delete Z01, start over
- 5+ questions in Z01_CLARIFY → design unclear → invoke superpowers:brainstorming, restart research
- No file paths in Z01_research → planner blocked → add exact files or don't create Z01

**Phase Gate at Step 4**:
- After creating Z01_CLARIFY, count questions
- If 5+ questions: STOP, delete Z01 files, invoke `superpowers:brainstorming`, restart from Step 1
- If < 5 questions: Proceed to Step 5

**New Rationalizations Prevented**:
- "6 questions but design seems clear"
- "I'll answer questions instead of brainstorming"
- "Delete Z01s after brainstorming wastes work"

**Files Modified**:
- `skills/feature-research/SKILL.md`: Lines 34-46 (Iron Law), 161-171 (Phase Gate), 191, 211-213 (Rationalizations), 223 (Success Criteria)

---

#### 2. Wrapper Pattern: feature-finish Invokes systematic-debugging
**Impact**: Fixes now use root cause analysis instead of direct Edit tool changes

**Previous behavior**:
- Step 8: Used Edit tool directly to apply fixes
- No root cause investigation
- No pattern analysis
- No 3-fix rule enforcement

**New behavior**:
- **"Fix all"**: Invokes `superpowers:systematic-debugging` with ALL findings
- **"Loop issues"**: For each issue user wants fixed, invokes `superpowers:systematic-debugging`
- Each fix goes through four phases: Root Cause → Pattern → Hypothesis → Implementation
- 3-fix rule automatically enforced (if 3+ fixes fail for same issue → STOP, report architectural problem)

**Benefits**:
- No duplication of systematic-debugging framework
- Quality enforcement: every fix gets root cause analysis
- Consistent with wrapper pattern (assessment at feature-workflow layer, fixing at superpowers layer)

**Files Modified**:
- `skills/feature-finish/SKILL.md`: Lines 172-255 (Step 8 execution), 313 (Red Flags), 325-327 (Rationalizations), 362-363 (Success Criteria)

---

#### 3. Wrapper Pattern: feature-prfix Invokes systematic-debugging
**Impact**: PR review comment fixes now use root cause analysis

**Previous behavior**:
- Step 7: Used Edit tool directly to fix valid reviewer comments
- No root cause investigation

**New behavior**:
- **"Auto: fix valid, refute invalid"**: For each VALID comment, invokes `superpowers:systematic-debugging`
- **"Review per-comment"**: When user chooses "Fix", invokes `superpowers:systematic-debugging`
- Each fix provides PR context, file/line, reviewer comment, CLAUDE.md constraints to systematic-debugging
- Four-phase framework applied to every fix

**Benefits**:
- Even "simple" reviewer comments get root cause analysis
- Prevents introducing new bugs while fixing reviewer comments
- Consistent wrapper pattern across all fixing workflows

**Files Modified**:
- `skills/feature-prfix/SKILL.md`: Lines 152-222 (Step 7 execution), 297 (Red Flags), 313-314 (Rationalizations), 329-332 (Success Criteria)

---

### Documentation Updates

#### improve_opportunities.md Analysis
**New file**: `improve_opportunities.md` - Comprehensive comparison of feature-workflow vs superpowers skills

**Key Findings**:
- **What we do better**: Document consolidation (Z01-Z05), PR workflows, CLAUDE.md integration
- **What to adopt from superpowers**: Iron Laws, verification discipline, battle-tested rationalizations
- **Architecture validation**: Wrapper pattern is correct - feature-workflow loads context, superpowers enforces process

**Sections**:
1. Structural Comparison
2. What Feature-Workflow Does Better (4 innovations)
3. What Superpowers Does Better (7 improvement opportunities)
4. Pattern Similarities (validation)
5. Specific Skill Recommendations
6. Implementation Roadmap (5 phases)
7. Key Takeaways
8. Quick Wins

**Future Work Identified**:
- Add verification protocol to feature-finish Step 1
- Battle-test all skills with superpowers:testing-skills-with-subagents
- Add Iron Laws to remaining skills (feature-plan, feature-implement, feature-prreview, feature-prfix)
- Collect real-world impact metrics

---

## Implementation Roadmap (from improve_opportunities.md)

### Phase 1: Critical Verification (Immediate) - 1-2 hours
- ~~Add verification to feature-implement~~ **SKIP** - wrapper skill, already has via superpowers
- Add verification protocol to feature-finish Step 1
- Add Iron Laws to each skill
- Test with subagents under time pressure

**Status**:
- ✅ Iron Law added to feature-research
- ⏳ Verification for feature-finish pending
- ⏳ Iron Laws for other skills pending

### Phase 2: Red-Green Enforcement (High Priority) - 30 min
- ~~Update feature-implement instructions~~ **SKIP** - superpowers:executing-plans already enforces TDD
- Verify superpowers:test-driven-development is being invoked
- Document in CLAUDE.md that superpowers:executing-plans uses TDD by default

**Status**: ⏳ Pending documentation

### Phase 3: Battle-Test Rationalizations (Medium Priority) - 8-12 hours
- Use superpowers:testing-skills-with-subagents on each feature-workflow skill
- Create pressure scenarios (time, authority, sunk cost)
- Document actual rationalization attempts (not hypothetical)
- Update tables with measured language

**Status**: ⏳ Not started

### Phase 4: Phase Gates & Architecture Questioning (Medium Priority) - 2-3 hours
- ✅ Add 5-question gate to feature-research (DONE)
- Add 3-fix rule to feature-finish (already delegated to systematic-debugging)
- Add explicit "question architecture" step

**Status**:
- ✅ feature-research phase gate complete
- ✅ feature-finish 3-fix rule via systematic-debugging

### Phase 5: Real-World Impact Tracking (Long-term) - Ongoing
- Define metrics for each skill
- Track with/without skill comparisons
- Add Real-World Impact section after 10 data points
- Update every 20 uses

**Status**: ⏳ Not started

---

## Migration Guide

### For Users

**No breaking changes for user-facing behavior**, but internal improvements:

1. **feature-research now enforces design clarity**:
   - If you get "Design unclear (5+ questions)" message, use brainstorming to refine requirements before research
   - Z01/Z02 files may be deleted and recreated if design is unclear

2. **Fixes now use systematic debugging**:
   - feature-finish and feature-prfix take slightly longer (root cause analysis)
   - Higher quality: fixes address root cause, not symptoms
   - Better long-term: prevents introducing new bugs

3. **More sub-skill invocations**:
   - You'll see more superpowers skills being invoked automatically
   - This is correct architecture: delegation instead of duplication

### For Developers

**If you're customizing skills:**

1. **feature-research Step 4 now has phase gate**:
   - Check Z01_CLARIFY question count
   - Handle brainstorming invocation if 5+ questions

2. **feature-finish Step 8 changed**:
   - Don't use Edit tool directly anymore
   - Invoke `superpowers:systematic-debugging` for fixes
   - Handle systematic-debugging results in Z05 documentation

3. **feature-prfix Step 7 changed**:
   - Don't use Edit tool directly for valid comments
   - Invoke `superpowers:systematic-debugging` for each valid fix
   - Refutations still use `gh api .../replies` (unchanged)

---

## Testing

**Testing completed**:
- ✅ Iron Law enforcement in feature-research verified manually
- ✅ Phase gate logic (5+ questions → brainstorming) tested
- ✅ Wrapper pattern changes reviewed for correctness

**Testing pending**:
- ⏳ Subagent pressure testing (superpowers:testing-skills-with-subagents)
- ⏳ Real-world usage with actual PRs and features
- ⏳ Verification protocol in feature-finish

---

## Known Issues

None currently. This is a pure enhancement release.

---

## Upgrade Instructions

### From v1.x to v2.0.0

1. **Update plugin**:
   ```bash
   /plugin update feature-workflow
   ```

2. **Verify version**:
   - Check that marketplace.json shows version 2.0.0
   - Check that git tag v2.0.0 exists

3. **Review changes**:
   - Read this release notes file
   - Review improve_opportunities.md for detailed analysis

4. **Test with low-risk feature**:
   - Run feature-research with small feature to see phase gate in action
   - Run feature-finish on test branch to see systematic-debugging integration

### Rollback (if needed)

If issues arise:
```bash
git checkout v1.8.0
/plugin update feature-workflow
```

Report issues at: https://github.com/escarti/agentDevPrompts/issues

---

## Contributors

- Eduardo Escarti (@escarti) - Architecture design and implementation
- Claude (Anthropic) - Implementation assistance and analysis

---

## Future Releases

### v2.1.0 (Planned)
- Verification protocol added to feature-finish Step 1
- Iron Laws added to remaining skills
- Battle-tested rationalization tables from subagent testing

### v2.2.0 (Planned)
- Real-world impact metrics added
- Performance optimizations for multiple systematic-debugging invocations

### v3.0.0 (Planned)
- Full integration with superpowers marketplace
- Shared rationalization database
- Automated testing framework

---

## Acknowledgments

Special thanks to the superpowers plugin for providing battle-tested process fundamentals that feature-workflow now properly wraps and delegates to.

The analysis in improve_opportunities.md revealed that the correct architecture is:
- **Feature-workflow**: Enterprise-scale feature management (document consolidation, PR workflows)
- **Superpowers**: Fundamental development discipline (TDD, systematic debugging, verification)
- **Integration**: Thin wrapper pattern preserving separation of concerns

This release implements that architecture correctly.
