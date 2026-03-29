#!/bin/bash
# PreToolUse hook: blocks writes to sensitive files
# Matches: Write|Edit
# Exit 0 = allow, Exit 2 = block with reason

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

# Block .env files (except .env.example)
if [[ "$FILE_PATH" == *".env"* && "$FILE_PATH" != *".env.example"* ]]; then
  echo "Blocked: Cannot modify .env files. Read for context only."
  exit 2
fi

# Block credentials files
if [[ "$FILE_PATH" == *"credentials"* ]]; then
  echo "Blocked: Cannot modify credentials files."
  exit 2
fi

# Block secret/key files
if [[ "$FILE_PATH" == *".pem" || "$FILE_PATH" == *".key" || "$FILE_PATH" == *"secret"* ]]; then
  echo "Blocked: Cannot modify secret/key files."
  exit 2
fi

# Allow everything else
exit 0
