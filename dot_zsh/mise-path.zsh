# mise activate の shell hook ではなく shims を PATH 先頭に置く。
# 非対話的な実行環境でも repo ごとの tool version を解決しやすくするため。
export PATH="$HOME/.local/share/mise/shims:$PATH"
