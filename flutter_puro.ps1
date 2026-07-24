# Self-contained Flutter wrapper for Puro on Windows
# Fixes: SDK root directory not found: ../../../.puro/envs/stable/flutter/bin/cache/flutter_web_sdk/

$ErrorActionPreference = "Stop"

# Set Flutter root to the actual Puro installation (not the shim)
$env:FLUTTER_ROOT = "$env:USERPROFILE\.puro\envs\stable\flutter"
$env:FLUTTER_WEB_SDK = "$env:FLUTTER_ROOT\bin\cache\flutter_web_sdk"

# Ensure the relative path junction exists for this project tree
$projectRoot = (Resolve-Path ".").Path

# Walk up to find where ../../../ from build dir would resolve
# Build dir is typically: project\.dart_tool\flutter_build\xxx\web\
# ../../../ from there = project\..\..\..\
# We need .puro at that level
$ancestor = Split-Path -Parent $projectRoot
$relativePuroDir = Join-Path $ancestor ".puro\envs\stable\flutter\bin\cache\flutter_web_sdk"

if (-not (Test-Path $relativePuroDir)) {
    $targetDir = Split-Path -Parent $relativePuroDir
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    if (-not (Test-Path $relativePuroDir)) {
        cmd /c mklink /J "$relativePuroDir" "$env:FLUTTER_WEB_SDK" 2>$null | Out-Null
    }
}

# Run flutter with all arguments passed through
$flutterExe = "$env:FLUTTER_ROOT\bin\flutter.bat"
& $flutterExe @args
