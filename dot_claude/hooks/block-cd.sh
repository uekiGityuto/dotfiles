#!/bin/bash
# Bashツールで直接cdを使うことを禁止する
# make等で間接的に呼ばれるcdは対象外（Bashコマンド文字列の判定のみ）
COMMAND=$(jq -r '.tool_input.command')

# cdで始まるコマンド、または ; や && の後にcdがあるケースを検出
if echo "$COMMAND" | grep -qE '(^|&&|;)\s*cd\s'; then
  cat >&2 <<'MSG'
cdを直接使わないでください。代替方法:
- サブディレクトリのスクリプト実行: pnpm --filter, npm --prefix, Makefile経由
- 特定ディレクトリでコマンド実行: git -C <dir>, ツールのpath/cwd引数
- ファイル操作: Read, Edit, Write, Glob, Grep等の専用ツール
MSG
  exit 2
fi

exit 0
