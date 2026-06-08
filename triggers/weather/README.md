# weather trigger

天気予報を1行で返す `weather` トリガー。LLMが「今日の天気は？」「名古屋の天気教えて」のような発話に反応して呼び出す。

## ソース

[wttr.in](https://wttr.in/) — シンプルな天気APIサービス。引数の都市名で世界中の天気が取れる。

## 使用例

LLM経由（チャット）：

```
ユーザー: 名古屋の天気は？
LLM: （内部で weather("名古屋") を呼ぶ）
LLM: 名古屋は ☀️ +25°C だね。今日は外歩き気持ちよさそう。
```

シェルから直叩き（デバッグ用）：

```powershell
> pwsh triggers/weather/handler.ps1
☀️ +22°C

> pwsh triggers/weather/handler.ps1 名古屋
☀️ +25°C

> pwsh triggers/weather/handler.ps1 Tokyo
☁️ +18°C

> pwsh triggers/weather/handler.ps1 "New York"
🌧 +12°C
```

引数を省略すると `Tokyo` がデフォルト。

## カスタマイズ

### 表示形式を変える

`handler.ps1` の `?format=3` を変更：

| format | 出力例 |
|---|---|
| `1` | `☀️ 🌡️+22°C 🌬️→8km/h` |
| `2` | `☀️ +22°C` |
| `3` | `名古屋: ☀️ +22°C` |
| `4` | `名古屋: ☀️ +22°C 8km/h` |

詳細は [wttr.in のドキュメント](https://github.com/chubin/wttr.in#one-line-output) を参照。

### 多日予報

`handler.ps1` の URL を `wttr.in/${City}?lang=ja&n` のように変えれば1日予報。`&format=...` を消すと数日分の詳細表示も可能（出力が長くなる点に注意）。

## デフォルト都市の変更

```powershell
param([string]$City = "Nagoya")  # ← Tokyoから変更
```
