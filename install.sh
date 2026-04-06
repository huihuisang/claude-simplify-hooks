#!/bin/bash
# install.sh — One-click installer for the Claude Code auto-simplify hooks.
#
# What it does:
#   1. Copies the three hook scripts into ~/.claude/hooks/
#   2. Merges the hook configuration into ~/.claude/settings.json
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh | bash
#   — or —
#   bash install.sh

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code auto-simplify hooks..."

# ── 1. Copy hook scripts ─────────────────────────────────────────────────────

mkdir -p "$HOOKS_DIR"
mkdir -p "$HOME/.claude/commands"

for script in record-baseline.sh record-touched.sh simplify-on-stop.sh; do
  cp "$SCRIPT_DIR/$script" "$HOOKS_DIR/$script"
  chmod +x "$HOOKS_DIR/$script"
  echo "  ✓ Installed $script"
done

cp "$SCRIPT_DIR/simplify-files.md" "$HOME/.claude/commands/simplify-files.md"
echo "  ✓ Installed simplify-files.md"

# ── 2. Merge hooks into settings.json ────────────────────────────────────────

HOOK_CONFIG=$(cat <<'EOF'
{
  "UserPromptSubmit": [
    {
      "hooks": [
        { "type": "command", "command": "~/.claude/hooks/record-baseline.sh" }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Edit|Write|NotebookEdit",
      "hooks": [
        { "type": "command", "command": "~/.claude/hooks/record-touched.sh" }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        { "type": "command", "command": "~/.claude/hooks/simplify-on-stop.sh" }
      ]
    }
  ]
}
EOF
)

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Merge hook config into existing settings (preserves all other keys)
MERGED=$(jq --argjson hooks "$HOOK_CONFIG" '.hooks = $hooks' "$SETTINGS_FILE")
echo "$MERGED" > "$SETTINGS_FILE"
echo "  ✓ Updated $SETTINGS_FILE"

echo ""
echo "Done! Auto-simplify hooks are now active for all Claude Code projects."
echo "Restart Claude Code if it is currently running."
