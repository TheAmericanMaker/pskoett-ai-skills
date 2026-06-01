---
name: control-session-orchestrator
description: >
  Control-plane workflow for coordinating multi-agent, multi-session project work from a single
  Codex, GitHub Copilot, or agent-app control session. Use this skill whenever the user asks to
  orchestrate agents, create or steer worker sessions, run a workflow-like effort, fan out
  audits/research/migrations, coordinate parallel implementation streams, monitor other project
  sessions, or compare this control-session pattern to Claude Code dynamic workflows. This skill is
  especially relevant when the current session can spawn persistent project sessions and those
  sessions can spawn their own subagents, creating a two-level orchestration hierarchy.
---

# Control Session Orchestrator

Use the current session as the control plane for project work that is too broad, risky, or
stateful for one conversation. The control session owns intent, decomposition, routing, status,
verification, and consolidation. Worker sessions own scoped execution. Worker subagents are local
implementation/research/audit helpers inside each worker session.

## Mental model

```
User
  -> Control session (strategy, dispatch, tracking, integration)
       -> Worker project session A (persistent branch/workstream)
            -> Subagents for research, implementation, review, tests
       -> Worker project session B (persistent branch/workstream)
            -> Subagents for local fan-out
       -> Verifier/reviewer session (optional independent gate)
```

This is similar to dynamic workflows, but the orchestration is human-readable and session-native
instead of a runtime script. Use it when persistence, branches, PRs, human steering, or cross-session
continuity matter more than fully automated fan-out.

## Supported control apps

This skill is app-agnostic. First discover which orchestration tools are available in the current
session, then adapt the same control workflow to that surface.

| Capability | Codex app | GitHub Copilot app | Fallback |
|---|---|---|---|
| Find worker sessions | List/search project threads | List/search app sessions | Ask user for target session links/IDs |
| Create persistent workstreams | Create or reuse Codex threads/worktrees when available | Create or reuse Copilot app sessions/workspaces when available | Use local subagents only |
| Steer an existing workstream | Send a follow-up prompt to the thread | Send a follow-up prompt to the session | Ask user to paste the prompt into the worker |
| Local fan-out | Spawn subagents from this session or ask workers to spawn their own | Use Copilot's available agent/session tools | Keep work local |
| Tracking | Thread titles, pins, branches, PRs, canvas nodes, compact status tables | Session names, branches, PRs, issues, canvas nodes, compact status tables | Markdown status table |

Do not assume the GitHub Copilot or Codex tool names. Use the tools exposed in the current
environment, and say which control surface is active before dispatching workers.

## When to use

Use this skill for:

- Codebase-wide audits, migrations, or parity checks
- Parallel investigation across modules, services, features, or PRs
- Work that benefits from independent implementer and verifier sessions
- Large features where design, implementation, testing, and review should be split
- Project-control prompts like "coordinate agents", "spin up sessions", "run a workflow",
  "make workers handle this", "monitor the other sessions", or "act as control"
- Situations where worker sessions may themselves use subagents for local research, coding, or review

Do not use it for a simple one-file fix, a quick answer, or a task where a single local subagent is
enough. Orchestration has overhead; spend it only when coordination reduces risk or increases
throughput.

## Control workflow

### 1. Frame the mission

Before spawning anything, capture:

- Objective and non-goals
- Repositories, branches, PRs, or issues in scope
- File or subsystem boundaries for each workstream
- Success criteria and verification gates
- Merge/integration expectations
- Any "do not touch" constraints

If any boundary is ambiguous and could cause conflicting edits, ask before dispatch.

### 2. Detect the control surface

Before dispatch, identify the available app tools:

- Codex app: thread/session tools such as list, create/read, send-message, rename, pin/archive, plus
  optional local subagent tools.
- GitHub Copilot app: session or workspace tools exposed by the app connector, plus any available
  GitHub issue/PR/branch controls.
- Generic agent app: any combination of session, task, subagent, branch, issue, PR, or automation
  tools.

If no persistent-session tools are available, downgrade to a local multi-agent plan and explain the
limitation. Do not invent a backend.

### 3. Choose the topology

Pick the smallest useful topology:

- **One worker**: isolated implementation or bug fix that should live in its own project session
- **Parallel workers**: independent modules, packages, endpoints, tests, or docs
- **Research then implementation**: exploratory sessions report findings before coding starts
- **Implementer + verifier**: one session changes code, another reviews or verifies independently
- **Control-only**: no workers yet; just inspect state, list sessions, or plan the dispatch

Prefer separate sessions when workers may edit overlapping history, need different branches, or need
long-running context. Prefer local subagents inside one session when the task is exploratory and does
not need persistent branch state.

### 4. Dispatch workers with complete prompts

Each worker prompt should be self-contained. Include:

- The mission and exact scope
- Files, subsystems, issue/PR links, and branch expectations
- What the worker may and may not change
- Verification commands or acceptance criteria
- Whether it may create commits, PRs, or only report back
- A concise reporting format

Worker prompt template:

```text
You are worker <name> for <project>.

Mission: <specific outcome>
Scope: <files/subsystems/issue/PR>
Do not touch: <boundaries>
Approach: <expected plan or constraints>
Verification: <commands/checks/evidence>
Report back with:
- Summary
- Files changed
- Verification run and result
- Risks/blockers
- Recommended next step
```

Tell workers they may use their own subagents for local research, implementation, and review, but the
worker remains accountable for its scope and final report.

When using Codex app controls, prefer to rename and pin important worker/control threads so the
session graph stays legible. When using GitHub Copilot app controls, use the corresponding session or
workspace labels if exposed.

### 5. Track state centrally

Use whatever state tools are available in the control environment:

- Session names and IDs for routing
- SQL/todo tables for workstream state
- Branches, issues, and PRs for durable project state
- Canvas nodes for visual topology and status when helpful

Track at least: worker/session ID, scope, status, branch/PR, last update, blocker, and verification
state. Keep the control session's context focused on summaries and decisions, not full transcripts.

### 6. Route follow-ups

When a worker reports:

- Accept completed work only if it includes evidence against the success criteria
- Send targeted follow-ups for missing verification, scope drift, or blockers
- Avoid duplicating a worker's investigation unless its result is incomplete or suspect
- If two workers conflict, pause integration and resolve ownership before more edits happen

### 7. Verify and consolidate

Before declaring the mission done:

- Run or delegate the agreed verification gate
- Review diffs or ask an independent reviewer session for high-signal findings
- Ensure worker outputs are integrated in the right branch/session
- Summarize what landed, what did not, and any remaining risk

For PR-bound work, keep the control session responsible for final PR readiness and review routing.

## Safety rules

- Do not spawn workers for trivial tasks.
- Do not let multiple workers edit the same files unless explicitly coordinated.
- Do not assume a named app connector exists; discover it and fall back honestly.
- Do not silently create branches, commits, pushes, or PRs; follow the user's consent and repo rules.
- Do not ask workers to share secrets or sensitive data across sessions.
- If using an in-place checkout, be extra careful: other user-owned changes may already exist.
- If the plan changes materially, update the user and the workers before continuing.

## Recommended reporting format

Use a compact control-plane update:

```markdown
**Status:** <on track | blocked | needs decision | complete>

| Workstream | Session | Scope | State | Evidence |
|---|---|---|---|---|
| <name> | <id/name> | <scope> | <state> | <test/report/PR> |

**Decision needed:** <only if blocked>
```

Keep user-facing updates concise. The control session should make coordination legible, not flood the
user with every worker's transcript.
