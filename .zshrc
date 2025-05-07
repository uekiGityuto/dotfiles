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

# GitHub Copilot

## GitHub Copilot CLI
## 参考: https://www.npmjs.com/package/@githubnext/github-copilot-cli
eval "$(github-copilot-cli alias -- "$0")"

## GitHub CLI
eval "$(gh completion -s zsh)"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/ueki/.dart-cli-completion/zsh-config.zsh ]] && . /Users/ueki/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# # zplug
# # 参考: https://github.com/zplug/zplug
# # 参考: https://dev.classmethod.jp/articles/20240408-i-tried-to-get-zplug-working-now/

export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# ## Macのターミナルで時間がかかるコマンドが終了したら通知する
# ## 参考: https://github.com/marzocchi/zsh-notify
# ## 参考: https://fromatom.hatenablog.com/entry/2019/12/10/201514
zplug "marzocchi/zsh-notify"

# Load theme file
# zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# 非同期処理できるようになる
# zplug "mafredri/zsh-async"
# テーマ(ここは好みで。調べた感じpureが人気)
# zplug "sindresorhus/pure"
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting"
# コマンド入力途中で上下キー押したときの過去履歴がいい感じに出るようになる
zplug "zsh-users/zsh-history-substring-search"
# 過去に入力したコマンドの履歴が灰色のサジェストで出る
zplug "zsh-users/zsh-autosuggestions"
# 補完強化
zplug "zsh-users/zsh-completions"
# 256色表示にする
zplug "chrissicool/zsh-256color"
# コマンドライン上の文字リテラルの絵文字を emoji 化する
# zplug "mrowa44/emojify", as:command

## Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

## Then, source plugins and add commands to $PATH
zplug load --verbose

## zsh-notifyのカスタマイズ
## 参考: https://github.com/marzocchi/zsh-notify
# zstyle ':notify:*' error-title "Command failed"
zstyle ':notify:*' success-title "Command succeeded"
# zstyle ':notify:*' error-sound "Glass"
zstyle ':notify:*' success-sound "default"
zstyle ':notify:*' always-notify-on-failure no
