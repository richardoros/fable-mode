---
name: fable-mode
description: Staged orchestration for genuinely multi-stage builds — stage map, warm implementer / fresh adversarial verifier, witnessed-red TDD, re-verify on every change. Builds on the always-on operating discipline in ~/.claude/CLAUDE.md (verify by re-execution, [confirmed]/[inferred] labeling, cost/blast gating), which applies to every non-trivial action with or without this skill. Triggers on "do this thoroughly", "be systematic", "act like Fable", "deep work mode", and proactively on multi-stage builds where "looks done but isn't" is the real risk. Not for typos or single-file fixes — the always-on rules already cover those.
---

# Fable Mode

Verify by re-executing, assuming the last step lied. The load-bearing beam is **adversarial verification** — a fresh check that re-runs the command and reads the output instead of trusting a report, including your own confident guess. Stages and sub-agents without that are theater and catch nothing.

## Prerequisite: the always-on core

The operating discipline — `[confirmed]`/`[inferred]` labeling, runtime proof, report-is-a-hypothesis, baselines before comparative claims, blast-radius and rollback gating, inspection-first on degraded hosts, the closeout — lives in `~/.claude/CLAUDE.md → Always-on Operating Discipline` and applies to **every non-trivial action**, with or without this skill. This skill adds only the orchestration layer for genuinely multi-stage builds. If those rules have faded (long session, post-compaction), re-read that section before proceeding.

Two guards, both directions:
- **Don't under-build:** a typo, a one-line obvious fix, a single clear function — just do it, no apparatus.
- **Don't let verification run away:** be relentless about cheap verification; **stop and ask before the verification apparatus costs more than the change.** Match effort to stakes in both directions.

Default proof per change class (deviate consciously, not by drift):

| Change class | Minimum proof |
|---|---|
| Docs / comments / no runtime surface | read the diff back; no apparatus |
| Runtime code, ordinary path | run the tests touching the changed files + exercise the changed path once |
| Risky path (auth, migration, money, deletion, concurrency) | `fable-verifier` fresh review + runtime exercise + witnessed-red on the fix |

## Orchestration (multi-stage builds only)

- **Stage map first** — numbered stages, a one-line expected output each, and the done criteria. Catches a stage-2 wrong assumption before stage 7. Shape:
  ```
  1. Schema + migration — expect: alembic upgrade clean on seeded DB — done: old rows still readable
  2. Write path — expect: POST persists [confirmed via curl] — done: row visible in psql
  3. Read API — expect: GET returns new field — done: contract test green
  4. Fresh review — done: fable-verifier findings scored, log entry written
  ```
- **Delegate independent work in parallel — but serialize anything that writes shared mutable state.** A git working tree, a database, a file, a build dir: concurrent writers corrupt each other. Parallelize reads, research, and verification freely; serialize shared writes.
- **Brief sub-agents completely** (task, output, paths, conventions, acceptance) and end every brief with **"ask questions before you begin."** Keep an implementer **warm** across fix cycles; spawn every verifier **fresh** — independence is the point. A fresh sub-agent does **not** inherit this skill — for verification, spawn the **`fable-verifier` agent type** (preloads the frozen brief + adversarial norms; reproducible across sessions); for other sub-agents, restate the load-bearing rules in the brief.
- **Verify each stage adversarially before advancing; loop fix → re-verify until clean.** Where you can, cross-check with a **different method or model** — a fresh pass of the same model shares its blind spots, the way a test that shares a bug with the code won't catch it. **Any code-modifying change — even a one-line fix — invalidates prior green; re-verify on the latest state, never inherit an old pass.**
- **TDD with a witnessed red phase:** write the test, watch it fail for the right reason, then fix, then watch it pass. A test you didn't see fail is not yet a test — this is what catches vacuous ones. Harness: `~/.claude/skills/fable-mode/fable-red.sh red <test cmd>` before the fix (must fail; read the printed failure tail to confirm the *reason*), `... green <same cmd>` after (must pass; rejects a green with no matching red).
- **Tune the ceremony to risk:** full separate spec + quality review for foundational/irreversible/security work; one combined check for additive, low-blast work.

## Measure the one live hypothesis

On every PR with a non-trivial code diff, run the two-arm comparison and log it in `review-comparison.md` (this directory) — full protocol and pre-registered decision rule live there. The short form, order load-bearing:
1. **SELF**: builder reviews its own final diff using `review-brief.md` verbatim; write findings into the log **before** step 2.
2. **FRESH**: spawn the **`fable-verifier`** agent type with only spec + diff + repo — never the self-review or the builder's context. It preloads the brief and returns output in log-entry format (paste it).
3. **Score at merge** (mechanical: did the finding change the code?) and update the tally. Qualifying PR shipped without the protocol → log a one-line SKIP.

Role separation is the only fable-mode mechanism with any evidence behind it, and that evidence is anecdotal. Decision fires at 5 logged PRs — an unfed log is dead paperwork; feed it or the hypothesis stays open forever.

## Closeout

Close with the always-on closeout (confirmed vs inferred vs couldn't-verify, what only the user can verify, git state, ordered next steps, the one claim most likely to be wrong). For multi-stage builds, add per-stage verification results and the commit hash / gate counts vs baseline.

## What this does not do

It does not make the model smarter. Reasoning, synthesis, and judgment still come from the model; this shapes *how* it works a problem. The process is **not** the active ingredient — adversarial, evidence-based, looped verification is. And the same trait that makes this useful (won't claim it works until it's seen it work) is what makes it expensive (it'll build an apparatus to see a triviality) — the cost/blast gate is the governor that keeps the virtue usable.

A skill **instructs; it cannot enforce.** For an invariant that must never be skipped, back it with a hook or a required status check — but only for **mechanically checkable** invariants; paperwork that can lie isn't proof, and an every-prompt reminder hook is the ceremony this file warns against (one was removed for exactly that reason — see `fable-source-notes.md`).

When a task is genuinely beyond the model's capability, **flag it** rather than produce plausible-sounding wrong output. A confident wrong answer is the exact failure this exists to prevent.
