.PHONY: init install brew-dump reload zplug-install zplug-update zplug-clean uv-install uv-dump

## 初期セットアップ（ディレクトリ作成、ファイルダウンロード、シンボリックリンク作成）
init:
	./init.sh

## install.sh を直接実行
install:
	./install.sh

## Brewfileを現在の状態で更新
brew-dump:
	brew bundle dump --force

## Homebrewパッケージをインストール
brew-install:
	brew bundle

## Miseで言語/ツールをインストール
mise-install:
	mise install

## シェル設定の再読み込み
reload:
	@echo "Run manually: source ~/.zshrc && source ~/.zprofile"

## zplugプラグインのインストール
zplug-install:
	zplug install

## zplugプラグインの更新
zplug-update:
	zplug update

## 未使用zplugプラグインの削除
zplug-clean:
	zplug clean

## uv toolのインストール
uv-install:
	while read -r tool; do uv tool install "$$tool"; done < uv-tools.txt

## uv-tools.txtを現在の状態で更新
uv-dump:
	uv tool list | grep -v '^-' | cut -d' ' -f1 > uv-tools.txt
