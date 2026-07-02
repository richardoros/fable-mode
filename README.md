# fable-mode

A Claude Code skill for staged orchestration on genuinely multi-stage builds:
stage map, warm implementer / fresh adversarial verifier, witnessed-red TDD,
and re-verification on every change.

The load-bearing idea is **adversarial verification** — a fresh reviewer that
re-runs the command and reads the output instead of trusting a report,
including the builder's own confident guess. Stages and sub-agents without
that are theater and catch nothing. See `skills/fable-mode/fable-source-notes.md`
for the design log (sources reviewed, what was adopted/rejected, and why).

## What's in here

- `skills/fable-mode/SKILL.md` — the skill itself.
- `skills/fable-mode/review-brief.md` — frozen, byte-identical review
  instructions given to both the self-review and fresh-review arms.
- `skills/fable-mode/review-comparison.md` — the live per-PR log measuring
  whether fresh review actually catches more than self-review (the one
  hypothesis this skill runs on).
- `skills/fable-mode/benchmark-fresh-review.md` — a pre-registered, not-yet-run
  controlled benchmark design for the same question.
- `skills/fable-mode/fable-red.sh` — a witnessed-red TDD harness: `red`
  requires the test to fail and saves evidence, `green` is only accepted for
  the byte-identical command that produced that red.
- `skills/fable-mode/fable-source-notes.md` — provenance-labeled research log.
- `agents/fable-verifier.md` — a custom Claude Code agent type: a fresh,
  read-only adversarial verifier preloaded with the frozen review brief.
- `CORE-DISCIPLINE.md` — the always-on operating discipline this skill
  assumes is already in force (verify-by-reexecution, blast-radius gating,
  etc.), extracted from a personal global CLAUDE.md so this repo is
  self-contained.

## Install

```
cp -r skills/fable-mode ~/.claude/skills/fable-mode
cp agents/fable-verifier.md ~/.claude/agents/fable-verifier.md
```

Then fold `CORE-DISCIPLINE.md` into your own always-on instructions (global
`~/.claude/CLAUDE.md` or project-level equivalent) — either merge its content
in directly, or point `SKILL.md`'s "Prerequisite" section at this file. The
skill's orchestration layer only pays off if that baseline discipline is
already active; it does not restate it.

## License

MIT — see `LICENSE`.
