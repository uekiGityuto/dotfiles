---
name: add-brew
description: Homebrewパッケージをインストールし、BrewfileとBREW_PACKAGES.mdを更新する。「brew add」「brew install」「Homebrewで追加して」「○○を入れたい」等と言われたとき、または新しいHomebrew formulaやcaskをdotfilesに追加したいときに使う。
---

# add-brew

Homebrewパッケージをインストールし、ドキュメントを同期する。

$ARGUMENTS = パッケージ指定（例: `bat`、`--cask raycast`）

## 手順

### 1. インストール

`brew install $ARGUMENTS` を実行する。

### 2. 用途の収集

会話の文脈からパッケージの用途を推測する。不明な場合はAskUserQuestionでユーザーに確認する。

### 3. 同期

用途情報を引数に渡して `/sync-brew` を呼び出す:

```
/sync-brew <パッケージ名>: <用途>
```
