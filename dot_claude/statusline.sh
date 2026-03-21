#!/bin/bash
input=$(cat)

# リポジトリ名
cwd=$(echo "$input" | jq -r '.workspace.project_dir // .cwd // ""')
repo_name=$(basename "$cwd" 2>/dev/null)

# ブランチ名
branch="-"
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo "-")
fi

# コンテキスト使用量
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // ""')
if [ -n "$ctx_pct" ] && [ "$ctx_pct" != "null" ]; then
  ctx_display="ctx: ${ctx_pct}%"
else
  ctx_display="ctx: -"
fi

# モデル名
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "-"')

# 5h使用量とリセット
five_h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // ""')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // ""')
if [ -n "$five_h_pct" ] && [ "$five_h_pct" != "null" ]; then
  five_h_str="5h: ${five_h_pct}%"
  if [ -n "$five_h_reset" ] && [ "$five_h_reset" != "null" ]; then
    five_h_str="${five_h_str}($(date -r "$five_h_reset" '+%H:%M' 2>/dev/null))"
  fi
else
  five_h_str="5h: -"
fi

# 7d使用量とリセット
seven_d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // ""')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // ""')
if [ -n "$seven_d_pct" ] && [ "$seven_d_pct" != "null" ]; then
  seven_d_str="7d: ${seven_d_pct}%"
  if [ -n "$seven_d_reset" ] && [ "$seven_d_reset" != "null" ]; then
    seven_d_str="${seven_d_str}($(date -r "$seven_d_reset" '+%m/%d' 2>/dev/null))"
  fi
else
  seven_d_str="7d: -"
fi

# 出力
# Line 1: リポジトリ名 | ブランチ名
# Line 2: コンテキスト使用量 | モデル
# Line 3: 5h,7dの使用量とリセット日
printf "\033[36m%s\033[0m | \033[32m%s\033[0m\n" "$repo_name" "$branch"
printf "%s | \033[33m%s\033[0m\n" "$ctx_display" "$model"
printf "%s | %s" "$five_h_str" "$seven_d_str"
