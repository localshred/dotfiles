---
name: keep-claude-session
description: |
    Use when the user wants to save, keep, or persist the CURRENT Claude Code
    session to their resumable session list — e.g. "keep this session", "save
    this session", "promote this scratch session", "I want to keep this one",
    "add this to my sessions". Records it via `mx claude keep`.
metadata:
    author: bneilsen
    version: 0.0.1
name: keep-claude-session
---

# Keep Claude Session

Persist the current session into `~/.claude-sessions.txt` so `mx claude` can
resume it later. Use when a scratch (unnamed, throwaway) session turns out to
be worth keeping.

## Steps

1. Get a session name. If the user didn't supply one, ask for a short,
   hyphenated, descriptive name (e.g. `oauth-refactor`). This name is the
   unique key in the list.
2. From the session's working directory, run:

   ```
   mx claude keep "<name>"
   ```

   `mx claude keep` auto-detects the current session id (the newest transcript
   in this directory's project) and records the cwd, so you normally pass only
   the name.
3. Confirm what was saved. Reusing an existing name overwrites that entry.

## Fallback: id detection failed

If `mx claude keep` reports it can't determine the session id (rare — usually
because the working directory changed), find the id yourself and pass it
explicitly:

1. Encode the current directory: replace every non-alphanumeric character with
   `-` (e.g. `/Users/you/code/app` → `-Users-you-code-app`).
2. The newest `*.jsonl` under `~/.claude/projects/<encoded-dir>/` is this
   session's transcript; its basename (without `.jsonl`) is the session id.
3. Run: `mx claude keep "<name>" <session-id>`

## Notes

- Detection assumes you run it inside the session you want to keep.
- `mx claude` lists saved sessions; `mx claude prune` cleans up dead ones.
