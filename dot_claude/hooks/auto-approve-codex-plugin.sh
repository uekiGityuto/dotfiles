#!/bin/bash
# codexプラグインのnode scripts実行（unsandboxed）を自動承認する
# codexプラグインはsandbox外でnode実行するため、許可プロンプトが出る問題の回避策
# settings.jsonのifフィールドでコマンドパターンを制限済み
echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
