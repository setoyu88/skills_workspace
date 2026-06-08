param([string]$WorkspacePath = "")

if (-not $WorkspacePath) {
    $WorkspacePath = (Get-Item (Join-Path $PSScriptRoot "..\..\..")).FullName
}

$Port = if ($env:WORKSPACE_RAG_PORT) { $env:WORKSPACE_RAG_PORT } else { "7890" }
$ScriptDir = $PSScriptRoot
$RuntimeDir = Join-Path $WorkspacePath ".workspace_rag"
$PidFile = Join-Path $RuntimeDir "server.pid"
$LogFile = Join-Path $RuntimeDir "server.log"

# 既に起動中ならスキップ
if (Test-Path $PidFile) {
    $existingPid = Get-Content $PidFile -ErrorAction SilentlyContinue
    if ($existingPid) {
        $proc = Get-Process -Id ([int]$existingPid) -ErrorAction SilentlyContinue
        if ($proc -and -not $proc.HasExited) {
            Write-Output "Workspace RAG Server already running (PID: $existingPid)"
            exit 0
        } else {
            Write-Output "Stale PID file found, removing..."
            Remove-Item $PidFile -Force
        }
    }
}

# ポートが使用中ならスキップ
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("127.0.0.1", [int]$Port)
    $tcp.Close()
    Write-Output "Port $Port already in use"
    exit 0
} catch {
    # ポートは空き、続行
}

# ログディレクトリ確認
New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

Write-Output "Starting Workspace RAG Server on port $Port..."

$proc = Start-Process -FilePath "cmd.exe" `
    -ArgumentList @("/c", "uv run python workspace_rag_server.py -w `"$WorkspacePath`" -p $Port >> `"$LogFile`" 2>&1") `
    -WorkingDirectory $ScriptDir `
    -NoNewWindow -PassThru

$proc.Id | Out-File -FilePath $PidFile -NoNewline

Write-Output "PID: $($proc.Id)"
Write-Output "Log: $LogFile"
Write-Output "Health: Invoke-RestMethod http://127.0.0.1:$Port/health"
