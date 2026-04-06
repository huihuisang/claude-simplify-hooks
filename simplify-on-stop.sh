#!/bin/bash
# Auto-run /simplify when this agent actually changed code files this turn.
# Diffs only the files this session touched — safe for concurrent agents on
# the same branch. Re-triggers until simplify produces no new changes or
# MAX_ROUNDS is reached.

MAX_ROUNDS=3

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
STATE_FILE="/tmp/claude_simplify_${SESSION_ID}"
TOUCHED_FILE="/tmp/claude_touched_${SESSION_ID}"

# Read state: "<round>|<prev_diff_hash>"
STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "0|")
ROUND=$(echo "$STATE" | cut -d'|' -f1)
PREV_HASH=$(echo "$STATE" | cut -d'|' -f2)

# On first pass: if no files were touched this turn, nothing to simplify
if [ "$ROUND" -eq 0 ] && [ ! -s "$TOUCHED_FILE" ]; then
  exit 0
fi

# Collect diff lines for code files only — check emptiness BEFORE hashing
# to avoid treating md5("") as a valid "no changes" sentinel
CODE_DIFF=$(while IFS= read -r f; do
  git diff HEAD -- "$f" 2>/dev/null
done < <(sort -u "$TOUCHED_FILE" 2>/dev/null) \
  | grep -E '^\+\+\+ b/.*\.(swift|ts|js|tsx|py|go|kt|java|rs|rb|cpp|c|h)')

# No code file changes this turn — nothing to simplify
if [ -z "$CODE_DIFF" ]; then
  rm -f "$STATE_FILE"
  exit 0
fi

CURRENT_HASH=$(echo "$CODE_DIFF" | md5 | awk '{print $1}')

# Stop conditions: same diff as last simplify round, or max rounds reached
if [ "$CURRENT_HASH" = "$PREV_HASH" ] || [ "$ROUND" -ge "$MAX_ROUNDS" ]; then
  rm -f "$STATE_FILE"
  exit 0
fi

# New changes detected — save state and trigger another simplify pass
echo "$((ROUND + 1))|${CURRENT_HASH}" > "$STATE_FILE"
printf '{"decision":"block","reason":"/simplify"}'

exit 0
