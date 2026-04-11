#!/bin/bash
# codexコマンドのsandbox外実行を自動承認する
# codexはmacOS sandbox内ではSystemConfiguration制限によりパニックするため
# ref: https://github.com/anthropics/claude-code/issues/26879
# SKILL.mdのifフィールドでコマンドパターンを制限済み
echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
