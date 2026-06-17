#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_path() {
	local source_path="$1"
	local target_path="$2"
	local target_parent

	target_parent="$(dirname "$target_path")"
	mkdir -p "$target_parent"

	if [ -L "$target_path" ]; then
		ln -sfn "$source_path" "$target_path"
		return
	fi

	if [ -e "$target_path" ]; then
		printf 'Refusing to replace existing non-symlink: %s\n' "$target_path" >&2
		printf 'Move it aside manually, then rerun install.sh.\n' >&2
		exit 1
	fi

	ln -s "$source_path" "$target_path"
}

mkdir -p "$HOME/.config"

# 個別ファイル
link_path "$script_dir/dot_zprofile" "$HOME/.zprofile"
link_path "$script_dir/dot_gitconfig" "$HOME/.gitconfig"
link_path "$script_dir/dot_zshrc" "$HOME/.zshrc"

# ディレクトリごとシンボリックリンク
link_path "$script_dir/dot_zsh" "$HOME/.zsh"
link_path "$script_dir/dot_ssh" "$HOME/.ssh"
link_path "$script_dir/dot_claude" "$HOME/.claude"
link_path "$script_dir/dot_config/ghostty" "$HOME/.config/ghostty"
link_path "$script_dir/dot_config/mise" "$HOME/.config/mise"
link_path "$script_dir/dot_config/uv" "$HOME/.config/uv"
link_path "$script_dir/dot_config/yazi" "$HOME/.config/yazi"
link_path "$script_dir/dot_config/zellij" "$HOME/.config/zellij"
link_path "$script_dir/dot_config/git" "$HOME/.config/git"
link_path "$script_dir/dot_config/gh" "$HOME/.config/gh"
link_path "$script_dir/dot_takt" "$HOME/.takt"
link_path "$script_dir/dot_codex" "$HOME/.codex"
link_path "$script_dir/dot_agents" "$HOME/.agents"

# ~/.zsh 内の外部ファイルを取得・更新
if [ "${INSTALL_SKIP_EXTERNALS:-0}" = "1" ]; then
	exit 0
fi

curl -fL -o "$HOME/.zsh/git-prompt.sh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -fL -o "$HOME/.zsh/git-completion.bash" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -fL -o "$HOME/.zsh/_git" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
if [ -d "$HOME/.zsh/zsh-autosuggestions/.git" ]; then
	git -C "$HOME/.zsh/zsh-autosuggestions" pull --ff-only
else
	git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
fi
