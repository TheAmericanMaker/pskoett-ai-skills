#!/usr/bin/env bash
# Known-good fix: guard the zero divisor per the documented behavior.
set -euo pipefail
python3 - <<'PY'
import os, pathlib
p = pathlib.Path(os.environ["WORKSPACE"]) / "calc.py"
src = p.read_text()
target = "    return a / b  # BUG: no zero guard -> raises ZeroDivisionError"
assert target in src, "oracle stale: target line not found"
guard = "    if b == 0:\n        return 0.0\n    return a / b"
p.write_text(src.replace(target, guard))
PY
