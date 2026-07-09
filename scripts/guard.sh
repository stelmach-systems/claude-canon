#!/usr/bin/env bash
# guard.sh — a fail-closed hygiene guard for the public claude-canon repo.
#
# It blocks GENERIC secret/PII/path leak shapes that have no place in a public,
# model-agnostic methodology repo. By design it contains NO owner-specific
# tokens: a denylist of private names (clients, hosts, internal tooling) would
# itself leak them into the public tree. Those owner-specific checks live in the
# private source of truth's export step (build-public.sh), which scans the whole
# export — including this file — before any push.
#
# Exit 1 (listing offenders) on any hit, 0 if clean. Runs in CI and locally:
#   bash scripts/guard.sh .
set -uo pipefail
TARGET="${1:-.}"

# Case-insensitive extended-regex patterns — generic leak shapes only.
PATTERNS=(
  '/Users/[A-Za-z0-9._-]+'            # absolute macOS home path (use ~/ or a relative path)
  '/home/[A-Za-z0-9._-]+'             # absolute Linux home path
  '[A-Za-z0-9_-]+\.local([^.a-z]|$)'  # a device fqdn (host.local) — not a .local.<ext> filename
  'sk-[A-Za-z0-9]{16,}'               # OpenAI-style secret token
  'ghp_[A-Za-z0-9]{20,}'              # GitHub personal access token
  'github_pat_[A-Za-z0-9_]{20,}'      # GitHub fine-grained PAT
  'AKIA[0-9A-Z]{16}'                  # AWS access key id
  'xox[baprs]-[A-Za-z0-9-]{10,}'      # Slack token
  '-----BEGIN [A-Z ]*PRIVATE KEY'     # PEM private key block
  'Bearer [A-Za-z0-9._~+/-]{20,}'     # bearer token
  '[A-Za-z0-9._%+-]+@(gmail|icloud|me|outlook|hotmail|live|yahoo|proton|protonmail)\.[a-z.]+'  # personal-provider email
)

hits=0
for p in "${PATTERNS[@]}"; do
  # --exclude=guard.sh: this file defines the patterns (generic shapes, no real
  # secret); the private export step scans it too, so nothing goes unwatched.
  if out=$(grep -r -I -n -i -E --exclude-dir=.git --exclude=guard.sh -e "$p" "$TARGET" 2>/dev/null); then
    echo "LEAK: /$p/"; echo "$out"; echo "---"; hits=1
  fi
done

if [ "$hits" -ne 0 ]; then
  echo "❌ guard: possible secret/PII/path leak in '$TARGET' — publish BLOCKED"; exit 1
fi
echo "✅ guard: clean ($TARGET)"
