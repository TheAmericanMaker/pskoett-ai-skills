#!/usr/bin/env bash
#
# bench runner — the harness fitness function.
#
# For each task in corpus/, materialize its broken workspace into a temp dir,
# run the chosen SOLVER against it, then run the task's objective checker.
# A task "passes" when its checker exits 0. The score is pass/total.
#
# Solvers are pluggable (solvers/<name>.sh): baseline-noop (the floor — agent
# does nothing), oracle (the ceiling — known-good fix), and — the whole point —
# agent solvers that run a real coding agent under a given skill configuration.
# The gap between an agent solver and the floor is the MEASURED value of the
# harness. Tracking that gap over time (as learnings accumulate) is the curve.
#
# Usage:
#   bench/runner/run-bench.sh [--solver NAME] [--task TASK_ID] [--record] [--json]
#     --solver NAME   solver in solvers/ (default: baseline-noop)
#     --task TASK_ID  run only one corpus task
#     --record        append the run to RESULTS.md
#     --json          print a one-line JSON summary
#
set -uo pipefail

BENCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORPUS_DIR="$BENCH_DIR/corpus"
SOLVERS_DIR="$BENCH_DIR/solvers"
RESULTS_FILE="$BENCH_DIR/RESULTS.md"

solver="baseline-noop"
only_task=""
record=0
emit_json=0

while [ $# -gt 0 ]; do
  case "$1" in
    --solver) solver="${2:?--solver needs a value}"; shift 2 ;;
    --task)   only_task="${2:?--task needs a value}"; shift 2 ;;
    --record) record=1; shift ;;
    --json)   emit_json=1; shift ;;
    -h|--help) sed -n '2,24p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

solver_script="$SOLVERS_DIR/$solver.sh"
if [ ! -f "$solver_script" ]; then
  echo "unknown solver '$solver' (looked in $SOLVERS_DIR)" >&2
  exit 2
fi

pass=0
total=0
failed=""

echo "bench: solver=$solver"
for task_dir in "$CORPUS_DIR"/*/; do
  tid="$(basename "$task_dir")"
  [ -n "$only_task" ] && [ "$only_task" != "$tid" ] && continue
  [ -f "$task_dir/check.sh" ] || continue
  [ -d "$task_dir/workspace" ] || continue
  total=$((total + 1))

  work="$(mktemp -d)"
  cp -R "$task_dir/workspace/." "$work/"

  # Run the solver against a private copy of the workspace. Solvers see the
  # task only through $WORKSPACE (the code to fix) and $TASK_DIR (metadata).
  WORKSPACE="$work" TASK_DIR="$task_dir" bash "$solver_script" >/dev/null 2>&1 || true

  # Score with the task's objective checker (exit 0 = pass).
  if WORKSPACE="$work" bash "$task_dir/check.sh" >/dev/null 2>&1; then
    pass=$((pass + 1))
    printf "  pass  %s\n" "$tid"
  else
    failed="${failed:+$failed,}$tid"
    printf "  FAIL  %s\n" "$tid"
  fi

  rm -rf "$work"
done

echo "score: $pass/$total"

if [ "$record" = "1" ]; then
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [ ! -f "$RESULTS_FILE" ]; then
    {
      echo "# Bench Results — the harness fitness curve"
      echo
      echo "Each row is one run of the corpus under one solver. \`baseline-noop\` is the"
      echo "floor (agent does nothing); \`oracle\` is the ceiling (known-good fix). Agent"
      echo "solvers (skills-off vs inner-loop vs inner+outer) land in between — that gap,"
      echo "tracked over time, is the harness's measured value."
      echo
      echo "| timestamp (UTC) | solver | pass | total | failed tasks |"
      echo "|-----------------|--------|------|-------|--------------|"
    } > "$RESULTS_FILE"
  fi
  printf '| %s | %s | %s | %s | %s |\n' "$ts" "$solver" "$pass" "$total" "${failed:-—}" >> "$RESULTS_FILE"
fi

if [ "$emit_json" = "1" ]; then
  printf '{"solver":"%s","pass":%s,"total":%s,"failed":"%s"}\n' "$solver" "$pass" "$total" "${failed:-}"
fi

# Exit non-zero if any task failed — lets CI gate an agent solver on full pass.
[ "$pass" = "$total" ]
