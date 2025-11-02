# AnderMotion Rebranding Script
# Renames VitalSense to AnderMotion throughout the project

Write-Host "🔄 Starting VitalSense → AnderMotion rebranding..." -ForegroundColor Cyan

# Define replacement mappings
$replacements = @(
    @{ 'Find' = 'VitalSense'; 'Replace' = 'AnderMotion' }
    @{ 'Find' = 'vitalsense'; 'Replace' = 'andermotion' }
    @{ 'Find' = 'VITALSENSE'; 'Replace' = 'ANDERMOTION' }
    @{ 'Find' = 'dev.andernet.VitalSense'; 'Replace' = 'dev.andernet.AnderMotion' }
)

# Files to update (excluding binary and generated files)
$filePatterns = @(
    '*.swift',
    '*.md',
    '*.plist',
    '*.entitlements',
    '*.xcscheme',
    '*.xcodebuild',
    '*.sh',
    '*.ps1'
)

Write-Host "📁 Scanning for files to update..." -ForegroundColor Yellow

$filesToUpdate = @()
foreach ($pattern in $filePatterns) {
    $files = Get-ChildItem -Recurse -Filter $pattern -ErrorAction SilentlyContinue
    $filesToUpdate += $files
}

Write-Host "📄 Found $($filesToUpdate.Count) files to process" -ForegroundColor Green

foreach ($file in $filesToUpdate) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction Stop
        $originalContent = $content

        # Apply all replacements
        foreach ($replacement in $replacements) {
            $content = $content -replace [regex]::Escape($replacement.Find), $replacement.Replace
        }

        # Only write if content changed
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "✅ Updated: $($file.FullName.Replace($PWD.Path, '.'))" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "⚠️  Skipped: $($file.FullName.Replace($PWD.Path, '.')) - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "🎉 Rebranding complete! AnderMotion is ready!" -ForegroundColor Cyan
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Verify changes in Xcode" -ForegroundColor White
Write-Host "   2. Update App Store Connect with new name" -ForegroundColor White
Write-Host "   3. Test build to ensure everything works" -ForegroundColor White
