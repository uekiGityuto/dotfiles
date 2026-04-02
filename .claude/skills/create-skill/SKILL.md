---
name: create-skill
description: "新しいスキルを作成する。「スキル作って」「スキル追加して」「このスキルを入れて」等と言われたときに使う。"
argument-hint: "[スキルの内容や参照元URL]"
---

# スキル作成

新しいスキルを作成する手順。

## 手順

### 1. 配置先の判定

ユーザーに以下を順番に確認する。

**Q1: ユーザー環境用か、プロジェクト固有か？**

- **プロジェクト固有** → `.claude/skills/` に作成（手順3へ）
- **ユーザー環境用** → Q2へ

**Q2: 各エージェント共有か、Claude Code固有か？**

- **各エージェント共有** → `dot_agents/skills/` に本体を作成し、`dot_claude/skills/` にシンボリックリンクを貼る（手順2→3へ）
- **Claude Code固有** → `dot_claude/skills/` のみに作成（手順3へ）

### 2. シンボリックリンク（各エージェント共有の場合のみ）

```bash
ln -s ../../../../../../.agents/skills/<skill-name> dot_claude/skills/<skill-name>
```

このパスは `~/.claude/skills/` を起点に `~/.agents/skills/` を参照する相対パス。

`dot_agents/.gitignore` と `dot_claude/.gitignore` にgit管理対象として追加する。

### 3. SKILL.md作成

#### 共通ルール

- スキルは**日本語で作成する**（参照元が英語の場合は日本語に訳す）
- コード例やフィールド名等の技術的な識別子はそのまま残す
- 既存スキル（brew-add, dotfiles-add-dir等）のフォーマットを参考にする

#### Frontmatterの使い分け

- **各エージェント共有スキル**（`dot_agents/skills/`）→ [Agent Skills共通仕様](https://agentskills.io/specification) のフィールドのみ使用する。作成前に仕様を読むこと
- **Claude Code固有/プロジェクト固有スキル** → 共通仕様に加え、[Claude Code独自のフィールド](https://code.claude.com/docs/ja/skills) も使用可能。作成前にドキュメントを読むこと
