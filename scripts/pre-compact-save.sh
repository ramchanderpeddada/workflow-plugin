#!/bin/bash
# PreCompact hook: auto-saves session context before compaction
# Saves what was being worked on so the post-compact session doesn't re-read everything

SESSION_DIR=~/.claude/sessions
mkdir -p "$SESSION_DIR"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H%M)
FILE="$SESSION_DIR/${DATE}-${TIME}-auto-compact.md"

cat > "$FILE" << 'HEADER'
# Auto-saved before compact
HEADER

echo "" >> "$FILE"
echo "## Working Directory" >> "$FILE"
pwd >> "$FILE"

echo "" >> "$FILE"
echo "## Modified Files" >> "$FILE"
git diff --name-only HEAD 2>/dev/null >> "$FILE" || echo "(not a git repo)" >> "$FILE"
git status --porcelain 2>/dev/null >> "$FILE"

echo "" >> "$FILE"
echo "## Recent Commits" >> "$FILE"
git log --oneline -5 2>/dev/null >> "$FILE" || echo "(no git)" >> "$FILE"

exit 0
