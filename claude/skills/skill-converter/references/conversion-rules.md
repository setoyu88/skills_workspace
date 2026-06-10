# Claude → GitHub Copilot スキル変換ルール

このリポジトリで実際に行われている変換を観察して抽出した規則。`convert_skill.ps1`
が機械的な部分（1〜3）を担い、AI が文脈判断の部分（4〜6）を仕上げる。

## 基本方針：忠実コピー＋最小限の書き換え

挙動を作り変えない。スキルの中身（手順・スクリプト・例）はそのまま移植し、
**置き場所が変わったことに伴うパスと文言だけ** を Copilot 向けに直す。

- フロントマター `name: xs:<skill>` / `description` は **変更しない**（トリガー判定に効くため）
- 機能を表す Claude 固有表現は **温存する**。例: `multi-agent` の「Claude Code のサブエージェント（Agent ツール）」はそのまま（Copilot 側にも対応機能があり、文意が壊れないため作り変えない）

## 1. ディレクトリ丸ごとコピー

`.claude/skills/<name>/` → `.github/skills/<name>/` を再帰コピー。
`SKILL.md` だけでなく `scripts/` `references/` `templates/` `assets/` `README.md`
など全サブディレクトリを含める。`__pycache__` `.venv` `*.pyc` は持ち込まない。

## 2. パス参照の書き換え（テキストファイル全般）

| 変換元 | 変換先 |
|--------|--------|
| `.claude/skills` | `.github/skills` |

対象拡張子: `.md .ps1 .py .txt .yaml .yml .json .toml .js .ts .sh`

### Before / After（実例）

```diff
- New-Item -ItemType Directory -Force "[WORKSPACE]/.claude/skills/<skill-name>"
+ New-Item -ItemType Directory -Force "[WORKSPACE]/.github/skills/<skill-name>"
```

```diff
- pm2 start "cmd /c cd .claude/skills/workspace-rag/scripts && uv run ..." --name workspace-rag
+ pm2 start "cmd /c cd .github/skills/workspace-rag/scripts && uv run ..." --name workspace-rag
```

`[WORKSPACE]` `[SKILL_DIR]` `[NOTES_DIR]` などのプレースホルダはそのまま残す。

## 3. 「自動読み込み」系の文言（主に README）

| 変換元 | 変換先 |
|--------|--------|
| `Claude Code 標準の` | `GitHub Copilot が認識する` |
| `Claude Code が自動的に読み込みます` | `GitHub Copilot が自動的に読み込みます` |
| `Claude Code への接続` | `GitHub Copilot への接続` |

### Before / After（skill-creator の登録手順）

```diff
- スキルは Claude Code 標準の `.claude/skills/` に置く。フォルダを作って `SKILL.md` を置けば自動認識される。
+ スキルは GitHub Copilot が認識する `.github/skills/` に置く。フォルダを作って `SKILL.md` を置けば自動認識される。
```

## 4. README.md（一覧）の追記（AI が実施）

`.github/skills/README.md` のスキル一覧表に、新規スキルの行を追加する。
カテゴリ（検索・思考/分析・記録・コンテンツ生成・システム/メタ）の適切な場所へ。

```markdown
| **skill-converter** | Claudeスキルを Copilot 用に変換 | 「Copilotに変換して」 |
```

## 5. Copilot への接続文言（README 末尾、AI が確認）

`.github/skills/README.md` の接続セクションは Copilot 向けの説明にする。
このリポジトリの既存表現：

> スキルは GitHub Copilot が認識する `.github/skills/` に直接置いています。Copilot
> （VS Code / CLI / cloud agent）は Agent Skills のディレクトリを自動で読み込むため、
> 追加設定は不要です。読み込み場所は `.vscode/settings.json` の
> `chat.agentSkillsLocations` で制御できます。

## 6. .vscode/settings.json の方針（変更しない・確認のみ）

このリポジトリは Claude Code で動いているため、`chat.agentSkillsLocations` は
`.claude/skills` を `true`、`.github/skills` を `false` にして二重検出を防いでいる。
Copilot 単体（`.claude` なし）の環境では `.github/skills` が既定で読まれる。
**設定の変更は依頼がない限り行わない。**

## やらないこと

- 手順やスクリプトのロジックを「Copilot流」に作り変える（忠実コピーが原則）
- フロントマターの name/description を書き換える
- 依頼されていない `.vscode/settings.json` の変更
