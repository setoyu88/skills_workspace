param([string]$City = "Tokyo")
try {
    $response = Invoke-WebRequest -Uri "https://wttr.in/${City}?format=3&lang=ja" -TimeoutSec 10 -UseBasicParsing
    Write-Output $response.Content
} catch {
    Write-Output "天気情報の取得に失敗しました"
}
