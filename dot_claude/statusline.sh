#!/bin/bash
input=$(cat)

# モデル名
model=$(echo "$input" | jq -r '.model.display_name')

# ユーザー・ホスト
user=$(whoami)
host=$(hostname -s)

# ディレクトリ
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
cd "$cwd" 2>/dev/null || cd ~
current_dir=$(pwd | sed "s|^$HOME|~|")

# Git情報
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    state=""
    git diff --quiet 2>/dev/null || state="${state}*"
    git diff --cached --quiet 2>/dev/null || state="${state}+"
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] && state="${state}%"
    git rev-parse --verify refs/stash >/dev/null 2>&1 && state="${state}\$"

    upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [ -n "$upstream" ]; then
      local_commit=$(git rev-parse @ 2>/dev/null)
      remote_commit=$(git rev-parse @{upstream} 2>/dev/null)
      base_commit=$(git merge-base @ @{upstream} 2>/dev/null)
      if [ "$local_commit" != "$remote_commit" ]; then
        if [ "$local_commit" = "$base_commit" ]; then
          state="${state}<"
        elif [ "$remote_commit" = "$base_commit" ]; then
          state="${state}>"
        else
          state="${state}<>"
        fi
      fi
    fi

    git_info=" ($branch$state)"
  fi
fi

# 出力
printf "\033[33m%s\033[0m \033[32m%s@%s\033[0m: \033[36m%s\033[0m\033[31m%s\033[0m" \
  "$model" "$user" "$host" "$current_dir" "$git_info"
