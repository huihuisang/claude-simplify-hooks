#!/bin/bash
# Reset per-session state at the start of each user turn.
# Saves the prompt text so the Stop hook can detect /simplify turns and skip.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')

rm -f "/tmp/claude_touched_${SESSION_ID}"

# Save prompt text for the Stop hook to inspect
echo "$INPUT" | jq -r '.prompt // ""' > "/tmp/claude_prompt_${SESSION_ID}"

exit 0
