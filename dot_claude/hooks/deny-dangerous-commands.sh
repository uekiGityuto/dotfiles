#!/bin/bash
# publish/deploy/push 系の危険なコマンドを block する hook
# tool ごとに global option（値をとるもの含む）をスキップして subcommand を判定する
# && || ; | で chain されたコマンドも各セグメントを個別にチェックする
#
# === 重要：これは「うっかり防止」のための補助レイヤーであり、完全な防御ではない ===
#
# string matching ベースで shell semantics を完全には掴めないため、以下の bypass 経路が存在する:
#   - alias 経由: `alias np='npm publish'; np`
#   - function 経由: `function p() { npm publish; }; p`
#   - source/eval: `source /tmp/evil.sh`, `eval "npm publish"`
#   - here-doc / process substitution: `bash <<< "npm publish"`, `<(npm publish)`
#   - 絶対パス: `/usr/local/bin/npm publish`
#   - 動的解決: `$(type -P npm) publish`
#   - シェル機能のあらゆる組み合わせ
#
# 真のセキュリティが必要な場合は以下の併用を検討:
#   - OS-level sandbox (macOS sandbox-exec, Linux seccomp/firejail 等)
#   - Claude Code の sandbox 機能（settings.json の sandbox.enabled）
#   - 高リスクプロジェクトでは defaultMode を変更し prompt を明示要求
#
# このフックの目的: 「Claude が単純な思い違いで危険コマンドを実行する事故」の防止

FULL_COMMAND=$(jq -r '.tool_input.command // empty')

# トークン周辺の quote を除去
strip_quotes() {
  local s="$1"
  s="${s#\"}"; s="${s%\"}"
  s="${s#\'}"; s="${s%\'}"
  echo "$s"
}

# tool の global option をスキップして 1 番目の非オプショントークンを取得
# $1: コマンド全体, $2: tool 名, $3: 値をとるオプションのスペース区切りリスト
strip_options() {
  local cmd="$1"
  local tool="$2"
  local two_token_opts="$3"
  cmd="${cmd#$tool }"
  cmd="${cmd# }"
  while true; do
    local first
    first=$(echo "$cmd" | awk '{print $1}')
    [[ -z "$first" ]] && break
    # quote 除去後で判定
    local first_unq
    first_unq=$(strip_quotes "$first")
    case "$first_unq" in
      --*=*|-*=*)
        cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        ;;
      -*)
        local is_two=0
        for opt in $two_token_opts; do
          [[ "$first_unq" == "$opt" ]] && is_two=1 && break
        done
        if [[ $is_two -eq 1 ]]; then
          cmd=$(echo "$cmd" | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        else
          cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        fi
        ;;
      *)
        break
        ;;
    esac
  done
  # 結果も quote 除去
  strip_quotes "$(echo "$cmd" | awk '{print $1}')"
}

# 同じく、最初の N トークンに target が含まれるか（multi-level subcommand 用）
contains_subcmd() {
  local cmd="$1"
  local tool="$2"
  local two_token_opts="$3"
  local target="$4"
  cmd="${cmd#$tool }"
  cmd="${cmd# }"
  while true; do
    local first
    first=$(echo "$cmd" | awk '{print $1}')
    [[ -z "$first" ]] && break
    case "$first" in
      --*=*|-*=*) cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}') ;;
      -*)
        local is_two=0
        for opt in $two_token_opts; do
          [[ "$first" == "$opt" ]] && is_two=1 && break
        done
        if [[ $is_two -eq 1 ]]; then
          cmd=$(echo "$cmd" | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        else
          cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        fi
        ;;
      *) break ;;
    esac
  done
  for i in 1 2 3; do
    local tok
    tok=$(echo "$cmd" | awk -v i=$i '{print $i}')
    [[ "$tok" == "$target" ]] && return 0
  done
  return 1
}

# 各 tool の「値をとるオプション」リスト
NPM_TWO="-w --workspace --prefix -C --registry --tag --otp --include-workspace-root --workspaces-update --userconfig --globalconfig --cache --logfile --loglevel --access --auth-type"
PNPM_TWO="-F --filter --reporter --workspace-concurrency --report-summary --registry --config.script-shell --userconfig --globalconfig --cache --network-concurrency --child-concurrency"
YARN_TWO=""
CARGO_TWO="--color --target --target-dir --manifest-path"
PIP_TWO="--proxy --cert --client-cert --cache-dir --log -i --index-url"
GEM_TWO="--config-file -C"
TWINE_TWO="--config-file --repository --repository-url -u --username -p --password --identity"
TERRAFORM_TWO="-chdir"
KUBECTL_TWO="--kubeconfig --context --cluster --namespace -n --server --user --token --as --as-group --request-timeout --tls-server-name"
DOCKER_TWO="--config --context --host -H --log-level -l --tlscacert --tlscert --tlskey"
AWS_TWO="--profile --region --output --endpoint-url --ca-bundle --cli-read-timeout --cli-connect-timeout"
GCLOUD_TWO="--project --account --configuration --billing-project --impersonate-service-account --log-http"
FIREBASE_TWO="--project -P --token --debug-feature"
VERCEL_TWO="--token --scope --cwd --local-config -A --debug -d"
NETLIFY_TWO="--auth --site -s --filter"
FLYCTL_TWO="--access-token -t --app -a --config -c --verbose"
HELM_TWO="--kubeconfig --kube-context --namespace -n --kube-as-user --kube-as-group --kube-token --kube-apiserver --kube-ca-file --registry-config --repository-config --repository-cache"

deny() {
  echo "$1" >&2
  exit 2
}

# 1 つのコマンドセグメントを検査する
check_segment() {
  local COMMAND="$1"
  COMMAND=$(echo "$COMMAND" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [[ -z "$COMMAND" ]] && return

  # quote/backslash 連結による bypass を防ぐため、検査前に全 quote と backslash を除去
  # 例: n'p'm publish → npm publish, npm pub"lish" → npm publish
  # bash 実行時にこれらは解釈されて消えるので、検査側でも同様に正規化
  COMMAND="${COMMAND//\'/}"
  COMMAND="${COMMAND//\"/}"
  COMMAND="${COMMAND//\\/}"

  # subshell / command substitution / backtick の検出
  # これらを使われると先頭 token 判定を bypass される
  case "$COMMAND" in
    \(*|*\$\(*|*\`*)
      deny "subshell / command substitution / backtick は許可されていません（権限チェック bypass のリスク）。コマンドを直接書いてください。"
      ;;
  esac

  # 先頭の環境変数代入（VAR=value VAR2=value）を剥がす
  # 例: "CMD=publish npm \$CMD" → 代入を剥がすと "npm \$CMD"
  # 代入だけなら問題ない（NODE_ENV=production npm run build など）が、
  # 代入 + \$VAR 展開の組み合わせは bypass リスクなので block
  local has_assignment=0
  while [[ "$COMMAND" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do
    has_assignment=1
    COMMAND=$(echo "$COMMAND" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
  done
  if [[ $has_assignment -eq 1 && "$COMMAND" =~ \$[A-Za-z_{] ]]; then
    deny "環境変数代入と \$VAR 展開の組み合わせは許可されていません（変数経由で危険サブコマンドを bypass するリスク）。"
  fi

  local FIRST
  FIRST=$(strip_quotes "$(echo "$COMMAND" | awk '{print $1}')")

  # コマンド wrapper（env, command, exec, nice, time 等）の検出
  # これらでラップすると FIRST がラッパーになり、危険コマンド判定を bypass される
  case "$FIRST" in
    env|command|exec|nohup|nice|ionice|time|timeout|xargs|stdbuf|unbuffer)
      deny "コマンド wrapper ($FIRST) は許可されていません（権限チェック bypass のリスク）。対象コマンドを直接実行してください。"
      ;;
    bash|sh|zsh|dash|ksh|fish)
      # シェル -c によるコマンド実行は bypass の温床
      case "$COMMAND" in
        *\ -c\ *|*\ --command\ *)
          deny "shell -c によるコマンド実行は許可されていません（権限チェック bypass のリスク）。"
          ;;
      esac
      ;;
  esac

  # 危険ツールのサブコマンド位置に \$VAR があれば bypass リスク
  # 例: npm \$CMD（CMD が事前に publish に設定されている可能性）
  case "$FIRST" in
    npm|yarn|pnpm|cargo|pip|gem|twine|terraform|kubectl|docker|aws|gcloud|firebase|vercel|netlify|flyctl|helm)
      local rest
      rest=$(echo "$COMMAND" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
      # サブコマンド位置（最初の非オプショントークン）に $ があれば deny
      local sub_pos
      sub_pos=$(echo "$rest" | awk '{for(i=1;i<=NF;i++){if($i!~/^-/){print $i; exit}}}')
      sub_pos=$(strip_quotes "$sub_pos")
      if [[ "$sub_pos" =~ ^\$ ]]; then
        deny "$FIRST のサブコマンド位置に変数展開が使われています（事前代入経由で危険サブコマンドを呼ぶリスク）。"
      fi
      ;;
  esac

  case "$FIRST" in
    npm)
      SUB=$(strip_options "$COMMAND" "npm" "$NPM_TWO")
      [[ "$SUB" == "publish" ]] && deny "npm publish は許可されていません（パッケージレジストリへの公開）。"
      ;;
    yarn)
      SUB=$(strip_options "$COMMAND" "yarn" "$YARN_TWO")
      [[ "$SUB" == "publish" ]] && deny "yarn publish は許可されていません（パッケージレジストリへの公開）。"
      ;;
    pnpm)
      SUB=$(strip_options "$COMMAND" "pnpm" "$PNPM_TWO")
      [[ "$SUB" == "publish" ]] && deny "pnpm publish は許可されていません（パッケージレジストリへの公開）。"
      ;;
    cargo)
      SUB=$(strip_options "$COMMAND" "cargo" "$CARGO_TWO")
      [[ "$SUB" == "publish" ]] && deny "cargo publish は許可されていません（crates.io への公開）。"
      ;;
    pip)
      SUB=$(strip_options "$COMMAND" "pip" "$PIP_TWO")
      [[ "$SUB" == "publish" ]] && deny "pip publish は許可されていません。"
      ;;
    gem)
      SUB=$(strip_options "$COMMAND" "gem" "$GEM_TWO")
      [[ "$SUB" == "push" ]] && deny "gem push は許可されていません（rubygems.org への公開）。"
      ;;
    twine)
      SUB=$(strip_options "$COMMAND" "twine" "$TWINE_TWO")
      [[ "$SUB" == "upload" ]] && deny "twine upload は許可されていません（PyPI への公開）。"
      ;;
    terraform)
      SUB=$(strip_options "$COMMAND" "terraform" "$TERRAFORM_TWO")
      [[ "$SUB" == "apply" ]] && deny "terraform apply は許可されていません（インフラ適用）。"
      ;;
    kubectl)
      SUB=$(strip_options "$COMMAND" "kubectl" "$KUBECTL_TWO")
      [[ "$SUB" == "apply" ]] && deny "kubectl apply は許可されていません（K8s リソース適用）。"
      ;;
    docker)
      SUB=$(strip_options "$COMMAND" "docker" "$DOCKER_TWO")
      [[ "$SUB" == "push" ]] && deny "docker push は許可されていません（イメージレジストリへの公開）。"
      ;;
    aws)
      contains_subcmd "$COMMAND" "aws" "$AWS_TWO" "deploy" && deny "aws ... deploy は許可されていません（デプロイ系コマンド）。"
      ;;
    gcloud)
      contains_subcmd "$COMMAND" "gcloud" "$GCLOUD_TWO" "deploy" && deny "gcloud ... deploy は許可されていません（デプロイ系コマンド）。"
      ;;
    firebase)
      contains_subcmd "$COMMAND" "firebase" "$FIREBASE_TWO" "deploy" && deny "firebase deploy は許可されていません。"
      ;;
    vercel)
      contains_subcmd "$COMMAND" "vercel" "$VERCEL_TWO" "deploy" && deny "vercel deploy は許可されていません。"
      ;;
    netlify)
      contains_subcmd "$COMMAND" "netlify" "$NETLIFY_TWO" "deploy" && deny "netlify deploy は許可されていません。"
      ;;
    flyctl)
      contains_subcmd "$COMMAND" "flyctl" "$FLYCTL_TWO" "deploy" && deny "flyctl deploy は許可されていません。"
      ;;
    helm)
      SUB=$(strip_options "$COMMAND" "helm" "$HELM_TWO")
      if [[ "$SUB" == "install" || "$SUB" == "upgrade" ]]; then
        deny "helm $SUB は許可されていません（K8s リソースの変更）。"
      fi
      ;;
    sudo)
      deny "sudo は許可されていません。"
      ;;
  esac
}

# chain 演算子（&& || ; |）でセグメントに分割し、各セグメントを検査
# bash 3.2 で動くよう sed で改行に置換、while read で分割
SEGMENTS=$(echo "$FULL_COMMAND" | sed 's/||/\n/g; s/&&/\n/g; s/;/\n/g; s/|/\n/g')
while IFS= read -r seg; do
  check_segment "$seg"
done <<< "$SEGMENTS"

exit 0
