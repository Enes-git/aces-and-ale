#!/usr/bin/env bash
#
# commit-roast — a harmless, opt-in git hook that prints a random line
# after every commit. It only echoes text. It does not touch your commit,
# your files, your credentials, or the network. Remove it any time with:
#   rm .git/hooks/post-commit
#
# This is a joke. It says so right here. 🫖

LINES=(
  # --- gentle roasts ---
  "Committed. Future-you is already annoyed."
  "Bold of you to call that 'final'."
  "Great commit. Did you run the tests? ...Did you?"
  "That's one commit closer to the bug you'll introduce tomorrow."
  "Ah yes, 'fix stuff'. Very descriptive. Historians will thank you."
  "Shipped it. May the CI have mercy on your soul."
  "Another commit, another TODO you'll never do."
  "Clean code is a myth, but I admire your optimism."
  # --- actually motivational ---
  "Small commits, steady progress. Nice work."
  "You showed up and wrote code today. That counts."
  "Done is better than perfect. This is done."
  "One commit at a time — that's how everything gets built."
  "Refactor later. Celebrate now."
)

idx=$((RANDOM % ${#LINES[@]}))
echo ""
echo "  🫖  ${LINES[$idx]}"
echo ""
