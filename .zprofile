# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# ssh-agentにSSH private keyを追加
# TODO: 本来は一度実行するだけで良いはず。毎回実行しないようにしたい。
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# nodeバージョン管理
## 参考: https://dev-yakuza.posstree.com/environment/nvm/
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Javaバージョン管理
## 参考: https://qiita.com/mmmu/items/5e00a28d2ccbb37b1110
## 参考: https://qiita.com/gishi_yama/items/9cdb3d95ee7f25b8018f
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Pythonバージョン管理
## 参考: https://qiita.com/koooooo/items/b21d87ffe2b56d0c589b
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# go installコマンドでinstallしたコマンドを実行可能にする
## 参考: https://maku77.github.io/p/s258beh/
export PATH=$HOME/go/bin:$PATH

# Macは標準でLibreSSLが使用されるので、brewでインストールしたopensslが使用されるようにする
## 参考: https://tearoom6.hateblo.jp/entry/2020/05/30/225038
export PATH="$(brew --prefix openssl@3)/bin:$PATH"

# MySQLクライアントのパスを通す
# export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Flutterバージョン管理（fvm）
# fvmで管理しているFlutterはfvm flutterコマンドで実行するが、flutterコマンドを実行したいときがあるので、
# fvmでglobal指定しているFlutterのパスを通して、flutterコマンドを実行できるようにする。
# aliasでfvm flutterコマンドをflutterコマンドに置き換えることもできるが、Makefileからはaliasが適用されなかったので、この方法を採用。
export PATH="$PATH":"$HOME/fvm/default/bin"

# alias
alias k='kubectl'
alias d='docker'
alias dc='docker compose'
alias p='python'
alias ll='ls -alF'
