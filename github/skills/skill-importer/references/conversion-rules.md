# GitHub Copilot → Claude スキル変換ルール

`skill-converter`（Claude→Copilot）の逆方向。`convert_skill.ps1` が機械的な部分
（1〜3）を担い、AI が文脈判断の部分（4〜6）を仕上げる。

## 基本方針：忠実コピー＋最小限の書き換え

挙動を作り変えない。スキルの中身（手順・スクリプト・例）はそのまま移植し、
**置き場所が変わったことに伴うパスと文言だけ** を Claude 向けに直す。

- フロントマター `name: xs:<skill>` / `description` は **変更しない**（トリガー判定に効くため）
- 機能を表す Copilot 固有表現は **温存する**（文意が壊れず Claude 側にも対応機能があるため）

## 1. ディレクトリ丸ごとコピー

`.github/skills/<name>/` → `.claude/skills/<name>/` を再帰コピー。
`SKILL.md` だけでなく `scripts/` `references/` `templates/` `assets/` `README.md`
など全サブディレクトリを含める。`__pycache__` `.venv` `*.pyc` は持ち込まない。

## 2. パス参照の書き換え（テキストファイル全般）

| 変換元 | 変換先 |
|--------|--------|
| `.github/skills` | `.claude/skills` |

対象拡張子: `.md .ps1 .py .txt .yaml .yml .json .toml .js .ts .sh`

### Before / After（実例）

```diff
- New-Item -ItemType Directory -Force "[WORKSPACE]/.github/skills/<skill-name>"
+ New-Item -ItemType Directory -Force "[WORKSPACE]/.claude/skills/<skill-name>"
```

`[WORKSPACE]` `[SKILL_DIR]` `[NOTES_DIR]` などのプレースホルダはそのまま残す。

## 3. 「自動読み込み」系の文言（主に README）

| 変換元 | 変換先 |
|--------|--------|
| `GitHub Copilot が認識する` | `Claude Code 標準の` |
| `GitHub Copilot が自動的に読み込みます` | `Claude Code が自動的に読み込みます` |
| `GitHub Copilot への接続` | `Claude Code への接続` |

### Before / After

```diff
- スキルは GitHub Copilot が認識する `.github/skills/` に置く。フォルダを作って `SKILL.md` を置けば自動認識される。
+ スキルは Claude Code 標準の `.claude/skills/` に置く。フォルダを作って `SKILL.md` を置けば自動認識される。
```

## 4. README.md（一覧）の追記（AI が実施）

`.claude/skills/README.md` のスキル一覧表に、新規スキルの行を追加する。
カテゴリ（検索・思考/分析・記録・コンテンツ生成・システム/メタ）の適切な場所へ。

## 5. Claude Code への接続文言（README 末尾、AI が確認）

`.claude/skills/README.md` の接続セクションは Claude Code 向けの説明にする。
このリポジトリの既存表現：

> スキルは Claude Code 標準の配置先である `.claude/skills/` に直接置いています。
> Claude Code はこのディレクトリを自動で読み込むため、追加設定は不要です。

## 6. .vscode/settings.json の方針（変更しない・確認のみ）

このリポジトリは Claude Code で動いているため、`chat.agentSkillsLocations` は
`.claude/skills` を `true`、`.github/skills` を `false` にして二重検出を防いでいる。
**設定の変更は依頼がない限り行わない。**

## やらないこと

- 手順やスクリプトのロジックを「Claude流」に作り変える（忠実コピーが原則）
- フロントマターの name/description を書き換える
- 依頼されていない `.vscode/settings.json` の変更
