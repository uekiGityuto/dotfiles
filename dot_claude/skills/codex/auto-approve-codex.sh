#!/bin/bash
# codexコマンドのsandbox外実行を自動承認する
# codexはmacOS sandbox内ではSystemConfiguration制限によりパニックするため
# ref: https://github.com/anthropics/claude-code/issues/26879
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -q 'codex exec'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
fi
