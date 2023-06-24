# git
## 参考: https://qiita.com/mikan3rd/items/d41a8ca26523f950ea9d
## 参考: https://qiita.com/yamaday0u/items/ee8acb35709bcc8c7fc7

## git-promptの読み込み
source ~/.zsh/git-prompt.sh
## git-completionの読み込み
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
autoload -Uz compinit && compinit
## プロンプトのオプション表示設定
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto
## プロンプトの表示設定(好きなようにカスタマイズ可)
setopt PROMPT_SUBST ; PS1='%F{green}%n@%m%f: %F{cyan}%~%f %F{red}$(__git_ps1 "(%s)")%f
\$ '

# 自動補完
## 参考: https://zenn.dev/snowcat/articles/dd90a7796b9af4

## 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history
## メモリに保存される履歴の件数
export HISTSIZE=1000
## 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
## 重複を記録しない
setopt hist_ignore_dups
## ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
## 余分な空白は詰めて記録
setopt hist_reduce_blanks
## 自動補完の設定
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# GitHub Copilot

## GitHub Copilot CLI
## 参考: https://www.npmjs.com/package/@githubnext/github-copilot-cli
eval "$(github-copilot-cli alias -- "$0")"

## GitHub CLI
eval "$(gh completion -s zsh)"
