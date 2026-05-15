---
name: skill-add
description: "スキルを追加・作成する。外部URLからの取得、既存スキルの導入、新規作成いずれにも対応。「スキル作って」「スキル追加して」「このスキルを入れて」「このスキルいれたい」+URL等と言われたときに使う。"
argument-hint: "[スキルの内容や参照元URL]"
---

# スキル追加

スキルを追加・作成する手順。外部URLからの取得でも新規作成でも、このスキルに従う。

## 手順

### 1. 配置先の判定

文脈から判断できない場合のみユーザーに確認する。

- **プロジェクト固有**（特定プロジェクトでのみ使うスキル） → `.agents/skills/` に作成（手順3へ）
- **ユーザー環境用**（どのプロジェクトでも使うスキル） → 手順2→3→4の順に実行

dotfilesリポジトリでの作業時は、明示的に「プロジェクト固有」と言われない限り**ユーザー環境用**として扱う。

### 命名規約

built-in スキルとの衝突を避けるため、以下のプレフィックスを付ける:

- **プロジェクト固有**: プレフィックスなし。同種スキルが複数ある場合は対象でグルーピング（例: `brew-add`, `brew-sync`）
- **ユーザー環境用**: `my-` プレフィックスを付ける（例: `my-pr-creator`）。自然な名詞形がある場合はそれを維持（`my-create-xxx` より `my-xxx-creator`）

このスキルで導入する場合はファイルをコピー・新規作成するため、ユーザー環境用なら必ず `my-` を付ける。

なお、既存のユーザー環境用スキルで `my-` がついていないものは、APM/npx 等のパッケージマネージャー経由で導入されたもの（アップストリーム名を保持する必要があるため `my-` を付けない）。

### 2. SKILL.md作成

`dot_agents/skills/my-<skill-name>/SKILL.md` に作成する（ユーザー環境用の場合）。プロジェクト固有の場合は `.agents/skills/<skill-name>/SKILL.md` に作成する。

プロジェクト固有スキルは `.claude/skills` が `.agents/skills` へのシンボリックリンクになっている前提で、Codex と Claude Code の両方から同じスキルを参照する。

外部URLが指定された場合は、その内容を取得してSKILL.mdとして配置する。

#### 共通ルール

- スキルは**日本語で作成する**（参照元が英語の場合は日本語に訳す）
- コード例やフィールド名等の技術的な識別子はそのまま残す
- 既存スキル（brew-add, dotfiles-dir-add等）のフォーマットを参考にする

#### Frontmatterの使い分け

- **各エージェント共有スキル**（`dot_agents/skills/`）→ 基本的に [Agent Skills共通仕様](https://agentskills.io/specification) のフィールドを使う。作成前に仕様を読むこと
- **Claude Code固有/プロジェクト固有スキル** → 共通仕様に加え、[Claude Code独自のフィールド](https://code.claude.com/docs/ja/skills) も使用可能。作成前にドキュメントを読むこと

ただし `allowed-tools` のような Claude Code 独自フィールドは、`dot_agents/skills/` 配下でも記述してよい。他 agent では無視されるだけで害はなく、Claude 側の権限管理がスキル単位で完結するメリットが大きいため。

### 3. シンボリックリンク作成（ユーザー環境用の場合のみ）

```bash
ln -s ../../../../../../.agents/skills/my-<skill-name> dot_claude/skills/my-<skill-name>
```

このパスは `~/.claude/skills/` を起点に `~/.agents/skills/` を参照する相対パス。

### 4. .gitignore更新（ユーザー環境用の場合のみ）

既存エントリのフォーマットに合わせて追加する。

**`dot_agents/.gitignore`** に追加:
```
!skills/my-<skill-name>/
!skills/my-<skill-name>/**
```

**`dot_claude/.gitignore`** に追加:
```
!skills/my-<skill-name>
```
