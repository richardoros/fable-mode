# Benchmark: does a fresh verifier catch more than self-review?

Status: **designed, not run** (real budget — see Cost). Pre-register everything below, then run exactly as written.

## Hypothesis
A fresh verifier catches more hidden implementation defects than the implementer reviewing its own work. This is the only fable-mode mechanism the single-function benchmarks could not reach, and it is where the real Threadline build's catches actually came from — FK-enforcement-off, reflected XSS, vacuous tests, timezone bucketing — all caught by fresh review of an implementer's diff, none by "a model read a function better."

## The one control that matters
Compare the **same implemented diff** reviewed two ways:
- **SELF** — the original builder agent, **resumed warm** (its build context intact), reviews its own final diff.
- **FRESH** — a new (cold) agent reviews the **exact same diff** with **byte-identical** review instructions.
- *(Optional)* **FABLE-FRESH** — a new agent + the lean fable review instructions, to test whether the instruction adds anything *on top of* role-separation.

Only the variable "author vs fresh" may differ. Same diff, same spec, identical prompts, neither reviewer sees the oracle, FRESH never sees SELF's output.

## Why you cannot pre-seed the defect
The author blind-spot is real only if the author wrote the bug. Injecting a defect into a foreign diff removes ownership and collapses SELF and FRESH into "same model twice vs two models" — measuring nothing. So: real builders implement from spec; a runnable hidden oracle detects whatever defect actually emerged; score reviews on catching **that**. Tasks where the builder implemented correctly become the **false-positive probe**.

## Corpus — 6 PR-sized tasks (pre-register, no edits after launch)
Each: a product spec, 2–5 files, normal tests, and a runnable **hidden oracle** that objectively detects one defect class. Pick task types that are trap-prone the way real agents err (mirror the real Threadline catches, not toy algorithms):

| Task | Defect class the oracle checks |
|---|---|
| Auth/session change | stale-token path still authenticates |
| DB relation/migration | FK / cascade declared but not enforced |
| UI error page | reflected XSS through an error string |
| Date bucketing | naive-timezone boundary bug |
| Prompt-budget logic | `continue` vs `break` divergence |
| Test-coverage task | vacuous test passes without exercising behavior |
| Pagination/cursor | duplicate or skipped row at the boundary |
| Scraper state update | retry / idempotency duplicate |

## Protocol (per task — no retries, no prompt edits after launch)
1. Builder agent implements from spec → save the final diff and working tree.
2. Run the hidden oracle → record (objective) whether a defect of the target class is present.
3. **SELF**: resume the builder (warm) → identical review prompt; does NOT see the oracle.
4. **FRESH**: new cold agent → **identical** review prompt; given spec + diff + repo; no oracle; does NOT see SELF's output.
5. *(Optional)* **FABLE-FRESH**: new cold agent + lean fable review instructions; same inputs.
6. Score each review against the oracle.

## Per-task "caught" criterion (pre-register before running)
For each task, write the exact condition that counts as caught, e.g. *"names that an orphan-FK insert succeeds / FK not enforced"* or *"flags the reflected XSS in the error string."* Caught = the review names the oracle's defect with actionable specificity. No partial credit.

## Scoring
- **Primary:** critical hidden defects caught, SELF vs FRESH — counted only on tasks where the oracle found a defect.
- **Secondary:** false positives (blocking defect invented on correct code), evidence quality (cites file:line / runtime behavior), fix specificity, spec-coverage check, stale-green detection, scope discipline; tokens + tool calls per arm.

## Pre-registered stop rule + win condition
- Run **exactly 6 tasks**, 1 build each, 1 SELF + 1 FRESH (+ optional FABLE-FRESH). No retries. **No extra tasks after seeing results. Stop even if null.**
- **Win:** FRESH catches **≥2 more** critical defects than SELF across 6 tasks, without materially more false positives.

| Result | Interpretation |
|---|---|
| SELF 2/6, FRESH 5/6 | role separation valuable |
| SELF 4/6, FRESH 5/6 | small gain, maybe not worth overhead |
| SELF 5/6, FRESH 5/6 | null — capable model self-reviews fine |
| SELF 5/6, FRESH 3/6 | fresh review is noise / backfires |

## Cost (state the blast radius before committing)
~6 builds + 12 reviews (18 with FABLE-FRESH) = **18–24 agent runs**. Builds are full implementations (~80–130k subagent tokens each, per the Threadline build); reviews ~40k each. Rough total ≈ **1.0–1.5M subagent tokens** + orchestration. This is the "real budget" — the reason it is designed, not run.

## Power caveat
6 tasks × 1 build is low statistical power; a ±1 swing is within noise. The ≥2 threshold is a coarse directional signal, not a p-value. A real study needs more tasks and multiple builds per task; this is a first, honest probe.
