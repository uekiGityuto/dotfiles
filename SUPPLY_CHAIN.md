# サプライチェーン対策

グローバルにインストールしているパッケージ/ツールごとの対策状況。
cooldown（公開からの最小経過時間）を設定できるものは設定し、できないものはアップデート時に手動で慎重に判断する。

## 対策済み（cooldown 設定あり）

| ツール | 設定値 | 設定ファイル |
| --- | --- | --- |
| uv（`uv tool` / `uv pip`） | `exclude-newer = "2 days"` | `dot_config/uv/uv.toml` |
| mise | `minimum_release_age = "2d"` | `dot_config/mise/config.toml` |

### 値の根拠

- **2日**: 主要な supply chain 攻撃の多くは公開後 1〜2 週間以内に検知・対応される。CLI 系ツールで cooldown を長く取りすぎるとセキュリティ修正の取り込みが遅れて逆効果なので、攻撃の即日波を弾く目的で 2日に設定。
- mise のデフォルト（24h）より少しだけ保守側。

### 書式の落とし穴

| ツール | 2日の書き方 |
| --- | --- |
| uv | `"2 days"`（フル表記）または `"P2D"`（ISO 8601）。`"2d"` は **NG** |
| mise | `"2d"`（短縮形）。`"2 days"` は **NG** |
| pnpm（参考） | `2880`（分単位の数値） |

## 未対策（手動で慎重に）

### Homebrew

- エンドユーザー側 cooldown 機能なし。Homebrew は formula 取り込み側で cooldown を吸収する方針（[公式ドキュメント](https://docs.brew.sh/Supply-Chain-Security)）。
- 運用:
  - `brew upgrade` を新リリース直後に即時実行しない。
  - 新規 `brew install` 時は `brew info <name>` で更新日時を一度確認する。

### npx skills（`npx skills update`）

- バージョン概念がなく、`skills-lock.json` の GitHub tree SHA を最新に追従するだけ。cooldown 機能なし。
- SKILL.md の中身は LLM への命令そのものなので、悪意ある変更は **prompt injection として直接効く**。Homebrew や uv より慎重に扱う。
- 運用:
  - `npx skills update` を無条件で実行しない。
  - 実行前にソースリポジトリの最近のコミット差分を必ず確認する。
  - 不要な skill は事前に外しておく。

### pnpm（グローバル）

- グローバルなパッケージとしては使わない方針のため、グローバル設定はしない。
- 必要になったら `~/Library/Preferences/pnpm/config.yaml` に `minimumReleaseAge: 2880`（分単位）を書く。
