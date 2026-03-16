# Plan 002: Agent Teams Simplify & Harden — Full Pipeline Flow

## Summary

Add full pipeline integration to `agent-teams-simplify-and-harden` so it works as both a standalone skill and as part of the skill pipeline. Currently the skill is a well-structured team loop but has no connection to the other pipeline skills.

## Success Criteria

- Skill has a built-in planning phase (mini interview → task breakdown) that runs when no existing plan is provided
- Team lead captures an intent frame at session start
- Team lead runs lightweight context-surfing (drift check between loop rounds)
- Audit findings feed into self-improvement via a learning loop output
- Full Interoperability section documents consumes/produces/pipeline position
- Everything works standalone — no upstream artifacts required

## Risk Assessment

- **Bloating the skill**: The skill is already 477 lines. Adding 5 new sections could push it past the 500-line convention. Mitigation: keep additions concise, use the existing patterns.
- **Over-engineering the planning phase**: This is a team coordination skill, not plan-interview. The planning phase should be lightweight. Mitigation: brief task breakdown interview, not a full plan-interview replication.

## Affected Files/Areas

- `skills/agent-teams-simplify-and-harden/SKILL.md` — all changes here

## Open Questions

- [x] Context-surfing for team lead only — answered
- [x] Planning built-in with standalone fallback — answered
- [x] Learning loop output — answered
- [x] Intent frame for team lead — answered

## Implementation Checklist

### 1. Add "Pipeline Integration" section after "When to Use"

Brief section explaining how this skill relates to the pipeline. Key points:
- This skill replaces stages 2-4 of the standard pipeline (execution + review + learning)
- Plan-interview can feed into it but isn't required
- It runs its own intent frame, drift checks, and learning loop

### 2. Add "Phase 0: Planning" before "Step 1: Create the Team"

A lightweight planning phase:
- If a plan file exists (from plan-interview), consume it — extract tasks from the implementation checklist
- If no plan exists, run a brief task breakdown interview:
  - What needs to be built/fixed? (features, bugs, hardening targets)
  - What's the spec or source of truth? (doc, issue, PR, verbal description)
  - What are the acceptance criteria?
- Output: a task list ready for step 2 (Create Tasks)

### 3. Add intent frame capture in step 1

Before creating the team, the team lead emits an intent frame:
```
## Intent Frame #1
**Outcome:** [What the team session will deliver]
**Approach:** [Team structure, audit dimensions, loop strategy]
**Constraints:** [Scope boundaries, budget limits]
**Success criteria:** [Clean audit or loop cap with all critical/high resolved]
**Estimated complexity:** [Based on task count and file count]
```

### 4. Add drift check between loop rounds

Between step 7 (Loop) iterations, team lead does a lightweight context-surfing check:
- Re-read the intent frame and plan/task breakdown
- Compare current state against original scope
- If scope has drifted (e.g., audit findings are pulling the team into unrelated areas), flag it and either re-scope or exit

Not the full exit/handoff protocol — just a re-anchor check. If drift is severe, the team lead can stop the loop early and produce the summary.

### 5. Add learning loop to final summary (step 8)

After the hardening summary, emit a learning loop block:
```yaml
learning_loop:
  target_skill: "self-improvement"
  candidates:
    - pattern_key: "harden.input_validation"
      pass: "harden"
      rounds_to_resolve: 1
      severity: "high"
      ...
```

Normalize recurring audit findings across rounds into pattern_keys, same format as simplify-and-harden.

### 6. Add Interoperability section

Following the pattern from other pipeline skills:

**What this skill consumes:**
- From plan-interview (optional): Plan file for task extraction
- From user (always available): Task description, spec, or feature list
- From intent-framed-agent: Not consumed — team lead creates its own intent frame

**What this skill produces:**
- For self-improvement: Learning loop candidates from recurring audit findings
- For the user: Hardening summary with full audit trail

**Pipeline position:**
- Replaces stages 2-4 when team-based execution is appropriate
- Can follow plan-interview or run standalone
- Feeds into self-improvement

## Test Strategy

- Manual read-through: skill reads coherently with new sections
- Line count check: stay under 500 lines (convention)
