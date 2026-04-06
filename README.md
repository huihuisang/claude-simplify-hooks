# claude-simplify-hooks

Auto-run `/simplify-files` after each Claude Code turn that modifies code files.

- **Skips pure Q&A turns** — only triggers when Claude actually wrote or edited files
- **Safe for concurrent agents** — each agent tracks only the files it touched, so multiple agents on the same branch never interfere with each other
- **Precise scope** — passes the exact list of changed files to `/simplify-files`, so Claude reviews only what was touched this turn

## How it works

```
UserPromptSubmit    → clear this session's touched-file list
Edit / Write tools  → append each modified file path to touched_<session_id>
Stop                → diff only the touched files
                       → code changed? trigger /simplify-files <file1> <file2> ...
                       → /simplify-files turn ends? skip (flag file prevents recursion)
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

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/huihuisang/claude-simplify-hooks/main/uninstall.sh)
```

Or if you cloned the repo:

```bash
bash claude-simplify-hooks/uninstall.sh
```

## Files

| File | Hook event | Purpose |
|------|-----------|---------|
| `record-baseline.sh` | `UserPromptSubmit` | Clears the touched-file list at the start of each turn |
| `record-touched.sh` | `PostToolUse` (Edit/Write) | Records each file path Claude modifies |
| `simplify-on-stop.sh` | `Stop` | Diffs touched files; triggers `/simplify-files` with exact file list |
| `simplify-files.md` | — | The `/simplify-files` slash command definition |
| `install.sh` | — | One-click installer |
| `uninstall.sh` | — | One-click uninstaller |
