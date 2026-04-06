#!/bin/bash
# Auto-run /simplify-files with the exact files changed this turn.
# Diffs only the files this session touched — safe for concurrent agents on
# the same branch. Uses a flag file to detect the /simplify-files turn itself,
# preventing infinite recursion.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
TOUCHED_FILE="/tmp/claude_touched_${SESSION_ID}"
FLAG_FILE="/tmp/claude_simplify_flag_${SESSION_ID}"

# If we set the flag last turn, this is the /simplify-files turn — skip and clear
if [ -f "$FLAG_FILE" ]; then
  rm -f "$FLAG_FILE"
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

# Build space-separated list of unique touched code files
FILE_LIST=$(sort -u "$TOUCHED_FILE" | tr '\n' ' ' | sed 's/ $//')

# Set flag so the next Stop (end of /simplify-files turn) is skipped
touch "$FLAG_FILE"
printf '{"decision":"block","reason":"/simplify-files %s"}' "$FILE_LIST"
exit 0
