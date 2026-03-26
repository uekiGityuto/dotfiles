---
name: codex
description: >-
  Codex CLIに第三者レビューまたは相談を依頼する。
  トリガー: 「Codexにレビューさせて」「Codexに聞いて」「Codexにも相談して」「別の視点が欲しい」「第三者レビュー」「Codexと議論して」
  使用場面: (1) 実装後のコードレビュー、(2) 設計・方針の相談、(3) Claude の回答が微妙な時のセカンドオピニオン、(4) 議論・ディベート
user-invocable: true
argument-hint: "[レビュー対象やCodexへの相談内容]"
allowed-tools: Bash(codex *), Read, Write(/tmp/claude/codex_*), Glob, Grep
---

あなたは、Claude Code で進めている作業について、Codex に第三者レビューまたは相談を依頼し、その結果を受けてユーザーに報告・対応する役割を担う。

**依頼文を作って終わりにしてはいけない。必ず Codex を実行し、結果をユーザーに届けること。**

---

## モードの判定

ユーザーの意図からモードを判断する。

- **レビューモード**（デフォルト）: Codex に一方向でレビューを依頼し、Claude が結果を評価して報告する。妥当な指摘があれば Claude 自身が修正対応まで行う。
- **相談モード**: ユーザーが「Codexにも聞いて」「相談して」と言った場合。ユーザーの相談内容をCodexに転送し、結果を報告する。
- **議論モード**: ユーザーが「議論して」「反論して」「ディベートして」と言った場合。Claude が自分の立場を明確にし、Codex と往復議論を行う（最大3ラウンド）。

---

## レビューモード

### Step 1: 情報の整理

以下を整理する。わからないものは省略してよい。

- **objective**: このレビューで確認したいこと
- **established_facts**: 確認済みの事実（コード、ログ等）
- **claude_proposal**: Claude が提案・実施した内容（事実と仮説を分けて）
- **diff_summary**: 変更差分の要点（関連ファイル名も）
- **questions_for_codex**: Codex への具体的な質問（3〜5個、「〜の場合、〜はリスクになりますか？」の形式）

### Step 2: Codex の実行

1. Write tool で `/tmp/claude/codex_prompt.txt` にプロンプトを書き出す：

```
# Review Request

## Objective
{objective}

## Established Facts
{established_facts}

## Claude's Proposal
{claude_proposal}

## Diff Summary
{diff_summary}

## Questions
{questions_for_codex}

## Instructions
Review this as a third-party reviewer, not as an implementer.
Do not assume Claude's proposal is correct.
Return your answer in this structure:
1. Conclusion
2. Valid Points
3. Concerns
4. Alternatives
5. Recommended Actions
```

2. Bash で実行：

```bash
codex exec --ephemeral -o /tmp/claude/codex_result.txt - < /tmp/claude/codex_prompt.txt
```

3. Read tool で `/tmp/claude/codex_result.txt` を読み取る。

- `--ephemeral`: セッション保存しない
- `-o /tmp/claude/codex_result.txt`: 最終回答をファイル出力（出力が長くても確実に取得）
- カレントディレクトリはプロジェクトルートであること

### Step 3: 結果の評価と報告

Codex の回答を取得したら：

1. 以下の形式でユーザーに報告する：

```
## Codex レビュー結果

### 総評
[Conclusion]

### 妥当な指摘
[Valid Points]

### 懸念事項
[Concerns]

### 代替案
[Alternatives]

### 推奨アクション
[Recommended Actions]

---
**Claude のコメント:** [Codex の回答に対する同意点・異論・補足を簡潔に]
```

2. **妥当な指摘があれば、ユーザーに確認の上で修正対応を行う。**

---

## 相談モード

ユーザーの相談内容をそのまま Codex に転送する。

### Step 1: Codex の実行

1. Write tool で `/tmp/claude/codex_prompt.txt` にプロンプトを書き出す：

```
{ユーザーの相談内容をそのまま、または要点を整理して記載}

Provide a concrete answer with specific examples or code if applicable.
```

2. Bash で実行：

```bash
codex exec --ephemeral -o /tmp/claude/codex_result.txt - < /tmp/claude/codex_prompt.txt
```

3. Read tool で `/tmp/claude/codex_result.txt` を読み取る。

### Step 2: 報告

```
## Codex の回答

{Codex の回答}

---
**Claude のコメント:** [Codex の回答に対する補足・同意・異論があれば簡潔に]
```

---

## 議論モード

### Phase 0: Claude の立場を表明

Codex に送る前に、Claude 自身の見解をユーザーに示す。

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Claude の立場】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**論点:** [1文で]
**Claude の見解:** [明確に]
**根拠:** [具体的なエビデンス]
**留保事項:** [不確かな部分]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase 1: Codex へ送信

依頼文に Claude の立場を追加して送信する。

1. Write tool で `/tmp/claude/codex_prompt.txt` にプロンプトを書き出す：

```
{依頼文}

## Claude's Position (for debate)
Claude has the following view:
{Claude の見解と根拠}

Evaluate Claude's position directly. State clearly where you agree and disagree, with specific reasons. Be direct.
```

2. Bash で実行：

```bash
codex exec --ephemeral -o /tmp/claude/codex_debate.txt - < /tmp/claude/codex_prompt.txt
```

3. Read tool で `/tmp/claude/codex_debate.txt` を読み取り、Codex の回答を**全文そのまま**表示する。

### Phase 2: Claude の評価

Codex の回答を読み評価する：

- **同意する点** — 具体的に、なぜ同意するか
- **反論したい点** — 根拠付きで
- **見落としを認める点** — 正直に

反論がある場合は次ラウンドへ。なければまとめへ。

### Phase 3: 追加ラウンド（最大3ラウンド）

反論を Codex に送り、回答を得て再評価する。3ラウンドまたは合意に至った時点でまとめに移る。

### まとめ

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【議論のまとめ】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**合意点:** [両者が一致した点]
**相違点:** [見解が分かれた点と各自の理由]
**ユーザーへの推奨:** [判断材料の整理]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 議論のルール

- 事実・コードに基づいて反論する
- 間違いは素直に認める
- 断定と推測を明示的に区別する

---

## 注意事項

- **必ず Codex を実行すること** — 依頼文を生成して終わりにしない
- **Codex に実装させない** — あくまでレビュアー・相談相手として扱う
- **会話全文をそのまま貼らない** — 要点を圧縮して送る
- **質問は具体的に** — 「どう思いますか？」ではなく「〜の場合、〜はリスクになりますか？」
