# ショートカット

Mac でよく使うショートカットメモ

## PC

- 選択キャプチャ:
  `command + shift + 4`
  - 4 を 3 にすると画面全体
  - ctrl をつけるとクリップボードに保存
- やり直し（`cmd + z`の取り消し）:
  `cmd + shift + z`
- 移動:
  `cmd + c → command + opt + v`
- 不可視ファイル表示:
  `cmd + shift + .`

## VSCode

### ショートカット

- フォーマット:
  `shift + option + f`
- コマンドパレット:
  `cmd + shift + p`
- 矩形選択:
  `cmd + shift + opt`
- PlantUML:
  `opt + d`
- Markdown:
  `cmd + k → v`
- エディタ → ターミナル移動:
  `ctrl + shift + @`
- ターミナル → エディタ移動:
  `ctrl + 1`
- タブを全て閉じる:
  `cmd + k + w`
- 同じ単語を選択:
  `cmd + d`
- 同じ単語を全て選択:
  `shift + cmd + l`
- コマンドパレット:
  `cmd + shift + p`

### コマンドパレット

`cmd + shift + p` → 以下で検索する

- コンペア:
  `compare`
- 小文字:
  `lowercase`
- 大文字:
  `uppercase`
- キャメルケースに変換:
  `change case camel`

### 検索/置換

[参考](https://khid.net/2019/05/regex-line-contain-string/)

- 文字列を含む行の検索:
  `._文字列._`
- 文字列を含まない行の削除:
  `^(?!._文字列)._\n`

### その他

- 定義箇所にジャンプ:
  - `cmd + click`
  - `F12`
- ジャンプ元に戻る:
  `ctrl + -`

## IntelliJ

[参考](https://speakerdeck.com/yusuke/spring-boot-and-intellij-idea-technique)

- フォーマット:
  `opt + cmd + l`
- 小文字/大文字:
  `cmd + shift + u`
- キャメル/スネーク:
  `cmd + opt + u`
- ジャンプ先から戻る:
  `cmd + [`
- 矩形選択:
  `opt + opt + カーソル`
  （2 回目の opt を押したままカーソルキー)
- テストクラス作成:
  `opt + enter`
- 選択した文字列と同じ文字列を選択:
  `ctrl + g`
- ブレークポイント管理:
  `shift + cmd + f8`
- ファイル検索:
  `shift \* 2`
- クラス名で開く:
  `cmd + o`
- シンボル名で開く:
  `opt + cmd + o`
- ファイル名で開く:
  `shift + cmd + o`
- アクション名で開く:
  `shift + cmd + a`
- プロジェクトペイン:
  `cmd + 1`
- バージョン管理ペイン:
  `cmd + 9`
- エディタペイン:
  `esc`
- 最近のファイル:
  `cmd + e`
- 最近編集したファイル:
  `cmd + e * 2`
- 最近編集した箇所:
  `shift + cmd + e`
- 1 つ前のファイル:
  `ctrl + tab`
- 2 つ前のファイル:
  `ctrl + tab * 2`
- 利用箇所ポップアップ:
  `cmd + b`
- 差分:
  `比較したいファイルを選択 + cmd + d`
- JavaDoc:
  `/** + Enter`
- ソース構造表示:
  `cmd + 7`
- メソッド呼び出し元を表示:
  `opt + F7`
- メソッド呼び出し階層を開く([参考](https://pleiades.io/help/idea/viewing-structure-and-hierarchy-of-the-source-code.html#ws_view_hierarchy)):
  `ctrl + opt + h`
- ファイルの先頭に移動(cursorTop):
  `cmd + fn + ←`
- ファイルの末尾に移動(cursorBottom):
  `cmd + fn + →`
- 次のエラー箇所に移動:
  `F2`

## GoLand

- テストファイル作成:
  `テストファイルを作成したいファイル上で、cmd + Shift + T`
- getter/setter/constructor 自動生成:
  `構造体のフィールド部（小文字で宣言されている必要がある）で、opt + Enter`
- 補完:
  `err.reterr`と入力
