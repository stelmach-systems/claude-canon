# RUNNER INSTRUCTIONS — running the trial package (you paste, I grade)

**8 sessions total**: ChatGPT 5.5 ×2 (with canon / without), Gemini ×2, Codex ×2, Claude Code Opus ×1, Sonnet ×1 (in Claude Code the canon is always injected, so we don't run a "without canon" variant there — we measure the delta on ChatGPT/Gemini/Codex instead). Everywhere, use the highest reasoning mode below "ultra" (Claude Code: `/effort xhigh`; ChatGPT: GPT-5.5 in extended-thinking mode; Gemini/AI Studio: maximum thinking budget).

## Running a single session (always the same)

1. FRESH chat/session.
2. "With canon" session: first load the canon (below), then paste the full contents of `trials/TEST-PACKAGE.md`. "Without canon" session: just the package.
3. Collect the result: a downloadable `results.md` file (if the tool supports it) or copy the answer block.
4. Save as `trials/results/<model>.md`; control variant: `trials/results/<model>-nocanon.md`. Model names: `chatgpt55`, `gemini`, `codex`, `opus`, `sonnet`.
5. Once a batch is collected — in Claude Code: **"grade trials/results"**. I score against ANSWER-KEY (verdict only with a quote), fill in the table, update the evidence ledger, propose conclusions.

## How to load the canon (contents of `CLAUDE-canon-universal.md`)

**Universal method — first message (RECOMMENDED, works everywhere and guarantees full context, no RAG involved):** in a new chat, first send:

> From now on, the rules below govern your work in this conversation. Apply them to all subsequent messages. Confirm in one sentence and wait for tasks.
>
> [paste the FULL contents of CLAUDE-canon-universal.md]

After confirmation — second message: the package.

**ChatGPT 5.5 (app):** pick the GPT-5.5 model with extended reasoning and use the first-message method. Alternative for multiple sessions: a Project with the canon pasted into the Project Instructions — but files uploaded to a project are sometimes retrieved via search (RAG) rather than read in full, so an attached file is less reliable for this test than a paste; Custom Instructions in settings have too small a limit for the whole canon. (UI details get rearranged over time — the first-message method is resistant to those changes.)

**Gemini:** cleanest via **Google AI Studio** (aistudio.google.com): the "System instructions" field → paste the whole canon, pick the highest available Gemini model, thinking at maximum, then the package as a message. In the consumer Gemini app: use the first-message method; a Gem with instructions also works, but check that the field limit hasn't truncated the content (the canon is roughly 11.4k characters). (As above — UI gets rearranged.)

**Codex (CLI):** in the working directory, place the canon contents as `AGENTS.md` (repo instructions, variant 2); the "without canon" variant = a directory with no AGENTS.md.

**Claude Code (Opus/Sonnet):** you don't load anything — the canon lives in `~/.claude/CLAUDE.md`. `/model opus` or `/model sonnet`, `/effort xhigh`, paste the package.

## Control runs "-nocanon" (measuring the delta)

**Claude Code (mechanism verified 2026-07-07: without the flag, Haiku sees the canon header; with the flag, it doesn't):**

1. Terminal, the SAME directory as the with-canon run.
2. Start the session: `claude --settings '{"claudeMdExcludes":["**/.claude/CLAUDE.md"]}'`
3. `/model` and `/effort` EXACTLY as in the arm you're comparing against (e.g. sonnet + max).
4. Paste the package, save the output as `trials/results/<model>-nocanon.md`.

What this flag does: it excludes only `~/.claude/CLAUDE.md` (canon + local rules) from context. Hooks, the organization's playbook digest, project-level instructions, and memory stay identical across both arms — the only variable is the canon. So the delta measures the ENTIRE user file (canon + local rules), not the universal portion alone.

**ChatGPT / Gemini control:** fresh chat, ZERO canon, straight to the package → `<model>-nocanon.md`.

**Automated `-p-` pairs (print modality, non-interactive):** files `*-p-withcanon.md` / `*-p-nocanon.md` are produced via `claude -p --model <m> --settings '{"effortLevel":"xhigh"[,"claudeMdExcludes":[...]]}' "<package>"`. This is a separate modality (no interactive tools, the model more often answers "dry") — compute the delta WITHIN the `-p-` ↔ `-p-` pair, never mixing with interactive runs; mark it "(pp)" in the table. Effort "max" isn't available in settings (only up to xhigh), so `-p-` pairs run on xhigh.

**Package version comparability:** the package changes over time (e.g. T02 v2 after 2026-07-07) — compare the control arm against the with-canon arm on the same version; tests whose wording changed should be marked in the table as non-comparable for delta purposes.

**Paste hygiene:** copy the content fresh from the file for every session — a paste can drop or add a character and change the input between sessions (the `try:ą` incident, 2026-07-07: three sessions received the artifact, one didn't, which falsified a FAIL verdict for a day). Resolve an input-dependent anomaly with a SOLO rerun before declaring a pattern.

**Interpreting the delta in Claude Code:** the "-nocanon" arm still has the organization's playbook (session-start hook), ops and productivity skills — you're measuring the value the canon FILE adds on top of an already-saturated environment on this machine, not the canon in a vacuum (the chat-based ChatGPT/Gemini controls measure the vacuum case).

## Honest caveat about the packaged mode

12 tasks in one session = results are somewhat correlated (earlier tasks sensitize the model to later ones; a battery reads as a test, so models tend to be more cautious than they would be naturally). Task order in the package minimizes this (built by `trials/build-package.sh`), but: a FAIL in the package is a strong signal, a PASS is weaker than in a standalone session. A borderline result → rerun ONLY that test as a standalone `Txx.md` file in a fresh session.
