param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

$Workspace = if ($env:WORKSPACE_PATH) { $env:WORKSPACE_PATH } else {
    (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName
}
$ScriptDir = Join-Path $Workspace "skills\workspace-rag\scripts"
$Port = if ($env:WORKSPACE_RAG_PORT) { $env:WORKSPACE_RAG_PORT } else { "7890" }
$RuntimeDir = Join-Path $Workspace ".workspace_rag"
$PidFile = Join-Path $RuntimeDir "server.pid"
$LogFile = Join-Path $RuntimeDir "server.log"
$IndexLog = Join-Path $RuntimeDir "index.log"

New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

function Test-RagRunning {
    try {
        $null = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/health" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Start-RagServer {
    if (Test-RagRunning) {
        Write-Output "RAGサーバーはすでに起動中です（port $Port）"
        return
    }
    if (-not (Test-Path $ScriptDir)) {
        Write-Output "workspace-ragスキルが見つかりません: $ScriptDir"
        return
    }

    $proc = Start-Process -FilePath "cmd.exe" `
        -ArgumentList @("/c", "uv run python workspace_rag_server.py -w `"$Workspace`" -p $Port >> `"$LogFile`" 2>&1") `
        -WorkingDirectory $ScriptDir `
        -NoNewWindow -PassThru

    $proc.Id | Out-File -FilePath $PidFile -NoNewline

    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Seconds 1
        if (Test-RagRunning) {
            $pidVal = Get-Content $PidFile
            Write-Output "RAGサーバー起動完了（port $Port, PID $pidVal）"
            return
        }
    }
    Write-Output "起動を待ちましたがヘルスチェックに応答しません。ログ: $LogFile"
}

function Start-RagIndex {
    $running = Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*workspace_rag.py*index*" }
    if ($running) {
        Write-Output "インデックス作成はすでに実行中です。進捗: Get-Content -Wait `"$IndexLog`""
        return
    }
    if (-not (Test-Path $ScriptDir)) {
        Write-Output "workspace-ragスキルが見つかりません: $ScriptDir"
        return
    }

    $proc = Start-Process -FilePath "cmd.exe" `
        -ArgumentList @("/c", "uv run python workspace_rag.py index -w `"$Workspace`" > `"$IndexLog`" 2>&1") `
        -WorkingDirectory $ScriptDir `
        -NoNewWindow -PassThru

    Write-Output "インデックス作成をバックグラウンドで開始しました（PID $($proc.Id)）"
    Write-Output "進捗: Get-Content -Wait `"$IndexLog`""
}

function Get-RagHealth {
    if (Test-RagRunning) {
        try {
            $result = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/health" -TimeoutSec 5 -UseBasicParsing
            Write-Output $result.Content
        } catch {
            Write-Output "ヘルスチェックの取得に失敗しました"
        }
    } else {
        Write-Output "RAGサーバーは起動していません（port $Port）。`pwsh triggers/rag/handler.ps1 start` で起動してください"
    }
}

function Search-Rag {
    param([string[]]$QueryParts)
    $Query = $QueryParts -join " "
    if (-not (Test-RagRunning)) {
        Write-Output "RAGサーバーが起動していません。`pwsh triggers/rag/handler.ps1 start` で起動してください"
        return
    }

    $encoded = [System.Uri]::EscapeDataString($Query)
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/search?q=$encoded&k=5" -TimeoutSec 10 -UseBasicParsing
        $data = $response.Content | ConvertFrom-Json
        $results = $data.results
        if (-not $results -or $results.Count -eq 0) {
            Write-Output "該当する結果がありませんでした"
        } else {
            $elapsed = $data.elapsed_ms
            Write-Output "検索結果: $($results.Count)件 ($([math]::Round($elapsed))ms)"
            Write-Output ""
            foreach ($r in $results) {
                $score = [math]::Round($r.score, 2)
                $path = $r.file_path
                $contentLen = [math]::Min(150, $r.content.Length)
                $content = $r.content.Substring(0, $contentLen).Replace("`n", " ")
                Write-Output "- **$path** (score: $score)"
                Write-Output "  $content..."
                Write-Output ""
            }
        }
    } catch {
        Write-Output "検索に失敗しました"
    }
}

function Show-RagHelp {
    Write-Output @"
ワークスペースRAG（port $Port）

使い方:
  start         サーバー起動（起動済みならスキップ）
  index         インデックス作成（バックグラウンド、初回は数十分〜）
  health        サーバーの稼働状況・統計を表示
  <検索クエリ>  検索（サーバー起動済みが前提）

例:
  pwsh triggers/rag/handler.ps1 start
  pwsh triggers/rag/handler.ps1 AIエージェント
"@
}

$cmd = if ($Arguments -and $Arguments.Count -gt 0) { $Arguments[0] } else { "" }

switch ($cmd) {
    { $_ -in @("", "help", "-h", "--help") } { Show-RagHelp; break }
    "start"  { Start-RagServer; break }
    "index"  { Start-RagIndex; break }
    "health" { Get-RagHealth; break }
    default  { Search-Rag -QueryParts $Arguments }
}
