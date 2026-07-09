# claude-canon

**English** · [Polski](README.pl.md)

**A small, hard set of working rules for AI coding agents — injected into every session, and tested to make sure the model actually *applies* them.**

[![ci](https://github.com/stelmach-systems/claude-canon/actions/workflows/ci.yml/badge.svg)](https://github.com/stelmach-systems/claude-canon/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A *canon* is the part of `~/.claude/CLAUDE.md` (or `AGENTS.md`) that binds **every** model, tool, and project on a device: report honestly, prove "it works" with command output, verify by the stakes at hand, stop and ask at high stakes, prefer mechanisms over promises. It's model-agnostic — a distillate of the **Fable 5** working methods — and it ships with the thing most rule-sets lack: a way to check that a given model+tool is *following* it, not just carrying it.

> **What is "Fable 5"?** A codename for a Claude model whose observed working methods this canon distills — parallel fan-out, adversarial verification, structural bets over scalar iteration. The canon itself is model-agnostic and runs on any model or tool.

## Why this exists

Rules pasted into a system prompt are a *promise*. This repo treats that promise the way the canon treats code — **"mechanisms, not promises"** — and applies it to itself:

- **Honesty is enforced, not assumed.** A failing test shows its output; a skipped step is named; "almost works" is a defect. In the maintainer's own trials the worst violation (a silent edit reported as "nothing else changed") came from a *top-tier* model — capability doesn't remove the need for the rule.
- **Verification scales with stakes.** A typo needs a command's exit code; a money/law/production change needs an independent panel and a cross-model audit. A panel for a typo and no panel for production are *both* errors.
- **The document is allowed to shrink.** Every rule earns its place in an evidence ledger or gets removed. Dead rules destroy trust in the whole file.

## Quickstart

**Full install** (auto-updates, versions your `~/.claude` in git, drift check):

```bash
gh repo clone stelmach-systems/claude-canon ~/Developer/claude-canon
cd ~/Developer/claude-canon && ./install.sh
```

`install.sh` assembles `~/.claude/CLAUDE.md` from two parts and **never** overwrites your local part (see below). Check for drift with `./install.sh --check`; update later with `git pull && ./install.sh`.

**Single file, zero dependencies** — copy the canon and you're done:

```bash
cp canon/CLAUDE-canon-universal.md ~/.claude/CLAUDE.md   # Claude Code (any model)
# ...or into a project as AGENTS.md — for Codex / other tools
```

A Polish variant (the canonical source, see *Derived export* below) lives at `canon/CLAUDE-canon-universal.pl.md`.

## The two-layer model

```
~/.claude/CLAUDE.md
┌─────────────────────────────────────────────────────────────┐
│  CANON-UNIVERSAL   ← canon/CLAUDE-canon-universal.md         │
│  overwritten from the repo on every install (governed)      │  install.sh manages this
├─────────────────────────────────────────────────────────────┤
│  LOCAL             ← your paths, org playbook, stakes        │
│  thresholds, live-production inventory, local skills        │  install.sh NEVER touches this
└─────────────────────────────────────────────────────────────┘
```

The universal part is the same everywhere and is version-governed. The **local** part is yours — it's where you calibrate: what counts as "high stakes" in money terms, which systems are live production, which consents are standing. A fresh device gets `canon/CLAUDE-local-template.md` with TODOs.

## Governance — how a rule lives and dies

```
  entry ─┬─ incident ×N  (forged from ≥2 documented failures)  ──┐
         └─ seed         (a Fable 5 method distillate)          ──┤
                                                                  ▼
   every rule ⇒ a row in governance/EVIDENCE.md  ──►  seed ──(first documented catch:
                                                        a trial / audit / caught defect)──► confirmed
                                                                  │
   exit ◄── dead (≥6 mo. unconfirmed) or contradicted ───────────┘        budget: 100 lines / ~11.5 KB
```

Nothing enters on vibes. A rule is either **incident-backed** (it exists because its absence cost something, twice) or a **seed** (a distilled Fable 5 pattern), and it carries a row in [`governance/EVIDENCE.md`](governance/EVIDENCE.md) — rule → provenance → status. Seeds mature to **confirmed** the first time they demonstrably fire. Dead rules get cut. A hard size budget forces every addition to justify its bytes. Full model: [`governance/GOVERNANCE.md`](governance/GOVERNANCE.md).

## Trials — is the canon *applied*, not just installed?

The differentiator. [`trials/`](trials/) holds **13 scenarios** (T01–T13), each a situation → expected behavior → failure signature, covering the behaviors that matter: bug-without-repro, honest test status, anti-scope-creep, production consent, prompt injection, numbers-from-source, an unrecognized API, stakes that rise mid-task.

- **Runner** pastes a prompt into the model under test and captures raw output — **[`trials/RUNNER.md`](trials/RUNNER.md)**.
- **Grader** scores it against the key with a quote per marker — and is *never* the model it grades (self-assessment ≠ verification) — **[`trials/ANSWER-KEY.md`](trials/ANSWER-KEY.md)**.
- A model failing ≥3 trials runs under a compensation regime (rubric + per-phase verifier) regardless of task size.
- The stakes declaration (`stakes: trivial/significant/high → rung`) is greppable, so trials scale to a cheap continuous audit.
- **[`trials/CROSS-MODEL-AUDIT.md`](trials/CROSS-MODEL-AUDIT.md)** — a ready prompt to have a model from another family audit the canon (diversity over redundancy).

## Executable pieces (Claude Code)

- [`claude-code/agents/`](claude-code/agents/) — the canon's roles as subagents: **reader** (recon), **skeptic** (adversarial verify), **ladder-verifier** (independent stakes-ladder check), **trial-grader**. Install: `cp claude-code/agents/*.md ~/.claude/agents/`.
- [`hooks/stakes-check.sh`](hooks/stakes-check.sh) — a Stop hook that nudges when a file-changing turn had no stakes declaration.
- [`knowledge/orchestration-patterns.md`](knowledge/orchestration-patterns.md) — the full fan-out / adversarial-verify / judge-panel / loop-until-dry patterns (the canon carries the essence inline; this is the read-on-demand extension).

## Safety & derived export

This public repo is a **sanitized, one-directional export** of a private source of truth. The private ledger names real incidents; the public [`governance/EVIDENCE.md`](governance/EVIDENCE.md) keeps every rule, provenance class, and status but redacts incident titles/dates and internal tooling.

Safety is a **mechanism, not discipline**, and it's two-tier:
- [`scripts/guard.sh`](scripts/guard.sh) — a fail-closed *hygiene* guard that **fails CI** on generic leak shapes: absolute paths, secret-token patterns, personal-provider emails, device fqdns. It ships in the repo and deliberately contains **no** private names — a denylist of private names would itself leak them. Run it yourself: `bash scripts/guard.sh .`
- an **owner-specific denylist** (client/host/tooling names) lives only with the private source and scans the whole export — the guard file included — before every push.

**What never lives here:** memory, session lessons, transcripts, client data, secrets, tokens. Those belong to their own mechanisms — not a repo cloned across devices.

## Layout

```
canon/        the canon: EN primary (.md) + PL variant (.pl.md) + local template
install.sh    tests/  .github/workflows/ci.yml        install + scenarios + CI
governance/   GOVERNANCE.md (the model) + EVIDENCE.md (the ledger)
trials/       T01–T13 + RUNNER + ANSWER-KEY + CROSS-MODEL-AUDIT + build-package.sh
claude-code/  agents/ (reader · skeptic · ladder-verifier · trial-grader)
hooks/        stakes-check.sh          knowledge/ orchestration-patterns.md
scripts/      guard.sh (fail-closed leak guard)
```

## License

[MIT](LICENSE). Contributions are proposals to the methodology — see [CONTRIBUTING.md](CONTRIBUTING.md).
