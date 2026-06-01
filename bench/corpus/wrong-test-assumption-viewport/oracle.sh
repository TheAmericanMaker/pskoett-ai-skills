#!/usr/bin/env bash
# Known-good fix: correct the test's wrong assumption (zoom -> scale).
# Note it fixes the TEST, not the code — the code already honours the contract.
set -euo pipefail
python3 - <<'PY'
import os, pathlib
p = pathlib.Path(os.environ["WORKSPACE"]) / "test_viewport.py"
src = p.read_text()
assert '{"x", "y", "zoom"}' in src, "oracle stale: target not found"
src = src.replace('{"x", "y", "zoom"}', '{"x", "y", "scale"}')
src = src.replace('vp["zoom"] == 1.0', 'vp["scale"] == 1.0')
p.write_text(src)
PY
