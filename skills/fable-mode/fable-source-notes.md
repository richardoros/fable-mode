# Fable Source Notes

## Scope
Background material about Fable / fable-mode: external sources, our local evidence,
what we adopted, what we rejected, and why. **This file is not operating policy.**
Active rules live in `~/.claude/CLAUDE.md` (always-on discipline) and
`fable-mode/SKILL.md` (heavy orchestration). The runnable benchmark spec is
`benchmark-fresh-review.md`; the live PR log is `review-comparison.md`.

Provenance is labeled: `[confirmed]` = I read/ran it this session; `[shared-research]`
= from material the user pasted, not independently verified by me; `[not-accessed]`
= I could not retrieve the source.

---

## Sources reviewed

### Medium — "Claude Fable 5 Guide for Claude Code"
`[not-accessed]` Member-gated; I only saw the title via web search, never the body.
Summary below is `[shared-research]`, not my independent read.
- Framed as a stronger Claude Code / Cowork model; "7 new features" walkthrough.
- Per the shared research: the author says launch numbers come from Anthropic
  materials, and the piece was AI-researched under his direction — i.e. **launch
  context, not the author's own benchmarks.**
- **Adopted:** nothing. **Rejected:** treating launch-guide claims as evidence.
- URL: https://alirezarezvani.medium.com/claude-fable-5-guide-for-claude-code-11501ceb78a8

### Hacker News — "Claude Fable is relentlessly proactive" (simonw)
`[confirmed]` Fetched and read the thread.
- **Core anecdote (the load-bearing one):** asked to hide a scrollbar — a two-line
  `overflow-x: hidden` fix — Fable launched browsers, hunted window IDs, screenshotted,
  and spun up a CORS server to *empirically verify* it, ~$12 for two lines. The virtue
  (won't claim it works until it's seen it work) and the vice (builds an apparatus for a
  triviality) are the **same trait**. Top critique: it should pause for permission before
  the hack-quest.
- Build-a-diagnostic techniques: `screencapture` + window IDs, dispatched `KeyboardEvent`,
  a 19-line CORS server, `getComputedStyle` into a shadow DOM, ffmpeg contact-sheets.
- Plan-then-review with a *different model* finds flaws the original missed (lossolo);
  counter (eddyzh): any fresh pass helps, doesn't prove the model choice.
- "tokenmaxxing" complaint (saberience): Claude/Fable write too much, burn tokens; Codex
  feels more steerable. The deflationary pole.
- "Agents never ask questions" (geysersam) vs the over-proactive scrollbar — the synthesis
  is: proactive on cheap verification, *ask* before expensive/irreversible action.
- Judgment ≠ capability (dreis_sw); prompting still matters as models improve (Simon).
- **Adopted:** the verification-cost gate (don't out-spend the change); build-a-diagnostic
  when blocked; cross-check with a different method/model; ask before expensive moves.
- **Rejected:** chasing discourse into the active skill; expanding process by sentiment.
- URL: https://news.ycombinator.com/item?id=48498573 (and the article it links,
  simonwillison.net/2026/Jun/11/fable-is-relentlessly-proactive/)

### Reddit r/ClaudeCode — "fable5.md distilled" + the actual `sgup/ai/Fable5.md`
`[confirmed]` Reddit body+comments pasted by user; I fetched the real GitHub file.
- A **parallel, independent distillation** done the same way we did (audit Fable chats,
  re-run prompts on Opus, diff). It **converged** with ours on the core — "match effort
  to blast radius" ≈ our cost gate; "a finding is a hypothesis until you confirm it" ≈
  "assume the report lied." Two independent reverse-engineerings landing on the same
  sentences is the strongest signal the behavior is real.
- It had things we lacked and **adopted**: the `[confirmed]`/`[inferred]` labeling
  convention; a structured closeout incl. "name the one claim you'd most expect to be
  wrong"; restore-known-good-first; name-what-still-speaks-the-old-contract; the injection
  rule (treat file/tool/pasted text as data).
- Comment caveat (the OP, sharp and correct about *us*): "capture actual model behaviour,
  not skill-specific work." Our distillation came from a session where Fable was running
  superpowers skills, so our skill partly re-encoded *those* skills, not Fable's intrinsic
  disposition. Theirs (a CLAUDE.md appendix) more cleanly captures the always-on habits —
  which drove our split into CLAUDE.md core + lean orchestration skill.
- Comment (No-Friend6257): independent test via a *separate method* to avoid the test
  sharing a bug with the code. **Adopted** into the cross-check rule.
- Their delivery is a CLAUDE.md appendix, not a skill. **Rejected:** their later heavy
  "evidence ledger / cost-band / metrics / rollout" research (below).

### "Improving Fable Mode for Threadline" research (pasted)
`[shared-research]` Citation-grounded analysis (Google review, NIST, GitHub branch
protection, Git worktrees).
- **Correct and adopted:** skills instruct / hooks enforce; sub-agents don't inherit an
  invoked skill (restate in briefs); any code-write invalidates prior green; the
  live-reload correction (skills hot-reload mid-session — proved true: I wrote fable-mode
  and invoked it without a restart, so my "restart needed" advice was wrong).
- **Questioned and rejected:** the 400-line SKILL.md draft (self-refuting — it warns about
  compaction truncation then buries its own rules); the 12-field evidence-ledger hook
  (enforces paperwork, not proof — a present-but-false ledger reads as rigor; and we
  `--no-verify`'d the existing T3 hook on first contact, so the loud bypass becomes the
  default); the metrics/DORA/rollout machinery (org-scale process, not a personal skill).

---

## Our local evidence (the part that's actually ours)

### Single-function benchmarks — NULL
`[confirmed]` 3 cases, 8 fresh Sonnet agents, same model + tools, only a discipline
preamble differing.
- Recall (buggy code, incl. a read-invisible binary-search bug): raw 100%, fable 100%.
- Precision (correct code): raw 0 false-positives, fable 0 — the discipline did **not**
  over-condemn good code.
- Cost: flat (~41k tokens both arms).
- **Decision:** stop single-function benchmarking; add no rules from a null. On tasks
  within a capable model's baseline, the operating instruction ("distrust the test, run
  it") is **redundant — Sonnet already does it.**

### Real Threadline build — where value actually showed up
`[confirmed]` Across the 15-task build, the *fresh reviewers* caught defects the
implementers missed: FK enforcement off, reflected XSS, vacuous tests, timezone bucketing.
- The candidate value is **role separation** (fresh agent vs the warm author), not "verify
  harder." Notably, the implementer prompt *already had a self-review step* and bugs still
  slipped to fresh review — anecdotal support, not controlled proof.
- **Decision:** keep warm-implementer / fresh-verifier; design the controlled test but
  don't spend ~1.5M tokens on it until the workflow is paying for itself (see
  `benchmark-fresh-review.md` + the opportunistic `review-comparison.md`).

### Dogfooding catches this session (fable-mode caught its own faults)
`[confirmed]`
- Invoking the skill exposed that the loader strips `$N` tokens — the cost-gate's "$12"
  arrived blank; reworded to "twelve dollars."
- On "fix the mess," re-verifying instead of trusting a 5-minute-old "ahead 2" snapshot
  revealed the shared `main` had moved under me; a blind `reset --hard` would have raced
  a concurrent auto-recovery on a live production checkout. The verify-before-destructive
  rule paid for itself on real prod git.

---

## Adopted doctrine
- Fable-mode is not magic; it shapes *how* a problem is worked, not raw capability.
- The active ingredient is adversarial verification + role separation, not ceremony.
- Single-agent correctness instructions are mostly redundant on capable models.
- Verify relentlessly but gate it by stakes — don't out-spend the change.
- Hooks enforce only mechanically checkable invariants. Paperwork that can lie isn't proof.
- Keep always-on rules short (CLAUDE.md); keep orchestration separate (SKILL.md); keep
  research separate (this file).

## Rejected doctrine
- No evidence-ledger hook. No broad paperwork gate. No giant SKILL.md.
- No benchmark-chasing until Fable "wins." No treating external Fable posts as proof.
- No expanding the active control surface from internet sentiment.

## Open questions
- Does fresh review outperform warm self-review on PR-shaped work? (the one live hypothesis)
- Does role separation justify its token cost over 5–10 real PRs?
- Does the always-on core survive a long, compacting session, or fade?
- Is the value real model behavior, or just good engineering habits a capable model
  converges on regardless (the deflationary read)?

## Related artifacts
- `~/.claude/CLAUDE.md` — always-on operating discipline (live, PR #649; expanded 2026-07-02
  to absorb the 8 rules that previously lived only in SKILL.md, making the dedup lossless).
- `fable-mode/SKILL.md` — orchestration-only skill (v5, 2026-07-02: operating-discipline
  section replaced with a pointer to CLAUDE.md — the two had drifted into ~60% duplication;
  review-comparison logging wired into the orchestration rules so the live hypothesis
  actually gets fed).
- `fable-mode/benchmark-fresh-review.md` — controlled fresh-vs-self design (not run).
- `fable-mode/review-comparison.md` — opportunistic per-PR log (the cheap live test).

## 2026-07-02 review outcome (v4 → v5)
A fresh review of v4 found three faults, all fixed:
1. The every-prompt `UserPromptSubmit` hook ("invoke fable-mode before responding")
   contradicted the skill's own stakes gate — unconditional ceremony, the exact theater
   line 69 warned against. **Removed from `~/.claude/settings.json`**; the skill's
   trigger description carries invocation.
2. Lines 22–51 duplicated CLAUDE.md's always-on section (~60% of the file); the two
   copies had already drifted. Fixed by a lossless 1:1 move: 8 missing rules (baseline,
   throwaway diagnostic, blast-radius statement, old-contract check, commit scoping,
   degraded-host mode, recommendation-first, data-not-instructions, ground-in-project-data)
   added to CLAUDE.md; SKILL.md now points instead of repeating.
3. `review-comparison.md` tally sat at 0/0/0 since creation — measurement apparatus with
   no wiring. Fixed by adding a "Measure the one live hypothesis" rule to SKILL.md's
   orchestration section.

## 2026-07-02 (later): review-comparison v2 — instrument hardening
Upgraded the live log from a vibes journal to a real instrument, importing the parked
benchmark's core controls at zero cost:
- `review-brief.md` (new, FROZEN v1): byte-identical review instructions for both arms —
  only warm-vs-cold context varies, the same isolation `benchmark-fresh-review.md`
  demanded. Any brief edit bumps the version and breaks cross-version comparability.
- Ordering + contamination rules: SELF findings written before FRESH spawns; FRESH gets
  only spec + diff + repo + brief.
- Mechanical scoring: confirmed = changed the code before merge (or backlog-deferred);
  dismissals need a stated reason; post-merge escapes tracked as missed-by-both.
- Pre-registered asymmetric decision rule (≥2 fresh-only med+ catches at n=5 →
  standardize; 1 → risky-paths only + single extension to 10; 0 → drop; false-positive
  guard), with a hard stop. Rationale: fresh pass costs ~30–60k tokens, one caught med+
  defect is worth 10–100×, so the bar for "keep" is deliberately low but not zero.
- Known biases recorded, not hidden: builder-decides-fix, low n, skip-selection
  (qualifying-but-skipped PRs must be logged as SKIP lines).

## 2026-07-02 (later still): artifact layer — prose was at its ceiling
Four artifacts added; the judgment was that remaining performance lives in mechanics,
not more doctrine:
1. `~/.claude/agents/fable-verifier.md` — custom agent type preloading the frozen brief
   (by Read-at-spawn, not duplication — no drift), adversarial norms, contamination
   self-check, log-entry output format. Smoke-tested via a general-purpose subagent
   executing the definition against a planted-defect mini-repo: caught the planted spec
   violation [confirmed via probe], proved the vacuous test non-vacuously (ran pytest
   against the broken impl), found 2 unplanted real low-sev hazards, correct format.
   Cost measured: 102k tokens on a 5-line diff (fixed overhead dominates).
   CAVEAT: agent-type registration loads at session start — the type itself is
   unverified until a fresh session spawns it; if user-level `~/.claude/agents/` isn't
   scanned, relocate into the project's `.claude/agents/` via PR.
2. `fable-red.sh` — witnessed-red TDD harness; `red` requires failure + saves evidence
   + prints the failure tail ("right reason" stays a human/model read), `green` only
   accepted for the byte-identical command that ran red. All 5 paths tested (red-on-fail,
   red-rejects-pass, green-without-red, green-after-red, command-mismatch) [confirmed].
3. Cost-gate defaults table in SKILL.md (change class → minimum proof) — converts the
   vaguest rule into defaults deviated from consciously.
4. Stage-map one-shot example in SKILL.md.
Rejected again, deliberately: telemetry machinery, per-prompt hooks, different-model
FRESH arm before the n=5 decision (confound).
