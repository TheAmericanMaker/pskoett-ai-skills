#!/usr/bin/env bash
# Known-good self-heal: write the missing helper, verify run.sh works, then file
# a VERIFIED HEAL with the verification output as proof. Mirrors the skill loop:
# diagnose -> patch -> verify -> file.
set -euo pipefail
cd "$WORKSPACE"

# --- PATCH: write the missing capability ---
mkdir -p scripts
cat > scripts/normalize.py <<'PY'
import sys

def normalize(path):
    seen, out = set(), []
    with open(path) as f:
        for line in f:
            row = line.strip()
            if not row or row in seen:
                continue
            seen.add(row)
            key, value = row.split(",", 1)
            out.append((key, value))
    out.sort(key=lambda kv: kv[0])
    return [f"{k}:{v}" for k, v in out]

if __name__ == "__main__":
    print("\n".join(normalize(sys.argv[1])))
PY

# --- VERIFY: re-run the originally blocked operation ---
proof="$(bash run.sh)"
echo "$proof" | grep -q "^apple:5$" || { echo "oracle self-check failed" >&2; exit 1; }

# --- FILE: durable, verified heal artifact ---
mkdir -p .learnings
cat >> .learnings/HEALS.md <<EOF

## [HEAL-00000000-001] missing_normalize_helper

**Logged**: 1970-01-01T00:00:00Z
**Status**: verified
**Trigger**: missing-capability
**Area**: data-pipeline
**Priority**: medium

### Failure
\`bash run.sh\` failed: it calls \`scripts/normalize.py\`, which did not exist
(\`No such file or directory\`). The dedupe+sort capability was missing.

### Fix
Wrote \`scripts/normalize.py\` — dedupes exact rows, sorts by key, prints
\`key:value\` lines. Helper is load-bearing (run.sh calls it), so it lives in the
project tree under \`scripts/\`, referenced here rather than copied.

### Verification
Re-ran the blocked op: \`bash run.sh\` → exit 0, output:
\`\`\`
$proof
\`\`\`

### Metadata
- Related Files: scripts/normalize.py, run.sh
- Pattern-Key: cap.missing_helper_script
- Recurrence-Count: 1
- First-Seen: 1970-01-01
- Last-Seen: 1970-01-01

---
EOF
