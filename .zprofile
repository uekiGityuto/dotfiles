# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Mise - Version Manager (Node.js, Ruby, Flutter, Java, Python, Go, etc.)
eval "$(mise activate zsh)"

eval "$(zoxide init zsh)"

# Macは標準でLibreSSLが使用されるので、brewでインストールしたopensslが使用されるようにする
## 参考: https://tearoom6.hateblo.jp/entry/2020/05/30/225038
export PATH="$(brew --prefix openssl@3)/bin:$PATH"

# MySQLクライアントのパスを通す
# export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Android
## adbコマンドのパスを通す
export PATH="$PATH":"$HOME/Library/Android/sdk/platform-tools"
## adbコマンドのパスを通す
export PATH="$PATH":"$HOME/Library/Android/sdk/emulator"

# alias
alias k='kubectl'
alias d='docker'
alias dc='docker compose'
alias p='python'
alias ll='ls -alF'
alias tf='terraform'
alias zelda='afplay ~/pg/my/dotfiles/assets/sounds/zelda.mp3'
alias pathcopy='pwd | pbcopy'
