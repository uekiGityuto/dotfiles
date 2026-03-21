#!/bin/bash
# Bashコマンドに&&が含まれていたらブロックする
# &&でコマンドをチェインすると、PermissionsでAllowにしていても、askされてしまって鬱陶しいので、それを回避する。
# Claudeは理由を見て自動的に個別コマンドに分割して再実行する
# NOTE: ;も同様にaskされるが、ここではブロックしない（誤検知リスクが高いため）
# NOTE: sandbox有効(autoAllowBashIfSandboxed: true)なら&&も;も許可を求められないので、このフック自体が不要になる
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q '&&'; then
  echo "&&でコマンドをチェインしないでください。コマンドを個別に実行してください。" >&2
  exit 2
fi

exit 0
