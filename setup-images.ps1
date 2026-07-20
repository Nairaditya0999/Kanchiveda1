# Copies saree images from Downloads into the project images folder
$source = "$env:USERPROFILE\Downloads"
$dest = "$PSScriptRoot\images"

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest | Out-Null
}

$scriptJs = Get-Content "$PSScriptRoot\script.js" -Raw
$matches = [regex]::Matches($scriptJs, 'images/([^"\]]+\.(jpg|jpeg|png|webp))', 'IgnoreCase')
$files = $matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

$copied = 0
$missing = @()

foreach ($file in $files) {
    $srcPath = Join-Path $source $file
    $dstPath = Join-Path $dest $file
    if (Test-Path $srcPath) {
        Copy-Item $srcPath $dstPath -Force
        $copied++
    } else {
        $missing += $file
    }
}

# Copy logo if present
$logoCandidates = @(
    "log-jukebox-bg-removed 11.jpg",
    "logo.jpg",
    "kanchiveda-logo.jpg"
)
foreach ($logo in $logoCandidates) {
    $src = Join-Path $source $logo
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $dest "logo.jpg") -Force
        Write-Host "Logo copied: $logo"
        break
    }
}

Write-Host "Copied $copied image(s) to images/"
if ($missing.Count -gt 0) {
    Write-Host "Missing $($missing.Count) file(s):"
    $missing | ForEach-Object { Write-Host "  - $_" }
}
