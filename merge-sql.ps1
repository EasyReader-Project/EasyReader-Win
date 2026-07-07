# merge-sql.ps1
# Merge SQL files from EasyReader-Specs/sql into schema.sql

# Set output encoding to UTF-8 (optional but recommended)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$projectRoot = Split-Path $PSScriptRoot -Parent
$specsSqlDir = Join-Path $projectRoot "EasyReader-Specs/sql"
$targetFile = Join-Path $PSScriptRoot "reader-backend/src/main/resources/database/schema.sql"

if (-not (Test-Path $specsSqlDir)) {
    Write-Error "Directory not found: $specsSqlDir"
    exit 1
}

$order = @("book.sql", "progress.sql", "bookmark.sql", "note.sql")

$targetDir = Split-Path $targetFile -Parent
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

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