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
- **シェル設定**: `.zshrc`（対話的設定）、`.zprofile`（環境変数）
- **パッケージ管理**: `Brewfile`（Homebrewパッケージとcask、VS Code拡張機能）
- **インストールスクリプト**: `install.sh`（実際の処理）、`init.sh`（ラッパー）
- **Git設定**: `.gitconfig`（グローバル設定、エイリアス、Git LFS）
- **SSH設定**: `.ssh/config`、`.ssh/conf.d/hosts/*.config`（ホスト別設定）

### バージョン管理統合
- Node.js: nvm（`.zprofile`で初期化）
- Java: jenv（`.zprofile`で初期化）
- Python: pyenv（`.zprofile`で初期化）
- Ruby: rbenv（`.zprofile`で初期化）
- Flutter: fvm（`.zprofile`でパス設定）

### 重要な設計方針
1. **シンボリックリンク方式**: `install.sh`がdotfilesをホームディレクトリにシンボリックリンクとして配置
2. **分離された設定**: 環境変数（`.zprofile`）と対話的設定（`.zshrc`）を分離
3. **zplugによるプラグイン管理**: 構文ハイライト、自動補完、通知機能などを管理
4. **VS Code Settings Sync**: VS Codeの設定は同期で管理、拡張機能はBrewfileで管理

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
SSH鍵ファイルは別途管理が必要（このリポジトリには含まれない）