# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# nodeバージョン管理
## 参考: https://qiita.com/mame_daifuku/items/373daf5f49ee585ea498
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Javaバージョン管理
## 参考: https://takezoe.hatenablog.com/entry/2020/04/20/233219
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# go installコマンドでinstallしたコマンドを実行可能にする
## 参考: https://maku77.github.io/p/s258beh/
export PATH=$HOME/go/bin:$PATH

# Macは標準でLibreSSLが使用されるので、brewでインストールしたopensslが使用されるようにする
## 参考: https://tearoom6.hateblo.jp/entry/2020/05/30/225038
export PATH="$(brew --prefix openssl@3)/bin:$PATH"

# alias
alias k='kubectl'
alias d='docker'
alias g='git'
