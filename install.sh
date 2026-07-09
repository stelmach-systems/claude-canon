#!/usr/bin/env bash
# install.sh — installs/updates the UNIVERSAL PART of the canon in ~/.claude/CLAUDE.md.
# Idempotent. Does NOT touch the LOCAL part (after the marker), skills, or memory.
# Usage:  ./install.sh          — install/update + commit in the ~/.claude repo
#         ./install.sh --check  — drift report only (exit 1 on drift), writes nothing
# Test without touching the real HOME:  CLAUDE_DIR=/tmp/x/.claude ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_DIR/canon/CLAUDE-canon-universal.md"
TPL="$REPO_DIR/canon/CLAUDE-local-template.md"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
TARGET="$CLAUDE_DIR/CLAUDE.md"

START='<!-- ===== CANON-UNIVERSAL :: start (copy/update from the claude-canon repo) ===== -->'
END='<!-- ===== CANON-UNIVERSAL :: end ===== -->'
LOCAL_MARK='<!-- ===== LOCAL (this device/organization — install.sh does NOT overwrite it) ===== -->'

[ -f "$SRC" ] || { echo "ERROR: missing $SRC" >&2; exit 2; }
VERSION="$(grep -oE 'canon version: v[0-9.]+' "$SRC" | head -1 || echo 'canon version: ?')"

expected_a() { printf '%s\n%s\n%s\n' "$START" "$(cat "$SRC")" "$END"; }
current_a()  { awk -v s="$START" -v e="$END" '$0==s{f=1} f{print} $0==e{exit}' "$TARGET"; }

if [ "${1:-}" = "--check" ]; then
  [ -f "$TARGET" ] || { echo "DRIFT: missing $TARGET (run ./install.sh)"; exit 1; }
  grep -qxF "$END" "$TARGET" || { echo "DRIFT: $TARGET has no valid canon end marker (run ./install.sh)"; exit 1; }
  if [ "$(current_a)" = "$(expected_a)" ]; then echo "OK: universal part matches the repo ($VERSION)"; exit 0
  else echo "DRIFT: universal part ≠ repo ($VERSION) — run ./install.sh"; exit 1; fi
fi

mkdir -p "$CLAUDE_DIR"

# Local part: keep the existing one; a file without markers OR an empty extraction = backup + template (loudly).
backup_target() {
  BAK="$TARGET.pre-canon-$(date +%Y%m%d-%H%M%S)"
  cp "$TARGET" "$BAK"
  echo "NOTICE: $1"
  echo "        Backup: $BAK — manually move your local rules from it into the LOCAL section."
}
LOCAL_PART=""
if [ -f "$TARGET" ] && grep -qxF "$END" "$TARGET"; then
  LOCAL_PART="$(awk -v e="$END" 'f{print} $0==e{f=1}' "$TARGET")"
  if [ -z "${LOCAL_PART//[[:space:]]/}" ]; then
    backup_target "the canon markers are present, but the LOCAL part came out empty (malformed file?)."
  fi
elif [ -f "$TARGET" ]; then
  backup_target "the existing $TARGET has no valid canon markers."
fi
if [ -z "${LOCAL_PART//[[:space:]]/}" ]; then
  LOCAL_PART="$(printf '\n%s\n\n%s\n' "$LOCAL_MARK" "$(cat "$TPL")")"
fi

TMP="$(mktemp)"
{ expected_a; printf '%s\n' "$LOCAL_PART"; } > "$TMP"
if [ -f "$TARGET" ] && cmp -s "$TMP" "$TARGET"; then
  echo "OK: no changes ($VERSION)"; rm -f "$TMP"; exit 0
fi
mv "$TMP" "$TARGET"
chmod 644 "$TARGET"
echo "SAVED: $TARGET ($VERSION)"

# Versioning ~/.claude (allowlist: only CLAUDE.md) — as the canon says: a mechanism, not a promise.
# Fail-soft commits: a missing git user.name/email must NOT kill the script after a successful file write.
GIT_WARN='NOTICE: commit failed (configure git user.name/user.email and rerun) — the canon file was SAVED correctly.'
if [ ! -d "$CLAUDE_DIR/.git" ]; then
  git -C "$CLAUDE_DIR" init -q
  printf '# Allowlist: we track ONLY CLAUDE.md\n*\n!CLAUDE.md\n!.gitignore\n' > "$CLAUDE_DIR/.gitignore"
  git -C "$CLAUDE_DIR" add .gitignore CLAUDE.md
  git -C "$CLAUDE_DIR" commit -qm "chore: init canon versioning (install.sh)" || echo "$GIT_WARN"
  echo "INITIALIZED: git repo in $CLAUDE_DIR (tracks only CLAUDE.md)"
fi
if ! git -C "$CLAUDE_DIR" diff --quiet -- CLAUDE.md 2>/dev/null || ! git -C "$CLAUDE_DIR" ls-files --error-unmatch CLAUDE.md >/dev/null 2>&1 || ! git -C "$CLAUDE_DIR" diff --cached --quiet -- CLAUDE.md 2>/dev/null; then
  git -C "$CLAUDE_DIR" add CLAUDE.md
  git -C "$CLAUDE_DIR" commit -qm "canon: install/update from the claude-canon repo ($VERSION)" || echo "$GIT_WARN"
  echo "COMMIT: $(git -C "$CLAUDE_DIR" log --oneline -1 2>/dev/null || echo 'none — see NOTICE')"
fi
