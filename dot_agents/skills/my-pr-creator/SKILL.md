---
name: my-pr-creator
description: GitHub Pull Request を作成・更新する。PR 作成、draft PR 作成、PR タイトル・本文修正、レビュー依頼前の PR 本文整備で使用する。タイトルと本文を日本語で書き、リポジトリのテンプレートがあれば必ず反映する。
---

# PR 作成

## 基本方針

PR のタイトルと本文は日本語で書く。

`gh pr create --fill` だけに任せない。本文はリポジトリの PR テンプレートを読んで明示的に作り、一時ファイル経由で `--body-file` に渡す。

デフォルトは ready PR。ユーザーが draft を求めた場合、または未完了・未検証で ready にできない明確な理由がある場合だけ draft PR にする。

## 作成前の確認

1. `git status --short --branch` で現在のブランチと差分を確認する
2. `git diff` / `git diff --cached` で PR に含める変更を確認する
3. 未関係の変更がある場合は勝手に stage しない
4. default branch 上なら作業ブランチを作る
5. stage は PR に含めるファイルだけを明示する
6. `gh auth status` で GitHub CLI が使えることを確認する

履歴改変、force push、既存 PR の大きな書き換えは、ユーザーが明示した場合だけ行う。

## テンプレート確認

次の順で PR テンプレートを探す。

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `.github/PULL_REQUEST_TEMPLATE/*.md`
4. `.github/pull_request_template/*.md`

複数ある場合は、ユーザー指定があればそれに従う。指定がなければ最も汎用的なテンプレートを選び、迷う場合は短く確認する。

テンプレートがない場合は、次の日本語フォーマットを使う。不要な節は削除してよい。

```markdown
## 概要

-

## 変更内容

-

## 確認

- [ ]

## 関連Issue

-
```

## 本文の粒度

各節の中身は **要点だけ** に圧縮する。実装の詳細はコードと PR の diff を読めば分かるので書かない。

### 各節に書くこと

- 「概要」:**メインの修正を 1〜2 行** + メインに付随した **大きめの修正** があれば 1 つにつき 1 行ずつ
- 「変更内容」: 概要より一段詳しく、ただし箇条書きの **1 項目あたり 1 行** で抑える
- 「確認」: 実行した検証項目のみ。粒度はチェックリスト 1 行

### 書かないこと

- 関数名・クラス名・コンポーネント名・変数名・ファイルパスなどの実装識別子
- 色名・スタイル値・CSS プロパティ・レイアウト調整の値
- 内部リファクタリングの理由付け（テクニカルな解説）
- フォーマット修正・lint 対応・依存追加・コメント修正など副次的な変更

### 良い例（概要）

```markdown
## 概要

- Figma に合わせて事前確認画面のデザインを修正
- ラジオボタンを外からも制御できる様に修正
```

### 悪い例（概要）

```markdown
## 概要

- RadioCardGroup に value + onChange を追加（dual mode 化）
- ageResetKey / residenceResetKey / nationalityResetKey と remount トリックを撤廃
- 自作の PreConfirmationRestrictionDialog を削除し共通 ModalProvider に統合
- buildRestrictionModal ヘルパーで modal config を切り出し
- <Stack component="form"> は残すが onChange は外す
...
```

実装の中身を細かく書き並べているのが NG。要点だけに圧縮する。

## PR 本文ルール

- 本文を書く前に `git log --oneline <base>..HEAD` で PR に含まれる全コミットを把握し、直前のコミットだけでなく全コミットを踏まえて書く（差分が必要なら `git log <base>..HEAD --stat` で範囲を絞って確認）
- テンプレートの見出し・チェック項目を尊重する
- placeholder や HTML コメントを未処理のまま残さない
- 実行していない確認を実行済みにしない
- 確認結果は「実行済み」「未実行」「対象外」「失敗」の区別が分かるように書く
- API コストがかかる eval や外部サービス依存の確認は、実行有無と理由を書く
- 関連 issue がない場合、issue close 用 placeholder は削除する
- `closes #123` は本当に close してよい issue にだけ使う
- テンプレート外の補足が必要な場合も日本語で追記する

## 作成・更新コマンド

本文は一時ファイルに書いて渡す。

```bash
gh pr create --base <base> --head "$(git branch --show-current)" --assignee uekiGityuto --title "<日本語タイトル>" --body-file "$tmpfile"
```

`--assignee uekiGityuto` で自分を assign する。draft PR の場合だけ `--draft` を付ける。

既存 PR のタイトルや本文を直す場合も、一時ファイルを使う。

```bash
gh pr edit <PR番号またはURL> --title "<日本語タイトル>" --body-file "$tmpfile"
```

## 作成後の報告

ユーザーには次を簡潔に伝える。

- PR URL
- branch と commit
- 実行した確認
- 未実行または失敗した確認
- PR に含めなかった未関係のローカル変更
