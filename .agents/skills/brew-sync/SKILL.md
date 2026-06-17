---
name: brew-sync
description: BrewfileとBREW_PACKAGES.mdを現在のHomebrew状態に同期する。「brew sync」「Brewfile更新」「Brewfile最新化」「パッケージ反映」等と言われたとき、または外部でのHomebrew変更をリポジトリに反映したいときに使う。/brew-addからも呼び出される。
---

# brew-sync

BrewfileとBREW_PACKAGES.mdを現在のHomebrew状態に同期する。

$ARGUMENTS が渡された場合、新規追加パッケージの用途情報として扱う（例: "bat: シンタックスハイライト付きcat代替"）。

## 手順

### 1. Brewfile更新

`make brew-dump` を実行する。

`git diff Brewfile` で `brew` と `cask` の追加・削除を確認する。`vscode`、`tap`、`go` 行の変更は無視する。

miseで管理しているツール（go等）がBrewfileに出力された場合は、該当行をBrewfileから手動で削除する。

**`npm "..."` 行は原則すべて削除する。**

`brew bundle dump` は `npm ls -g` の結果を `npm "..."` 行として記録するが、これらは多くが Node.js 同梱の標準パッケージ（`corepack`, `npm` 自身など）で、`brew bundle install` 時にすでに存在するため意味がない。さらに Node 自体は mise 管理なので Brewfile の責務外。

例外として「自分が明示的に `npm install -g` したパッケージ」を Brewfile に残したい場合のみ、判断のうえ維持する。それ以外は削除すること。

なお `uv "..."` と `go "..."` 行は「自分でインストールしたものを再現する」用途で維持している（標準同梱ではない）。`npm` だけ扱いが違う点に注意。

**注意: サードパーティ tap の brew 行は手動で維持する。**

`brew bundle dump` は `brew "tap_owner/tap_name/pkg"` 形式（サードパーティ tap のパッケージ）を出力しない。そのため:

- `diff` でこれらの行が「削除」として現れても、勝手に削除してはならない。`brew list` で該当パッケージが実際にインストール済みかを確認し、インストールされていれば Brewfile に書き戻す
- Brewfile 内では「手動維持」とわかるコメント（例: `# NOTE: brew bundle dump はサードパーティ tap の \`brew "tap/name/pkg"\` 行を出力しないため、以下は手動で維持する`）を残しておく
- 該当パッケージを新規追加した場合（`/brew-add` 経由含む）も、`make brew-dump` 後に手動で書き戻し + コメント付与をすること

現時点で手動維持が必要な行: `brew "facebook/fb/idb-companion"`, `brew "k1low/tap/tbls"`

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
