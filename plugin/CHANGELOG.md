# Changelog

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
