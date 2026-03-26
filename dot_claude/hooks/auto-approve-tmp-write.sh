#!/bin/bash
# /tmp/claude/ 配下へのWrite/Editを自動承認する
# macOSの /tmp → /private/tmp シンボリックリンクにより、Write toolが許可プロンプトを出す問題の回避策
# ref: https://github.com/anthropics/claude-code/issues/36044
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if echo "$FILE_PATH" | grep -qE '^(/tmp/claude/|/private/tmp/claude/)'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
fi
