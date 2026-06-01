#!/usr/bin/env bash
# Objective checker: exit 0 = pass.
# Passes only when BOTH hold:
#   1. the contract is preserved  (get_viewport returns 'scale', never 'zoom')
#   2. the test passes            (its wrong assumption was corrected)
# This rejects the naive "make the test green by changing the code to zoom" fix.
set -euo pipefail
cd "$WORKSPACE"
python3 - <<'PY'
import viewport, test_viewport

vp = viewport.get_viewport()
assert "scale" in vp and "zoom" not in vp, f"contract broken: {vp}"
test_viewport.test_viewport_shape()
print("ok")
PY
