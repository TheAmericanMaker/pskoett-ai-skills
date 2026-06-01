#!/usr/bin/env bash
# Objective checker: exit 0 = pass.
set -euo pipefail
cd "$WORKSPACE"
python3 - <<'PY'
from calc import safe_divide

assert safe_divide(6, 3) == 2.0, "normal division wrong"
assert safe_divide(1, 0) == 0.0, "missing zero guard (expected 0.0)"
print("ok")
PY
