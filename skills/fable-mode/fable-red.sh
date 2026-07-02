#!/usr/bin/env bash
# fable-red.sh — witnessed-red TDD harness (fable-mode).
# A test you didn't see fail is not yet a test. This makes the ritual two commands
# with an evidence trail, keyed so green is only accepted for the SAME command
# that produced the red.
#
# Usage:
#   fable-red.sh red   <test command...>   # BEFORE the fix: must FAIL; saves evidence
#   fable-red.sh green <test command...>   # AFTER the fix: must PASS; requires prior red
#
# Plain argv commands only (e.g. `fable-red.sh red uv run pytest tests/x.py::test_y`);
# no pipes/shell syntax. Evidence in $FABLE_RED_DIR (default /tmp/fable-red).
# NOTE: "failed for the RIGHT reason" cannot be mechanized — read the printed tail
# of the red log and confirm the failure is the defect, not a typo/import error.
set -u
[ $# -ge 2 ] || { echo "usage: fable-red.sh red|green <test command...>"; exit 2; }
mode=$1; shift
dir="${FABLE_RED_DIR:-/tmp/fable-red}"
mkdir -p "$dir"
key=$(printf '%s' "$*" | md5sum | cut -c1-12)
out="$dir/$key.$mode.log"

"$@" >"$out" 2>&1
rc=$?

case "$mode" in
  red)
    if [ $rc -eq 0 ]; then
      echo "FABLE-RED ✗ test PASSED before the fix — not a witnessed red. Wrong test, or the bug isn't reproduced. ($out)"
      exit 1
    fi
    printf '%s\n' "$*" > "$dir/$key.cmd"
    echo "witnessed red (exit $rc) — evidence: $out"
    echo "--- failure tail (confirm this is the RIGHT reason before fixing) ---"
    tail -n 12 "$out"
    ;;
  green)
    if [ ! -f "$dir/$key.red.log" ]; then
      echo "FABLE-RED ✗ no witnessed red exists for this exact command — run 'red' first (or the command text differs)."
      exit 1
    fi
    if [ $rc -ne 0 ]; then
      echo "FABLE-RED ✗ still failing (exit $rc) — $out"
      tail -n 12 "$out"
      exit 1
    fi
    echo "green after witnessed red ✓ — evidence pair: $dir/$key.red.log + $dir/$key.green.log"
    ;;
  *)
    echo "usage: fable-red.sh red|green <test command...>"; exit 2
    ;;
esac
