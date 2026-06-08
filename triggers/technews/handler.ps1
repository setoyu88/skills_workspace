try {
    $response = Invoke-WebRequest -Uri "https://karaage0703.github.io/tech-blog-rss-feed/feeds/rss.xml" -TimeoutSec 10 -UseBasicParsing
    [xml]$rss = $response.Content
    $items = $rss.rss.channel.item | Select-Object -First 5
    foreach ($item in $items) {
        Write-Output "- $($item.title)"
        Write-Output "  $($item.link)"
        Write-Output ""
    }
} catch {
    Write-Output "ニュースの取得に失敗しました"
}
