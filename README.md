# dotfiles

Mac の PC を初期状態からセットアップする前提。

## セットアップ

### Homebrew インストール

[Homebrew のドキュメント](https://docs.brew.sh/FAQ)を参考にインストール。

### セットアップ実行

#### セットアップスクリプト実行

```
./init.sh
```

`init.sh` は以下を順に実行する:
1. `install.sh`（シンボリックリンクの作成）
2. `brew bundle`（Homebrew パッケージのインストール）
3. `mise install`（言語/ツールのインストール）
4. `uv tool install`（uv ツールのインストール）

`brew bundle` でエラーが起きた場合はエラー内容に応じて対応すること。

#### config 再読み込み

```
source ~/.zshrc
source ~/.zprofile
```

## SSH

### 鍵

鍵ファイルは別途配置すること。

### Github セットアップ

config の設定などはセットアップスクリプトで実施済みなので、基本的には鍵の作成と登録のみで良い認識。

問題がある場合は、[Github のドキュメント](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=mac)を参考にしてセットアップすること。

# その他

## VS Code

### 設定

VS Code の設定と拡張機能は Settings Sync で同期している。  
VS Code をインストールして同期をオンにすること。
[参考](https://code.visualstudio.com/docs/editor/settings-sync)

### 注意

[Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=SimonSiefke.prettier-vscode)の拡張機能によって、各ファイルが予期せぬフォーマットされる可能性があるので注意。

必要に応じてワークスペース内で無効にしたり、任意のタイプのファイルのみ有効にしたり、任意のタイプのファイルは別のフォーマッタを有効にするなど対応すること。

# dotfiles 作成方法

- 基本的には、dotfile を更新して GitHub に push するだけで良い。
- homebrew でインストールしたパッケージは、`brew bundle dump --force`で Brewfile を作成しておく必要がある。
- 注意）go を mise で管理しているのに出力される場合は、`brew bundle dump --force --no-go`で go は除外できる。

# バージョン管理

[Mise](https://mise.jdx.dev/) で統一管理。

| ツール | 管理対象                                                       |
| ------ | -------------------------------------------------------------- |
| mise   | Node.js, Ruby, Flutter, Java, Python, Go, Terraform, pnpm など |

```bash
# グローバル設定確認
cat ~/.config/mise/config.toml

# プロジェクト別設定
cat .mise.toml
```

# Homebrew パッケージ

[BREW_PACKAGES.md](./BREW_PACKAGES.md) を参照。

# メモ

- Docker とか Slack も brew でインストールした方が良さげ。（[参考](https://engineers.weddingpark.co.jp/homebrew-bundle/)）

## zplug

zsh の plugin は、一部で管理している。
zplug から削除したい場合は、以下手順で削除する（はず）。

- `.zshrc`から該当の plugin の記述を削除
- `zplug clean`で削除（未使用のプラグインが削除される）
- `zplug list`で削除されたことを確認

## dotfiles の作り方

各種設定ファイルをリポジトリ内にコピー

```bash
mv ~/.zshrc $(pwd)/.zshrc
```

もとの場所にシンボリックリンクを作成

```bash
ln -s $(pwd)/.zshrc ~/.zshrc
```
