#!/bin/bash
# Record which files this agent touched via Edit/Write tools.
# Called via PostToolUse hook — one entry per file, per tool call.
# Stored per session so multiple agents on the same branch don't interfere.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -n "$FILE_PATH" ]; then
  echo "$FILE_PATH" >> "/tmp/claude_touched_${SESSION_ID}"
fi

exit 0
