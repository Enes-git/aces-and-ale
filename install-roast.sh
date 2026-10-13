#!/usr/bin/env bash
#
# install-roast.sh — opt-in installer for the commit-roast joke hook.
# Run this yourself, on purpose, to enable the gag:
#   ./install-roast.sh
#
# It copies commit-roast.sh into .git/hooks/post-commit for THIS repo only.
# Nothing is installed globally. Nothing runs until you run this.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SRC="$SCRIPT_DIR/commit-roast.sh"
HOOK_DST="$SCRIPT_DIR/.git/hooks/post-commit"

if [ ! -d "$SCRIPT_DIR/.git" ]; then
  echo "No .git directory here. Run this from the root of the repo." >&2
  exit 1
fi

cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"

echo "🫖  commit-roast installed for this repo."
echo "    Make a commit to see it. Uninstall any time with:"
echo "    rm .git/hooks/post-commit"
