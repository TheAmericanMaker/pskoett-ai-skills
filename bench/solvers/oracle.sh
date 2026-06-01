#!/usr/bin/env bash
# oracle — the ceiling of the curve.
#
# Applies the task's own known-good fix ($TASK_DIR/oracle.sh) to $WORKSPACE, so
# every task's checker should PASS. This proves each checker actually recognises
# a correct fix (i.e. the metric discriminates), and marks the best achievable
# score. A real agent solver's job is to close the gap from the floor to here.
set -euo pipefail
exec bash "$TASK_DIR/oracle.sh"
