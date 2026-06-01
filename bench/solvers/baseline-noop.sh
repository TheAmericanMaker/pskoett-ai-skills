#!/usr/bin/env bash
# baseline-noop — the floor of the curve.
#
# A solver that does nothing. The workspace is left in its broken state, so a
# task's checker should FAIL. This proves the corpus tasks are genuinely broken
# (and gives the zero-effort reference point every other solver is measured
# against).
exit 0
