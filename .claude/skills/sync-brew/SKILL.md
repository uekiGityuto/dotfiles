---
name: sync-brew
description: BrewfileとBREW_PACKAGES.mdを現在のHomebrew状態に同期する。「brew sync」「Brewfile更新」「Brewfile最新化」「パッケージ反映」等と言われたとき、または外部でのHomebrew変更をリポジトリに反映したいときに使う。/add-brewからも呼び出される。
---

# sync-brew

BrewfileとBREW_PACKAGES.mdを現在のHomebrew状態に同期する。

$ARGUMENTS が渡された場合、新規追加パッケージの用途情報として扱う（例: "bat: シンタックスハイライト付きcat代替"）。

## 手順

### 1. Brewfile更新

`make brew-dump` を実行する。

`git diff Brewfile` で `brew` と `cask` の追加・削除を確認する。`vscode`、`tap`、`go` 行の変更は無視する。

miseで管理しているツール（go等）がBrewfileに出力された場合は、該当行をBrewfileから手動で削除する。

### 2. BREW_PACKAGES.md更新

`BREW_PACKAGES.md` を読み込み、Brewfileの差分に基づいて更新する。

**追加されたパッケージ:**
- 適切なカテゴリテーブルに追記する（例: 「CLI ツール」「Cask（GUI アプリ）」）
- $ARGUMENTS に用途情報があればそれを使う
- 用途が不明な場合はAskUserQuestionでユーザーに確認する
- 既存カテゴリに合わない場合は、新カテゴリ作成前にユーザーに確認する

**削除されたパッケージ:**
- テーブルから該当行を削除する

### 3. 報告

変更内容をまとめて報告する（追加・削除されたパッケージ、影響のあったカテゴリ）。
