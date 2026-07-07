# merge-sql.ps1
# 位于 EasyReader-Win/reader-backend/src/main/resources/database/

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = $PSScriptRoot  # 当前脚本所在目录

# 项目根目录：上移5级 (database -> resources -> main -> src -> reader-backend -> EasyReader-Win)
$projectRoot = Resolve-Path (Join-Path $scriptDir "..\..\..\..\..")

# 父目录（即 EasyReader-Win 所在目录）
$parentDir = Split-Path $projectRoot -Parent

# 规范源目录（与项目根同级）
$specsSqlDir = Join-Path $parentDir "EasyReader-Specs\sql"

# 输出目标：直接放在脚本所在目录下
$targetFile = Join-Path $scriptDir "schema.sql"

# 检查源目录
if (-not (Test-Path $specsSqlDir)) {
    Write-Error "Directory not found: $specsSqlDir"
    exit 1
}

# 创建目标目录（如果不存在，其实已经存在）
$targetDir = Split-Path $targetFile -Parent
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# 按顺序合并 SQL 文件
$order = @("book.sql", "progress.sql", "bookmark.sql", "note.sql")
$content = @()
foreach ($file in $order) {
    $fullPath = Join-Path $specsSqlDir $file
    if (Test-Path $fullPath) {
        Write-Host "Adding $file ..."
        $content += "`n-- ============================================`n-- File: $file`n-- ============================================`n"
        $content += Get-Content $fullPath -Raw -Encoding UTF8
        $content += "`n"
    } else {
        Write-Warning "Skipping missing file: $file"
    }
}

$content -join "`n" | Out-File -FilePath $targetFile -Encoding UTF8 -Force
Write-Host "Merge completed! Generated: $targetFile"