---
name: my-retrospective-codify
description: "タスク完了時に「最初に失敗した内容」と「最終的に通った解法」を対応付け、最初に知っておくべきだった知見を再利用可能な形式（ast-grep ルール / skill / CLAUDE.md ルール / my-agent-memory / takt ワークフロー）に固定する。トリガー: タスク完了直前、「学びを残して」「振り返って」「retrospective」「学びを記録」「次回のために」と言われたとき。試行錯誤を経た解の汎用化に使う。"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls *), Bash(rg *), Bash(git rev-parse *), Bash(basename *), Bash(diff *), Skill(my-agent-memory), Skill(takt-builder), Skill(skill-creator), Skill(skill-add)
---

# Retrospective Codify

試行錯誤の末にたどり着いた解法や、同じ落とし穴を将来に繰り返させたくない場面で、学びを**再現可能な形に固定する**ためのスキル。

参照元: [mizchi/skills retrospective-codify](https://github.com/mizchi/skills/blob/main/retrospective-codify/SKILL-ja.md) を、本環境（dotfiles + my-agent-memory + takt + 命名規約）に合わせて拡張。

## いつ使うか

- タスク完了直前、または「学びを残して」「振り返って」「retrospective」等と指示されたとき
- 試行錯誤を経て解に到達したとき
- 同種のタスクを将来また行う可能性があるとき

**使わない場面:**
- 一発で通った単純なタスク
- プロジェクト固有の一回限りの対応で再利用見込みがないもの

## 出力先カテゴリ（6つ + 何もしない）

| 種別 | 適切なケース | 配置場所 |
|---|---|---|
| **ast-grep ルール** | 構文レベルで機械的に検出可能 | プロジェクトの `sgconfig.yml` / `ast-grep.yml` 等 |
| **CLAUDE.md ルール** | 短く・常時適用・判断不要の指示 | プロジェクト/グローバル CLAUDE.md |
| **新規 skill** | 複数ステップ、文脈判断、テンプレ必要 | `skill-add` スキルに委譲 |
| **既存 skill への追記** | 既存にカバー領域があり、補完で済む | 該当 skill の SKILL.md を編集 |
| **my-agent-memory に保存** | プロジェクト固有の context 復帰情報、再開予定あり | `my-agent-memory` skill が管理（path はそちらの仕様に従う） |
| **takt ワークフロー** | 複数ステップ + マルチエージェント協調が再現価値あり | `<project>/.takt/workflows/` |
| **何もしない** | 1 回限り・汎用性なし | - |

## 処理フロー

### Step 1: 失敗⇄成功の対応付け

各学びについて以下を記述:

```
- 最初の失敗: <試した内容と、なぜ失敗したか>
- 最終解: <最終的に動いた内容>
- 気付き: <最初に知っていれば回避できた知見>
```

複数の学びがあれば、それぞれ独立に整理する。

### Step 2: 知見の言語化

気付きを **1〜3 文の未来指示形** に圧縮する。

- ❌ "X を試したら失敗した"（過去形・状況依存）
- ✅ "X をする前に Y を確認する"（未来指示形・汎用）

### Step 3: 分類判定

各学びを上記カテゴリに割り当てる。判断基準:

- ast-grep で書ける? → **ast-grep ルール**
- 1 行で表現できて常時適用? → **CLAUDE.md ルール**
- 既存 skill にあと一節足せば済む? → **既存 skill への追記**
- 複数ステップ・テンプレ必要? → **新規 skill**
- 特定 PJ の作業文脈、後で再開予定? → **my-agent-memory**
- 複数 agent で再現価値ある複雑なプロセス? → **takt ワークフロー**
- 上記いずれにも当てはまらない? → **何もしない**

### Step 4: 重複チェック（必須）

書き出す前に、既存の同種知見がないか確認する。各学びからキーワードを抽出し、以下のコマンドの `<keyword>` 部分を**実際の検索語に置換**して実行する（リテラル `<keyword>` のまま実行しないこと）。

```bash
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# 既存 skill の確認（user-level + project-level）
ls ~/.agents/skills/ "$PROJECT_ROOT/.claude/skills/" 2>/dev/null
rg -l "<keyword>" ~/.agents/skills/ "$PROJECT_ROOT/.claude/skills/" 2>/dev/null

# CLAUDE.md の確認（重複 path を排除）
for f in "$PROJECT_ROOT/CLAUDE.md" ~/.claude/CLAUDE.md; do
  [[ -f "$f" ]] && rg -l "<keyword>" "$f"
done

# ast-grep ルールの確認（プロジェクトに依存）
find "$PROJECT_ROOT" -maxdepth 3 -name "sgconfig.y*ml" -o -name "ast-grep.y*ml" 2>/dev/null
ls "$PROJECT_ROOT/.ast-grep/" "$PROJECT_ROOT/ast-grep/" 2>/dev/null

# my-agent-memory の確認
ls ~/.agents/skills/my-agent-memory/memories/$PROJECT/ 2>/dev/null
rg "^summary:.*<keyword>" ~/.agents/skills/my-agent-memory/memories/$PROJECT/ --hidden 2>/dev/null

# takt ワークフローの確認
ls "$PROJECT_ROOT/.takt/workflows/" 2>/dev/null
```

既存にカバー済みの内容があれば、**新規作成せず既存への追記**を提案する。

### Step 5: 配置先の決定（skill 化の場合）

新規 skill を作る場合、`skill-add` スキルの規約に従う:

- **プロジェクト固有**: `<project>/.claude/skills/<name>/SKILL.md`（プレフィックスなし、グルーピング推奨）
- **ユーザー環境用**: `~/.agents/skills/my-<name>/SKILL.md`（`my-` プレフィックス、シンボリック張り、gitignore 更新）

判断できない場合はユーザーに確認する。

### Step 6: ユーザーへの提示

以下のフォーマットで、書き出す前に必ず承認を求める。

```
## Retrospective

### 学び 1: <短いラベル>
- 最初の失敗: <内容>
- 最終解: <内容>
- 気付き: <未来指示形 1〜3 文>

### 学び 2: ...

## 提案

| 学び | 採用候補 | 配置先 | 重複検出 |
|------|---------|--------|---------|
| 1 | ast-grep ルール | `sgconfig.yml` | なし |
| 2 | CLAUDE.md ルール | `~/.claude/CLAUDE.md` | 既存 X 行と類似（追記提案） |
| 3 | my-agent-memory | `memories/<project>/category/` | なし |
| 4 | 何もしない | - | プロジェクト固有・1 回限り |

## 書き出し内容（承認待ち）

<diff 形式で各 artifact を表示>
```

**ハードストップ**: ここでユーザーの応答を必ず待つ。承認語（「OK」「進めて」「採用」「書いて」「コミット」等）が明示されない限り、Step 7 へ進んではならない。「いい感じ」のような曖昧な肯定では進まず、どの項目を採用するか確認する。

### Step 7: 承認後の書き出し

ユーザーが採用すると言った項目のみ書き出す。**黙って更新しない**。

書き出し方法は配置先カテゴリに応じて以下を使う:

- **ast-grep ルール**: 該当 config ファイル（`sgconfig.yml` 等）に Edit で追記
- **CLAUDE.md ルール**: 該当 CLAUDE.md の適切なセクションに Edit で追記
- **新規 skill**: `skill-creator` skill を Skill ツールで呼び出す（user-level、全環境で利用可能）。dotfiles リポジトリで作業中の場合は project 固有の `skill-add` skill を優先（命名規約・シンボリック・gitignore まで自動処理）
- **既存 skill への追記**: 該当 SKILL.md を直接 Edit
- **my-agent-memory に保存**: `my-agent-memory` skill を Skill ツールで呼び出す（プロジェクト名取得・frontmatter 規約・ディレクトリ構造はそちらに従う。直接 Write しない）
- **takt ワークフロー**: `takt-builder` skill を Skill ツールで呼び出す（ワークフロー YAML / ファセットの設計はそちらに従う）

書き出し後、何を作成/更新したかを最終報告する。

## ガイドライン

1. **未来指示形を徹底**: "次は X しろ" 形式。"X だった"はメモ、ルールにならない
2. **過剰書き出しを避ける**: 1 タスクで 5 件以上書き出すなら粒度が細かすぎる可能性。統合する
3. **抽象化しすぎない**: 抽象的すぎるルールは適用判断ができない。具体的トリガーと条件を含める
4. **重複チェックを省略しない**: 同じ知見が複数箇所に分散すると、どれが正かわからなくなる
5. **承認なしの書き込み禁止**: 必ず diff を見せて承認を得る

## 例: 各カテゴリの典型例

### ast-grep ルール（構文検出）

```yaml
# 「Promise を await し忘れる」を検出
id: no-floating-promise
language: typescript
rule:
  pattern: $FUNC()
  inside:
    pattern: async function $$ { $$ }
  not:
    has:
      pattern: await $FUNC()
```

### CLAUDE.md ルール（短く常時適用）

```md
- TypeScript のクラスは可能な限り `readonly` プロパティで宣言する
```

### my-agent-memory（PJ 固有 context）

```yaml
---
summary: "API 側のカプセル化方針: 関数型構成のため class 不採用、validation を境界で実施"
created: 2026-05-09
status: resolved
tags: [api, architecture]
related:
  - apps/api/src/features/tasks/service.ts
---

# 結論
... 詳細
```

### 既存 skill への追記

該当 skill の SKILL.md の "ガイドライン" や "FAQ" 等のセクションに 1 項目追加する。

## References

- [ast-grep documentation](https://ast-grep.github.io/) — ast-grep ルールの書き方、pattern syntax、rule config
- [Claude Code Skills](https://code.claude.com/docs/ja/skills) — skill 作成時のフィールド仕様
- [Agent Skills Specification](https://agentskills.io/specification) — クロスエージェント共通の skill 仕様
