---
name: xs:skill-importer
description: GitHub Copilot 用スキル（.github/skills）を Claude Code 用（.claude/skills）に変換するスキル。スキルディレクトリを丸ごと移植し、パス参照と自動読み込み文言を Claude 向けに書き換える。「Claude用に変換して」「Copilotスキルを取り込んで」「.claude/skillsに変換」「copilotスキルをclaude化」で使用。
---

# スキルインポーター（GitHub Copilot → Claude）

`.github/skills/<name>/` のスキルを `.claude/skills/<name>/` へ忠実に移植し、
配置場所の変更に伴うパスと文言だけを Claude 向けに直す。`skill-converter` の逆方向。

## 変換の方針

挙動は作り変えない。中身（手順・スクリプト・例）はそのまま移し、**置き場所が
変わったことに伴う差分だけ** を直す。だから移植先でも元と同じように動く。

- フロントマター `name` / `description` は変更しない（トリガー判定に効くため）
- 機能を表す Copilot 固有表現は温存する（文意が壊れず Claude 側にも対応機能があるため）

詳細な変換ルールと Before/After 実例は [`references/conversion-rules.md`](references/conversion-rules.md) を参照。

## 手順

### Step 1: 対象の確認

変換するスキル名をユーザーに確認する（「どのスキルを変換する？」）。
「全部」なら `-All`。変換元の一覧は次で確認できる：

```powershell
Get-ChildItem .github/skills -Directory | Select-Object Name
```

### Step 2: スクリプトで変換（機械的な部分）

ワークスペースルートで実行する。ディレクトリ丸ごとコピー＋パス/文言の書き換えまでを行う（冪等）。

```powershell
# 単体
pwsh .github/skills/skill-importer/scripts/convert_skill.ps1 -Name <skill-name>

# 全スキル
pwsh .github/skills/skill-importer/scripts/convert_skill.ps1 -All

# 先に内容を見たいだけ（コピーしない）
pwsh .github/skills/skill-importer/scripts/convert_skill.ps1 -Name <skill-name> -WhatIf
```

スクリプトが行うこと：

| やること | 内容 |
|----------|------|
| コピー | `SKILL.md` / `scripts` / `references` / `templates` / `README` を再帰コピー（`__pycache__` `.venv` `*.pyc` は除外） |
| パス置換 | `.github/skills` → `.claude/skills` |
| 文言置換 | 「GitHub Copilot が認識する」→「Claude Code 標準の」等 |

実行後、`'Copilot' を含む（要レビュー候補）` として挙がったファイルを確認する。
多くは機能説明なので温存でよい（Step 4 で判断）。

### Step 3: README 一覧に追記

`.claude/skills/README.md` のスキル一覧表へ、変換したスキルの行を適切なカテゴリに追加する。

```markdown
| **<skill-name>** | <一行説明> | 「<トリガー>」 |
```

### Step 4: 仕上げレビュー（文脈判断）

スクリプトが挙げた「Copilot を含むファイル」を確認し、次を判断する：

- **機能の説明** → 温存
- **配置・自動読み込みの説明** → Claude 表現に直す（README の接続セクションなど）

迷ったら [`references/conversion-rules.md`](references/conversion-rules.md) の Before/After に照合する。

### Step 5: 完了報告

```
変換完了：<skill-name>
.claude/skills/<skill-name>/
- SKILL.md（パス N 箇所を置換）
- scripts/ references/ など同梱物もコピー済み
README.md の一覧に追記済み。
```

## 注意

- `.vscode/settings.json` の `chat.agentSkillsLocations` は依頼がない限り変更しない（このリポジトリは二重検出を避けるため `.github/skills` を `false` にしている）
- フロントマターと機能ロジックは書き換えない（忠実コピーが原則）
- 逆方向（Claude → Copilot）は `xs:skill-converter`（`.claude/skills` 側）

## 使用例

```
note-taking スキルを Claude 用に変換して
Copilotのスキルを全部 .claude/skills に取り込んで
arxiv を claude 化して（まず WhatIf で中身見せて）
```
