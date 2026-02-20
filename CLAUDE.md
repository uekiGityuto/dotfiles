# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

このリポジトリはmacOS用のdotfiles管理リポジトリです。シェル設定、開発ツール設定、パッケージ管理を中心に構成されています。

## 重要なコマンド

### セットアップ関連
```bash
# 初期セットアップ（ディレクトリ作成、ファイルダウンロード、シンボリックリンク作成）
./init.sh

# Homebrewパッケージのインストール
brew bundle

# Miseで言語/ツールをインストール
mise install

# Brewfileの更新（新しいパッケージを追加した後）
brew bundle dump --force

# 設定の再読み込み
source ~/.zshrc
source ~/.zprofile
```

### zplugプラグイン管理
```bash
# プラグインのインストール/更新
zplug install
zplug update

# 未使用プラグインの削除
zplug clean

# インストール済みプラグインの確認
zplug list
```

## アーキテクチャと構造

### ファイル構成
- **シェル設定**: `dot_zshrc`（対話的設定）、`dot_zprofile`（環境変数）
- **パッケージ管理**: `Brewfile`（Homebrewパッケージとcask、VS Code拡張機能）
- **パッケージ一覧**: `BREW_PACKAGES.md`（Homebrewパッケージの用途説明）
- **インストールスクリプト**: `install.sh`（実際の処理）、`init.sh`（ラッパー）
- **Git設定**: `dot_gitconfig`（グローバル設定、エイリアス、Git LFS）
- **SSH設定**: `dot_ssh/config`、`dot_ssh/conf.d/hosts/*.config`（ホスト別設定）
- **Mise設定**: `dot_config/mise/config.toml`（言語バージョン管理）
- **Ghostty設定**: `dot_config/ghostty/config`
- **Yazi設定**: `dot_config/yazi/yazi.toml`
- **Claude設定**: `dot_claude/`（CLAUDE.md, settings.json, statusline.sh）

### バージョン管理統合
[Mise](https://mise.jdx.dev/)で統一管理（`.zprofile`で初期化）：
- Node.js
- Ruby
- Flutter
- Java
- Python
- Go
- pnpm

### ファイル命名規則
- `dot_` プレフィックス → ホームディレクトリでは `.` に対応（例: `dot_zshrc` → `~/.zshrc`）
- ディレクトリごとシンボリックリンクにする場合、`.gitignore` で管理対象のみを許可リスト方式で管理

### 重要な設計方針
1. **シンボリックリンク方式**: `install.sh`がdotfilesをホームディレクトリにシンボリックリンクとして配置
2. **ディレクトリごとシンボリックリンク**: `.ssh`, `.claude`, `.config/ghostty`, `.config/mise`, `.config/yazi` はディレクトリごとリンク。管理外ファイル（鍵、ランタイムデータ等）は各ディレクトリの `.gitignore` で除外
3. **分離された設定**: 環境変数（`.zprofile`）と対話的設定（`.zshrc`）を分離
4. **zplugによるプラグイン管理**: 構文ハイライト、自動補完、通知機能などを管理
5. **VS Code Settings Sync**: VS Codeの設定は同期で管理、拡張機能はBrewfileで管理

## 開発時の注意点

### dotfileの更新
1. 対象のdotfileを直接編集
2. Gitでコミット・プッシュ
3. 他のマシンでは`git pull`後、必要に応じて`source ~/.zshrc`等で再読み込み

### 新しいHomebrewパッケージの追加
1. `brew install <package>` でインストール
2. `brew bundle dump --force` でBrewfileを更新
3. Brewfileをコミット

### zplugプラグインの追加/削除
- 追加: `.zshrc`にプラグイン記述を追加後、`zplug install`
- 削除: `.zshrc`から記述を削除後、`zplug clean`

### SSH鍵の管理
SSH鍵ファイルは `dot_ssh/` ディレクトリ内に存在するが、`.gitignore` で除外されておりGit管理対象外