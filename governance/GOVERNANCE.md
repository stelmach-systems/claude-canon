# Governance

How rules enter the canon, how they mature, how they get removed, and how a
release goes out. This file governs `canon/CLAUDE-canon-universal.md` (and its
Polish source variant); trial/audit mechanics live in `trials/`.

## Rule entry

Two ways in, both must be traceable:

- **Incident-backed**: confirmed by ≥2 documented incidents, across more than
  one project. The commit that adds the rule cites the evidence — where and
  when the missing rule actually cost something. Marked `(inc×N)` in the canon
  text.
- **Seed**: a distillate of the Fable 5 working methods, admitted without an
  incident requirement. Marked `seed` in the evidence ledger.

## Seed → confirmed maturation

A `seed` rule is promoted to **confirmed** the first time it's documented
actually catching something: a trial result (`trials/TRIALS.md`), a
stakes-declaration audit, or a real defect it prevented. Record the date and
what it caught as a row update in `governance/EVIDENCE.md`. A seed that stays
unconfirmed for ≥6 months falls under the exit rule below.

## Exit rule

A rule is a removal candidate at the next release if either holds:

- it's dead — ≥6 months with no confirmation and no incident, or
- it contradicts a newer, verified lesson.

The canon is allowed to shrink. Dead rules that linger erode trust in the
whole file more than a shorter file costs in coverage.

## Evidence ledger

Every rule in the canon has a row in `governance/EVIDENCE.md`:
rule → provenance → status → source. A rule with no row has no standing —
if you can't find its row, treat the rule as unverified and say so.

## Size budget

Hard limits, enforced by CI: **100 lines / ~11.5 KB**, measured on the
canonical Polish source. The installed English primary gets slightly more
headroom (12,500 bytes) to absorb translation expansion. A rule that would
push the file over budget requires removing or merging another one first —
budget pressure is a feature, not a bug to work around.

## Release checklist (any wording change)

1. Add or update the row in `governance/EVIDENCE.md`.
2. Re-read the new/changed wording against the task-archetype matrix (plain
   answer, research/analysis, plan mode, TDD new code, docs edit, production
   including an outage, tool without subagents, multi-session work, untrusted
   external content, an actively invoked skill, stakes escalating mid-task) —
   hunting for misfires (a correct rule firing at the wrong moment), not just
   known loopholes.
3. Check the size budget.
4. Run a verification panel sized to the stakes ladder.
5. Bump the version footer, commit with the evidence trail, push.
6. Regenerate the derived English export from the updated Polish wording and
   bump its stamp; CI's stamp guard fails the build if the EN and PL version
   stamps diverge.

## Derivation

This repo is a curated, translated export of a private, Polish-language
working canon developed and tested inside the owner's own environment
(trials, stakes-declaration audits, incident logs). The Polish source is
canonical; the English publication here is regenerated from it at each
release, with organization-specific material stripped by the leak guard
(`scripts/guard.sh`) before anything is pushed. Don't hand-edit the published
files independent of a source-side release — edits belong upstream.
