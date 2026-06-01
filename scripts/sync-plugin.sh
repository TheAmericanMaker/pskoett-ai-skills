#!/bin/bash
# Syncs skills/ → plugin/skills/ with the public source as the single source of truth.
#
# Each plugin SKILL.md is rebuilt from the SOURCE body + SOURCE description, while
# preserving the plugin-only frontmatter (hooks, user-invocable, argument-hint) that
# makes the skill register as a plugin. references/, scripts/, and assets/ are copied
# from source. This is what stops plugin/skills/ from drifting away from skills/.
#
# Delegates to scripts/sync_plugin.py (requires python3 + PyYAML).
#
# Usage: ./scripts/sync-plugin.sh [skill-name ...]
#   No args: sync every skill present in both skills/ and plugin/skills/.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec python3 "$REPO_ROOT/scripts/sync_plugin.py" "$@"
