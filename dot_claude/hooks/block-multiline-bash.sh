#!/bin/bash
# 複数行のBashコマンド（heredoc等）をブロックし、ファイル経由に誘導する
# heredocや複数行コマンドは$()コマンド置換として検出され、permission allowパターンにマッチしなくなるため
# NOTE: バックスラッシュ継続(\+改行)も複数行としてブロックされるが、Claude Codeがこれを使うケースは稀
# NOTE: パイプ付きコマンド(echo foo | grep bar)は1行なのでブロックされない
# NOTE: gh pr create や codex exec はこの対応をしないと許可プロンプトが出るが、git commitはでない。許可プロンプトが出るコマンドと出ないコマンドの理由は不明。
COMMAND=$(jq -r '.tool_input.command')

# git commitはheredocでも許可プロンプトが出ないため除外
if echo "$COMMAND" | grep -q 'git.*commit'; then
  exit 0
fi

# 複数行チェック（heredocや長いインライン文字列を検出）
LINE_COUNT=$(echo "$COMMAND" | wc -l | tr -d ' ')
if [ "$LINE_COUNT" -gt 1 ]; then
  echo "複数行のBashコマンドは禁止です。長い文字列はWrite toolで /tmp/claude/bash-body.txt に書き出してください。例: gh pr create --body-file /tmp/claude/bash-body.txt" >&2
  exit 2
fi

exit 0
