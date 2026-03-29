---
disable-model-invocation: true
---

# Save Session

Save current session state for resuming later.

1. Read current git status and recent commits
2. Write a session summary to ~/.claude/sessions/[date]-manual.md including:
   - What was being worked on
   - Files modified
   - Decisions made
   - Next steps
3. Confirm save is complete
