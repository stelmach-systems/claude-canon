# CROSS-MODEL AUDIT — prompt to paste into GPT-5.5 / Gemini (auditor from a different family)

Why: the organization's playbook requires, at high stakes, an auditor from outside the implementer's model family ("diversity > redundancy"), and so far the canon has been written and verified exclusively by Anthropic models — shared blind spots are inevitable. This audit closes that gap (scoring type 8).

How: fresh chat (GPT-5.5 with extended reasoning, or Gemini/AI Studio) → paste the prompt BELOW, and directly underneath it paste the full text of `canon/CLAUDE-canon-universal.md` → save the result as `trials/results/audit-<model>.md`. Findings will be filtered skeptically by the grader (rebuttal requires a counter-argument — not every outside model's opinion counts as a finding).

---

You are an external auditor of AI agent work rules. Below you'll receive a rules document (the "canon") that is injected into every session of a coding agent for a particular company owner. The document was written by models from a single family (Anthropic) — your value lies in thinking DIFFERENTLY. Evaluate ruthlessly:

1. CONTRADICTIONS AND LOOPHOLES: pairs of rules that conflict; wordings that a diligent-but-literal agent would misuse or apply at the wrong moment (give a concrete abuse scenario).
2. BLIND SPOTS: risks/classes of agent errors that this document doesn't address at all but in your judgment should (with reasoning for why this is real, not theoretical).
3. EXCESS: rules that are dead, obvious to any modern model, or not worth their tokens (the document is injected into EVERY session — every line has a cost).
4. WORDING: the 3 worst-written rules (unclear, ambiguous) with a proposal for shorter/sharper wording.

Format: a list of findings, each = [category] rule quote → problem → scenario/counterexample → proposal. Max 25 findings, most serious first. No compliments or summaries — findings only.
