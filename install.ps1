# oh-my-stalab-harness installer for Windows
$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  oh-my-stalab-harness installer" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js required. Install from https://nodejs.org" -ForegroundColor Red
    exit 1
}
Write-Host "[1/4] Node.js: $(node --version)" -ForegroundColor Green

# Create ~/.claude if needed
if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

# Backup existing
$DirsToLink = @("agents", "commands", "hooks", "skills", "rules", "cc-chips-custom")
$Existing = $DirsToLink | Where-Object { Test-Path (Join-Path $ClaudeDir $_) }

if ($Existing.Count -gt 0) {
    $BackupDir = Join-Path $ClaudeDir "backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "[2/4] Found existing: $($Existing -join ', ')" -ForegroundColor Yellow
    $confirm = Read-Host "  Back up to $BackupDir? (Y/n)"
    if ($confirm -ne 'n') {
        New-Item -ItemType Directory -Path $BackupDir | Out-Null
        foreach ($dir in $Existing) {
            Move-Item (Join-Path $ClaudeDir $dir) (Join-Path $BackupDir $dir)
        }
        Write-Host "  Backed up." -ForegroundColor Green
    }
}

# Copy directories
Write-Host "[3/4] Installing harness..." -ForegroundColor Green
foreach ($dir in $DirsToLink) {
    $src = Join-Path $RepoDir $dir
    $dst = Join-Path $ClaudeDir $dir
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        Write-Host "  Copied $dir/"
    }
}

# Copy configs
Write-Host "[4/4] Setting up configs..." -ForegroundColor Green
$configs = @("settings.json", ".mcp.json")
foreach ($cfg in $configs) {
    $src = Join-Path $RepoDir $cfg
    $dst = Join-Path $ClaudeDir $cfg
    if ((Test-Path $src) -and -not (Test-Path $dst)) {
        Copy-Item $src $dst
        Write-Host "  Created $cfg"
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Installation complete!" -ForegroundColor Cyan
Write-Host "  10 agents, 14 commands, 12 hooks, 13 skills, 6 rules" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
