# PowerShell script to set up Xcode Cloud scripts on Windows
# This will be useful when the repository is checked out on macOS/Linux for Xcode Cloud

Write-Host "🔧 Setting up Xcode Cloud scripts..." -ForegroundColor Cyan

$scriptPath = Join-Path $PSScriptRoot "ci_scripts"

if (Test-Path $scriptPath) {
    Write-Host "✅ CI scripts directory found at: $scriptPath" -ForegroundColor Green
    
    Get-ChildItem -Path $scriptPath -Filter "*.sh" | ForEach-Object {
        Write-Host "📄 Found script: $($_.Name)" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ CI scripts directory not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Xcode Cloud setup verified!" -ForegroundColor Green