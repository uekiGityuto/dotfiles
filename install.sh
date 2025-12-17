#!/bin/bash

mkdir -p ~/.zsh
mkdir -p ~/.ssh/conf.d
mkdir -p ~/.config/mise

curl -o ~/.zsh/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o ~/.zsh/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

ln -sf "$(pwd)/Brewfile" ~/Brewfile
ln -sf "$(pwd)/.zprofile" ~/.zprofile
ln -sf "$(pwd)/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/.zshrc" ~/.zshrc
ln -sf "$(pwd)/.ssh/config" ~/.ssh/config
ln -sf "$(pwd)/.ssh/conf.d" ~/.ssh/conf.d
ln -sf "$(pwd)/.config/mise/config.toml" ~/.config/mise/config.toml
