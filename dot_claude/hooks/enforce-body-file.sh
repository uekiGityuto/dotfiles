#!/bin/bash
# gh pr create で --body を使っている場合、--body-file を使うよう強制する
# HEREDOCの # 行によるask回避のため
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'gh pr create' && echo "$COMMAND" | grep -q '\-\-body ' && ! echo "$COMMAND" | grep -q '\-\-body-file'; then
  echo "--body ではなく --body-file を使ってください。まずbodyの内容を /tmp/claude/pr-body.md に書き出してから gh pr create --body-file ~/.claude/tmp/pr-body.md を使ってください。" >&2
  exit 2
fi

exit 0
