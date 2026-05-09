#!/bin/bash
# Bash コマンドに機密ファイルパスが含まれている場合に deny する hook
# Read ツール側の deny だけでは Bash 経由のアクセス（cat/grep/head/tail/find/less/more 等）を防げないための補完

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 機密パスパターン（コマンド文字列内で検出する）
SENSITIVE_PATTERNS=(
  # SSH鍵
  'id_rsa'
  'id_ed25519'
  'id_ecdsa'
  'id_dsa'
  '\.ssh/'
  # 証明書・鍵ファイル
  '\.pem(\s|$|"|'\'')'
  '\.p12(\s|$|"|'\'')'
  '\.pfx(\s|$|"|'\'')'
  '\.key(\s|$|"|'\'')'
  # 環境変数・シークレット
  '\.env(\s|$|"|'\'')'
  '\.env\.'
  # AWS / クラウド認証情報
  '\.aws/credentials'
  '\.aws/config'
  # Kubernetes
  '\.kube/config'
  # GnuPG
  '\.gnupg(\s|$|"|/|'\'')'
  # 一般的な credentials ディレクトリ
  '/credentials/'
  '/secrets/'
  # netrc, npmrc 等の認証情報
  '\.netrc(\s|$|"|'\'')'
  '\.npmrc(\s|$|"|'\'')'
  '\.pypirc(\s|$|"|'\'')'
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","reason":"機密ファイル/ディレクトリ ($pattern) へのアクセスは禁止されています。Read ツール側の deny と同様の保護です。"}}}
JSON
    exit 0
  fi
done

exit 0
