# dotfiles

Mac の PC を初期状態からセットアップする前提。

## セットアップ

### Homebrew セットアップ

[Homebrew のドキュメント](https://docs.brew.sh/FAQ)を参考にインストール。

## Github セットアップ

### OpenSSL をインストール

Mac デフォルトの OpenSSL だと ssh-agent のセットアップが上手く出来ない(?)ので、
Homebrew で OpenSSL をインストールしておく。

```
brew install openssl@3
echo 'export PATH="$(brew --prefix openssl@3)/bin:$PATH"' >> ~/.zprofile
```

#### SSH のセットアップ

[Github のドキュメント](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=mac)を参考にしてセットアップする。

```
./install.sh
```

## パッケージインストール

```
brew bundle
```

## config 再読み込み

```
source ~/.zshrc
source ~/.zprofile
```

# その他

## VS Code

### 設定

VS Code の設定と拡張機能は Settings Sync で同期している。  
VS Code をインストールして同期をオンにすること。
[参考](https://code.visualstudio.com/docs/editor/settings-sync)

### 注意

[Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=SimonSiefke.prettier-vscode)の拡張機能によって、各ファイルが予期せぬフォーマットされる可能性があるので注意。

必要に応じてワークスペース内で無効にしたり、任意のタイプのファイルのみ有効にしたり、任意のタイプのファイルは別のフォーマッタを有効にするなど対応すること。

# メモ

- node は nvm でバージョン管理
- python は pyenv でバージョン管理
- java は jenv でバージョン管理
- 環境切り替えはそもそも anyenv 使うと便利かも（[参考](https://zenn.dev/ryuu/articles/use-anyversions)）
- adoptopenjdk8 のインストールに失敗する可能性あり。  
  その場合は以下コマンドでインストールする。（[参考](https://qiita.com/gishi_yama/items/9cdb3d95ee7f25b8018f)）
- DockerとかSlackもbrewでインストールした方が良さげ。（[参考](https://engineers.weddingpark.co.jp/homebrew-bundle/)）

```
brew install --cask adoptopenjdk/openjdk/adoptopenjdk8
```
