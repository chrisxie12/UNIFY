# Shared Puro detection and Flutter web SDK path fixes for Windows.
# See: https://github.com/pingbird/puro/issues/156

function Test-PuroProject {
    param([string]$ProjectRoot)

    if (Test-Path (Join-Path $ProjectRoot '.puro.json')) { return $true }
    if (Test-Path (Join-Path $ProjectRoot '.puro')) { return $true }

    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCmd -and $flutterCmd.Source -match '[\\/]\.puro[\\/]') { return $true }

    return $false
}

function Get-PuroEnvName {
    param([string]$ProjectRoot)

    $puroJson = Join-Path $ProjectRoot '.puro.json'
    if (Test-Path $puroJson) {
        try {
            $config = Get-Content $puroJson -Raw | ConvertFrom-Json
            if ($config.env) { return [string]$config.env }
        }
        catch {
            Write-Warning "Could not parse .puro.json: $_"
        }
    }

    return 'stable'
}

function Resolve-FlutterRootPath {
    param([string]$Path)

    if (-not $Path) { return $null }

    $resolved = $Path
    if (-not [System.IO.Path]::IsPathRooted($resolved)) {
        $resolved = Join-Path (Get-Location) $resolved
    }

    try {
        return (Resolve-Path -LiteralPath $resolved).Path
    }
    catch {
        return $null
    }
}

function Get-PuroFlutterRoot {
    param([string]$ProjectRoot)

    $envName = Get-PuroEnvName -ProjectRoot $ProjectRoot
    $puroRoot = Join-Path $env:USERPROFILE '.puro'
    $candidate = Join-Path $puroRoot "envs\$envName\flutter"

    $resolved = Resolve-FlutterRootPath -Path $candidate
    if ($resolved -and (Test-Path (Join-Path $resolved 'bin\flutter.bat'))) {
        return $resolved
    }

    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCmd) {
        $binDir = Split-Path -Parent $flutterCmd.Source
        $fromPath = Resolve-FlutterRootPath -Path (Join-Path $binDir '..')
        if ($fromPath -and (Test-Path (Join-Path $fromPath 'bin\flutter.bat'))) {
            return $fromPath
        }
    }

    throw "Could not resolve Puro Flutter SDK. Expected at $candidate"
}

function Install-PuroFlutterEnv {
    param(
        [string]$FlutterRoot,
        [switch]$Quiet
    )

    $flutterRoot = Resolve-FlutterRootPath -Path $FlutterRoot
    if (-not $flutterRoot) {
        throw "Invalid Flutter root: $FlutterRoot"
    }

    $flutterBin = Join-Path $flutterRoot 'bin'
    $env:FLUTTER_ROOT = $flutterRoot

    if ($env:PATH -notlike "*$flutterBin*") {
        $env:PATH = "$flutterBin;$env:PATH"
    }

    if (-not $Quiet) {
        Write-Host "FLUTTER_ROOT=$flutterRoot"
    }

    return $flutterRoot
}

function Repair-PuroWebSdk {
    param(
        [string]$FlutterRoot,
        [switch]$Force
    )

    $flutterRoot = Resolve-FlutterRootPath -Path $FlutterRoot
    $cacheDir = Join-Path $flutterRoot 'bin\cache'
    $webSdkPath = Join-Path $cacheDir 'flutter_web_sdk'
    $markerPath = Join-Path $cacheDir '.puro_web_sdk_materialized'

    if ((Test-Path $markerPath) -and -not $Force) {
        return $false
    }

    if (-not (Test-Path $webSdkPath)) {
        Write-Host "flutter_web_sdk missing; running flutter precache --web..."
        & (Join-Path $flutterRoot 'bin\flutter.bat') precache --web
        if ($LASTEXITCODE -ne 0) {
            throw "flutter precache --web failed with exit code $LASTEXITCODE"
        }
    }

    $item = Get-Item -LiteralPath $webSdkPath -Force -ErrorAction SilentlyContinue
    if (-not $item) {
        throw "flutter_web_sdk not found at $webSdkPath"
    }

    $isReparsePoint = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
    if (-not $isReparsePoint -and (Test-Path $markerPath)) {
        return $false
    }

    if (-not $isReparsePoint) {
        Set-Content -Path $markerPath -Value @(
            "materialized_at=$(Get-Date -Format o)"
            "flutter_root=$flutterRoot"
            "reason=already_real_directory"
        ) -Encoding UTF8
        return $false
    }

    $target = $item.Target
    if ($target -is [array]) {
        $target = $target[0]
    }

    $sourcePath = Resolve-FlutterRootPath -Path $target
    if (-not $sourcePath -or -not (Test-Path $sourcePath)) {
        throw "Could not resolve flutter_web_sdk junction target: $target"
    }

    Write-Host "Materializing Puro flutter_web_sdk (junction -> directory)..."
    Write-Host "  Source: $sourcePath"
    Write-Host "  Target: $webSdkPath"

    Remove-Item -LiteralPath $webSdkPath -Force -Recurse

    $null = New-Item -ItemType Directory -Path $webSdkPath -Force
    & robocopy $sourcePath $webSdkPath /E /NFL /NDL /NJH /NJS /NC /NS /NP
    $robocopyExit = $LASTEXITCODE
    if ($robocopyExit -ge 8) {
        throw "robocopy failed while materializing flutter_web_sdk (exit $robocopyExit)"
    }

    Set-Content -Path $markerPath -Value @(
        "materialized_at=$(Get-Date -Format o)"
        "flutter_root=$flutterRoot"
        "source=$sourcePath"
        "reason=puro_junction_breaks_dart_web_compiler"
    ) -Encoding UTF8

    Write-Host "flutter_web_sdk materialized successfully."
    return $true
}

function Initialize-PuroFlutter {
    param(
        [string]$ProjectRoot,
        [switch]$SkipWebSdkRepair,
        [switch]$Quiet
    )

    if (-not (Test-PuroProject -ProjectRoot $ProjectRoot)) {
        return $null
    }

    $flutterRoot = Get-PuroFlutterRoot -ProjectRoot $ProjectRoot
    Install-PuroFlutterEnv -FlutterRoot $flutterRoot -Quiet:$Quiet | Out-Null

    if (-not $SkipWebSdkRepair) {
        Repair-PuroWebSdk -FlutterRoot $flutterRoot | Out-Null
    }

    return $flutterRoot
}
