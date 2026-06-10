---
name: xs:skill-converter
description: Claude Code 用スキル（.claude/skills）を GitHub Copilot 用（.github/skills）に変換するスキル。スキルディレクトリを丸ごと移植し、パス参照と自動読み込み文言を Copilot 向けに書き換える。「Copilot用に変換して」「スキルをCopilotに移植」「.github/skillsに変換」「claudeスキルをcopilot化」で使用。
---

# スキルコンバーター（Claude → GitHub Copilot）

`.claude/skills/<name>/` のスキルを `.github/skills/<name>/` へ忠実に移植し、
配置場所の変更に伴うパスと文言だけを Copilot 向けに直す。

## 変換の方針

挙動は作り変えない。中身（手順・スクリプト・例）はそのまま移し、**置き場所が
変わったことに伴う差分だけ** を直す。だから移植先でも元と同じように動く。

- フロントマター `name` / `description` は変更しない（トリガー判定に効くため）
- 機能を表す Claude 固有表現は温存する（例: `multi-agent` の「Agent ツール」はそのまま。文意が壊れず Copilot 側にも対応機能があるため）

詳細な変換ルールと Before/After 実例は [`references/conversion-rules.md`](references/conversion-rules.md) を参照。

## 手順

### Step 1: 対象の確認

変換するスキル名をユーザーに確認する（「どのスキルを変換する？」）。
「全部」なら `-All`。変換元の一覧は次で確認できる：

```powershell
Get-ChildItem .claude/skills -Directory | Select-Object Name
```

### Step 2: スクリプトで変換（機械的な部分）

ワークスペースルートで実行する。ディレクトリ丸ごとコピー＋パス/文言の書き換えまでを行う（冪等）。

```powershell
# 単体
pwsh .claude/skills/skill-converter/scripts/convert_skill.ps1 -Name <skill-name>

# 全スキル
pwsh .claude/skills/skill-converter/scripts/convert_skill.ps1 -All

# 先に内容を見たいだけ（コピーしない）
pwsh .claude/skills/skill-converter/scripts/convert_skill.ps1 -Name <skill-name> -WhatIf
```

スクリプトが行うこと：

| やること | 内容 |
|----------|------|
| コピー | `SKILL.md` / `scripts` / `references` / `templates` / `README` を再帰コピー（`__pycache__` `.venv` `*.pyc` は除外） |
| パス置換 | `.claude/skills` → `.github/skills` |
| 文言置換 | 「Claude Code 標準の」→「GitHub Copilot が認識する」等 |

実行後、`'Claude' を含む（要レビュー候補）` として挙がったファイルを確認する。
多くは `multi-agent` のように機能説明なので温存でよい（Step 4 で判断）。

### Step 3: README 一覧に追記

`.github/skills/README.md` のスキル一覧表へ、変換したスキルの行を適切なカテゴリに追加する。

```markdown
| **<skill-name>** | <一行説明> | 「<トリガー>」 |
```

### Step 4: 仕上げレビュー（文脈判断）

スクリプトが挙げた「Claude を含むファイル」を確認し、次を判断する：

- **機能の説明** → 温存（例: 「Claude Code のサブエージェント」はそのまま）
- **配置・自動読み込みの説明** → Copilot 表現に直す（README の接続セクションなど）

迷ったら [`references/conversion-rules.md`](references/conversion-rules.md) の Before/After に照合する。

### Step 5: 完了報告

```
変換完了：<skill-name>
.github/skills/<skill-name>/
- SKILL.md（パス N 箇所を置換）
- scripts/ references/ など同梱物もコピー済み
README.md の一覧に追記済み。
```

## 注意

- `.vscode/settings.json` の `chat.agentSkillsLocations` は依頼がない限り変更しない（このリポジトリは二重検出を避けるため `.github/skills` を `false` にしている）
- フロントマターと機能ロジックは書き換えない（忠実コピーが原則）
- 関連スキル: 新規作成は [[xs:skill-creator]]

## 使用例

```
note-taking スキルを Copilot 用に変換して
全スキルを .github/skills に移植して
arxiv を copilot 化して（まず WhatIf で中身見せて）
```
