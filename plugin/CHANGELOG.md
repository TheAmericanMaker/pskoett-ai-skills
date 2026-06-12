# Changelog

## 2.3.0 — 2026-06-12

### Fixed
- **self-improvement `error-detector.sh`**: now reads the hook payload as JSON from stdin (the previously referenced `CLAUDE_TOOL_OUTPUT` env variable never existed) and returns its reminder as `hookSpecificOutput.additionalContext` JSON, which PostToolUse requires for output to reach the model. The hook had never fired.
- **self-healing `detect-failure.sh`**: same output-channel fix; now also probes `tool_response.exit_code` (the real Claude Code/Codex payload field).
- **Hook docs rewritten against verified vendor documentation**: removed the fictional `.codex/settings.json` hook system; documented real Codex CLI hooks (`.codex/hooks.json` behind the `codex_hooks` feature flag) and Copilot hooks (`.github/hooks/*.json`, logging/policy only — output cannot inject context). Removed the unsupported UserPromptSubmit matcher tip and the invalid JSON-comments example.
- **Hook command paths**: install-location aware everywhere; plugin skill frontmatter hooks now use `${CLAUDE_PLUGIN_ROOT}` instead of relative paths that resolved against the project cwd.
- **Routing contradiction resolved**: context-surfing's pipeline depth table now matches skill-pipeline (canonical) — verify-gate runs for Small and Medium tasks.
- **CI promotion chain**: learning-aggregator-ci now reads `HEALS.md` and parses `Handoff` blocks; self-improvement-ci's read-only contract clarified with an explicit Heal Handoff Intake procedure.
- **Promotion threshold unified** (Recurrence-Count >= 3, 2+ distinct tasks, 30-day window) across self-improvement, self-healing, self-healing-ci, and both aggregators.
- **plan-interview / intent-framed-agent**: clarified that plan-approval auto-start flows into the Intent Frame, whose own confirmation still applies.
- **Plugin-only agents** (context-monitor, harness-updater): standalone skills now carry fallbacks for environments without the plugin bundle.
- **agent-teams-simplify-and-harden**: added environment requirements and a fallback path for environments without team tools or subagents.
- **skill-tester**: SKILL.md now states which checks run-tests.sh automates vs agent-performed; removed unused PLUGIN_DIR; skill-tester-ci no longer shadows the system TMPDIR variable.
- **self-improvement consistency**: single promotion threshold, openclaw guidance fully factored to references/, status vocabulary completed, asset templates match documented categories.

### Added
- **error-detector.sh multi-agent support**: handles Claude Code/Codex (`tool_response`) and Copilot (`toolResult.textResultForLlm` + `resultType`) payload shapes, with in-script shell-tool filtering for agents without matchers.
- **self-improvement assets**: `ERRORS.md` and `FEATURE_REQUESTS.md` file templates (previously promised, missing).

### Removed
- `skills/self-healing-workspace/` scratch directory (benchmark summaries preserved under `skills/self-healing/evals/`).

---

## 2.0.0 — 2026-04-11

### Added — Two Loops Implementation
- **verify-gate**: Machine verification gate (compile, test, lint) between implementation and quality review with fix loop
- **learning-aggregator**: Cross-session analysis of .learnings/ files — finds patterns, ranks promotion candidates
- **pre-flight-check**: Session-start scan that surfaces relevant learnings, errors, and eval status
- **eval-creator**: Creates permanent eval cases from promoted learnings and runs regression checks

### Agents
- **harness-updater**: Applies promotion candidates to CLAUDE.md, AGENTS.md, copilot-instructions.md

### Hooks
- SessionStart: pre-flight-check surfaces accumulated learning signals

### Changed
- Moved self-improvement and context-surfing hooks from plugin-level hooks.json into SKILL.md frontmatter
- Updated skill-pipeline with full two-loop routing (inner loop + outer loop)
- Updated pipeline depth table to include verify-gate and pre-flight-check at all levels

---

## 1.0.0 — 2025-03-16

### Added
- **plan-interview**: Structured interview before implementation planning
- **intent-framed-agent**: Intent capture and scope drift monitoring during execution
- **context-surfing**: Context window health monitoring with clean handoff on drift
- **simplify-and-harden**: Post-completion simplify, harden, and micro-documentation passes
- **self-improvement**: Learning capture with hook-based activation and error detection
- **agent-teams-simplify-and-harden**: Parallel implementation and audit loop using agent teams

### Agents
- simplify-auditor, harden-auditor, spec-auditor, context-monitor, self-improvement-logger

### Hooks
- UserPromptSubmit: self-improvement activator reminder
- PostToolUse (Bash): automatic error detection
- SessionStart: context-surfing handoff file checker
