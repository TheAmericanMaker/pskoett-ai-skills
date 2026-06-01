#!/usr/bin/env bash
# Objective checker: exit 0 = pass. Runs against $WORKSPACE (the solved copy).
set -euo pipefail
cd "$WORKSPACE"
python3 - <<'PY'
from pagination import paginate

items = list(range(1, 11))  # [1..10]
assert paginate(items, 1, 3) == [1, 2, 3], f"page 1: {paginate(items, 1, 3)}"
assert paginate(items, 2, 3) == [4, 5, 6], f"page 2: {paginate(items, 2, 3)}"
assert paginate(items, 4, 3) == [10],      f"page 4: {paginate(items, 4, 3)}"
print("ok")
PY
