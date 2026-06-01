#!/usr/bin/env bash
# Known-good fix: 1-indexed page start.
set -euo pipefail
python3 - <<'PY'
import os, pathlib
p = pathlib.Path(os.environ["WORKSPACE"]) / "pagination.py"
src = p.read_text()
target = "start = page * per_page"
assert target in src, "oracle stale: target line not found"
p.write_text(src.replace(target, "start = (page - 1) * per_page"))
PY
