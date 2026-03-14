# pskoett-ai-skills

A collection of skills for AI agents. Follows the [Agent Skills specification](https://agentskills.io/specification).
This repository is my personal skill testing ground.

## Install

```bash
npx skills add pskoett/pskoett-ai-skills
```

## Structure

```
skills/
  skill-name/
    SKILL.md         # Required - skill definition with YAML frontmatter
    scripts/         # Optional - executable code
    references/      # Optional - documentation loaded on demand
    assets/          # Optional - templates, images, data files
```

## Skills

| Skill | Description |
|-------|-------------|
| [agent-teams-simplify-and-harden](skills/agent-teams-simplify-and-harden/) | Implementation + audit loop using parallel agent teams with structured simplify, harden, and document passes |
| [context-surfing](skills/context-surfing/) | Monitors context window health and rides peak context quality for maximum output fidelity during multi-step execution |
| [dx-data-navigator](skills/dx-data-navigator/) | Query DX Data Cloud for developer productivity metrics, DORA metrics, PR/deployment data, and engineering analytics |
| [intent-framed-agent](skills/intent-framed-agent/) | Captures a lightweight intent contract at execution start and monitors coding-task drift until resolution |
| [plan-interview](skills/plan-interview/) | Runs a structured interview before planning non-trivial implementations |
| [self-improvement](skills/self-improvement/) | Captures learnings and errors with hook-based activation and automatic skill extraction |
| [simplify-and-harden](skills/simplify-and-harden/) | Post-completion self-review that runs simplify, harden, and micro-documentation passes before signaling done |

## Experimental (CI Skills)

These skills are experimental and currently part of the testing ground setup.

| Skill | Description |
|-------|-------------|
| [self-improvement-ci](skills/self-improvement-ci/) | CI-only self-improvement workflow for recurring failure-pattern capture using gh-aw |
| [simplify-and-harden-ci](skills/simplify-and-harden-ci/) | CI-only simplify/harden workflow for pull requests using gh-aw with headless scan/report gates |

## Recommended Flow

- `plan-interview` aligns requirements.
- `intent-framed-agent` locks execution intent and catches scope drift.
- `context-surfing` rides peak context quality through execution and exits cleanly on context degradation.
- `simplify-and-harden` improves post-implementation quality/security.
- `self-improvement` captures recurring patterns across tasks.

Not every task needs all five. Match depth to complexity:

| Task | Skills |
|------|--------|
| Trivial (typo fix, rename) | None |
| Small (isolated bug fix) | `simplify-and-harden` |
| Medium (feature, multi-file) | `intent-framed-agent` + `simplify-and-harden` |
| Large (refactor, new architecture) | Full pipeline |
| Long-running (multi-session) | Full pipeline — `context-surfing` is critical |

## Usage

To use a skill, add it to your agent's configuration or reference it directly.

### Self-Improvement with Hooks

The self-improvement skill supports automatic activation via hooks. Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "./skills/self-improvement/scripts/activator.sh"
      }]
    }]
  }
}
```

Features:
- **Hook activation**: Automatic reminders to evaluate learnings after tasks
- **Error detection**: PostToolUse hook detects command failures
- **Skill extraction**: Promote high-value learnings to reusable skills
- **Multi-agent support**: Works with Claude Code, Codex CLI, and GitHub Copilot

## Contributing

Feel free to submit PRs with new skills or improvements to existing ones.
