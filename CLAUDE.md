# CLAUDE.md

macOS用dotfiles管理リポジトリ。コマンドは `Makefile` を参照。

## 管理ルール

### dot_プレフィクス命名規則

- `dot_` プレフィクス付きファイル/ディレクトリは、ホームディレクトリの `.` に対応する（例: `dot_zshrc` → `~/.zshrc`）
- **dot_プレフィクスのファイルやディレクトリ内のファイルはすべてグローバル設定**であり、このプロジェクト固有の設定ではない
  - 例: `dot_claude/settings.json` は `~/.claude/settings.json`（グローバル設定）であり、プロジェクト設定ではない
- このプロジェクト自体の設定ファイル（`.claude/` 等）はプレフィクスなしでそのまま配置する

### シンボリックリンク方式

`install.sh` がdotfilesをホームディレクトリにシンボリックリンクとして配置する。2つの方式がある：

1. **個別ファイル**: `dot_zshrc` → `~/.zshrc` のように個別にリンク
2. **ディレクトリごと**: `dot_ssh` → `~/.ssh` のようにディレクトリ単位でリンク。この場合、ディレクトリ内に `.gitignore` を置き、許可リスト方式（`*` で全除外後、`!` で管理対象のみ許可）で管理対象を制御する（`dot_claude/.gitignore` が参考例）

### dotfileの更新手順

1. 対象のdotfileを直接編集してコミット
2. Homebrewパッケージの追加は `/brew-add`、外部での変更反映は `/brew-sync` を使う

## サプライチェーン対策

各ツールの cooldown 設定状況は [SUPPLY_CHAIN.md](./SUPPLY_CHAIN.md) を参照。

- **`npx skills update` を勝手に実行しない**。skills は cooldown 機能を持たず、SKILL.md は LLM への命令そのもの（prompt injection リスクが直接効く）。実行前に必ずユーザーに確認し、対象 skill のソースリポジトリの最近のコミット差分を提示してから判断を仰ぐこと。
- `brew upgrade` をリリース直後に即時実行しない。新規 `brew install` 時は `brew info <name>` で更新日時を確認する。
- uv / mise は cooldown が設定済み。値を変更する際は SUPPLY_CHAIN.md の「値の根拠」「書式の落とし穴」を確認してから編集する。
