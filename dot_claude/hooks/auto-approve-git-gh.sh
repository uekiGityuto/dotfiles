#!/bin/bash
# git/gh コマンドの permission を自動承認する hook
# settings.json の allow list 肥大化を避けるため、サブコマンドベースで判定
# - 読み取り系・破壊性の低いサブコマンドは allow
# - その他はスルー（通常の prompt or deny list で判定される）
# - git -C <dir>, -c <key=val>, --git-dir, --work-tree のオプションを正しく処理

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git のグローバルオプションをスキップしてサブコマンドを抽出
get_git_subcmd() {
  local cmd="${1#git }"
  cmd="${cmd# }"
  while true; do
    case "$cmd" in
      -C\ *|--git-dir\ *|--work-tree\ *|-c\ *|--namespace\ *|-p\ *|--paginate\ *)
        # -X <arg> 形式: 2トークン消費
        cmd=$(echo "$cmd" | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        ;;
      --git-dir=*|--work-tree=*|--namespace=*|-c\=*|--*=*)
        # --opt=val 形式: 1トークン消費
        cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        ;;
      --no-pager|--paginate|--no-replace-objects|--bare|--no-optional-locks|--literal-pathspecs|--glob-pathspecs|--noglob-pathspecs|--icase-pathspecs|--exec-path*|--html-path|--man-path|--info-path|--version|--help)
        # フラグのみオプション: 1トークン消費
        cmd=$(echo "$cmd" | awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
        ;;
      *)
        break
        ;;
    esac
  done
  echo "$cmd" | awk '{print $1}'
}

# gh のサブコマンド + サブサブコマンドを抽出
get_gh_sub() {
  echo "${1#gh }" | awk '{print $1, $2}'
}

if [[ "$COMMAND" =~ ^git[[:space:]] ]] || [[ "$COMMAND" == "git" ]]; then
  SUBCMD=$(get_git_subcmd "$COMMAND")
  case "$SUBCMD" in
    # 純粋な読み取り系のみ（フラグで変更可能なもの: config/branch/tag/remote/bisect は除外）
    status|log|diff|show|rev-parse|ls-files|ls-tree|ls-remote|describe|blame|cat-file|symbolic-ref|merge-base|reflog|shortlog|name-rev|whatchanged|grep|annotate|archive|count-objects|fsck|verify-commit|verify-tag|var|for-each-ref|check-ref-format|check-attr|check-ignore|check-mailmap|version|help)
      echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
      ;;
  esac
elif [[ "$COMMAND" =~ ^gh[[:space:]] ]] || [[ "$COMMAND" == "gh" ]]; then
  SUB=$(get_gh_sub "$COMMAND")
  case "$SUB" in
    # 純粋な読み取り系のサブコマンドのみ
    # 除外したもの:
    #   - api *: -X DELETE/POST 等で破壊的 API 実行可能
    #   - auth token: 秘密値出力
    #   - pr checkout: ローカル作業状態を変える
    #   - repo clone, label clone: リモート/ローカル状態に影響
    "pr list"|"pr view"|"pr diff"|"pr checks"|"pr status"|\
    "issue view"|"issue list"|"issue status"|\
    "repo view"|"repo list"|\
    "search "*|\
    "run list"|"run view"|"run watch"|\
    "release list"|"release view"|\
    "workflow list"|"workflow view"|\
    "browse"|"browse "*|\
    "auth status"|\
    "config get"|"config list"|\
    "label list"|\
    "gist view"|"gist list")
      echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
      ;;
  esac
fi

exit 0
