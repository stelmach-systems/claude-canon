# Contributing to claude-canon

This repo is a **derived public export**. The maintainer's private repo is the source of
truth; accepted changes here get folded back upstream and re-exported. Expect review to
take that round-trip into account — a PR is a proposal to the methodology, not a guaranteed
merge.

## How a rule enters

- **Seed**: a distillate of the underlying Fable 5 working method, admitted without an
  incident requirement — but tagged `seed` in the evidence ledger and expected to mature.
- **Incident-backed**: forged from ≥2 documented, cross-project failures where the rule's
  absence cost something. Tagged `(inc×N)` in the canon text.
- A `seed` matures to **confirmed** the first time it's caught something for real — a trial
  run, a stakes-declaration audit, a real defect. That, too, is logged.
- A rule with no ledger row has no standing in the canon. A rule that's gone stale (no
  confirming signal in a long stretch, or superseded by a newer verified lesson) is a
  candidate for removal, not indefinite carry.

Full process, statuses, and exit criteria: see [`governance/GOVERNANCE.md`](governance/GOVERNANCE.md).
Every proposed rule change needs a matching row in [`governance/EVIDENCE.md`](governance/EVIDENCE.md)
(rule → provenance → status → source) — a PR that edits `canon/` without one will not be merged.

## Size budget

`canon/CLAUDE-canon-universal.md` is hard-capped (CI-enforced) at 100 lines / 12,500 bytes,
and its version stamp must match the Polish original's. A new rule above budget requires
cutting or merging another — the canon is allowed to shrink.

## Before opening a PR

```bash
bash tests/test-install.sh   # installer scenarios
bash scripts/guard.sh .      # fails closed on any internal/private marker
```

CI also runs shellcheck and regenerates `trials/TEST-PACKAGE.md` to confirm it still matches
the `trials/Txx.md` sources. All of these must pass before review.
