# dotfiles

macOS 用の dotfiles 管理リポジトリ。

初期セットアップでは、ホームディレクトリ配下の設定ファイル/ディレクトリをこのリポジトリ内のファイルへシンボリックリンクし、Homebrew / mise / uv tool をまとめてセットアップする。

## 前提

- macOS
- Homebrew がインストール済みであること

Homebrew が未インストールの場合は、[Homebrew の公式ドキュメント](https://docs.brew.sh/Installation)を参照して先にインストールする。

## 初期セットアップ

```bash
./init.sh
```

`init.sh` は以下を順に実行する。

1. `./install.sh`
2. `make brew-install`
3. `make mise-install`
4. `make uv-install`

主な処理内容は次の通り。

- `install.sh`: dotfiles のシンボリックリンク作成、zsh 用の外部補完ファイル取得、`zsh-autosuggestions` の clone/pull
- `make brew-install`: `brew bundle`
- `make mise-install`: `mise install`
- `make uv-install`: `uv-tools.txt` に書かれた uv tool のインストール

`brew bundle` でエラーが起きた場合は、表示されたエラー内容に応じて対応する。

## 設定の再読み込み

初期セットアップ後、必要に応じて zsh 設定を再読み込みする。

```bash
source ~/.zshrc
source ~/.zprofile
```

Makefile から確認する場合:

```bash
make reload
```

## 管理方式

### dot_ プレフィクス

`dot_` プレフィクス付きのファイル/ディレクトリは、ホームディレクトリ配下の `.` 付きパスに対応する。

例:

| リポジトリ内 | リンク先 |
| --- | --- |
| `dot_zshrc` | `~/.zshrc` |
| `dot_zprofile` | `~/.zprofile` |
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_zsh` | `~/.zsh` |
| `dot_ssh` | `~/.ssh` |
| `dot_claude` | `~/.claude` |
| `dot_codex` | `~/.codex` |
| `dot_agents` | `~/.agents` |
| `dot_takt` | `~/.takt` |
| `dot_config/mise` | `~/.config/mise` |
| `dot_config/ghostty` | `~/.config/ghostty` |
| `dot_config/yazi` | `~/.config/yazi` |

このリポジトリ自体の設定ファイルは、`.claude/` や `.vscode/` のようにプレフィクスなしで配置する。

### シンボリックリンク

リンク作成は `install.sh` が行う。

```bash
make install
```

既存のシンボリックリンクは上書きされる。既存の通常ファイル/通常ディレクトリがある場合は、黙って上書きせずエラーで停止する。初回セットアップ前に必要なファイルを退避しておく。

ディレクトリごとリンクする対象の管理ファイルは、各ディレクトリ内の `.gitignore` で制御する。

## よく使うコマンド

| コマンド | 内容 |
| --- | --- |
| `make init` | 初期セットアップを実行 |
| `make install` | シンボリックリンク作成と zsh 関連ファイル取得 |
| `make brew-install` | `brew bundle` を実行 |
| `make brew-dump` | 現在の Homebrew 状態を `Brewfile` に反映 |
| `make mise-install` | mise 管理ツールをインストール |
| `make uv-install` | `uv-tools.txt` の uv tool をインストール |
| `make uv-dump` | 現在の uv tool 一覧を `uv-tools.txt` に反映 |
| `make zplug-install` | zplug plugin をインストール |
| `make zplug-update` | zplug plugin を更新 |
| `make zplug-clean` | 未使用 zplug plugin を削除 |

## Homebrew

Homebrew パッケージは `Brewfile` で管理する。

現在のインストール状態を反映する場合:

```bash
make brew-dump
```

Go など mise で管理したいツールが `Brewfile` に混ざる場合は、必要に応じて `brew bundle dump --force --no-go` のように除外オプションを使う。

パッケージの概要は [BREW_PACKAGES.md](./BREW_PACKAGES.md) を参照。

## mise

言語/ツールのバージョン管理は [mise](https://mise.jdx.dev/) で行う。

グローバル設定:

```bash
cat ~/.config/mise/config.toml
```

このリポジトリでは `dot_config/mise/config.toml` を `~/.config/mise` にリンクする。

## uv tool

uv tool は `uv-tools.txt` で管理する。

現在の uv tool 一覧を反映する場合:

```bash
make uv-dump
```

## サプライチェーン対策

各パッケージマネージャの cooldown 設定状況と、未対策ツールの運用方針は [SUPPLY_CHAIN.md](./SUPPLY_CHAIN.md) を参照。

## SSH

SSH 鍵は別途用意する。

GitHub への SSH 接続で問題がある場合は、[GitHub の公式ドキュメント](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=mac)を参照する。

## VS Code

VS Code の設定と拡張機能は Settings Sync で同期している。

VS Code をインストールして同期を有効化する。詳細は [Settings Sync の公式ドキュメント](https://code.visualstudio.com/docs/editor/settings-sync) を参照。

[Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=SimonSiefke.prettier-vscode) などの拡張機能によって、ファイルが意図せずフォーマットされる可能性がある。必要に応じてワークスペース単位で無効化する。

## zplug

zsh plugin は zplug で管理する。

plugin を削除する場合:

1. `dot_zshrc` から対象 plugin の記述を削除する
2. `make zplug-clean`
3. `zplug list` で削除を確認する

## dotfile の追加手順

例: `~/.example` を管理対象に追加する場合。

```bash
mv ~/.example "$(pwd)/dot_example"
ln -s "$(pwd)/dot_example" ~/.example
```

永続化するには、必要に応じて `install.sh` にリンク作成処理を追加してコミットする。
