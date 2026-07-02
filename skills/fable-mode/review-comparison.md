# Fresh-vs-warm review comparison log — v2

Measures the one live fable-mode hypothesis: **does a fresh verifier catch defects the
warm builder's self-review misses on real PRs?** This is the only mechanism with any
evidence behind it (anecdotal: the Threadline build's FK/XSS/vacuous-test catches), and
the v1 log sat at 0 entries for lack of wiring. v2 fixes the wiring (SKILL.md →
"Measure the one live hypothesis") and upgrades the instrument: both arms now get
**byte-identical instructions** (`review-brief.md`, frozen v1) so the only variable is
warm-vs-cold context — the same control the parked ~1.5M-token benchmark
(`benchmark-fresh-review.md`) was designed around, obtained here for free.

## Which PRs to log

Log every PR where the session **authored a non-trivial code diff**: touches runtime
code and is more than a trivial edit (~30+ changed lines, or ANY diff on a risky path —
auth, migrations, money, concurrency, deletion). Docs/config-only PRs: skip. If a
qualifying PR ships without the protocol (time pressure, forgot), add a one-line
`SKIPPED — PR #n, reason` entry — unlogged skips are silent selection bias.

## Protocol (order is load-bearing)

1. **SELF first.** After the diff is final, the builder reviews its own diff using the
   brief in `review-brief.md`, verbatim. Write the findings into a log entry draft
   **now, before step 2** — self-review written after seeing fresh output is
   contaminated and must be marked void.
2. **FRESH second.** Spawn the **`fable-verifier` agent type** (`~/.claude/agents/`)
   with ONLY: spec/task description, the diff, repo path. It preloads the frozen brief,
   self-checks for contamination, and returns findings in log-entry format. Not the
   self-review, not the builder's session context. Same model as the builder unless
   deliberately varied; record the model per arm.
3. **Score at merge.** For every finding from either arm, record what happened by
   merge time (the mechanical criterion below). Then update the running tally.

## Scoring — mechanical, not judgment

A finding counts as a **confirmed defect** iff it changed the code before merge
(a fix commit) or was explicitly deferred with a backlog entry (`confirmed-deferred`).
A finding the builder dismissed with a stated reason = **false-positive candidate**
(mark `disputed` if the dismissal itself is shaky). A defect discovered post-merge that
neither arm caught = add to `missed-by-both` in the tally — the honest denominator.

Known biases, accepted and recorded rather than pretended away:
- *Builder-decides-fix bias*: the warm builder chooses whether a finding "changed the
  code." Mitigation: the fix/dismiss decision is visible in the PR; dismissals must
  state a reason in the entry.
- *Low n*: 5 PRs is a directional signal, not significance. The decision rule below is
  asymmetric because the payoffs are: a fresh pass costs ~100k tokens (measured: the
  2026-07-02 fable-verifier smoke test spent 102k on a 5-line diff — fixed overhead
  dominates, so real diffs won't scale linearly); one caught med+ defect saves a
  debug/incident cycle worth 10–100× that.

## Pre-registered decision rule (written before any entry exists — do not edit after)

Evaluate at **5 logged PRs**, hard stop:
- **Fresh-only confirmed catches (severity ≥ med) ≥ 2** → standardize the fresh pass
  for all non-trivial PRs.
- **Exactly 1** → keep the fresh pass for risky-path PRs only; extend the log to 10
  PRs (one extension, never more), then re-apply this rule with thresholds doubled.
- **0** → drop the fresh pass as a default; warm self-review suffices. Keep independent
  verification only where the always-on rules already demand it (irreversible/security).
- **False-positive guard**: if FRESH's false positives exceed SELF's by >3 across the 5
  PRs while fresh-only catches ≤ 1, fresh review is noise here — drop it regardless.
- Self-only catches are recorded too: if SELF beats FRESH, that's a real (and cheaper)
  answer — warm context helps more than independence. Report it, don't bury it.

## Entry template

```
## PR #<n> — <title>   (date, brief_version: v1)
- Task/spec: <one line>
- Diff size / risk path: <e.g. 4 files, +180/-40, touches auth: yes/no>
- Builder model: <model>  | Fresh model: <model>
- SELF findings: <each: file:line — sev — defect — [confirmed|inferred] — outcome: fixed|deferred|dismissed(reason)>
- FRESH findings: <same format>
- Fresh-only confirmed catches (THE SIGNAL): <list or none>
- Self-only confirmed catches: <list or none>
- False positives: self <n> / fresh <n>
- Cost: fresh arm ≈ <subagent count / rough tokens if visible>
- Post-merge escapes traced to this PR (fill in later if any): <none yet>
```

### EXAMPLE — fabricated, not data (PR #000)
SELF finds `app/x.py:42 — med — off-by-one in pagination cursor — [inferred] — fixed`.
FRESH finds the same, plus `tests/test_x.py:10 — med — test passes with feature
reverted (vacuous) — [confirmed: ran with revert] — fixed`. Fresh-only confirmed
catches: 1 (the vacuous test). False positives: 0/0. That entry moves the tally.

---

# Entries

(none yet — first qualifying PR starts here)

---

# Running tally

- PRs logged: 0   | skipped-but-qualifying: 0
- Fresh-only confirmed catches, sev ≥ med (the signal): 0
- Fresh-only confirmed catches, low: 0
- Self-only confirmed catches: 0
- False positives — self / fresh: 0 / 0
- Missed-by-both (post-merge escapes on logged PRs): 0

> Decision point: at 5 logged PRs, apply the pre-registered rule above. No
> peeking-based edits to the rule; no extensions beyond the single 10-PR case.
