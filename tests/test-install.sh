#!/usr/bin/env bash
# test-install.sh — install.sh scenarios on a temporary CLAUDE_DIR (never touches the real ~/.claude).
# Run locally and by CI. Exit 0 = all passed.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@test GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@test

PASS=0
ok()   { PASS=$((PASS+1)); echo "ok $PASS - $1"; }
fail() { echo "FAIL - $1" >&2; exit 1; }

CD="$WORK/a/.claude"

# 1. Fresh install: file with markers and the LOCAL template
CLAUDE_DIR="$CD" "$REPO_DIR/install.sh" >/dev/null
grep -q 'CANON-UNIVERSAL :: start' "$CD/CLAUDE.md" || fail "missing start marker"
grep -q 'CANON-UNIVERSAL :: end' "$CD/CLAUDE.md" || fail "missing end marker"
grep -q 'LOCAL (this device' "$CD/CLAUDE.md" || fail "missing LOCAL section"
grep -q 'TODO' "$CD/CLAUDE.md" || fail "fresh install without the TODO template"
ok "fresh install"

# 2. Idempotency: a second run = no changes
OUT="$(CLAUDE_DIR="$CD" "$REPO_DIR/install.sh")"
echo "$OUT" | grep -q 'OK: no changes' || fail "second run is not a no-op: $OUT"
ok "idempotency"

# 3. --check after install = match (exit 0) + parsable version (footer must carry 'canon version: v…')
CHK="$(CLAUDE_DIR="$CD" "$REPO_DIR/install.sh" --check)" || fail "--check ≠ 0 after install"
echo "$CHK" | grep -q 'canon version: v' || fail "unparsable version (footer without 'canon version: vX'): $CHK"
ok "--check matches + version parsable"

# 4. A LOCAL section with custom content survives reinstall
printf -- '- MY-LOCAL-RULE-42\n' >> "$CD/CLAUDE.md"
CLAUDE_DIR="$CD" "$REPO_DIR/install.sh" >/dev/null
grep -q 'MY-LOCAL-RULE-42' "$CD/CLAUDE.md" || fail "reinstall ate the LOCAL section"
grep -q 'CANON-UNIVERSAL :: start' "$CD/CLAUDE.md" || fail "reinstall damaged the universal part"
ok "LOCAL survives reinstall"

# 5. Universal-part drift: --check exit 1, install restores
sed -i.bak 's/# Communication/# CommunicationDRIFTED/' "$CD/CLAUDE.md" && rm -f "$CD/CLAUDE.md.bak"
if CLAUDE_DIR="$CD" "$REPO_DIR/install.sh" --check >/dev/null 2>&1; then fail "--check did not detect drift"; fi
CLAUDE_DIR="$CD" "$REPO_DIR/install.sh" >/dev/null
grep -q 'CommunicationDRIFTED' "$CD/CLAUDE.md" && fail "install did not restore the universal part"
grep -q 'MY-LOCAL-RULE-42' "$CD/CLAUDE.md" || fail "restore ate the LOCAL part"
ok "drift detected and restored"

# 6. Malformed file (no markers) → backup + LOCAL template
CD2="$WORK/b/.claude"; mkdir -p "$CD2"
printf 'old rules without markers\n' > "$CD2/CLAUDE.md"
CLAUDE_DIR="$CD2" "$REPO_DIR/install.sh" >/dev/null
ls "$CD2"/CLAUDE.md.pre-canon-* >/dev/null 2>&1 || fail "no backup of the malformed file"
grep -q 'old rules' "$CD2"/CLAUDE.md.pre-canon-* || fail "backup without the original content"
grep -q 'CANON-UNIVERSAL :: start' "$CD2/CLAUDE.md" || fail "malformed: no new canon"
ok "malformed file → backup"

# 7. Versioning: a git repo in CLAUDE_DIR with a CLAUDE.md commit
# (no git|grep -q pipe: pipefail + SIGPIPE gave a false FAIL)
LOG="$(git -C "$CD" log --oneline -- CLAUDE.md)"
echo "$LOG" | grep -q canon || fail "no canon commit in the CLAUDE_DIR repo"
ok "git versioning"

echo "PASS: $PASS/7"
