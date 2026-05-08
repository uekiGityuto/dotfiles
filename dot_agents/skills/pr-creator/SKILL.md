---
name: pr-creator
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

## PR 本文ルール

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
gh pr create --base <base> --head "$(git branch --show-current)" --title "<日本語タイトル>" --body-file "$tmpfile"
```

draft PR の場合だけ `--draft` を付ける。

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
