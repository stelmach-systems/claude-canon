#!/usr/bin/env bash
# stakes-check.sh — Stop hook (Claude Code): reminds you of a missing stakes declaration
# when the turn changed files (Edit/Write/NotebookEdit) but the assistant text had no `stakes:`.
# NOT wired in by default — enable it once you've measured declaration coverage and want the nudge
# (wire: settings.json → hooks.Stop, command: bash <path>/stakes-check.sh).
# Non-blocking: emits only a systemMessage; on ANY error it stays silent (exit 0).
# Transcript format verified against a live jsonl (types assistant/user, message.content[]).
# ponytail: catches only Edit/Write/NotebookEdit — writes via Bash are out of scope (a deliberate ceiling).
INPUT="$(cat 2>/dev/null || true)"
python3 - "$INPUT" <<'PYEOF' 2>/dev/null || true
import sys, json, os, re
try:
    hook = json.loads(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].strip() else {}
    tp = hook.get("transcript_path") or ""
    if not tp:
        sid = hook.get("session_id") or ""
        cwd = hook.get("cwd") or os.getcwd()
        if sid:
            tp = os.path.expanduser(f"~/.claude/projects/{cwd.replace('/', '-')}/{sid}.jsonl")
    if not tp or not os.path.isfile(tp):
        sys.exit(0)
    entries = []
    with open(tp, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if line:
                try: entries.append(json.loads(line))
                except Exception: pass
    # last real user message = a 'user' entry with a content item of type 'text'
    last_user = -1
    for i, d in enumerate(entries):
        if d.get("type") == "user":
            for c in ((d.get("message") or {}).get("content") or []):
                if isinstance(c, dict) and c.get("type") == "text":
                    last_user = i
                    break
    if last_user < 0:
        sys.exit(0)
    changed, texts = False, []
    for d in entries[last_user:]:
        if d.get("type") != "assistant":
            continue
        for c in ((d.get("message") or {}).get("content") or []):
            if not isinstance(c, dict):
                continue
            if c.get("type") == "tool_use" and c.get("name") in ("Edit", "Write", "NotebookEdit"):
                changed = True
            if c.get("type") == "text":
                texts.append(c.get("text") or "")
    if changed and not re.search(r"stakes:\s*(trivial|significant|high)", " ".join(texts), re.I):
        print(json.dumps({"systemMessage":
            "⚠️ canon: the turn changed files without a stakes declaration (`stakes: trivial/significant/high → rung`)."},
            ensure_ascii=False))
except Exception:
    pass
PYEOF
exit 0
