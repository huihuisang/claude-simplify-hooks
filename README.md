# claude-simplify-hooks

Auto-run `/simplify` after each Claude Code turn that modifies code files.

- **Skips pure Q&A turns** — only triggers when Claude actually wrote or edited files
- **Safe for concurrent agents** — each agent tracks only the files it touched, so multiple agents on the same branch never interfere with each other
- **Self-limiting** — re-runs until simplify produces no new changes, or a maximum of 3 rounds

## How it works

```
UserPromptSubmit    → clear this session's touched-file list
Edit / Write tools  → append each modified file path to touched_<session_id>
Stop                → diff only the touched files; trigger /simplify if code changed
```

State is stored per `session_id` under `/tmp/`, so concurrent agents stay isolated.

## Install

**Requires:** `jq` (`brew install jq`)

```bash
curl -fsSL https://raw.githubusercontent.com/huihuisang/claude-simplify-hooks/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/huihuisang/claude-simplify-hooks.git
bash claude-simplify-hooks/install.sh
```

Restart Claude Code after installing.

## Uninstall

Remove the hook scripts:

```bash
rm ~/.claude/hooks/record-baseline.sh \
   ~/.claude/hooks/record-touched.sh \
   ~/.claude/hooks/simplify-on-stop.sh
```

Then remove the `hooks` key from `~/.claude/settings.json`.

## Files

| File | Hook event | Purpose |
|------|-----------|---------|
| `record-baseline.sh` | `UserPromptSubmit` | Clears the touched-file list at the start of each turn |
| `record-touched.sh` | `PostToolUse` (Edit/Write) | Records each file path Claude modifies |
| `simplify-on-stop.sh` | `Stop` | Diffs touched files; triggers `/simplify` if code changed |
| `install.sh` | — | One-click installer |
