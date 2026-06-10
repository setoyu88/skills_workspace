#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Claude Code 用スキル (.claude/skills) を GitHub Copilot 用 (.github/skills) に変換する。

.DESCRIPTION
  スキルディレクトリを丸ごとコピーし、テキストファイル内のパス参照と
  「自動読み込み」系の文言を Copilot 向けに書き換える。
  - フロントマター (name / description) は変更しない
  - 機能を表す Claude 固有表現（例: multi-agent の "Agent ツール"）は温存する
  - 何度実行しても結果が同じ（冪等）

.PARAMETER Name
  変換するスキル名（例: note-taking）。

.PARAMETER All
  Source 配下の全スキルを変換する。

.PARAMETER Source
  変換元ディレクトリ。既定: .claude/skills

.PARAMETER Dest
  変換先ディレクトリ。既定: .github/skills

.EXAMPLE
  pwsh convert_skill.ps1 -Name note-taking

.EXAMPLE
  pwsh convert_skill.ps1 -All

.EXAMPLE
  pwsh convert_skill.ps1 -Name arxiv -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Name,
    [switch]$All,
    [string]$Source = ".claude/skills",
    [string]$Dest   = ".github/skills"
)

$ErrorActionPreference = 'Stop'

# --- 置換テーブル（リテラル一致・冪等） -------------------------------------
# キーは「変換元の文字列」、値は「変換先の文字列」。
# .Replace() でリテラル置換するため正規表現の特殊文字を気にしなくてよい。
$replacements = [ordered]@{
    '.claude/skills'                       = '.github/skills'
    'Claude Code 標準の'                    = 'GitHub Copilot が認識する'
    'Claude Code が自動的に読み込みます'      = 'GitHub Copilot が自動的に読み込みます'
    'Claude Code への接続'                  = 'GitHub Copilot への接続'
}

# 書き換え対象とするテキスト拡張子
$textExts = @('.md', '.ps1', '.py', '.txt', '.yaml', '.yml', '.json', '.toml', '.js', '.ts', '.sh')

function Convert-OneSkill {
    param([string]$SkillName)

    $src = Join-Path $Source $SkillName
    $dst = Join-Path $Dest   $SkillName

    if (-not (Test-Path -LiteralPath $src -PathType Container)) {
        Write-Warning "変換元が見つかりません: $src"
        return
    }

    if (-not $PSCmdlet.ShouldProcess($dst, "コピー＆変換")) {
        Write-Host "[WhatIf] $src -> $dst"
        return
    }

    # 既存の変換先は作り直す（冪等にするため）
    if (Test-Path -LiteralPath $dst) {
        Remove-Item -LiteralPath $dst -Recurse -Force
    }
    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force

    # キャッシュ類は持ち込まない
    Get-ChildItem -LiteralPath $dst -Recurse -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @('__pycache__', '.venv', '.mypy_cache', '.pytest_cache') } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath $dst -Recurse -File -Filter '*.pyc' -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue

    # テキストファイルを書き換え
    $changedFiles = 0
    $pathHits     = 0
    $reviewFiles  = [System.Collections.Generic.List[string]]::new()

    foreach ($f in Get-ChildItem -LiteralPath $dst -Recurse -File) {
        if ($textExts -notcontains $f.Extension.ToLower()) { continue }

        $orig = Get-Content -LiteralPath $f.FullName -Raw
        if ($null -eq $orig) { continue }

        # パス出現数をカウント（報告用）
        $pathHits += ([regex]::Matches($orig, [regex]::Escape('.claude/skills'))).Count

        $text = $orig
        foreach ($k in $replacements.Keys) {
            $text = $text.Replace($k, $replacements[$k])
        }

        if ($text -ne $orig) {
            # -Raw で読み込んだ末尾改行を保持するため -NoNewline で書き戻す
            Set-Content -LiteralPath $f.FullName -Value $text -Encoding utf8 -NoNewline
            $changedFiles++
        }

        # 機能的な Claude 表現が残っていれば、人手レビュー候補として通知
        if ($text -match 'Claude') {
            $reviewFiles.Add($f.FullName.Substring((Resolve-Path $dst).Path.Length).TrimStart('\','/'))
        }
    }

    Write-Host "✔ $SkillName : コピー完了 / 書換ファイル $changedFiles 件 / パス置換 $pathHits 箇所"
    if ($reviewFiles.Count -gt 0) {
        Write-Host "  ↳ 'Claude' を含む（要レビュー候補）: $($reviewFiles -join ', ')"
    }
}

# --- 実行 -------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    Write-Error "変換元ディレクトリがありません: $Source （ワークスペースルートで実行してください）"
    exit 1
}

$targets = @()
if ($All) {
    # 変換器自身（.claude 側に常駐するツール）は Copilot へ出力しない
    $targets = Get-ChildItem -LiteralPath $Source -Directory |
        Where-Object { $_.Name -ne 'skill-converter' } |
        Select-Object -ExpandProperty Name
} elseif ($Name) {
    $targets = @($Name)
} else {
    Write-Error "-Name <skill> または -All を指定してください。"
    exit 1
}

foreach ($t in $targets) { Convert-OneSkill -SkillName $t }

Write-Host ""
Write-Host "完了。次にこれらを確認してください:"
Write-Host "  1. .github/skills/README.md の一覧に新規スキルを追記"
Write-Host "  2. 'Claude' が残ったファイルで、機能説明はそのままでよいか確認"
Write-Host "  3. .vscode/settings.json の chat.agentSkillsLocations の方針を確認"
