#!/usr/bin/env bash
# Objective checker: exit 0 = pass.
#
# Self-healing is only "done" when BOTH hold:
#   (1) working state restored — run.sh produces the correct normalized output
#   (2) a VERIFIED heal was filed — .learnings/HEALS.md records the fix with proof
# Requiring (2) is deliberate: it is the behavior that separates a self-healing
# agent from one that just patches and moves on.
set -euo pipefail
cd "$WORKSPACE"

# (1) working state restored
got="$(bash run.sh)"
want="apple:5
banana:2
cherry:9"
if [ "$got" != "$want" ]; then
  echo "fix not working: run.sh output mismatch" >&2
  echo "--- got ---"; echo "$got"; echo "--- want ---"; echo "$want"
  exit 1
fi

# (2) a verified heal was filed with proof.
# Validate a SINGLE HEAL block — not loose tokens scattered across the file —
# so a fake HEALS.md that merely contains the right words can't false-pass.
heals=".learnings/HEALS.md"
[ -f "$heals" ] || { echo "no HEAL filed: $heals missing" >&2; exit 1; }

python3 - "$heals" <<'PY'
import re, sys

text = open(sys.argv[1]).read()
# Split into individual "## [HEAL-...] name" blocks; a valid heal must satisfy
# every requirement WITHIN ONE block, not across the whole file.
blocks = re.split(r"(?m)^##\s+\[HEAL-", text)[1:]
if not blocks:
    sys.exit("no '## [HEAL-...]' entry found")

def field(block, name):
    # match "**Status**: x", "Status: x", or "- Pattern-Key: x" (optional
    # list bullet, optional bold) on its own line
    m = re.search(rf"(?im)^\s*(?:[-*]\s+)?\**{re.escape(name)}\**\s*:\s*(.+)$", block)
    return m.group(1).strip().lower() if m else None

def valid(b):
    if field(b, "Status") != "verified":
        return False
    if field(b, "Trigger") != "missing-capability":
        return False
    pk = field(b, "Pattern-Key")
    if not pk or pk in ("todo", "—", "-"):
        return False
    # the fix must reference the helper that was written
    if "normalize.py" not in b:
        return False
    # verification proof: the block must show the originally-blocked op re-run
    # and its expected output (not just claim success)
    verify = re.search(r"(?is)###\s*Verification(.+?)(?:\n###|\Z)", b)
    proof = verify.group(1) if verify else ""
    if "run.sh" not in proof or "apple:5" not in proof:
        return False
    return True

if not any(valid(b) for b in blocks):
    sys.exit("no single HEAL block is fully valid "
             "(needs Status: verified, Trigger: missing-capability, a real "
             "Pattern-Key, a normalize.py reference, and Verification proof "
             "showing `bash run.sh` -> apple:5)")
print("heal ok")
PY
echo "ok"
