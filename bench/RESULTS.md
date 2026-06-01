# Bench Results — the harness fitness curve

Each row is one run of the corpus under one solver. `baseline-noop` is the
floor (agent does nothing); `oracle` is the ceiling (known-good fix). Agent
solvers (skills-off vs inner-loop vs inner+outer) land in between — that gap,
tracked over time, is the harness's measured value.

| timestamp (UTC) | solver | pass | total | failed tasks |
|-----------------|--------|------|-------|--------------|
| 2026-06-01T15:12:24Z | baseline-noop | 0 | 3 | logic-offbyone-pagination,missing-guard-safediv,wrong-test-assumption-viewport |
| 2026-06-01T15:12:24Z | oracle | 3 | 3 | — |
