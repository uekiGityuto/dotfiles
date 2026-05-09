#!/bin/bash
# Bash コマンドに機密ファイルパスが含まれている場合に block する hook
# PreToolUse に登録すること（PermissionRequest だと allow list / auto-mode で auto-approve されたコマンドに発火しない）
# Read ツール側の deny だけでは Bash 経由のアクセス（cat/grep/head/tail/find/less/more 等）を防げないための補完
#
# パフォーマンス: パターンを 1 つの巨大正規表現にまとめて grep を 1 回だけ実行する
#
# === 重要：これは「うっかり防止」のための補助レイヤーであり、完全な防御ではない ===
#
# 文字列パターンマッチで shell semantics を完全には掴めないため、以下の bypass 経路が存在する:
#   - シンボリックリンク経由: `cat /tmp/link` （link が ~/.ssh/id_rsa を指していても検出不可）
#   - 高度な shell expansion: パラメータ置換 `${VAR}`, 算術展開 `$((...))` 等
#   - alias / function 経由
#   - 動的にパスを構築: `cat ~/.s${A}sh/id_rsa`（A=空文字 等）
#   - パターン漏れ: 新しいクラウドサービスや独自の認証情報配置
#
# 真の機密保護が必要な場合は以下を併用:
#   - OS-level の access control（macOS の TCC、Linux の AppArmor 等）
#   - 機密ファイルを別ディレクトリに置き、agent の作業ディレクトリと完全分離
#   - 環境変数経由でシークレットを渡し、ファイル直接読みを避ける
#
# このフックの目的: 「Claude が単純な思い違いで機密ファイルを読む事故」の防止

COMMAND=$(jq -r '.tool_input.command // empty')

# 機密パスパターンを alternation でまとめる
# 末尾サフィックス（\s, $, ", ', /）が必要なものは個別にグループ化
SENSITIVE_REGEX='(id_rsa|id_ed25519|id_ecdsa|id_dsa)|(\.ssh/)|(\.pem|\.p12|\.pfx|\.key|\.env|\.netrc|\.npmrc|\.pypirc)([[:space:]]|$|"|'\''|\.)|(\.env\.)|(\.aws/|\.azure/|\.kube/|\.docker/|\.config/gcloud/|application_default_credentials\.json)|(\.gnupg)([[:space:]]|$|"|/|'\'')|(/credentials/|/secrets/)|(Application Support/Google/Chrome|Application Support/Firefox|Library/Cookies)'

matched=$(echo "$COMMAND" | grep -oE "$SENSITIVE_REGEX" | head -1)
if [[ -n "$matched" ]]; then
  echo "機密ファイル/ディレクトリ (\"$matched\") へのアクセスは禁止されています。Read ツール側の deny と同様の保護です。" >&2
  exit 2
fi

exit 0
