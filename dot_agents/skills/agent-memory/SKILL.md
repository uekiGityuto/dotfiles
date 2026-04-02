---
name: agent-memory
description: "ユーザーが記憶の保存・呼び出し・整理を求めたときに使う。トリガー: 「記憶して」「保存して」「メモして」「前に何を話した？」「メモ確認して」「メモリ整理して」。また、保存する価値のある発見をしたときにも積極的に使う。"
---

# Agent Memory

会話をまたいで永続する知識の保存領域。

**保存先:** `.claude/skills/agent-memory/memories/`

## 積極的な活用

保存する価値のある発見をしたときにメモリに保存する：
- 調査に労力を要したリサーチ結果
- コードベースの非自明なパターンやハマりどころ
- 厄介な問題の解決策
- アーキテクチャ上の決定とその理由
- 後で再開する可能性のある作業中の内容

関連する作業を始めるときにメモリを確認する：
- 問題のある領域を調査する前
- 以前触ったことのある機能に取り組むとき
- 会話が途切れた後に作業を再開するとき

必要に応じてメモリを整理する：
- 同じトピックに関する散在したメモリを統合する
- 古くなった・置き換えられた情報を削除する
- 作業が完了・ブロック・放棄されたらstatusフィールドを更新する

## フォルダ構造

可能な限り、カテゴリフォルダに整理する。事前定義された構造はなく、内容に合ったカテゴリを自由に作成する。

ガイドライン：
- フォルダ名・ファイル名はkebab-caseを使用
- 知識ベースの成長に合わせて統合・再編成する

例：
```text
memories/
├── file-processing/
│   └── large-file-memory-issue.md
├── dependencies/
│   └── iconv-esm-problem.md
└── project-context/
    └── december-2025-work.md
```

これは一例。実際の内容に基づいて自由に構造化すること。

## Frontmatter

すべてのメモリにはfrontmatterと `summary` フィールドが必須。summaryは全文を読むかどうかの判断材料になる程度に簡潔に書く。

**summaryが判断基準**: エージェントは `rg "^summary:"` でsummaryをスキャンし、全文を読むかどうか判断する。この判断に十分な文脈（何についてのメモリか、主要な問題やトピック、なぜ重要か）をsummaryに含めること。

**必須:**
```yaml
---
summary: "このメモリの内容を1-2行で説明"
created: 2025-01-15  # YYYY-MM-DD形式
---
```

**任意:**
```yaml
---
summary: "大規模ファイル処理時のワーカースレッドメモリリーク - 原因と解決策"
created: 2025-01-15
updated: 2025-01-20
status: in-progress  # in-progress | resolved | blocked | abandoned
tags: [performance, worker, memory-leak]
related: [src/core/file/fileProcessor.ts]
---
```

## 検索ワークフロー

summary優先アプローチで効率的に関連メモリを検索する：

```bash
# 1. カテゴリ一覧
ls .claude/skills/agent-memory/memories/

# 2. 全summaryを表示
rg "^summary:" .claude/skills/agent-memory/memories/ --no-ignore --hidden

# 3. キーワードでsummaryを検索
rg "^summary:.*keyword" .claude/skills/agent-memory/memories/ --no-ignore --hidden -i

# 4. タグで検索
rg "^tags:.*keyword" .claude/skills/agent-memory/memories/ --no-ignore --hidden -i

# 5. 全文検索（summary検索で不十分な場合）
rg "keyword" .claude/skills/agent-memory/memories/ --no-ignore --hidden -i

# 6. 関連するメモリファイルを読む
```

**注意:** メモリファイルはgitignoreされているため、ripgrepで `--no-ignore` と `--hidden` フラグを使用すること。

## 操作

### 保存

1. 内容に適したカテゴリを決定する
2. 既存のカテゴリが適合するか確認し、なければ新規作成
3. 必須のfrontmatter付きでファイルを作成する（`date +%Y-%m-%d` で現在日付を取得）

```bash
mkdir -p .claude/skills/agent-memory/memories/category-name/
# 注意: 上書きを避けるため、書き込む前にファイルの存在を確認すること
cat > .claude/skills/agent-memory/memories/category-name/filename.md << 'EOF'
---
summary: "このメモリの簡潔な説明"
created: 2025-01-15
---

# タイトル

内容...
EOF
```

### メンテナンス

- **更新**: 情報が変わったら内容を更新し、frontmatterに `updated` フィールドを追加
- **削除**: もう関連性のないメモリを削除
  ```bash
  trash .claude/skills/agent-memory/memories/category-name/filename.md
  # 空のカテゴリフォルダを削除
  rmdir .claude/skills/agent-memory/memories/category-name/ 2>/dev/null || true
  ```
- **統合**: 関連するメモリが増えたらマージする
- **再編成**: 知識ベースの成長に合わせて、より適切なカテゴリにメモリを移動する

## ガイドライン

1. **再開を前提に書く**: メモリは後で作業を再開するために存在する。文脈を失わずに続行するために必要なすべてのポイント（決定事項、理由、現在の状態、次のステップ）を記録する
2. **自己完結したノートを書く**: 読者が事前知識なしに内容を理解し行動できるよう、完全な文脈を含める
3. **summaryは決定的に書く**: summaryを読めば詳細が必要かどうか判断できるようにする
4. **最新に保つ**: 古くなった情報は更新または削除する
5. **実用的に**: すべてではなく、実際に役立つものだけを保存する

## 内容のリファレンス

詳細なメモリを書くときに含めることを検討する項目：
- **文脈**: 目標、背景、制約
- **状態**: 完了したこと、進行中のこと、ブロックされていること
- **詳細**: 主要なファイル、コマンド、コードスニペット
- **次のステップ**: 次にやること、未解決の質問

すべてのメモリにすべてのセクションが必要なわけではない。関連するものだけ使うこと。
