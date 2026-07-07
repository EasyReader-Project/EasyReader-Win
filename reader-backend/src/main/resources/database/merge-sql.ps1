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

# 获取所有 .sql 文件，并按文件名排序
$sqlFiles = Get-ChildItem -Path $specsSqlDir -Filter "*.sql" | Sort-Object Name

if ($sqlFiles.Count -eq 0) {
    Write-Warning "No .sql files found in $specsSqlDir"
    exit 0
}

$content = @()
foreach ($file in $sqlFiles) {
    $fullPath = $file.FullName
    $fileName = $file.Name
    Write-Host "Adding $fileName ..."
    $content += "`n-- ============================================`n-- File: $fileName`n-- ============================================`n"
    $content += Get-Content $fullPath -Raw -Encoding UTF8
    $content += "`n"
}

$content -join "`n" | Out-File -FilePath $targetFile -Encoding UTF8 -Force
Write-Host "Merge completed! Generated: $targetFile"