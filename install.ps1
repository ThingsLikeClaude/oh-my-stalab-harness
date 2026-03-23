# oh-my-stalab-harness installer for Windows
# File-level merge — never overwrites user's custom files
$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  oh-my-stalab-harness installer" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# 1. Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js required. Install from https://nodejs.org" -ForegroundColor Red
    exit 1
}
Write-Host "[1/4] Node.js: $(node --version)" -ForegroundColor Green

# 2. Create directories
Write-Host "[2/4] Preparing directories..." -ForegroundColor Green
$DirsToInstall = @("agents", "commands", "hooks", "skills", "rules", "cc-chips-custom")
foreach ($dir in $DirsToInstall) {
    $dst = Join-Path $ClaudeDir $dir
    if (-not (Test-Path $dst)) {
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
    }
}

# 3. File-level merge with conflict detection
Write-Host "[3/4] Installing files (file-level merge)..." -ForegroundColor Green

$Stats = @{ installed = 0; skipped = 0; conflicts = @() }

function Install-FileWithMerge {
    param($SrcFile, $DstFile)

    if (-not (Test-Path $DstFile)) {
        # New file — safe to copy
        $parent = Split-Path -Parent $DstFile
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        Copy-Item $SrcFile $DstFile
        $Stats.installed++
        return
    }

    # File exists — check if identical
    $srcHash = (Get-FileHash $SrcFile -Algorithm SHA256).Hash
    $dstHash = (Get-FileHash $DstFile -Algorithm SHA256).Hash

    if ($srcHash -eq $dstHash) {
        # Identical — skip silently
        $Stats.skipped++
        return
    }

    # Conflict: different content
    $relPath = $DstFile.Replace($ClaudeDir, "~/.claude")
    $Stats.conflicts += $relPath

    # Back up existing, then install
    $backupPath = "$DstFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $DstFile $backupPath
    Copy-Item $SrcFile $DstFile -Force
    $Stats.installed++
}

foreach ($dir in $DirsToInstall) {
    $srcDir = Join-Path $RepoDir $dir
    if (-not (Test-Path $srcDir)) { continue }

    $files = Get-ChildItem -Path $srcDir -Recurse -File
    foreach ($file in $files) {
        $relPath = $file.FullName.Substring($srcDir.Length)
        $dstFile = Join-Path (Join-Path $ClaudeDir $dir) $relPath
        Install-FileWithMerge -SrcFile $file.FullName -DstFile $dstFile
    }
}

Write-Host "  Installed: $($Stats.installed) files" -ForegroundColor Green
Write-Host "  Skipped (identical): $($Stats.skipped) files" -ForegroundColor DarkGray

if ($Stats.conflicts.Count -gt 0) {
    Write-Host ""
    Write-Host "  CONFLICTS (backed up originals with .backup-* suffix):" -ForegroundColor Yellow
    foreach ($c in $Stats.conflicts) {
        Write-Host "    $c" -ForegroundColor Yellow
    }
}

# 4. Config files — never overwrite
Write-Host "[4/4] Setting up configs..." -ForegroundColor Green
$configs = @("settings.json", ".mcp.json")
foreach ($cfg in $configs) {
    $src = Join-Path $RepoDir $cfg
    $dst = Join-Path $ClaudeDir $cfg
    if ((Test-Path $src) -and -not (Test-Path $dst)) {
        Copy-Item $src $dst
        Write-Host "  Created $cfg"
    } elseif (Test-Path $dst) {
        Write-Host "  $cfg exists — merge manually if needed" -ForegroundColor DarkGray
    }
}

# Summary
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Installation complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Installed: $($Stats.installed) | Skipped: $($Stats.skipped) | Conflicts: $($Stats.conflicts.Count)" -ForegroundColor White
if ($Stats.conflicts.Count -gt 0) {
    Write-Host "  Review .backup-* files for conflicts" -ForegroundColor Yellow
}
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
