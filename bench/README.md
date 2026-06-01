# bench — the harness fitness function

This library claims the agent **gets better every cycle**: the inner loop catches
failures in-session, the outer loop encodes them so they don't recur. `bench` is
the scoreboard that makes that claim **falsifiable** — and, once agent solvers are
wired in, turns it into a number that should go up over time.

Every skill in `skills/` is a hypothesis about what makes an agent better
("verify-gate catches wrong test assumptions", "harden catches missing guards").
Without measurement those are just well-argued beliefs. `bench` measures them.

## How it works

```
corpus/<task>/workspace/   the broken code a solver must fix
corpus/<task>/check.sh      objective checker — exit 0 = pass (the metric)
corpus/<task>/oracle.sh     the known-good fix (defines the ceiling)
corpus/<task>/task.yaml      metadata: failure_mode, skill_under_test, expectations
solvers/<name>.sh           pluggable "who attempts the task"
runner/run-bench.sh         materialize → solve → check → score → record
RESULTS.md                  append-only ledger: the curve over time
```

For each task the runner copies the broken `workspace/` to a temp dir, runs a
**solver** against it, then runs the task's **checker**. Pass = checker exits 0.

Solvers are the key idea — they are pluggable, and the metric is solver-agnostic:

| solver | what it is | expected | meaning |
|--------|------------|----------|---------|
| `baseline-noop` | does nothing | 0 / N | the **floor** — proves tasks are really broken |
| `oracle` | applies each task's known fix | N / N | the **ceiling** — proves checkers recognise a correct fix |
| *(next)* `agent-bare` | a coding agent, no skills | between | the agent's unaided ability |
| *(next)* `agent-inner` | same agent + inner-loop skills | higher? | **the measured value of the inner loop** |
| *(next)* `agent-outer` | + outer-loop learnings accrued | higher still? | the **compounding** claim, tested |

The gap between `agent-inner` and `agent-bare`, tracked in `RESULTS.md` as the
corpus grows and learnings accrue, is the whole thesis made empirical.

## Run it

```bash
bench/runner/run-bench.sh --solver baseline-noop --record   # floor
bench/runner/run-bench.sh --solver oracle --record          # ceiling
bench/runner/run-bench.sh --solver oracle --task missing-guard-safediv
```

Only `bash` + `python3` required. No network, fully deterministic.

## Add a task

1. `mkdir -p corpus/<id>/workspace` and put the broken code in `workspace/`.
2. Write `check.sh` (exit 0 = pass; runs against `$WORKSPACE`). Make it assert
   the **contract**, not just "a test passes" — see `wrong-test-assumption-viewport`,
   where a naive fix that greens the test but breaks the contract is rejected.
3. Write `oracle.sh` to apply the known-good fix to `$WORKSPACE` (assert your
   target exists so a stale oracle fails loudly).
4. Add `task.yaml` with `failure_mode` and `skill_under_test`.
5. Confirm it discriminates: `baseline-noop` fails it, `oracle` passes it.

The most accretive source of tasks is `.learnings/` — every real failure that was
captured becomes a permanent, measured regression. `wrong-test-assumption-viewport`
is built directly from `LRN-20260412-001`.

## Writing an agent solver (the next step)

A solver receives two env vars and mutates the workspace in place:

- `WORKSPACE` — the dir containing the code to fix
- `TASK_DIR` — the task dir (read `task.yaml` for the prompt/intent)

So an agent solver is roughly: build a prompt from `task.yaml`, point your agent
CLI at `$WORKSPACE` under a chosen skill configuration, let it edit files, return.
The runner scores it with the same objective checker. Drop it in `solvers/` and
it slots into the same curve as `baseline-noop` and `oracle`.

## Relationship to `.evals/`

`.evals/` (eval-creator) asks *"do promoted rules still hold?"* — regression of
**rules**. `bench` asks *"does the harness improve task outcomes?"* — a fitness
curve over **outcomes**. Complementary: rules guard against forgetting; bench
proves the loop is worth running. The natural follow-up is to have
`learning-aggregator` rank promotion candidates by their measured `bench` impact,
not just recurrence — closing the loop onto the metric.

## Status

Spike. Floor and ceiling work and discriminate across the seed corpus (3 tasks).
Agent solvers + the longitudinal curve are the next build; the substrate is ready
for them.
