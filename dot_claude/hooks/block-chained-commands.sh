#!/bin/bash
# Bashコマンドに&&が含まれていたらブロックする
# &&でコマンドをチェインすると、PermissionsでAllowにしていても、askされてしまって鬱陶しいので、それを回避する。
# Claudeは理由を見て自動的に個別コマンドに分割して再実行する
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q '&&'; then
  echo "&&でコマンドをチェインしないでください。コマンドを個別に実行してください。" >&2
  exit 2
fi

exit 0
