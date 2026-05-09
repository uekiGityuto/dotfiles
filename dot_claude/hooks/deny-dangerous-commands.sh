#!/bin/bash
# publish/deploy/push 系の危険なコマンドを block する hook
# tool ごとに global option（値をとるもの含む）をスキップして subcommand を判定する

COMMAND=$(jq -r '.tool_input.command // empty')

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
    case "$first" in
      --*=*|-*=*)
        # --opt=val 形式: 1 トークン消費
        cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        ;;
      -*)
        # 値をとるオプションかチェック
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
      *)
        break
        ;;
    esac
  done
  echo "$cmd" | awk '{print $1}'
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
NPM_TWO="-w --workspace --prefix -C --registry --tag --otp --include-workspace-root --workspaces-update"
PNPM_TWO="-F --filter --reporter --workspace-concurrency --report-summary --registry --config.script-shell"
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

FIRST=$(echo "$COMMAND" | awk '{print $1}')

deny() {
  echo "$1" >&2
  exit 2
}

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

exit 0
