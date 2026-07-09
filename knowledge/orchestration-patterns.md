# FABLE5 — orchestration patterns (a distillate of how Fable 5 works, for any model)

> Read ON DEMAND (not injected into the session) — trigger: a line in the global `~/.claude/CLAUDE.md` ("tasks wider than one context"). Changed by the canon maintainer. Sources: internal method notes (verified), a setup audit (Agent and Workflow tool usage — the best-performing part of the setup). 2026-07-06.

## 1. Cycle for a non-trivial task

recon → plan/rubric → implementation → panel → report.
- Recon: parallel readers in separate contexts, each with a CONCRETE question; they return distillates, not files.
- Plan/rubric: checkable criteria BEFORE the first line of change; "done" is defined by the rubric.
- Implementation: the shortest working diff (global rule: YAGNI).
- Panel: per the verification ladder — ONE source of wording: the canon, section "Before you say it's done" (not copied here, so the two wordings don't drift). On production: panel BEFORE the owner's approval and the push, not after.
- Report: result/verdict in the first line.

## 2. Fan-out (parallel decomposition)

- Cut along DIMENSIONS, not files: bugs/perf/security/compliance; by-container/by-content/by-entity/by-time. Each agent blind to the others — that's a feature (independence), not a bug.
- Pipeline by default (an item moves through stages without waiting for the rest); a barrier ONLY when stage N needs ALL of stage N-1's results (dedup, early-exit on zero findings, "vs. the rest" comparison).
- Explicitly log what was skipped (top-N, sampling) — a silent cutoff reads as "everything was covered."

## 3. Adversarial verify (verification by rebuttal)

- N independent skeptics, each tasked with REBUTTING the finding/claim. A rebuttal is a concrete counter-proof OR showing the finding has no proof the skeptic actually CHECKED (repro run, source opened — a claimed-but-not-run proof doesn't count); "I'm not sure" alone doesn't settle it — otherwise a weak skeptic rebuts everything and the pattern degenerates to zero findings.
- Majority rebuts → the finding falls. Only what couldn't be rebutted survives.
- Skeptics from DIFFERENT perspectives (correctness, security, is-it-reproducible), not N identical ones — diversity catches what redundancy misses.

## 4. Judge panel (wide solution space)

- N independent approaches from different angles (e.g., MVP-first / risk-first / user-first) → independent judges score them against a rubric → synthesis from the winner plus the best ideas from the runners-up.
- Better than iterating on a single approach when the solution space is wide (architecture, strategy).
- This is NOT the verification panel from the global ladder: run the judge panel BEFORE implementation (choosing an approach); the verification panel runs AFTER the change (assessed per stakes). On a large refactor both may apply — §4 first, the ladder at the end.

## 5. Loop-until-dry (discovering an unknown number of problems)

- Successive rounds of independent finders until K rounds in a row (usually 2) turn up nothing new. A "find N" counter loses the tail of the distribution.
- Dedup against EVERYTHING seen (including what judges rejected) — otherwise a rejected item comes back every round and the loop never converges.

## 6. Structural bets (the essence of Fable)

- The rule lives in the global canon (section "Work"); context here: after 2 failures with the same approach, change the STRUCTURE of the approach — back to recon, decompose into smaller pieces, a different tool, a different representation of the problem. NEVER a third iteration of the same screw.
- Evidence: Fable improved a pipeline roughly 6x more than Opus 4.7 precisely through structural bets (internal method notes); scalar iteration gets stuck in a local optimum.

## 7. Delegation

- The rules on distillates and parallelism live in the global canon (Economy of effort); refinement here: an assignment for an agent = a CONCRETE question + the expected distillate format (≤20 lines of conclusions) + scope (files/directories/sources). Never "read everything and tell me about it."
- Merge results from distillates; raw dumps don't enter the main context.
- Send independent assignments in ONE step (in parallel); sequential only when result A is input to B.
- Route by cost: a mechanical role (reader, extractor) on the cheapest model; a judgment role (skeptic, judge, auditor) on the strongest. The ≤20-line distillate format applies to every role.

## 8. Per-model compensation regime

- Not sure you're a Fable-class model → treat yourself as a scalar iterator (Opus and weaker): on rubric-based (multi-stage) assignments, a rubric file BEFORE implementation is MANDATORY + an independent verifier AFTER EVERY phase (not just at the end); single fixes are exempt from this regime. The rubric plus verifier compensate for the lack of structural judgment. Without subagents (Codex CLI): after every phase, proof by command per the ladder, with the owner's own independent runs at the end and at high-stakes phases — don't pester the owner for a fresh session after every phase.
- Design the ENVIRONMENT with feedback (tests, logs, a `/goal` with a condition readable from output) instead of counting on the model's self-critique — self-critique in one's own context window fails in every model.
- At HIGH STAKES, the auditor must be a stronger model or from a different family than the implementer (the organization's playbook: Opus builds, Fable audits; cross-model at money/legal/production). Falling back to a weaker auditor model is forbidden — an audit must fail loudly, not degrade quietly.
- A model without subagents (Codex, bare CLI): apply the same patterns sequentially — each role (finder/skeptic/judge) in a fresh window/session, results exchanged via distillate files.
