#!/bin/bash
# Reset per-session touched file list at the start of each user turn.
# This ensures the Stop hook only sees files modified in the current turn.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')

rm -f "/tmp/claude_touched_${SESSION_ID}"
exit 0
