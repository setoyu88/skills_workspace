# スキル一覧

スキルは `.github/skills/` ディレクトリに格納されたAIの拡張機能です。各スキルには `SKILL.md` が含まれ、GitHub Copilot が自動的に読み込みます（Agent Skills 標準形式）。

> このディレクトリは Claude Code 用の `.claude/skills/` と同じ内容を GitHub Copilot 向けに調整した自己完結セットです。`.claude` が無くても `.github` 単体で動作します。

## 利用可能なスキル

### 検索・知識ベース

| スキル | 説明 | トリガー |
|--------|------|----------|
| **workspace-rag** | ワークスペース全体をベクトル検索（SQLite + multilingual-e5、port 7890） | 「ワークスペース検索して」「RAGで探して」 |

### 思考・分析・レビュー

| スキル | 説明 | トリガー |
|--------|------|----------|
| **bridge-ideas** | ワークスペース内の遠い知識・資産をつないでアイデア生成 | 「アイデア出して」「知識をつないで」 |
| **multi-agent** | Claude Code のサブエージェントを並行起動して協調分析・レビュー | 「みんなで考えて」「複数の視点でレビュー」 |
| **code-reviewer** | PRを体系的にレビュー（任意でサブエージェント検証） | 「PRレビューして」「PR#123をチェック」 |
| **arxiv** | arXiv論文の検索・トレンド発見・詳細分析 | 「論文探して」「arxivで調べて」 |

### 記録・メモ

| スキル | 説明 | トリガー |
|--------|------|----------|
| **note-taking** | 調査結果・アイデア・会議メモを保存 | 「メモして」「ノートにまとめて」 |

### コンテンツ生成

| スキル | 説明 | トリガー |
|--------|------|----------|
| **marp-slides** | Marpでプレゼンスライドを作成 | 「スライド作って」「プレゼン資料を作って」 |
| **diagram-generator** | 図表自動生成（Pillow画像/Mermaid/PlantUML） | 「図にして」「アーキテクチャ図描いて」 |
| **transcriber** | 音声ファイルをWhisperで文字起こし | 「文字起こしして」「音声をテキストに」 |
| **podcast** | ポッドキャストの取得・文字起こし・まとめ | 「ポッドキャストまとめて」 |
| **youtube-notes** | YouTube動画の字幕からノートを作成 | 「YouTube動画をまとめて」 |
| **tech-news-curation** | AI・技術系の最新ニュースを取得 | 「テックニュース」「最新のニュース教えて」 |

### システム・メタ

| スキル | 説明 | トリガー |
|--------|------|----------|
| **skill-creator** | 新しいスキルを作成する | 「スキルを作って」 |

## SKILL.mdの書き方

各スキルのディレクトリに `SKILL.md` を作成します。先頭にYAMLフロントマターで `name` と `description` を記述してください。

```markdown
---
name: skill-name
description: 何をするスキルか。「呼び出しフレーズ」で使用。
---

# スキル名

## 手順

### Step 1: ...
```

`description` はAIがスキルを選択する際の判断材料になるので、具体的に書いてください。

## GitHub Copilot への接続

スキルは GitHub Copilot が認識する `.github/skills/` に直接置いています。Copilot（VS Code / CLI / cloud agent）は Agent Skills のディレクトリを自動で読み込むため、追加設定は不要です。リポジトリ内で読み込み場所を制御したい場合は `.vscode/settings.json` の `chat.agentSkillsLocations` で指定できます。

スキルを追加するときは `.github/skills/` に新しいフォルダを作り、`SKILL.md` を置くだけで利用できます。
