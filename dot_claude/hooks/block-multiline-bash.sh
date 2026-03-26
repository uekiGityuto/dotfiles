#!/bin/bash
# 複数行のBashコマンド（heredoc等）をブロックし、ファイル経由に誘導する
# heredocや複数行コマンドは$()コマンド置換として検出され、permission allowパターンにマッチしなくなるため
# NOTE: バックスラッシュ継続(\+改行)も複数行としてブロックされるが、Claude Codeがこれを使うケースは稀
# NOTE: パイプ付きコマンド(echo foo | grep bar)は1行なのでブロックされない
COMMAND=$(jq -r '.tool_input.command')

# 複数行チェック（heredocや長いインライン文字列を検出）
LINE_COUNT=$(echo "$COMMAND" | wc -l | tr -d ' ')
if [ "$LINE_COUNT" -gt 1 ]; then
  echo "複数行のBashコマンドは使わないでください。長い文字列（PRのbody、プロンプト等）はWrite toolで /tmp/claude/bash-body.txt に書き出してから、ファイルを参照するコマンド（--body-file、< file、-f file 等）を使ってください。" >&2
  exit 2
fi

exit 0
