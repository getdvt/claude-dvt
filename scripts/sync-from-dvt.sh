#!/usr/bin/env bash
#
# Sync the vendored canonical dvt assets into the claude-dvt plugin.
#
# Canonical source of truth: getdvt/dvt → web/public/dvt-spec-authoring-skill.md
# Vendored mirror (this repo):  plugins/dvt/skills/dvt-spec-author/SKILL.md
#
# The plugin ships a byte-for-byte copy of the canonical spec-authoring skill so it
# installs offline with no network call or token into the private dvt repo. Do NOT
# hand-edit the vendored copy — edit it in the dvt repo, then run this script. CI
# (.github/workflows/skill-drift.yml) fails the build if the two copies drift apart.
#
# Usage (from the claude-dvt repo root, with the dvt repo checked out as a sibling):
#   ./scripts/sync-from-dvt.sh
#   DVT_REPO=/path/to/dvt ./scripts/sync-from-dvt.sh   # explicit source location
#   DVT_REF=my-feature-branch ./scripts/sync-from-dvt.sh   # sync from a non-default ref
#
# By default this reads the canonical file from the dvt repo's `origin/main` (via
# `git show`) after a fetch — NOT your possibly-stale working tree. The DVT-199 vendor
# bug was copying from a local checkout six commits behind origin/main; sourcing from
# the fetched ref prevents that recurring.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DVT_REPO="${DVT_REPO:-$REPO_ROOT/../dvt}"
DVT_REF="${DVT_REF:-origin/main}"
SRC_PATH="web/public/dvt-spec-authoring-skill.md"
DST="$REPO_ROOT/plugins/dvt/skills/dvt-spec-author/SKILL.md"

if [[ ! -d "$DVT_REPO/.git" ]]; then
  echo "error: dvt repo not found at:" >&2
  echo "         $DVT_REPO" >&2
  echo "       Check out getdvt/dvt as a sibling of this repo, or set DVT_REPO=/path/to/dvt." >&2
  exit 1
fi

# Refresh remote refs so origin/main is current (the staleness guard). Non-fatal: an
# offline run can still sync from whatever ref is already fetched.
if [[ "$DVT_REF" == origin/* ]]; then
  git -C "$DVT_REPO" fetch origin -q || echo "warning: git fetch failed; using last-fetched $DVT_REF" >&2
fi

if ! git -C "$DVT_REPO" cat-file -e "$DVT_REF:$SRC_PATH" 2>/dev/null; then
  echo "error: canonical file not found at $DVT_REF:$SRC_PATH in $DVT_REPO" >&2
  exit 1
fi

git -C "$DVT_REPO" show "$DVT_REF:$SRC_PATH" > "$DST"
echo "synced: $DVT_REPO @ $DVT_REF : $SRC_PATH"
echo "    ->: $DST"
