---
name: create-pr-with-screenshots
description: >-
  画面のスクリーンショット付きPRを作成する。
  トリガー例：「スクショ付きでPR作って」「画面のスクリーンショットを撮ってPR作成して」
  「SP/PCのスクショをPRに貼って」「localhost:8080/lp/meijinのスクショ撮ってPR作って」
  PRに画像を添付したい場合や、新規画面の実装後にビジュアル確認用のPRを作りたい場合に使用する。
user-invocable: true
disable-model-invocation: true
argument-hint: "[url]"
allowed-tools: Bash(gh *), Bash(lsof *), Bash(git *), Bash(sips *), Bash(pnpm dlx playwright *), Bash(npx playwright *), Bash(browser-use *), Bash(ls *), Bash(sleep *), Read, Glob, Write, Skill(browser-use *)
---

# スクリーンショット付きPR作成スキル

新規画面や変更画面のSP/PCスクリーンショットを撮影し、テーブル形式でPR説明欄に埋め込んでPRを作成する。

## ツール構成

- **スクショ撮影**: Playwright CLI — ビューポート指定が簡単、ログイン不要
  - pnpmプロジェクトでは `pnpm dlx playwright screenshot`、npmプロジェクトでは `npx playwright screenshot` を使うこと
- **GitHub画像アップロード**: browser-use CLI — ChromeのProfile 1のログイン状態を利用。コマンド詳細は `browser-use` スキルを参照

## 仕組み

GitHub APIには画像アップロードのエンドポイントがないため、**PRのコメント欄を画像ホスティングのステージングエリアとして利用する**。
コメント欄にファイルをアップロードすると `user-attachments/assets/` のURLが生成され、コメントを投稿しなくてもURLは永続化される。

## Step 0: 情報の整理

以下を確定させる:

1. **スクリーンショット対象のURL** — 会話の文脈からわかればそれを使う。わからなければユーザーに聞く
2. **PRのタイトルと内容** — 会話の文脈から推測する

## Step 1: スクリーンショット撮影

Playwright CLIでSP・PCの2サイズでフルページスクリーンショットを撮影する。

```bash
# pnpmプロジェクトの場合
pnpm dlx playwright screenshot --full-page --viewport-size="375,667" <対象URL> /tmp/claude/screenshot_sp.png
pnpm dlx playwright screenshot --full-page --viewport-size="1440,900" <対象URL> /tmp/claude/screenshot_pc.png

# npmプロジェクトの場合
npx playwright screenshot --full-page --viewport-size="375,667" <対象URL> /tmp/claude/screenshot_sp.png
npx playwright screenshot --full-page --viewport-size="1440,900" <対象URL> /tmp/claude/screenshot_pc.png
```

撮影後にファイルサイズを確認し、10MBを超える場合はリサイズする:

```bash
sips --resampleWidth 1024 /tmp/claude/screenshot_sp.png
sips --resampleWidth 1440 /tmp/claude/screenshot_pc.png
```

## Step 2: PRの作成

### 2-1. ブランチ作成・コミット・プッシュ

まだ済んでいない場合は通常の手順で行う。

### 2-2. PRテンプレートの読み込み

プロジェクトの `.github/pull_request_template.md` を探して読み込む。
テンプレートが見つかった場合は、その構造に従ってPR本文を作成する。

### 2-3. PR作成（スクショなしで先に作成）

PR本文を `/tmp/claude/pr-body.md` に書き出してから作成する:

```bash
gh pr create --title "<タイトル>" --body-file /tmp/claude/pr-body.md
```

画像URLの取得にPRページが必要なため、スクショは次のStepで追加する。

## Step 3: 画像のアップロードとPR説明欄への埋め込み

browser-use CLIを使い、ChromeのProfile 1（GitHubログイン済み）でPRページにアクセスして画像をアップロードする。
browser-use CLIのコマンド詳細は `browser-use` スキルを参照すること。

**重要**: browser-useのグローバルオプション（`--profile`, `--headed` 等）はサブコマンドの**前**に指定すること。

### 手順

1. 既存セッションを確認し、あれば閉じる
2. PRページを開く:
   ```bash
   browser-use --profile "Profile 1" --headed open <PR URL>
   ```
3. `browser-use state` でログイン状態とファイルアップロード用input要素（`fc-new_comment_field`）のインデックスを確認
4. SP画像、PC画像の順にアップロード（各アップロード後に5秒程度待機する）:
   ```bash
   browser-use upload <fc-new_comment_fieldのインデックス> /tmp/claude/screenshot_sp.png
   sleep 5
   browser-use upload <fc-new_comment_fieldのインデックス> /tmp/claude/screenshot_pc.png
   sleep 5
   ```
5. テキストエリアから画像URLを抽出:
   ```bash
   browser-use eval "document.getElementById('new_comment_field')?.value"
   ```
   `<img ... src="https://github.com/user-attachments/assets/..." />` 形式でSP・PCの2つのURLが返る。これらのsrc属性の値を控える。
6. テキストエリアをクリア（**コメントは投稿しない**）:
   ```bash
   browser-use eval "document.getElementById('new_comment_field').value = ''"
   ```
7. `browser-use close --all` でセッションを閉じる（**画像URL抽出後、必ず実行すること**）
8. 既存のPR本文にスクショテーブルを追加した内容を `/tmp/claude/pr-body.md` に書き出し、`gh pr edit --body-file /tmp/claude/pr-body.md` で更新:

```markdown
| SP                                             | PC                                              |
| ---------------------------------------------- | ----------------------------------------------- |
| <img width="375" alt="SP" src="{SP画像URL}" /> | <img width="1440" alt="PC" src="{PC画像URL}" /> |
```

**テーブルの挿入位置**: PRの変更内容を説明しているセクション（例: `## 概要`）の末尾、次のセクションの前に追記する。

## Step 4: 結果の確認

browser-useのセッションが残っていないか確認し、残っていれば閉じる:

```bash
browser-use sessions
browser-use close --all  # セッションが残っていた場合
```

```bash
gh pr view --web
```

ユーザーにPRのURLを伝えて完了。

## トラブルシューティング

| 問題                              | 対処                                                |
| --------------------------------- | --------------------------------------------------- |
| `npx playwright` が動かない       | pnpmプロジェクトでは `pnpm dlx playwright` を使う   |
| ログインしていない                | ユーザーに手動ログインを依頼し、再度 `state` で確認 |
| テキストエリアにURLが出ない       | 待機時間を延長して再試行                            |
| 画像が10MBを超える                | `sips --resampleWidth` でリサイズ                   |
| file input要素が見つからない      | ページ最下部までスクロールしてから `state` で再確認 |
| browser-useセッションが残っている | 全セッションを閉じてから再実行                      |
