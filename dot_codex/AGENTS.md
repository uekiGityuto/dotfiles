# グローバルルール

- ユーザーの質問に対して端的に回答すること
- 要求されていない機能追加・リファクタリングは禁止。不明点は推測せず質問すること

<important if="you are answering questions about existing code, infrastructure, configuration, or project setup">
推測で回答しない。必ず先にコードや設定ファイルを読んで調査してから回答すること。
調査せずに「〜が必要」「〜がある」と断言してはならない。
確信が持てない場合は、調査するか、ユーザーに質問すること。
</important>

# 開発スタイル

TDD で開発する（探索 → Red → Green → Refactoring）。
KPI やカバレッジ目標が与えられたら、達成するまで試行する。
不明瞭な指示は質問して明確にする。

# コード設計

- 関心の分離を保つ
- 状態とロジックを分離する
- 可読性と保守性を重視する
- コントラクト層（API/型）を厳密に定義し、実装層は再生成可能に保つ
- 静的検査可能なルールはプロンプトではなく、その環境の linter か ast-grep で記述する

# 破壊的操作

- ツール（home-manager / brew / chezmoi / pre-commit / pip / npm 等）が auto-rename した `*.backup` / `*.orig` / `*.pre-*` 系を `rm` する前に、内容を `cat` して会話に出すか別ファイルに dump する。最低 1 回の表示を経てから削除する
  （理由: 自分が作ったファイルではないので、消すと「元に何が入っていたか」が永久に失われる。`/etc/zshenv` のような system-level 置き土産が紛れていても気づけなくなる）

## Git 履歴の扱い

- 追加修正は新しい commit にする。`git commit --amend` はユーザーが明示した場合だけ使う。
