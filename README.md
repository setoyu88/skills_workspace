# ai-assistant-workspace

あなた専用のAIアシスタント・ワークスペースです。

**[Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) と [GitHub Copilot](https://docs.github.com/copilot) の両対応**スターターキットです。スキル（拡張機能）を通じて、調査・メモ・資料作成などの日常タスクを効率化します。

行動ルールと同じスキルセットを2つのツールで共有します。

- **Claude Code** — `CLAUDE.md`（設定の実体）+ `.claude/skills/`（スキル）
- **GitHub Copilot** — `.github/copilot-instructions.md`（`CLAUDE.md` を Copilot 向けに翻訳）+ `.github/skills/`（Agent Skills）

## できること

- **ワークスペース検索** — ファイルをベクトル検索で横断検索（workspace-rag）
- **メモ管理** — 調査結果・アイデア・会議メモを整理して保存
- **アイデア発想** — ワークスペース内の遠い知識をつないで企画を出す（bridge-ideas）
- **マルチエージェント協調** — Claude Code のサブエージェントを並行起動して多角的に分析・レビュー（multi-agent）
- **コードレビュー** — GitHub PRを体系的にレビュー（任意でサブエージェント検証）
- **arXiv論文調査** — 論文検索・トレンド発見・詳細分析を統合的に実行
- **プレゼン作成** — マークダウンからスライドを生成（Marp）
- **図表生成** — フローチャート・アーキテクチャ図を自動生成（Pillow / Mermaid / PlantUML）
- **音声文字起こし** — 音声ファイルをテキストに変換（Whisper）
- **テックニュース** — 最新のAI・技術ニュースを収集・紹介
- **スキル作成** — 自分だけのカスタムスキルを作る

## クイックスタート

### 必要なもの

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) または [GitHub Copilot](https://docs.github.com/copilot)（VS Code 等）

### セットアップ手順

```powershell
# 1. リポジトリをクローン
git clone <このリポジトリのURL>
cd ai-assistant-workspace

# 2. Claude Code を起動（スキルは .claude/skills/ に同梱済み）
claude
```

`CLAUDE.md` がアシスタントの設定ファイルです。起動するとこの内容に従ってアシスタント（Nexus）が振る舞います。

### GitHub Copilot で使う場合

VS Code 等で開くと、`.github/copilot-instructions.md` の行動ルールと `.github/skills/` の Agent Skills を自動的に読み込みます（Agent Skills の読み込み先は `.vscode/settings.json` の `chat.agentSkillsLocations` で設定）。Claude Code と同じ人格（Nexus）・同じスキルセットで動作します。

## ディレクトリ構成

```
ai-assistant-workspace/
├── CLAUDE.md              # 設定ファイル（Claude Code が読み込む実体）
├── MEMORY.md              # 長期記憶（近況・日常メモ・ワークスペース情報）
├── .claude/
│   └── skills/            # Claude Code 用スキル — 一覧は .claude/skills/README.md を参照
├── .github/
│   ├── copilot-instructions.md  # GitHub Copilot 用の行動ルール（CLAUDE.md の翻訳）
│   └── skills/            # GitHub Copilot 用 Agent Skills — 一覧は .github/skills/README.md を参照
├── memory/                # 日次メモの保存先（YYYYMMDD.md 形式）
├── notes/                 # ノート・調査メモの保存先
└── triggers/              # 決まった処理を実行する軽量ツール — triggers/README.md を参照
```

## 使い方のヒント

### メモを取る
```
「調査結果をまとめて」
「会議メモを保存して」
「最近のメモ教えて」
```

### ワークスペースを検索する
```
「前に話した○○について教えて」
「ワークスペース検索して: ○○」
```

### アイデアを出す
```
「アイデア出して: 次のブログのネタ」
「過去の記事と最近のメモをつないで」
```

### 複数の視点で考える・レビューする
```
「みんなで考えて: ○○のアーキテクチャ」
「複数の視点でこのPRをレビューして」
```

### PRをレビューする
```
「PR#123をレビューして」
「owner/repo の PR#45 をコードレビューして」
```

### arXiv論文を調べる
```
「LLMエージェントの最新論文を探して」
「この1週間のAIトレンド論文を教えて」
「論文 2401.12345 を詳しく分析して」
```

### プレゼン資料を作る
```
「AIの歴史について5枚のスライドを作って」
「このメモからプレゼン資料を作って」
```

### 図表を作る
```
「アーキテクチャ図描いて」
「フローチャートにして」
```

### テックニュースをチェック
```
「今日のテックニュースを教えて」
```

### 自分だけのスキルを作る
```
「読書メモを管理するスキルを作って」
```

## トリガー（軽量ツール）

`triggers/` ディレクトリには、決まった処理を実行する軽量ツール（`trigger.yaml` + `handler.ps1`）があります。`pwsh triggers/<name>/handler.ps1 <args>` で直接実行できます。

| トリガー | 内容 |
|----------|------|
| **rag** | ワークスペース全体をRAG検索 |
| **technews** | 最新テックニュース（RSS）を取得 |
| **weather** | 天気予報を取得（wttr.in） |

仕組み・新規作成手順は `triggers/README.md` を参照してください。

## カスタマイズ

### AIの性格を変える

`CLAUDE.md` の「自分について」セクションを編集すると、AIの話し方や性格を変えられます。GitHub Copilot にも同じ振る舞いをさせたい場合は `.github/copilot-instructions.md` も合わせて更新してください（原典は `CLAUDE.md`）。

### スキルを追加する

`.claude/skills/`（Claude Code 用）にフォルダを作り、`SKILL.md` を書くだけで新しいスキルを追加できます。詳しくは `.claude/skills/README.md` を参照してください。GitHub Copilot でも使うなら、同じスキルを `.github/skills/`（一覧は `.github/skills/README.md`）にも置いて両者を揃えます。

## ライセンス

MIT License
