#!/bin/bash

mkdir -p ~/.zsh
mkdir -p ~/.config

curl -o ~/.zsh/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o ~/.zsh/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
if [ -d ~/.zsh/zsh-autosuggestions ]; then
	git -C ~/.zsh/zsh-autosuggestions pull --ff-only
else
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

# 個別ファイル
ln -sf "$(pwd)/dot_zprofile" ~/.zprofile
ln -sf "$(pwd)/dot_gitconfig" ~/.gitconfig
ln -sf "$(pwd)/dot_zshrc" ~/.zshrc

# ディレクトリごとシンボリックリンク
ln -sfn "$(pwd)/dot_ssh" ~/.ssh
ln -sfn "$(pwd)/dot_claude" ~/.claude
ln -sfn "$(pwd)/dot_config/ghostty" ~/.config/ghostty
ln -sfn "$(pwd)/dot_config/mise" ~/.config/mise
ln -sfn "$(pwd)/dot_config/yazi" ~/.config/yazi
ln -sfn "$(pwd)/dot_takt" ~/.takt
ln -sfn "$(pwd)/dot_codex" ~/.codex
ln -sfn "$(pwd)/dot_agents" ~/.agents
