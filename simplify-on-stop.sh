#!/bin/bash
# Auto-run /simplify when this agent actually changed code files this turn.
# Diffs only the files this session touched — safe for concurrent agents on
# the same branch. Skips if the current turn was itself a /simplify invocation,
# preventing infinite recursion without needing a hard round limit.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
TOUCHED_FILE="/tmp/claude_touched_${SESSION_ID}"
PROMPT_FILE="/tmp/claude_prompt_${SESSION_ID}"

# If this turn was triggered by /simplify, don't recurse
PROMPT=$(cat "$PROMPT_FILE" 2>/dev/null || echo "")
if echo "$PROMPT" | grep -qi "simplify"; then
  exit 0
fi

# No files touched this turn — nothing to simplify
if [ ! -s "$TOUCHED_FILE" ]; then
  exit 0
fi

# Collect diff lines for code files only — check emptiness BEFORE hashing
# to avoid treating md5("") as a valid "no changes" sentinel
CODE_DIFF=$(while IFS= read -r f; do
  git diff HEAD -- "$f" 2>/dev/null
done < <(sort -u "$TOUCHED_FILE" 2>/dev/null) \
  | grep -E '^\+\+\+ b/.*\.(swift|ts|js|tsx|py|go|kt|java|rs|rb|cpp|c|h)')

# No code file changes — nothing to simplify
if [ -z "$CODE_DIFF" ]; then
  exit 0
fi

printf '{"decision":"block","reason":"/simplify"}'
exit 0
