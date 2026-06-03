#!/usr/bin/env bash
# Normalize data.csv: drop exact-duplicate rows, sort by key, print "key:value".
# Delegates to scripts/normalize.py — which does not exist yet (the failure).
set -euo pipefail
cd "$(dirname "$0")"
python3 scripts/normalize.py data.csv
