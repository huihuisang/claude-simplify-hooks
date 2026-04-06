#!/bin/bash
# uninstall.sh — Remove the Claude Code auto-simplify hooks.

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Uninstalling Claude Code auto-simplify hooks..."

# ── 1. Remove hook scripts ───────────────────────────────────────────────────

for script in record-baseline.sh record-touched.sh simplify-on-stop.sh; do
  if [ -f "$HOOKS_DIR/$script" ]; then
    rm "$HOOKS_DIR/$script"
    echo "  ✓ Removed $script"
  fi
done

if [ -f "$HOME/.claude/commands/simplify-files.md" ]; then
  rm "$HOME/.claude/commands/simplify-files.md"
  echo "  ✓ Removed simplify-files.md"
fi

# ── 2. Remove hooks key from settings.json ───────────────────────────────────

if [ -f "$SETTINGS_FILE" ]; then
  MERGED=$(jq 'del(.hooks)' "$SETTINGS_FILE")
  echo "$MERGED" > "$SETTINGS_FILE"
  echo "  ✓ Removed hooks from $SETTINGS_FILE"
fi

echo ""
echo "Done! Restart Claude Code if it is currently running."
