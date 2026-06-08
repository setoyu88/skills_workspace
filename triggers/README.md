# triggers

**LLMがFunction Callingで呼び出す軽量ツール**を置く場所。スキルとツール呼び出しの中間に位置する仕組みで、ローカルLLMのように性能が限定的なモデルでも「再現性高く決まった処理」を実行できるように設計されている。

[xangi](https://github.com/karaage0703/xangi) と組み合わせて使う想定。コンセプトの詳細は [Trigger: ローカルLLM用簡易スキルシステム](https://zenn.dev/karaage0703/articles/89631872ca5a86) を参照。

## どう動くか

1. ユーザーがチャットで自然言語で発話する（例: 「名古屋の天気は？」）
2. LLMが各 `trigger.yaml` の `description` を見て、関連するトリガーがあるか判断
3. 関連すれば Function Calling で `handler.ps1` を呼ぶ（引数も自動生成）
4. `handler.ps1` の標準出力をLLMが受け取り、ユーザーへの応答に活用

トリガーは LLM の Function Calling 経由で呼ばれることを前提とした仕組み。xangi の場合、ローカルLLM向け機能（`LOCAL_LLM_TRIGGERS=true`）として使われる。

## triggers と skills の違い

| | triggers | skills |
|---|---|---|
| 実行 | LLMがFunction Callingで呼ぶ | AI（LLM）が読み込んで段階的に実行 |
| 形式 | `handler.ps1` + `trigger.yaml` | `SKILL.md`（プロンプト+補助スクリプト） |
| LLMの関与 | description見て呼ぶか判断するだけ | プロンプトを読み込んで都度推論 |
| 柔軟性 | 固定処理（引数だけ可変） | 自然言語の揺らぎに対応・複数ステップ |
| 適している用途 | 天気・ニュース・検索など決まった取得処理 | 文章生成・要約・判断・対話・ワークフロー |

ざっくり言うと、**トリガーは「LLMが叩ける固定ツール」**、スキルは「LLMが読み込んで判断するプロンプト」。判断・生成が必要ならスキル、決まった処理ならトリガー。

## ディレクトリ構成

```
triggers/
├── README.md           # このファイル
├── rag/                # ワークスペースRAG検索
│   ├── trigger.yaml
│   ├── handler.ps1
│   └── README.md
├── technews/           # テックニュース取得
│   ├── trigger.yaml
│   ├── handler.ps1
│   └── README.md
└── weather/            # 天気予報
    ├── trigger.yaml
    ├── handler.ps1
    └── README.md
```

各トリガーは独立したディレクトリ。最低限 `trigger.yaml`（メタ情報）と `handler.ps1`（処理本体）の2つが必要。

## trigger.yaml

```yaml
name: weather
description: "天気予報を取得する（例: weather 名古屋）"
handler: handler.ps1
```

| フィールド | 必須 | 説明 |
|---|---|---|
| `name` | ◯ | ツール名。LLMがFunction Callingで指定する識別子 |
| `description` | ◯ | **LLMが「これを使うか」判断する手がかり**。具体例（例: `weather 名古屋`）を含めると判定精度が上がる |
| `handler` | ◯ | 実行するスクリプトのパス（`trigger.yaml` からの相対パス） |

## handler.ps1

PowerShellスクリプト。**ワークスペースルートをcwdとして実行される**。LLMが Function Calling で生成した引数は `param()` で受け取る。標準出力に書いたものがLLMに返る（LLMがそれを読んでユーザーに応答）。

```powershell
param([string]$City = "Tokyo")
try {
    $response = Invoke-WebRequest "https://wttr.in/${City}?format=3&lang=ja" -UseBasicParsing
    Write-Output $response.Content
} catch {
    Write-Output "天気情報の取得に失敗しました"
}
```

ポイント:

- **`param()` で引数を定義** — `param([string]$City = "Tokyo")` のようにデフォルト値も指定できる
- **エラーは出力でユーザーに伝える** — チャットに返るのは標準出力なので、失敗時もユーザーに分かるメッセージを出す
- **長時間処理は `Start-Process` でバックグラウンド** — チャット側のタイムアウト（数分〜）を超えるなら、起動だけして「実行開始した」と返す

## 新しいトリガーの作り方

```powershell
# 1. ディレクトリを作る
New-Item -ItemType Directory triggers/myhello

# 2. trigger.yaml を書く
@'
name: myhello
description: "挨拶を返す"
handler: handler.ps1
'@ | Set-Content triggers/myhello/trigger.yaml

# 3. handler.ps1 を書く
@'
param([string]$Name = "世界")
Write-Output "こんにちは $Name さん"
'@ | Set-Content triggers/myhello/handler.ps1

# 4. xangi を再起動（新トリガーは起動時に読み込まれる）
xangi-cmd system_restart
```

登録後はチャットで「○○さんに挨拶して」のような自然言語で話しかけると、LLMが `myhello` トリガーを呼ぶ判断をして `こんにちは からあげ さん` のような応答を返してくれる（具体的な発火条件は `description` の書き方次第）。

## xangi 以外で使う場合

トリガーはPowerShellスクリプトなので、xangi に縛られず単体でも使える。

```powershell
pwsh triggers/weather/handler.ps1 名古屋
pwsh triggers/rag/handler.ps1 "AI開発ワークフロー"
```

別のFunction Calling対応LLMフレームワークから呼ぶことも、CIから呼ぶことも可能。

## デバッグ

- LLMが呼んでくれない → `trigger.yaml` の `description` を見直す。具体例（`例:`〜）を含めると判定精度が上がる
- 認識されない → `trigger.yaml` の `name` と `handler` のパスを確認
- LLMが呼んでも失敗する → 直接 `pwsh triggers/<name>/handler.ps1 <args>` で実行して切り分け
- 出力が文字化け → `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` を確認

## 同梱されているトリガー

| トリガー | 説明 | LLMが呼ぶ場面の例 |
|---|---|---|
| [rag](rag/README.md) | ワークスペースRAGで検索（[`workspace-rag`](../.claude/skills/workspace-rag/) 連携） | 「過去のメモから○○探して」 |
| [technews](technews/README.md) | 最新テックニュース取得（RSS） | 「テックニュース教えて」 |
| [weather](weather/README.md) | 天気予報取得（wttr.in） | 「名古屋の天気は？」 |
